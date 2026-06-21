import Foundation

/// Resolves the `container` binary and runs the two-command fetch flow off the
/// main thread (ADRs 004, 006, 012).
struct ContainerCLI {
    /// Apple silicon install locations, Homebrew first (ADR 004).
    static let candidatePaths = [
        "/opt/homebrew/bin/container",
        "/usr/local/bin/container",
    ]

    /// First candidate path that exists, or nil for the CLI-not-found state.
    func resolveBinary() -> URL? {
        for path in Self.candidatePaths where FileManager.default.fileExists(atPath: path) {
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
            let containers = try decoder.decode([Container].self, from: list.stdout)
            return containers.isEmpty ? .empty : .populated(containers)
        } catch {
            return .error(error.localizedDescription)
        }
    }

    private struct ProcessResult {
        let terminationStatus: Int32
        let stdout: Data
        let stderr: Data
    }

    /// Run a binary and capture stdout and stderr. Both pipes are drained
    /// concurrently on detached tasks: reading only one risks a deadlock if the
    /// child fills the other pipe's buffer and blocks. The main thread never
    /// blocks (ADR 012).
    private func run(_ url: URL, _ arguments: [String]) async throws -> ProcessResult {
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
        let (out, err) = await (stdoutData, stderrData)

        // Both pipes are at EOF, so the child has closed its write ends; this
        // returns promptly and yields a valid termination status.
        process.waitUntilExit()
        return ProcessResult(terminationStatus: process.terminationStatus, stdout: out, stderr: err)
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
