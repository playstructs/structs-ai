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
defenders_json="$(q struct-all-by-planet "$PLANET_ID" || true)"

# Stealable ore = owner's unrefined ore balance (refined Alpha cannot be raided).
ore="$(jget "$owner_json" '(.Player // .player // .).ore // .ore' "0")"

# Command Ship (struct type 1) status in the owner's fleet.
cs_status="$(printf '%s' "$fleet_json" | jq -r '
  [ (.. | objects | select((.type? // .structType? // .typeId?) as $t | ($t==1 or $t=="1")) ) ]
  | (.[0].status // .[0].state // empty)' 2>/dev/null || true)"
cs_present="no"; [[ -n "$cs_status" ]] && cs_present="yes"

# Fleet on-station vs away. The Command Ship only defends home while the fleet
# is on station, so an away/off-station fleet leaves the planet vulnerable.
fleet_station="$(printf '%s' "$fleet_json" | jq -r '
  (.Fleet // .fleet // .) | (.status // .state // (if .onStation==true then "onStation" elif .onStation==false then "away" else empty end))' 2>/dev/null || true)"
fleet_away="unknown"
case "$(printf '%s' "$fleet_station" | tr '[:upper:]' '[:lower:]')" in
  *away*|*offstation*|*off_station*) fleet_away="yes" ;;
  *onstation*|*on_station*|*station*) fleet_away="no" ;;
esac

# Vulnerability: vulnerable if the fleet is away, or no command ship, or the
# command ship reads offline/destroyed/inactive. Only "not vulnerable" when the
# fleet is on station AND the command ship is online.
vulnerable="unknown"
if [[ "$fleet_away" == "yes" ]]; then
  vulnerable="yes"
else
  case "$(printf '%s' "$cs_status" | tr '[:upper:]' '[:lower:]')" in
    *offline*|*destroyed*|*inactive*|*off*|"") [[ "$cs_present" == "no" ]] && vulnerable="yes" || { [[ -n "$cs_status" ]] && vulnerable="yes"; } ;;
    *online*|*active*|*on*) [[ "$fleet_away" == "no" ]] && vulnerable="no" ;;
  esac
fi

defender_count="$(printf '%s' "$defenders_json" | jq -r '[ (.. | objects | select(.id? != null)) ] | length' 2>/dev/null || echo "?")"

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
printf '  %-22s %s\n' "command ship"     "present=$cs_present status=${cs_status:-?}"
printf '  %-22s %s\n' "fleet"            "${fleet_station:-?} (away=$fleet_away)"
printf '  %-22s %s\n' "shields vulnerable" "$vulnerable"
printf '  %-22s %s\n' "defenders on planet" "${defender_count:-?}"
echo

verdict="${C_YEL}REVIEW${C_RST}"; reason="confirm command-ship and fleet status manually"
if [[ "$vulnerable" == "no" && "${ore:-0}" != "0" ]]; then
  verdict="${C_YEL}SIEGE CANDIDATE${C_RST}"
  reason="shields up (CMD ship online, fleet on station) — an opportunistic raid can't complete; the only path is to destroy the CMD ship first (a fleet engagement + your home exposed while away). Weigh ${ore} ore vs that cost; best vs a dormant owner who won't rebuild."
elif [[ "$vulnerable" == "no" ]]; then
  verdict="${C_RED}NO-GO${C_RST}"; reason="shields up and no unrefined ore to steal — nothing to gain even via siege"
elif [[ "$vulnerable" == "yes" && "${ore:-0}" != "0" ]]; then
  verdict="${C_GRN}GO (verify)${C_RST}"; reason="shields vulnerable and ore present — confirm you out-damage $defender_count defender(s)"
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
  echo "${C_DIM}--- defenders ---${C_RST}";       printf '%s\n' "$defenders_json" | jq . 2>/dev/null || true
fi
