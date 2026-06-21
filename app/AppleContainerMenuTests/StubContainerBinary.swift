import Foundation

/// Writes a throwaway executable that mimics the `container` CLI's two-command
/// contract (ADR 006): `system status` for the service gate and
/// `ls --all --format json` for the list. The functional tier points
/// `ContainerCLI` at this stub and runs the real `Process` + `Pipe` pipeline,
/// so the deadlock-avoiding concurrent drain, exit-code gate, and ISO8601 decode
/// are all exercised without the real binary or a running service.
///
/// Stays within the safety boundary: a local temp script only, removed by
/// `cleanup()`. No network and no real `container`.
struct StubContainerBinary {
    let url: URL
    private let directory: URL

    /// - Parameters:
    ///   - statusExitCode: exit code for `system status` (0 means service up).
    ///   - listJSON: stdout for `ls`, written verbatim.
    ///   - listExitCode: exit code for `ls`.
    ///   - listStderr: stderr for `ls`, for the error-message path.
    init(
        statusExitCode: Int32 = 0,
        listJSON: String = "[]",
        listExitCode: Int32 = 0,
        listStderr: String = ""
    ) throws {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("acm-stub-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        url = directory.appendingPathComponent("container")

        // Dispatch on the first argument, mirroring the two subcommands fetch()
        // calls. Quoted heredocs keep both the JSON payload and the stderr text
        // intact regardless of quotes or shell metacharacters in fixtures.
        let script = """
        #!/bin/sh
        case "$1" in
        system)
          exit \(statusExitCode)
          ;;
        ls)
          cat <<'STUB_JSON_EOF'
        \(listJSON)
        STUB_JSON_EOF
          cat >&2 <<'STUB_ERR_EOF'
        \(listStderr)
        STUB_ERR_EOF
          exit \(listExitCode)
          ;;
        *)
          exit 64
          ;;
        esac
        """
        try script.write(to: url, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: url.path)
    }

    func cleanup() {
        try? FileManager.default.removeItem(at: directory)
    }
}
