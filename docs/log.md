# Log

## 2026-06-21

* **Creation**: Added reference/swiftui-menubarextra.md for MenuBarExtra macOS 13 API availability and minimal syntax.
* **Creation**: Adopted OKF v0.1 (issue #5); added doctrine/prose.md, reference/{cli-json-output, service-status, binary-paths}.md, and decision 013-okf-knowledge-format.md.
* **Creation**: Added decision 014-markdown-format-enforcement.md (issue #6); markdown normalized by scripts/format-markdown.sh and enforced by .githooks/pre-commit.
* **Decision**: Resolved the fetch-on-open trigger (issue #12). Added decision 015-appkit-status-item-open-trigger.md and reference/nsstatusitem-menu-open.md; the menu now renders from an AppKit NSStatusItem whose menuWillOpen drives the fetch. Set 008-menubarextra-menu-style.md to Superseded and reconciled 003 and 009.
* **Creation**: Added decision 016-swift-testing-framework.md (issue #13); AppleContainerMenuTests Swift Testing target with unit/functional tiers over an injected ContainerCLI seam, run via xcodebuild.
* **Creation**: Added decision 017-definition-of-ready-gate.md (issue #20); a Definition of Ready provenance gate over the active issue's manifest, enforced by a human-minted marker, a PreToolUse guard, and a pre-push hook scoped to app changes.
