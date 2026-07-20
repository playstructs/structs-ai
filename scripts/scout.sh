#!/usr/bin/env bash
# scout.sh — raid go/no-go assessment for a planet.
#
# A raid can only COMPLETE while the owner's shields are vulnerable
# (shieldsVulnerable): their fleet is off-station, or their Command Ship is
# offline/destroyed/absent. The Command Ship defends the home planet only while
# the fleet is on station. This script gathers those facts plus defenders and
# stealable ore, then prints a verdict. It is READ-ONLY.
#
# Two raid modes shape the verdict:
#   - OPPORTUNISTIC: the target is already vulnerable  -> "GO (verify)".
#   - SIEGE:         the target is shielded but holds ore -> "SIEGE CANDIDATE":
#                    an opportunistic raid can't complete, but you can force the
#                    window open by destroying their Command Ship (a fleet
#                    engagement + your home left exposed while away). Best vs a
#                    dormant owner who won't rebuild.
# NOTE: an idle/dormant owner is NOT the same as a vulnerable one — powered
# structs stay online with no player action. This script surfaces the owner's
# last action so you don't mistake inactivity for raidability.
#
# Usage:   scripts/scout.sh <planet-id>            # e.g. scripts/scout.sh 2-117
#          scripts/scout.sh <planet-id> --raw      # also dump raw JSON sections
# Env:     STRUCTSD, STRUCTS_NODE (see lib.sh)
#
# NOTE: field names follow `structsd query structs ... -o json`. If your chain
# build names a field differently, the raw dump (--raw) shows the truth; adjust
# the jq filters below to match. Treat a "GO" as a hypothesis to confirm.

set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "$HERE/lib.sh"
preflight

PLANET_ID="${1:-}"
RAW="${2:-}"
[[ -n "$PLANET_ID" ]] || die "usage: scout.sh <planet-id> [--raw]"

planet_json="$(q planet "$PLANET_ID")"
[[ -n "$planet_json" ]] || die "no data for planet $PLANET_ID (wrong id, or node unreachable)"

owner="$(jget "$planet_json" '(.Planet // .planet // .).owner')"
pname="$(jget "$planet_json" '(.Planet // .planet // .).name' '(unnamed)')"

owner_json=""; fleet_json=""; defenders_json=""
[[ -n "$owner" ]] && owner_json="$(q player "$owner" || true)"
fleet_id="$(jget "$owner_json" '(.Player // .player // .).fleetId // (.Player // .player // .).fleet_id')"
[[ -n "$fleet_id" ]] && fleet_json="$(q fleet "$fleet_id" || true)"
# NOTE: there is no `structsd query structs` command that lists the structs on a
# planet (struct-all-by-planet is a Guild Stack / webapp query, not a CLI one —
# see scripts/BASELINE.md). Defender enumeration is therefore out of scope for
# this CLI-only script; use the Guild Stack for "defenders by planet".

# Stealable ore = owner's unrefined ore (refined Alpha cannot be raided).
# storedOre lives on the PLAYER as a grid attribute, exposed as gridAttributes.ore
# on the player query — NOT as planet.ore or player.ore.
ore="$(jget "$owner_json" '(.gridAttributes // .GridAttributes // {}).ore' "0")"

# Command Ship: it lives in the fleet's dedicated `commandStruct` field (a struct
# id), NOT in the space/air/land/water ambit slot arrays. Read that id, then query
# the struct for its live status. status is a bitmask (online=4, destroyed=32);
# this mirrors HasCommandStruct + IsOnline/IsDestroyed as used by the chain's
# IsDefenderCommandStructVulnerable().
cs_id="$(jget "$fleet_json" '(.Fleet // .fleet // .).commandStruct')"
cs_present="no"; [[ -n "$cs_id" ]] && cs_present="yes"

cs_status_num=""; cs_health=""; cs_online="unknown"; cs_destroyed="unknown"
if [[ "$cs_present" == "yes" ]]; then
  cs_json="$(q struct "$cs_id" || true)"
  cs_status_num="$(jget "$cs_json" '(.structAttributes // .StructAttributes // {}).status')"
  cs_health="$(jget "$cs_json" '(.structAttributes // .StructAttributes // {}).health')"
  if [[ "$cs_status_num" =~ ^[0-9]+$ ]]; then
    (( cs_status_num & 32 )) && cs_destroyed="yes" || cs_destroyed="no"
    (( cs_status_num & 4  )) && cs_online="yes"    || cs_online="no"
  fi
fi

cs_desc="absent"
if [[ "$cs_present" == "yes" ]]; then
  if   [[ "$cs_destroyed" == "yes" ]]; then cs_desc="$cs_id destroyed"
  elif [[ "$cs_online" == "yes" ]];    then cs_desc="$cs_id online (hp ${cs_health:-?})"
  elif [[ "$cs_online" == "no" ]];     then cs_desc="$cs_id offline (hp ${cs_health:-?})"
  else                                      cs_desc="$cs_id status=${cs_status_num:-?}"; fi
fi

