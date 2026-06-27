import AppKit
import SwiftUI

/// Owns the status item and the SwiftUI popover, and triggers the fetch on open
/// (ADRs 003, 018). `popoverWillShow` is the open hook: the cache renders first
/// and a live fetch updates the open popover in place (ADR 018, superseding the
/// `NSMenu` snapshot of ADR 015). When the user opts in, a poll loop refreshes
/// at the configured interval for as long as the popover stays open (ADR 019).
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    private let store = ContainerStore()
    private var statusItem: NSStatusItem?
    private let popover = NSPopover()
    private var pollTask: Task<Void, Never>?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.image = NSImage(
            systemSymbolName: "shippingbox",
            accessibilityDescription: "Apple Container Menu"
        )
        item.button?.target = self
        item.button?.action = #selector(togglePopover)
        statusItem = item

        let hosting = NSHostingController(rootView: ContainerListView(store: store))
        // Resize the popover as rows appear or disappear under a live update.
        hosting.sizingOptions = .preferredContentSize
        popover.contentViewController = hosting
        popover.behavior = .transient
        popover.delegate = self
    }

    /// Click toggles the popover. The `isShown` guard avoids the
    /// close-then-reopen race on a single button click. The app is
    /// `LSUIElement`, so it stays inactive when the status item is clicked and a
    /// `.transient` popover would not dismiss on an outside click until first
    /// focused; `NSApp.activate` makes the window key immediately so click-away
    /// works like other menu-bar apps (ADR 018).
    @objc private func togglePopover() {
        guard let button = statusItem?.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            NSApp.activate()
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    func popoverWillShow(_ notification: Notification) {
        store.refresh()
        startPolling()
    }

    func popoverDidClose(_ notification: Notification) {
        pollTask?.cancel()
        pollTask = nil
    }

    /// Poll only while the popover is open, and only when the user has opted in.
    /// The loop lives for the whole open and re-reads the settings each pass, so
    /// toggling auto-refresh or the interval mid-open takes effect; it never
    /// polls in the background, preserving the fetch-on-open model (ADRs 009,
    /// 015, 018, 019).
    private func startPolling() {
        pollTask?.cancel()
        pollTask = Task { [weak self] in
            while !Task.isCancelled {
                let interval = UserDefaults.standard.object(forKey: AppSettings.refreshIntervalKey) as? Int
                    ?? AppSettings.defaultRefreshInterval
                try? await Task.sleep(for: .seconds(max(1, interval)))
                if Task.isCancelled { return }
                if UserDefaults.standard.bool(forKey: AppSettings.autoRefreshEnabledKey) {
                    self?.store.refresh()
                }
            }
        }
    }
}
