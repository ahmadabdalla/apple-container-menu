---
type: Decision
title: AppKit status item open trigger
description: Render the menu from an AppKit NSStatusItem so menuWillOpen can trigger the fetch on open.
timestamp: 2026-06-21
tags: [ui, appkit, menubarextra, fetch]
status: Accepted
---

# 15. AppKit status item open trigger

## Context

The fetch must run when the menu opens (see [3](003-static-icon-fetch-on-open.md))
so the cache refreshes for the next open (see [9](009-last-known-cache.md)). The
SwiftUI `MenuBarExtra` `.menu` style (see
[8](008-menubarextra-menu-style.md)) gives no menu-open hook: `.onAppear` does not
fire and the runloop is blocked while the menu is up (see
[nsstatusitem-menu-open](../reference/nsstatusitem-menu-open.md)). Without a hook
the cache only warms at launch and on manual Refresh, so data is stale until
Refresh is pressed.

## Decision

Render the menu from an AppKit `NSStatusItem` and `NSMenu` instead of
`MenuBarExtra` `.menu`. An `NSMenuDelegate.menuWillOpen(_:)` triggers the
fetch-on-open. This supersedes [8](008-menubarextra-menu-style.md).

## How

An `NSApplicationDelegateAdaptor` installs the status item and assigns an `NSMenu`
whose delegate triggers the refresh. `menuWillOpen` renders the last-known cache
synchronously, then kicks the async fetch (see
[12](012-async-cli-execution.md)). The result cannot re-render the open menu (the
runloop is blocked), so it lands in the cache and surfaces on the next open: the
one-open-stale, self-correcting behaviour [9](009-last-known-cache.md) already
describes. The six-state model (see [5](005-six-state-model.md)) maps to native
single-line items with Refresh and Quit fixed below (see
[10](010-inline-rows-menu-chrome.md)). The `App` scene becomes an empty `Settings`
scene; the status item is the entire UI.

## Consequences

- The fetch-on-open trigger required by [3](003-static-icon-fetch-on-open.md) and
  [9](009-last-known-cache.md) now exists, with no third-party dependency.
- Menu items are built imperatively as `NSMenuItem`s rather than declaratively in
  SwiftUI, which is more verbose.
- The open menu still cannot update in place; the cache remains the mechanism that
  makes the next open fresh.

## Alternatives / deferred

- MenuBarExtraAccess dependency: rejected; its `isPresented` binding is documented
  as unreliable for `.menu`, and its open signal is a KVO handler the blocked
  runloop defers until the menu closes, so it would fire on close, not open, and
  add the first third-party dependency.
- Blocking fetch in `menuWillOpen` for fresh-in-one-open: deferred; an unbounded
  block freezes the menu bar and risks a beachball (see
  [12](012-async-cli-execution.md)). The two CLI calls measured about 33ms
  combined on the test machine (`system status` plus `ls --all --format json`), so
  a short bounded block would be imperceptible in the common case. Revisit once the
  CLI subprocess has a timeout to cap the worst case (issue #14).
