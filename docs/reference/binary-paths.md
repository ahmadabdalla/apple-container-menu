---
type: Reference
title: container binary locations
description: Where the container binary lives by install method, and why a GUI app cannot rely on PATH.
timestamp: 2026-06-21
tags: [cli, path, install, reference]
resource: https://formulae.brew.sh/formula/container
---

# container binary locations

A GUI `.app` launched from Finder does not inherit the shell PATH, so invoking
`container` by bare name fails in the shipped app even though it works in a
terminal. The binary must be found by absolute path.

## Locations (Apple silicon)

| Install method | Path |
|----------------|------|
| Homebrew | `/opt/homebrew/bin/container` (symlink into the Cellar) |
| Official Apple pkg | `/usr/local/bin/container` |

Intel locations are out of scope; the app targets Apple silicon only.

The app checks these in order, Homebrew first, and uses the first that exists
(see [../decisions/004-cli-binary-resolution.md](../decisions/004-cli-binary-resolution.md)).

## Citations

[1] [Homebrew container formula](https://formulae.brew.sh/formula/container)
[2] [Apple container CLI](https://github.com/apple/container)
