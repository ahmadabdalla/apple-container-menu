import AppKit
import SwiftUI

/// Root of the popover (ADR 018). Renders the six-state model (ADR 005) as
/// SwiftUI, updating in place when `store.state` changes under a live fetch.
/// A bottom chrome bar (Refresh, Settings, Quit) is present in every state; the
/// gear swaps the content for the inline settings panel (ADR 019).
struct ContainerListView: View {
    let store: ContainerStore

    @State private var filter = ""
    @State private var showingSettings = false

    /// Fixed width; the populated list scrolls under a capped height. No
    /// background is painted: `NSPopover` draws its own vibrant material and is
    /// the only thing that fills the arrow notch (ADR 018).
    private let popoverWidth: CGFloat = 390
    private let listMaxHeight: CGFloat = 360

    var body: some View {
        VStack(spacing: 0) {
            if showingSettings {
                SettingsPanelView()
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                content
            }
            Divider()
            chromeBar
        }
        .frame(width: popoverWidth)
        // Each open should start on the list with no stale filter; the
        // hosting controller is long-lived, so reset when the popover closes.
        .onDisappear {
            filter = ""
            showingSettings = false
        }
    }

    @ViewBuilder
    private var content: some View {
        switch store.state {
        case .loading:
            infoView("Checking...")
        case .cliNotFound:
            infoView("container CLI not found")
        case .serviceNotRunning:
            infoView("container service stopped")
        case .empty:
            infoView("No containers")
        case .error(let message):
            infoView("Error: \(message)")
        case .populated(let containers):
            populatedView(containers)
        }
    }

    @ViewBuilder
    private func populatedView(_ containers: [Container]) -> some View {
        let now = Date()
        let filtered = containers.filter { $0.matches(filter: filter) }
        VStack(spacing: 0) {
            filterField
            Divider()
            if filtered.isEmpty {
                infoView("No matches")
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filtered) { container in
                            ContainerRowView(container: container, now: now)
                            Divider()
                        }
                    }
                }
                .frame(maxHeight: listMaxHeight)
            }
        }
    }

    private var filterField: some View {
        HStack(spacing: 6) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .foregroundStyle(.secondary)
            TextField("Filter by name", text: $filter)
                .textFieldStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func infoView(_ text: String) -> some View {
        Text(text)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
    }

    private var chromeBar: some View {
        HStack(spacing: 12) {
            Button("Refresh") { store.refresh() }
            Spacer()
            Button {
                showingSettings.toggle()
            } label: {
                Image(systemName: "gearshape")
            }
            .help("Settings")
            Button("Quit") { NSApplication.shared.terminate(nil) }
        }
        .buttonStyle(.borderless)
        .padding(.horizontal, 12)
        .padding(.top, 8)
        // Extra bottom inset lifts the controls clear of the popover's rounded
        // bottom corners, where they otherwise crowd the curve.
        .padding(.bottom, 14)
    }
}

/// One container row (ADR 018): a leading box icon, the name with a dim image
/// line beneath, and a trailing group pinned to the edge holding the port chip
/// (when published) and the status token, so the status dots align in a column.
struct ContainerRowView: View {
    let container: Container
    let now: Date

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "shippingbox")
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(container.id)
                    .lineLimit(1)
                    .truncationMode(.tail)
                if let image = container.image {
                    Text(image)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }

            Spacer(minLength: 8)

            HStack(spacing: 6) {
                if let ports = container.portsSummary,
                   let hostPort = container.publishedPorts.first?.hostPort {
                    PortChip(summary: ports, hostPort: hostPort)
                }
                statusToken
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(container.accessibilityLabel(now: now))
        // The collapsed row hides the PortChip button from VoiceOver, so expose
        // the open action at the row level (ADRs 018, 019).
        .accessibilityActions {
            if let hostPort = container.publishedPorts.first?.hostPort {
                Button("Open port") { PortChip.open(hostPort: hostPort) }
            }
        }
    }

    /// State word plus uptime, then the dot as the rightmost element so dots
    /// align across rows. Shape and colour are paired: filled green when
    /// running, hollow grey ring when stopped (ADR 018, carried from ADR 010).
    private var statusToken: some View {
        HStack(spacing: 5) {
            Text(container.statusCapsule(now: now))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            Image(systemName: container.isRunning ? "circle.fill" : "circle")
                .font(.system(size: 9))
                .foregroundStyle(container.isRunning ? Color.green : Color.secondary)
        }
    }
}

/// Accent capsule showing the published host port(s). The only row action
/// (ADR 019): a click opens `http://localhost:<hostPort>` for the first port.
/// Opening a URL is not a container mutation, so ADR 001 read-only holds. The
/// chip is built only when a host port exists, so the port is non-optional.
struct PortChip: View {
    let summary: String
    let hostPort: Int

    var body: some View {
        Button {
            PortChip.open(hostPort: hostPort)
        } label: {
            Text(summary)
                .font(.caption)
                .foregroundStyle(.tint)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(Color.accentColor.opacity(0.15)))
        }
        .buttonStyle(.plain)
        .help("Open http://localhost:\(hostPort)")
    }

    /// Shared by the chip and the row-level accessibility action.
    static func open(hostPort: Int) {
        if let url = URL(string: "http://localhost:\(hostPort)") {
            NSWorkspace.shared.open(url)
        }
    }
}
