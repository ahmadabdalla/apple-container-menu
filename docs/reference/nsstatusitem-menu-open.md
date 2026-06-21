---
type: Reference
title: NSStatusItem menu open trigger
description: NSMenu menuWillOpen is the reliable menu-open hook; MenuBarExtra .menu has none and blocks the runloop while open.
timestamp: 2026-06-21
tags: [appkit, menubarextra, swiftui, macos, reference]
resource: https://developer.apple.com/documentation/appkit/nsmenudelegate/menuwillopen(_:)
---

# NSStatusItem menu open trigger

Why the app renders its menu from an AppKit `NSStatusItem` rather than SwiftUI
`MenuBarExtra` `.menu` (see
[015](../decisions/015-appkit-status-item-open-trigger.md)).

## MenuBarExtra .menu has no open hook

A SwiftUI `MenuBarExtra` with `.menuBarExtraStyle(.menu)` exposes no menu-open
event. `.onAppear` on the menu content does not fire on open, and while the menu
is presented the main runloop is blocked, so async work and SwiftUI observation
do not resume until the menu closes. Apple feedback FB13683950 and FB13683957
track this. The practical effect is that any open-triggered refresh can only run
after the menu has been dismissed.

## NSMenu menuWillOpen is the reliable hook

An AppKit `NSMenu` assigned to an `NSStatusItem` calls
`NSMenuDelegate.menuWillOpen(_:)` synchronously before the menu is displayed. That
is the canonical place to start an open-triggered fetch and to populate items. The
runloop is still blocked while the menu is up, so an async result cannot re-render
the open menu; it lands in the cache and surfaces on the next open (see
[009](../decisions/009-last-known-cache.md)).

## Citations

[1] [NSMenuDelegate menuWillOpen(_:)](https://developer.apple.com/documentation/appkit/nsmenudelegate/menuwillopen(_:))
[2] [SwiftUI MenuBarExtra](https://developer.apple.com/documentation/swiftui/menubarextra)
