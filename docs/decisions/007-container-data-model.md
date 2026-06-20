---
type: Decision
title: Container data model
description: Decode five fields per container and show all containers including infrastructure ones.
timestamp: 2026-06-21
tags: [model, json, data]
status: Accepted
---

# 7. Container data model

## Context

The `ls --format json` payload is large and deeply nested (config, networks,
mounts, env, resources, image descriptor; see
[json output](../reference/cli-json-output.md)). A row needs only enough to answer
"what is this and is it alive", plus a couple of useful extras.

## Decision

Decode and surface five fields per container: `id`, `state` (`status.state`),
`image` (`configuration.image.reference`), `startedDate` (`status.startedDate`),
and `publishedPorts` (`configuration.publishedPorts`). Show all containers,
including infrastructure ones (for example `buildkit`).

## How

The `Decodable` struct models only these five and ignores everything else, so the
JSON can grow without breaking. `startedDate` renders as relative uptime;
`publishedPorts` renders only when non-empty. Infrastructure containers are
identifiable by the label `com.apple.container.resource.role` but are not
filtered in the MVP.

## Consequences

- The row answers "what, alive, since when, on which ports" without crowding.
- More fields later means more CodingKeys, not a restructure.
- The user's own list shows infrastructure containers (noisier), accepted for
  now.

## Alternatives / deferred

- Decode IP, MAC, networks, mounts, env, resources, platform: deferred; additive.
- Filter infrastructure containers: deferred; a toggle later.
