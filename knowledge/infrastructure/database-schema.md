# Database Schema Reference

**Purpose**: AI-readable reference for the Structs Guild Stack PostgreSQL database. Covers core game state tables, the key-value grid pattern, event categories, and ready-to-use query patterns.

**Requires**: Guild Stack running locally. See `.cursor/skills/structs-guild-stack/SKILL.md` for setup.

---

## Schema Overview

PostgreSQL 17 with TimescaleDB extension. Four schemas:

| Schema | Purpose |
|--------|---------|
| `structs` | Game state (~50 tables covering all game objects) |
| `cache` | Blockchain event indexing (event-sourcing from chain to game state) |
| `signer` | Transaction signing queue (TSA account/role/tx management) |
| `sqitch` | Schema migration tracking |

### Database Roles

| Role | Access | Used By |
|------|--------|---------|
| `structs` | Superuser (owner) | Administration, migrations |
| `structs_indexer` | Read/write on `structs.*`, `cache.*` | `structsd` (indexer), `structs-grass` |
| `structs_webapp` | Read/write on most `structs.*`, full on `signer.*` | Webapp, MCP, TSA |
| `structs_crawler` | Read-only on select tables | Crawler |

For agent queries, use `structs_indexer` via the GRASS container (see guild-stack skill).

---

## Core Game State Tables

### `structs.player`

| Column | Type | Notes |
|--------|------|-------|
| `id` | varchar PK | `1-{index}` (e.g., `1-142`) |
| `index` | integer | Numeric portion of ID |
| `guild_id` | varchar | Guild membership (e.g., `0-1`) |
| `guild_rank` | bigint | Player's rank within their guild (1 = highest, 101 = default on join, 0 = unset) |
| `planet_id` | varchar | Home planet (e.g., `2-105`) |
| `fleet_id` | varchar | Fleet (e.g., `9-142`) |
| `primary_address` | varchar | Cosmos address |
| `creator` | varchar | Who created this player |

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

### `structs.struct`

| Column | Type | Notes |
|--------|------|-------|
| `id` | varchar PK | `5-{index}` |
| `type` | integer | FK to `struct_type.id` (1-22) |
| `owner` | varchar | Player ID |
| `location_type` | varchar | `fleet` or `planet` |
| `location_id` | varchar | Fleet/planet ID |
| `operating_ambit` | varchar | `space`, `air`, `land`, `water` |
| `slot` | integer | Position within ambit (0-3) |
| `is_destroyed` | boolean | Destruction state |
| `destroyed_block` | bigint | Block height when destroyed |

### `structs.struct_type`

The authoritative reference for all game balance data (~60 columns). Key columns:

**Weapons (primary + secondary prefixed):**
- `*_weapon_control` -- `guided` or `unguided`
- `*_weapon_charge` -- charge cost per attack
- `*_weapon_ambits` -- bitmask of targetable ambits
- `*_weapon_ambits_array` -- JSONB readable form
- `*_weapon_shots`, `*_weapon_damage` -- shots per attack, damage per shot
- `*_weapon_blockable`, `*_weapon_counterable` -- boolean
- `*_weapon_recoil_damage` -- self-damage after firing
- `*_weapon_shot_success_rate_numerator/denominator` -- per-shot hit rate

**Defense:**
- `unit_defenses` -- `signalJamming`, `armour`, `defensiveManeuver`, `stealthMode`, `indirectCombatModule`, `noUnitDefenses`
- `guided_defensive_success_rate_numerator/denominator` -- evasion vs guided
- `unguided_defensive_success_rate_numerator/denominator` -- evasion vs unguided
- `counter_attack` -- counter-attack damage (cross-ambit)
- `counter_attack_same_ambit` -- counter-attack damage (same ambit)

**Other:**
- `planetary_shield_contribution` -- shield value for planet structs
- `generating_rate` -- power generation per gram (generators)
- `ore_mining_difficulty`, `ore_refining_difficulty` -- PoW difficulty
- `build_difficulty` -- PoW difficulty for construction
- Charge costs: `activate_charge`, `build_charge`, `defend_change_charge`, `move_charge`, `stealth_activate_charge`
- Display: `class`, `class_abbreviation`, `unit_description`

### `structs.struct_attribute`

Key-value attributes per struct instance.

| Column | Type | Notes |
|--------|------|-------|
| `object_id` | varchar | Struct ID |
| `attribute_type` | varchar | `health`, `status`, `protectedStructIndex`, etc. |
| `val` | integer | Attribute value |

