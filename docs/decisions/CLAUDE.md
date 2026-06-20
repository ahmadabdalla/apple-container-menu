---
type: Instruction
title: Decision authoring rules
description: How to author ADR concepts in docs/decisions.
timestamp: 2026-06-21
tags: [okf, authoring, decisions]
---

# decisions authoring rules

Concepts here are `type: Decision`: one Architecture Decision Record per file.
Shared schema is in the parent [../CLAUDE.md](../CLAUDE.md).

- `type` is always `Decision`. Add `status`: one of `Accepted`, `Superseded`,
  `Deprecated`. Frontmatter `status` is the source of truth; do not repeat it in
  the body.
- Filename is `NNN-kebab-slug.md`, zero-padded to three digits, sequential.
- The body starts at `## Context` (no `Status:`/`Date:` lines) and uses this
  order: `## Context`, `## Decision`, `## How`, `## Consequences`,
  `## Alternatives / deferred`.
- The `# N. Title` heading keeps the decimal number matching the filename.
- A new decision, or a `status` transition, is a material change: add a
  `../log.md` entry.
- Never edit an accepted decision's substance to reverse it. Supersede it: set
  the old one's `status` to `Superseded` and write a new ADR.

## Body formatting

Match the existing ADRs; keep it simple.

- `## Context`, `## Decision`, `## How`: prose, hard-wrapped near 80 columns.
  State the decision plainly in one or two sentences under `## Decision`.
- `## Consequences`: a `-` bullet list, one consequence per bullet. Include the
  costs and trade-offs, not only the upside.
- `## Alternatives / deferred`: a `-` bullet list, each `<alternative>:
  <verdict>`, where the verdict is `rejected`, `deferred`, or `revisit if ...`
  followed by the reason.
- Bullets use `-`; the `*` marker is reserved for `index.md`.
- Backticks for filenames, commands, types, enum cases, and field names. No bold
  in the body.
- Cross-link by relative path: a bare number for a sibling ADR
  (`[007](007-container-data-model.md)`), a short phrase for other concepts
  (`[json output](../reference/cli-json-output.md)`).
