---
type: Decision
title: Swift Testing for the test target
description: Use Swift Testing for the unit and functional test target, with a two-tier strategy over an injected CLI seam.
timestamp: 2026-06-21
tags: [testing, tooling, swift]
status: Accepted
---

# 16. Swift Testing for the test target

## Context

The app had no test target. The highest-risk code is not the SwiftUI shell; it
is JSON decoding, state mapping, and CLI failure classification (see
[002](002-cli-output-json.md), [005](005-six-state-model.md),
[006](006-two-command-fetch-flow.md), [007](007-container-data-model.md)). A test
target needs a framework. The choice is Swift Testing or XCTest, and it is a
durable tooling decision. This is new Swift code with no existing XCTest suite,
the project was created with Xcode 26.5, and Swift Testing ships with Xcode 16+
toolchains.

## Decision

Use Swift Testing for the `AppleContainerMenuTests` target.

## How

`AppleContainerMenuTests` is a unit-test bundle hosted by the app, kept in the
raw Xcode project (ADR [011](011-xcode-project-scaffolding.md)) and run with
`xcodebuild -project app/AppleContainerMenu.xcodeproj -scheme AppleContainerMenu test`.

Tests run in two tiers over one seam, so coverage is honest without making the
CLI hard to read:

- `ContainerCLI` exposes two injected closures, a binary resolver and a process
  runner, both defaulted to the production `FileManager` scan and `Process` +
  `Pipe` flow (ADR [012](012-async-cli-execution.md)). `ContainerCLI()` call
  sites are unchanged.
- The `.unit` tier injects a fake runner: deterministic, no subprocess. It covers
  `Container` decoding and helpers and all six `fetch()` mappings.
- The `.functional` tier injects only a stub `container` binary and runs the real
  `Process` pipeline end to end: the two-command gate, the concurrent pipe drain,
  ISO8601 decoding, and state mapping.

Conventions for writing these tests live in
[../../app/AppleContainerMenuTests/CLAUDE.md](../../app/AppleContainerMenuTests/CLAUDE.md).

## Consequences

- New code uses the current framework: `@Test`, `@Suite`, `#expect`, `#require`,
  parameterized cases, and tags for the tier split.
- Swift Testing runs in parallel by default, which suits independent tests but
  means shared mutable state needs `.serialized` if it appears later.
- The functional tier spawns a local stub subprocess, so those tests are slower
  than the unit tier and depend on the unsandboxed host (already true by design).
  Running the suite also launches the host app, so `ContainerStore.init` performs
  a real `fetch()`; a misbehaving local `container` can stall the run.
- The test target deploys to macOS 14.0 because the Swift Testing and XCTest
  dylibs require it; the app stays at 13.0. The split is intentional and lives in
  `project.pbxproj`.
- Swift Testing and XCTest can coexist, so an XCUITest or performance suite can be
  added later without reworking this target.

## Alternatives / deferred

- XCTest: rejected for new code; kept as the fallback only if the raw Xcode
  project or the Swift 5 language mode (`SWIFT_VERSION = 5.0`) had blocked a Swift
  Testing target. It did not.
- A protocol seam instead of closures: rejected; closures are the smaller seam and
  already serve both tiers.
- CI execution and code-coverage thresholds: deferred; `.github/` has no workflow
  yet and CI is out of scope for this decision.
