---
type: Decision
title: Six-state model
description: A single enum models loading, CLI-not-found, service-not-running, empty, populated, and error.
timestamp: 2026-06-21
tags: [state, model, ui]
status: Accepted
---

# 5. Six-state model

## Context

A monitor that only handles the happy path looks broken the moment the service is
down or the CLI is missing. The full reachable space of "run a CLI and show the
result" has several distinct states, each with a different user action.

## Decision

The menu renders exactly six states: loading, CLI-not-found, service-not-running,
empty, populated, error.

## How

A single Swift enum models the states, with associated values where needed
(`populated([Container])`, `error(String)`). The view switches on the enum. State
is reached by the fetch flow (see [006](006-two-command-fetch-flow.md)): binary
resolution yields CLI-not-found; `system status` yields service-not-running; `ls`
yields empty, populated, or error.

## Consequences

- Unhappy paths are designed, not discovered in production.
- Adding actions later never changes these states.
- Each state can guide the user (install vs start the service vs file a bug).

## Alternatives / deferred

- Collapsing states (for example one generic "unavailable"): rejected; the states
  have different user actions, so collapsing degrades the UX for no real code
  saving.
