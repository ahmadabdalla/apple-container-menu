---
type: Decision
title: CLI binary resolution
description: Resolve the container binary from an ordered candidate list because a GUI app does not inherit shell PATH.
timestamp: 2026-06-21
tags: [cli, path, resolution]
status: Accepted
---

# 4. CLI binary resolution

## Context

A GUI app launched from Finder does not inherit the shell PATH, so invoking
`container` by name fails in the shipped app even though it works in a terminal.
The binary lives in different places by install method (see
[binary paths](../reference/binary-paths.md)).

## Decision

Resolve the binary from an ordered candidate list, Homebrew first:
`/opt/homebrew/bin/container`, then `/usr/local/bin/container`. Apple silicon
only. Use the first path that exists.

## How

At fetch time, check each candidate with `FileManager.fileExists`. The first hit
is the binary. If none exist, the menu shows the CLI-not-found state (see
[005](005-six-state-model.md)). Homebrew is tried first because it matches the
project's documented install (`brew install container`); order only matters if a
user has both installed.

## Consequences

- Covers both real install locations on Apple silicon with near-zero code.
- Honest failure: "container CLI not found" instead of silent emptiness.
- A user with a non-standard install location gets "not found" until a
  configurable override ships.

## Alternatives / deferred

- Hardcode a single path: rejected; breaks for one of the two install methods.
- Configurable override path: deferred; checked before the candidate list when it
  ships.
- Intel support: out of scope.