# Fleet on-station vs away. The Command Ship only defends home while the fleet
# is on station, so an away/off-station fleet leaves the planet vulnerable.
fleet_station="$(printf '%s' "$fleet_json" | jq -r '
  (.Fleet // .fleet // .) | (.status // .state // (if .onStation==true then "onStation" elif .onStation==false then "away" else empty end))' 2>/dev/null || true)"
fleet_away="unknown"
case "$(printf '%s' "$fleet_station" | tr '[:upper:]' '[:lower:]')" in
  *away*|*offstation*|*off_station*) fleet_away="yes" ;;
  *onstation*|*on_station*|*station*) fleet_away="no" ;;
esac
# FleetStatus is onStation(0)/away(1); the 0 value is omitted from JSON. An away
# fleet always renders "away", so an existing fleet with no away signal is on
# station. Infer that so the readout and vulnerability check are explicit.
if [[ "$fleet_away" == "unknown" && -n "$fleet_id" && -n "$fleet_json" ]]; then
  fleet_away="no"; fleet_station="onStation (inferred)"
fi

# Vulnerability mirrors IsDefenderCommandStructVulnerable(): vulnerable if the
# fleet is off-station, there is no Command Ship, or the Command Ship is
# destroyed or offline. Only "not vulnerable" when the fleet is on station AND a
# built Command Ship is online.
vulnerable="unknown"
if   [[ "$fleet_away" == "yes" ]];    then vulnerable="yes"
elif [[ "$cs_present" == "no" ]];     then vulnerable="yes"
elif [[ "$cs_destroyed" == "yes" ]];  then vulnerable="yes"
elif [[ "$cs_online" == "yes" ]];     then vulnerable="no"
elif [[ "$cs_online" == "no" ]];      then vulnerable="yes"
fi

# Owner activity: lastAction is a block height. Compare to current height (best
# effort) so a dormant owner is visible and not mistaken for a vulnerable one.
last_action="$(jget "$owner_json" '(.Player // .player // .).lastAction // .lastAction')"
current_height="$(${STRUCTSD} status 2>/dev/null | jq -r '.sync_info.latest_block_height // .SyncInfo.latest_block_height // empty' 2>/dev/null || true)"
idle_desc=""
if [[ -n "$last_action" && "$last_action" =~ ^[0-9]+$ ]]; then
  if [[ -n "$current_height" && "$current_height" =~ ^[0-9]+$ && "$current_height" -ge "$last_action" ]]; then
    idle_desc="lastAction=$last_action (~$((current_height - last_action)) blocks ago)"
  else
    idle_desc="lastAction=$last_action"
  fi
fi

echo "${C_CYN}== Raid scout: planet $PLANET_ID ($pname) ==${C_RST}"
printf '  %-22s %s\n' "owner"            "${owner:-?}"
[[ -n "$idle_desc" ]] && printf '  %-22s %s\n' "owner activity" "$idle_desc"
printf '  %-22s %s\n' "stealable ore"    "${ore:-0}"
printf '  %-22s %s\n' "command ship"     "present=$cs_present ($cs_desc)"
printf '  %-22s %s\n' "fleet"            "${fleet_station:-?} (away=$fleet_away)"
printf '  %-22s %s\n' "shields vulnerable" "$vulnerable"
printf '  %-22s %s\n' "defenders on planet" "(CLI cannot list; use Guild Stack)"
echo

verdict="${C_YEL}REVIEW${C_RST}"; reason="confirm command-ship and fleet status manually"
if [[ "$vulnerable" == "no" && "${ore:-0}" != "0" ]]; then
  verdict="${C_YEL}SIEGE CANDIDATE${C_RST}"
  reason="shields up (CMD ship online, fleet on station) — an opportunistic raid can't complete; the only path is to destroy the CMD ship first (a fleet engagement + your home exposed while away). Weigh ${ore} ore vs that cost; best vs a dormant owner who won't rebuild."
elif [[ "$vulnerable" == "no" ]]; then
  verdict="${C_RED}NO-GO${C_RST}"; reason="shields up and no unrefined ore to steal — nothing to gain even via siege"
elif [[ "$vulnerable" == "yes" && "${ore:-0}" != "0" ]]; then
  verdict="${C_GRN}GO (verify)${C_RST}"; reason="shields vulnerable and ${ore} ore present — confirm you out-damage the planet's defenders (enumerate via Guild Stack)"
elif [[ "$vulnerable" == "yes" ]]; then
  verdict="${C_YEL}LOW VALUE${C_RST}"; reason="vulnerable but no unrefined ore to steal"
fi
echo "  verdict: $verdict — $reason"
echo "${C_DIM}  Idle != vulnerable: a dormant owner with an online CMD ship is shielded, not raidable — don't fleet-move on inactivity alone.${C_RST}"
echo "${C_DIM}  Re-scout immediately before fleet-move; power/fleet state changes block-to-block.${C_RST}"

if [[ "$RAW" == "--raw" ]]; then
  echo; echo "${C_DIM}--- planet ---${C_RST}";    printf '%s\n' "$planet_json"    | jq . 2>/dev/null || true
  echo "${C_DIM}--- owner ---${C_RST}";           printf '%s\n' "$owner_json"     | jq . 2>/dev/null || true
  echo "${C_DIM}--- fleet ---${C_RST}";           printf '%s\n' "$fleet_json"     | jq . 2>/dev/null || true
  echo "${C_DIM}--- command ship ---${C_RST}";    printf '%s\n' "${cs_json:-}"    | jq . 2>/dev/null || true
fi
