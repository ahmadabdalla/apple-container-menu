---
type: Decision
title: Parse container JSON output
description: Read container state via container ls --all --format json and decode only the fields the UI needs.
timestamp: 2026-06-21
tags: [cli, json, parsing]
status: Accepted
---

# 2. Parse container JSON output

## Context

The app needs structured container data. `container ls` defaults to a human
table but supports `--format json` (see
[json output](../reference/cli-json-output.md)). Scraping the table couples the
app to column layout and spacing.

## Decision

Read machine output with `container ls --all --format json` and decode it.

## How

A `Decodable` model maps only the fields the UI needs (see
[007](007-container-data-model.md)) and ignores the rest, so the verbose,
deeply nested JSON can gain fields without breaking decoding. `--all` includes
stopped containers so the six-state model can show them.

## Consequences

- Parsing is stable against cosmetic CLI changes.
- The model is decoupled from output formatting.
- If Apple renames a field we depend on, decoding of that field fails; the error
  state (see [005](005-six-state-model.md)) catches it.

## Alternatives / deferred

- Scraping the human table: rejected. Brittle against spacing and column changes.
