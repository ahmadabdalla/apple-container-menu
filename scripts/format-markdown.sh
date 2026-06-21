#!/usr/bin/env bash
# Normalize markdown whitespace only: trailing whitespace, blank-line runs, final
# newline. No reflow, no bullet-marker changes. Idempotent. Enforced by
# .githooks/pre-commit; see scripts/CLAUDE.md.
set -euo pipefail

# -0777 slurps the file so the final-newline rule sees end-of-file.
PERL_RULES='s/[ \t]+$//mg; s/\n{3,}/\n\n/g; s/\s*\z/\n/'

usage() {
  echo "usage: $(basename "$0") (--check|--write) <file-or-dir>..." >&2
  exit 2
}

[ $# -ge 2 ] || usage
mode=$1
shift
case "$mode" in
  --check | --write) ;;
  *) usage ;;
esac

# Expand args into a flat list of .md files.
files=()
for arg in "$@"; do
  if [ -d "$arg" ]; then
    while IFS= read -r f; do
      files+=("$f")
    done < <(find "$arg" -type f -name '*.md')
  elif [ -f "$arg" ]; then
    case "$arg" in
      *.md) files+=("$arg") ;;
    esac
  fi
done

[ ${#files[@]} -gt 0 ] || exit 0

status=0
for f in "${files[@]}"; do
  if [ "$mode" = "--write" ]; then
    perl -0777 -pi -e "$PERL_RULES" "$f"
  else
    if ! perl -0777 -pe "$PERL_RULES" "$f" | cmp -s - "$f"; then
      echo "unformatted: $f" >&2
      status=1
    fi
  fi
done

exit $status
