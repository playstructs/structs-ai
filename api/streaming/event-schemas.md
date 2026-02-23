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
| username | string | Player username |

### GuildConsensusEvent

Extends [BaseEvent](#base-event). Category: `guild_consensus`

**Data Fields**: Guild consensus data object.

### GuildMetaEvent

Extends [BaseEvent](#base-event). Category: `guild_meta`

**Data Fields**:

| Field | Type | Description |
|-------|------|-------------|
| id | string | Guild ID |
| name | string | Guild name |

### GuildMembershipEvent

Extends [BaseEvent](#base-event). Category: `guild_membership`

**Data Fields**: Guild membership change data object.

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
| guild | `guild_consensus`, `guild_meta`, `guild_membership` |
| planet | `raid_status`, `fleet_arrive`, `fleet_advance`, `fleet_depart`, `planet_activity` |
| struct | `struct_attack`, `struct_defense_remove`, `struct_defense_add`, `struct_defender_clear`, `struct_status`, `struct_move`, `struct_block_build_start`, `struct_block_ore_mine_start`, `struct_block_ore_refine_start` |
| player | `player_consensus`, `player_meta` |

---

## Related Documentation

- [Event Types](event-types.yaml)
- [Streaming Protocol](../../protocols/streaming.md)
