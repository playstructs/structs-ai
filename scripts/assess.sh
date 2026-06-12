#!/usr/bin/env bash
# assess.sh — one-shot state assessment for your player.
#
# Snapshots the things that decide your next move: power headroom, unrefined ore
# (a liability), charge, planet ore remaining, and fleet station status. READ-ONLY.
#
# Usage:   scripts/assess.sh <player-id>          # e.g. scripts/assess.sh 1-42
#          STRUCTS_PLAYER=1-42 scripts/assess.sh
# Env:     STRUCTSD, STRUCTS_NODE (see lib.sh)

set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "$HERE/lib.sh"
preflight

PLAYER_ID="${1:-${STRUCTS_PLAYER:-}}"
[[ -n "$PLAYER_ID" ]] || die "usage: assess.sh <player-id>  (or set STRUCTS_PLAYER)"

player_json="$(q player "$PLAYER_ID")"
[[ -n "$player_json" ]] || die "no data for player $PLAYER_ID"
P='(.Player // .player // .)'

capacity="$(jget "$player_json" "$P.capacity" 0)"
load="$(jget "$player_json" "$P.load // $P.structsLoad" 0)"
ore="$(jget "$player_json" "$P.ore" 0)"
charge="$(jget "$player_json" "$P.charge" "?")"
planet_id="$(jget "$player_json" "$P.planetId // $P.planet_id")"
fleet_id="$(jget "$player_json" "$P.fleetId // $P.fleet_id")"
guild_id="$(jget "$player_json" "$P.guildId // $P.guild_id" "(none)")"

headroom="?"
if [[ "$capacity" =~ ^[0-9]+$ && "$load" =~ ^[0-9]+$ ]]; then headroom=$((capacity - load)); fi

planet_ore="?"; fleet_status="?"
if [[ -n "$planet_id" ]]; then
  planet_json="$(q planet "$planet_id" || true)"
  planet_ore="$(jget "$planet_json" '(.Planet // .planet // .).ore' "?")"
fi
if [[ -n "$fleet_id" ]]; then
  fleet_json="$(q fleet "$fleet_id" || true)"
  fleet_status="$(jget "$fleet_json" '(.Fleet // .fleet // .).status // (.Fleet // .fleet // .).locationStatus' "?")"
fi

echo "${C_CYN}== State assessment: player $PLAYER_ID (guild $guild_id) ==${C_RST}"
printf '  %-20s %s\n' "power capacity" "$capacity"
printf '  %-20s %s\n' "power load"     "$load"
if [[ "$headroom" =~ ^-?[0-9]+$ ]] && (( headroom < 0 )); then
  printf '  %-20s %s\n' "headroom" "${C_RED}$headroom  (OVERLOADED — you will go offline)${C_RST}"
elif [[ "$headroom" =~ ^[0-9]+$ ]] && (( headroom == 0 )); then
  printf '  %-20s %s\n' "headroom" "${C_YEL}0  (no room to activate anything)${C_RST}"
else
  printf '  %-20s %s\n' "headroom" "${C_GRN}$headroom${C_RST}"
fi
printf '  %-20s %s\n' "charge" "$charge ${C_DIM}(per-player bar; blocks since last action)${C_RST}"
if [[ "$ore" =~ ^[0-9]+$ ]] && (( ore > 0 )); then
  printf '  %-20s %s\n' "unrefined ore" "${C_YEL}$ore  (REFINE NOW — stealable)${C_RST}"
else
  printf '  %-20s %s\n' "unrefined ore" "$ore"
fi
printf '  %-20s %s\n' "planet ore left" "$planet_ore"
printf '  %-20s %s\n' "fleet"           "$fleet_id  status=$fleet_status"
echo
echo "${C_DIM}  Priority order: Survival > Security > Economy > Expansion > Dominance (awareness/priority-framework.md).${C_RST}"
