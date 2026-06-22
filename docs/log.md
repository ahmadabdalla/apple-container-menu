# Log

## 2026-06-22

* **Decision**: Added a leading status glyph to the menu rows (issue #25).
  Running rows show a filled green dot, non-running rows a filled red dot, via
  NSMenuItem.image; row text is unchanged. Extends 010-inline-rows-menu-chrome.md.
* **Creation**: Added reference/disabled-menu-item-images.md; verified that
  non-template palette SF Symbol images remain readable on disabled menu rows in
  light and dark appearance.
* **Creation**: Added reference/container-state-values.md; verified by experiment that container ls status.state is binary (running or stopped) with no transient lifecycle states.

## 2026-06-21

* **Creation**: Added reference/swiftui-menubarextra.md for MenuBarExtra macOS 13 API availability and minimal syntax.
* **Creation**: Adopted OKF v0.1 (issue #5); added doctrine/prose.md, reference/{cli-json-output, service-status, binary-paths}.md, and decision 013-okf-knowledge-format.md.
* **Creation**: Added decision 014-markdown-format-enforcement.md (issue #6); markdown normalized by scripts/format-markdown.sh and enforced by .githooks/pre-commit.
* **Decision**: Resolved the fetch-on-open trigger (issue #12). Added decision 015-appkit-status-item-open-trigger.md and reference/nsstatusitem-menu-open.md; the menu now renders from an AppKit NSStatusItem whose menuWillOpen drives the fetch. Set 008-menubarextra-menu-style.md to Superseded and reconciled 003 and 009.
* **Creation**: Added decision 016-swift-testing-framework.md (issue #13); AppleContainerMenuTests Swift Testing target with unit/functional tiers over an injected ContainerCLI seam, run via xcodebuild.
* **Decision**: Recorded the docs-vs-reality contract (issue #18). Added decision 017-context-describes-current-state.md; context files describe what exists today and mark planned artifacts explicitly. Reconciled scope and stale MenuBarExtra wording in CLAUDE.md/README, marked .github and scripts CLAUDE.md as planned, backfilled 015 and 016 in the decisions index, and aligned the .claude test-command allowlist.
