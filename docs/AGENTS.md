---
type: Instruction
title: OKF authoring contract
description: How to author concepts in this bundle: types, frontmatter, links, indexes, and the log.
timestamp: 2026-06-21
tags: [okf, authoring, meta]
---

# docs authoring contract

`docs/` is an Open Knowledge Format (OKF) v0.1 bundle. Every non-reserved `.md`
file here is a concept: YAML frontmatter plus a markdown body. Why we adopted
OKF and every choice below is recorded in
[decisions/013-okf-knowledge-format.md](decisions/013-okf-knowledge-format.md).
Spec: https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md

This is the shared contract. Each subfolder's `CLAUDE.md` adds only its own
narrow rules and relies on this file being loaded with it.

## Type vocabulary

`type` is required and closed. Do not add a value without an ADR.

| `type` | Used for | Folder |
|--------|----------|--------|
| `Decision` | Architecture Decision Records | `decisions/` |
| `Doctrine` | Operating philosophy (PROSE) | `doctrine/` |
| `Reference` | Verified external facts (CLI behavior, paths) | `reference/` |
| `Instruction` | Scoped authoring and behavior rules | `CLAUDE.md` files |

## Frontmatter schema

```yaml
---
type: <one of the vocabulary>     # required
title: <display name>             # required
description: <one sentence>       # required; read to decide whether to open the body
timestamp: <YYYY-MM-DD>           # required; ISO 8601 date of last meaningful change
tags: [<short>, <short>]          # required; low-cardinality, no central registry
---
```

Per-type additions:

- `Decision` adds `status`: one of `Accepted`, `Superseded`, `Deprecated`. This
  is the single source of truth for status; do not also put it in the body.
- `Reference` adds `resource`: the canonical upstream URI the fact derives from.
- `Doctrine` and `Instruction` add nothing and omit `resource`; there is no
  single underlying asset to point at.

Keep `description` to one sentence: an agent reads it to route, then loads the
body only if relevant. That is the whole point of the format.

## Cross-links

Relative paths only. No bundle-relative `/` links.

- Same folder: `[005](005-six-state-model.md)`
- Across folders: `[json shape](../reference/cli-json-output.md)`
- From a `CLAUDE.md` outside the bundle: repo-relative, `docs/decisions/005-six-state-model.md`

Links assert a relationship; the surrounding prose says what it is. A broken link
is tolerated, not fatal, but fix it when you see it.

## index.md

Reserved filename. One per folder, no frontmatter, body is a sectioned listing
of the folder's concepts with each concept's `description`. The bundle-root
`docs/index.md` is the only `index.md` permitted frontmatter, and only to carry
`okf_version: "0.1"`.

## log.md

Single file at the bundle root: `docs/log.md`. ISO `YYYY-MM-DD` headings, newest
first, one bullet per change with an optional bold category word
(`**Creation**`, `**Update**`, `**Deprecation**`). No prose.

Material-change policy: add an entry only for a new concept, a removed concept,
or a `status` transition. Typo fixes and rewordings get no entry. Without this
rule the log becomes a worse copy of `git log`.

## Conformance

A file here conforms if it has parseable frontmatter with a non-empty `type` from
the vocabulary. Optional fields missing is fine. When in doubt, prefer the
thinnest concept that carries the fact.
