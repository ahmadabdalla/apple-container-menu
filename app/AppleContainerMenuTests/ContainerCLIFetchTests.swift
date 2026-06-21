import Foundation
import Testing
@testable import AppleContainerMenu

/// Unit tier: `fetch()` state mapping with a fake runner, no subprocess.
@Suite("ContainerCLI.fetch mapping", .tags(.unit))
struct ContainerCLIFetchTests {
    @Test("No resolvable binary maps to cliNotFound")
    func cliNotFound() async {
        let cli = ContainerCLI(resolveBinary: { nil }, run: FakeCLI.runner(list: FakeCLI.result(0)))

        #expect(await cli.fetch().isCLINotFound)
    }

    @Test("A non-zero system status maps to serviceNotRunning")
    func serviceNotRunning() async {
        let cli = FakeCLI.cli(FakeCLI.runner(status: FakeCLI.result(1), list: FakeCLI.result(0)))

        #expect(await cli.fetch().isServiceNotRunning)
    }

    @Test("An empty list maps to empty")
    func emptyList() async {
        let cli = FakeCLI.cli(FakeCLI.runner(list: FakeCLI.result(0, stdout: Fixtures.emptyList)))

        #expect(await cli.fetch().isEmpty)
    }

    @Test("A populated list maps to populated with decoded containers")
    func populatedList() async {
        let cli = FakeCLI.cli(FakeCLI.runner(list: FakeCLI.result(0, stdout: Fixtures.populatedList)))

        let containers = await cli.fetch().containers
        #expect(containers?.count == 2)
        #expect(containers?.first?.id == "web")
    }

    @Test("A non-zero ls maps to error, preferring stderr text")
    func listError() async {
        let cli = FakeCLI.cli(FakeCLI.runner(list: FakeCLI.result(1, stdout: "noise", stderr: "ls blew up")))

        #expect(await cli.fetch().errorMessage == "ls blew up")
    }

    @Test("A non-array payload maps to error")
    func decodeFailure() async {
        let cli = FakeCLI.cli(FakeCLI.runner(list: FakeCLI.result(0, stdout: Fixtures.nonArrayPayload)))

        #expect(await cli.fetch().errorMessage != nil)
    }

    @Test("A non-empty list that all fails to parse maps to a parse error")
    func allRowsMalformed() async {
        let cli = FakeCLI.cli(FakeCLI.runner(list: FakeCLI.result(0, stdout: Fixtures.allMalformedList)))

        #expect(await cli.fetch().errorMessage == "could not parse container list")
    }

    @Test("An ls error with empty stderr falls back to stdout text")
    func listErrorFallsBackToStdout() async {
        let cli = FakeCLI.cli(FakeCLI.runner(list: FakeCLI.result(1, stdout: "stdout boom", stderr: "")))

        #expect(await cli.fetch().errorMessage == "stdout boom")
    }

    @Test("fetch runs the two-command flow with exact arguments")
    func issuesExactTwoCommandFlow() async {
        let recorder = CommandRecorder()
        let cli = ContainerCLI(resolveBinary: { FakeCLI.binary }) { _, arguments in
            await recorder.record(arguments)
            return arguments.first == "system"
                ? FakeCLI.result(0)
                : FakeCLI.result(0, stdout: Fixtures.emptyList)
        }

        _ = await cli.fetch()

        #expect(await recorder.commands == [["system", "status"], ["ls", "--all", "--format", "json"]])
    }
}

/// Records the argument vectors a fake runner is called with, so tests can assert
/// the exact two-command contract (ADR 006) rather than just `arguments.first`.
private actor CommandRecorder {
    private(set) var commands: [[String]] = []

    func record(_ arguments: [String]) {
        commands.append(arguments)
    }
}
