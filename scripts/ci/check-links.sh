#!/usr/bin/env bash
# CI: verify internal relative markdown links resolve to real files.
#
# Checks [text](target) links where target is a relative path ending in .md
# (optionally with a #anchor). Skips http(s), mailto, structs://, absolute
# site paths (/foo), and pure #anchors. Redirect stubs are valid targets.
# Portable to bash 3.2 (no mapfile).
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"
BROKEN=0

find . -type f -name '*.md' \
  -not -path './.references/*' -not -path './.git/*' \
  -not -path './structs-webapp/*' -not -path './structs-desktop/*' \
  -not -path '*/node_modules/*' -not -name 'CHANGELOG.md' -print | while IFS= read -r f; do
  dir="$(dirname "$f")"
  grep -oE '\]\(([^)]+)\)' "$f" 2>/dev/null | sed -E 's/^\]\(//; s/\)$//' | while IFS= read -r target; do
    case "$target" in
      http://*|https://*|mailto:*|structs://*|/*|\#*|"") continue;;
    esac
    path="${target%%#*}"
    case "$path" in *.md) : ;; *) continue;; esac
    # Intentionally-local, gitignored files an operator/agent creates at runtime.
    case "$path" in */config/operator.md|config/operator.md) continue;; esac
    if [ ! -f "$dir/$path" ]; then
      echo "BROKEN LINK $f -> $target" >&2
    fi
  done
done > /tmp/structs-linkcheck.out 2>/tmp/structs-linkcheck.err || true

if [ -s /tmp/structs-linkcheck.err ]; then
  cat /tmp/structs-linkcheck.err >&2
  BROKEN="$(wc -l < /tmp/structs-linkcheck.err | tr -d ' ')"
fi

if [ "${BROKEN:-0}" -eq 0 ]; then
  echo "OK: no broken internal .md links"
  exit 0
else
  echo "check-links FAILED: $BROKEN broken internal link(s)" >&2
  exit 1
fi
