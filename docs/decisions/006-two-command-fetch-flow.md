---
type: Decision
title: Two-command fetch flow
description: Gate on container system status exit code, then run ls, to distinguish service-down from empty or error.
timestamp: 2026-06-21
tags: [cli, fetch, state]
status: Accepted
---

# 6. Two-command fetch flow

## Context

To distinguish "service not running" from "no containers" or "error", the app
must know whether the service is up. Experiment shows `container system status`
is a clean exit-code signal while `container ls` fails noisily when the service
is down (see [service status](../reference/service-status.md)).

## Decision

Fetch in two steps gated on exit code: run `container system status` first; if it
exits non-zero, the state is service-not-running. Otherwise run `container ls
--all --format json` and resolve empty, populated, or error.

## How

`system status` is an exit-code boolean: no string matching, nothing Apple can
break by rewording. Only when status succeeds does `ls` run. An `ls` failure
after a healthy status lands in the generic error state. The two commands own
contiguous slices of the state machine (see [005](005-six-state-model.md)).

## Consequences

- Robust: service detection never depends on parsing a stderr string Apple
  controls.
- One extra process spawn per open, negligible on a fetch-on-open app.
- If status reports running but `ls` fails for a service reason, it shows as a
  generic error. Rare and acceptable.

## Alternatives / deferred

- Single command, classify `ls` stderr: rejected; depends on a fragile,
  reworded-at-any-time error string.
- ls-first hybrid (run status only when `ls` fails): deferred micro-optimization;
  saves one spawn in the common case at the cost of a conditional branch.
