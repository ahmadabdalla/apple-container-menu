import AppKit

/// Owns the status item and its menu, and triggers the fetch on open (ADRs 003,
/// 015). `menuWillOpen` is the reliable open hook AppKit gives us: it renders the
/// last-known cache synchronously, then kicks an async refresh that updates the
/// cache for the next open (ADR 009). The menu never blocks on the CLI.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private let store = ContainerStore()
    private var statusItem: NSStatusItem?
    private let menu = NSMenu()

    func applicationDidFinishLaunching(_ notification: Notification) {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.image = NSImage(
            systemSymbolName: "shippingbox",
            accessibilityDescription: "Apple Container Menu"
        )
        menu.delegate = self
        menu.autoenablesItems = false
        item.menu = menu
        statusItem = item
        rebuildMenu()
    }

    /// Render the last-known cache for this open, then refresh for the next one.
    /// The refresh is async and non-blocking; the result cannot re-render this
    /// open (the runloop is blocked while the menu is up, ADR 015), so it lands
    /// in the cache and surfaces on the following open (ADR 009).
    func menuWillOpen(_ menu: NSMenu) {
        rebuildMenu()
        store.refresh()
    }

    /// Map the six-state model (ADR 005) to native single-line items, with
    /// Refresh and Quit fixed below the list (ADR 010). Informational rows are
    /// disabled because the app is read-only (ADR 001).
    private func rebuildMenu() {
        menu.removeAllItems()

        switch store.state {
        case .loading:
            menu.addItem(infoItem("Checking..."))
        case .cliNotFound:
            menu.addItem(infoItem("container CLI not found"))
        case .serviceNotRunning:
            menu.addItem(infoItem("container service stopped"))
        case .empty:
            menu.addItem(infoItem("No containers"))
        case .error(let message):
            menu.addItem(infoItem("Error: \(message)"))
        case .populated(let containers):
            let now = Date()
            for container in containers {
                menu.addItem(infoItem(container.menuLabel(now: now)))
            }
        }

        menu.addItem(.separator())

        let refresh = NSMenuItem(
            title: "Refresh",
            action: #selector(refreshClicked),
            keyEquivalent: "r"
        )
        refresh.target = self
        menu.addItem(refresh)

        let quit = NSMenuItem(
            title: "Quit",
            action: #selector(quitClicked),
            keyEquivalent: "q"
        )
        quit.target = self
        menu.addItem(quit)
    }

    private func infoItem(_ title: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.isEnabled = false
        return item
    }

    @objc private func refreshClicked() {
        store.refresh()
    }

    @objc private func quitClicked() {
        NSApplication.shared.terminate(nil)
    }
}
