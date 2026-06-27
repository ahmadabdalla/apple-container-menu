---
type: Decision
title: Static icon, fetch on open
description: The menu bar icon is static and the app fetches once when the menu opens, with no background poll.
timestamp: 2026-06-26
tags: [ui, fetch, performance]
status: Accepted
---

# 3. Static icon, fetch on open

## Context

A menu bar app can either reflect state at rest (a live icon or badge, which
needs a background poll) or stay inert until clicked. A background poll adds
timer lifecycle, frequency tuning, battery cost, and stale-state races.

## Decision

The menu bar icon is static (SF Symbol `shippingbox`). The app does no work until
the menu opens, at which point it fetches once.

## How

The fetch is triggered from `popoverWillShow` on the popover's delegate (see
[018](018-swiftui-popover-ui.md)). There is no timer and no background activity
while the popover is closed. Idle cost is effectively zero. Auto-refresh (see
[019](019-settings-launch-autorefresh-filter.md)) is opt-in and polls only while
the popover is open, so the no-background-poll stance here holds.

## Consequences

- Simplest functional model: click, see state.
- No battery or CPU cost at rest.
- The icon conveys nothing until opened; at-a-glance state needs a future live
  icon, which is purely additive (wrap the same fetch in a timer).

## Alternatives / deferred

- Live icon with background poll: deferred. Same data layer; add a timer and bind
  the result to the icon.
