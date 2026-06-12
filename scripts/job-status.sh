#!/usr/bin/env bash
# job-status.sh — summarize background proof-of-work jobs tracked in memory/jobs/.
#
# For each <job>.pid in the jobs directory, reports whether the process is still
# alive, the last line of its log, and any structured fields from <job>.json.
# This is the first thing to run on resume (see awareness/async-operations.md).
#
# Usage:   scripts/job-status.sh
# Env:     STRUCTS_JOBS_DIR (default: memory/jobs)

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "$HERE/lib.sh"

JOBS_DIR="${STRUCTS_JOBS_DIR:-memory/jobs}"

[[ -d "$JOBS_DIR" ]] || die "jobs dir '$JOBS_DIR' not found (run from repo root or set STRUCTS_JOBS_DIR)"

shopt -s nullglob
pids=("$JOBS_DIR"/*.pid)
if [[ ${#pids[@]} -eq 0 ]]; then
  echo "${C_DIM}No tracked jobs in $JOBS_DIR.${C_RST}"
  exit 0
fi

printf '%-22s %-10s %-8s %s\n' "JOB" "STATE" "PID" "LAST LOG"
printf '%-22s %-10s %-8s %s\n' "----------------------" "----------" "--------" "--------"

for pidfile in "${pids[@]}"; do
  job="$(basename "$pidfile" .pid)"
  pid="$(cat "$pidfile" 2>/dev/null || echo "")"
  log="$JOBS_DIR/$job.log"
  json="$JOBS_DIR/$job.json"

  state="${C_YEL}unknown${C_RST}"
  if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
    state="${C_GRN}running${C_RST}"
  elif [[ -n "$pid" ]]; then
    # Process gone — distinguish completed vs died using the log tail.
    if [[ -f "$log" ]] && grep -qiE "txhash|code: 0|complete" "$log" 2>/dev/null; then
      state="${C_CYN}finished${C_RST}"
    else
      state="${C_RED}dead${C_RST}"
    fi
  fi

  last=""
  [[ -f "$log" ]] && last="$(tail -n 1 "$log" 2>/dev/null | cut -c1-60)"

  printf '%-22s %-19b %-8s %s\n' "$job" "$state" "${pid:-?}" "${last:-}"

  if [[ -f "$json" ]] && command -v jq >/dev/null 2>&1; then
    summary="$(jq -r '[.type, .structId, .status, ("expectComplete=" + (.expectedCompleteBlock|tostring))] | map(select(. != null and . != "null")) | join("  ")' "$json" 2>/dev/null || true)"
    [[ -n "$summary" ]] && echo "    ${C_DIM}$summary${C_RST}"
  fi
done

echo
echo "${C_DIM}A 'dead' job exited without a success marker — inspect its .log and verify on-chain state before relaunching (awareness/async-operations.md).${C_RST}"
