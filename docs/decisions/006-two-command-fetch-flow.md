# 6. Two-command fetch flow

Status: Accepted
Date: 2026-06-21

## Context

To distinguish "service not running" from "no containers" or "error", the app
must know whether the service is up. Experiment (service stopped): `container
system status` exits non-zero with a clean message; `container ls --format json`
exits non-zero with a noisy internal error (XPC) plus a hint line.

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
