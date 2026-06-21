---
name: Task
about: A single, self-contained unit of work
title: ""
labels: []
assignees: []
---

<!--
One task, one concern. No bundling unrelated changes.
Fill every section. An issue that relies on prior conversation or external
memory to be understood is not ready. Write it so anyone (human or agent) with
zero prior context can pick it up.
-->

## What

<!-- The concrete change. Scope it to one concern. -->

## Why

<!-- The reason this is worth doing. What it unblocks or fixes. -->

## Provenance

<!--
The codified concepts that govern this work, one manifest for the whole issue
(not per criterion). The agent maps every planned step to a line here; a step
that resolves to neither a line here nor an explicit requirement above is a gap,
and the agent must halt rather than fill it from training data.

One line each:
  pattern: docs/decisions/NNN-some-slug.md   # a concept that already exists
  new-pattern: some-slug                     # none exists; author an ADR first

A new-pattern is a forward declaration. To reach Ready, author the ADR, set its
status to Accepted, then convert the line to a pattern: link. A surviving
new-pattern line means the issue is not Ready. See
docs/decisions/017-definition-of-ready-gate.md.

Worked example:
  pattern: docs/decisions/005-six-state-model.md
  pattern: docs/decisions/007-container-data-model.md
  new-pattern: container-row-action-menu
-->

## Constraints

<!-- Boundaries and non-goals: what must NOT change, dependencies on other
issues, explicit out-of-scope items. -->

## Acceptance criteria

<!-- Checkboxes that make "done" objective and testable. -->

- [ ]
- [ ]
