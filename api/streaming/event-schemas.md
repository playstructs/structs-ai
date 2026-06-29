# GRASS Event Schemas

**Version**: 1.1.0
**Category**: streaming

Complete catalog of GRASS event payload schemas for AI agents.

---

## Base Event

All GRASS events share a common base structure.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| subject | string | Yes | NATS subject for this event. Pattern: `^structs\..+$` |
| category | string | Yes | Event category (see `event-types.yaml`) |
| id | string | Yes | Entity identifier |
| updated_at | string (date-time) | Yes | ISO 8601 timestamp of update |

> **`detail` has two representations depending on transport.** Over **NATS/GRASS** the frame is parsed once (`message.json()`), so `detail` arrives as an **already-parsed object** — access `detail.*` directly. Over the **Guild API `planet-activity` REST feed** the same `detail` comes from a PostgreSQL column as a **JSON-encoded string** — you must `JSON.parse(row.detail)` first. Code that consumes both transports must branch on the source. See [api/integration-notes.md — Event detail has two representations](../integration-notes.md#event-detail-has-two-representations).

---

## Event Definitions

### PlayerConsensusEvent

Extends [BaseEvent](#base-event). Category: `player_consensus`

**Data Fields**:

| Field | Type | Description |
|-------|------|-------------|
| id | string | Player ID |
| guildId | string | Guild ID |
| primaryAddress | string | Player primary address |
| username | string | Player display name (on `structs.player`; from chain UGC) |
| pfp | string | Profile picture URI (on `structs.player`; from chain UGC) |

Fires when sync-state commits an insert or update to `structs.player`, including UGC changes from `MsgPlayerUpdateName` / `MsgPlayerUpdatePfp` or signup proxy.

### GuildConsensusEvent

Extends [BaseEvent](#base-event). Category: `guild_consensus`

**Data Fields**: Guild consensus data object.

### GuildMetaEvent

Extends [BaseEvent](#base-event). Category: `guild_meta`

**Data Fields**:

| Field | Type | Description |
|-------|------|-------------|
| id | string | Guild ID |
| description | string | Guild description (off-chain config on `structs.guild_meta`) |
| tag | string | Short guild tag |
| logo | string | Logo URI |
| services | object | Guild API / GRASS / webapp endpoint map |

Chain UGC `name` and `pfp` live on `structs.guild` and surface via `guild_consensus` / chain events — not through `guild_meta`.

### UGCModeratedEvent (Cosmos chain event)

**Not** delivered through GRASS. This is a typed Cosmos `sdk.Event` of type `ugc_moderated` emitted by the chain keeper. Subscribe via Tendermint event subscriptions (`tx.events`/`block_events`).

Fires only when the actor of a UGC update is **not** the target object's owner (i.e. moderation overrides only — self-service updates are silent).

**Attributes**:

| Attribute | Description |
|-----------|-------------|
| `actor_player_id` | Player ID of the moderator |
| `actor_address` | Signing address that authored the tx |
| `target_object_id` | Player / planet / substation / guild ID being moderated |
| `target_owner_player_id` | Owner player ID at the time of the update |
| `field` | `name` or `pfp` |
| `old_value` | Field value before the update |
| `new_value` | Field value after the update |

See `knowledge/mechanics/ugc-moderation.md` for the full philosophy and validation rules.

### GuildMembershipEvent

Extends [BaseEvent](#base-event). Category: `guild_membership`

**Data Fields**: Guild membership change data object.

### EventGuildRankPermission

Extends [BaseEvent](#base-event). Category: `guild_rank_permission`

Fires when guild rank permissions are set or revoked on an object.

**Data Fields**:

| Field | Type | Description |
|-------|------|-------------|
| guildRankPermissionRecord | object | Guild rank permission record |
| guildRankPermissionRecord.objectId | string | Object the permission applies to |
| guildRankPermissionRecord.guildId | string | Guild ID |
| guildRankPermissionRecord.permissions | integer | Permission bitmask (single bit, decomposed) |
| guildRankPermissionRecord.rank | integer | Worst-allowed rank for this permission bit (0 = revoked) |

```json
{
  "guildRankPermissionRecord": {
    "objectId": "6-1",
    "guildId": "0-1",
    "permissions": 4,
    "rank": 3
  }
}
```

### PlanetRaidStatusEvent

Extends [BaseEvent](#base-event). Category: `raid_status`

**Data Fields**:

| Field | Type | Description |
|-------|------|-------------|
| status | string | Raid outcome. One of: `victory` (attacker won), `defeat` (attacker lost), `attackerRetreated` (attacker retreated from raid) |
| attackerId | string | Attacker player ID |
| planetId | string | Target planet ID |

### PlanetActivityEvent

Extends [BaseEvent](#base-event). Category: `planet_activity`

**Data Fields**:

| Field | Type | Description |
|-------|------|-------------|
| planetId | string | Planet ID associated with this activity |
| details | object | Activity details (JSONB from `planet_activity` table) |
| details.struct_health | object | Struct health information (additional properties allowed) |

### FleetArriveEvent

Extends [BaseEvent](#base-event). Category: `fleet_arrive`

**Data Fields**: Fleet arrival data object.

### StructAttackEvent

Extends [BaseEvent](#base-event). Category: `struct_attack`

The `detail` payload has the **attacker context flat at the top** and the **per-projectile outcomes nested** in `eventAttackShotDetail[]` (one entry per shot). Field keys are camelCase (unlike most other struct events).

**Top-level (attacker) fields**:

| Field | Type | Description |
|-------|------|-------------|
| attackerStructId | string | Attacking struct ID |
| attackerStructType | integer | Attacker struct type ID |
| attackerStructOperatingAmbit | integer | Attacker ambit (enum: water=1…space=4) |
| weaponSystem | integer | 0 = primary, 1 = secondary |
| weaponControl | integer | Weapon control value |
| recoilDamage | integer | Recoil damage amount |
| recoilDamageToAttacker | boolean | Whether recoil hit the attacker |
| planetaryDefenseCannonDamage | integer | PDC damage contribution |
| attackerPlayerId | string | Attacking player ID |
| targetPlayerId | string | Defending player ID |
| eventAttackShotDetail | array | Per-projectile shot outcomes (see below) |

**`eventAttackShotDetail[]` (per-projectile) fields**:

| Field | Type | Description |
|-------|------|-------------|
| targetStructId | string | Struct hit by this shot |
| targetStructType | integer | Target struct type ID |
| evaded | boolean | Shot evaded |
| evadedCause | integer | Evasion cause code |
| blocked | boolean | Shot absorbed by a defender |
| blockedByStructId | string | Defender struct that blocked (empty if none) |
| damageDealt | integer | Final damage applied |
| damage | integer | Pre-reduction damage |
| damageReduction | integer | Damage reduced by armor/effects |
| targetDestroyed | boolean | Target reached 0 HP |
| targetCountered | boolean | Target fired a counter |
| targetCounteredDamage | integer | Counter damage dealt back |

> `attackerHealthBefore`, `targetHealthBefore`, and `targetHealthAfter` are **runtime-enriched** fields present on the live activity feed (used for animation) and are not part of the canonical protobuf type; they may arrive as strings. See [api/integration-notes.md — struct_attack event detail schema](../integration-notes.md#struct_attack-event-detail-schema) and [combat.md](../../knowledge/mechanics/combat.md#attack-resolution-sequence).

> **Stubbing on the live stream.** The NATS NOTIFY payload is capped at ~8000 bytes. When a `struct_attack` row's full `detail` exceeds 7995 bytes (typical of multi-shot, multi-defender fights), the realtime stream sends a **stub** — `{ "category": "struct_attack", "stub": true, "planet_id": ..., "seq": ..., "time": ... }` with **no `detail`**. The full `eventAttackShotDetail[]` is then only available by pulling the Guild API `planet-activity` row (keyed by `seq`/`planet_id`). Detect combat from the effect events that always stream in full (`struct_health`, `struct_status`, `shield_change`, `raid_status`); use the pull for per-shot detail. Small attacks ship `detail` inline.

### StructStatusEvent

Extends [BaseEvent](#base-event). Category: `struct_status`

**Data Fields**: Struct status change data object.

### BlockEvent

Extends [BaseEvent](#base-event). Category: `block`

**Data Fields**:

| Field | Type | Description |
|-------|------|-------------|
| height | integer | Block height |
| hash | string | Block hash |

---

## Event Categories

All `planet`/`struct` categories below are `planet_activity` rows delivered on `structs.planet.{id}`.

| Category Group | Event Types |
|----------------|-------------|
| consensus | `block` |
| guild | `guild_consensus`, `guild_meta`, `guild_membership` |
| planet | `raid_status`, `shield_change`, `block_raid_start`, `fleet_arrive`, `fleet_depart`, `planet_activity` |
| struct | `struct_attack`, `struct_health`, `struct_defense_remove`, `struct_defense_add`, `struct_defender_clear`, `struct_status`, `struct_move`, `struct_block_build_start`, `struct_block_ore_mine_start`, `struct_block_ore_refine_start` |
| player | `player_consensus`, `player_address`, `player_address_pending` |
| grid (`structs.grid.{object}`) | attribute names: `ore`, `fuel`, `capacity`, `load`, `structsLoad`, `power`, `connectionCapacity`, `connectionCount`, `allocationPointerStart`, `allocationPointerEnd`, `proxyNonce`, `lastAction`, `nonce`, `ready`, `checkpointBlock` |
| inventory (`structs.inventory.{denom}…`) | ledger actions: `genesis`, `received`, `sent`, `migrated`, `infused`, `defusion_started`, `defusion_cancelled`, `defusion_completed`, `mined`, `refined`, `seized`, `forfeited`, `minted`, `burned`, `diversion_started`, `diversion_completed` |
| address | `address_register` |

> Not emitted by the current indexer (present in the enum/older docs only): `fleet_advance` and `player_meta`. Do not subscribe expecting them.

---

## Related Documentation

- [Event Types](event-types.yaml)
- [Streaming Protocol](../../protocols/streaming.md)
