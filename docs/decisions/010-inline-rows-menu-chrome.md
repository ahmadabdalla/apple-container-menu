---
type: Decision
title: Inline rows and menu chrome
description: Each container is one inline single-line item with Refresh and Quit fixed below the list.
timestamp: 2026-06-21
tags: [ui, layout, menu]
status: Accepted
---

# 10. Inline rows and menu chrome

## Context

Each container's detail (image, uptime, ports) can be shown inline on one line or
hidden behind a per-container submenu. In a read-only app a submenu would hold
only static text and no actions.

## Decision

Each container is one inline, single-line menu item. Fixed items below the list:
Refresh and Quit.

## How

A running row reads roughly `name  state, up Xh, :port`; a stopped row drops the
uptime clause (`name  stopped`, ports appended when published). `name` is the
container `id` and `image` is decoded but not shown inline (see
[007](007-container-data-model.md)). Many ports are truncated (for example
`:3001 +2`). The five non-populated states (see
[005](005-six-state-model.md)) replace the list with a single explanatory item,
keeping Refresh and Quit below. Refresh forces a re-fetch (it is the escape hatch
for cache staleness, see [009](009-last-known-cache.md)). Quit is required
because an `LSUIElement` app has no Dock icon.

## Consequences

- Everything is visible at a glance, no nesting.
- A container with many ports yields a long line; ports are truncated.
- A submenu is deferred until it carries actions.

## Alternatives / deferred

- Per-container submenu: deferred; it earns its place when start, stop, and remove
  actions exist, which belong inside it.
