# Database Schema Reference

**Purpose**: AI-readable reference for the Structs Guild Stack PostgreSQL database. Covers core game state tables, the key-value grid pattern, event categories, and ready-to-use query patterns.

**Requires**: Guild Stack running locally. See `.cursor/skills/structs-guild-stack/SKILL.md` for setup.

---

## Schema Overview

PostgreSQL 17 with TimescaleDB extension. Six application schemas (plus `cron` for pg_cron jobs and the `_timescaledb_*` internals):

| Schema | Purpose |
|--------|---------|
| `structs` | Game state (51 base tables covering all game objects) |
| `sync_state` | Chain indexer state: sync cursor, block log, raw blocks/events, handler error log |
| `cache` | Compatibility views over `sync_state.raw_*` (read-only; not an event-sink) |
| `view` | Computed views (`view.player`, `view.guild`, leaderboards, inventories, permission projection) |
| `signer` | Transaction signing queue (TSA account/role/tx management) |
| `sqitch` | Schema migration tracking |

Full table enumeration: [`schemas/database-schema.md`](../../schemas/database-schema.md).

Chain events are ingested by the **`structs-sync-state`** service (not `structsd`). It polls the chain RPC and writes directly into `structs.*` and `sync_state.*`.

### Database Roles

| Role | Access | Used By |
|------|--------|---------|
| `structs` | Superuser (owner) | Administration, migrations |
| `structs_indexer` | Read/write on `structs.*`, `sync_state.*`, `cache.*` (views) | `structs-sync-state`, `structs-grass` |
| `structs_webapp` | Read/write on most `structs.*`, full on `signer.*` | Webapp, TSA |
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
| `substation_id` | varchar | Substation the player draws capacity from (e.g., `4-5`) |
| `primary_address` | varchar | Cosmos address |
| `creator` | varchar | Who created this player |
| `username` | varchar | Player display name (chain UGC; from `MsgPlayerUpdateName` or signup proxy) |
| `pfp` | varchar | Profile picture URI (chain UGC; from `MsgPlayerUpdatePfp` or signup proxy) |
| `pfp_client_render_attributes` | varchar | Compacted JSON string describing how a client renders a locally generated pfp (chain `Player` field 12, added v0.18.0). Untrusted UGC — do not eval. |

### `structs.fleet`

| Column | Type | Notes |
|--------|------|-------|
| `id` | varchar PK | `9-{index}` |
| `owner` | varchar | Player ID |
| `status` | varchar | `onStation`, `away` — **camelCase**. `WHERE status = 'on_station'` returns 0 rows. |
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
- `*_weapon_armour_piercing` -- boolean; ignores the target's `armour` damage reduction (added v0.18.0)
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
- `generating_rate_p` -- power generation per gram (generators); **this is the writable column**
- `ore_mining_difficulty`, `ore_refining_difficulty` -- PoW difficulty
- `build_difficulty` -- PoW difficulty for construction
- Charge costs: `activate_charge`, `build_charge`, `defend_change_charge`, `move_charge`, `stealth_activate_charge`
- Display: `class`, `class_abbreviation`, `unit_description`

> **`_p` precision columns are the base; their bare companions are GENERATED.** Three pairs on this table are split: `generating_rate_p` / `generating_rate` (= `generating_rate_p * 1000`), `build_draw_p` / `build_draw`, and `passive_draw_p` / `passive_draw` (both formatted via `unit_legacy_format(…, 'milliwatt')`). The bare names are still readable — a `SELECT generating_rate` keeps working — but only the `_p` column is writable, so it is the one sync-state upserts and the one to use in a `WHERE` on an exact integer. The same pattern applies to `structs.ledger.amount_p`, `structs.infusion.fuel_p`/`power_p`/`ratio_p`/`defusing_p`, and `structs.guild.join_infusion_minimum_p`. The `*_array` bitmask-derivative columns (`primary_weapon_ambits_array`, `possible_ambit_array`, …) are likewise GENERATED.

### `structs.struct_attribute`

Key-value attributes per struct instance.

| Column | Type | Notes |
|--------|------|-------|
| `id` | varchar PK | `{attrType}-{objectTypeId}-{objectIndex}` |
| `object_id` | varchar | Struct ID (or player ID for `typeCount`) |
| `object_type` | varchar | `struct` or `player` |
| `attribute_type` | varchar | See below |
| `val` | integer | Attribute value |

