#!/usr/bin/env bash
# power-budget.sh — power capacity vs load, with activation headroom.
#
# Energy is per-block: capacity = production/block, load = consumption/block.
# Online when (capacity + capacitySecondary) >= (load + structsLoad).
# Shows your margin and whether you can afford another struct's passiveDraw.
# Units are chain milliwatts (÷1000 for watts). READ-ONLY.
#
# Usage:   scripts/power-budget.sh <player-id> [prospective-load | --type <struct-type-id>]
#          scripts/power-budget.sh 1-42 500000       -> milliwatts headroom check
#          scripts/power-budget.sh 1-42 --type 14    -> Ore Extractor passiveDraw
# Env:     STRUCTSD, STRUCTS_NODE (see lib.sh)

set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "$HERE/lib.sh"
preflight

PLAYER_ID="${1:-${STRUCTS_PLAYER:-}}"
[[ -n "$PLAYER_ID" ]] || die "usage: power-budget.sh <player-id> [prospective-load-mW | --type <struct-type-id>]"

NEW_LOAD="0"; LOAD_LABEL=""
if [[ "${2:-}" == "--type" ]]; then
  TYPE_ID="${3:-}"
  [[ -n "$TYPE_ID" ]] || die "--type requires a struct-type-id (e.g. --type 14)"
  st_json="$(q struct-type "$TYPE_ID" || true)"
  [[ -n "$st_json" ]] || die "no data for struct-type $TYPE_ID"
  ST='(.StructType // .structType // .struct_type // .)'
  NEW_LOAD="$(jget "$st_json" "$ST.passiveDraw // $ST.passive_draw" "")"
  [[ "$NEW_LOAD" =~ ^[0-9]+$ ]] || die "could not read passiveDraw for struct-type $TYPE_ID (try: $STRUCTSD query structs struct-type $TYPE_ID -o json)"
  LOAD_LABEL=" (struct-type $TYPE_ID passiveDraw=${NEW_LOAD} mW)"
else
  NEW_LOAD="${2:-0}"
fi

player_json="$(q player "$PLAYER_ID")"
[[ -n "$player_json" ]] || die "no data for player $PLAYER_ID"
G='(.gridAttributes // .GridAttributes // {})'

capacity="$(jget "$player_json" "$G.capacity" 0)"
capacity_sec="$(jget "$player_json" "$G.capacitySecondary // $G.capacity_secondary" 0)"
load="$(jget "$player_json" "$G.load" 0)"
structs_load="$(jget "$player_json" "$G.structsLoad // $G.structs_load" 0)"

[[ "$capacity" =~ ^[0-9]+$ && "$capacity_sec" =~ ^[0-9]+$ && "$load" =~ ^[0-9]+$ && "$structs_load" =~ ^[0-9]+$ ]] \
  || die "could not read numeric gridAttributes (try: $STRUCTSD query structs player $PLAYER_ID -o json)"

cap_total=$((capacity + capacity_sec))
load_total=$((load + structs_load))
headroom=$((cap_total - load_total))

echo "${C_CYN}== Power budget: player $PLAYER_ID ==${C_RST}"
printf '  %-28s %s\n' "capacity" "$capacity"
printf '  %-28s %s\n' "capacitySecondary" "$capacity_sec"
printf '  %-28s %s\n' "load" "$load"
printf '  %-28s %s\n' "structsLoad" "$structs_load"
printf '  %-28s %s\n' "total capacity" "$cap_total"
printf '  %-28s %s\n' "total load" "$load_total"
if (( headroom < 0 )); then
  printf '  %-28s %s\n' "headroom" "${C_RED}$headroom  OVERLOADED (offline)${C_RST}"
  echo "  ${C_RED}Shed load or add capacity (structs-energy skill).${C_RST}"
else
  printf '  %-28s %s\n' "headroom" "${C_GRN}$headroom mW${C_RST}"
fi

if [[ "$NEW_LOAD" =~ ^[0-9]+$ ]] && (( NEW_LOAD > 0 )); then
  after=$((headroom - NEW_LOAD))
  echo
  if (( after >= 0 )); then
    echo "  ${C_GRN}OK${C_RST}: +$NEW_LOAD mW$LOAD_LABEL leaves headroom $after mW."
  else
    echo "  ${C_RED}NO${C_RST}: +$NEW_LOAD mW$LOAD_LABEL would put you ${after#-} mW over capacity. Add power first."
  fi
fi
echo "${C_DIM}  Formula: (capacity+capacitySecondary) − (load+structsLoad). Values are milliwatts.${C_RST}"
