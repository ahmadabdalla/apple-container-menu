import Foundation
@testable import AppleContainerMenu

/// Builds `ContainerCLI` seams for the unit tier: a fixed binary resolver and a
/// fake `ProcessRunner` that returns canned results, dispatched by the first
/// argument (`system status` vs `ls`). No subprocess runs, so these tests are
/// deterministic and fast.
enum FakeCLI {
    static let binary = URL(fileURLWithPath: "/stub/container")

    static func result(_ code: Int32, stdout: String = "", stderr: String = "") -> ContainerCLI.ProcessResult {
        ContainerCLI.ProcessResult(
            terminationStatus: code,
            stdout: Data(stdout.utf8),
            stderr: Data(stderr.utf8)
        )
    }

    /// A runner that answers `system status` with `status` and `ls` with `list`.
    static func runner(
        status: ContainerCLI.ProcessResult = result(0),
        list: ContainerCLI.ProcessResult
    ) -> ContainerCLI.ProcessRunner {
        { _, arguments in
            arguments.first == "system" ? status : list
        }
    }

    /// A `ContainerCLI` wired to a resolved stub binary and the given runner.
    static func cli(_ runner: @escaping ContainerCLI.ProcessRunner) -> ContainerCLI {
        ContainerCLI(resolveBinary: { binary }, run: runner)
    }
}