| attribute_type | Found On | Meaning |
|----------------|----------|---------|
| `health` | struct | Current HP |
| `status` | struct | Status bitfield (online/offline/stealth) |
| `protectedStructIndex` | struct | Index of the struct this one defends |
| `blockStartBuild` | struct | Block height the build PoW window opened |
| `blockStartOreMine` | struct | Block height the mining PoW window opened |
| `blockStartOreRefine` | struct | Block height the refining PoW window opened |
| `typeCount` | player | Per-struct-type build count for this player |

A row is deleted rather than zeroed when the attribute clears, so absence means zero.

### `structs.struct_defender`

Defense assignments. One row per defender (`defending_struct_id` is the whole primary key), so a struct defends at most one target at a time.

| Column | Type | Notes |
|--------|------|-------|
| `defending_struct_id` | varchar PK | The defender |
| `protected_struct_id` | varchar | The struct being protected |
| `updated_at` | timestamptz | Last assignment change |

> The `planet_activity` `struct_defense_add` / `struct_defense_remove` `detail` uses the key **`defender_struct_id`** (no `-ing`) for what this table calls `defending_struct_id`. Joining the timeline to the table requires translating the name.

### `structs.planet`

| Column | Type | Notes |
|--------|------|-------|
| `id` | varchar PK | `2-{index}` |
| `owner` | varchar | Player ID |
| `max_ore` | integer | Maximum ore capacity |
| `space_slots` / `air_slots` / `land_slots` / `water_slots` | integer | Slot counts |
| `status` | varchar | `active` (claimable/inhabited) or `complete` (ore exhausted) |
| `map` | jsonb | Generated planet map |
| `name` | text | Planet display name (chain UGC; from `MsgPlanetUpdateName` or optional name on `planet-explore`) |

There is **no `seized_ore` column on `structs.planet`.** Seized ore is tracked per raid on `structs.planet_raid` and per token movement in `structs.ledger`.

### `structs.planet_attribute`

| Column | Type | Notes |
|--------|------|-------|
| `id` | varchar PK | `{attrType}-{objectTypeId}-{objectIndex}` |
| `object_id` | varchar | Planet ID |
| `object_type` | varchar | `planet` |
| `attribute_type` | varchar | See below |
| `val` | integer | Attribute value |

| attribute_type | Meaning |
|----------------|---------|
| `planetaryShield` | Current planetary shield value |
| `defensiveCannonQuantity` | Defensive Cannons installed on the planet |
| `lowOrbitBallisticsInterceptorNetworkQuantity` | LOBIN installations |
| `lowOrbitBallisticsInterceptorNetworkSuccessRateNumerator` / `...Denominator` | LOBIN interception rate |

As with `struct_attribute`, a cleared attribute is deleted rather than stored as `0`.

### `structs.planet_raid`

| Column | Type | Notes |
|--------|------|-------|
| `planet_id` | varchar PK | Target planet — **the entire primary key** |
| `fleet_id` | varchar | Raiding fleet |
| `status` | varchar | `initiated`, `shieldsVulnerable`, `raidSuccessful`, `attackerRetreated`, `attackerDefeated`, `demilitarized`. There is **no `completed` value.** |
| `seized_ore` | numeric | Ore taken by the raid this row describes |
| `updated_at` | timestamptz | Last status change |

> **`planet_raid` is latest-state, not history.** Because the primary key is `planet_id` alone, each planet holds exactly one row that is overwritten by every subsequent raid. Do not use this table for raid history or for summing a planet's cumulative losses — it only answers "what is the most recent raid on this planet."

> **Per-raid seized ore: read `planet_activity`.** For raid history, use `planet_activity` rows with `category = 'raid_status'`; their `detail` carries `seized_ore` alongside `planet_id`, `fleet_id`, and `status`. This key was added to `emitRaidStatusActivity` recently, so **rows indexed before the fix are missing it entirely** — on `structstestnet-111` roughly half of `raid_status` rows still lack the key. Treat `detail ? 'seized_ore'` as false meaning *unknown*, not zero, and gate on it explicitly:
>
> ```sql
> SELECT time, planet_id, detail->>'fleet_id' AS fleet_id, detail->>'status' AS status,
>     (detail->>'seized_ore')::numeric AS seized_ore
> FROM structs.planet_activity
> WHERE category = 'raid_status'
>     AND detail ? 'seized_ore'
> ORDER BY time DESC;
> ```
>
> Upstream ships a one-time backfill, `sync-state/sql/repair-raid-status-seized-ore.sql`, that reconstructs the missing values from the ledger. It is an operator task on the guild-stack host, not something an agent should run.

