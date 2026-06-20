---
type: Reference
title: container service status behavior
description: Exit-code and message behavior of container system status and container ls when the service is down.
timestamp: 2026-06-21
tags: [cli, service, reference]
resource: https://github.com/apple/container
---

# container service status behavior

How the CLI behaves when the local container service is stopped. Established by
experiment on 2026-06-21 (service stopped, then observed).

## Service down

| Command | Exit | Output |
|---------|------|--------|
| `container system status` | non-zero | clean message: `apiserver is not running and not registered with launchd` |
| `container ls --all --format json` | non-zero | noisy internal error (XPC) plus a hint line |

## Implication

`container system status` is a reliable exit-code boolean for "is the service
up": no string parsing, nothing Apple can break by rewording. The app gates on it
before running `ls` (see
[../decisions/006-two-command-fetch-flow.md](../decisions/006-two-command-fetch-flow.md)).

Note: stopping the service also stops running containers, and they do not
auto-restart on `container system start`.

## Citations

[1] [Apple container CLI](https://github.com/apple/container)
[2] Verified by experiment, 2026-06-21.
