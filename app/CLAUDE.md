---
type: Instruction
title: App constraints
description: SwiftUI menu bar app constraints (AppKit NSStatusItem + NSPopover): unsandboxed, LSUIElement, macOS 14+ Apple silicon.
timestamp: 2026-06-26
tags: [app, swiftui, constraints]
---

# App constraints

SwiftUI menu bar app code for `apple-container-menu`.

Standing decisions:

- Unsandboxed by design. The app shells out to the `container` CLI via
  `Process()`; the App Sandbox would block that. The sandbox is only required
  for Mac App Store distribution, which is a non-goal.
- UI is an AppKit `NSStatusItem` driving a SwiftUI `NSPopover` (via
  `NSHostingController`), driven by an `NSApplicationDelegateAdaptor`, with
  `LSUIElement` set (no Dock icon). The status button toggles the popover and the
  `NSPopoverDelegate.popoverWillShow` hook drives the fetch on open; the open
  popover updates in place under a live fetch (see
  [decision 018](../docs/decisions/018-swiftui-popover-ui.md), which supersedes
  009, 010, and 015). Settings, launch-at-login, auto-refresh, and the name filter
  are in [decision 019](../docs/decisions/019-settings-launch-autorefresh-filter.md).
- Target macOS 14 (Sonoma) and later, Apple silicon. The floor rose from 13 for
  the `@Observable` macro (see
  [decision 018](../docs/decisions/018-swiftui-popover-ui.md)).

Implementation patterns (footguns worth stating, detail in the ADRs):

- Shelling out: drain stdout and stderr concurrently before reading the exit
  status. Reading only one pipe deadlocks when the child fills the other pipe's
  buffer. Run the CLI off the main thread (see
  [012](../docs/decisions/012-async-cli-execution.md)).
- Decoding: decode only the fields a row renders as required; everything else
  (`image`, `containerPort`, `proto`) is optional and unknown keys are ignored,
  so a payload reshape degrades one row instead of blanking the menu (see
  [002](../docs/decisions/002-cli-output-json.md),
  [007](../docs/decisions/007-container-data-model.md)).
- Async refresh: a newer fetch cancels the in-flight one and the result is
  applied only if not cancelled, so a slow earlier fetch cannot overwrite a
  fresher result (see [009](../docs/decisions/009-last-known-cache.md), retained
  under [018](../docs/decisions/018-swiftui-popover-ui.md)).

Build, signing, and CI concerns do not belong here; see `scripts/CLAUDE.md` and
`.github/CLAUDE.md`.
