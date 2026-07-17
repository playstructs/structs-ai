#!/usr/bin/env bash
# Regenerate generated/structsd-commands.txt from the pinned structsd binary.
# This snapshot is the source of truth for the command-name lint.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT="$ROOT/generated/structsd-commands.txt"
mkdir -p "$ROOT/generated"

if ! command -v structsd >/dev/null 2>&1; then
  echo "error: structsd not found on PATH; cannot regenerate command snapshot" >&2
  exit 1
fi

extract() { # $1 = "tx" | "query"
  structsd "$1" structs --help 2>&1 \
    | awk '/Available Commands:/{f=1;next} /^Flags:|^Global Flags:/{f=0} f && $1 ~ /^[a-z]/ {print $1}'
}

{
  echo "# structsd command snapshot"
  echo "# source: structsd $(structsd version 2>&1) --help"
  echo "# regenerate: scripts/ci/snapshot-commands.sh"
  echo "## tx structs"
  extract tx
  echo "## query structs"
  extract query
} > "$OUT"

echo "wrote $OUT ($(grep -cvE '^#|^##' "$OUT") commands)"