> **The ledger remains the source of truth for token movement.** Seized ore lands as `structs.ledger` rows with `action = 'seized'`, `direction = 'credit'`, `denom = 'ore'`, credited to the thief with the victim in `counterparty`. The ledger preserves **0-gram `seized` rows** — a raid that reached the planet but stole nothing (a probe repelled, or ore already refined away) still writes a meaningful `seized` entry, and on `structstestnet-111` those are the plurality of them. A raid-analytics pipeline should treat 0-gram rows as real outcomes, not noise. Correlate a ledger row to a raid via `block_height` plus the thief's `player_address` → `player.fleet_id`.

---

## The Grid Table (Key-Value Pattern)

`structs.grid` is a **key-value store** for resource attributes. This is the most common source of query errors.

> **GRASS publishing**: grid changes fire `structs.GRID_NOTIFY()`, which `pg_notify`s each change on subject `structs.grid.{object_type}.{object_id}.{player_id}` with a top-level `player_id` field (owner resolved via `player_object`, falling back to `planet.owner`; `noPlayer` when unresolved; for `object_type='player'` the owner is the object itself). The owner segment/field was added 2026-07-07.

| Column | Type | Notes |
|--------|------|-------|
| `id` | varchar PK | `{attributeType}-{objectTypeId}-{objectIndex}` |
| `object_id` | varchar | Player/planet/struct/substation/reactor/provider/allocation ID |
| `object_type` | varchar | `player`, `planet`, `struct`, `substation`, `reactor`, `provider`, `allocation` |
| `object_index` | integer | Numeric portion of `object_id` |
| `attribute_type` | varchar | See table below |
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
| `capacity` | player, reactor, struct, substation | Energy capacity |
| `structsLoad` | player | Energy consumed by active structs |
| `load` | player, provider, reactor, struct, substation | Base load on the object |
| `fuel` | reactor, struct | Total ualpha infused |
| `power` | allocation, struct | Energy carried by an allocation / generated by a generator struct |
| `connectionCapacity` | substation | Capacity granted to **each** connected player — **already the per-player share** `(capacity − load) / connectionCount`. Do **not** divide by `connectionCount` again; that double-dilutes and understates a player's real capacity. |
| `connectionCount` | substation | Active connections |
| `ready` | struct | Block height at which the struct's next action is available |
| `lastAction` | player | Block height of the player's last action (charge-bar basis) |
| `nonce` / `proxyNonce` | player | Signing nonces for the player's own and proxy-signed transactions |
| `checkpointBlock` | provider | Last settlement checkpoint for the provider's agreements |

> Per-infusion `power` is **not** in the grid — it lives on `structs.infusion` as `power` / `power_p`, keyed `(destination_id, address)`. Grid `power` on an `allocation` is the energy that allocation routes; on a `struct` it is what that generator produces.

---

## planet_activity (Event Log)

TimescaleDB hypertable for all planet-level events.

| Column | Type | Notes |
|--------|------|-------|
| `time` | timestamptz | Event time (chain block time; hypertable partition key) |
| `seq` | integer | **Per-planet** counter starting at 0 — see the trap below |
| `planet_id` | varchar | Planet where event occurred |
| `category` | `structs.grass_category` | Event type (see below) |
| `detail` | JSONB | Event-specific data |
| `block_height` | bigint | Block height when the event occurred (populated by sync-state) |

> **`seq` is scoped to a planet, not to the table.** It is drawn from `structs.planet_activity_sequence`, a `(planet_id, counter)` table whose counter is bumped per planet, so every planet has its own series starting at 0 and thousands of rows share any given `seq`. A single scalar high-water mark applied across several planets silently skips events on every planet whose counter is behind the largest one. Track **one cursor per planet**, or order globally on `time` / `block_height` and use `seq` only to disambiguate within a planet.

### Event Categories

`category` is the shared `structs.grass_category` enum, which also labels GRASS notifications that never become `planet_activity` rows (`block`, `guild_consensus`, `guild_meta`, `guild_membership`, `player_consensus`, `player_meta`). The planet-scoped subset actually written to this table:

