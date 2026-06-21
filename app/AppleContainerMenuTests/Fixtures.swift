import Foundation
@testable import AppleContainerMenu

/// Realistic `container ls --all --format json` payloads and a JSON container
/// builder. Encodes the CLI contract this app decodes (ADRs 002, 007 and
/// `docs/reference/cli-json-output.md`) in one place so both tiers reuse the same
/// shape: the unit tier decodes these strings, the functional tier feeds them to
/// the stub binary.
enum Fixtures {
    /// A fixed ISO8601 start instant, so uptime math in tests is deterministic.
    static let startedDateISO = "2026-06-21T00:00:00Z"

    /// One running container: image plus two published host ports.
    static let runningRow = """
    {
      "id": "web",
      "status": { "state": "running", "startedDate": "\(startedDateISO)" },
      "configuration": {
        "image": { "reference": "docker.io/library/nginx:latest" },
        "publishedPorts": [
          { "hostPort": 8080, "containerPort": 80, "proto": "tcp", "count": 1 },
          { "hostPort": 8443, "containerPort": 443, "proto": "tcp", "count": 1 }
        ]
      }
    }
    """

    /// A stopped container: no `startedDate`, no `publishedPorts`.
    static let stoppedRow = """
    {
      "id": "db",
      "status": { "state": "stopped" },
      "configuration": {
        "image": { "reference": "docker.io/library/postgres:16" }
      }
    }
    """

    /// A row missing the required top-level `id`: decodes to nil via
    /// `LossyContainer` rather than failing the whole list (ADR 007).
    static let malformedRow = """
    { "status": { "state": "running" }, "configuration": {} }
    """

    /// Wrap rows in a JSON array, matching the `ls` payload.
    static func array(_ rows: String...) -> String {
        "[\n" + rows.joined(separator: ",\n") + "\n]"
    }

    static let populatedList = array(runningRow, stoppedRow)
    static let emptyList = "[]"
    static let listWithOneMalformedRow = array(malformedRow, stoppedRow)

    /// Every row malformed: a non-empty list that parses to nothing, which is a
    /// real failure rather than "no containers".
    static let allMalformedList = array(malformedRow, malformedRow)

    /// A published port with no `count`: it must default to 1 (ADR 007).
    static let portMissingCountRow = """
    {
      "id": "svc",
      "status": { "state": "running", "startedDate": "\(startedDateISO)" },
      "configuration": {
        "publishedPorts": [ { "hostPort": 7000 } ]
      }
    }
    """

    /// A nested `configuration.id` that differs from the top-level `id`: the
    /// top-level value must win.
    static let idConflictRow = """
    {
      "id": "real",
      "status": { "state": "running" },
      "configuration": { "id": "wrong", "image": { "reference": "img" } }
    }
    """

    /// A non-array payload: forces a decode failure into the error state.
    static let nonArrayPayload = #"{ "unexpected": true }"#

    /// Build a single-container JSON string for helper tests. Only the fields a
    /// menu row renders are modelled; ports take `(hostPort, count)` pairs.
    static func containerJSON(
        id: String = "c",
        state: String = "running",
        startedDateISO: String? = nil,
        image: String? = nil,
        ports: [(hostPort: Int, count: Int)] = []
    ) -> String {
        var status = "\"state\": \"\(state)\""
        if let startedDateISO { status += ", \"startedDate\": \"\(startedDateISO)\"" }

        var configuration = ""
        if let image { configuration += "\"image\": { \"reference\": \"\(image)\" }" }
        if !ports.isEmpty {
            let entries = ports
                .map { "{ \"hostPort\": \($0.hostPort), \"count\": \($0.count) }" }
                .joined(separator: ", ")
            if !configuration.isEmpty { configuration += ", " }
            configuration += "\"publishedPorts\": [\(entries)]"
        }

        return """
        { "id": "\(id)", "status": { \(status) }, "configuration": { \(configuration) } }
        """
    }

    /// Decode one `Container` the way `fetch()` does (ISO8601 dates).
    static func decodeContainer(_ json: String) throws -> Container {
        try decoder().decode(Container.self, from: Data(json.utf8))
    }

    /// Decode the lossy `ls` array the way `fetch()` does.
    static func decodeList(_ json: String) throws -> [LossyContainer] {
        try decoder().decode([LossyContainer].self, from: Data(json.utf8))
    }

    private static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
