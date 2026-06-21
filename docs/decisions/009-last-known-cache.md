---
type: Decision
title: Last-known cache
description: Render the last-known result synchronously on open and refresh the cache asynchronously.
timestamp: 2026-06-21
tags: [cache, ui, async]
status: Accepted
---

# 9. Last-known cache

## Context

The fetch is async (a process spawn returns tens of milliseconds after the menu
opens). The menu is effectively a snapshot at open time (see
[015](015-appkit-status-item-open-trigger.md)), and its ability
to re-render items from an async result while already open is unreliable. Without
a cache, the first open shows "Checking..." and may need a close-and-reopen to
show data.

## Decision

Keep a last-known result in memory. On open, render it synchronously; kick the
async fetch to update the cache for the next open.

## How

The cache holds the most recent successful fetch. Opening renders from cache
immediately (or "Checking..." if cold), then the fetch-on-open refresh updates
it. This is not background polling: it only fetches on open. A manual Refresh item
(see [010](010-inline-rows-menu-chrome.md)) forces an update.

## Consequences

- The menu always has something to render synchronously; the UI never blocks.
- Data is at most one open stale after a change; self-correcting.
- The first cold open still shows "Checking..." until reopened.

## Alternatives / deferred

- Blocking fetch on open: rejected; freezes the menu bar, beachball risk if the
  CLI or service is slow.
- A reactive popover that re-renders while open: deferred; it would avoid this
  tension, but the app uses a native `NSMenu` snapshot instead (see
  [015](015-appkit-status-item-open-trigger.md)).
