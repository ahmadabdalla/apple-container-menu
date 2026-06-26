import Foundation
import Testing
@testable import AppleContainerMenu

@Suite("Container row labels", .tags(.unit))
struct ContainerLabelTests {
    struct UptimeCase: Sendable {
        let interval: TimeInterval
        let expected: String
    }

    @Test("Running uptime rolls up to s, m, h, then d", arguments: [
        UptimeCase(interval: 5, expected: "up 5s"),
        UptimeCase(interval: 90, expected: "up 1m"),
        UptimeCase(interval: 7200, expected: "up 2h"),
        UptimeCase(interval: 172800, expected: "up 2d"),
    ])
    func runningUptime(_ testCase: UptimeCase) throws {
        let container = try runningContainer()
        let started = try #require(container.startedDate)
        let now = started.addingTimeInterval(testCase.interval)

        #expect(container.uptimeSummary(now: now) == testCase.expected)
    }

    @Test("A stopped row has no uptime")
    func stoppedHasNoUptime() throws {
        let container = try Fixtures.decodeContainer(
            Fixtures.containerJSON(state: "stopped", startedDateISO: Fixtures.startedDateISO)
        )

        #expect(container.uptimeSummary(now: Date.distantFuture) == nil)
    }

    @Test("A running row with no started date has no uptime")
    func runningWithoutStartHasNoUptime() throws {
        let container = try Fixtures.decodeContainer(Fixtures.containerJSON(state: "running"))

        #expect(container.uptimeSummary(now: Date.distantFuture) == nil)
    }

    struct PortsCase: Sendable {
        let ports: [PortPair]
        let expected: String?
    }

    struct PortPair: Sendable {
        let hostPort: Int
        let count: Int
    }

    @Test("Ports summary shows the first host port and a +N for the rest", arguments: [
        PortsCase(ports: [], expected: nil),
        PortsCase(ports: [PortPair(hostPort: 8080, count: 1)], expected: ":8080"),
        PortsCase(ports: [PortPair(hostPort: 8080, count: 1), PortPair(hostPort: 8443, count: 1)], expected: ":8080 +1"),
        PortsCase(ports: [PortPair(hostPort: 9000, count: 3)], expected: ":9000 +2"),
        PortsCase(ports: [PortPair(hostPort: 9000, count: 2), PortPair(hostPort: 9100, count: 1)], expected: ":9000 +2"),
    ])
    func portsSummary(_ testCase: PortsCase) throws {
        let pairs = testCase.ports.map { (hostPort: $0.hostPort, count: $0.count) }
        let container = try Fixtures.decodeContainer(
            Fixtures.containerJSON(state: "running", ports: pairs)
        )

        #expect(container.portsSummary == testCase.expected)
    }

    struct StatusCapsuleCase: Sendable {
        let state: String
        let withStart: Bool
        let expected: String
    }

    @Test("Capsule joins state and uptime when running with a start; bare state otherwise", arguments: [
        StatusCapsuleCase(state: "running", withStart: true, expected: "running · up 2h"),
        StatusCapsuleCase(state: "running", withStart: false, expected: "running"),
        StatusCapsuleCase(state: "stopped", withStart: false, expected: "stopped"),
        StatusCapsuleCase(state: "stopped", withStart: true, expected: "stopped"),
    ])
    func statusCapsule(_ testCase: StatusCapsuleCase) throws {
        let container = try Fixtures.decodeContainer(
            Fixtures.containerJSON(
                state: testCase.state,
                startedDateISO: testCase.withStart ? Fixtures.startedDateISO : nil
            )
        )
        // Two hours after the start instant, so a running container reads "up 2h".
        let now = (container.startedDate ?? Date.distantPast).addingTimeInterval(7200)

        #expect(container.statusCapsule(now: now) == testCase.expected)
    }

    struct AccessibilityLabelCase: Sendable {
        let state: String
        let withStart: Bool
        let ports: [PortPair]
        let expected: String
    }

    @Test("Accessibility label joins name, status capsule, and ports", arguments: [
        AccessibilityLabelCase(state: "running", withStart: true, ports: [PortPair(hostPort: 8080, count: 1)], expected: "web, running · up 2h, port :8080"),
        AccessibilityLabelCase(state: "running", withStart: false, ports: [PortPair(hostPort: 8080, count: 1)], expected: "web, running, port :8080"),
        AccessibilityLabelCase(state: "stopped", withStart: false, ports: [], expected: "web, stopped"),
    ])
    func accessibilityLabel(_ testCase: AccessibilityLabelCase) throws {
        let pairs = testCase.ports.map { (hostPort: $0.hostPort, count: $0.count) }
        let container = try Fixtures.decodeContainer(
            Fixtures.containerJSON(
                id: "web",
                state: testCase.state,
                startedDateISO: testCase.withStart ? Fixtures.startedDateISO : nil,
                ports: pairs
            )
        )
        let now = (container.startedDate ?? Date.distantPast).addingTimeInterval(7200)

        #expect(container.accessibilityLabel(now: now) == testCase.expected)
    }

    struct FilterCase: Sendable {
        let id: String
        let query: String
        let matches: Bool
    }

    @Test("Name filter is a case-insensitive substring; blank matches all", arguments: [
        FilterCase(id: "web", query: "", matches: true),
        FilterCase(id: "web", query: "   ", matches: true),
        FilterCase(id: "web", query: "\t\n", matches: true),
        FilterCase(id: "web-api", query: "API", matches: true),
        FilterCase(id: "web-api", query: "ap", matches: true),
        FilterCase(id: "web", query: "db", matches: false),
    ])
    func filterMatch(_ testCase: FilterCase) throws {
        let container = try Fixtures.decodeContainer(
            Fixtures.containerJSON(id: testCase.id, state: "running")
        )

        #expect(container.matches(filter: testCase.query) == testCase.matches)
    }

    @Test("isRunning is case-insensitive")
    func runningIsCaseInsensitive() throws {
        let container = try Fixtures.decodeContainer(
            Fixtures.containerJSON(state: "RUNNING", startedDateISO: Fixtures.startedDateISO)
        )
        let started = try #require(container.startedDate)

        #expect(container.isRunning)
        #expect(container.uptimeSummary(now: started.addingTimeInterval(5)) == "up 5s")
    }

    private func runningContainer() throws -> Container {
        try Fixtures.decodeContainer(
            Fixtures.containerJSON(state: "running", startedDateISO: Fixtures.startedDateISO)
        )
    }
}
