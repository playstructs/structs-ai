# Structs Database Schema

**Category**: database
**Source**: https://github.com/playstructs/structs-pg
**Last Updated**: 2026-05-29
**Description**: Authoritative structural catalog of the Structs Guild Stack PostgreSQL schema. Mirrors [`playstructs/structs-pg`](https://github.com/playstructs/structs-pg) as deployed by Sqitch.

For query patterns, grid gotchas, and agent-ready SQL examples, see [`knowledge/infrastructure/database-schema.md`](../knowledge/infrastructure/database-schema.md).

---

## Database Info

| Property | Value |
|----------|-------|
| Name | `structs` |
| Engine | PostgreSQL 17 + TimescaleDB |
| Management | Sqitch (`sqitch` schema) |
| Repository | https://github.com/playstructs/structs-pg |
| Ingestion | `structs-sync-state` (polls chain RPC; writes `structs.*` and `sync_state.*`) |

Chain events are **not** ingested by `structsd`. The `structs-sync-state` service owns block-by-block indexing.

---

## Schema Overview

| Schema | Purpose |
|--------|---------|
| `structs` | Core game state (~50 tables) |
| `sync_state` | Chain indexer state: sync cursor, block log, raw chain data, handler errors |
| `cache` | Four **read-only compatibility views** over `sync_state.raw_*` (legacy webapp shim) |
| `view` | Computed views — entity projections, permissions, work queue, leaderboards |
| `signer` | Transaction Signing Agent (TSA) queue — roles, accounts, pending txs |
| `sqitch` | Migration tracking |

---

## Database Roles

| Role | Access | Used By |
|------|--------|---------|
| `structs` | Owner / superuser | Administration, Sqitch migrations |
| `structs_indexer` | Read/write on `structs.*`, `sync_state.*`; SELECT on `cache.*` views | `structs-sync-state`, `structs-grass` |
| `structs_webapp` | Read/write on most `structs.*`; full on `signer.*`; SELECT on `cache.*` views | Webapp, TSA |
| `structs_crawler` | Read-only on select `structs.*` tables | Crawler |

For agent queries, connect as `structs_indexer` via the GRASS container (see `.cursor/skills/structs-guild-stack/SKILL.md`).

---

## Enums

### `structs.grass_category`

Activity category enum on `structs.planet_activity.category`.

| Value | Notes |
|-------|-------|
| `block` | New block committed |
| `guild_consensus` | Guild state changes |
| `guild_meta` | Off-chain guild metadata updates |
| `guild_membership` | Membership changes |
| `raid_status` | Raid initiated / completed / failed |
| `fleet_arrive` | Fleet arrived at planet |
| `fleet_advance` | Fleet movement in progress |
| `fleet_depart` | Fleet departed |
| `struct_attack` | Combat attack |
| `struct_defense_add` | Defense assignment added |
| `struct_defense_remove` | Defense assignment removed |
| `struct_status` | Struct status change (online / offline / destroyed) |
| `struct_move` | Struct moved between slots / ambits |
| `struct_block_build_start` | Build PoW started |
| `struct_block_ore_mine_start` | Mining PoW started |
| `struct_block_ore_refine_start` | Refining PoW started |
| `struct_health` | Struct health changed |
| `player_consensus` | Player state changes (**including UGC `username` / `pfp` updates**) |

### Other notable enums

| Enum | Schema | Values (summary) |
|------|--------|------------------|
| `object_type` | `structs` | `guild`, `player`, `planet`, `reactor`, `substation`, `struct`, `allocation`, `infusion`, `address`, `fleet`, `provider`, `agreement` |
| `signer_tx_status` | `structs` | `pending`, `claimed`, `broadcast`, `error` |
| `signer_tx_module` | `structs` | `structs`, `bank`, `staking`, `auth`, `authz` |
| `signer_tx_type` | `structs` | 100+ command types (see `signer.tx.command`) |

UGC-related `signer_tx_type` values: `player-update-name`, `player-update-pfp`, `guild-update-name`, `guild-update-pfp`, `planet-update-name`, `substation-update-name`, `substation-update-pfp`.

---

## `structs` Schema

### Table Index

| Group | Tables |
|-------|--------|
| **Core entities** | `player`, `planet`, `fleet`, `struct`, `struct_type`, `guild`, `guild_meta`, `reactor`, `substation`, `allocation`, `infusion`, `provider`, `agreement` |
| **Attributes & grid** | `grid`, `struct_attribute`, `planet_attribute`, `struct_defender` |
| **Permissions** | `permission`, `permission_guild_rank` |
| **Planet activity** | `planet_activity`, `planet_activity_sequence`, `planet_raid` |
| **Player addresses** | `player_address`, `player_address_activity`, `player_address_meta`, `player_address_pending`, `player_address_activation_code`, `player_object` |
| **Onboarding / pending** | `player_pending`, `player_internal_pending`, `player_external_pending`, `guild_membership_application` |
| **Integrations** | `player_discord` |
| **Economy / ledger** | `ledger`, `defusion` |
| **Stats (TimescaleDB)** | `stat_ore`, `stat_fuel`, `stat_capacity`, `stat_load`, `stat_structs_load`, `stat_power`, `stat_connection_count`, `stat_connection_capacity`, `stat_struct_health`, `stat_struct_status` |
| **Config / moderation** | `setting`, `banned_word`, `address_tag`, `current_block` |

**Dropped tables** (migrated 2026-05-25): `player_meta` → columns on `player`; `planet_meta` → `name` on `planet`.

---

### `structs.player`

| Column | Type | Notes |
|--------|------|-------|
| `id` | varchar PK | `1-{index}` |
| `index` | integer | Numeric portion of ID |
| `guild_id` | varchar | Guild membership (`0-{index}`) |
| `guild_rank` | bigint | Rank within guild (1 = highest; 101 = default on join) |
| `substation_id` | varchar | Connected substation (`4-{index}`) |
| `planet_id` | varchar | Home planet (`2-{index}`) |
| `fleet_id` | varchar | Fleet (`9-{index}`) |
| `primary_address` | varchar | Cosmos address |
| `creator` | varchar | Creating address |
| `username` | varchar | Chain UGC display name |
| `pfp` | varchar | Chain UGC profile picture URI |
| `created_at` / `updated_at` | timestamptz | Row timestamps |

`player_meta` was dropped; `username` and `pfp` live directly on this table. Sync-state writes them from `MsgPlayerUpdateName` / `MsgPlayerUpdatePfp` or signup proxy fields.

---

### `structs.planet`

| Column | Type | Notes |
|--------|------|-------|
| `id` | varchar PK | `2-{index}` |
| `owner` | varchar | Player ID |
| `max_ore` | integer | Maximum ore capacity |
| `space_slots` / `air_slots` / `land_slots` / `water_slots` | integer | Slot counts per ambit |
| `status` | varchar | Planet status |
| `name` | text | Chain UGC display name |
| `seized_ore` | numeric | Cumulative ore seized across all raids |
| `map` | jsonb | Planet map data |
| `creator` | varchar | Creating address |
| `location_list_start` / `location_list_end` | varchar | Location list bounds |
| `created_at` / `updated_at` | timestamptz | Row timestamps |

`planet_meta` was dropped; `name` lives directly on this table.

Related: `planet_attribute` (key-value, e.g. `planetaryShield`), `planet_raid` (`planet_id` PK, `fleet_id`, `status`, `seized_ore` per raid).

---

### `structs.guild`

| Column | Type | Notes |
|--------|------|-------|
| `id` | varchar PK | `0-{index}` |
| `index` | integer | Numeric portion of ID |
| `name` | varchar | Chain UGC display name |
| `pfp` | varchar | Chain UGC profile picture URI |
| `entry_rank` | bigint | Default rank for new members |
| `endpoint` | varchar | Guild API endpoint |
| `join_infusion_minimum` | numeric | Generated from `join_infusion_minimum_p` |
| `join_infusion_minimum_p` | numeric | Raw infusion minimum |
| `primary_reactor_id` | varchar | Guild reactor |
| `entry_substation_id` | varchar | Default substation for new members |
| `creator` / `owner` | varchar | Addresses |
| `created_at` / `updated_at` | timestamptz | Row timestamps |

---

### `structs.guild_meta`

Off-chain guild configuration — **not** chain UGC name/pfp (those are on `structs.guild`).

| Column | Type | Notes |
|--------|------|-------|
| `id` | varchar PK | Guild ID (mirrors `structs.guild.id`) |
| `name` | varchar | Legacy display name (prefer `structs.guild.name` for on-chain UGC) |
| `description` | text | Guild description |
| `tag` | varchar | Short guild tag |
| `logo` | varchar | Logo URI |
| `socials` | jsonb | Social links |
| `denom` | jsonb | Guild token denomination map |
| `services` | jsonb | Guild API / GRASS / webapp endpoints |
| `domain` | varchar | Guild domain |
| `website` | varchar | Guild website |
| `base_energy` | numeric | Base energy allocation |
| `this_infrastructure` | boolean | Whether this guild stack hosts this guild's infra |
| `status` | varchar | Meta status |
| `created_at` / `updated_at` | timestamptz | Row timestamps |

`pfp` was removed from this table (2026-05-25); chain UGC lives on `structs.guild`.

---

### `structs.struct`

| Column | Type | Notes |
|--------|------|-------|
| `id` | varchar PK | `5-{index}` |
| `index` | integer | Numeric portion of ID |
| `type` | integer | FK to `struct_type.id` (1–22) |
| `owner` | varchar | Player ID |
| `creator` | varchar | Creating address |
| `location_type` | varchar | `fleet` or `planet` |
| `location_id` | varchar | Fleet or planet ID |
| `operating_ambit` | varchar | `space`, `air`, `land`, `water` |
| `slot` | integer | Position within ambit (0–3) |
| `is_destroyed` | boolean | Destruction state (default false) |
| `destroyed_block` | bigint | Block height when destroyed |
| `created_at` / `updated_at` | timestamptz | Row timestamps |

Related: `struct_attribute` (`health`, `status`, `protectedStructIndex`, …), `struct_defender` (`defending_struct_id` PK → `protected_struct_id`). Full balance data in `struct_type` (~60 columns — weapons, defense, charges, difficulties).

---

### `structs.fleet`

| Column | Type | Notes |
|--------|------|-------|
| `id` | varchar PK | `9-{index}` |
| `owner` | varchar | Player ID |
| `status` | varchar | `on_station`, `away` |
| `location_type` | varchar | `planet` |
| `location_id` | varchar | Planet ID where fleet is located |
| `command_struct` | varchar | Command Ship struct ID |
| `space_slots` / `air_slots` / `land_slots` / `water_slots` | integer | Available slots per ambit |
| `map` | jsonb | Fleet map data |
| `location_list_forward` / `location_list_backward` | varchar | Movement list bounds |
| `created_at` / `updated_at` | timestamptz | Row timestamps |

---

### `structs.grid`

Key-value store for resource attributes. **No dedicated `ore` column** — filter by `attribute_type`.

| Column | Type | Notes |
|--------|------|-------|
| `id` | varchar PK | Encoded `attribute_type-object_type-object_index` |
| `object_id` | varchar | Player, planet, struct, etc. ID |
| `object_type` | varchar | Entity type prefix |
| `object_index` | integer | Entity index |
| `attribute_type` | varchar | `ore`, `alpha`, `capacity`, `structsLoad`, `fuel`, `power`, … |
| `val` | numeric | Attribute value |
| `updated_at` | timestamptz | Last update |

---

### `structs.planet_activity`

TimescaleDB hypertable — planet-level event log (GRASS source).

| Column | Type | Notes |
|--------|------|-------|
| `time` | timestamptz | Event time (hypertable partition key) |
| `seq` | integer | Monotonic sequence per planet (high-water mark for polling) |
| `planet_id` | varchar | Planet where event occurred |
| `category` | `grass_category` | Event type (see enum above) |
| `detail` | jsonb | Event-specific payload |
| `block_height` | bigint | Block height when event occurred (populated by sync-state) |

#### Event categories (reference)

| Category | Description |
|----------|-------------|
| `block` | New block committed |
| `raid_status` | Raid initiated / completed / failed |
| `fleet_arrive` | Fleet arrived at planet |
| `fleet_advance` | Fleet movement in progress |
| `fleet_depart` | Fleet departed |
| `struct_attack` | Combat attack |
| `struct_defense_add` | Defense assignment added |
| `struct_defense_remove` | Defense assignment removed |
| `struct_status` | Struct status change |
| `struct_move` | Struct moved |
| `struct_block_build_start` | Build PoW started |
| `struct_block_ore_mine_start` | Mining PoW started |
| `struct_block_ore_refine_start` | Refining PoW started |
| `struct_health` | Struct health changed |
| `guild_consensus` | Guild state changes |
| `guild_meta` | Off-chain guild metadata |
| `guild_membership` | Membership changes |
| `player_consensus` | Player changes (including UGC) |

---

### Other `structs` tables (summary)

| Table | Key columns | Purpose |
|-------|-------------|---------|
| `permission` | `object_id`, `player_id`, `val` | Per-player permission bitmask on objects |
| `permission_guild_rank` | `object_id`, `guild_id`, `permission`, `rank` | Guild-rank permission grants (PK: object + guild + permission bit) |
| `reactor` | `id`, `guild_id`, `validator`, `owner` | Validator-linked energy production |
| `substation` | `id`, `owner`, `name`, `pfp` | Power distribution; chain UGC on `name` / `pfp` |
| `allocation` | `id`, `source_id`, `destination_id`, `controller` | Energy routing |
| `infusion` | `destination_id`, `address`, `fuel`, `power`, `commission` | Composite PK `(destination_id, address)` |
| `provider` | `id`, `rate_amount`, `rate_denom`, `access_policy` | Energy marketplace listings |
| `agreement` | `id`, provider/consumer refs, capacity, duration | Active purchase contracts |
| `ledger` | `time`, `address`, `amount`, `action`, `direction`, `denom` | Financial transaction log (hypertable) |
| `defusion` | `validator_address`, `delegator_address`, `amount`, `completes_at` | In-flight reactor unbonding |
| `setting` | `name` PK, `value` | Live tunables (`REACTOR_RATIO`, `PLANET_STARTING_ORE`, …) |
| `banned_word` | `word` PK | UGC name validation seed data |
| `address_tag` | `address`, `label`, `entry` | Labelled address records |
| `current_block` | `height`, `status`, `lag_blocks`, `tip_height` | Chain tip mirror (sync-state writes) |
| `player_pending` | `primary_address` PK, `username`, `pfp`, … | Signup queue |
| `player_address` | `address` PK, `player_id`, `guild_id`, `status` | Address ↔ player mapping |

Stat hypertables (`stat_*`) share the pattern: `time`, `object_type`, `object_index`, `value`, `block_height` — one table per metric (ore, capacity, fuel, load, power, struct health, etc.).

---

## `sync_state` Schema

Written by `structs-sync-state`. Operator and debugging tables.

| Table | Purpose | Key columns |
|-------|---------|-------------|
| `sync_cursor` | Per-chain ingest pointer | `chain_id` PK, `last_height`, `status`, `lag_blocks`, `tip_height`, `last_block_hash`, `last_block_time` |
| `block_log` | One row per ingested block | `chain_id`, `height`, `block_hash`, `num_txs`, `num_events`, `num_handler_errors` |
| `handler_error_log` | Per-event handler failures | `chain_id`, `height`, `composite_key`, `error`, `severity`, `resolved_at` |
| `raw_blocks` | Raw block mirror | `chain_id`, `height`, `block_time` |
| `raw_tx_results` | Raw tx mirror | `height`, `tx_index`, `tx_hash` |
| `raw_events` | Raw event mirror | `height`, `tx_index`, `event_index`, `event_type` |
| `raw_attributes` | Raw attribute mirror | `height`, `tx_index`, `event_index`, `key`, `composite_key`, `value` |
| `verification_report` | Output of `sync-state verify` runs | `run_id`, `scope`, `status`, `expected`, `actual` |
| `genesis_log` | Genesis import audit trail | Genesis-state snapshots |
| `unknown_event_log` | Unrecognized event types | Debugging unhandled chain events |

Monitor indexer health:

```sql
SELECT chain_id, last_height, status, lag_blocks, tip_height
FROM sync_state.sync_cursor;
```

---

## `cache` Schema

Read-only compatibility layer over `sync_state.raw_*`. `cache` consists of four views.

| View | Source | Notes |
|------|--------|-------|
| `cache.blocks` | `sync_state.raw_blocks` | `rowid` = `height` |
| `cache.tx_results` | `sync_state.raw_tx_results` | `tx_result` is permanently NULL (protobuf not captured) |
| `cache.events` | `sync_state.raw_events` | Surrogate `rowid` from height + tx_index + event_index |
| `cache.attributes` | `sync_state.raw_attributes` | `event_id` matches `cache.events.rowid` |

New code should query `sync_state.raw_*` directly. `cache.*` exists for webapp backward compatibility.

---

## `view` Schema

Computed projections — prefer these over hand-joining raw tables where available.

| View | Purpose |
|------|---------|
| `view.player` | Player + grid attributes + inline `username` / `pfp` |
| `view.planet` | Planet + attributes + defense struct counts + `name` |
| `view.guild` | Guild + off-chain meta + on-chain `name` / `pfp` |
| `view.struct` | Struct joined with full `struct_type` balance data |
| `view.substation` | Substation + grid attributes + UGC fields |
| `view.reactor` | Reactor + grid attributes |
| `view.grid` | Expanded grid with object metadata |
| `view.permission_player` / `view.permission_address` | Permission projections — one boolean column per permission bit (`perm_play`, `perm_admin`, …, `perm_hash_raid`) |
| `view.work` | Active PoW tasks (`object_id`, `player_id`, `category`, `block_start`, `difficulty_target`) |
| `view.guild_bank` | Per-guild Central Bank position |
| `view.leaderboard_guild` | Guild scoreboard |
| `view.leaderboard_player` | Player scoreboard |

### `view.permission_player` / `view.permission_address`

Project `structs.permission` joined with `permission_guild_rank`, keyed by `player_id` and `address` respectively. Each exposes one boolean column per permission bit (`perm_play`, `perm_admin`, `perm_update`, …, `perm_hash_build`/`perm_hash_mine`/`perm_hash_refine`/`perm_hash_raid`) alongside `object_id`, `object_type`, and `updated_at`.

`PermAll` = **33554431** (25 bits, 0..24 set; bit 24 = `PermGuildUGCUpdate` = 16777216).

`signer.UPDATE_PENDING_ACCOUNT` defaults to `PermAll` so newly provisioned signer addresses receive every permission bit.

---

## `signer` Schema

TSA (Transaction Signing Agent) infrastructure. Services insert into `signer.tx` with `status = 'pending'`; TSA claims, signs, and broadcasts.

| Table | Key columns | Notes |
|-------|-------------|-------|
| `signer.role` | `id`, `player_id`, `guild_id`, `status` | Status: `stub`, `generating`, `pending`, `ready` |
| `signer.account` | `id`, `role_id`, `address`, `status` | Status: `stub`, `generating`, `pending`, `available`, `signing` |
| `signer.tx` | `id`, `object_id`, `module`, `command`, `args` (jsonb), `status` | Status: `pending`, `claimed`, `broadcast`, `error` |

### UGC signing wrappers

12 PL/pgSQL `signer.tx_*` functions queue UGC updates:

- **7 self-service** — require `PermUpdate` (4) on the target object
- **5 guild-moderation** — require `PermGuildUGCUpdate` (16777216) on the target owner's guild

Both groups broadcast the same chain messages (`MsgPlayerUpdateName`, `MsgGuildUpdatePfp`, etc.). Guild moderation is the same update message gated by moderator permissions; the chain emits `ugc_moderated` when actor ≠ owner.

---

## `sqitch` Schema

Sqitch migration registry. Do not modify manually.

---

## See Also

- [`knowledge/infrastructure/database-schema.md`](../knowledge/infrastructure/database-schema.md) — Agent query guide (grid patterns, planet_activity polling, energy commerce)
- [`knowledge/infrastructure/guild-stack.md`](../knowledge/infrastructure/guild-stack.md) — Architecture and service topology
- [`.cursor/skills/structs-guild-stack/SKILL.md`](../.cursor/skills/structs-guild-stack/SKILL.md) — Local deployment and common queries
- [`knowledge/mechanics/permissions.md`](../knowledge/mechanics/permissions.md) — 25-bit permission flag reference
