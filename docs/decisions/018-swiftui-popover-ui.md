---
type: Decision
title: SwiftUI popover UI
description: Render the menu-bar UI as a SwiftUI NSPopover that fetches on popoverWillShow and updates in place.
timestamp: 2026-06-26
tags: [ui, appkit, nspopover, swiftui, fetch]
status: Accepted
---

# 18. SwiftUI popover UI

## Context

The `NSMenu` snapshot (see [015](015-appkit-status-item-open-trigger.md)) renders
single-line items (see [010](010-inline-rows-menu-chrome.md)) and cannot update
once open, so a fetch landing after open only surfaces on the next open (see
[009](009-last-known-cache.md)). Issue #24 asks for a richer per-container row: a
status capsule with uptime, an accent port chip, a status dot, and a dim image
line, none of which a native menu item can lay out. A SwiftUI popover can, and it
can re-render in place while open.

## Decision

Render the UI as an `NSPopover` hosting a SwiftUI view through
`NSHostingController`. The status button toggles the popover and the open hook is
`NSPopoverDelegate.popoverWillShow(_:)`, which renders the cache and then kicks
the live fetch that updates the open popover in place. This supersedes
[009](009-last-known-cache.md), [010](010-inline-rows-menu-chrome.md), and
[015](015-appkit-status-item-open-trigger.md).

## How

`ContainerStore` adopts the `@Observable` macro so the SwiftUI views track
`state`; the infrastructure properties (`cli`, the in-flight `Task`) are
`@ObservationIgnored`. The popover is `.transient` with `sizingOptions =
.preferredContentSize` so it resizes as rows appear under a live update. The
status button action toggles: `performClose` when shown, else
`show(relativeTo:...)`; the `isShown` guard avoids the close-then-reopen race on
the click. The app is `LSUIElement`, so a `.transient` popover would not dismiss
on an outside click until first focused; `NSApp.activate(ignoringOtherApps:)`
before `show` makes the window key immediately so click-away works.

No SwiftUI background is painted: `NSPopover` draws its own vibrant material and
is the only thing that fills the arrow notch, so a `.background` on the root would
leave the arrow showing the window backing. `popover.appearance` is left unset so
the shade adapts to light and dark. The six-state model (see
[005](005-six-state-model.md)) renders as SwiftUI; the status dot pairs shape and
colour (filled green when running, hollow grey ring when stopped), carrying the
preattentive-status rationale from [010](010-inline-rows-menu-chrome.md). Each
populated row collapses to one accessibility element with a combined label. The
macOS floor rises to 14 for `@Observable`.

## Consequences

- The open popover updates in place, so a fetch on open is visible immediately;
  the cache still renders first so the UI never blocks (the instant-render half of
  [009](009-last-known-cache.md) is kept, the one-open-stale half is gone).
- Rows carry full layout: status capsule, port chip, status dot, and image line.
- The macOS deployment target rises from 13 to 14, so the app and the test target
  now match.
- More moving parts than a menu: popover lifecycle, focus, and dismissal are owned
  by the app rather than the menu system.

## Alternatives / deferred

- Keep the `NSMenu` snapshot: rejected; it cannot lay out the richer row or update
  in place, which is the point of issue #24.
- `MenuBarExtra` `.window` style: rejected; it has no reliable open hook (see
  [008](008-menubarextra-menu-style.md) and
  [015](015-appkit-status-item-open-trigger.md)), so the app drives the popover
  from an `NSStatusItem` directly.
