import Foundation
import Testing
@testable import AppleContainerMenu

/// Functional tier: prove the subprocess timeout and cancellation paths against
/// a real `Process` driving a stub that never exits (issue #14). Both run the
/// production `liveRun` pipeline with a short, injected budget so a wedged child
/// is bounded instead of hanging the menu (ADR 012, additive).
@Suite("ContainerCLI subprocess timeout", .tags(.functional))
struct ContainerCLITimeoutTests {
    /// Wires `ContainerCLI` to the real pipeline with an explicit per-command
    /// budget, so a test need not wait the production `commandTimeout`.
    private static func cli(_ stub: StubContainerBinary, timeout: Duration) -> ContainerCLI {
        ContainerCLI(resolveBinary: { stub.url }) { url, arguments in
            try await ContainerCLI.liveRun(url, arguments, timeout: timeout)
        }
    }

    @Test("A hung command is terminated and mapped to a timeout error")
    func hungCommandTimesOut() async throws {
        let stub = try StubContainerBinary(statusHangs: true)
        defer { stub.cleanup() }
        let cli = Self.cli(stub, timeout: .milliseconds(200))

        let clock = ContinuousClock()
        let start = clock.now
        let state = await cli.fetch()
        let elapsed = clock.now - start

        #expect(state.errorMessage == "container command timed out")
        // Bounded: resolves near the budget, never hangs the caller.
        #expect(elapsed < .seconds(3))
    }

    @Test("Cancelling a superseded refresh terminates the in-flight process")
    func cancellationTerminatesProcess() async throws {
        let stub = try StubContainerBinary(statusHangs: true)
        defer { stub.cleanup() }
        // A long budget proves cancellation, not the deadline, is what unblocks.
        let cli = Self.cli(stub, timeout: .seconds(30))

        let fetch = Task { await cli.fetch() }
        // Let the child actually launch before superseding the refresh.
        try await Task.sleep(for: .milliseconds(200))

        let clock = ContinuousClock()
        let start = clock.now
        fetch.cancel()
        _ = await fetch.value
        let elapsed = clock.now - start

        // Resolves on cancellation, far below the 30s budget; the process was
        // terminated rather than waited out.
        #expect(elapsed < .seconds(3))
    }
}
