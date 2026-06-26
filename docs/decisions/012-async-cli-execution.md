---
type: Decision
title: Async CLI execution
description: Run the CLI off the main thread with async/await so the menu bar stays responsive.
timestamp: 2026-06-26
tags: [concurrency, cli, async]
status: Accepted
---

# 12. Async CLI execution

## Context

`Process` is blocking. Running the CLI on the main thread freezes the menu bar; if
the CLI or service is slow, the user gets a beachball.

## Decision

Run the CLI off the main thread with Swift async/await.

## How

Wrap `Process` in a `Task`, read stdout and stderr via `Pipe`, decode the JSON,
then hop to `@MainActor` to update the state (see
[005](005-six-state-model.md)) and the cache (see
[009](009-last-known-cache.md), retained under
[018](018-swiftui-popover-ui.md)). The macOS 14 floor supports structured
concurrency.

## Consequences

- The menu bar stays responsive regardless of CLI latency.
- Results arrive asynchronously, which is why the cache exists.
- A wedged child that never exits or never closes its pipes is bounded: each
  `container` invocation has a per-command timeout (terminate, then SIGKILL after
  a short grace), and a superseded refresh cancels and terminates the in-flight
  `Process`. A timeout maps to `.error` (see [005](005-six-state-model.md)).

## Alternatives / deferred

- Blocking the main thread: rejected; beachball risk.
- A store-level timeout that just cancels `fetch()`: rejected; cancelling drops
  the result but does not kill the child, so wedged processes and pipe readers
  pile up. The timeout lives in the CLI so it terminates the `Process`.
- Per-fetch timeout instead of per-command: not taken; per-command is simpler and
  the seam is per command. Tradeoff: a fully wedged two-command fetch can take up
  to two timeouts.
