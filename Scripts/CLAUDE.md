---
type: Instruction
title: Scripts constraints
description: Build, sign, notarize, package, and repo-maintenance script conventions: atomic, composable, gated, lean comments, no hardcoded credentials.
timestamp: 2026-06-21
tags: [scripts, build, constraints]
---

# Scripts constraints

Build, sign, notarize, and package scripts for distribution.

Standing decisions:

- Atomic and composable: one script, one job. No mega-script. Compose them (for
  example, a release step that calls build, then notarize, then package) rather
  than inlining everything into one file.
- Gated operations (`codesign`, `xcrun notarytool submit`, `gh release create`,
  Homebrew tap pushes) require explicit approval; see `.claude/settings.json`.
- Never hardcode signing identities or credentials; read them from the
  environment or keychain.
- Comments are lean. Explain the non-obvious (a perl flag, a footgun, why a step
  exists), not what the code already says. No banner blocks, no narrating obvious
  lines.
- Markdown is normalized by `format-markdown.sh` (whitespace only: trailing
  whitespace, blank-line runs, final newline) and enforced by the
  `.githooks/pre-commit` hook, which fixes and re-stages staged `.md`. A new clone
  runs `git config core.hooksPath .githooks` once. See
  `docs/decisions/014-markdown-format-enforcement.md`.
