---
type: Decision
title: MenuBarExtra .menu style
description: Use the native .menu style rather than .window, accepting reduced visual expressiveness.
timestamp: 2026-06-21
tags: [ui, menubarextra, swiftui]
status: Accepted
---

# 8. MenuBarExtra .menu style

## Context

SwiftUI `MenuBarExtra` offers two mutually exclusive styles. `.menu` renders a
native dropdown menu (buttons, dividers, single-line items). `.window` renders a
popover panel with full SwiftUI layout (spinners, colored dots, multi-line rows).
Apple recommends `.window` for data-rich extras.

## Decision

Use the `.menu` style.

## How

States render as native menu items. The loading state is a text item
("Checking...") rather than a spinner; container status is an SF Symbol or text,
not a free-form colored dot; rows are single-line (see
[010](010-inline-rows-menu-chrome.md)). The async-update limitation of menus is
handled by a cache (see [009](009-last-known-cache.md)).

## Consequences

- Native, familiar menu feel.
- Visual expressiveness is reduced: no spinner, limited color, single-line rows.
- A menu is essentially a snapshot at open time, which forces the caching
  decision.

## Alternatives / deferred

- `.window` style: deferred. Richer layout and reactive updates while open, at the
  cost of a popover look instead of a native menu. Revisit if the visual limits or
  the async-update behavior become a problem.
