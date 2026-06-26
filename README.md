# apple-container-menu

A native macOS menu bar app that surfaces Apple's `container` CLI status:
running containers, one click away in the menu bar.

> Status: early skeleton. The SwiftUI menu bar shell exists, but there is no
> distributable app yet. Container monitoring lands in later issues.

## What it does

Once built, `apple-container-menu` runs as a menu bar app (no Dock icon) and
shows the state of containers managed by Apple's `container` CLI. The first
release is read-only; mutating actions (start, stop, remove) are deferred (see
[ADR 001](docs/decisions/001-read-only-scope.md)). It targets macOS 14 (Sonoma)
and later on Apple silicon.

## How to use

Not yet distributable. You can build the local skeleton with Xcode:

```bash
xcodebuild -project app/AppleContainerMenu.xcodeproj -scheme AppleContainerMenu build
```

When released, it will ship as a signed, notarized `.dmg` on the GitHub Releases
page: download, drag to `Applications`, and launch. A personal Homebrew tap may
follow.

It requires Apple's `container` CLI installed and its service running:

```bash
brew install container
container system start
container ls
```

## How to contribute

1. Open an issue using the task template. Every issue must be self-contained:
   what, why, constraints, acceptance criteria. Blank issues are disabled.
2. Branch from `main`; do not commit to `main` directly. One issue per
   non-trivial change.
3. Use conventional commit prefixes (`feat:`, `fix:`, `docs:`, `chore:`,
   `release:`, `version:`).
4. Agents and contributors: start at `docs/index.md` for decisions and verified
   facts, then read `CLAUDE.md` and the scoped `CLAUDE.md` for the area you are
   touching before starting.
