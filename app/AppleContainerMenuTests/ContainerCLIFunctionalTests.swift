import Foundation
import Testing
@testable import AppleContainerMenu

/// Functional tier: drive the real `Process` + `Pipe` pipeline through a stub
/// `container` binary. Proves the two-command gate (ADR 006), the concurrent
/// pipe drain (ADR 012), ISO8601 decoding, and state mapping end to end, with no
/// fake runner in the path.
@Suite("ContainerCLI.fetch pipeline", .tags(.functional))
struct ContainerCLIFunctionalTests {
    @Test("A populated list flows through the real process pipeline")
    func populatedThroughRealProcess() async throws {
        let stub = try StubContainerBinary(listJSON: Fixtures.populatedList)
        defer { stub.cleanup() }
        let cli = ContainerCLI(resolveBinary: { stub.url })

        let containers = await cli.fetch().containers
        #expect(containers?.count == 2)
        #expect(containers?.first?.id == "web")
        #expect(containers?.first?.startedDate != nil)
    }

    @Test("A non-zero system status gates before ls and maps to serviceNotRunning")
    func serviceDownGatesBeforeList() async throws {
        let stub = try StubContainerBinary(statusExitCode: 1, listJSON: Fixtures.populatedList)
        defer { stub.cleanup() }
        let cli = ContainerCLI(resolveBinary: { stub.url })

        #expect(await cli.fetch().isServiceNotRunning)
    }

    @Test("A non-zero ls surfaces its stderr through the real pipe")
    func listErrorThroughRealProcess() async throws {
        let stub = try StubContainerBinary(listExitCode: 1, listStderr: "container ls exploded")
        defer { stub.cleanup() }
        let cli = ContainerCLI(resolveBinary: { stub.url })

        #expect(await cli.fetch().errorMessage == "container ls exploded")
    }
}
