#!/usr/bin/env bash
# check-webapp-drift.sh — report what changed in structs-webapp since the docs were pinned.
#
# develop/ui/ and develop/client/ are written from structs-webapp at the revision in
# .structs-webapp-version. This script answers two questions a reviewer needs:
#
#   1. MECHANICAL — did the extracted SUI inventory change? (tokens, icons, classes,
#      modifiers, scale breakpoints, SUI JS modules). Exact, no judgement needed.
#   2. SURFACE    — which directories the docs depend on saw commits since the pin, so a
#      human knows where to look for behaviour changes a diff of CSS cannot catch.
#
# READ-ONLY. Never modifies the checkout, the pin, or generated/. Prints a report.
#
# Exit codes:  0  no drift
#              1  drift detected (inventory differs, or commits landed since the pin)
#              2  could not run (missing checkout, missing baseline)
#
# Usage:  scripts/check-webapp-drift.sh [--fetch]
#           --fetch   git fetch the checkout first, so the comparison is against upstream
#                     HEAD rather than whatever the local clone last saw.
# Env:    STRUCTS_WEBAPP   path to a structs-webapp checkout
#                          (default: .references/structs-webapp)

set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PIN_FILE="$ROOT/.structs-webapp-version"
BASELINE="$ROOT/generated/sui-inventory.md"
WEBAPP="${STRUCTS_WEBAPP:-$ROOT/.references/structs-webapp}"
DO_FETCH=0
[ "${1:-}" = "--fetch" ] && DO_FETCH=1

# Directories the docs make claims about, mapped to the pages that would be wrong.
# Keep in sync with the "Verified against" footers in develop/.
SURFACES="
src/public/css/sui|develop/ui/tokens.md, components.md, gotchas.md
src/public/css/structicons.css|develop/ui/icons.md
src/public/css/main.css|develop/ui/index.md (scaling)
src/js/sui|develop/ui/runtime.md
src/js/managers/SigningQueueManager.js|develop/client/actions-and-signing.md
src/js/managers/SigningClientManager.js|develop/client/actions-and-signing.md
src/js/managers/WalletManager.js|develop/client/actions-and-signing.md
src/js/workers|develop/client/work-and-pow.md
src/js/managers/TaskManager.js|develop/client/work-and-pow.md
src/js/models/TaskState.js|develop/client/work-and-pow.md
src/js/framework/GrassManager.js|develop/client/realtime-grass.md
src/js/grass_listeners|develop/client/realtime-grass.md
src/js/models/GameState.js|develop/client/state-and-data.md
src/js/factories|develop/client/state-and-data.md
src/js/api/GuildAPI.js|develop/client/state-and-data.md
src/js/view_models/components/map|develop/client/map.md
src/js/view_models/components/PfpViewerComponent.js|develop/client/rendering-entities.md
src/js/data_structures/AnimationEventQueue.js|develop/client/rendering-entities.md
src/js/framework|develop/frontend-architecture.md
src/webpack.config.js|develop/frontend-architecture.md
"

say() { printf '%s\n' "$*"; }
rule() { printf -- '---\n'; }

# --- preconditions -----------------------------------------------------------

if [ ! -f "$PIN_FILE" ]; then
  say "error: missing $PIN_FILE"; exit 2
fi
PIN="$(grep -vE '^\s*(#|$)' "$PIN_FILE" | head -1 | tr -d '[:space:]')"
if [ -z "$PIN" ]; then
  say "error: no revision in $PIN_FILE"; exit 2
fi

if [ ! -d "$WEBAPP/.git" ]; then
  say "error: no structs-webapp checkout at $WEBAPP"
  say "       clone it, or set STRUCTS_WEBAPP. See develop/repos.md."
  exit 2
fi

if [ ! -f "$BASELINE" ]; then
  say "error: missing baseline $BASELINE — run scripts/gen-sui-inventory.sh"; exit 2
fi

if [ "$DO_FETCH" -eq 1 ]; then
  say "Fetching $WEBAPP ..."
  git -C "$WEBAPP" fetch --quiet --depth 200 origin 2>/dev/null \
    || say "  (fetch failed; comparing against the local checkout as-is)"
fi

HEAD_SHA="$(git -C "$WEBAPP" rev-parse HEAD)"
HEAD_DATE="$(git -C "$WEBAPP" log -1 --format=%cd --date=short)"

say "structs-webapp drift report"
say "  docs pinned at : ${PIN:0:12}"
say "  checkout HEAD  : ${HEAD_SHA:0:12} ($HEAD_DATE)"
rule

DRIFT=0

# --- 1. mechanical: inventory diff -------------------------------------------

say "## SUI inventory"
say ""
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

if ! "$ROOT/scripts/gen-sui-inventory.sh" --stdout > "$TMP" 2>/dev/null; then
  say "  could not regenerate the inventory; skipping the mechanical check."
else
  # Ignore the front matter, which carries the SHA and today's date and so always differs.
  strip_meta() { sed -n '/^# SUI inventory/,$p' "$1" | grep -v '^Source commit:'; }
  if diff -q <(strip_meta "$BASELINE") <(strip_meta "$TMP") >/dev/null; then
    say "  No change. Tokens, icons, classes, modifiers and breakpoints all match."
  else
    DRIFT=1
    say "  CHANGED. Affected pages: develop/ui/tokens.md, icons.md, components.md."
    say ""
    diff -u <(strip_meta "$BASELINE") <(strip_meta "$TMP") \
      | grep -E '^[+-]' | grep -vE '^[+-]{3}' | sed 's/^/    /'
  fi
fi
rule

# --- 2. surface: commits per watched directory -------------------------------

say "## Commit surface since the pin"
say ""

if ! git -C "$WEBAPP" cat-file -e "${PIN}^{commit}" 2>/dev/null; then
  DRIFT=1
  say "  Pinned commit $PIN is not in this checkout (shallow clone?)."
  say "  Deepen with: git -C \"$WEBAPP\" fetch --unshallow"
else
  TOTAL="$(git -C "$WEBAPP" rev-list --count "${PIN}..HEAD" 2>/dev/null || echo 0)"
  if [ "$TOTAL" = "0" ]; then
    say "  No commits since the pin. Nothing to review."
  else
    DRIFT=1
    say "  $TOTAL commit(s) since the pin. Watched paths with changes:"
    say ""
    printf '%s\n' "$SURFACES" | while IFS='|' read -r path pages; do
      [ -z "$path" ] && continue
      n="$(git -C "$WEBAPP" rev-list --count "${PIN}..HEAD" -- "$path" 2>/dev/null || echo 0)"
      [ "$n" = "0" ] && continue
      printf '    %-52s %3s commit(s)\n' "$path" "$n"
      printf '      → %s\n' "$pages"
      git -C "$WEBAPP" log --oneline --no-decorate "${PIN}..HEAD" -- "$path" \
        | head -5 | sed 's/^/        /'
      say ""
    done
  fi
fi
rule

# --- verdict -----------------------------------------------------------------

if [ "$DRIFT" -eq 0 ]; then
  say "No drift. The docs still describe this revision."
  exit 0
fi

say "Drift detected. Review procedure: develop/maintenance.md"
say ""
say "  1. Read the commits above for the pages they touch."
say "  2. Re-verify the affected claims against source."
say "  3. scripts/gen-sui-inventory.sh   # refresh the mechanical baseline"
say "  4. Update .structs-webapp-version and the page footers to the new SHA."
exit 1
