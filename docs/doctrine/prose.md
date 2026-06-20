---
type: Doctrine
title: PROSE operating doctrine
description: The five principles that govern how this repo is built and how agents should work in it.
timestamp: 2026-06-21
tags: [prose, doctrine, process]
---

# PROSE

The operating doctrine for `apple-container-menu`. Root `CLAUDE.md` carries the
one-line version on the eager path; this is the expanded why and how. The OKF
bundle (see [../decisions/013-okf-knowledge-format.md](../decisions/013-okf-knowledge-format.md))
is this doctrine made concrete.

## Progressive disclosure

Load context just in time. Keep instruction files thin and point to detail
instead of inlining it.

- Why: every eagerly loaded line is a fixed tax on every session. Detail that
  most tasks do not need should not be on the hot path.
- How: a concept's frontmatter `description` is read to route; its body is opened
  only on a match. Read a doc only when the task touches its area.

## Reduced scope

One task, one concern. No bundling unrelated changes.

- Why: a change that does one thing is reviewable, revertible, and self-contained.
- How: every handoff (issue, prompt, session) carries its own full context. An
  issue that needs prior conversation to be understood is not ready.

## Orchestrated composition

Build from small, atomic, composable scripts and skills. No mega-scripts, no
mega-prompts.

- Why: small units are testable and recombine; a monolith is neither.
- How: a release step calls build, then notarize, then package, rather than
  inlining all three. Compose, do not concatenate.

## Safety boundaries

Risky or externally visible operations are gated.

- Why: irreversible or outward-facing actions deserve a deliberate stop.
- How: `codesign`, `xcrun notarytool submit`, `gh release create`, Homebrew tap
  pushes, and `git push` require explicit approval; see `.claude/settings.json`.

## Explicit hierarchy

Conventions live in the nearest scoped `CLAUDE.md`; specificity rises as scope
narrows.

- Why: rules belong next to what they govern, and the parent chain guarantees the
  shared rules are present without duplicating them.
- How: read the local `CLAUDE.md` first, then up to the root. A subfolder states
  only its own narrow rules and leans on the always-loaded parent for the rest.
