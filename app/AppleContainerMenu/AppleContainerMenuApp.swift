import SwiftUI

@main
struct AppleContainerMenuApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // The UI is an AppKit NSStatusItem managed by AppDelegate (ADR 015).
        // An LSUIElement app still needs a scene; this empty one adds no window.
        Settings {
            EmptyView()
        }
    }
}
