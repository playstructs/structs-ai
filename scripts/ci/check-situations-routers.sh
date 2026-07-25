#!/usr/bin/env bash
# Every playbooks/situations/*.md (except index.md) must appear in the three
# bootstrap discovery routers. Section indexes alone are not enough — agents
# that only read AGENTS.md / llms.txt / SITEMAP.md never see orphaned pages.
# See .review/tasks.md T-011.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

fail=0
for f in playbooks/situations/*.md; do
  base=$(basename "$f")
  [ "$base" = "index.md" ] && continue
  stem=${base%.md}
  for router in AGENTS.md llms.txt SITEMAP.md; do
    if ! grep -q "situations/${stem}" "$router"; then
      echo "FAIL: playbooks/situations/${base} missing from ${router}"
      fail=1
    fi
  done
done

if [ "$fail" -eq 0 ]; then
  echo "OK: all situation playbooks appear in AGENTS.md, llms.txt, and SITEMAP.md"
else
  exit 1
fi
