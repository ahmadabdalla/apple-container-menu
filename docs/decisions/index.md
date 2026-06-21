# Decisions

Architecture Decision Records for apple-container-menu. Each concept is one
decision: context (why), the decision, how it applies, consequences, and deferred
alternatives. Read one when your task touches its area.

* [001 Read-only monitor for the MVP](001-read-only-scope.md) - The MVP only runs observing commands; mutating actions are deferred.
* [002 Parse container JSON output](002-cli-output-json.md) - Read state via container ls --all --format json and decode only the needed fields.
* [003 Static icon, fetch on open](003-static-icon-fetch-on-open.md) - Static menu bar icon; fetch once on open, no background poll.
* [004 CLI binary resolution](004-cli-binary-resolution.md) - Resolve the binary from an ordered candidate list because a GUI app has no PATH.
* [005 Six-state model](005-six-state-model.md) - One enum models loading, not-found, not-running, empty, populated, error.
* [006 Two-command fetch flow](006-two-command-fetch-flow.md) - Gate on system status exit code, then run ls.
* [007 Container data model](007-container-data-model.md) - Decode five fields per container; show all including infrastructure.
* [008 MenuBarExtra .menu style](008-menubarextra-menu-style.md) - Superseded by 015. Used the native .menu style rather than .window.
* [009 Last-known cache](009-last-known-cache.md) - Render the last-known result on open; refresh the cache asynchronously.
* [010 Inline rows and menu chrome](010-inline-rows-menu-chrome.md) - One inline single-line item per container; Refresh and Quit fixed below.
* [011 Xcode project scaffolding](011-xcode-project-scaffolding.md) - Ship as a raw Xcode project driven by composable scripts.
* [012 Async CLI execution](012-async-cli-execution.md) - Run the CLI off the main thread with async/await.
* [013 Adopt Open Knowledge Format](013-okf-knowledge-format.md) - docs/ becomes an OKF v0.1 bundle and the CLAUDE.md files become nodes.
* [014 Enforce markdown formatting with a pre-commit hook](014-markdown-format-enforcement.md) - One script normalizes whitespace; a git pre-commit hook fixes and re-stages it.
* [015 AppKit status item open trigger](015-appkit-status-item-open-trigger.md) - Render the menu from an AppKit NSStatusItem so menuWillOpen fetches on open; supersedes 008.

## Scope

These cover the read-only MVP and the repo's knowledge format. Distribution
(signing, notarizing, packaging) and post-MVP features (actions, live icon,
infrastructure-container filter, configurable binary path) earn their own ADRs.
