---
type: Instruction
title: Test target conventions
description: How to write tests for AppleContainerMenuTests: Swift Testing, the unit/functional tiers, and the CLI seam.
timestamp: 2026-06-21
tags: [testing, swift, conventions]
---

# Test conventions

`AppleContainerMenuTests` is a Swift Testing target hosted by the app. Decision
and rationale: [016](../../docs/decisions/016-swift-testing-framework.md). Run it
with `xcodebuild -project app/AppleContainerMenu.xcodeproj -scheme
AppleContainerMenu test`.

Standing rules:

- Swift Testing only: `@Suite`, `@Test`, `#expect`, `#require`. Only import
  `Testing`. No XCTest unless a UI or performance suite later needs it.
- Two tiers, tagged in `TestTags.swift`:
  - `.unit`: inject a fake `ProcessRunner` via `FakeCLI`. No subprocess; fast and
    deterministic. Decoding, helpers, and `fetch()` mapping live here.
  - `.functional`: inject only a stub binary via `StubContainerBinary` and let the
    real `Process` pipeline run. Reserve for proving the production path end to
    end (the two-command gate, pipe drain, ISO8601 decode).
- The seam is `ContainerCLI(resolveBinary:run:)`. Both close over production
  defaults, so add a scenario by composing a new fake runner (unit) or a new stub
  behavior (functional), not by adding production types.
- Reuse the fixtures: realistic `ls` JSON and the container builder are in
  `Fixtures.swift`; assert on `MenuState` via `MenuStateMatchers.swift`. Do not
  inline ad hoc JSON or re-pattern-match cases. `MenuState` is intentionally not
  `Equatable`; the matchers exist so tests never force `Equatable` onto a
  production type for convenience. Keep it that way.
- Prefer parameterized `@Test(arguments:)` for input tables (uptime, ports).
- Tests run in parallel by default. Keep them independent; reach for
  `.serialized` only when shared mutable state forces it, and say why.
- Functional tests spawn a local temp script only and clean it up; no network and
  no real `container`. The stub's heredoc stdout/stderr carry a trailing newline,
  which is safe only because `ContainerCLI.message(from:)` trims; do not remove
  that trim without updating the stub.
- The test target deploys to macOS 14.0 (the Swift Testing and XCTest dylibs
  require it); the app stays at 13.0. The split is deliberate, lives in
  `project.pbxproj`, and must not be aligned.
- Running the suite launches the host app, so `ContainerStore.init` performs a
  real `fetch()`. The run can stall if the local `container` misbehaves; that is
  the hosted-bundle cost, not a test bug.

## Adding a file to the target

This is the raw Xcode project (ADR
[011](../../docs/decisions/011-xcode-project-scaffolding.md)), so new test files
are wired by hand in `project.pbxproj`: a file ref, a build file, the group
child, and the Sources phase entry. Mint object IDs as
`8BAA<group><n>2E00000100AC0001` so they cannot collide with the app's
`8B77C0xx...` IDs.
