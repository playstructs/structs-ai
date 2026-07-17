#!/usr/bin/env bash
# Read-only environment preflight: detect which interfaces an agent can use to
# play Structs, WITHOUT reading, printing, or exporting any secrets.
#
# Writes a capability profile to config/environment.json (gitignored) and prints
# a human/agent-readable summary. Safe to run anytime.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
mkdir -p config

MCP_URL="${STRUCTS_MCP_URL:-http://127.0.0.1:8420}"

have() { command -v "$1" >/dev/null 2>&1; }
yn() { [ "$1" = "1" ] && echo true || echo false; }

# --- structsd CLI ---
CLI=0; CLI_VER=""
if have structsd; then CLI=1; CLI_VER="$(structsd version 2>&1 | head -1)"; fi

# --- Desktop MCP (loopback health probe, unauthenticated) ---
MCP=0
if have curl; then
  if curl -fsS --max-time 2 "$MCP_URL/health" >/dev/null 2>&1; then MCP=1; fi
fi

# --- node (for create-player.mjs / watch-defense.mjs) ---
NODE=0; NODE_VER=""
if have node; then NODE=1; NODE_VER="$(node --version 2>&1)"; fi

# --- docker (Guild Stack) ---
DOCKER=0
if have docker; then DOCKER=1; fi

# --- psql (Guild Stack PostgreSQL client) ---
PSQL=0
if have psql; then PSQL=1; fi

# --- key presence (existence only; never read material) ---
KEY=0; KEY_COUNT=0
if [ "$CLI" = "1" ]; then
  KEY_COUNT="$(structsd keys list --output json 2>/dev/null | grep -c '"name"' || true)"
  [ "${KEY_COUNT:-0}" -gt 0 ] && KEY=1
fi

# --- operator profile present? ---
OPERATOR=0
[ -f config/operator.md ] && OPERATOR=1

cat > config/environment.json <<EOF
{
  "generated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "structsd_cli": { "available": $(yn $CLI), "version": "${CLI_VER}" },
  "desktop_mcp": { "available": $(yn $MCP), "url": "${MCP_URL}" },
  "node": { "available": $(yn $NODE), "version": "${NODE_VER}" },
  "docker": { "available": $(yn $DOCKER) },
  "psql": { "available": $(yn $PSQL) },
  "signing_key": { "present": $(yn $KEY), "count": ${KEY_COUNT:-0} },
  "operator_profile": { "present": $(yn $OPERATOR) }
}
EOF

echo "== Structs preflight =="
echo "structsd CLI      : $([ $CLI = 1 ] && echo "yes ($CLI_VER)" || echo "NO — see .cursor/skills/structsd-install/")"
echo "Desktop MCP       : $([ $MCP = 1 ] && echo "yes ($MCP_URL)" || echo "no (not running / not installed)")"
echo "node              : $([ $NODE = 1 ] && echo "yes ($NODE_VER)" || echo "no (needed for guild signup script)")"
echo "docker            : $([ $DOCKER = 1 ] && echo "yes" || echo "no (Guild Stack unavailable)")"
echo "psql              : $([ $PSQL = 1 ] && echo "yes" || echo "no")"
echo "signing key       : $([ $KEY = 1 ] && echo "present ($KEY_COUNT)" || echo "none yet")"
echo "operator profile  : $([ $OPERATOR = 1 ] && echo "config/operator.md" || echo "MISSING — copy config/operator.example.md")"
echo
echo "Recommended interface: $([ $MCP = 1 ] && echo "Desktop MCP (structs_* tools)" || { [ $CLI = 1 ] && echo "structsd CLI" || echo "install structsd first"; })"
echo "Profile written to config/environment.json"