| Category | Description | Key `detail` fields |
|----------|-------------|---------------------|
| `raid_status` | Raid status transition | `planet_id`, `fleet_id`, `status`, `seized_ore` |
| `fleet_arrive` | Fleet arrived at planet | `fleet_id` |
| `fleet_advance` | Fleet movement in progress | `fleet_id` |
| `fleet_depart` | Fleet departed from planet | `fleet_id` |
| `struct_attack` | Combat attack event | see below |
| `struct_defense_add` | Defense assignment added | `defender_struct_id`, `protected_struct_id` |
| `struct_defense_remove` | Defense assignment removed | `defender_struct_id`, `protected_struct_id` |
| `struct_status` | Struct status change (online/offline/destroyed) | `struct_id`, `status` |
| `struct_move` | Struct moved between slots/ambits | `struct_id`, ambit/slot |
| `struct_health` | Struct health changed (damage) | `struct_id`, health values |
| `struct_block_build_start` | Build PoW window opened | `struct_id`, `block` |
| `struct_block_ore_mine_start` | Mining PoW window opened | `struct_id`, `block` |
| `struct_block_ore_refine_start` | Refining PoW window opened | `struct_id`, `block` |
| `shield_change` | Planetary shield value changed | `planetary_shield`, `planetary_shield_old` |
| `block_raid_start` | Planet's `blockStartRaid` changed (raid clock) | `block_start_raid`, `block_start_raid_old` |

`shield_change` and `block_raid_start` (added v0.18.0) have no dedicated chain event — sync-state derives them from `planet_attribute` writes for `planetaryShield` and `blockStartRaid`, emitting a row only when the value actually changes and carrying both the old and new value. `shield_change` is high-volume: it is the second-largest category on `structstestnet-111` after `struct_status`, so a poller that does not filter by category will spend most of its budget on shield ticks.

`struct_defense_remove` is emitted from the `struct_defender_clear` handler, which is the only path that clears a defender's `protectedStructIndex`. Before that fix the category existed in the enum but was never written, so **defense-removal history is absent from older indexed data** even though additions are present.

### Polling Pattern (Real-Time Monitoring)

Because `seq` is per-planet, initialize and carry a cursor per planet:

```sql
-- Initialize: one high-water mark per watched planet
SELECT planet_id, COALESCE(MAX(seq), 0) AS last_seq
FROM structs.planet_activity
WHERE planet_id IN ('2-105', '2-127')
GROUP BY planet_id;

-- Poll every ~6 seconds, comparing each planet against its own cursor
SELECT pa.planet_id, pa.seq, pa.category, pa.detail::text
FROM structs.planet_activity pa
JOIN (VALUES ('2-105', $LAST_SEQ_2_105), ('2-127', $LAST_SEQ_2_127))
    AS cur(planet_id, last_seq) ON cur.planet_id = pa.planet_id
WHERE pa.seq > cur.last_seq
ORDER BY pa.planet_id, pa.seq ASC;
```

A planet with no rows yet is absent from the initialize query, so default its cursor to `-1` rather than `0` — `seq` starts at 0 and `seq > 0` would drop that planet's first event.

For a single-cursor poller across arbitrary planets, use `block_height` instead, which is globally ordered:

```sql
SELECT planet_id, seq, category, detail::text
FROM structs.planet_activity
WHERE block_height > $LAST_HEIGHT
ORDER BY block_height, planet_id, seq;
```

The `detail` column for `struct_attack` carries the attacker at the top level (`attackerStructId`, `attackerPlayerId`, `attackerStructType`, `weaponSystem`, `weaponControl`, attacker health before/after) plus an `eventAttackShotDetail` array with the per-shot breakdown. **`targetStructId` exists only inside the shot entries, not at the top level** — filtering attacks on a target requires descending into the array (e.g. `detail->'eventAttackShotDetail' @> '[{"targetStructId":"5-6438"}]'`). Each shot entry carries `damage`, `damageDealt`, `evaded`/`evadedCause`, `blocked`/`blockedByStructId`, `armourPiercing`, `damageReduction`/`damageReductionCause`, `targetCountered`/`targetCounteredDamage`, `targetDestroyed`, and `evadedByPlanetaryDefenses`/`Cause`.

