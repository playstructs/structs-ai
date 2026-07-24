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

# --- Positional-argument signatures ---------------------------------------
# check-invocations.py needs each command's arity, and CI has no structsd
# binary, so the Usage line is snapshotted here too.
SIG="$ROOT/generated/structsd-signatures.txt"
{
  echo "# structsd positional-argument signatures"
  echo "# source: structsd $(structsd version 2>&1) '<cmd> --help' Usage lines"
  echo "# regenerate: scripts/ci/snapshot-commands.sh"
  echo "# format: <tx|query><TAB><command><TAB><bracketed positional args, [flags] removed>"
  for kind in tx query; do
    while IFS= read -r cmd; do
      [ -z "$cmd" ] && continue
      usage="$(structsd "$kind" structs "$cmd" --help 2>/dev/null \
        | awk '/^Usage:/{getline; print; exit}')"
      # Keep only bracketed groups, drop the [flags] placeholder.
      # A command with no positionals leaves both greps empty, which would trip
      # `set -e` under pipefail — hence the guard.
      args="$( { printf '%s\n' "$usage" \
        | grep -oE '\[[^]]+\]' | grep -vx '\[flags\]' || true; } | tr '\n' ' ' | sed 's/ *$//')"
      printf '%s\t%s\t%s\n' "$kind" "$cmd" "$args"
    done < <(extract "$kind")
  done
} > "$SIG"

echo "wrote $SIG ($(grep -cvE '^#' "$SIG") signatures)"
