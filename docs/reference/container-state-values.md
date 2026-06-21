---
type: Reference
title: container status.state values
description: The status.state field from container ls only emits running or stopped; there are no transient lifecycle states.
timestamp: 2026-06-22
tags: [cli, json, state]
resource: https://github.com/apple/container
---

# container status.state values

`status.state` in `container ls --all --format json` is binary: `running` or
`stopped`. There is no transient lifecycle value.

| Action                   | Resulting `status.state` |
| ------------------------ | ------------------------ |
| `create` (never started) | `stopped`                |
| `start`                  | `running`                |
| `stop`                   | `stopped`                |
| `kill`                   | `stopped`                |

Tight polling across start and stop transitions observed only `running` and
`stopped`; no `starting`, `stopping`, `created`, or `paused`. Transitions are
atomic from this field. A UI distinction beyond running versus not-running
therefore has no data in this field to stand on.

## Citations

[1] [Apple container CLI](https://github.com/apple/container)
[2] Verified by experiment, 2026-06-22, container CLI v1.0.0.
