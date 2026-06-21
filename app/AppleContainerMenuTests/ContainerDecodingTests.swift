import Foundation
import Testing
@testable import AppleContainerMenu

@Suite("Container decoding", .tags(.unit))
struct ContainerDecodingTests {
    @Test("Decodes top-level id, nested state and image, started date, and ports")
    func decodesRunningRow() throws {
        let container = try Fixtures.decodeContainer(Fixtures.runningRow)

        #expect(container.id == "web")
        #expect(container.state == "running")
        #expect(container.image == "docker.io/library/nginx:latest")
        let started = try #require(container.startedDate)
        #expect(started == ISO8601DateFormatter().date(from: Fixtures.startedDateISO))
        #expect(container.publishedPorts.count == 2)
        #expect(container.publishedPorts.first?.hostPort == 8080)
    }

    @Test("A stopped row has no started date and no published ports")
    func decodesStoppedRow() throws {
        let container = try Fixtures.decodeContainer(Fixtures.stoppedRow)

        #expect(container.id == "db")
        #expect(container.state == "stopped")
        #expect(container.image == "docker.io/library/postgres:16")
        #expect(container.startedDate == nil)
        #expect(container.publishedPorts.isEmpty)
    }

    @Test("A missing image reference decodes to nil, not a failure")
    func decodesMissingImage() throws {
        let json = Fixtures.containerJSON(id: "x", state: "running", startedDateISO: Fixtures.startedDateISO)
        let container = try Fixtures.decodeContainer(json)

        #expect(container.image == nil)
        #expect(container.publishedPorts.isEmpty)
    }

    @Test("A malformed row decodes to nil via LossyContainer; valid rows survive")
    func lossyDropsMalformedRow() throws {
        let rows = try Fixtures.decodeList(Fixtures.listWithOneMalformedRow)

        #expect(rows.count == 2)
        let survivors = rows.compactMap(\.value)
        #expect(survivors.count == 1)
        #expect(survivors.first?.id == "db")
    }

    @Test("The top-level id wins over a nested configuration.id")
    func topLevelIdWins() throws {
        let container = try Fixtures.decodeContainer(Fixtures.idConflictRow)

        #expect(container.id == "real")
    }

    @Test("A published port without count defaults to 1")
    func portCountDefaultsToOne() throws {
        let container = try Fixtures.decodeContainer(Fixtures.portMissingCountRow)

        #expect(container.publishedPorts.first?.count == 1)
        #expect(container.portsSummary == ":7000")
    }
}
