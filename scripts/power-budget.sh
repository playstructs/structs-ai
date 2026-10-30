#!/usr/bin/env bash
# power-budget.sh — exact stored-state diagnostics; queries only, no signing.
# Usage: scripts/power-budget.sh <player-id> [prospective-load-mW | --type <struct-type-id>]
# Env: STRUCTSD, STRUCTS_NODE, STRUCTS_CHAIN_ID, STRUCTS_PLAYER.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
command -v python3 >/dev/null 2>&1 || { echo "error: Python 3 is required" >&2; exit 1; }
exec python3 "$HERE/assessment.py" power "$@"
