---
type: Decision
title: Xcode project scaffolding
description: Ship as a raw Xcode project driving build, sign, and notarize via composable scripts.
timestamp: 2026-06-21
tags: [build, xcode, tooling]
status: Accepted
---

# 11. Xcode project scaffolding

## Context

A menu bar app must ship as a proper `.app` bundle with `Info.plist`
(`LSUIElement`), an icon, and code signing. The build can be owned by a raw Xcode
project, by SwiftPM with hand-rolled bundling, or by a generated project
(XcodeGen/Tuist). The app architecture is independent of this choice.

## Decision

Use a raw Xcode project.

## How

Xcode owns the bundle, `Info.plist`, asset-catalog icon, signing, and
notarization, driven from composable scripts via `xcodebuild` (see
`scripts/CLAUDE.md`). Only the project configuration is opaque; the build, sign,
and notarize pipeline stays scriptable.

## Consequences

- The class of failures around bundling and signing a menu bar app is removed.
- Standard, well-documented path: every tutorial and doc matches the setup, which
  suits a learning project.
- `project.pbxproj` is machine-generated and merge-hostile: the least AI-legible
  artifact in the repo.

## Alternatives / deferred

- Generated project (XcodeGen/Tuist): deferred. Text, diffable config plus Xcode's
  reliability; adopt later by writing a manifest that reproduces the project and
  dropping `pbxproj`. A toolkit swap, not an app rework.
- SwiftPM plus hand-rolled bundle: rejected; a menu bar app needs a real bundle
  and `LSUIElement` to appear in the menu bar, so the bundle work and its footguns
  are not worth it for the MVP.
