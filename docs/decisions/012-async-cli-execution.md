# 12. Async CLI execution

Status: Accepted
Date: 2026-06-21

## Context

`Process` is blocking. Running the CLI on the main thread freezes the menu bar; if
the CLI or service is slow, the user gets a beachball.

## Decision

Run the CLI off the main thread with Swift async/await.

## How

Wrap `Process` in a `Task`, read stdout and stderr via `Pipe`, decode the JSON,
then hop to `@MainActor` to update the state (see
[005](005-six-state-model.md)) and the cache (see
[009](009-last-known-cache.md)). macOS 13 supports structured concurrency.

## Consequences

- The menu bar stays responsive regardless of CLI latency.
- Results arrive asynchronously, which is why the cache exists.

## Alternatives / deferred

- Blocking the main thread: rejected; beachball risk.