**GRASS publishing**: each `planet_activity` insert fires the `structs.PLANET_ACTIVITY_NOTIFY()` trigger, which `pg_notify('grass', …)`s the row with a `subject` of `structs.planet.{planet_id}.{player_id}` (the owning player id was appended 2026-07-07; `noPlayer` when unresolved) plus a top-level `player_id` field. Payloads over ~7995 bytes are sent as a stub — `{subject, planet_id, player_id, seq, category, time, stub:'true'}` with no `detail` — so live consumers pull the full `detail` from this table by `seq`/`planet_id`. See [structs-streaming SKILL](../../.cursor/skills/structs-streaming/SKILL.md).

---

## Energy Commerce Tables

| Table | Key Columns | Notes |
|-------|-------------|-------|
| `reactor` | `id`, `guild_id`, `validator`, `owner` | Links validator address to guild; `owner` is PlayerId |
| `infusion` | `destination_id`, `address`, `destination_type`, `player_id`, `fuel_p`, `power_p`, `ratio_p`, `defusing_p`, `commission` | Composite PK: `(destination_id, address)`. `destination_type` is `reactor` or `struct`. The bare `fuel`/`power`/`ratio`/`defusing` columns are GENERATED from the `_p` values. |
| `allocation` | `id`, `source_id`, `destination_id`, `controller` | Energy routing; `controller` is PlayerId (not address) |
| `substation` | `id`, `owner` | Power distribution nodes |
| `provider` | `id`, `rate_amount`, `rate_denom`, `access_policy` | Energy marketplace listings |
| `agreement` | `id`, provider/consumer refs, capacity, duration | Active purchase contracts |

### `structs.guild`

| Column | Type | Notes |
|--------|------|-------|
| `id` | varchar PK | `0-{index}` (e.g., `0-1`) |
| `entry_rank` | bigint | Default guild rank assigned to new members (chain default: 101) |
| `name` | varchar | Guild display name (chain UGC; from `MsgGuildUpdateName`) |
| `pfp` | varchar | Guild profile picture (chain UGC; from `MsgGuildUpdatePfp`) |

### `structs.guild_meta` (off-chain guild config)

Guild presentation and infrastructure metadata — **not** chain UGC name/pfp (those live on `structs.guild`).

| Column | Type | Notes |
|--------|------|-------|
| `id` | varchar PK | Guild ID, mirrors `structs.guild.id` |
| `name` | varchar | Legacy display name field (prefer `structs.guild.name` for on-chain UGC) |
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

### `structs.substation` (with UGC fields)

| Column | Type | Notes |
|--------|------|-------|
| `id` | varchar PK | Substation ID |
| `owner` | varchar | Owner player ID |
| `name` | varchar | Substation name (chain UGC; from `MsgSubstationUpdateName`) |
| `pfp` | varchar | Substation profile picture (chain UGC; from `MsgSubstationUpdatePfp`) |

### `structs.permission_guild_rank`

| Column | Type | Notes |
|--------|------|-------|
| `object_id` | varchar | The object permissions are set on |
| `guild_id` | varchar | The guild whose members receive the permission |
| `permission` | bigint | Single permission bit (power of 2) |
| `rank` | bigint | Worst-allowed guild rank; 0 = revoked |
| `updated_at` | timestamptz | Last update timestamp |

Primary key: `(object_id, guild_id, permission)`. See [permissions.md](../mechanics/permissions.md) for the guild rank permission system.

The `view.permission_player` (keyed by `player_id`) and `view.permission_address` (keyed by `address`) views project `structs.permission` rows joined with `permission_guild_rank`, exposing one boolean column per permission bit (`perm_play`, `perm_admin`, …, `perm_hash_build`/`perm_hash_mine`/`perm_hash_refine`/`perm_hash_raid`). The raw integer bitmask (`val`) lives on the base table `structs.permission`. The `PermAll` mask is `33554431` (bits 0..24 set).

### `sync_state` schema (indexer)

Written by `structs-sync-state`. Key operator tables:

| Table | Purpose |
|-------|---------|
| `sync_cursor` | Per-chain ingest pointer (`last_height`, `status`, `lag_blocks`, `tip_height`). `status` is `catching_up` while behind and `current` once caught up. |
| `block_log` | One row per ingested block (tx/event counts, handler error count) |
| `handler_error_log` | Per-event handler failures (for debugging replay) |
| `unknown_event_log` | Chain events with no registered handler — first place to look when a new chain version adds an event the indexer does not yet project |
| `genesis_log` | Genesis import record |
| `raw_blocks`, `raw_tx_results`, `raw_events`, `raw_attributes` | Raw chain event storage — **populated only when `SYNC_STATE_MIRROR_RAW=true`**, which the default Compose sets to `false`. Do not plan a query path around them without checking. |
| `verification_report` | Output of sync-state verify runs |

