---
description: "The authoritative structural catalog of the Structs PostgreSQL database: schema overview, roles, and enums."
---

# Structs Database Schema

**Category**: database
**Source**: https://github.com/playstructs/structs-pg
**Last Updated**: 2026-10-30 (scoped review below)
**Description**: Authoritative structural catalog of the Structs Guild Stack PostgreSQL schema. Mirrors [`playstructs/structs-pg`](https://github.com/playstructs/structs-pg) as deployed by Sqitch.

For query patterns, grid gotchas, and agent-ready SQL examples, see [`knowledge/infrastructure/database-schema.md`](../knowledge/infrastructure/database-schema.md).

---

## Database Info

| Property | Value |
|----------|-------|
| Name | `structs` |
| Engine | PostgreSQL (version belongs to the deployed image) + TimescaleDB |
| Management | Sqitch (`sqitch` schema) |
| Repository | https://github.com/playstructs/structs-pg |
| Ingestion | `structs-sync-state` (polls chain RPC; writes `structs.*` and `sync_state.*`) |

Chain events are **not** ingested by `structsd`. The `structs-sync-state` service owns block-by-block indexing.

---

## Schema Overview

| Schema | Purpose |
|--------|---------|
| `structs` | Core game state, current economic ownership and API projections |
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
| `structs_webapp` | Application reads, off-chain state and permitted queue wrappers; indexed permissions are read-only | Webapp |
| `structs_tsa` | Selected reads and guarded signer functions; no direct game/queue mutation grants | TSA |
| `structs_crawler` | Read-only on select `structs.*` tables | Crawler |

For agent queries, connect as `structs_indexer` via the GRASS container (see `.cursor/skills/structs-guild-stack/SKILL.md`).

These are service boundaries, not a guarantee that a legacy deployment has no
administrative grants. Inspect `pg_roles` and actual ACLs. The migration verifies
explicit webapp ACLs even on legacy superusers; it does not silently demote them.
A non-superuser fixture verifies effective access. `structs_tsa` must not have
administrative role attributes.

---

## Enums

### `structs.grass_category`

Activity category enum on `structs.planet_activity.category`.

| Value | Notes |
|-------|-------|
| `block` | New block committed (emitted as a consensus heartbeat on subject `consensus`) |
| `guild_consensus` | Guild state changes |
| `guild_meta` | Off-chain guild metadata updates |
| `guild_membership` | Membership changes |
| `raid_status` | Raid status transitions (`initiated`, `ongoing`, `shieldsVulnerable`, … — no `completed`) |
| `shield_change` | Planetary shield value changed (`planetary_shield` / `planetary_shield_old`) |
| `block_raid_start` | Raid vulnerability clock (`blockStartRaid`) armed |
| `fleet_arrive` | Fleet arrived at planet |
| `fleet_advance` | **Defined but not emitted** — movement surfaces as `fleet_depart` + `fleet_arrive` |
| `fleet_depart` | Fleet departed |
| `struct_attack` | Combat attack (per-shot `detail`; **stubbed when the payload exceeds ~7995 bytes** — `stub:true`, no `detail`, pull `planet_activity` for shot detail) |
| `struct_defense_add` | Defense assignment added |
| `struct_defense_remove` | Defense assignment removed |
| `struct_status` | Struct status change (online / offline / destroyed) |
| `struct_move` | Struct moved between slots / ambits |
| `struct_block_build_start` | Build PoW started |
| `struct_block_ore_mine_start` | Mining PoW started |
| `struct_block_ore_refine_start` | Refining PoW started |
| `struct_health` | Struct health changed (`health` / `health_old`) |
| `player_consensus` | Player state changes (**including UGC `username` / `pfp` updates**) |
| `player_meta` | Off-chain player metadata updates |

Live enum ends at `player_meta` — there are **no** `player_address` / `player_address_pending` grass_category values (those are tables, not categories).

Every `planet_activity` INSERT fires `pg_notify('grass', …)` on subject `structs.planet.{planet_id}.{player_id}` (literal `noPlayer` when owner unresolved; top-level `player_id` in payload). Subscribe with a trailing wildcard: `structs.planet.{planet_id}.*`. The `struct_attack` stub guard (and the same guard on `player_consensus` / `guild_consensus` / `guild_meta`) replaces an over-8000-byte payload with a `{ "stub": true }` envelope. Grid attribute changes (`structs.grid.{object}`) and ledger actions (`structs.inventory.…`) stream on their own subjects with their own category values.

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
| **Core entities** | `player`, `planet`, `fleet`, `struct`, `struct_type`, `struct_type_meta`, `guild`, `guild_meta`, `reactor`, `substation`, `allocation`, `infusion`, `provider`, `agreement` |
| **Attributes & grid** | `grid`, `struct_attribute`, `planet_attribute`, `struct_defender` |
| **Permissions** | `permission`, `permission_guild_rank` |
| **Planet activity** | `planet_activity`, `planet_activity_sequence`, `planet_activity_player`, `planet_activity_player_drift`, `planet_raid` |
| **Player addresses** | `player_address`, `player_address_activity`, `player_address_meta`, `player_address_pending`, `player_address_activation_code`, `player_object` |
| **Onboarding / pending** | `player_pending`, `player_internal_pending`, `player_external_pending`, `guild_membership_application`, `onboarding_session`, `onboarding_step`, `onboarding_progress` |
| **Integrations** | `player_discord` |
| **Economy / ledger** | `vault`, `owner_reactor_diversity`, `reactor_commission_revision`, `reactor_stake_cap`, `ledger`, `defusion` |
| **API projections / drift** | `api_refresh_state`, `api_inventory`, `api_inventory_drift`, `api_work`, `api_work_dirty`, `api_work_drift`, `api_guild_bank`, five `api_leaderboard_*` tables |
| **Stats (TimescaleDB)** | `stat_ore`, `stat_fuel`, `stat_capacity`, `stat_load`, `stat_structs_load`, `stat_power`, `stat_connection_count`, `stat_connection_capacity`, `stat_struct_health`, `stat_struct_status`, `stat_rollup`, `stat_rollup_metric`; caggs `planet_activity_hourly`, `planet_activity_daily`, `planet_activity_player_daily` |
| **OIDC provider** | `oidc_client`, `oidc_authorization_request`, `oidc_authorization_code`, `oidc_access_token` |
| **Config / moderation** | `setting`, `banned_word`, `address_tag`, `current_block` |

**Dropped tables** (migrated 2026-05-25): `player_meta` → columns on `player`; `planet_meta` → `name` on `planet`.

---

### `structs.player`

| Column | Type | Notes |
|--------|------|-------|
| `id` | varchar PK | `1-{index}` |
| `index` | integer | Numeric portion of ID |
| `guild_id` | varchar | Guild membership (`0-{index}`) |
| `guild_rank` | numeric (uint64) | Rank within guild (1 = highest; 101 = default on join) |
| `substation_id` | varchar | Connected substation (`4-{index}`) |
| `planet_id` | varchar | Home planet (`2-{index}`) |
| `fleet_id` | varchar | Fleet (`9-{index}`) |
| `primary_address` | varchar | Cosmos address |
| `creator` | varchar | Creating address |
| `username` | varchar | Chain UGC display name |
| `pfp` | varchar | Chain UGC profile picture URI |
| `pfp_client_render_attributes` | varchar | Chain-sourced pfp render hints — a compacted JSON **string**, mirroring `username`/`pfp`. (The JSONB sibling is `player_pending.pfp_cr_attributes`, a different table and column.) |
| `created_at` / `updated_at` | timestamptz | Row timestamps |

`player_meta` was dropped as a table; `username` / `pfp` live on `player`. Off-chain meta updates still surface as grass_category `player_meta`. Sync-state writes UGC from `MsgPlayerUpdateName` / `MsgPlayerUpdatePfp` or signup proxy fields.

---

### `structs.planet`

| Column | Type | Notes |
|--------|------|-------|
| `id` | varchar PK | `2-{index}` |
| `owner` | varchar | Player ID |
| `max_ore` | integer | Maximum ore capacity |
| `space_slots` / `air_slots` / `land_slots` / `water_slots` | integer | Slot counts per ambit |
| `status` | varchar | `active`, `complete` |
| `name` | text | Chain UGC display name |
| `map` | jsonb | Planet map data |
| `creator` | varchar | Creating address |
| `location_list_start` / `location_list_end` | varchar | Location list bounds |
| `created_at` / `updated_at` | timestamptz | Row timestamps |

`planet_meta` was dropped; `name` lives directly on this table.

There is **no `seized_ore` column on `structs.planet`** — seized ore lives on `planet_raid`. Related: `planet_attribute` (key-value, e.g. `planetaryShield`), and `planet_raid` (`planet_id`, `fleet_id`, `status`, `updated_at`, `seized_ore`). Note `planet_raid`'s primary key is `planet_id` alone, so it holds only the **latest** raid per planet, not raid history — derive history from `ledger` rows with `action = 'seized'`.

Planet mine/refine work uses shared `planet_attribute` clocks: `blockStartOreMine` (ID prefix `12-`) and `blockStartOreRefine` (`13-`). `view.planet`, `view.struct`, and work projections expose these planet clocks; do not infer an independent timer from each mining/refining struct.

---

### `structs.guild`

| Column | Type | Notes |
|--------|------|-------|
| `id` | varchar PK | `0-{index}` |
| `index` | integer | Numeric portion of ID |
| `name` | varchar | Chain UGC display name |
| `pfp` | varchar | Chain UGC profile picture URI |
| `entry_rank` | numeric (uint64) | Default rank for new members |
| `endpoint` | varchar | Guild API endpoint |
| `join_infusion_minimum` | numeric | Generated from `join_infusion_minimum_p` |
| `join_infusion_minimum_p` | numeric | Raw infusion minimum |
| `primary_reactor_id` | varchar | Guild reactor |
| `entry_substation_id` | varchar | Default substation for new members |
| `rank_purchase_base_price` / `rank_purchase_step_increase` / `rank_purchase_minimum_rank` | numeric (uint64) | Exact rank purchase policy |
| `join_by_rank_purchase_enabled` | boolean | Whether purchase can join this guild |
| `bank_convert_in_fee` / `bank_convert_out_fee` | numeric | Conversion fees in [0,1), nullable without a snapshot |
| `charter_solver_id` | varchar | Current charter solver |
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
| `status` | varchar | `onStation`, `away` — **camelCase**, not snake_case. Querying `= 'on_station'` returns zero rows, which for a raid check fails *open* (every target looks raidable). |
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
| `attribute_type` | varchar | Grid labels only: `ore`, `fuel`, `capacity`, `load`, `structsLoad`, `power`, `connectionCapacity`, `connectionCount`, `allocationPointerStart`, `allocationPointerEnd`, `proxyNonce`, `lastAction`, `nonce`, `ready`, `checkpointBlock`. **No `alpha`** — Alpha Matter is a ledger denom, not a grid attribute. |
| `val` | numeric | Attribute value (single column — no `value_p`/`value` pair on grid) |
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

`struct_attack` target ownership is per projectile: `detail.eventAttackShotDetail[].targetPlayerId`. There is no top-level `targetPlayerId`.

#### Event categories (reference)

| Category | Description |
|----------|-------------|
| `block` | New block committed |
| `raid_status` | Raid status (`initiated` / `ongoing` / `shieldsVulnerable` / … — not “completed”) |
| `shield_change` | Planetary shield changed |
| `block_raid_start` | Raid vulnerability clock armed |
| `fleet_arrive` | Fleet arrived at planet |
| `fleet_advance` | **Never emitted** — use `fleet_depart` + `fleet_arrive` |
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
| `player_meta` | Off-chain player metadata |

---

### Other `structs` tables (summary)

| Table | Key columns | Purpose |
|-------|-------------|---------|
| `permission` | `object_id`, `player_id`, `val` | Per-player permission bitmask on objects |
| `permission_guild_rank` | `object_id`, `guild_id`, `permission`, `rank` | Guild-rank permission grants (PK: object + guild + permission bit) |
| `reactor` | `id`, `guild_id`, `validator`, `owner` | Validator-linked energy production |
| `substation` | `id`, `owner`, `name`, `pfp`, `deletion_pending`, `deletion_migration_substation_id` | Power distribution and continuing migration state |
| `allocation` | `id`, `source_id`, `destination_id`, `controller` | Energy routing |
| `infusion` | `destination_id`, `address`, `owner_id`, `player_id`, `fuel_p`, `power_p`, `commission`, `generator_disabled` | Composite PK `(destination_id,address)`; stored game output is not current native staking |
| `provider` | `id`, `rate_amount`, `rate_denom`, `access_policy` | Energy marketplace listings |
| `agreement` | `id`, provider/consumer refs, capacity, duration | Active purchase contracts |
| `ledger` | `time`, `address`, `amount`, `action`, `direction`, `denom` | Financial transaction log (hypertable) |
| `defusion` | `validator_address`, `delegator_address`, `amount_p`, `completed_at`, source/reconciliation/retirement coordinates | Historical operation receipts, not current native balances or entry IDs |
| `setting` | `name` PK, `value` | Live tunables (`REACTOR_RATIO`, `PLANET_STARTING_ORE`, …) |
| `banned_word` | `word` PK | UGC name validation seed data |
| `address_tag` | `address`, `label`, `entry` | Labelled address records |
| `current_block` | `height`, `status`, `lag_blocks`, `tip_height` | Chain tip mirror (sync-state writes) |
| `player_pending` | `primary_address` PK, `username`, `pfp`, … | Signup queue |
| `player_address` | `address` PK, `player_id`, `guild_id`, `status` | Address ↔ player mapping |

Most `stat_*` hypertables use `time`, `object_type`, `object_index`, `value`, `block_height` — but several omit `object_type` (e.g. `stat_structs_load`, `stat_connection_*`, `stat_struct_*`). Check `\d` before joining.

`ledger` carries nullable all-or-none coordinates `chain_id`, `tx_index`,
`msg_index`, `event_index`. The unique key includes the complete denomination:
`(time,chain_id,tx_index,msg_index,event_index,denom)`. Multi-coin bank events must
retain every coin/denom; an existing identity with conflicting values is an error.
Legacy rows may have all four coordinates NULL. `sync_state.economy_event_position`
and `infusion_event_position` retain ordered mutation evidence including event
phase; sorting sentinel transaction indices alone does not reproduce execution.

---

## `sync_state` Schema

### Economic ownership and native evidence

| Relation | Contract |
|----------|----------|
| `structs.vault` | Owner ID (player or guild), unique address, exact uint64 account number, nullable `account_created` origin evidence |
| `structs.asset_owner` | Current ownership of player/guild vaults and approved retained player addresses; economic identity, not signing authority |
| `structs.owner_reactor_diversity` | Exact nonnegative `power`, `squared_power`, uint64 `applied_bonus` per owner |
| `structs.reactor_commission_revision` | `slash_revision` and `reconciled_slash_revision`; delayed reconciliation is explicit |
| `structs.reactor_stake_cap` | Authoritative active/cap-bps/min-validator snapshot; an absent row is unknown |
| `sync_state.native_staking_snapshot` | Complete address-level native balances and required/source heights, retry and receipt/position completeness |
| `sync_state.native_staking_position` | Exact bonded/unbonding totals and entry counts per address/validator |
| `sync_state.native_staking_exposure`, `native_staking_invalidation` | Validator/redelegation exposure and invalidation watermarks |
| `sync_state.native_staking_claim`, `native_staking_position_state` | Readiness-qualified native evidence; an absent position is zero only under a complete address snapshot |
| `sync_state.economy_contract` | Contiguous complete-block coverage with activation height, last height/hash and contract `events-v022-1` |

Never insert a vault into `player_address` to make an ownership join work: that table
also authorizes login/signing. A guild vault remains a guild asset, not the leader's
personal balance. Nullable `account_created` is meaningful: only true proves the
release created a BaseAccount; false means adopted and NULL means unknown.
Neither false nor NULL proves unrestricted spendability.

Keep raw uint64 values as exact integers/decimal strings, including ranks,
attribute/work clocks and catalog difficulties. Some economic totals and diversity
aggregates exceed uint64 and use unscaled NUMERIC with their own constraints.
Display-unit columns are not transaction inputs. Work clients preserve the original
block-start anchor; rounding a height or difficulty changes the proof.

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
| `view.work` | Active PoW tasks read from `structs.api_work`; includes `object_id`, `player_id`, `target_id`, category, clocks/difficulty, and location fields |
| `view.work_live` | Live BUILD/MINE/REFINE/RAID specification used only by refresh/reconciliation |
| `view.guild_bank` | Per-guild Central Bank position |
| `view.leaderboard_guild` | Guild scoreboard |
| `view.leaderboard_player` | Player scoreboard |

### `view.permission_player` / `view.permission_address`

Project `structs.permission` joined with `permission_guild_rank`, keyed by `player_id` and `address` respectively. Each exposes one boolean column per permission bit (`perm_play`, `perm_admin`, `perm_update`, …, `perm_hash_build`/`perm_hash_mine`/`perm_hash_refine`/`perm_hash_raid`) alongside `object_id`, `object_type`, and `updated_at`.

`PermAll` = **33554431** (25 bits, 0..24 set; bit 24 = `PermGuildUGCUpdate` = 16777216).

`PermAll` is a protocol constant, not a provisioning default. New key requests
require an explicit mask/proof context. Automatic pool growth inherits one eligible
key's exact grant and counts pending keys toward the maximum of 40. New role
primary keys use the protocol-required mask; queue pressure never creates a role.

### Work and inventory projections

`structs.api_work` matches the nine public columns of `view.work` and adds `source_height` / `updated_at`; its key is `(category, object_id, target_id)`. `structs.api_work_refresh()` drains trigger-fed `api_work_dirty` after each block, and `api_work_refresh_full()` provides the hourly repair pass. `api_work_drift` records `missing`, `extra`, and `stale` comparisons against `view.work_live`.

`structs.api_inventory` stores exact address/player/guild balances under current
`asset_owner` attribution. Real bank denoms derive from idempotent ledger writes.
`ualpha.infused` uses current native bonded stake plus stored generator fuel,
including disabled generators; `ualpha.defusing` uses native unbonding. Missing
native evidence propagates NULL. Redelegation is exposure, not another asset.
Incremental/full/reconcile paths share this specification; synthetic claims must
not be reconstructed by summing historical receipts. Do not sum address and owner
layers or equate wealth with spendable vault funds.

`api_refresh_state` records model source heights/times. `structs.api_readiness`
requires those to match the cursor and current block, plus current-claims authority
and complete economy source coverage after activation. `data_ready` and
`transaction_ready` are distinct; native/action eligibility remains a separate check.
`view.guild_bank.minted_supply` retains its name but denotes current token supply,
including genesis once and subsequent issuance/burns across all holders.

---

## `signer` Schema

TSA uses the guarded `v022-1` queue contract with explicit acting-player authority.

| Table | Contract |
|-------|----------|
| `signer.role`, `account` | Player roles and key pool; unresolved sends reserve their accounts |
| `signer.tx`, `tx_authority` | Request, acting player, exact arguments and authorization requirements |
| `signer.tx_submission` | Immutable signed bytes/hash/account/sequence; state `prepared`, `sending`, `unknown`, `accepted`, `rejected`, `committed`, `cancelled` |
| `signer.local_key` | Public local-key inventory: `unverified`, `unregistered`, `held`, `waiting-index`, `waiting-registration`, `conflict`, `ready` |
| `signer.account_request`, `account_registration`, `account_pool_source` | Idempotent requested grant, registration lifecycle and source-key evidence |
| `signer.role_key_request`, `role_operator_request`, `role_proxy_attempt` | Role/bootstrap/approval identities |
| `signer.tx_registration_proof`, `tx_proxy_proof`, `tx_unsent_abort` | Bound proofs and unsent cancellation history |
| `signer.worker_function_settings` | Saved function security/configuration/ACL metadata for the dedicated worker role migration |

SQL and the persistent TSA journal preserve one signed identity and a one-use send
permit. `accepted` is admission, not committed success. `committed` preserves the
DeliverTx result, including failure. Unknown outcomes are observed, never replaced
or resent automatically. Local-key reconciliation restores registered key inventory,
not a destroyed business queue. Preserve all signer tables and the key/journal volume.

### UGC signing wrappers

12 PL/pgSQL `signer.tx_*` functions queue UGC updates:

- **7 self-service** — require `PermUpdate` (4) on the target object
- **5 guild-moderation** — require `PermGuildUGCUpdate` (16777216) on the target owner's guild

Both groups broadcast the same chain messages (`MsgPlayerUpdateName`, `MsgGuildUpdatePfp`, etc.). Guild moderation is the same update message gated by moderator permissions; the chain emits `ugc_moderated` when actor ≠ owner.

### Wrapper and proof contracts

Wallet wrappers bind the acting player and spending owner. Reactor sources route to
the selected owner's vault unless an explicit retained address is validated;
generator infusion uses the acting player's vault. Only `alpha` has the display
alias `ualpha`; do not guess other denomination scales. Native registration/proxy
proofs bind their current nonce/context, and queue identity survives retries.
Deploy enum additions before wrappers, and the full coordinated contract before
starting the matching worker. See [signer lifecycle and wrappers](../knowledge/infrastructure/database-schema.md#signer-schema-transaction-signing-agent).

---

## `sqitch` Schema

Sqitch migration registry. Do not modify manually.

---

## See Also

- [`knowledge/infrastructure/database-schema.md`](../knowledge/infrastructure/database-schema.md) — Agent query guide (grid patterns, planet_activity polling, energy commerce)
- [`knowledge/infrastructure/guild-stack.md`](../knowledge/infrastructure/guild-stack.md) — Architecture and service topology
- [`.cursor/skills/structs-guild-stack/SKILL.md`](/skills/structs-guild-stack/SKILL.html) — Local deployment and common queries
- [`knowledge/mechanics/permissions.md`](../knowledge/mechanics/permissions.md) — 25-bit permission flag reference

**Verified scope:** economy/native/readiness tables, exact rank types, denomination
identity, role boundaries and signer contracts against structs-pg `400e1c1`,
docker-structs-pg `d0b5924`, structs-tsa `3258529`. Unchanged entity/statistics and
enum catalogs retain the earlier `f66fd81` scope; this is not a complete schema dump.
