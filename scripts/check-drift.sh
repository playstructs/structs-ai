#!/usr/bin/env bash
# check-drift.sh — detect documentation drift against the live chain.
#
# The docs hard-code game constants (build difficulties, charge costs, HP, build
# limits). When the chain ships a balance patch, those constants silently go
# stale. This script queries the live struct-type definitions and compares a
# curated set of values against what the docs claim for the CURRENT release.
#
# It is READ-ONLY. A "DRIFT" line means: either the chain changed (update the
# docs) or the expected value below is wrong (fix this table). Keep the CHECKS
# table in sync with the catalog in knowledge/entities/struct-types.md.
#
# Usage:   scripts/check-drift.sh
# Env:     STRUCTSD, STRUCTS_NODE (see lib.sh)

set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "$HERE/lib.sh"
preflight

# Expected values for the current documented release (structsd v0.18.0).
# Format: "<struct-type-id>|<jq-field-alternation>|<expected>|<label>"
# The jq alternation tolerates snake_case vs camelCase field naming.
CHECKS=(
  "1|.buildDifficulty,.build_difficulty|200|Command Ship build difficulty"
  "14|.buildDifficulty,.build_difficulty|700|Ore Extractor build difficulty"
  "15|.buildDifficulty,.build_difficulty|700|Ore Refinery build difficulty"
  "18|.buildDifficulty,.build_difficulty|3600|Ore Bunker build difficulty"
  "1|.activateCharge,.activate_charge|2|Command Ship activateCharge"
  "14|.activateCharge,.activate_charge|2|Ore Extractor activateCharge"
  "18|.buildLimit,.build_limit|0|Ore Bunker build limit (0 = unlimited)"
)

extract() {
  # extract <json> <comma-separated-jq-paths>
  local json="$1" paths="$2" p out
  IFS=',' read -ra parts <<< "$paths"
  for p in "${parts[@]}"; do
    out="$(printf '%s' "$json" | jq -r "(.StructType // .structType // .struct_type // .) | $p // empty" 2>/dev/null || true)"
    [[ -n "$out" && "$out" != "null" ]] && { printf '%s' "$out"; return; }
  done
  printf ''
}

pass=0; drift=0; skip=0
echo "${C_CYN}== Doc drift check (expected = structsd v0.18.0 docs) ==${C_RST}"

declare -A CACHE
for row in "${CHECKS[@]}"; do
  IFS='|' read -r tid paths expected label <<< "$row"
  json="${CACHE[$tid]:-}"
  if [[ -z "$json" ]]; then
    json="$(q struct-type "$tid" || true)"
    CACHE[$tid]="$json"
  fi
  if [[ -z "$json" ]]; then
    printf '  %-44s %s\n' "$label" "${C_YEL}SKIP (no chain data)${C_RST}"
    skip=$((skip+1)); continue
  fi
  actual="$(extract "$json" "$paths")"
  if [[ -z "$actual" ]]; then
    printf '  %-44s %s\n' "$label" "${C_YEL}SKIP (field not found)${C_RST}"
    skip=$((skip+1))
  elif [[ "$actual" == "$expected" ]]; then
    printf '  %-44s %s\n' "$label" "${C_GRN}OK${C_RST} ($actual)"
    pass=$((pass+1))
  else
    printf '  %-44s %s\n' "$label" "${C_RED}DRIFT${C_RST} expected=$expected actual=$actual"
    drift=$((drift+1))
  fi
done

echo
echo "  ${C_GRN}$pass ok${C_RST}, ${C_RED}$drift drift${C_RST}, ${C_YEL}$skip skipped${C_RST}"
if (( drift > 0 )); then
  echo "${C_DIM}  Reconcile each DRIFT: update the docs (and CHANGELOG) or correct the CHECKS table.${C_RST}"
  exit 1
fi
