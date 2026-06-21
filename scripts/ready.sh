#!/usr/bin/env bash
# Mint the human readiness marker for an issue, once its manifest checks out.
# Run this yourself; the agent is blocked from running it by the PreToolUse
# guard. Minting is the human's bless: it is not delegated.
# See docs/decisions/017-definition-of-ready-gate.md.
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)

issue=${1:-}
if [ -z "$issue" ]; then
  branch=$(git rev-parse --abbrev-ref HEAD)
  if [[ $branch =~ ^issue-([0-9]+)- ]]; then
    issue=${BASH_REMATCH[1]}
  else
    echo "ready: no issue number given and branch '$branch' is not issue-<n>-slug" >&2
    exit 2
  fi
fi

# Mint only when the manifest fully resolves; the marker holds its canonical hash
# so any later manifest edit invalidates readiness.
hash=$("$repo_root/scripts/check-ready.sh" "$issue")

mkdir -p "$repo_root/.claude/ready"
printf '%s\n' "$hash" > "$repo_root/.claude/ready/$issue.ok"

echo "ready: minted .claude/ready/$issue.ok for issue #$issue" >&2
