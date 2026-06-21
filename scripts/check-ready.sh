#!/usr/bin/env bash
# Validate an issue's Provenance manifest and print its canonical hash.
# Zero judgment: resolves pattern: links and ADR status only, never whether the
# cited pattern is the right one. Non-zero exit on any miss; on success prints a
# shasum -a 256 of the manifest to stdout.
# Used by scripts/ready.sh (mint) and .githooks/pre-push (detective floor).
# Needs gh plus network to read the issue body.
# See docs/decisions/017-definition-of-ready-gate.md.
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)

# Issue number: explicit arg, else parsed from the issue-<n>-slug branch.
issue=${1:-}
if [ -z "$issue" ]; then
  branch=$(git rev-parse --abbrev-ref HEAD)
  if [[ $branch =~ ^issue-([0-9]+)- ]]; then
    issue=${BASH_REMATCH[1]}
  else
    echo "check-ready: no issue number given and branch '$branch' is not issue-<n>-slug" >&2
    exit 2
  fi
fi

body=$(gh issue view "$issue" --json body -q .body) || {
  echo "check-ready: cannot read issue #$issue (gh not authenticated or offline?)" >&2
  exit 2
}

# Slice the Provenance section: its heading to the next ## heading or EOF.
section=$(printf '%s\n' "$body" | awk '
  /^## Provenance[[:space:]]*$/ { grab=1; next }
  grab && /^## / { grab=0 }
  grab { print }
')

# Drop HTML comment regions so the template guide and its worked example are
# never read as real entries.
manifest=$(printf '%s\n' "$section" | perl -0777 -pe 's/<!--.*?-->//gs')

# Canonical content: non-blank lines with trailing whitespace stripped.
canonical=$(printf '%s\n' "$manifest" | sed -e 's/[[:space:]]*$//' -e '/^[[:space:]]*$/d')

if [ -z "$canonical" ]; then
  echo "check-ready: issue #$issue has no Provenance manifest entries" >&2
  exit 1
fi

status=0
while IFS= read -r line; do
  case "$line" in
    pattern:*)
      path=$(printf '%s' "$line" | sed -E 's/^pattern:[[:space:]]*//')
      case "$path" in
        /* | *..*)
          echo "check-ready: pattern path must be repo-relative with no '..': $path" >&2
          status=1
          continue
          ;;
      esac
      full="$repo_root/$path"
      if [ ! -f "$full" ]; then
        echo "check-ready: pattern target missing: $path" >&2
        status=1
        continue
      fi
      case "$path" in
        docs/decisions/*)
          if ! awk -F': *' '/^status:/ {print $2; exit}' "$full" | grep -qx 'Accepted'; then
            echo "check-ready: ADR not Accepted: $path" >&2
            status=1
          fi
          ;;
      esac
      ;;
    new-pattern:*)
      echo "check-ready: unresolved new-pattern (author + Accept the ADR, then convert to pattern:): $line" >&2
      status=1
      ;;
    *)
      echo "check-ready: unrecognized manifest line: $line" >&2
      status=1
      ;;
  esac
done <<< "$canonical"

[ "$status" -eq 0 ] || exit "$status"

printf '%s' "$canonical" | shasum -a 256 | awk '{print $1}'
