#!/usr/bin/env bash
# Namespace-aware CLI command lint.
#
# Check 1 (invocations, WARNING): flags `structsd tx structs <cmd>` / `structsd query
#   structs <cmd>` whose <cmd> is not in generated/structsd-commands.txt. This is
#   informational only (does not fail the build) because: (a) the snapshot binary version
#   may skew from the docs' target release, and (b) many reads route through Guild
#   Stack/webapp queries that are not CLI subcommands. It intentionally ignores proto
#   message names (MsgStruct...) and doc/action slugs — only the CLI namespace.
# Check 2 (deprecated tokens, HARD GATE): none of the tokens in
#   scripts/ci/deprecated-tokens.txt may appear anywhere in agent-facing docs.
#
# Portable to bash 3.2 (macOS). Uses grep --include/--exclude-dir, no mapfile.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

SNAPSHOT="generated/structsd-commands.txt"
DEPRECATED="scripts/ci/deprecated-tokens.txt"
FAIL=0

if [ ! -f "$SNAPSHOT" ]; then
  echo "error: $SNAPSHOT missing. Run scripts/ci/snapshot-commands.sh" >&2
  exit 1
fi

VALID="$(grep -vE '^#' "$SNAPSHOT" | grep -vE '^[[:space:]]*$' | sort -u)"

# Documentation placeholders that are not real commands.
PLACEHOLDERS="command [command]"

GREP_EXCL=(--include='*.md'
  --exclude-dir=.references --exclude-dir=.git --exclude-dir=structs-webapp
  --exclude-dir=structs-desktop --exclude-dir=node_modules --exclude-dir=archive
  --exclude-dir=.review --exclude-dir=vendor)

# --- Check 1 (WARNING only): CLI invocations that don't resolve in the snapshot ---
WARN=0
while IFS= read -r line; do
  [ -z "$line" ] && continue
  file="${line%%:*}"
  case "$file" in scripts/BASELINE.md|*/CHANGELOG.md|CHANGELOG.md) continue;; esac
  cmd="$(printf '%s\n' "$line" | sed -nE 's/.*structsd (tx|query) structs[[:space:]]+([a-z][a-z0-9-]*).*/\2/p' | head -1)"
  [ -z "$cmd" ] && continue
  case " $PLACEHOLDERS " in *" $cmd "*) continue;; esac
  if ! printf '%s\n' "$VALID" | grep -qxF "$cmd"; then
    echo "warn [not in snapshot; verify vs Guild Stack/webapp or newer release] $file -> '$cmd'"
    WARN=$((WARN+1))
  fi
done < <(grep -rInE 'structsd (tx|query) structs[[:space:]]+[a-z]' "${GREP_EXCL[@]}" . 2>/dev/null)
[ "$WARN" -gt 0 ] && echo "($WARN invocation warning(s) — informational, not failing)"

# --- Check 2: deprecated tokens must not appear as live guidance ---
# Explanatory hits are allowed when the same line clearly marks the name as
# phantom / absent (so BASELINE-style teaching and integration-notes caveats pass).
while IFS= read -r tok; do
  [ -z "$tok" ] && continue
  case "$tok" in \#*) continue;; esac
  hits="$(grep -rInF "$tok" "${GREP_EXCL[@]}" \
    --exclude=BASELINE.md --exclude=CHANGELOG.md . 2>/dev/null \
    | grep -v '^scripts/ci/deprecated-tokens.txt' \
    | grep -vE 'does not exist|do not exist|no such|there is no|never existed|Phantom|phantom|Not a query|no CLI form|WRONG CLI|removed from the module|absent from|purged' \
    || true)"
  if [ -n "$hits" ]; then
    echo "FAIL [deprecated token '$tok']:" >&2
    echo "$hits" >&2
    FAIL=1
  fi
done < "$DEPRECATED"

if [ "$FAIL" -eq 0 ]; then
  echo "OK: command lint passed ($(printf '%s\n' "$VALID" | wc -l | tr -d ' ') valid commands known)"
else
  echo "command lint FAILED" >&2
fi
exit $FAIL
