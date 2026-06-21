---
type: Reference
title: SwiftUI MenuBarExtra API
description: MenuBarExtra and the .menu style are available on macOS 13 and later.
timestamp: 2026-06-21
tags: [swiftui, menubarextra, macos, reference]
resource: https://developer.apple.com/documentation/swiftui/menubarextra
---

# SwiftUI MenuBarExtra API

The app no longer uses `MenuBarExtra`: the `.menu` style has no menu-open hook, so
the menu now renders from an AppKit `NSStatusItem` (see
[nsstatusitem-menu-open](nsstatusitem-menu-open.md) and
[decision 015](../decisions/015-appkit-status-item-open-trigger.md)). The API facts
below are kept for reference.

`MenuBarExtra` creates a menu bar extra scene for macOS apps. A minimal app
scene can use the system-image initializer to display an SF Symbol in the menu
bar:

```swift
import AppKit
import SwiftUI

@main
struct AppleContainerMenuApp: App {
    var body: some Scene {
        MenuBarExtra("Apple Container Menu", systemImage: "shippingbox") {
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .menuBarExtraStyle(.menu)
    }
}
```

The `.menuBarExtraStyle(.menu)` modifier configures the scene to use the native
pull-down menu style. Both the modifier and the `.menu` style are available on
macOS 13.0 and later.

`LSUIElement=true` is an app bundle setting, not a SwiftUI API. It belongs in the
app's `Info.plist` when the app should appear only in the menu bar, without a
Dock icon.

## Citations

[1] [SwiftUI MenuBarExtra](https://developer.apple.com/documentation/swiftui/menubarextra)
[2] [SwiftUI `menuBarExtraStyle(_:)`](https://developer.apple.com/documentation/swiftui/scene/menubarextrastyle%28_%3A%29)
[3] [SwiftUI `MenuBarExtraStyle.menu`](https://developer.apple.com/documentation/swiftui/menubarextrastyle/menu)
