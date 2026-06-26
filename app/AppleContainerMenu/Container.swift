import Foundation

/// One container row decoded from `container ls --all --format json`.
///
/// Only the five fields the menu needs are modelled (ADR 007); the rest of the
/// large, nested payload is ignored so the JSON can grow without breaking.
struct Container: Decodable, Identifiable {
    /// The container `id` is its display name; there is no separate name field.
    let id: String
    let state: String
    let image: String?
    let startedDate: Date?
    let publishedPorts: [PublishedPort]

    var isRunning: Bool { state.lowercased() == "running" }

    /// Relative uptime, running containers only. A stopped container has none.
    func uptimeSummary(now: Date) -> String? {
        guard isRunning, let startedDate else { return nil }
        let seconds = Int(max(0, now.timeIntervalSince(startedDate)))
        if seconds >= 86400 { return "up \(seconds / 86400)d" }
        if seconds >= 3600 { return "up \(seconds / 3600)h" }
        if seconds >= 60 { return "up \(seconds / 60)m" }
        return "up \(seconds)s"
    }

    /// First published host port, with `+N` when more are published (ADR 010).
    /// A single entry can publish a range via `count`, so extras are counted
    /// from the total published ports, not the array length.
    var portsSummary: String? {
        guard let first = publishedPorts.first else { return nil }
        let total = publishedPorts.reduce(0) { $0 + $1.count }
        let base = ":\(first.hostPort)"
        let extra = total - 1
        return extra > 0 ? "\(base) +\(extra)" : base
    }

    /// Status token for a row: `running · up 22h` when running with a known
    /// start, or just the state word otherwise (a stopped row, or a running
    /// one with no start date). Ports are not joined in; the chip is a separate
    /// element (ADR 018).
    func statusCapsule(now: Date) -> String {
        guard let uptime = uptimeSummary(now: now) else { return state }
        return "\(state) · \(uptime)"
    }

    /// Combined VoiceOver label for a row: name, then the status capsule, then
    /// the ports when published (ADRs 018, 019). A pure helper so the spoken
    /// composition stays unit-testable rather than living only in the view.
    func accessibilityLabel(now: Date) -> String {
        var parts = [id, statusCapsule(now: now)]
        if let ports = portsSummary { parts.append("port \(ports)") }
        return parts.joined(separator: ", ")
    }

    /// Case-insensitive substring match on the name for the live filter (ADR
    /// 019). An empty or whitespace-only query matches every row.
    func matches(filter query: String) -> Bool {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return true }
        return id.range(of: trimmed, options: .caseInsensitive) != nil
    }

    private enum CodingKeys: String, CodingKey {
        case id, status, configuration
    }

    private enum StatusKeys: String, CodingKey {
        case state, startedDate
    }

    private enum ConfigurationKeys: String, CodingKey {
        case image, publishedPorts
    }

    private enum ImageKeys: String, CodingKey {
        case reference
    }

    init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        // Decode the top-level id; `configuration.id` is a different field.
        id = try root.decode(String.self, forKey: .id)

        let status = try root.nestedContainer(keyedBy: StatusKeys.self, forKey: .status)
        state = try status.decode(String.self, forKey: .state)
        startedDate = try status.decodeIfPresent(Date.self, forKey: .startedDate)

        let configuration = try root.nestedContainer(keyedBy: ConfigurationKeys.self, forKey: .configuration)
        // image is reserved for a later detail view (ADR 007); decode it
        // optionally so a missing or reshaped reference never fails the whole
        // list and blanks the menu.
        if let image = try? configuration.nestedContainer(keyedBy: ImageKeys.self, forKey: .image) {
            self.image = try image.decodeIfPresent(String.self, forKey: .reference)
        } else {
            self.image = nil
        }
        publishedPorts = try configuration.decodeIfPresent([PublishedPort].self, forKey: .publishedPorts) ?? []
    }
}

/// A published port mapping. Only `hostPort` is needed for the row; the rest
/// are optional so a payload shape change cannot fail the whole list. A single
/// entry can represent a range of `count` consecutive ports.
struct PublishedPort: Decodable {
    let hostPort: Int
    let containerPort: Int?
    let proto: String?
    let count: Int

    private enum CodingKeys: String, CodingKey {
        case hostPort, containerPort, proto, count
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hostPort = try container.decode(Int.self, forKey: .hostPort)
        containerPort = try container.decodeIfPresent(Int.self, forKey: .containerPort)
        proto = try container.decodeIfPresent(String.self, forKey: .proto)
        count = try container.decodeIfPresent(Int.self, forKey: .count) ?? 1
    }
}

/// Wraps a `Container` so a single malformed row in the `ls` array decodes to
/// `nil` instead of throwing and failing the whole list. The caller drops the
/// nil rows, so one bad entry degrades to a missing row rather than a blank
/// menu (ADR 007).
struct LossyContainer: Decodable {
    let value: Container?

    init(from decoder: Decoder) throws {
        value = try? Container(from: decoder)
    }
}
