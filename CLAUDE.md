---
type: Instruction
title: Repo operating doctrine and conventions
description: Top-level PROSE doctrine, global conventions, and pointers to scoped instructions and the knowledge bundle.
timestamp: 2026-06-21
tags: [okf, authoring, doctrine, conventions]
---

# apple-container-menu

Native macOS menu bar app (SwiftUI `MenuBarExtra`) that surfaces Apple's
`container` CLI: running containers and basic actions. Distributed via GitHub
Releases (signed, notarized `.dmg`); not targeting the Mac App Store.

Curated knowledge (decisions, doctrine, verified facts) lives in the OKF bundle
under `docs/`; start at `docs/index.md`.

## Operating doctrine (PROSE)

Expanded why and how: `docs/doctrine/prose.md`. The eager rules:

- Progressive disclosure: load context just in time. Keep instruction files
  thin; point to detail, do not inline it. Read a doc only when the task matches.
- Reduced scope: one task, one concern. No bundling unrelated changes. Every
  handoff (issue, prompt, session) must be self-contained.
- Orchestrated composition: build from small, atomic, composable scripts and
  skills. No mega-scripts, no mega-prompts.
- Safety boundaries: risky or externally visible operations are gated in
  `.claude/settings.json`.
- Explicit hierarchy: conventions live in the nearest scoped `CLAUDE.md`;
  specificity rises as scope narrows. Read local first, then up to here.

## Global conventions

- No em dashes, no emojis in code, comments, or docs.
- Branch first; never commit to `main`. One issue per non-trivial change.
- Conventional commit prefixes: `feat:`, `fix:`, `docs:`, `chore:`, `release:`,
  `version:`.

## Scoped instructions

- `App/CLAUDE.md`: SwiftUI / `MenuBarExtra` app constraints.
- `Scripts/CLAUDE.md`: build, sign, notarize, package conventions.
- `.github/CLAUDE.md`: CI and release workflow conventions.
- `docs/CLAUDE.md`: OKF authoring contract for the knowledge bundle.