### `structs.struct_defender`

Defense assignments.

| Column | Type | Notes |
|--------|------|-------|
| `defending_struct_id` | varchar PK | The defender |
| `protected_struct_id` | varchar | The struct being protected |

### `structs.planet`

| Column | Type | Notes |
|--------|------|-------|
| `id` | varchar PK | `2-{index}` |
| `owner` | varchar | Player ID |
| `max_ore` | integer | Maximum ore capacity |
| `space_slots` / `air_slots` / `land_slots` / `water_slots` | integer | Slot counts |
| `status` | varchar | Planet status |
| `seized_ore` | numeric | Cumulative ore taken from this planet across raids (planet-level total; per-raid totals live in `planet_raid.seized_ore`) |

### `structs.planet_attribute`

| Column | Type | Notes |
|--------|------|-------|
| `object_id` | varchar | Planet ID |
| `attribute_type` | varchar | `planetaryShield`, etc. |
| `val` | integer | Attribute value |

### `structs.planet_raid`

| Column | Type | Notes |
|--------|------|-------|
| `planet_id` | varchar | Target planet |
| `fleet_id` | varchar | Raiding fleet |
| `status` | varchar | `initiated`, `completed`, etc. |
| `seized_ore` | numeric | Ore taken |

---

## The Grid Table (Key-Value Pattern)

`structs.grid` is a **key-value store** for resource attributes. This is the most common source of query errors.

| Column | Type | Notes |
|--------|------|-------|
| `object_id` | varchar | Player/planet/struct/etc ID |
| `attribute_type` | varchar | `ore`, `alpha`, `structsLoad`, `capacity`, `fuel`, `power`, etc. |
| `val` | numeric | The value |

**Wrong** (no `ore` column exists):
```sql
SELECT ore FROM structs.grid WHERE object_id = '1-142';
```

**Correct** (filter by `attribute_type`):
```sql
SELECT val FROM structs.grid WHERE object_id = '1-142' AND attribute_type = 'ore';
```

**Multiple attributes** (use JOINs):
```sql
SELECT p.id,
    COALESCE(g_ore.val, 0) as ore,
    COALESCE(g_cap.val, 0) as capacity,
    COALESCE(g_load.val, 0) as structs_load
FROM structs.player p
LEFT JOIN structs.grid g_ore ON g_ore.object_id = p.id AND g_ore.attribute_type = 'ore'
LEFT JOIN structs.grid g_cap ON g_cap.object_id = p.id AND g_cap.attribute_type = 'capacity'
LEFT JOIN structs.grid g_load ON g_load.object_id = p.id AND g_load.attribute_type = 'structsLoad'
WHERE p.id = '1-142';
```

### Grid Attribute Types

| attribute_type | Found On | Meaning |
|----------------|----------|---------|
| `ore` | player, planet | Ore balance (player = mined/stealable; planet = remaining) |
| `capacity` | player, reactor, substation | Energy capacity |
| `structsLoad` | player | Energy consumed by active structs |
| `fuel` | reactor | Total ualpha infused |
| `power` | infusion | Energy generated from fuel |
| `connectionCapacity` | substation | Available capacity per connection |
| `connectionCount` | substation | Active connections |
| `load` | player | Base player load |

---

## planet_activity (Event Log)

TimescaleDB hypertable for all planet-level events.

| Column | Type | Notes |
|--------|------|-------|
| `time` | timestamp | Event time |
| `seq` | integer | Sequence number (monotonically increasing, use as high-water mark) |
| `planet_id` | varchar | Planet where event occurred |
| `category` | enum | Event type (see below) |
| `detail` | JSONB | Event-specific data |

### Event Categories

| Category | Description |
|----------|-------------|
| `block` | New block committed |
| `raid_status` | Raid initiated/completed/failed |
| `fleet_arrive` | Fleet arrived at planet |
| `fleet_advance` | Fleet movement in progress |
| `fleet_depart` | Fleet departed from planet |
| `struct_attack` | Combat attack event |
| `struct_defense_add` | Defense assignment added |
| `struct_defense_remove` | Defense assignment removed |
| `struct_status` | Struct status change (online/offline/destroyed) |
| `struct_move` | Struct moved between slots/ambits |
| `struct_block_build_start` | Build PoW started |
| `struct_block_ore_mine_start` | Mining PoW started |
| `struct_block_ore_refine_start` | Refining PoW started |
| `struct_health` | Struct health changed (damage) |
| `guild_consensus` | Guild consensus events |
| `guild_meta` | Guild metadata changes |
| `guild_membership` | Membership changes |
| `player_consensus` | Player consensus events |
| `player_meta` | Player metadata changes |

