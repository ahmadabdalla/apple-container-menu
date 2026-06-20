# Design decisions

Architecture Decision Records (ADRs) for apple-container-menu. Each file is one
decision: why it was made, how it is applied, what it costs, and what we
deferred. These are the detail behind the operating doctrine in the root
`CLAUDE.md`. Scoped `CLAUDE.md` files and issues point here instead of inlining
rationale.

Read an ADR when your task touches its area. Do not read all of them up front.

## Index

| ADR | Decision | Status |
|-----|----------|--------|
| [001](001-read-only-scope.md) | Read-only monitor for the MVP | Accepted |
| [002](002-cli-output-json.md) | Parse `container` JSON output | Accepted |
| [003](003-static-icon-fetch-on-open.md) | Static icon, fetch on open | Accepted |
| [004](004-cli-binary-resolution.md) | CLI binary resolution | Accepted |
| [005](005-six-state-model.md) | Six-state model | Accepted |
| [006](006-two-command-fetch-flow.md) | Two-command fetch flow | Accepted |
| [007](007-container-data-model.md) | Container data model | Accepted |
| [008](008-menubarextra-menu-style.md) | MenuBarExtra `.menu` style | Accepted |
| [009](009-last-known-cache.md) | Last-known cache | Accepted |
| [010](010-inline-rows-menu-chrome.md) | Inline rows and menu chrome | Accepted |
| [011](011-xcode-project-scaffolding.md) | Xcode project scaffolding | Accepted |
| [012](012-async-cli-execution.md) | Async CLI execution | Accepted |

## Scope

These cover the read-only MVP only. Distribution (signing, notarizing,
packaging) and post-MVP features (actions, live icon, infrastructure-container
filter, configurable binary path) are out of scope until they earn their own
ADRs.
