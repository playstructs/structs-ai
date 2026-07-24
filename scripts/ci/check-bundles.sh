#!/usr/bin/env bash
# CI: verify the committed llms-*.txt bundles match what the generator produces.
# Prevents hand-edited or stale bundles.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

# Snapshot committed bundles.
tmp="$(mktemp -d)"
for b in llms-start.txt llms-core.txt llms-full.txt; do
  [ -f "$b" ] && cp "$b" "$tmp/$b" || true
done

# Regenerate.
bash scripts/generate-llms-full.sh >/dev/null 2>&1 || {
  echo "FAIL: bundle generator errored" >&2; exit 1; }

FAIL=0
for b in llms-start.txt llms-core.txt llms-full.txt; do
  if [ ! -f "$tmp/$b" ]; then
    echo "FAIL: $b was not committed (generator produced it)" >&2; FAIL=1; continue
  fi
  if ! diff -q "$tmp/$b" "$b" >/dev/null 2>&1; then
    echo "FAIL: $b is stale — run scripts/generate-llms-full.sh and commit" >&2
    FAIL=1
  fi
done

# Budgets (targets; warn only).
warn_budget() { # file, max_bytes
  local sz; sz=$(wc -c < "$1" | tr -d ' ')
  [ "$sz" -gt "$2" ] && echo "warn: $1 is ${sz} bytes (target <= $2)"
}
warn_budget llms-start.txt 30720
# 120 KB: core carries the quick cards (power, defense) rather than the full
# energy/combat systems. What remains is dominated by struct-types.md (the
# build-decision lookup table) and SAFETY.md (the trust contract); dropping
# either to reach 100 KB would cost more than the bytes are worth. Raise this
# only with a matching change to CORE_FILES in scripts/generate-llms-full.sh.
warn_budget llms-core.txt 122880

rm -rf "$tmp"
if [ "$FAIL" -eq 0 ]; then echo "OK: bundles in sync with generator"; else exit 1; fi