### Polling Pattern (Real-Time Monitoring)

```sql
-- Initialize: set high-water mark
SELECT COALESCE(MAX(seq), 0) as last_seq
FROM structs.planet_activity
WHERE planet_id IN ('2-105');

-- Poll every ~6 seconds
SELECT seq, planet_id, category, detail::text
FROM structs.planet_activity
WHERE planet_id IN ('2-105', '2-127')
    AND seq > $LAST_SEQ
ORDER BY seq ASC;
```

The `detail` column for `struct_attack` includes `attackerStructId`, `targetStructId`, and `eventAttackShotDetail` with per-shot damage breakdowns.

---

## Energy Commerce Tables

| Table | Key Columns | Notes |
|-------|-------------|-------|
| `reactor` | `id`, `guild_id`, `validator`, `owner` | Links validator address to guild; `owner` is PlayerId |
| `infusion` | `destination_id`, `address`, `fuel`, `power`, `commission` | Composite PK: `(destination_id, address)` |
| `allocation` | `id`, `source_id`, `destination_id`, `controller` | Energy routing; `controller` is PlayerId (not address) |
| `substation` | `id`, `owner` | Power distribution nodes |
| `provider` | `id`, `rate_amount`, `rate_denom`, `access_policy` | Energy marketplace listings |
| `agreement` | `id`, provider/consumer refs, capacity, duration | Active purchase contracts |

### `structs.guild`

| Column | Type | Notes |
|--------|------|-------|
| `id` | varchar PK | `0-{index}` (e.g., `0-1`) |
| `entry_rank` | bigint | Default guild rank assigned to new members (chain default: 101) |

### `structs.guild_meta` (UGC mirror)

| Column | Type | Notes |
|--------|------|-------|
| `id` | varchar PK | Guild ID, mirrors `structs.guild.id` |
| `name` | text | Guild name (UGC; populated by chain `MsgGuildUpdateName` -> cache trigger) |
| `pfp` | text | Guild profile picture (UGC; added in v0.16.0; populated by `MsgGuildUpdatePfp`) |

### `structs.player_meta` (UGC mirror, v0.16.0)

| Column | Type | Notes |
|--------|------|-------|
| `id` | varchar PK | Player ID. **PK collapsed in v0.16.0 from `(id, guild_id)` to `(id)`** -- there is now exactly one meta row per player |
| `guild_id` | varchar | Player's current guild (kept in sync via `cache.handle_event_player`) |
| `username` | text | Player username (UGC; chain is sole source of truth as of v0.16.0; written from `MsgPlayerUpdateName` and from `MsgGuildMembershipJoinProxy.playerName` at signup) |
| `pfp` | text | Player profile picture (UGC; written from `MsgPlayerUpdatePfp` and from `MsgGuildMembershipJoinProxy.playerPfp`) |

The webapp no longer writes `player_meta` directly. The `PLAYER_PENDING_MERGE` trigger was modified in v0.16.0 to skip the meta insert -- the chain UGC update is the only path that populates `username` and `pfp`. The trigger still writes the `lastAction` grid seed so newly merged players have a complete grid.

### `structs.substation` (with UGC fields)

| Column | Type | Notes |
|--------|------|-------|
| `id` | varchar PK | Substation ID |
| `owner` | varchar | Owner player ID |
| `name` | text | Substation name (UGC; added in v0.16.0; written from `MsgSubstationUpdateName` directly on the substation row -- no separate `substation_meta` table) |
| `pfp` | text | Substation profile picture (UGC; added in v0.16.0; written from `MsgSubstationUpdatePfp`) |

### `structs.planet_meta`

Planet name is written by `cache.handle_event_planet`. As of v0.16.0 the chain only updates the planet name when the chain event carries a non-empty value, so an auto-generated default name is never overwritten by an empty UGC update.

### `structs.permission_guild_rank`

| Column | Type | Notes |
|--------|------|-------|
| `object_id` | varchar | The object permissions are set on |
| `guild_id` | varchar | The guild whose members receive the permission |
| `permission` | bigint | Single permission bit (power of 2) |
| `rank` | bigint | Worst-allowed guild rank; 0 = revoked |
| `updated_at` | timestamptz | Last update timestamp |

