#!/usr/bin/env bash
# Clean-clone smoke test: verify the workspace still satisfies the harness
# contracts after structural changes. Runnable in CI and locally.
#
# Does NOT touch the chain or require structsd. Pure filesystem/structure checks.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
FAIL=0
ok() { echo "  ok: $1"; }
bad() { echo "  FAIL: $1" >&2; FAIL=1; }

echo "== Harness entry files =="
for f in AGENTS.md SAFETY.md SOUL.md USER.md COMMANDER.md IDENTITY.md TOOLS.md OPENCLAW.md START.md README.md index.md; do
  [ -f "$f" ] && ok "$f present" || bad "$f missing"
done

echo "== Cursor skills (canonical) =="
[ -d .cursor/skills ] && ok ".cursor/skills present" || bad ".cursor/skills missing"
for s in play-structs structs-onboarding structs-combat structs-energy; do
  [ -f ".cursor/skills/$s/SKILL.md" ] && ok "skill $s" || bad "skill $s missing"
done

echo "== Skills mirror (Windows-safe real files) =="
if [ -d skills ]; then
  # No symlinks allowed in the mirror.
  if find skills -type l | grep -q .; then bad "skills/ contains symlinks (should be real files)"; else ok "skills/ has no symlinks"; fi
  [ -f skills/play-structs/SKILL.md ] && ok "mirror skills/play-structs/SKILL.md" || bad "mirror missing play-structs"
else
  bad "skills/ mirror missing"
fi

echo "== Runtime state =="
[ -d memory ] && ok "memory/ present" || bad "memory/ missing"

echo "== Operator config =="
[ -f config/operator.example.md ] && ok "config/operator.example.md present" || bad "operator example missing"

echo "== Discovery bundle =="
[ -f llms.txt ] && ok "llms.txt present" || bad "llms.txt missing"

echo
if [ "$FAIL" -eq 0 ]; then echo "SMOKE TEST PASSED"; else echo "SMOKE TEST FAILED" >&2; fi
exit $FAIL
