# Structs Database Schema

**Version**: 1.3.0
**Category**: database
**Source**: https://github.com/playstructs/structs-pg
**Last Updated**: 2026-02-24

PostgreSQL database schema for Structs guild infrastructure. Managed by structs-pg repository using Sqitch.

---

## Database Info

| Property | Value |
|----------|-------|
| Name | structs |
| Type | PostgreSQL |
| Management | Sqitch |
| Repository | https://github.com/playstructs/structs-pg |

---

## v0.8.0-beta Changelog

| Date | Change | Description | Impact |
|------|--------|-------------|--------|
| 2025-11-22 | function-signer-tx-player | Latest messages for testnet 103 | -- |
| 2025-11-29 | table-struct-type-cheatsheet-details | Added cheatsheet details to `struct_type` table | New columns for cheatsheet information in `struct_type` |
| 2025-12-02 | table-struct-type-extended-cheatsheet | Added extended cheatsheet details to `struct_type` | Additional cheatsheet columns added |
| 2025-12-03 | table-struct-type-update-cheatsheet | Updated extended cheatsheet details to `struct_type` | Cheatsheet columns refined |
| 2025-12-08 | remove-deprecated-charge-columns | Removed deprecated Charge Bar columns for mine and refine | Deprecated charge columns removed from `struct_type`, views, and cache triggers. Tables: `struct_type`, `view.struct`, `view.work`. Trigger: `cache-trigger-add-queue` |
| 2025-12-13 | view-work-fixed-raid-logic | Fixed raid logic in `view.work` | Improved raid task filtering in work view |
| 2025-12-15 | table-signer-tx-complete-input-changes | Hash Complete nonces were INTEGER instead of CHARACTER VARYING | Fixed nonce data type for hash complete transactions |
| 2025-12-18 | view-permission-add-permission-hash | Added new `permission_hash` level | New permission level added to permission view. Related: Hash permission bit (value 64) in API layer |
| 2025-12-18 | table-signer-tx-permission-update | Updated tx signing permission levels | Transaction signing now supports Hash permission level |
| 2025-12-18 | table-signer-tx-add-tx-types | Updated tx types | Additional transaction types added |
| 2025-12-18 | cache-trigger-struct-type-fix | Fix to Struct Type cache commit | Cache trigger improvements for `struct_type` |
| 2025-12-19 | trigger-grass-grid-p-values | Fixed grass grid p values | GRASS grid trigger improvements |
| 2025-12-27 | view-work-exclusion-logic | Improved `view.work` logic to exclude impossible tasks | Better filtering of impossible tasks in work view |
| 2025-12-29 | table-struct-add-destroyed | New `destroyed` column on struct table | Struct table now tracks destroyed status. Related: StructSweepDelay (5 blocks) -- destroyed structs persist for 5 blocks |
| 2025-12-29 | function-signer-account-bug-fix | Resolved bug in the signer | Signer function bug fix |
| 2025-12-29 | table-player-address-pending-permissions | `permissions` column was missing for device adding | Added `permissions` column to `player_address_pending` table |
| 2026-01-01 | table-planet-activity-struct-health | Added `struct_health` as a detail field in `planet_activity` table | `planet_activity` table now includes `struct_health` in details JSONB field. This field is also emitted by GRASS in planet activity events. |

---

## v0.10.0 through v0.13.0-beta Changelog

