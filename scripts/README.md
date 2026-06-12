# Agent Script Toolkit

Small, **read-only** helpers that turn multi-step queries into one-line decisions. None of these sign or submit transactions — that stays with the agent under [`SAFETY.md`](../SAFETY.md). They wrap the same `structsd query structs` commands the skills document, so you can always fall back to the raw CLI.

## Requirements

- [`structsd`](../.cursor/skills/structsd-install/SKILL.md) on PATH (queries need no key)
- [`jq`](https://jqlang.github.io/jq/) for the shell scripts
- Node 18+ and `npm install nats.ws` for `watch-defense.mjs`

Common env vars (see [`lib.sh`](lib.sh)): `STRUCTSD` (binary), `STRUCTS_NODE` (RPC endpoint), `STRUCTS_PLAYER` (default player id).

## Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| [`assess.sh`](assess.sh) | One-shot state snapshot: power headroom, unrefined ore, charge, planet ore, fleet status | `scripts/assess.sh 1-42` |
| [`power-budget.sh`](power-budget.sh) | Capacity vs load + "can I afford this struct?" | `scripts/power-budget.sh 1-42 --type 14` |
| [`scout.sh`](scout.sh) | Raid go/no-go: shield vulnerability (Command Ship status), stealable ore, defenders | `scripts/scout.sh 2-117 [--raw]` |
| [`job-status.sh`](job-status.sh) | Summarize background PoW jobs in `memory/jobs/` (alive / finished / dead) | `scripts/job-status.sh` |
| [`watch-defense.mjs`](watch-defense.mjs) | Live GRASS alerts: raids against you, attacks, Command Ship going offline | `node scripts/watch-defense.mjs structs.planet.2-117` |
| [`check-drift.sh`](check-drift.sh) | Flag documented game constants that drift from the live chain / source | `scripts/check-drift.sh` |
| [`generate-llms-full.sh`](generate-llms-full.sh) | Regenerate `llms-full.txt` / `llms-core.txt` from canonical docs | `scripts/generate-llms-full.sh` |

## Caveats

- Field names follow `structsd query structs ... -o json`. If a build renames a field, use `--raw` (where available) or the raw CLI to see the truth, then adjust the `jq` filters.
- A `GO` verdict from `scout.sh` is a **hypothesis** — power and fleet state change block-to-block. Re-scout immediately before committing proof-of-work.
- These scripts are deliberately dependency-light and easy to read. Fork them per playstyle.
