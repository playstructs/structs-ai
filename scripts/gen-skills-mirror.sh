#!/usr/bin/env bash
# Generate the root skills/ mirror from the canonical .cursor/skills/ tree.
#
# Why: .cursor/skills/ is the canonical AgentSkills source. Root skills/ is the
# OpenClaw-facing discovery surface and the GitHub Pages URL base
# (https://structs.ai/skills/<name>/SKILL). We keep skills/ as REAL FILES (not
# symlinks) so checkouts work on Windows. This script rebuilds that mirror.
#
# Usage: scripts/gen-skills-mirror.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/.cursor/skills"
DST="$ROOT/skills"

if [ ! -d "$SRC" ]; then
  echo "error: canonical skills dir not found: $SRC" >&2
  exit 1
fi

# Remove any legacy symlinks and stale mirror contents, then copy fresh.
rm -rf "$DST"
mkdir -p "$DST"

# Copy the entire tree verbatim (byte-identical, so publishing + diff checks work).
if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete "$SRC"/ "$DST"/
else
  cp -R "$SRC"/. "$DST"/
fi

# Marker so humans/agents know not to hand-edit the mirror.
cat > "$DST/.generated" <<EOF
This directory is a GENERATED mirror of ../.cursor/skills/ (the canonical source).
Do not edit these files by hand. Edit .cursor/skills/ and run scripts/gen-skills-mirror.sh.
EOF

count=$(find "$DST" -name 'SKILL.md' | wc -l | tr -d ' ')
echo "skills mirror rebuilt: $count SKILL.md files under skills/"
