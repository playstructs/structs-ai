# Baseline & Compatibility Contracts

Maintainer-facing record of the runtime contracts this repo must preserve across the
documentation redesign. Excluded from the Jekyll build (`scripts/` is in `_config.yml`
`exclude`). Regenerate the inventory bits with `scripts/ci/*.sh`.

Pinned toolchain: see [`.structsd-version`](../.structsd-version) = `v0.20.0` (matches
`.references/structsd` and the installed binary's `structsd version`). The committed command
snapshot (`generated/structsd-commands.txt`) and catalogs (`generated/commands.md`,
`generated/struct-types.md`) are generated against it. Command-name truth is additionally
enforced by the version-independent deprecated-token blocklist.

Note: the command lint treats unknown *invocations* as warnings, not hard failures, because
some reads legitimately have no CLI form. Resolved so far — do not reintroduce these names:

| Phantom name | Reality (verified v0.20.0) |
|--------------|----------------------------|
| `struct-all-by-planet` | No CLI form. Guild Stack: `select … from struct where location_id=…` |
| `player-charge` | Not a query at all. Derived: `latest_block_height − player.gridAttributes.lastAction` (`GetCharge()` in `x/structs/keeper/player_cache.go`); `lastAction` is omitted from JSON when `0` |
| `guild-membership-all-by-guild` | No CLI form. Membership is a field on the player: `select id, guild_rank from player where guild_id=…`. `guild-membership-application[-all]` covers *pending applications* only |
| `player-update-pfp-client-render-attributes` | CLI name is abbreviated: `player-update-pfp-cr-attributes`. Only the RPC method and `Msg` type spell out `ClientRenderAttributes` |

When a lint warning turns out to be a phantom, fix the doc and add a row here rather than
leaving the warning to be re-triaged every audit.

### Invocation lint (`check-invocations.py`) — hard gate

A correct command *name* is not enough to be runnable. `scripts/ci/check-invocations.py` gates
three parse-time failures that `lint-commands.sh` cannot see, reading arities from
`generated/structsd-signatures.txt` so it needs no binary in CI:

- **ARITY** — positional count must match the Usage line.
- **ORDER** — `--` must come *after* the flags. pflag stops parsing flags at `--`, so
  `… -- 0-1 1 --from key` hands `--from` and `key` to the command as positional arguments and it
  dies with `accepts N arg(s), received M`. Verified empirically against v0.20.0.
- **GAS** — every `tx` needs `--gas auto` ([`AGENTS.md`](../AGENTS.md) rule 6).

Regenerate the signature snapshot alongside the command snapshot with
`scripts/ci/snapshot-commands.sh` whenever the pinned binary moves.

## Harness entry files (root)

These filenames are read by agent harnesses (Cursor `AGENTS.md`, OpenClaw `USER.md`/`SOUL.md`,
etc.) or referenced by external tooling. They MUST continue to exist (as real files or
compatibility stubs). Never delete outright.

| File | Consumer | Post-redesign role |
|------|----------|--------------------|
| `AGENTS.md` | Cursor / injected context | Concise contract + invariants |
| `SAFETY.md` | agent | Full trust/approval contract (unchanged) |
| `SOUL.md` | OpenClaw | Compatibility stub → `START.md` |
| `USER.md` | OpenClaw | Compatibility stub → `config/operator.md` |
| `COMMANDER.md` | legacy prompts | Compatibility stub → `config/operator.md` |
| `IDENTITY.md` | legacy prompts | Compatibility stub → `memory/` |
| `TOOLS.md` | legacy prompts | Static capability guide → preflight |
| `OPENCLAW.md` | OpenClaw setup | Thin harness adapter |
| `QUICKSTART.md` | old links / `structs://` | Compatibility stub → `START.md` |
| `README.md` | GitHub repo view | Repo-specific pointer |
| `index.md` | structs.ai home | Warm human+agent landing |

## Skill discovery

- Canonical skills live in `.cursor/skills/` (Cursor AgentSkills). This is the source of truth.
- Root `skills/` is the OpenClaw-facing discovery surface AND the GitHub Pages URL base
  (`https://structs.ai/skills/<name>/SKILL`).
- Historically `skills/` entries were symlinks into `.cursor/skills/`. Symlinks are unreliable
  on Windows checkouts, so `skills/` is now a **generated real-file mirror**:
  - Generate: `scripts/gen-skills-mirror.sh`
  - Verify (CI): `scripts/ci/check-skills-mirror.sh`
- Do NOT edit files under `skills/` by hand — edit `.cursor/skills/` and regenerate.

## Public URL base

`https://structs.ai/<path-without-.md>` (Jekyll, `CNAME` = structs.ai). Any page move MUST add
`redirect_from:` (via the `jekyll-redirect-from` plugin) and/or leave a stub at the old path so
old URLs and `sitemap.xml` entries keep resolving.

## structs:// MCP resources (cross-repo gate — RESOLVED)

Structs Desktop bundles this repo as MCP resources. Investigated
`.references/structs-desktop/src-tauri/src/mcp/resources.rs`:

- URIs are built **dynamically** by walking the synced compendium tree:
  `format!("structs://{}", relative_path)` for every `*.md`. No paths are hardcoded in Desktop
  code.
- `resources/list` returns whatever files exist after `make sync`, so moving a file simply
  changes its URI; nothing breaks at the code level.
- The only hardcoded old paths are **illustrative examples** in docs
  (`structs-desktop/README.md`, our `TOOLS.md`, `knowledge/infrastructure/structs-desktop.md`).
- Verdict: the physical restructure needs **no coordinated code change** in structs-desktop.
  Leaving redirect stubs at old paths keeps old `structs://` URIs resolving to a pointer after
  the next sync. Update the doc examples to the new canonical paths.

## Runtime state (do not relocate)

- `memory/` — jobs, player state, handoffs, intel, audit. Scripts (`assess.sh`, `job-status.sh`,
  `scout.sh`, `watch-defense.mjs`) and SAFETY audit paths depend on it. Keep as-is.
- `.env` / mnemonics — never read, exported, or committed. Preflight only detects presence.

## Known truth issues to fix before restructure (Phase 1)

1. "Transaction fees come from energy" (`play-structs`, `TOOLS.md`, `knowledge/economy/energy-market.md`)
   contradicts source-referenced `knowledge/mechanics/transactions.md` (pure Structs gameplay
   messages are free via the free-gas ante meter; no `ualpha`, no energy spent as a fee).
2. Stale command name `struct-ore-refinery-complete` in `schemas/actions.md`,
   `awareness/threat-detection.md`, `awareness/state-assessment.md`, `reference/action-index.md`,
   `reference/action-quick-reference.md`.
3. `-D 1` vs `-D 3` proof-of-work default inconsistency between `AGENTS.md`/`README` and
   `play-structs`.
