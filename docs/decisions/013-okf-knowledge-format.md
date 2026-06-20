---
type: Decision
title: Adopt Open Knowledge Format for the knowledge layer
description: docs/ becomes an OKF v0.1 bundle and the CLAUDE.md files become conformant nodes in the same graph.
timestamp: 2026-06-21
tags: [okf, knowledge, meta, prose]
status: Accepted
---

# 13. Adopt Open Knowledge Format for the knowledge layer

## Context

The repo is built to be driven by agents. Its curated knowledge (decisions,
doctrine, verified CLI facts) was accumulating with no uniform shape, so an agent
had to read whole files to learn whether they were relevant. Open Knowledge
Format (OKF) v0.1 is a thin, vendor-neutral convention: a directory of markdown
"concepts", each with YAML frontmatter (`type` required) and a body that favors
tables and lists. It standardizes exactly the routing metadata we lacked, and its
`type` plus one-line `description` let an agent decide what to load from
frontmatter alone. That is token efficiency by construction and a direct
expression of the PROSE progressive-disclosure principle (see
[../doctrine/prose.md](../doctrine/prose.md)).

## Decision

Make `docs/` an OKF v0.1 bundle and bring the four `CLAUDE.md` files in as
`Instruction` nodes of the same graph. Adopt the format only: no Google reference
tooling, runtime, or SDK.

## How

- Bundle root is `docs/`. The repo-root `README.md` stays outside it.
- Closed `type` vocabulary: `Decision`, `Doctrine`, `Reference`, `Instruction`.
- Frontmatter schema, link rule, and index/log conventions are codified in
  [../CLAUDE.md](../CLAUDE.md); each subfolder `CLAUDE.md` adds its narrow enums
  and leans on the always-loaded parent chain (Explicit-hierarchy).
- Decision `Status:`/`Date:` body lines move into frontmatter `status`/
  `timestamp`; bodies start at `## Context`.
- `README.md` listings are replaced by reserved `index.md` files.
- Cross-links are relative paths; no bundle-relative `/` links.
- The `CLAUDE.md` files stay in place (Claude Code auto-loads them by directory)
  and gain `Instruction` frontmatter. The expanded PROSE rationale moves into
  `doctrine/prose.md`; root `CLAUDE.md` keeps the eager rules and links to it.
- `reference/` holds verified CLI facts as `Reference` concepts; the decisions
  that cited that evidence link to them instead of inlining it.
- A single `docs/log.md` records material changes only.

## Consequences

- An agent routes by frontmatter, reads bodies only on a match: less context per
  task, the explicit goal.
- The knowledge surface is uniform and queryable, and the bundle is portable
  (plain markdown, no runtime).
- Every concept now carries a frontmatter block: a small, fixed authoring cost.
- The bundle spans the repo (the in-place `CLAUDE.md` nodes), so it is not a clean
  `docs/` subtree; accepted to keep instructions in the graph.

## Alternatives / deferred

- No format, keep ad hoc markdown: rejected; leaves every agent to reassemble
  context from whole files.
- Adopt OKF plus Google's tooling (enrichment agent, visualizer, `src/`): rejected
  for a menu bar app; the format alone delivers the queryability, the tooling is
  scope we do not need.
- Per-directory `log.md` (OKF idiom): rejected for a single root log to cap the
  sync burden; revisit if the bundle is redistributed without git.
