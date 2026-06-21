---
type: Decision
title: Context files describe current state
description: Context files describe what exists in the repo today; planned-but-absent artifacts carry an explicit marker rather than being presented as present.
timestamp: 2026-06-21
tags: [context, docs, doctrine, alignment]
status: Accepted
---

# 17. Context files describe current state

## Context

A cold-start agent cannot tell aspirational scaffolding from a real artifact.
Several scoped `CLAUDE.md` files described things as if they exist when they do
not: `.github/CLAUDE.md` documented Actions workflows with no `.github/workflows/`
present, `scripts/CLAUDE.md` documented a build / sign / notarize / package chain
when `scripts/` held only `format-markdown.sh`, and the root `CLAUDE.md`
advertised "basic actions" that [001](001-read-only-scope.md) defers. An agent
asked to modify one of these would invent a whole subsystem while believing it is
editing an existing one.

## Decision

Context files (the `CLAUDE.md` chain and the OKF bundle) describe the repository
as it exists today. An artifact that is planned but not yet present is documented
only behind an explicit marker that names what is missing; it is never presented
as if it exists. An unmarked description is a promise that the file or behavior is
real and can be opened.

## How

- A scoped `CLAUDE.md` whose subject does not yet exist opens with a one-line
  "Planned, not yet present" marker before its standing decisions, so the
  conventions read as rules for when the work lands, not a description of what is
  here. The planned conventions stay in the repo; only the marker distinguishes
  them.
- Scope language that promises a deferred capability (for example mutating
  actions) carries the deferral inline and links the ADR that defers it.
- When a planned artifact lands, the marker is removed in the same change that
  adds the artifact. From then on an unmarked-but-absent artifact is a defect,
  not ambiguity.
- The README's existing "early skeleton" status note is the model; the rest of
  the context chain follows it.

## Consequences

- An agent can trust that an unmarked description maps to a real file or behavior
  it can open, so "self-contained, zero prior context" becomes true rather than a
  trap.
- Planned conventions are preserved, not deleted, so the rules are ready when the
  work starts; the cost is one marker line per planned area.
- Keeping markers honest is now a maintenance obligation: removing the artifact's
  marker is part of the change that adds it.

## Alternatives / deferred

- Describe the intended end-state and mark only what is missing: rejected. It
  inverts the default to "assume aspirational," which is exactly the trap this
  decision closes.
- Delete every planned-but-absent doc: rejected. The conventions are real
  decisions; deleting them loses the rationale and forces re-litigation when the
  artifact lands. Marking preserves them cheaply.