`structs.current_block` mirrors the same cursor (`chain`, `height`, `status`, `lag_blocks`, `tip_height`) as an unlogged single-row table, which is the cheaper read when all you need is "what block are we on."

Monitor indexer health:

```sql
SELECT chain_id, last_height, status, lag_blocks, tip_height
FROM sync_state.sync_cursor;
```

The `cache` schema exposes four **views** (`blocks`, `tx_results`, `events`, `attributes`) over `sync_state.raw_*` for webapp backward compatibility.

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

Seeded keys: `REACTOR_RATIO`, `PLAYER_RESUME_CHARGE`, `PLANETARY_SHIELD_BASE`, `PLAYER_PASSIVE_DRAW`, `PLANET_STARTING_ORE`, `PLANET_STARTING_SLOTS`, `STRUCT_SWEEP_DELAY`. Treat the table as an open name/value map — keys are added over time.

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

The `view` schema holds 21 views. The ones worth reaching for:

| View | Purpose |
|------|---------|
| `view.player` / `view.guild` / `view.planet` / `view.struct` / `view.substation` / `view.reactor` | Object rows pre-joined with their grid attributes, so a single `SELECT` replaces the multi-JOIN grid pattern below |
| `view.grid` | Grid rows resolved to object type/owner labels |
| `view.struct_status` | Struct status bitfield decoded into readable flags |
| `view.guild_bank` | Per-guild Central Bank position — minted/redeemed token balances, collateral, and outstanding supply, joined from `structs.guild`, the on-chain bank module, and ledger movements |
| `view.player_inventory` / `view.guild_inventory` / `view.address_inventory` / `view.reactor_inventory` | Token balances per player, guild, address, and reactor |
| `view.leaderboard_guild` / `view.leaderboard_player` | Ranked scoreboards (members, ore mined, planets completed, raids launched, raids successful) |
| `view.leaderboard_provider` / `view.leaderboard_reactor` / `view.leaderboard_substation` | Energy-market scoreboards |
| `view.permission_player` / `view.permission_address` | Permission bitmask projected to one boolean column per bit |
| `view.work` | Outstanding proof-of-work windows |

Use views, not raw tables, when building leaderboard, inventory, or treasury surfaces — the views absorb the `seized_ore`, ledger, and infusion joins so the upstream surface stays stable when underlying tables change.

---

## Other Time-Series Tables (TimescaleDB)

| Hypertable | Purpose | Key Columns |
|------------|---------|-------------|
| `ledger` | Financial transaction log | `time`, `id`, `address`, `counterparty`, `amount_p`, `amount`, `action`, `direction`, `denom`, `block_height` |
| `stat_ore` | Ore value history | `time`, `object_type`, `object_index`, `value` |
| `stat_capacity` | Capacity history | Same pattern (has `object_type`) |
| `stat_fuel` | Fuel history | Same pattern (has `object_type`) |
| `stat_load` | Load history | Same pattern (has `object_type`) |
| `stat_power` | Power history | Same pattern (has `object_type`) |
| `stat_structs_load` | structsLoad over time | `time`, `object_index`, `value` — **no `object_type`** |
| `stat_connection_capacity` | Per-connection substation share over time | `time`, `object_index`, `value` — **no `object_type`** |
| `stat_connection_count` | Substation connection count over time | `time`, `object_index`, `value` — **no `object_type`** |
| `stat_struct_health` | Struct health over time | `time`, `object_index`, `value` — **no `object_type`** |
| `stat_struct_status` | Struct status over time | `time`, `object_index`, `value` — **no `object_type`** |

> **Type-implied stat tables (silent-wrong-row trap).** Five hypertables — `stat_structs_load`, `stat_connection_capacity`, `stat_connection_count`, `stat_struct_health`, `stat_struct_status` — have **no `object_type` column** (verified in `structs-pg/deploy/table-stat.sql`). The object type is *implied by the table itself* (e.g. `stat_connection_*` and `stat_structs_load` are player/substation series; `stat_struct_*` are struct series). A generic helper that joins every stat table on `(object_type, object_index)` will silently read the wrong rows against these five — filter on `object_index` alone and rely on the table name for the type. This mirrors the note in [api/webapp/stat.md](../../api/webapp/stat.md).

### Ledger Action Types