Primary key: `(object_id, guild_id, permission)`. See [permissions.md](../mechanics/permissions.md) for the guild rank permission system.

The `permission` view is a 24-bit-mask projection over `structs.permission` rows joined with `permission_guild_rank` and exposes a `permission_hash` column so callers can compare aggregated permission state cheaply. The `PermAll` mask is `33554431` (bits 0..24 set).

### `structs.banned_word`

Seed data for UGC name validation. The chain rejects any `Msg*UpdateName` (player, guild, planet, substation) whose name contains a substring matching any row in this table; webapps surface the same list via [`api/webapp/banned-word.md`](../../api/webapp/banned-word.md) so client-side forms can preflight.

| Column | Type | Notes |
|--------|------|-------|
| `word` | text PK | Banned token (lowercase) |

### `structs.address_tag`

Labelled address records. Each `(address, label)` pair tags a Cosmos address with a human-readable label, plus an `entry` integer for ordering.

| Column | Type | Notes |
|--------|------|-------|
| `address` | varchar | Cosmos address |
| `label` | text | Tag name |
| `entry` | bigint | Sort/insert order within `label` |

Primary key: `(address, label)`; reverse-lookup index `(label, entry)` (`table-address-tag-idx-label-entry`).

### `structs.setting`

Live tunables — chain economy and gameplay constants exposed unauthenticated through [`api/webapp/setting.md`](../../api/webapp/setting.md).

| Column | Type | Notes |
|--------|------|-------|
| `name` | text PK | Setting key |
| `value` | text | Setting value (string-encoded; numeric where applicable) |

Seeded keys: `REACTOR_RATIO`, `PLAYER_RESUME_CHARGE`, `PLANETARY_SHIELD_BASE`, `PLAYER_PASSIVE_DRAW`, `PLANET_STARTING_ORE`, `PLANET_STARTING_SLOTS`. Treat the table as an open name/value map — keys are added over time.

### `structs.defusion`

In-flight reactor defusion records — Alpha Matter being unbonded from a reactor.

| Column | Type | Notes |
|--------|------|-------|
| `validator_address` | varchar | Validator operator address |
| `delegator_address` | varchar | Delegator account address |
| `defusion_type` | varchar | Defusion category |
| `amount` | numeric | Amount being unbonded |
| `denom` | varchar | Token denom |
| `created_at` / `completes_at` | timestamptz | Lifecycle timestamps |

Old rows are reaped by the `structs.CLEAN_DEFUSION()` cron. Read endpoints live in [`api/webapp/defusion.md`](../../api/webapp/defusion.md).

---

## Aggregated Views

| View | Purpose |
|------|---------|
| `view.guild_bank` | Per-guild Central Bank position — minted/redeemed token balances, collateral, and outstanding supply, joined from `structs.guild`, the on-chain bank module, and ledger movements |
| `view.leaderboard_guild` | Ranked guild scoreboard (members, ore mined, planets completed, raids launched, raids successful) for UI surfaces |
| `view.leaderboard_player` | Same shape as `view.leaderboard_guild` but per player |

Use views, not raw tables, when building leaderboard or treasury surfaces — the views absorb the `seized_ore`, ledger, and infusion joins so the upstream surface stays stable when underlying tables change.

---

## Other Time-Series Tables (TimescaleDB)

| Hypertable | Purpose | Key Columns |
|------------|---------|-------------|
| `ledger` | Financial transaction log | `time`, `address`, `amount`, `action`, `direction`, `denom` |
| `stat_ore` | Ore value history | `time`, `object_type`, `object_index`, `value` |
| `stat_capacity` | Capacity history | Same pattern |
| `stat_fuel` | Fuel history | Same pattern |
| `stat_load` | Load history | Same pattern |
| `stat_power` | Power history | Same pattern |
| `stat_struct_health` | Struct health over time | `time`, `object_index`, `value` |
| `stat_struct_status` | Struct status over time | Same pattern |
| `stat_structs_load` | structsLoad over time | Same pattern |

### Ledger Action Types

`genesis`, `received`, `sent`, `migrated`, `infused`, `defusion_started`, `defusion_cancelled`, `defusion_completed`, `mined`, `refined`, `seized`, `forfeited`, `minted`, `burned`, `diversion_started`, `diversion_completed`

---

## Signer Schema (Transaction Signing Agent)

