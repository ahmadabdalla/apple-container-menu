---
type: Decision
title: Enforce markdown formatting with a git pre-commit hook
description: A single script normalizes markdown whitespace; a git pre-commit hook fixes and re-stages it, with no CI and no editor hook.
timestamp: 2026-06-21
tags: [formatting, tooling, hooks, scripts]
status: Accepted
---

# 14. Enforce markdown formatting with a git pre-commit hook

## Context

The OKF bundle (decision [013-okf-knowledge-format.md](013-okf-knowledge-format.md))
was normalized by hand before it merged: trailing whitespace stripped, runs of
blank lines collapsed, one final newline. That is a per-file invariant worth
keeping, but a hand step does not hold. The repo's markdown is authored by agents,
not people, so enforcement can sit close to the agent's workflow rather than in a
shared pipeline.

## Decision

Normalize markdown with one script and enforce it with one local gate: a git
pre-commit hook that fixes staged markdown and re-stages it. No CI check and no
Claude Code editor hook.

## How

- `Scripts/format-markdown.sh (--check|--write) <paths>` applies the whitespace
  rules: strip trailing whitespace, collapse 3+ newlines to one blank line, end
  with exactly one newline. It is idempotent and touches whitespace only (no
  reflow, no bullet-marker changes).
- `.githooks/pre-commit` runs `--write` on staged `.md`, re-stages the result, and
  no-ops when no markdown is staged.
- The hook is shared by committing `.githooks/` and setting
  `core.hooksPath .githooks`; a new clone runs that `git config` once.
- The script is bash 3.2 compatible (macOS default) and depends only on perl and
  coreutils already present.

## Consequences

- Docs stay normalized without a human or a runtime toolchain.
- Enforcement is local and self-contained; nothing runs in GitHub Actions for
  this.
- The gate is bypassable (`git commit --no-verify`) and inactive until a clone
  sets `core.hooksPath`. Accepted: the sole authors are agents in this repo, and
  the cost of a missed normalization is cosmetic.
- A file staged partially is fully staged by the re-stage step. Accepted: agents
  stage whole files.

## Alternatives / deferred

- CI check that fails on unformatted docs: rejected; no humans write markdown
  here, so a shared pipeline guard is scope we do not need. Revisit if outside
  contributors start editing docs.
- Claude Code `PostToolUse` hook that auto-formats on every write: rejected as the
  primary gate; it mutates silently and is not a commit-time guarantee. The
  pre-commit hook covers every author and tool at the gate. Revisit if write-time
  ergonomics matter more than the single gate.