| Date | Change | Description | Impact |
|------|--------|-------------|--------|
| 2025-12-29 | table-struct-add-destroyed | New `is_destroyed` column on struct table | Struct table tracks destroyed status (boolean, default false) |
| 2025-12-29 | function-signer-account-fix | Resolved bug in the signer | Signer function bug fix |
| 2025-12-29 | table-player-address-pending-permissions | `permissions` column was missing for device adding | Added `permissions` (integer) to `player_address_pending` |
| 2026-01-11 | cache-trigger-fix-defenders | Fixing an issue with defenders | Defender cache event processing fix |
| 2026-01-11 | cache-trigger-fix-defender-clear | Adding Defensive Clear event processing | New `handle_event_struct_defender_clear` cache function |
| 2026-01-15 | planet-activity-struct-attribute-add-health | Adding health changes to planetary activity | `struct_health` added to `grass_category` enum; health changes tracked in planet activity |
| 2026-01-15 | type-grass-category-add-struct-health | Adding `struct_health` to grass_category enum | Enum now includes `struct_health` for planet activity events |
| 2026-01-18 | planet-activity-struct-attribute-fix-bad-location | Fixing import issue on stale struct attributes | Stale struct attribute location fix |
| 2026-01-18 | cache-trigger-fix-defender-clear | Fix Defender Clear caching | Iteration on defender clear cache handling |
| 2026-01-18 | planet-activity-struct-attribute-fix-defender-clear | Fix Defender Clear in planet activity | Defender clear planet activity fix |
| 2026-01-19 | view-work-fixed-migration-issue-with-zero | Work view issue post-migration because of zero blocks | `view.work` fix for zero block_start values |
| 2026-01-21 | cache-trigger-bigly-refactor | Refactoring the cache system | Major cache system refactor; 41 handler functions in `cache` schema |
| 2026-01-21 | table-player-address-activity-fix-index | Fixing an index | Index fix on `player_address_activity` |
| 2026-01-23 | table-player-fix-internal-player-trigger | Fixing a player insert trigger on guild | Player insert trigger fix for guild association |
| 2026-02-03 | cache-trigger-add-new-events | Updating Struct and Planet attribute handlers to delete on zero | Zero-value attribute cleanup in cache handlers |
| 2026-02-07 | table-struct-add-destroyed-block | Adding `destroyed_block` column to struct table | `destroyed_block` (bigint) tracks block height of destruction |
| 2026-02-07 | cache-trigger-add-destroyed-block | Updating cache for destroyed_block | Cache handler updated for `destroyed_block` |
| 2026-02-21 | table-planet-raid-add-seized-ore | Adding `seized_ore` to planet_raid table | `seized_ore` (numeric) on `planet_raid` for raid victory handling |
| 2026-02-21 | cache-trigger-add-seized-ore | Updating cache for seized_ore | Cache handler updated for `seized_ore` |
| 2026-02-23 | trigger-player-address-cascade | Fixing onboarding | `player_address_cascade` trigger on player table |
| 2026-02-23 | trigger-player-address-cascade-v2 | Fixing onboarding (iteration) | Refined `player_address_cascade` trigger |
| 2026-02-23 | cache-trigger-add-player-address | Fixing onboarding | Cache trigger for player address during onboarding |

---

## Database Schemas

| Schema | Purpose |
|--------|---------|
| structs | Core game tables (52 tables) |
| view | Materialized/computed views (21 views) |
| cache | Event handler functions (41 functions) and queue management |
| signer | Transaction signing infrastructure |
| sqitch | Migration management |

---

## Tables

### struct_type

Struct type definitions with all properties.

**v0.8.0-beta changes**:

| Action | Details |
|--------|---------|
| Added | `cheatsheet_details`, `cheatsheet_extended_details` |
| Removed | Deprecated charge columns for mine and refine |

Cheatsheet details added for better struct type documentation. Deprecated charge columns removed.

### struct

Struct instances. Verified columns: `id` (varchar, PK), `index` (int), `type` (int), `creator` (varchar), `owner` (varchar), `location_type` (varchar), `location_id` (varchar), `operating_ambit` (varchar), `slot` (int), `created_at` (timestamptz), `updated_at` (timestamptz), `is_destroyed` (boolean, default false), `destroyed_block` (bigint).

Trigger: `planet_activity_struct_movement` fires on update.

**v0.8.0-beta changes**:

| Action | Details |
|--------|---------|
| Added | `is_destroyed` (boolean, default false) |

**v0.10.0-v0.13.0 changes**:

| Action | Details |
|--------|---------|
| Added | `destroyed_block` (bigint) -- block height at which struct was destroyed (2026-02-07) |

### signer_tx

Transaction signing information.

**v0.8.0-beta changes**:

- Hash Complete nonces changed from INTEGER to CHARACTER VARYING
- Updated permission levels to support Hash permission
- Added new transaction types

### player_address_pending

Pending player address additions.

**v0.8.0-beta changes**:

| Action | Details |
|--------|---------|
| Added | `permissions` |

`permissions` column added for device adding functionality.

### planet_activity

Planet activity log (TimescaleDB hypertable). Columns: `time` (timestamptz, not null), `seq` (int, not null), `planet_id` (varchar, not null), `category` (grass_category enum), `detail` (jsonb). Index on `time DESC`.

Trigger: `planet_activity_notify` fires on insert.

**v0.8.0-beta changes**:

| Action | Details |
|--------|---------|
| Added | `struct_health` in details JSONB field |

**v0.10.0-v0.13.0 changes**:

| Action | Details |
|--------|---------|
| Updated | `struct_health` added to `grass_category` enum (2026-01-15) |
| Fixed | Stale struct attribute location handling (2026-01-18) |
| Fixed | Defender clear event in planet activity (2026-01-18) |

### planet_raid

Raid status tracking per planet. Columns: `planet_id` (varchar, PK), `fleet_id` (varchar), `status` (varchar), `updated_at` (timestamptz), `seized_ore` (numeric).

Trigger: `planet_activity_raid_status` fires on insert/update.

**v0.10.0-v0.13.0 changes** (new table section):

| Action | Details |
|--------|---------|
| Added | `seized_ore` (numeric) -- ore seized during raids for victory handling (2026-02-21) |

### grass_category Enum