`genesis`, `received`, `sent`, `migrated`, `infused`, `defusion_started`, `defusion_cancelled`, `defusion_completed`, `mined`, `refined`, `seized`, `forfeited`, `minted`, `burned`, `diversion_started`, `diversion_completed`

Each row is one side of a movement: `address` is the party the row belongs to, `counterparty` is the other side, and `direction` (`credit`/`debit`) gives the sign. `amount_p` is the raw integer; `amount` is GENERATED via `unit_legacy_format(amount_p, denom)` for display. Use `amount_p` for arithmetic and for matching.

> **Historical duplicate rows on `refined` and `infused` (affects any balance query).** Two chain messages each produced *two* ledger rows for the same movement, because sync-state's event handler and the Cosmos bank-event handler both wrote one:
>
> | Message | Correct row | Spurious duplicate |
> |---------|-------------|--------------------|
> | `MsgStructOreRefineryComplete` | `refined` credit, `ualpha` | `received` credit, `ualpha` |
> | `MsgStructGeneratorInfuse` | `infused` debit, `ualpha` | `sent` debit, `ualpha` |
>
> The duplicate shares the same `address`, `time`, `block_height`, and `amount_p` as the correct row. Current sync-state suppresses the bank-side row, but **the duplicates persist in already-indexed data** — on `structstestnet-111` there are 123 refine and 13 infusion pairs still present. Any query of the form `SUM(CASE direction WHEN 'credit' THEN amount ELSE -amount END)` over `ualpha` therefore double-counts every historical refine and infusion. Until an operator runs the upstream repairs (`sync-state/sql/repair-refine-ledger-dupes.sql`, `repair-infusion-ledger-dupes.sql`), exclude the shadowed actions when computing a net position:
>
> ```sql
> SELECT address, denom,
>     SUM(CASE direction WHEN 'credit' THEN amount_p ELSE -amount_p END) AS net
> FROM structs.ledger l
> WHERE NOT (
>         l.denom = 'ualpha'
>     AND l.action IN ('received', 'sent')
>     AND EXISTS (
>         SELECT 1 FROM structs.ledger d
>          WHERE d.address = l.address
>            AND d.time = l.time
>            AND d.block_height = l.block_height
>            AND d.amount_p = l.amount_p
>            AND d.denom = 'ualpha'
>            AND d.action = CASE l.action WHEN 'received' THEN 'refined'::structs.ledger_action
>                                         ELSE 'infused'::structs.ledger_action END
>     ))
> GROUP BY address, denom;
> ```
>
> `seized` and `mined` were never duplicated, so ore analytics are unaffected.

---

## Signer Schema (Transaction Signing Agent)

The TSA (Transaction Signing Agent, [`playstructs/structs-tsa`](https://github.com/playstructs/structs-tsa)) manages a pool of signing accounts. Services insert rows into `signer.tx` with `status='pending'`. TSA claims them, signs, and broadcasts.

| Table | Key Columns | Notes |
|-------|-------------|-------|
| `signer.role` | `id`, `player_id`, `guild_id`, `status` | Status: `stub`, `generating`, `pending`, `ready` |
| `signer.account` | `id`, `role_id`, `address`, `status` | Status: `stub`, `generating`, `pending`, `available`, `signing` |
| `signer.tx` | `id`, `module`, `command`, `args` (JSONB), `status` | Status: `pending`, `claimed`, `broadcast`, `error`. 100+ command types. |

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

### `PLAYER_PENDING_JOIN_PROXY`

The `PLAYER_PENDING_JOIN_PROXY` trigger threads `username` and `pfp` from the pending row through to `signer.CREATE_TRANSACTION` for the `guild-membership-join-proxy` command, packaged into the `ugc` JSONB argument. The webapp's signup flow is:

```text
webapp signup
  -> structs.player_pending row (with username, pfp)
  -> PLAYER_PENDING_JOIN_PROXY trigger
  -> signer.tx (command=guild-membership-join-proxy, args.ugc={username, pfp, ...})
  -> TSA claims, signs MsgGuildMembershipJoinProxy with playerName/playerPfp
  -> chain validates name/pfp, creates player, sync-state writes username/pfp to structs.player
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
- `schemas/database-schema.md` -- Full structural schema catalog
- `knowledge/entities/entity-relationships.md` -- Full entity graph and ID format
- `knowledge/entities/struct-types.md` -- Struct type stats (mirrors `struct_type` table)
