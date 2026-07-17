# Baseline & Compatibility Contracts

Maintainer-facing record of the runtime contracts this repo must preserve across the
documentation redesign. Excluded from the Jekyll build (`scripts/` is in `_config.yml`
`exclude`). Regenerate the inventory bits with `scripts/ci/*.sh`.

Pinned toolchain: see [`.structsd-version`](../.structsd-version) = `v0.20.0` (matches
`.references/structsd` and the installed binary's `structsd version`). The committed command
snapshot (`generated/structsd-commands.txt`) and catalogs (`generated/commands.md`,
`generated/struct-types.md`) are generated against it. Command-name truth is additionally
enforced by the version-independent deprecated-token blocklist.

Note: several read commands used by skills (e.g. `struct-all-by-planet`, `player-charge`,
`guild-membership-all-by-guild`) are NOT `structsd query structs` subcommands in either
0.19.0 or v0.20.0 — they route through the Guild Stack / webapp query API. The command
lint therefore treats unknown *invocations* as warnings, not hard failures.

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
