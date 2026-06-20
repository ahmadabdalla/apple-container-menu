---
type: Instruction
title: App constraints
description: SwiftUI MenuBarExtra app constraints: unsandboxed, LSUIElement, macOS 13+ Apple silicon.
timestamp: 2026-06-21
tags: [app, swiftui, constraints]
---

# App constraints

SwiftUI menu bar app code for `apple-container-menu`.

Standing decisions:

- Unsandboxed by design. The app shells out to the `container` CLI via
  `Process()`; the App Sandbox would block that. The sandbox is only required
  for Mac App Store distribution, which is a non-goal.
- UI is a `MenuBarExtra` scene with `LSUIElement` set (no Dock icon).
- Target macOS 13 (Ventura) and later, Apple silicon.

Build, signing, and CI concerns do not belong here; see `Scripts/CLAUDE.md` and
`.github/CLAUDE.md`.
