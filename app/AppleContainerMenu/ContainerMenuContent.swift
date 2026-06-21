import AppKit
import SwiftUI

/// Menu contents for every state (ADR 005), rendered as native single-line
/// items with fixed Refresh and Quit below the list (ADRs 008, 010).
struct ContainerMenuContent: View {
    @ObservedObject var store: ContainerStore

    var body: some View {
        switch store.state {
        case .loading:
            Text("Checking...")
        case .cliNotFound:
            Text("container CLI not found")
        case .serviceNotRunning:
            Text("container service stopped")
        case .empty:
            Text("No containers")
        case .error(let message):
            Text("Error: \(message)")
        case .populated(let containers):
            let now = Date()
            ForEach(containers) { container in
                Text(container.menuLabel(now: now))
            }
        }

        Divider()

        Button("Refresh") { store.refresh() }
            .keyboardShortcut("r")
        Button("Quit") { NSApplication.shared.terminate(nil) }
            .keyboardShortcut("q")
    }
}
