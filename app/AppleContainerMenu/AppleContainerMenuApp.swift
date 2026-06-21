import AppKit
import SwiftUI

@main
struct AppleContainerMenuApp: App {
    @StateObject private var store = ContainerStore()

    var body: some Scene {
        MenuBarExtra("Apple Container Menu", systemImage: "shippingbox") {
            ContainerMenuContent(store: store)
        }
        .menuBarExtraStyle(.menu)
    }
}
