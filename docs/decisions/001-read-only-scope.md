# 1. Read-only monitor for the MVP

Status: Accepted
Date: 2026-06-21

## Context

The end goal is a menu bar app that shows container status and offers basic
actions (start, stop, remove). Building actions first means designing
confirmation flows, destructive-operation gating, and write-path error handling
before the read path is even proven.

## Decision

The MVP is read-only. The app only runs commands that observe: `container system
status`, `container ls`, and (later) `container inspect`. No command mutates
state.

## How

The execution layer exposes only read operations. No UI element triggers a
mutating CLI call. Actions are added later as a separate, additive layer over the
same `Process` plumbing; they do not require restructuring the read path.

## Consequences

- The entire safety surface collapses: no destructive calls, no confirmation
  dialogs, no "are you sure" state machine.
- The hard parts (reliable CLI reads, JSON parsing, service-down handling, menu
  refresh) are proven before any write path exists.
- Users cannot control containers from the app yet; they use the terminal for
  that until actions ship.

## Alternatives / deferred

- Monitor plus actions in the MVP: deferred. Actions belong in a per-container
  submenu (see [010](010-inline-rows-menu-chrome.md)) and arrive with their own
  gating.
