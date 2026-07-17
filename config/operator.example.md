---
# ─────────────────────────────────────────────────────────────────────────────
# Structs operator profile — the ONE file a human edits.
# Copy this to config/operator.md (gitignored) and fill it in. Your agent reads
# config/operator.md at session start. Everything here is optional; sensible
# defaults apply. Nothing here is a personality — it is intent + connection.
# ─────────────────────────────────────────────────────────────────────────────

operator:
  name: ""                 # what your agent should call you
  timezone: ""             # e.g. America/New_York
  comms: concise           # concise | detailed | casual | formal

# What you want out of the game. Weights 0–3 (0 = ignore, 3 = primary focus).
# The agent uses these to decide which tasks and skills matter. Compose freely,
# or start from a preset in strategy/presets/ (e.g. Industrialist, Raider, Merchant).
goals:
  economy: 2               # mining, refining, energy sales, staking
  expansion: 2             # new planets, more structs, territory
  military: 1              # attacks, raids, defense, fleet
  exploration: 1           # scouting planets, mapping the galaxy
  guild: 1                 # guild membership, banking, coordination

risk: moderate             # cautious | moderate | aggressive
autonomy: ask_for_irreversible   # see the ladder below
tempo: patient             # patient | balanced | fast

guild_preference: optional # optional | required | none | "<guild name/id>"

# Connection details (where your agent plays). Leave blank to auto-detect via
# `scripts/preflight.sh`. NEVER put mnemonics or private keys in this file.
environment:
  interface: auto          # auto | mcp | cli   (auto = prefer Desktop MCP, else CLI)
  chain_id: structs
  rpc: ""                  # e.g. https://rpc.example.com:443  (blank = CLI default)
  key_name: ""             # structsd key name to sign with (material stays in your keyring)
  mcp_url: http://127.0.0.1:8420   # Structs Desktop MCP (if running)
---

# Operator profile

This is your standing agreement with your agent. The frontmatter above is the
machine-readable part; the sections below are your standing orders. See
[SAFETY.md](../SAFETY.md) for the trust contract and the Tier definitions these
orders reference.

## Autonomy ladder

Set `autonomy` above to one of:

- `ask_first` — confirm every action before signing (most cautious).
- `ask_for_irreversible` — act on routine/reversible moves; escalate anything in the
  Tier 2 list below (recommended default).
- `act_and_report` — act within the Tier 1 caps below; report after.
- `full` — full autonomy within caps; escalate only Tier 2. Use with care.

## Tier 1 (significant) auto-approval caps

Limits inside which the agent may act without per-action approval. Above them, escalate.

- `reactor-infuse`: up to ___ ualpha per session
- `agreement-open`: up to ___ ualpha committed at any time
- `struct-build-initiate`: up to ___ new builds per session
- `struct-attack`: only against targets in the known-hostile list below
- Long proof-of-work builds (> 1 hr to D=3): require per-build approval

## Tier 2 (irreversible / identity) — always escalate

Never auto-execute these, regardless of autonomy level:

- Every `struct-generator-infuse`
- Every `permission-grant-on-object` with `PermAll` (33554431)
- Every `permission-guild-rank-set` with broad bits (16777216, 524288, 262144)
- Every `address-register`, `address-revoke`, `player-update-primary-address`
- Every `guild-bank-confiscate-and-burn`
- Every `reactor-defuse` and `reactor-begin-migration`
- Every `provider-delete`, `substation-delete`, `allocation-delete`
- Cross-account `player-send` to a recipient with no prior history
- Multi-target `struct-attack` that crosses guild boundaries

## Known-hostile targets

Player or guild IDs against which routine combat is pre-approved.

## Forbidden

Hard limits, e.g. "Do not attack guild-mate planets", "Do not run more than 2
concurrent background expeditions."

## Notes

Anything else your agent should know about working with you.
