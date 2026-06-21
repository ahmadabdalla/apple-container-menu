---
type: Decision
title: Definition of Ready provenance gate
description: Fail-closed controls that block app code until a human blesses a provenance manifest for the active issue.
timestamp: 2026-06-21
tags: [process, agents, governance, hooks]
status: Accepted
---

# 17. Definition of Ready provenance gate

## Context

An agent fills missing requirement context with training data. The dangerous
gaps are the invisible ones: the model never registers them as gaps because its
prior makes absence feel like knowledge. Self-reported uncertainty only surfaces
the gaps the agent already knows it has, which are the safe ones. So "stop when
unsure" is necessary but insufficient; introspection cannot catch what sits below
introspection.

Judgment over whether requirements and patterns are correct is the human's, and
is not delegated. What can be made mechanical is provenance: every implementation
step should resolve to a codified concept or an explicit issue line, and anything
else is a gap and a halt. The need is a deterministic, fail-closed control that
makes "is this work Ready" a checkable property rather than a feeling, without
ever automating the judgment call.

## Decision

Gate app code behind a Definition of Ready provenance contract. Each issue
carries a Provenance manifest of the codified concepts that govern the work. A
human blesses readiness by minting a marker only a human can produce. A
preventative control blocks an agent from writing `app/**` until that marker
exists; a detective control re-checks at push time. The machinery resolves
provenance only; it never evaluates whether a cited pattern is correct.

## How

The manifest lives in the issue body under a `## Provenance` section, one per
issue. Each line is `pattern: docs/decisions/NNN-...` for an existing concept, or
`new-pattern: <name>` for one that needs an ADR first.

A `new-pattern:` line is a forward declaration of an unwritten ADR. To reach
Ready, the human authors the ADR, sets its `status` to `Accepted`, then converts
the line to a `pattern:` link. So `scripts/check-ready.sh` only ever resolves
`pattern:` links to existing files (an ADR target must be `Accepted`), and any
surviving `new-pattern:` line is an automatic fail. This keeps the check
deterministic and judgment-free, and avoids fragile slug-to-file matching.

The active issue is the branch name, convention `issue-<n>-slug`, parsed by the
scripts and hooks.

`scripts/check-ready.sh <n>` fetches the issue body with `gh`, validates the
manifest, and prints a `shasum -a 256` of the trimmed manifest block. The
marker, `.claude/ready/<n>.ok`, holds that hash; it is gitignored local human
provenance, not repo state. `scripts/ready.sh` mints it after a passing check.
The human runs `ready.sh` outside the agent; the agent cannot mint it.

Two layers enforce the gate, both scoped to `app/**`:

- Preventative: a Claude Code `PreToolUse` hook, `.claude/hooks/dor-guard.sh`,
  blocks an `Edit`/`Write` under `app/` unless a marker for the active issue
  exists, blocks any write under `.claude/ready/`, and blocks an agent `Bash`
  call that invokes `ready.sh`. Reads are never blocked. This is the fast-fail
  Claude Code layer, not the universal floor.
- Detective: the `.githooks/pre-push` hook re-runs `check-ready.sh`, verifies the
  marker hash matches, and runs the test suite, but only when the pushed commits
  touch `app/**`. This is the tool-agnostic floor; it catches a stale marker, a
  manifest edited after blessing, or a `commit --no-verify` bypass.

Scoping the detective control to `app/**` mirrors the preventative one and means
the gate never blocks its own construction: building it touches no `app/` file,
so this decision and its machinery ship without a manifest of their own.

## Consequences

- Readiness becomes a checkable contract minted by a human; an agent cannot
  rubber-stamp its own work, because it cannot write the marker.
- `check-ready.sh` and `pre-push` need `gh` plus network at their boundary; an
  offline push of an `app/**` change fails closed. This is a deliberate boundary
  event, not a hot path.
- Non-app branches (docs, tooling, this gate itself) carry no manifest and are
  not gated, so trivial changes are not taxed.
- The `PreToolUse` layer governs Claude Code only; another tool bypasses it and
  is caught at push instead. The push hook is the real floor, and `--no-verify`
  can still skip it locally, so it is a floor, not a wall.
- The marker embeds the manifest hash, so editing requirements after blessing
  invalidates readiness and forces a re-mint.
- The hash is computable by anyone, including the agent, because `check-ready.sh`
  carries no secret and no judgment. So "human-minted" rests on denying the agent
  every write surface to `.claude/ready/`, not on the marker being unforgeable.
  The two surfaces are not equally strong, by design. The `Edit`/`Write` path
  classifies on the resolved real path (`./`, `..`, and case-insensitive volumes
  cannot dodge it) and is the airtight floor. The Bash marker-dir and `ready.sh`
  string-match is best-effort: it stops casual minting but is evadable by
  assembling the path from pieces, so it is a deterrent, not a wall. The honest
  guarantee is that the agent does not casually self-approve, not that it cannot
  under adversarial effort. The human mints by running `ready.sh` via the `!`
  prompt prefix or a separate terminal, which is not an agent tool call and so is
  never guarded.

## Alternatives / deferred

- Trusting agent-reported confidence: rejected; it cannot surface invisible
  assumptions, which is the whole problem.
- An LLM judge of readiness: rejected; judgment stays with the human by design.
- A `.current-issue` file instead of the branch name: rejected; one more artifact
  to drift when the branch already encodes the issue.
- Per-criterion provenance tags: rejected; patterns span criteria and tagging
  each one manufactures fake citations for behavioral criteria.
- `new-pattern:` resolved by slug-matching a decisions file: rejected for
  conversion-on-acceptance; matching filenames to names is brittle.
- CI enforcement of the detective check: deferred; local-first now, `.github/`
  has no workflow yet, and CI may later mirror it as a backstop.
- Gate 4 (does the work verify, not just declare): deferred; this ADR covers
  Ready, not Verify.
