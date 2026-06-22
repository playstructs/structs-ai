#!/usr/bin/env bash
# scout.sh — raid go/no-go assessment for a planet.
#
# A raid can only COMPLETE while the owner's shields are vulnerable
# (shieldsVulnerable): their fleet is off-station, or their Command Ship is
# offline/destroyed/absent. The Command Ship defends the home planet only while
# the fleet is on station. This script gathers those facts plus defenders and
# stealable ore, then prints a verdict. It is READ-ONLY.
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

echo "${C_CYN}== Raid scout: planet $PLANET_ID ($pname) ==${C_RST}"
printf '  %-22s %s\n' "owner"            "${owner:-?}"
printf '  %-22s %s\n' "stealable ore"    "${ore:-0}"
printf '  %-22s %s\n' "command ship"     "present=$cs_present status=${cs_status:-?}"
printf '  %-22s %s\n' "fleet"            "${fleet_station:-?} (away=$fleet_away)"
printf '  %-22s %s\n' "shields vulnerable" "$vulnerable"
printf '  %-22s %s\n' "defenders on planet" "${defender_count:-?}"
echo

verdict="${C_YEL}REVIEW${C_RST}"; reason="confirm command-ship and fleet status manually"
if [[ "$vulnerable" == "no" ]]; then
  verdict="${C_RED}NO-GO${C_RST}"; reason="fleet on station with Command Ship online — shields up, raid cannot complete"
elif [[ "$vulnerable" == "yes" && "${ore:-0}" != "0" ]]; then
  verdict="${C_GRN}GO (verify)${C_RST}"; reason="shields vulnerable and ore present — confirm you out-damage $defender_count defender(s)"
elif [[ "$vulnerable" == "yes" ]]; then
  verdict="${C_YEL}LOW VALUE${C_RST}"; reason="vulnerable but no unrefined ore to steal"
fi
echo "  verdict: $verdict — $reason"
echo "${C_DIM}  Re-scout immediately before fleet-move; power/fleet state changes block-to-block.${C_RST}"

if [[ "$RAW" == "--raw" ]]; then
  echo; echo "${C_DIM}--- planet ---${C_RST}";    printf '%s\n' "$planet_json"    | jq . 2>/dev/null || true
  echo "${C_DIM}--- owner ---${C_RST}";           printf '%s\n' "$owner_json"     | jq . 2>/dev/null || true
  echo "${C_DIM}--- fleet ---${C_RST}";           printf '%s\n' "$fleet_json"     | jq . 2>/dev/null || true
  echo "${C_DIM}--- defenders ---${C_RST}";       printf '%s\n' "$defenders_json" | jq . 2>/dev/null || true
fi
