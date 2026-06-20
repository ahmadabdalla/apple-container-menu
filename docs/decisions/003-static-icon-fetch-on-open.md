---
type: Decision
title: Static icon, fetch on open
description: The menu bar icon is static and the app fetches once when the menu opens, with no background poll.
timestamp: 2026-06-21
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

The fetch is triggered from the menu content appearing on open. There is no timer
and no background activity while the menu is closed. Idle cost is effectively
zero.

## Consequences

- Simplest functional model: click, see state.
- No battery or CPU cost at rest.
- The icon conveys nothing until opened; at-a-glance state needs a future live
  icon, which is purely additive (wrap the same fetch in a timer).

## Alternatives / deferred

- Live icon with background poll: deferred. Same data layer; add a timer and bind
  the result to the icon.
