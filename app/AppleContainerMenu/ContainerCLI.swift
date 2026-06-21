import Foundation

/// Resolves the `container` binary and runs the two-command fetch flow off the
/// main thread (ADRs 004, 006, 012).
struct ContainerCLI {
    /// Apple silicon install locations, Homebrew first (ADR 004).
    static let candidatePaths = [
        "/opt/homebrew/bin/container",
        "/usr/local/bin/container",
    ]

    /// Per-command wall-clock budget (ADR 012, additive). A wedged `container`
    /// invocation that never exits or never closes its pipes is terminated after
    /// this, so a refresh cannot block indefinitely. Typical fetch is ~33ms, so
    /// this only fires on a genuine hang.
    static let commandTimeout: Duration = .seconds(5)

    /// Resolves the `container` binary, or nil for the CLI-not-found state.
    typealias BinaryResolver = @Sendable () -> URL?
    /// Runs a resolved binary and returns its captured result.
    typealias ProcessRunner = @Sendable (URL, [String]) async throws -> ProcessResult

    /// A `container` invocation that exceeded `commandTimeout`. Mapped in
    /// `fetch()` to `.error` (ADR 005) with a user-facing message.
    struct TimeoutError: LocalizedError {
        var errorDescription: String? { "container command timed out" }
    }

    /// The two seams `fetch()` runs through. Production wires the live
    /// `FileManager` scan and `Process` + `Pipe` flow; tests inject fakes (unit)
    /// or a stub binary resolver over the real runner (functional). Both are
    /// defaulted so `ContainerCLI()` call sites are unchanged.
    private let resolveBinary: BinaryResolver
    private let run: ProcessRunner

    init(
        resolveBinary: @escaping BinaryResolver = ContainerCLI.defaultResolveBinary,
        run: @escaping ProcessRunner = ContainerCLI.defaultRun
    ) {
        self.resolveBinary = resolveBinary
        self.run = run
    }

    /// First candidate path that exists, or nil for the CLI-not-found state.
    @Sendable static func defaultResolveBinary() -> URL? {
        for path in candidatePaths where FileManager.default.fileExists(atPath: path) {
            return URL(fileURLWithPath: path)
        }
        return nil
    }

    /// Gate on `system status` exit code, then `ls`, mapping to a MenuState
    /// (ADR 006). Never throws: failures resolve to `.error`.
    func fetch() async -> MenuState {
        guard let binary = resolveBinary() else { return .cliNotFound }

        do {
            let status = try await run(binary, ["system", "status"])
            guard status.terminationStatus == 0 else { return .serviceNotRunning }

            let list = try await run(binary, ["ls", "--all", "--format", "json"])
            guard list.terminationStatus == 0 else {
                return .error(Self.message(from: list.stderr) ?? Self.message(from: list.stdout) ?? "container ls failed")
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            // Decode leniently so one malformed row degrades to a dropped row,
            // not a blank menu (ADR 007). A non-array payload still throws into
            // the error state below; a non-empty list that parses to nothing is
            // a real failure, not "no containers".
            let rows = try decoder.decode([LossyContainer].self, from: list.stdout)
            let containers = rows.compactMap(\.value)
            if rows.isEmpty { return .empty }
            if containers.isEmpty { return .error("could not parse container list") }
            return .populated(containers)
        } catch {
            return .error(error.localizedDescription)
        }
    }

    struct ProcessResult: Sendable {
        let terminationStatus: Int32
        let stdout: Data
        let stderr: Data
    }

    /// Run a binary and capture stdout and stderr. Both pipes are drained
    /// concurrently on detached tasks: reading only one risks a deadlock if the
    /// child fills the other pipe's buffer and blocks. The main thread never
    /// blocks (ADR 012). A wedged child is bounded by `commandTimeout`.
    @Sendable private static func defaultRun(_ url: URL, _ arguments: [String]) async throws -> ProcessResult {
        try await liveRun(url, arguments, timeout: commandTimeout)
    }

    /// The live `Process` + `Pipe` pipeline with an explicit timeout. Exposed
    /// (internal) so functional tests can drive a hanging stub with a short
    /// budget instead of waiting `commandTimeout`.
    static func liveRun(_ url: URL, _ arguments: [String], timeout: Duration) async throws -> ProcessResult {
        let process = Process()
        process.executableURL = url
        process.arguments = arguments
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        try process.run()

        async let stdoutData = Self.readToEnd(stdoutPipe)
        async let stderrData = Self.readToEnd(stderrPipe)

        // Race process exit against the deadline and cooperative cancellation.
        // On either, the child is terminated, which closes its pipe write ends
        // so both readers reach EOF; the drain below then returns promptly.
        //
        // Boundary: this bounds a wedged *single* process. The two commands run
        // here (`system status`, `ls`) are short-lived CLI clients that do not
        // fork a backgrounded child inheriting these pipes (the daemon is
        // launchd-managed, not spawned by us), so terminating the child reliably
        // reaches EOF. A hypothetical orphaned grandchild holding a write end
        // could delay this drain, but it runs off-main, so the menu still
        // renders the last-known cache (ADR 009) and never blocks.
        let outcome = await Self.waitForExit(process, timeout: timeout)
        let (out, err) = await (stdoutData, stderrData)

        switch outcome {
        case .exited:
            return ProcessResult(terminationStatus: process.terminationStatus, stdout: out, stderr: err)
        case .timedOut:
            throw TimeoutError()
        case .cancelled:
            throw CancellationError()
        }
    }

    private enum ExitOutcome: Sendable {
        case exited
        case timedOut
        case cancelled
    }

    /// Wait for the child to exit, the deadline to pass, or this task to be
    /// cancelled, whichever comes first. On the latter two the child is
    /// terminated so the blocking exit wait and both pipe readers unblock; the
    /// returned outcome never resolves until the child is actually gone.
    private static func waitForExit(_ process: Process, timeout: Duration) async -> ExitOutcome {
        // Detached so a blocking `waitUntilExit()` never ties up a cooperative
        // pool thread; it returns once the child dies (naturally or terminated).
        let exited = Task.detached(priority: .utility) { process.waitUntilExit() }

        return await withTaskGroup(of: ExitOutcome.self) { group in
            group.addTask {
                await exited.value
                return .exited
            }
            group.addTask {
                // Cancellation (a superseded refresh) surfaces as a throw here.
                do {
                    try await Task.sleep(for: timeout)
                    return .timedOut
                } catch {
                    return .cancelled
                }
            }

            let first = await group.next() ?? .exited
            if first != .exited {
                Self.terminate(process)
            }
            group.cancelAll()
            return first
        }
    }

    /// Stop a runaway child: SIGTERM first, then SIGKILL after a short grace if
    /// it ignores the polite signal, so a child that traps SIGTERM still cannot
    /// hang the caller.
    private static func terminate(_ process: Process) {
        guard process.isRunning else { return }
        process.terminate()
        Task.detached(priority: .utility) {
            try? await Task.sleep(for: .milliseconds(500))
            if process.isRunning {
                kill(process.processIdentifier, SIGKILL)
            }
        }
    }

    private static func readToEnd(_ pipe: Pipe) async -> Data {
        await Task.detached(priority: .utility) {
            pipe.fileHandleForReading.readDataToEndOfFile()
        }.value
    }

    private static func message(from data: Data) -> String? {
        let text = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }
}
