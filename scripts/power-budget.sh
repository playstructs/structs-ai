#!/usr/bin/env bash
# power-budget.sh — power capacity vs load, with activation headroom.
#
# Energy is per-block: capacity = production/block, load = consumption/block.
# If load > capacity you go offline. This shows your margin and whether you can
# afford to activate another struct of a given load. READ-ONLY.
#
# Usage:   scripts/power-budget.sh <player-id> [prospective-load | --type <struct-type-id>]
#          scripts/power-budget.sh 1-42 5            -> can I afford a +5 load struct?
#          scripts/power-budget.sh 1-42 --type 14    -> can I bring an Ore Extractor online?
# Env:     STRUCTSD, STRUCTS_NODE (see lib.sh)

set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "$HERE/lib.sh"
preflight

PLAYER_ID="${1:-${STRUCTS_PLAYER:-}}"
[[ -n "$PLAYER_ID" ]] || die "usage: power-budget.sh <player-id> [prospective-load | --type <struct-type-id>]"

NEW_LOAD="0"; LOAD_LABEL=""
if [[ "${2:-}" == "--type" ]]; then
  TYPE_ID="${3:-}"
  [[ -n "$TYPE_ID" ]] || die "--type requires a struct-type-id (e.g. --type 14)"
  st_json="$(q struct-type "$TYPE_ID" || true)"
  [[ -n "$st_json" ]] || die "no data for struct-type $TYPE_ID"
  ST='(.StructType // .structType // .struct_type // .)'
  NEW_LOAD="$(jget "$st_json" "$ST.passiveDraw // $ST.passive_draw" "")"
  [[ "$NEW_LOAD" =~ ^[0-9]+$ ]] || die "could not read passiveDraw for struct-type $TYPE_ID (try: $STRUCTSD query structs struct-type $TYPE_ID -o json)"
  LOAD_LABEL=" (struct-type $TYPE_ID passiveDraw)"
else
  NEW_LOAD="${2:-0}"
fi

player_json="$(q player "$PLAYER_ID")"
[[ -n "$player_json" ]] || die "no data for player $PLAYER_ID"
P='(.Player // .player // .)'

capacity="$(jget "$player_json" "$P.capacity" 0)"
load="$(jget "$player_json" "$P.load // $P.structsLoad" 0)"
conn_cap="$(jget "$player_json" "$P.connectionCapacity // $P.connection_capacity" "?")"

[[ "$capacity" =~ ^[0-9]+$ && "$load" =~ ^[0-9]+$ ]] || die "could not read numeric capacity/load (try: $STRUCTSD query structs player $PLAYER_ID -o json)"
headroom=$((capacity - load))

echo "${C_CYN}== Power budget: player $PLAYER_ID ==${C_RST}"
printf '  %-22s %s\n' "capacity (prod/block)" "$capacity"
printf '  %-22s %s\n' "load (cons/block)"      "$load"
printf '  %-22s %s\n' "connection capacity"    "$conn_cap"
if (( headroom < 0 )); then
  printf '  %-22s %s\n' "headroom" "${C_RED}$headroom  OVERLOADED${C_RST}"
  echo "  ${C_RED}You are over capacity — bring load down or capacity up (structs-energy skill).${C_RST}"
else
  printf '  %-22s %s\n' "headroom" "${C_GRN}$headroom${C_RST}"
fi

if [[ "$NEW_LOAD" =~ ^[0-9]+$ ]] && (( NEW_LOAD > 0 )); then
  after=$((headroom - NEW_LOAD))
  echo
  if (( after >= 0 )); then
    echo "  ${C_GRN}OK${C_RST}: a +$NEW_LOAD load$LOAD_LABEL leaves headroom $after."
  else
    echo "  ${C_RED}NO${C_RST}: a +$NEW_LOAD load$LOAD_LABEL would put you ${after#-} over capacity. Add power first."
  fi
fi
echo "${C_DIM}  Idle capacity is wasted (energy is ephemeral); negative headroom means offline.${C_RST}"
