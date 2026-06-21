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

    /// Single inline row: `id  state, up Xh, :port`. A stopped row drops the
    /// uptime clause; ports are appended when published (ADR 010).
    func menuLabel(now: Date) -> String {
        var parts = [state]
        if let uptime = uptimeSummary(now: now) { parts.append(uptime) }
        if let ports = portsSummary { parts.append(ports) }
        return "\(id)  " + parts.joined(separator: ", ")
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
