# Agent Script Toolkit

Small, **read-only** helpers that turn multi-step queries into one-line decisions. None of these sign or submit transactions — that stays with the agent under [`SAFETY.md`](../SAFETY.md). They wrap the same `structsd query structs` commands the skills document, so you can always fall back to the raw CLI.

## Requirements

- [`structsd`](/skills/structsd-install/SKILL.html) on PATH (queries need no key)
- [`jq`](https://jqlang.github.io/jq/) for the shell scripts
- Python 3 for `assess.sh` and `power-budget.sh` (standard library only)
- Node 18+ and `npm install nats.ws` for `watch-defense.mjs`

Common env vars: `STRUCTSD` (binary), `STRUCTS_NODE` (RPC endpoint), `STRUCTS_PLAYER` (default player id). Assessment and power-budget helpers also accept `STRUCTS_CHAIN_ID` to require a specific network.

## Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| [`assess.sh`](https://github.com/playstructs/structs-ai/blob/main/scripts/assess.sh) | One-height snapshot: exact stored power margin, unrefined ore, charge, planet ore, fleet status | `scripts/assess.sh 1-42` |
| [`power-budget.sh`](https://github.com/playstructs/structs-ai/blob/main/scripts/power-budget.sh) | Exact stored capacity/load and a prospective passive-draw comparison | `scripts/power-budget.sh 1-42 --type 14` |
| [`scout.sh`](https://github.com/playstructs/structs-ai/blob/main/scripts/scout.sh) | Raid go/no-go: shield vulnerability (Command Ship status), stealable ore, defenders | `scripts/scout.sh 2-117 [--raw]` |
| [`job-status.sh`](https://github.com/playstructs/structs-ai/blob/main/scripts/job-status.sh) | Summarize background PoW jobs in `memory/jobs/` (alive / finished / dead) | `scripts/job-status.sh` (run from repo root) |
| [`watch-defense.mjs`](https://github.com/playstructs/structs-ai/blob/main/scripts/watch-defense.mjs) | Live GRASS alerts: raids against you, attacks, Command Ship going offline | `node scripts/watch-defense.mjs structs.planet.2-117` |
| [`check-drift.sh`](https://github.com/playstructs/structs-ai/blob/main/scripts/check-drift.sh) | Flag documented game constants that drift from the live chain / source | `scripts/check-drift.sh` |
| [`generate-llms-full.sh`](https://github.com/playstructs/structs-ai/blob/main/scripts/generate-llms-full.sh) | Regenerate `llms-full.txt` / `llms-core.txt` from canonical docs | `scripts/generate-llms-full.sh` |

## Caveats

- Assessment and power-budget queries use the same configured node and explicit height. Status before and after the reads must agree on chain identity and must not move backwards. The helpers trust the CLI and node; they do not perform light-client verification. Each CLI read has a 15-second deadline.
- Individual numeric fields are validated as exact uint64 values. Totals can exceed uint64 and stored margins can be negative without wrapping. Only omitted protobuf primitive fields in a valid response receive zero defaults. Missing entities, malformed responses, failed/pruned reads and invalid values refuse the whole assessment with a nonzero exit; they never produce a partial positive verdict.
- Stored margins do not establish live usable power, online status or permission to activate a struct. Native eligibility checks can differ while repairs are pending or supply is invalid. Verify the actual action separately. `--type` compares passive draw; it does not reserve build draw or account for target permissions.

- Field names follow `structsd query structs ... -o json`. If a build renames a field, use `--raw` (where available) or the raw CLI to see the truth, then adjust the `jq` filters.
- A `GO` verdict from `scout.sh` is a **hypothesis** — power and fleet state change block-to-block. Re-scout immediately before committing proof-of-work.
- These scripts are deliberately dependency-light and easy to read. Fork them per playstyle.

Run deterministic helper checks without a node or key: `python3 scripts/ci/test-assessment.py`.
