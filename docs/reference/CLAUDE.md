---
type: Instruction
title: Reference authoring rules
description: How to author Reference concepts in docs/reference.
timestamp: 2026-06-21
tags: [okf, authoring, reference]
---

# reference authoring rules

Concepts here are `type: Reference`: verified external facts (CLI behavior,
install paths, output shapes). Shared schema is in the parent
[../CLAUDE.md](../CLAUDE.md).

- `type` is always `Reference`. `resource` is required and points at the
  canonical upstream source the fact derives from.
- State facts, not decisions. A decision that consumes a fact lives in
  `decisions/` and links here; do not argue tradeoffs in a reference.
- Cite the source under a `## Citations` heading. If a fact was established by
  experiment, say so and date it, so it can be re-verified.
- A new reference, or removing a stale one, is a material change: add a
  `../log.md` entry.
