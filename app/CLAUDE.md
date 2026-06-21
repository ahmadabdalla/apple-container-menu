---
type: Instruction
title: App constraints
description: SwiftUI menu bar app constraints (AppKit NSStatusItem): unsandboxed, LSUIElement, macOS 13+ Apple silicon.
timestamp: 2026-06-21
tags: [app, swiftui, constraints]
---

# App constraints

SwiftUI menu bar app code for `apple-container-menu`.

Standing decisions:

- Unsandboxed by design. The app shells out to the `container` CLI via
  `Process()`; the App Sandbox would block that. The sandbox is only required
  for Mac App Store distribution, which is a non-goal.
- UI is an AppKit `NSStatusItem` with an `NSMenu`, driven by an
  `NSApplicationDelegateAdaptor`, with `LSUIElement` set (no Dock icon). The
  `MenuBarExtra` `.menu` style was dropped because it has no menu-open hook; the
  `menuWillOpen` delegate drives the fetch on open (see
  [decision 015](../docs/decisions/015-appkit-status-item-open-trigger.md) and
  [docs/reference/nsstatusitem-menu-open.md](../docs/reference/nsstatusitem-menu-open.md)).
- Target macOS 13 (Ventura) and later, Apple silicon.

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
  fresher cache (see [009](../docs/decisions/009-last-known-cache.md)).

Build, signing, and CI concerns do not belong here; see `scripts/CLAUDE.md` and
`.github/CLAUDE.md`.
