# Changelog

All notable changes to the Structs Compendium documentation will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.9.0] - 2026-05-13

### Added

- **[`SAFETY.md`](SAFETY.md)** — the trust contract between agent and commander. Three operation tiers (Routine / Significant / Irreversible) mapped to `COMMANDER.md` autonomy levels. Battle-order approval pattern, background-expedition rules, key hygiene, verification checklist, and audit log pattern. Links the public [ClawScan audits](https://clawhub.ai/abstrct) for every skill.
- **[`awareness/agent-security.md`](awareness/agent-security.md)** — operational threat playbook. UGC prompt injection, RPC node trust, `address-register` identity hijack, guild API trust, MCP/signing-agent exposure, multi-agent key isolation. Includes a step-by-step incident response playbook (defuse → revoke → transfer → revoke permissions → rotate primary address → log).
- **[`COMMANDER.md`](COMMANDER.md)** standing-orders template — pre-filled Tier 1 auto-approval caps and Tier 2 always-escalate lists so commanders fill blanks instead of designing from scratch.
- **Per-skill Safety callouts** on all 11 affected skills ([`structs-onboarding`](.cursor/skills/structs-onboarding/SKILL.md), [`structs-mining`](.cursor/skills/structs-mining/SKILL.md), [`structs-building`](.cursor/skills/structs-building/SKILL.md), [`structs-combat`](.cursor/skills/structs-combat/SKILL.md), [`structs-economy`](.cursor/skills/structs-economy/SKILL.md), [`structs-energy`](.cursor/skills/structs-energy/SKILL.md), [`structs-power`](.cursor/skills/structs-power/SKILL.md), [`structs-guild`](.cursor/skills/structs-guild/SKILL.md), [`structs-diplomacy`](.cursor/skills/structs-diplomacy/SKILL.md), [`structs-exploration`](.cursor/skills/structs-exploration/SKILL.md), [`structs-guild-stack`](.cursor/skills/structs-guild-stack/SKILL.md)). Each callout lists the skill's highest-impact ops with their tier and in-character flavor.
- **[`.cursor/skills/structs-guild-stack/SKILL.md`](.cursor/skills/structs-guild-stack/SKILL.md)** "Lifecycle & Trust" subsection — pin a release tag rather than tracking `main`, disable services not needed (read-only PG profile), bind MCP to `127.0.0.1`, signing-agent caveat, teardown commands.

### Changed

- [`AGENTS.md`](AGENTS.md), [`README.md`](README.md), [`index.md`](index.md), [`QUICKSTART.md`](QUICKSTART.md), [`llms.txt`](llms.txt), [`SITEMAP.md`](SITEMAP.md), and [`awareness/index.md`](awareness/index.md) — surface SAFETY.md and agent-security.md as discoverable entry points; added Critical Rule 9 in AGENTS.md.
- [`scripts/generate-llms-full.sh`](scripts/generate-llms-full.sh) — includes SAFETY.md and `awareness/agent-security.md` in the aggregated build.

### Context

Responds to [ClawScan](https://clawhub.ai/abstrct) audits of 11 Structs skills (ASI02 `-y` auto-confirm; ASI03 signing-key scope; ASI04 binary trust; ASI06 personal-file context poisoning; ASI07 guild API + MCP; ASI10 long-running PoW). Keeps `-y` in `TX_FLAGS` for ergonomics and instead makes the approval gate explicit through a commander-grounded tier system. `structsd-install` was the only audited skill that already passed; it remains unchanged.

## [1.8.0] - 2026-05-13

### Added

- **Public SSL chain endpoint** documented as the canonical example for chain queries: `https://public.testnet.structs.network` (REST) and `https://public.testnet.structs.network:26657` (Tendermint RPC; `wss://...:26657/websocket` for the Tendermint WebSocket). The new endpoint avoids mixed-content and CORS issues that occurred when calling `http://reactor.oh.energy:1317` from HTTPS contexts. The Guild API (`http://crew.oh.energy/api/`) and GRASS NATS WebSocket (`ws://crew.oh.energy:1443`) remain hosted by individual guilds and are unchanged.
- **Webapp catalog read API**: 19 new per-entity files in [`api/webapp/`](api/webapp/) covering the `CatalogReadController` family (`address-tag`, `agreement`, `allocation`, `banned-word`, `defusion`, `fleet/list`, `grid`, `guild-membership-application`, `permission`, `permission-guild-rank`, `planet-activity`, `planet-attribute`, `provider`, `reactor`, `substation`, `struct-attribute`, `struct-defender`) plus `setting` (live tunables) and `stat` (time-series range queries). Existing per-entity files (`player.md`, `planet.md`, `guild.md`, `struct.md`, `ledger.md`, `infusion.md`) extended with their corresponding `/list/...` catalog endpoints.
- **Webapp protocol additions** in [`protocols/webapp-api-protocol.md`](protocols/webapp-api-protocol.md): catalog-read pattern, time-series stats pattern, live-tunables pattern, kebab-case naming, the `/list/` namespacing rule that prevents the catalog list from shadowing single-id routes, and the `?start_time=&end_time=` (unix seconds) query convention.
- **structs-pg schema additions** in [`knowledge/infrastructure/database-schema.md`](knowledge/infrastructure/database-schema.md): new tables `structs.banned_word`, `structs.address_tag` (with the `(label, entry)` reverse-lookup index), `structs.setting` (seeded keys: `REACTOR_RATIO`, `PLAYER_RESUME_CHARGE`, `PLANETARY_SHIELD_BASE`, `PLAYER_PASSIVE_DRAW`, `PLANET_STARTING_ORE`, `PLANET_STARTING_SLOTS`), `structs.defusion` (with the `CLEAN_DEFUSION()` cron), aggregated views `view.guild_bank`, `view.leaderboard_guild`, `view.leaderboard_player`, and the `planet.seized_ore` column. [`knowledge/infrastructure/guild-stack.md`](knowledge/infrastructure/guild-stack.md) gained a one-paragraph note that the PG schema is owned by `structs-pg` and applied with Sqitch (initial deploy by `structs-pg-init`, ongoing by `structs-pg-auto-migrate`).

### Changed

- **Reference node** in [`TOOLS.md`](TOOLS.md) switched to `https://public.testnet.structs.network` and the SSL Tendermint URL (`wss://...:26657/websocket`). Skills (`play-structs`, `structs-onboarding`, `structs-streaming`) and the `create-player.mjs` script header / usage strings updated to match.
- **Endpoint indexes** ([`api/endpoints.md`](api/endpoints.md), [`reference/endpoint-index.md`](reference/endpoint-index.md), [`reference/endpoint-quick-lookup.md`](reference/endpoint-quick-lookup.md), [`reference/api-quick-reference.md`](reference/api-quick-reference.md), [`api/webapp/README.md`](api/webapp/README.md)) refreshed to register the new webapp endpoints and the SSL chain hosts. Stale per-doc "Version" pins removed in favour of `Last Updated` dates only — these documents represent current truth, not versioned history.
- **structsd v0.16 wording reconciled**: documented the fact that there is no `MsgGuildModerate*` message in `tx.proto`. Moderation is the same `Msg*UpdateName` / `Msg*UpdatePfp` chain message, gated by `PermGuildUGCUpdate` (bit 24) on the target owner's guild when actor != owner, and the chain emits a `ugc_moderated` Cosmos event for audit. The 1.7.0 entry below references "Guild moderation overrides: `MsgGuildModeratePlayerName/Pfp` ..." — those names refer to `tx_guild_moderate_*` PL/pgSQL wrappers in the **signer** layer (which queue the same `Msg*Update*` chain message after a `PermGuildUGCUpdate` preflight), not to chain message types. [`knowledge/infrastructure/database-schema.md`](knowledge/infrastructure/database-schema.md) reworded the `signer.tx_*` wrapper section to make this explicit.

### Removed

- Per-file "Version: 1.x.0" pins on touched documentation files. The repo now expresses freshness only via `Last Updated` dates on the file and via this `CHANGELOG.md`.

## [1.7.0] - 2026-04-28

### Added - v0.16.0 (Quantillia) / structstestnet-112

Major documentation update for `structsd` v0.16.0 (codename "Quantillia"). Synchronizes the docs with the chain's permission expansion (24->25 bit), the new fee/ante model, the seven new UGC (User-Generated Content) transactions and their decentralized moderation hooks, the `GuildMembershipJoinProxy` UGC fields, the planet-explore precondition tightening, the Starfighter guaranteed-shot fix, the Quantillia database schema, and the related webapp / signer / build-system changes. Includes two new knowledge documents (`transactions.md`, `ugc-moderation.md`) and a Makefile-based install path.

#### Permission System (24-bit -> 25-bit)

- `PermAll` and `PermPlayerAll` bumped from `16777215` to `33554431` (25 bits).
- New permission flag `PermGuildUGCUpdate` (bit 24, value `16777216`) for guild-scoped moderation of player/planet/substation UGC.
- `PermGuildAll` updated to `17166862`.
- `knowledge/mechanics/permissions.md` now documents `UGCPermissionCheck` -- the two-tier flow that first attempts a self-service `PermUpdate` check, and falls back to `PermGuildUGCUpdate` against the target owner's guild.
- All affected docs updated: `api/queries/permission.md`, `schemas/entities.md`, `schemas/game-state.md`, `knowledge/mechanics/index.md`, `reference/entity-index.md`, `reference/action-quick-reference.md`, `troubleshooting/edge-cases.md`, `troubleshooting/permission-issues.md`, `patterns/performance-optimization.md`, `examples/database/query-examples.md`, `examples/workflows/permission-checking.md`, `examples/auth/permission-examples.md`, `.cursor/skills/structs-diplomacy/SKILL.md`, `.cursor/skills/structs-guild/SKILL.md`, `SITEMAP.md`, `llms.txt`.

#### Free Gameplay Transactions and Custom Ante Handler

- **NEW: `knowledge/mechanics/transactions.md`** -- explains the v0.16.0 fee model: pure-Structs gameplay transactions (allocations, substations, guilds, combat, UGC, ...) are free with a 20M gas cap; six Cosmos SDK staking messages are free with a 40M gas cap (one per address per block); standard Cosmos SDK operations (`MsgSend`, non-listed `x/staking` messages, mixed transactions) still pay `ualpha`. `--gas auto` is still required for accurate gas estimation.
- `protocols/action-protocol.md` updated with a new "Fees" subsection summarizing the free-gas changes.

#### UGC Transactions and Decentralized Moderation

- **NEW: `knowledge/mechanics/ugc-moderation.md`** -- philosophy and how-to for guild-scoped moderation. Covers self-service vs. moderator paths, the `PermGuildUGCUpdate` permission, the `ugc_moderated` Cosmos chain event (emitted only when `actor != owner`), per-field validation rules with Python and JavaScript snippets, and operational guidance for guild policy/auditing.
- Seven new transactions documented across `schemas/actions.md`, `reference/action-quick-reference.md`, `.cursor/skills/structs-guild/SKILL.md`, and the structsd CLI references:
  - Self-service: `MsgPlayerUpdateName`, `MsgPlayerUpdatePfp`, `MsgGuildUpdateName`, `MsgGuildUpdatePfp`, `MsgPlanetUpdateName`, `MsgSubstationUpdateName`, `MsgSubstationUpdatePfp` (all gated by `PermUpdate` on the target object)
  - Guild moderation overrides: `MsgGuildModeratePlayerName/Pfp`, `MsgGuildModeratePlanetName`, `MsgGuildModerateSubstationName/Pfp` (all gated by `PermGuildUGCUpdate` on the target owner's guild)
- `knowledge/lore/factions.md` got a new "Identity and moderation" subsection introducing the model in lore terms.

#### UGC String Validation

- Per-profile validation rules added to `schemas/validation.md` and fully spelled out in `knowledge/mechanics/ugc-moderation.md` for: player name (3-20, no spaces, no apostrophe), entity name (guild/substation, 3-20, allows space and apostrophe, no leading/trailing/double space), planet name (3-25, same as entity), and PFP (opaque `[A-Za-z0-9._/-]{1,256}` or URL with allowed schemes `https`, `http`, `ipfs`, `ipns`, `ar`).
- All names: NFC-normalized, no control characters, no bidi/zero-width/format/combining marks, no `N-N` ID-shaped strings, must be valid UTF-8.
- `.cursor/skills/structs-onboarding/scripts/create-player.mjs` -- new `--username` and `--pfp` flags, client-side validators that mirror the chain's `ValidatePlayerName` / `ValidatePfp`, and `pfp` plumbed into the signup payload and final output.

#### `GuildMembershipJoinProxy` UGC Fields

- `MsgGuildMembershipJoinProxy` now accepts optional `playerName` and `playerPfp` so the chain becomes the sole source of truth for player identity at signup. Documented in `schemas/actions.md`, `reference/action-quick-reference.md`, `.cursor/skills/structs-guild/SKILL.md`, `.cursor/skills/structs-onboarding/SKILL.md`, and threaded through `create-player.mjs`.

#### Planet Exploration Precondition

- `MsgPlanetExplore` now requires the fleet to be `onStation` at the player's current planet *only when the player already owns one*. First-time explorers (no current planet) are exempt. Documented in `schemas/actions.md`, `knowledge/mechanics/planet.md`, `knowledge/mechanics/fleet.md`, and `.cursor/skills/structs-exploration/SKILL.md`. New error string `"fleet must be onStation to explore"` added to the exploration skill's error handling.

#### Starfighter Guaranteed Shots

- New struct-type fields `primaryWeaponGuaranteedShots` and `secondaryWeaponGuaranteedShots` documented in `knowledge/entities/struct-types.md`. Starfighter's secondary weapon is set to `1` guaranteed shot.
- `knowledge/mechanics/combat.md` Multi-Shot Damage section explains how `weaponGuaranteedShots` provides a floor of successful hits per volley before probabilistic rolls.

#### Streaming and Events

- `api/streaming/event-types.md` and `api/streaming/event-schemas.md` updated:
  - `PlayerMetaEvent` now carries `username` and `pfp` (chain is sole source of truth as of v0.16.0).
  - `GuildMetaEvent` now carries `pfp` in addition to `name`.
  - New section/schema for the **Cosmos chain** `ugc_moderated` event with attribute schema and emission rules. (Not delivered through GRASS -- subscribe via Tendermint event subscriptions.)
- `.cursor/skills/structs-streaming/SKILL.md` got a "UGC Moderation Events" section explaining the two streams (GRASS DB-trigger meta events vs. the chain `ugc_moderated` event) and the "actor != owner" emission condition.

#### Database Schema (Quantillia / structs-pg)

- `knowledge/infrastructure/database-schema.md` updated:
  - New rows for `structs.guild_meta` (now with `pfp`), `structs.player_meta` (PK collapsed from `(id, guild_id)` to `(id)` -- one row per player; webapp no longer writes meta directly), `structs.substation` (with `name` and `pfp`), and `structs.planet_meta` (chain-only updates, never overwritten by empty values).
  - New `signer.signer_tx_type` enum values for the seven UGC transactions.
  - 12 new `signer.tx_*` wrappers documented (7 self-service + 5 guild moderation).
  - `signer.UPDATE_PENDING_ACCOUNT` bumped to `PermAll = 33554431`.
  - `PLAYER_PENDING_JOIN_PROXY` trigger now threads `playerName`/`playerPfp` into the `ugc` JSONB; `PLAYER_PENDING_MERGE` no longer writes `player_meta`.

#### Webapp API

- `PUT /api/player/username` removed in v0.16.0. Username and PFP are now updated via the chain `MsgPlayerUpdate*` transactions; the webapp's signing client manager queues them through `queueMsgPlayerUpdateName` / `queueMsgPlayerUpdatePfp`. Updated: `api/endpoints.md`, `api/endpoints-by-entity.md`, `api/webapp/player.md`, `api/rate-limits.md`, `schemas/requests.md`.
- New `queueMsg*` wrappers (10 new entries) added to the webapp registry alongside `MsgGuildMembershipJoinProxy`'s expanded args; `queueMsgBankSend` removed (no callers).

#### Build System

- **structsd-install skill rewritten**: switched from Ignite-based builds to two supported paths -- (A) prebuilt release binaries from <https://github.com/playstructs/structsd/releases>, or (B) build from source via the Makefile (`make install` / `make build`). Go 1.23+ now required (was 1.24.1). Ignite is only needed for local devnet (`make serve`).
- Cross-compilation targets documented (`build-linux-amd64`, `build-darwin-arm64`, ..., `build-all`).

#### Top-Level / Indices

- `AGENTS.md`, `SITEMAP.md`, `llms.txt`, and `TOOLS.md` updated to reflect the new structsd-install description.
- `scripts/generate-llms-full.sh` includes `knowledge/mechanics/transactions.md` and `knowledge/mechanics/ugc-moderation.md`. `llms-full.txt` regenerated.

---

## [1.6.0] - 2026-03-26

### Added - v0.15.0-beta (Pyrexnar) / structstestnet-111

Major update incorporating all changes from Structs v0.15.0-beta (codenamed Pyrexnar) on the structstestnet-111 network. v0.14.0-beta (Opheliora) was a botched release; v0.15.0-beta (Pyrexnar) supersedes it with proxy join and test fixes.

#### Permission System Overhaul (8-bit -> 24-bit)

- **NEW: `knowledge/mechanics/permissions.md`** -- Comprehensive permission reference combining the Permission System, Guild Rank Permission System, and Message Handler Permission Reference. Covers all 24 permission bits, composite masks, storage format, check flow, and every handler's permission requirements.
- Permissions expanded from 8 flags (PermAll=255) to 24 flags (PermAll=16777215) with HasAll semantics (all required bits must be present)
- Old struct-specific permissions removed in favor of new fine-grained flags: PermTokenTransfer, PermTokenInfuse, PermTokenMigrate, PermTokenDefuse, PermSourceAllocation, PermGuildMembership, PermSubstationConnection, PermAllocationConnection, PermGuildTokenBurn, PermGuildTokenMint, PermGuildEndpointUpdate, PermGuildJoinConstraintsUpdate, PermGuildSubstationUpdate, PermProviderWithdraw, PermProviderOpen, PermReactorGuildCreate, PermHashBuild, PermHashMine, PermHashRefine, PermHashRaid
- Guild Rank Permission System: rank-based access control where guild members receive permissions based on their numeric rank (lower = more privileged)
- New transactions: `permission-guild-rank-set`, `permission-guild-rank-revoke`, `player-update-guild-rank`
- New queries: `guild-rank-permission-by-object`, `guild-rank-permission-by-object-and-guild`
- All examples, troubleshooting, patterns, and reference files updated with 24-bit values

#### Combat Engine Rewrite

- Attack resolution centralized into AttackContext with typed result structs
- Counter-attacks now fire at most once per `struct-attack` invocation (not per shot)
- Defender counter-attack fires before block and on evaded shots
- Target counter-attack fires after all shots resolve; destroyed targets cannot counter
- Block does NOT fire on evaded shots
- Each projectile gets its own EventAttackShotDetail row (per-projectile events)
- `targetPlayerId` moved from EventAttackDetail to EventAttackShotDetail (API-breaking)
- Planetary Defense Cannon now correctly reports when cannons fire; multiple PDCs stack
- EvadedCause only set on successful evasion

#### Allocation System Rework

- `controller` field is now PlayerId (not address) -- account abstraction
- `locked` column removed from allocation table
- Source capacity underloads properly guarded
- `provider-guild-grant` and `provider-guild-revoke` transactions removed; replaced by guild rank permissions (`permission-guild-rank-set` with PermProviderOpen on the provider)

#### New Entity Fields

- Guild: `entryRank` (uint64) -- default rank for new members (chain default: 101)
- Player: `guildRank` (uint64) -- rank within guild (1 = creator, 101 = default on join)
- Reactor: `owner` (string) -- PlayerId of reactor owner

#### New/Changed Transactions

- Added: `guild-create` (from reactor), `guild-update-entry-rank`, `player-update-guild-rank`, `player-send`, `permission-guild-rank-set`, `permission-guild-rank-revoke`
- Removed: `provider-guild-grant`, `provider-guild-revoke`
- Changed args: `player-update-primary-address` (removed playerId), `address-register` (removed playerId)

#### Database Schema

- New table: `structs.permission_guild_rank` (object_id, guild_id, permission, rank)
- New columns: `guild.entry_rank`, `player.guild_rank`, `reactor.owner`
- Removed column: `allocation.locked`
- New event: `EventGuildRankPermission`
- Cache handler updates for all affected entities
- Permission views rewritten for 24-bit flags

### Updated Files

- `knowledge/mechanics/permissions.md` -- NEW
- `knowledge/mechanics/combat.md` -- Attack resolution rewrite, counter-attack overhaul, PDC fix, per-projectile events
- `knowledge/mechanics/index.md` -- Permissions entry
- `knowledge/economy/energy-market.md` -- Controller=PlayerId, provider access via guild rank
- `knowledge/infrastructure/database-schema.md` -- New tables, columns, removed locked
- `schemas/entities/allocation.md` -- Controller=PlayerId, removed locked
- `schemas/entities/guild.md` -- entryRank field
- `schemas/entities/player.md` -- guildRank field
- `schemas/entities/reactor.md` -- owner field
- `schemas/entities.md` -- 24-bit permission flags
- `schemas/game-state.md` -- 24-bit permission flags
- `schemas/actions.md` -- New transactions, updated requirements
- `reference/action-quick-reference.md` -- New actions, permission/allocation/provider sections
- `reference/entity-index.md` -- New fields, 24-bit perms
- `reference/gameplay-index.md` -- Counter-attack mechanics
- `api/queries/permission.md` -- Guild rank queries
- `api/queries/guild.md` -- entryRank
- `api/queries/player.md` -- guildRank
- `api/queries/reactor.md` -- owner
- `api/streaming/event-types.md` -- EventGuildRankPermission
- `api/streaming/event-schemas.md` -- EventGuildRankPermission, targetPlayerId move
- `api/endpoints.md` -- Guild rank permission endpoints
- `api/endpoints-by-entity.md` -- Guild rank permission queries
- `.cursor/skills/structs-combat/SKILL.md` -- Counter-attack rules, PDC notes
- `.cursor/skills/structs-economy/SKILL.md` -- Controller=PlayerId, provider access
- `.cursor/skills/structs-energy/SKILL.md` -- Guild rank provider access
- `.cursor/skills/structs-power/SKILL.md` -- Controller=PlayerId
- `.cursor/skills/structs-diplomacy/SKILL.md` -- 24-bit perms, guild rank commands, arg changes
- `.cursor/skills/structs-guild/SKILL.md` -- guild-create, rank system, provider access
- `.cursor/skills/structs-onboarding/SKILL.md` -- Guild rank note
- `troubleshooting/permission-issues.md` -- 24-bit perms, HasAll, guild rank
- `troubleshooting/edge-cases.md` -- 24-bit perms
- `examples/auth/permission-examples.md` -- 24-bit perms, guild rank examples
- `examples/workflows/permission-checking.md` -- 24-bit perms, guild rank step
- `examples/database/query-examples.md` -- 24-bit perms
- `examples/gameplay-combat-bot.md` -- Per-projectile events, counter-attack
- `protocols/gameplay-protocol.md` -- Combat mechanics, battleDetails
- `patterns/performance-optimization.md` -- 24-bit bitwise checks
- `patterns/decision-tree-combat.md` -- Combat resolution order
- `AGENTS.md` -- Permissions in Knowledge section
- `SITEMAP.md` -- permissions.md entry
- `llms.txt` -- permissions.md entry
- `sitemap.xml` -- permissions URL

---

## [1.5.0] - 2026-02-24

### Added - Async Agent Architecture

Major overhaul addressing PoW timing and async operations, based on agent field experience:

- **NEW: `awareness/async-operations.md`** -- Core document teaching agents the async pattern: pipeline strategy, background PoW management, job/charge tracker templates, difficulty planning table, multi-player orchestration, ore vulnerability analysis.
- **Timing corrections across all docs** -- Previous estimates were wrong by 1-2 orders of magnitude. Mining takes ~8 hours (D=8) not ~15-30 min. Refining takes ~15 hours (D=8) not ~30-45 min. All skills and mechanics docs updated with correct calculations.
- **Difficulty cliff documented** -- D=8 to D=9 cliff is the most important tactical fact in PoW. Hash is instant at D<=8, impossible at D>=9. Recommended `-D 8` for all operations.
- **Game loop updated** -- Added "Check Jobs" (step 0) and "Dispatch" step. Renamed "Passive" tempo to "Pipeline" mode.
- **Playbooks reframed** -- Early game changed from "First 30 minutes" to "First 1-2 days". Build order updated with pipeline strategy. Mid-game and tempo docs updated with realistic multi-day timelines.
- **Ore vulnerability window** -- New section in `resources.md`: ore is stealable for ~15-24 hours between mining and refining completion. Primary driver of PvP conflict.
- **Context handoff expanded** -- Templates now include Active PoW Jobs, Pending Initiations, and Charge Status sections.
- **Continuity updated** -- Memory file list includes `jobs.md`, `charge-tracker.md`, `game-state.md`. Session resume checks jobs first.
- **Critical rule #5** -- "Never block on PoW" added to AGENTS.md.
- **`llms.txt` and `llms-full.txt` updated** -- New async-operations entry, corrected descriptions, regenerated full text.

### Updated Files

- `awareness/async-operations.md` -- NEW
- `knowledge/mechanics/building.md` -- Difficulty decay table, cliff, charge costs, async cross-reference
- `knowledge/mechanics/resources.md` -- PoW timing table, ore vulnerability window
- `.cursor/skills/structs-onboarding/SKILL.md` -- Correct timing, async strategy, D=8 recommendation
- `.cursor/skills/structs-building/SKILL.md` -- Correct timing, async cross-reference
- `.cursor/skills/structs-mining/SKILL.md` -- Multi-hour timing, pipeline strategy
- `.cursor/skills/structs-combat/SKILL.md` -- Background raid compute, fleet lock note
- `awareness/game-loop.md` -- Async loop, pipeline tempo mode
- `awareness/context-handoff.md` -- Job state in handoff template
- `awareness/continuity.md` -- Memory file list expanded
- `playbooks/phases/early-game.md` -- Reframed to 1-2 days, pipeline build order
- `playbooks/phases/mid-game.md` -- Days/weeks timeline
- `playbooks/meta/tempo.md` -- Tempo through parallelism section
- `AGENTS.md` -- Async-operations in awareness, timeline fix, rule #5
- `llms.txt` -- Async-operations entry, corrected descriptions
- `scripts/generate-llms-full.sh` -- Added async-operations.md
- `llms-full.txt` -- Regenerated
- `awareness/index.md` -- Async-operations entry
- `playbooks/phases/index.md` -- Timeline fix
- `reference/gameplay-index.md` -- Timeline fix

---

## [1.4.0] - 2026-02-24

### Fixed - Agent Operational Documentation

Addressed 10 issues reported by an AI agent during first play session:

- **Struct type IDs corrected** -- Command Ship is type 1 (was incorrectly listed as 14), Ore Extractor is type 14. All skills now use explicit, verified type IDs.
- **Complete struct type table** -- All 22 struct types added to `knowledge/entities/struct-types.md` with DB-verified stats: ID, category, build difficulty, build/passive draw, max HP, and possible ambit.
- **Ambit bit-flag encoding documented** -- Space=16, Air=8, Land=4, Water=2. Added to struct-types, building mechanics, and onboarding skill.
- **Compute vs Complete clarified** -- `struct-build-compute` (and mine-compute, refine-compute, raid-compute) are helpers that calculate the hash AND auto-submit the complete transaction. Documented across all skills and building mechanics.
- **-D flag documented** -- Range 1-64, waits until difficulty drops to target level before hashing. Recommended `-D 5` for most operations. Added to building, mining, combat skills, and building mechanics.
- **Timing expectations added** -- Every skill now includes approximate durations. Build times range from ~2-5 min (Command Ship) to ~45-60 min (World Engine). Mine ~15-30 min, refine ~30-45 min.
- **`player-me` replaced** -- All references replaced with `structsd query structs address [address]`. Note: player ID `1-0` means nonexistent.
- **New player power budget** -- Added to `knowledge/mechanics/power.md`. Documents cumulative load through onboarding build order, minimum viable capacity (~575 kW).
- **TOOLS.md improved** -- Added deployment options, placeholder guidance, address query tip, MCP parameter reference.

### Fixed - MCP Query Tools

- **Parameter bug resolved** -- MCP query tools now accept both entity-specific parameters (`player_id`, `planet_id`, etc.) and generic `id` as an alias.
- **Root cause** -- Callers using generic `id` left entity-specific params undefined, causing crash in `validateEntityId`. Server now guards against undefined/null/non-string IDs.
- **MCP query parameter reference** added to `TOOLS.md` with correct parameter names and examples for all 10 query tools.

### Updated Files

- `.cursor/skills/structs-onboarding/SKILL.md` -- Rewrote: correct type IDs, address query, -D flag, timing, ambit encoding
- `.cursor/skills/structs-building/SKILL.md` -- Compute/complete clarification, -D flag, build time table
- `.cursor/skills/structs-mining/SKILL.md` -- Compute auto-complete, timing section
- `.cursor/skills/structs-combat/SKILL.md` -- Raid compute auto-complete, -D flag, raid timing
- `.cursor/skills/structs-reconnaissance/SKILL.md` -- Address query pattern, 1-0 note
- `knowledge/mechanics/building.md` -- Build process, -D flag, timing, ambit encoding section
- `knowledge/entities/struct-types.md` -- Complete 22-type table, ambit encoding, combat stats
- `knowledge/mechanics/power.md` -- New player power budget section
- `TOOLS.md` -- Deployment, placeholders, MCP query parameter reference

---

## [1.3.0] - 2026-02-24

### Chain Releases Covered

- **v0.10.0-beta (Junctiondale)** -- Sticky State (partial; some items in 1.2.0)
- **v0.11.0-beta (Luxoria)** -- IBC v10, SDK v0.53.5, open hashing, genesis improvements
- **v0.12.0-beta (Mystigon)** -- Context Manager refactor, combat fixes, raid improvements
- **v0.13.0-beta (Nebulon)** -- Indexer commit order fix

### Changed - Combat Mechanics

- **Minimum damage floor** (v0.12.0-beta)
  - After damage reduction, minimum damage is now 1 -- attacks always deal at least 1 damage
  - Updated `knowledge/mechanics/combat.md` with minimum damage edge case

- **Offline counter-attack fix** (v0.12.0-beta)
  - Offline/destroyed structs can no longer counter-attack
  - Counter-attack now requires full readiness check including weapon system validation
  - Updated `knowledge/mechanics/combat.md` counter-attack section

- **Attack health results** (v0.11.0-beta)
  - Attack events now include remaining health values in addition to damage amounts
  - Updated `knowledge/mechanics/combat.md` algorithm description

- **Multi-commit prevention** (v0.11.0-beta)
  - Each struct can only commit once per attack action (prevents double-commit on same target)
  - Updated `knowledge/mechanics/combat.md` edge cases

- **Target struct validation** (v0.11.0-beta)
  - Target struct existence is now validated before attack proceeds
  - Updated `knowledge/mechanics/combat.md` edge cases

### Added - Raid Improvements

- **Seized ore tracking** (v0.12.0-beta)
  - `seized_ore` (numeric) field added to `planet_raid` table
  - Tracks total ore stolen during a raid for easier victory handling
  - Updated `schemas/entities/planet.md` with `planet_raid` table schema
  - Updated `knowledge/mechanics/planet.md` raid vulnerability section
  - Updated `knowledge/mechanics/combat.md` outcomes section

### Changed - Building & Hashing

- **Open hashing by default** (v0.11.0-beta)
  - All proof-of-work operations (build, mine, refine, raid) now accept hashes openly
  - Zero-block hashing results handled correctly post-migration
  - Updated `knowledge/mechanics/building.md` proof-of-work section

### Changed - Fleet Movement

- **Fleet movement readiness fix** (v0.12.0-beta)
  - Fixed `MoveReadiness` bug that erroneously checked for fleet-away status
  - Fixed error on fleet movement to populated planet
  - Updated `knowledge/mechanics/fleet.md` fleet movement section

### Added - Struct Fields

- **`destroyed_block` field** (v0.12.0-beta)
  - `destroyed_block` (bigint) added to struct table -- records block height of destruction
  - Updated `schemas/entities/struct.md` with new field
  - Updated `knowledge/mechanics/building.md` StructSweepDelay note
  - Corrected existing `destroyed` field: DB column is actually `is_destroyed` (boolean)

### Added - Provider Guild Access

- **`ProviderGuildAccessRecord`** (v0.12.0-beta)
  - New protobuf message for provider-guild access tracking
  - Fields: `providerId`, `guildId`
  - Used for genesis import/export of provider access policies
  - Updated `schemas/entities/provider.md`

### Changed - Internal Architecture (v0.11.0-v0.12.0)

- **Cosmos SDK v0.53.5 and IBC v10 upgrade** (v0.11.0-beta)
- **General Context Manager** (v0.12.0-beta) -- major keeper refactoring introducing `*_context.go` files for all entity types
- **Structured error types** (v0.11.0-beta) -- migrated error handling to structured error types
- **Improved genesis import/export** (v0.11.0-beta) -- allocation count, reactor index, index rebuild, block attribute resets
- **Object deletion consistency** (v0.11.0-beta) -- resolved inconsistencies in object deletion
- **Indexer commit order fix** (v0.13.0-beta) -- attributes now committed after objects to prevent indexer cascading failures

### Added - Database Schema Changes

- **`struct.destroyed_block`** (bigint) -- block height of destruction (2026-02-07)
- **`planet_raid.seized_ore`** (numeric) -- ore seized during raids (2026-02-21)
- **`struct_health`** added to `grass_category` enum for planet activity events (2026-01-15)
- **`handle_event_struct_defender_clear`** cache function (2026-01-11)
- **`player_address_cascade`** trigger on player table for onboarding (2026-02-23)
- **Cache system refactor** (2026-01-21) -- 41 handler functions in cache schema
- **`view.work` zero-block fix** (2026-01-19)
- **Player insert trigger fix** for guild association (2026-01-23)
- **Defender clear caching** -- multiple iterations fixing defender removal event processing (2026-01-11 through 2026-01-18)
- **Zero-value attribute cleanup** in cache handlers (2026-02-03)
- See `schemas/database-schema.md` for complete migration log

### Added - Webapp Features (PRs #16-#40)

- **Struct actions UI** -- move (#29-#30), defend (#32), attack (#37-#38), stealth (#28)
- **Raid end dialogues** (#39) -- victory/defeat notification sequences with Lottie animations
- **Struct HUD** (#27) -- struct status display with real-time updates
- **Progress estimations** (#16) -- estimated completion times for proof-of-work tasks
- **Signing Manager** cleanup (#20) and TX response logging (#31)
- **Key player refactor** (#22-#23) -- improved player state management
- **Command Ship loading** during planet exploration (#25)
- **Map rendering fixes** (#35-#36) -- struct rendering on preview map, raid enemy map display
- **Planet depart button** fix and messaging update (#40)
- **Gameplay bug fixes** (#33-#34) -- action bar visibility, various gameplay issues

### Updated - Documentation Files

- `schemas/database-schema.md` -- v0.10.0-v0.13.0 changelog, database schemas overview, verified table/view/trigger definitions
- `schemas/entities/struct.md` -- `destroyed_block` field, corrected `is_destroyed` column name, updated verification
- `schemas/entities/planet.md` -- planet view fields, `planet_raid` table, `seized_ore`, updated verification
- `schemas/entities/provider.md` -- `ProviderGuildAccessRecord`
- `knowledge/mechanics/combat.md` -- minimum damage, counter-attack fixes, seizedOre, health results, edge cases
- `knowledge/mechanics/fleet.md` -- movement readiness fix, populated planet fix
- `knowledge/mechanics/building.md` -- open hashing, destroyed_block in sweep delay
- `knowledge/mechanics/planet.md` -- seized ore tracking in raids
- `.cursor/skills/structs-combat/SKILL.md` -- combat notes, verification updates

---

## [1.2.0] - 2026-01-16

### Added - Streaming Events

- **Struct Defender Clear Event** (v0.10.0-beta)
  - Added `struct_defender_clear` to streaming event types
  - Updated GRASS event category list to include defender-clear events

### Added - Genesis Operations

- **Genesis Import/Export Notes** (v0.10.0-beta)
  - Added operator notes for import/export completeness changes
  - Documented allocation count, reactor index, and index rebuild behavior

### Changed - Action Requirements

- **Struct Activate Charge** (v0.10.0-beta)
  - Documented `activateCharge = 1` for all struct types in genesis
  - Updated action quick reference charge guidance

- **Build Cancel Requirements** (v0.10.0-beta)
  - Documented that build cancel no longer requires charge or player online

### Changed - Onboarding & Command Ship

- **Initial Command Ship Grant** (v0.10.0-beta)
  - Documented initial Command Ship grant at player creation
  - Updated onboarding flow to verify existing Command Ship and activate if offline

## [1.1.0] - 2026-01-01

### Added - Permissions

- **Hash Permission** (v0.8.0-beta)
  - Added new Hash permission bit to permission system
  - Permission values are bit-based flags that can be combined
  - Hash permission bit value: 64
  - Updated `schemas/game-state.md` with permission bit documentation
  - See `schemas/game-state.md#/definitions/Permission` for details

### Added - Combat & Raids

- **New Raid Status: `attackerRetreated`** (v0.8.0-beta)
  - Added `attackerRetreated` status to raid outcome enum in `schemas/gameplay.md`
  - Updated `api/streaming/event-schemas.md` to include attackerRetreated in PlanetRaidStatusEvent
  - Documented new status in `protocols/gameplay-protocol.md`
  - Updated `examples/gameplay-combat-bot.md` to handle attackerRetreated status
  - Status indicates attacker retreated from raid before completion
  - No resources gained or lost when attacker retreats

### Added - Reactor Staking & Validation Delegation

- **Reactor Staking Functionality** (v0.8.0-beta)
  - Added reactor staking fields to `schemas/entities/reactor.md`
  - Documented player-level staking management
  - Added staking delegation statuses: `active`, `undelegating`, `migrating`
  - Updated `schemas/economics.md` with reactor staking section
  - Updated `reference/entity-index.md` with staking information

- **Validation Delegation Actions** (v0.8.0-beta)
  - Updated `MsgReactorInfuse` to handle validation delegation
  - Updated `MsgReactorDefuse` to handle validation undelegation
  - Added `MsgReactorBeginMigration` action for redelegation
  - Added `MsgReactorCancelDefusion` action to cancel undelegation
  - All actions documented in `schemas/actions.md`
  - Added comprehensive workflow examples in `protocols/economic-protocol.md`
  - Added reactor staking examples to `examples/economic-bot.md`

### Added - Struct Lifecycle

- **StructSweepDelay** (v0.8.0-beta)
  - Added block-based delay (5 blocks) for struct sweeping
  - Documented in `lifecycles/struct-lifecycle.md`
  - Added constant to `schemas/gameplay.md`
  - Planet/fleet slot references persist during delay period
  - Slots fully cleared after 5 blocks

### Changed - Fleet Movement

- **Fleet Movement Improvements** (v0.8.0-beta)
  - Updated `lifecycles/fleet-lifecycle.md` with bug fix documentation
  - Improved fleet movement logic and validation
  - Better error handling for invalid movements
  - More reliable fleet status transitions

### Changed - Membership Join Process

- **Streamlined Redelegation** (v0.8.0-beta)
  - Updated `protocols/economic-protocol.md` with membership join improvements
  - Staked assets automatically redelegated during migration
  - Streamlined process for joining guilds

### Fixed - Bug Resolutions

- **GetInfusionByID Array Split Bug** (v0.8.0-beta)
  - Bug in GetInfusionByID array split logic resolved
  - Documented in `schemas/errors.md` and `troubleshooting/common-issues.md`

- **EventGuildBankAddress Format Bug** (v0.8.0-beta)
  - Bug in EventGuildBankAddress format resolved
  - Documented in `schemas/errors.md` and `troubleshooting/common-issues.md`

- **BankAddress Format Logging Bug** (v0.8.0-beta)
  - Bug in BankAddress format logging resolved
  - Documented in `schemas/errors.md` and `troubleshooting/common-issues.md`

### Updated - Documentation

- **Version Updates**
  - Updated version numbers to 1.1.0 in all major schema files
  - Updated `AGENTS.md` version and last updated date
  - Updated `DOCUMENTATION_INDEX.md` version and last updated date
  - Updated `reference/action-quick-reference.md` with new actions

- **Quick References**
  - Updated `reference/action-quick-reference.md` with reactor staking actions
  - Added documentation for new validation delegation actions
  - Updated combat/raid quick reference with attackerRetreated status
  - Updated `reference/entity-index.md` with Hash permission information

- **Examples**
  - Updated `examples/gameplay-combat-bot.md` with attackerRetreated handling
  - Added reactor staking workflow to `examples/economic-bot.md`
  - Updated version to 1.1.0 in economic bot example

- **Error Handling**
  - Added resolved bugs section to `troubleshooting/common-issues.md`
  - Updated `schemas/errors.md` with v0.8.0-beta resolved bugs metadata
  - Documented all resolved bugs from v0.8.0-beta

### Added - Database Schema

- **Database Schema Documentation** (v0.8.0-beta)
  - Created `schemas/database-schema.md` documenting PostgreSQL schema changes
  - Documented all structs-pg repository changes from November-December 2025
  - See `schemas/database-schema.md` for complete database change log

- **Struct Table Changes** (v0.8.0-beta)
  - Added `destroyed` column to struct table (2025-12-29)
  - Tracks struct destruction status
  - Related to StructSweepDelay (5 blocks) - destroyed structs persist for 5 blocks
  - Updated `schemas/entities/struct.md` with destroyed field

- **Struct Type Table Changes** (v0.8.0-beta)
  - Added `cheatsheet_details` column (2025-11-29)
  - Added `cheatsheet_extended_details` column (2025-12-02)
  - Removed deprecated charge columns for mine and refine (2025-12-08)
  - Updated `schemas/entities/struct-type.md` with database change metadata

- **Permission System Database Changes** (v0.8.0-beta)
  - Added `permission_hash` level to permission view (2025-12-18)
  - Updated signer_tx table to support Hash permission (2025-12-18)
  - Added permissions column to player_address_pending table (2025-12-29)
  - Maps to Hash permission bit (value 64) in API layer

- **Transaction Signing Changes** (v0.8.0-beta)
  - Fixed Hash Complete nonces: INTEGER → CHARACTER VARYING (2025-12-15)
  - Updated transaction signing permission levels (2025-12-18)
  - Added new transaction types (2025-12-18)
  - Fixed signer account bug (2025-12-29)

- **View Improvements** (v0.8.0-beta)
  - Fixed raid logic in view.work (2025-12-13)
  - Improved exclusion logic to exclude impossible tasks (2025-12-27)
  - Removed deprecated charge columns from views (2025-12-08)

- **Cache and Trigger Updates** (v0.8.0-beta)
  - Fixed struct type cache commit (2025-12-18)
  - Fixed GRASS grid p values (2025-12-19)
  - Updated cache triggers for deprecated column removal (2025-12-08)

### Technical Details

- **Schema Changes**
  - `schemas/game-state.md`: Added Hash permission bit (64) documentation
  - `schemas/gameplay.md`: Added attackerRetreated status, StructSweepDelay constant
  - `schemas/entities/reactor.md`: Added staking fields and delegation properties
  - `schemas/entities.md`: Updated Permission entity with Hash permission info
  - `schemas/entities/struct.md`: Added destroyed field, updated version to 1.1.0
  - `schemas/entities/struct-type.md`: Added database change metadata, updated version to 1.1.0
  - `schemas/actions.md`: Updated Reactor Infuse/Defuse, added Begin Migration/Cancel Defusion
  - `schemas/economics.md`: Added reactor staking section
  - `schemas/errors.md`: Added v0.8.0-beta resolved bugs metadata
  - `schemas/database-schema.md`: New file documenting PostgreSQL schema changes

- **Protocol Updates**
  - `protocols/gameplay-protocol.md`: Added attackerRetreated status documentation
  - `protocols/economic-protocol.md`: Added reactor staking and validation delegation sections

- **Lifecycle Updates**
  - `lifecycles/struct-lifecycle.md`: Documented StructSweepDelay
  - `lifecycles/fleet-lifecycle.md`: Documented fleet movement improvements

---

## [1.0.0] - 2025-12-07

### Initial Release

- Comprehensive AI agent documentation
- Complete schema definitions
- Protocol documentation
- Example implementations
- Quick reference guides

---

## Version History

- **1.6.0** (2026-03-26): v0.15.0-beta (Pyrexnar) / structstestnet-111 -- Permission system overhaul (8-bit to 24-bit, guild rank permissions, HasAll semantics), combat engine rewrite (counter-attack limits, per-projectile events), allocation rework (controller=PlayerId, removed locked), new entity fields, new/changed/removed transactions, database schema updates. ~48 files updated, 1 new. Supersedes v0.14.0-beta (Opheliora).
- **1.4.0** (2026-02-24): Agent feedback fixes - Corrected struct type IDs, documented compute/complete workflow, -D flag, timing expectations, ambit encoding, new player power budget. MCP query tool parameter fix and documentation.
- **1.3.0** (2026-02-24): v0.10.0-v0.13.0-beta updates - Combat fixes (minimum damage, counter-attack), seized ore tracking, open hashing, destroyed_block, fleet movement fix, Context Manager refactor, SDK v0.53.5/IBC v10, database schema updates, webapp struct actions UI
- **1.2.0** (2026-01-16): v0.10.0-beta updates - Defender clear event, genesis import/export, activate charge, build cancel, initial Command Ship grant
- **1.1.0** (2026-01-01): v0.8.0-beta updates - Hash permission, reactor staking, attackerRetreated status, struct sweep delay, database schema changes, bug fixes
- **1.0.0** (2025-12-07): Initial release

---

*For detailed information about each change, see the relevant documentation files.*

