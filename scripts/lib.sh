#!/usr/bin/env bash
# Shared helpers for the Structs agent script toolkit.
#
# Source this from other scripts: `source "$(dirname "$0")/lib.sh"`
# All scripts here are READ-ONLY (queries only). None of them sign or submit
# transactions — that stays in the agent's hands per SAFETY.md.

set -euo pipefail

# Binary + chain config. Override via environment.
STRUCTSD="${STRUCTSD:-structsd}"
# Optional: pass a --node endpoint to every query (e.g. export STRUCTS_NODE=https://public.testnet.structs.network:26657)
STRUCTS_NODE="${STRUCTS_NODE:-}"

# Colors (disabled when not a TTY)
if [[ -t 1 ]]; then
  C_RED=$'\033[31m'; C_GRN=$'\033[32m'; C_YEL=$'\033[33m'; C_CYN=$'\033[36m'; C_DIM=$'\033[2m'; C_RST=$'\033[0m'
else
  C_RED=""; C_GRN=""; C_YEL=""; C_CYN=""; C_DIM=""; C_RST=""
fi

die() { echo "${C_RED}error:${C_RST} $*" >&2; exit 1; }
note() { echo "${C_DIM}$*${C_RST}" >&2; }

require() {
  command -v "$1" >/dev/null 2>&1 || die "'$1' not found on PATH. $2"
}

# q <query-args...> : run a structs query and emit JSON on stdout.
# Example: q player 1-42   ->   structsd query structs player 1-42 -o json
q() {
  local args=("$@")
  if [[ -n "$STRUCTS_NODE" ]]; then
    "$STRUCTSD" query structs "${args[@]}" --node "$STRUCTS_NODE" -o json 2>/dev/null
  else
    "$STRUCTSD" query structs "${args[@]}" -o json 2>/dev/null
  fi
}

# jget <json> <jq-filter> [default] : safe jq extraction, prints default if null/empty/error.
jget() {
  local json="$1" filter="$2" def="${3:-}"
  local out
  out="$(printf '%s' "$json" | jq -r "$filter // empty" 2>/dev/null || true)"
  if [[ -z "$out" || "$out" == "null" ]]; then printf '%s' "$def"; else printf '%s' "$out"; fi
}

# Common preflight for scripts that need both binaries.
preflight() {
  require "$STRUCTSD" "Install it with the structsd-install skill."
  require jq "Install jq (e.g. 'brew install jq' or 'apt install jq')."
}
