---
type: Reference
title: container ls JSON output
description: The container ls --all --format json command and the fields this app decodes from it.
timestamp: 2026-06-21
tags: [cli, json, reference]
resource: https://github.com/apple/container
---

# container ls JSON output

`container ls` defaults to a human-readable table but accepts `--format`.

## Formats

Verified `--format` values: `json`, `table`, `yaml`, `toml`. The app uses
`container ls --all --format json`; `--all` includes stopped containers.

## Fields decoded

The payload is large and deeply nested (config, networks, mounts, env,
resources, image descriptor). The app decodes only these and ignores the rest,
so the JSON can grow without breaking decoding.

| Field | Source in payload |
|-------|-------------------|
| `id` | container id |
| `state` | `status.state` |
| `image` | `configuration.image.reference` |
| `startedDate` | `status.startedDate` |
| `publishedPorts` | `configuration.publishedPorts` |

Infrastructure containers (for example `buildkit`) are identifiable by the label
`com.apple.container.resource.role`. The MVP does not filter them.

## Citations

[1] [Apple container CLI](https://github.com/apple/container)
[2] Verified by experiment, 2026-06-21.