Activity category enum used by `planet_activity.category`. Values: `block`, `guild_consensus`, `guild_meta`, `guild_membership`, `raid_status`, `fleet_arrive`, `fleet_advance`, `fleet_depart`, `struct_attack`, `struct_defense_remove`, `struct_defense_add`, `struct_status`, `struct_move`, `struct_block_build_start`, `struct_block_ore_mine_start`, `struct_block_ore_refine_start`, `struct_health`, `player_consensus`, `player_meta`.

**v0.10.0-v0.13.0 changes**:

| Action | Details |
|--------|---------|
| Added | `struct_health` (2026-01-15) |

---

## Views

### permission

Permission view.

**v0.8.0-beta changes**:

| Action | Details |
|--------|---------|
| Added | `permission_hash` level |

New `permission_hash` level added. Maps to Hash permission bit (value 64) in API layer.

### work

Work/task view. Columns: `object_id`, `player_id`, `target_id`, `category` (text), `block_start` (int), `difficulty_target` (int).

**v0.8.0-beta changes**:

| Action | Details |
|--------|---------|
| Improved | Fixed raid logic; improved exclusion logic to exclude impossible tasks |
| Removed | Deprecated charge columns |

**v0.10.0-v0.13.0 changes**:

| Action | Details |
|--------|---------|
| Fixed | Zero block_start values post-migration (2026-01-19) |

### struct

Struct view (joins struct with struct_type). Includes all struct_type weapon/defense properties, charge costs, generator stats, and cosmetic metadata.

**v0.8.0-beta changes**:

| Action | Details |
|--------|---------|
| Removed | Deprecated charge columns |

### planet

Planet view. Columns include: `planet_id`, `max_ore`, `buried_ore`, `available_ore`, `planetary_shield`, defense struct quantities (repair_network, defensive_cannon, CGSN, LOBI, advanced LOBI, orbital jamming, advanced orbital jamming), `lobi_network_success_rate_numerator/denominator`, `block_start_raid`, `creator`, `owner`, `status`, `created_at`, `updated_at`.

---

## Functions

### signer_tx_player

Transaction signing for player.

**v0.8.0-beta**: Updated 2025-11-22 -- Latest messages for testnet 103.

### signer_account

Account signing function.

**v0.8.0-beta**: Bug fix 2025-12-29 -- Resolved bug in the signer.

---

## Triggers

### cache.add_queue

Main cache trigger for queue management. Processes chain events and dispatches to 41 handler functions.

**v0.8.0-beta changes**:

- Removed deprecated charge columns
- Fixed struct type cache commit

**v0.10.0-v0.13.0 changes**:

- Fixed defender event processing (2026-01-11)
- Added `handle_event_struct_defender_clear` (2026-01-11)
- Major refactor of cache system (2026-01-21)
- Added zero-value attribute cleanup (2026-02-03)
- Added `destroyed_block` handling (2026-02-07)
- Added `seized_ore` handling (2026-02-21)
- Added player address handling for onboarding (2026-02-23)

### player_address_cascade

Trigger on `structs.player` table. Fires after insert or update. Cascades player data to associated addresses during onboarding.

**v0.10.0-v0.13.0**: Added 2026-02-23 -- Fixes onboarding flow.

### planet_activity_raid_status

Trigger on `structs.planet_raid` table. Fires after insert or update. Logs raid status changes to `planet_activity`.

### planet_activity_struct_movement

Trigger on `structs.struct` table. Fires after update. Logs struct movement to `planet_activity`.

### grass_grid

GRASS grid trigger.

**v0.8.0-beta**: Fix 2025-12-19 -- Fixed grass grid p values.

---

## Cache Handler Functions (cache schema)

41 handler functions processing chain events. Key handlers:

| Function | Purpose |
|----------|---------|
| `handle_event_struct` | Struct create/update/delete |
| `handle_event_struct_attribute` | Struct attribute changes (health, status, etc.) |
| `handle_event_struct_defender` | Defender assignment |
| `handle_event_struct_defender_clear` | Defender removal (added v0.10.0) |
| `handle_event_struct_type` | Struct type definitions |
| `handle_event_planet` | Planet create/update |
| `handle_event_planet_attribute` | Planet attribute changes |
| `handle_event_fleet` | Fleet status/movement |
| `handle_event_raid` | Raid events |
| `handle_event_attack` | Attack events |
| `handle_event_player` | Player create/update |
| `handle_event_guild` | Guild operations |
| `handle_event_guild_membership_application` | Guild membership |
| `handle_event_infusion` | Infusion operations |
| `handle_event_permission` | Permission changes |
| `handle_event_ore_mine` | Mining events |
| `handle_event_ore_theft` | Ore theft during raids |
| `handle_event_alpha_refine` | Refinement events |

---

## Verification

| Property | Value |
|----------|-------|
| Verified | Yes (partial) |
| Verified Date | 2026-02-24 |
| Method | Direct database connection via docker |
| Note | Table schemas, views, triggers, enums, and cache functions verified against live database |
| Source | https://github.com/playstructs/structs-pg |