The TSA (Transaction Signing Agent, [`playstructs/structs-tsa`](https://github.com/playstructs/structs-tsa)) manages a pool of signing accounts. Services insert rows into `signer.tx` with `status='pending'`. TSA claims them, signs, and broadcasts.

| Table | Key Columns | Notes |
|-------|-------------|-------|
| `signer.role` | `id`, `player_id`, `guild_id`, `status` | Status: `stub`, `generating`, `pending`, `ready` |
| `signer.account` | `id`, `role_id`, `address`, `status` | Status: `stub`, `generating`, `pending`, `available`, `signing` |
| `signer.tx` | `id`, `module`, `command`, `args` (JSONB), `status` | Status: `pending`, `claimed`, `broadcast`, `error`. 100+ command types as of v0.16.0. |

### `signer.signer_tx_type` (UGC enum values)

Seven enum values cover the UGC chain message types:

| Enum Value | Wraps |
|------------|-------|
| `guild-update-name` | `MsgGuildUpdateName` |
| `guild-update-pfp` | `MsgGuildUpdatePfp` |
| `player-update-name` | `MsgPlayerUpdateName` |
| `player-update-pfp` | `MsgPlayerUpdatePfp` |
| `substation-update-name` | `MsgSubstationUpdateName` |
| `substation-update-pfp` | `MsgSubstationUpdatePfp` |
| `planet-update-name` | `MsgPlanetUpdateName` |

### `signer.tx_*` wrappers

The signing layer ships 12 PL/pgSQL wrapper functions that queue UGC updates into `signer.tx`. They split into two groups by **permission preflight only** — both groups ultimately broadcast the same chain messages (`MsgPlayerUpdateName`, `MsgPlayerUpdatePfp`, `MsgPlanetUpdateName`, `MsgSubstationUpdateName`, `MsgSubstationUpdatePfp`):

- **7 self-service wrappers** (one per UGC tx type above) that require `PermUpdate` (4) on the target object before queueing the tx. These are used when a player updates their own UGC.
- **5 guild-moderation wrappers** (`tx_guild_moderate_player_name`, `_player_pfp`, `_planet_name`, `_substation_name`, `_substation_pfp`) that require `PermGuildUGCUpdate` (16777216) on the target owner's guild before queueing the tx. These are used when a guild moderator overrides a member's UGC.

There is no `MsgGuildModerate*` chain message — moderation is the same `Msg*Update*` message, gated by the actor's `PermGuildUGCUpdate` on the owner's guild. The chain emits a `ugc_moderated` event whenever the actor differs from the target object's owner.

`signer.UPDATE_PENDING_ACCOUNT` defaults to `PermAll = 33554431` (bits 0..24) so newly provisioned signer addresses receive every permission, including `PermGuildUGCUpdate`, by default.

### `PLAYER_PENDING_JOIN_PROXY` (v0.16.0)

The `PLAYER_PENDING_JOIN_PROXY` trigger was modified to thread `username` and `pfp` from the pending row through to `signer.CREATE_TRANSACTION` for the `guild-membership-join-proxy` command, packaged into the `ugc` JSONB argument. The webapp's signup flow becomes:

```text
webapp signup
  -> structs.player_pending row (with username, pfp)
  -> PLAYER_PENDING_JOIN_PROXY trigger
  -> signer.tx (command=guild-membership-join-proxy, args.ugc={username, pfp, ...})
  -> TSA claims, signs MsgGuildMembershipJoinProxy with playerName/playerPfp
  -> chain validates name/pfp, creates player, populates player_meta via cache trigger
```

---

## ID Format Reference

All game object IDs follow `{type_prefix}-{index}`. See [entity-relationships.md](../entities/entity-relationships.md) for the complete type code table.

| Prefix | Object Type | Example |
|--------|-------------|---------|
| `0-` | Guild | `0-1` |
| `1-` | Player | `1-142` |
| `2-` | Planet | `2-105` |
| `3-` | Reactor | `3-1` |
| `4-` | Substation | `4-5` |
| `5-` | Struct | `5-1165` |
| `6-` | Allocation | `6-10` |
| `9-` | Fleet | `9-142` |
| `10-` | Provider | `10-2` |
| `11-` | Agreement | `11-1` |

---

## See Also

- `.cursor/skills/structs-guild-stack/SKILL.md` -- Setup and common queries
- `knowledge/infrastructure/guild-stack.md` -- Architecture overview
- `knowledge/entities/entity-relationships.md` -- Full entity graph and ID format
- `knowledge/entities/struct-types.md` -- Struct type stats (mirrors `struct_type` table)
