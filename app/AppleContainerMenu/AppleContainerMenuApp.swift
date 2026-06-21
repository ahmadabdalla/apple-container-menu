import AppKit
import SwiftUI

@main
struct AppleContainerMenuApp: App {
    var body: some Scene {
        MenuBarExtra("Apple Container Menu", systemImage: "shippingbox") {
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .menuBarExtraStyle(.menu)
    }
}
