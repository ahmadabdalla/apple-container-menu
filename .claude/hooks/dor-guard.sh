#!/usr/bin/env bash
# Claude Code PreToolUse guard for the Definition of Ready gate.
# Blocks (exit 2): an agent app/ write without a fresh marker; any write under
# .claude/ready/; an agent Bash call that mints the marker. Reads are never
# blocked. This is the fast-fail Claude Code layer; the push hook is the floor.
# See docs/decisions/017-definition-of-ready-gate.md.
set -euo pipefail

input=$(cat)

tool=$(printf '%s' "$input" | /usr/bin/python3 -c 'import sys,json; print(json.load(sys.stdin).get("tool_name",""))')

field() {
  printf '%s' "$input" | /usr/bin/python3 -c \
    "import sys,json; d=json.load(sys.stdin).get('tool_input',{}) or {}; print(d.get('$1',''))"
}

block() {
  echo "dor-guard: $1" >&2
  exit 2
}

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

active_issue() {
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  if [[ $branch =~ ^issue-([0-9]+)- ]]; then
    printf '%s' "${BASH_REMATCH[1]}"
  fi
}

case "$tool" in
  Bash)
    cmd=$(field command)
    # Match ready.sh as an invoked path (preceded by /, space, or line start);
    # the / and space boundary keeps check-ready.sh from matching.
    if printf '%s' "$cmd" | grep -Eq '(^|[[:space:]]|/)ready\.sh([^[:alnum:]]|$)'; then
      block "minting readiness is human-only. Run scripts/ready.sh yourself (the ! prompt prefix or your own terminal)."
    fi
    # Close the redirection surface: any Bash mention of the marker dir is blocked,
    # so the agent cannot fabricate a marker without ready.sh. Reads included; the
    # agent never needs to read it, the hook does.
    if printf '%s' "$cmd" | grep -Eq '\.claude/ready'; then
      block "the readiness marker is human-minted; the agent cannot touch .claude/ready/ from Bash."
    fi
    ;;
  Edit | MultiEdit | Write | NotebookEdit)
    path=$(field file_path)
    [ -n "$path" ] || path=$(field notebook_path)
    [ -n "$path" ] || exit 0
    # Classify on the resolved real path, not the raw string, so ./, .., and a
    # case-insensitive volume cannot dodge the app/ and marker checks. Any
    # classify failure blocks (fail closed).
    klass=$(REPO="$repo_root" TARGET="$path" /usr/bin/python3 - <<'PY'
import os
repo = os.path.realpath(os.environ["REPO"])
p = os.environ["TARGET"]
if not os.path.isabs(p):
    p = os.path.join(repo, p)
p = os.path.realpath(p)
def under(sub):
    base = os.path.realpath(os.path.join(repo, sub))
    pf, bf = p.casefold(), base.casefold()
    return pf == bf or pf.startswith(bf + os.sep)
print("marker" if under(".claude/ready") else "app" if under("app") else "other")
PY
) || block "could not resolve the write path; refusing it."
    case "$klass" in
      marker)
        block "the readiness marker is human-minted; the agent cannot write under .claude/ready/."
        ;;
      app)
        issue=$(active_issue)
        [ -n "$issue" ] || block "not on an issue-<n>-slug branch; cannot verify Definition of Ready for an app/ change."
        [ -f "$repo_root/.claude/ready/$issue.ok" ] || block "issue #$issue is not marked Ready. A human runs scripts/ready.sh $issue after blessing the manifest. See docs/decisions/017-definition-of-ready-gate.md."
        ;;
    esac
    ;;
esac

exit 0
