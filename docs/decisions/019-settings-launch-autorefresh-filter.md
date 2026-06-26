---
type: Decision
title: Settings, launch-at-login, auto-refresh, and filter
description: Add an inline settings panel, SMAppService launch-at-login, opt-in poll-while-open, a name filter, and a port-opening row action.
timestamp: 2026-06-26
tags: [ui, settings, launch-at-login, auto-refresh, filter]
status: Accepted
---

# 19. Settings, launch-at-login, auto-refresh, and filter

## Context

The popover (see [018](018-swiftui-popover-ui.md)) is the substrate for the rest
of issue #24: a name filter, an auto-refresh toggle, a settings surface
(launch-at-login and refresh interval), and opening a published port. These need
a persistence story, a login-item mechanism, and a place to live, none of which
the read-only MVP had.

## Decision

Add an inline settings panel inside the popover, launch-at-login through
`SMAppService.mainApp`, an opt-in poll that refreshes only while the popover is
open, a case-insensitive name filter, and a port chip that opens
`http://localhost:<hostPort>`. Settings persist in `UserDefaults`.

## How

The gear in the chrome bar swaps the popover content for the settings panel; it
is not a separate `Settings` window, because opening one from an `LSUIElement`
menu-bar app on macOS 14 is unreliable (`SettingsLink` and `openSettings` need a
live render tree, and the legacy selectors throw on Sonoma). `@AppStorage` holds
`autoRefreshEnabled` (default off, so fetch-on-open stays the baseline) and
`refreshIntervalSeconds` (default 5, chosen from 2, 5, 10, 30). Launch-at-login is
not persisted: `SMAppService.mainApp.status` is the source of truth, and the
toggle reads it back after each register or unregister so a failed call
self-corrects.

The poll loop lives in `AppDelegate`, starts on `popoverWillShow`, is cancelled on
`popoverDidClose`, and re-reads the settings each pass so toggling mid-open takes
effect. It never runs in the background, so the no-background-poll stance of
[003](003-static-icon-fetch-on-open.md) holds. The filter is view-local state
matched by `Container.matches(filter:)`; an empty query matches all and zero
matches shows a line. The port chip is the one row action; opening a URL is not a
container mutation, so read-only [001](001-read-only-scope.md) is preserved.

## Consequences

- The app gains persisted settings and a registered login item: the first
  `UserDefaults` use and the first `ServiceManagement` dependency.
- Auto-refresh softens fetch-on-open into poll-while-open when opted in, but only
  while open; closing the popover stops it.
- The port chip, display-only in [018](018-swiftui-popover-ui.md), becomes a
  read-only action that opens the host port in the browser.
- Launch-at-login registration can fail silently under ad-hoc signing; the toggle
  reflects the real status rather than the requested one.

## Alternatives / deferred

- Separate SwiftUI `Settings` window: rejected; unreliable to open from a menu-bar
  `LSUIElement` app on macOS 14 without a hidden-window and dock-icon hack or a
  third-party package.
- Background polling regardless of popover state: rejected; it reintroduces the
  drain [003](003-static-icon-fetch-on-open.md) avoided, for no benefit while the
  popover is closed.
- Persisting launch-at-login in `UserDefaults`: rejected; the system registration
  can change outside the app, so the live `SMAppService` status is authoritative.
