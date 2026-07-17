#!/usr/bin/env bash
# CI: verify the root skills/ mirror matches the canonical .cursor/skills/ tree.
# Fails if they have drifted (i.e. someone edited .cursor/skills/ without
# regenerating, or hand-edited the mirror).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SRC="$ROOT/.cursor/skills"
DST="$ROOT/skills"

if [ ! -d "$DST" ]; then
  echo "FAIL: skills/ mirror missing. Run scripts/gen-skills-mirror.sh" >&2
  exit 1
fi

# Compare content, ignoring the generator marker file.
if diff -r --exclude='.generated' "$SRC" "$DST" >/tmp/skills-mirror.diff 2>&1; then
  echo "OK: skills/ mirror is in sync with .cursor/skills/"
else
  echo "FAIL: skills/ mirror has drifted from .cursor/skills/:" >&2
  cat /tmp/skills-mirror.diff >&2
  echo "Fix: scripts/gen-skills-mirror.sh" >&2
  exit 1
fi
