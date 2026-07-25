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
G='(.gridAttributes // .GridAttributes // {})'

capacity="$(jget "$player_json" "$G.capacity" 0)"
capacity_sec="$(jget "$player_json" "$G.capacitySecondary // $G.capacity_secondary" 0)"
load="$(jget "$player_json" "$G.load" 0)"
structs_load="$(jget "$player_json" "$G.structsLoad // $G.structs_load" 0)"
ore="$(jget "$player_json" "$G.ore" 0)"
last_action="$(jget "$player_json" "$G.lastAction // $G.last_action" "")"
planet_id="$(jget "$player_json" "$P.planetId // $P.planet_id")"
fleet_id="$(jget "$player_json" "$P.fleetId // $P.fleet_id")"
guild_id="$(jget "$player_json" "$P.guildId // $P.guild_id" "(none)")"

# Charge = height − lastAction; omitted lastAction ⇒ 0 ⇒ full charge.
current_height="$(${STRUCTSD} status 2>/dev/null | jq -r '.sync_info.latest_block_height // .SyncInfo.latest_block_height // empty' 2>/dev/null || true)"
if [[ -z "$last_action" || "$last_action" == "0" ]]; then
  charge="full (lastAction omitted/0)"
elif [[ "$current_height" =~ ^[0-9]+$ && "$last_action" =~ ^[0-9]+$ ]]; then
  charge=$((current_height - last_action))
else
  charge="? (lastAction=$last_action height=${current_height:-?})"
fi

cap_total=0; load_total=0; headroom="?"
if [[ "$capacity" =~ ^[0-9]+$ && "$capacity_sec" =~ ^[0-9]+$ && "$load" =~ ^[0-9]+$ && "$structs_load" =~ ^[0-9]+$ ]]; then
  cap_total=$((capacity + capacity_sec))
  load_total=$((load + structs_load))
  headroom=$((cap_total - load_total))
fi

planet_ore="?"; fleet_status="?"
if [[ -n "$planet_id" ]]; then
  planet_json="$(q planet "$planet_id" || true)"
  planet_ore="$(jget "$planet_json" '(.Planet // .planet // .).remainingOre // (.Planet // .planet // .).remaining_ore' "?")"
fi
if [[ -n "$fleet_id" ]]; then
  fleet_json="$(q fleet "$fleet_id" || true)"
  fleet_status="$(jget "$fleet_json" '(.Fleet // .fleet // .).status // (.Fleet // .fleet // .).locationStatus' "?")"
  # status 0 (onStation) is omitempty — empty with a known fleet ⇒ onStation
  if [[ -z "$fleet_status" || "$fleet_status" == "?" ]]; then
    fleet_status="onStation (inferred)"
  fi
fi

echo "${C_CYN}== State assessment: player $PLAYER_ID (guild $guild_id) ==${C_RST}"
printf '  %-20s %s\n' "capacity (+secondary)" "$capacity + $capacity_sec = $cap_total"
printf '  %-20s %s\n' "load (+structsLoad)" "$load + $structs_load = $load_total"
if [[ "$headroom" =~ ^-?[0-9]+$ ]] && (( headroom < 0 )); then
  printf '  %-20s %s\n' "headroom" "${C_RED}$headroom  (OVERLOADED — offline)${C_RST}"
elif [[ "$headroom" =~ ^[0-9]+$ ]] && (( headroom == 0 )); then
  printf '  %-20s %s\n' "headroom" "${C_YEL}0  (no room to activate anything)${C_RST}"
else
  printf '  %-20s %s\n' "headroom" "${C_GRN}$headroom${C_RST}"
fi
printf '  %-20s %s\n' "charge" "$charge ${C_DIM}(per-player; height − lastAction)${C_RST}"
if [[ "$ore" =~ ^[0-9]+$ ]] && (( ore > 0 )); then
  printf '  %-20s %s\n' "unrefined ore" "${C_YEL}$ore  (REFINE NOW — stealable)${C_RST}"
else
  printf '  %-20s %s\n' "unrefined ore" "$ore"
fi
printf '  %-20s %s\n' "planet ore left" "$planet_ore ${C_DIM}(remainingOre)${C_RST}"
printf '  %-20s %s\n' "fleet"           "$fleet_id  status=$fleet_status"
echo
echo "${C_DIM}  Priority order: Survival > Security > Economy > Expansion > Dominance (awareness/priority-framework.md).${C_RST}"
