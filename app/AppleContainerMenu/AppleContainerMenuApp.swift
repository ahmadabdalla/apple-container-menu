import SwiftUI

@main
struct AppleContainerMenuApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // The UI is an AppKit NSStatusItem with a SwiftUI popover, managed by
        // AppDelegate (ADR 018).
        // An LSUIElement app still needs a scene; this empty one adds no window.
        Settings {
            EmptyView()
        }
    }
}
