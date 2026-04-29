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

### PlayerMetaEvent

Extends [BaseEvent](#base-event). Category: `player_meta`

**Data Fields**:

| Field | Type | Description |
|-------|------|-------------|
| id | string | Player ID |
| username | string | Player username (UGC; updated by `MsgPlayerUpdateName`, validated against `ValidatePlayerName`) |
| pfp | string | Player profile picture (UGC; updated by `MsgPlayerUpdatePfp`, validated against `ValidatePfp`). Empty string if not set. |

This event fires when the cache layer commits an update to `structs.player_meta`. As of v0.16.0 the chain is the sole source of truth for `username` and `pfp` -- the database `player_meta` table is no longer written by the webapp; both fields are populated from `MsgPlayerUpdateName` / `MsgPlayerUpdatePfp` (or from `MsgGuildMembershipJoinProxy.playerName` / `playerPfp` at signup).

### GuildConsensusEvent

Extends [BaseEvent](#base-event). Category: `guild_consensus`

**Data Fields**: Guild consensus data object.

### GuildMetaEvent

Extends [BaseEvent](#base-event). Category: `guild_meta`

**Data Fields**:

| Field | Type | Description |
|-------|------|-------------|
| id | string | Guild ID |
| name | string | Guild name (UGC; updated by `MsgGuildUpdateName`, validated against `ValidateEntityName`) |
| pfp | string | Guild profile picture (UGC; updated by `MsgGuildUpdatePfp`, validated against `ValidatePfp`). Empty string if not set. |

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
    "guildId": "4-1",
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

| Category Group | Event Types |
|----------------|-------------|
| consensus | `block` |
| guild | `guild_consensus`, `guild_meta`, `guild_membership`, `guild_rank_permission` |
| planet | `raid_status`, `fleet_arrive`, `fleet_advance`, `fleet_depart`, `planet_activity` |
| struct | `struct_attack`, `struct_defense_remove`, `struct_defense_add`, `struct_defender_clear`, `struct_status`, `struct_move`, `struct_block_build_start`, `struct_block_ore_mine_start`, `struct_block_ore_refine_start` |
| player | `player_consensus`, `player_meta` |

---

---

## Breaking Changes

- **`targetPlayerId` moved**: The `targetPlayerId` field has moved from `EventAttackDetail` to `EventAttackShotDetail`. Clients parsing attack events must update to read this field from the shot detail level instead of the top-level attack detail.

---

## Related Documentation

- [Event Types](event-types.yaml)
- [Streaming Protocol](../../protocols/streaming.md)
