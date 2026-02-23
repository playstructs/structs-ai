# GRASS Event Types

**Version**: 1.0.0
**Last Updated**: 2026-01-16
**Description**: Complete catalog of GRASS event types and categories

---

## Event Categories

### Consensus Events

| Event Name | Description | Subject Pattern | Schema |
|------------|-------------|-----------------|--------|
| block | Block updates | `structs.block.*` | `event-schemas.md#BlockEvent` |

### Guild Events

| Event Name | Description | Subject Pattern | Schema |
|------------|-------------|-----------------|--------|
| guild_consensus | Guild consensus data updates | `structs.guild.*` | `event-schemas.md#GuildConsensusEvent` |
| guild_meta | Guild metadata updates | `structs.guild.*` | `event-schemas.md#GuildMetaEvent` |
| guild_membership | Guild membership changes | `structs.guild.*` | `event-schemas.md#GuildMembershipEvent` |

### Planet Events

| Event Name | Description | Subject Pattern | Schema |
|------------|-------------|-----------------|--------|
| raid_status | Raid status changes | `structs.planet.*` | `event-schemas.md#PlanetRaidStatusEvent` |
| planet_activity | Planet activity events from planet_activity table, including struct_health details | `structs.planet.*` | `event-schemas.md#PlanetActivityEvent` |
| fleet_arrive | Fleet arrival | `structs.fleet.*` | `event-schemas.md#FleetArriveEvent` |
| fleet_advance | Fleet advancement | `structs.fleet.*` | -- |
| fleet_depart | Fleet departure | `structs.fleet.*` | -- |

### Struct Events

| Event Name | Description | Subject Pattern | Schema |
|------------|-------------|-----------------|--------|
| struct_attack | Struct attack events | `structs.struct.*` | -- |
| struct_defense_remove | Defense structure removed | `structs.struct.*` | -- |
| struct_defense_add | Defense structure added | `structs.struct.*` | -- |
| struct_defender_clear | Defense relationships cleared from a struct | `structs.struct.*` | -- |
| struct_status | Struct status changes | `structs.struct.*` | `event-schemas.md#StructStatusEvent` |
| struct_move | Struct movement | `structs.struct.*` | -- |
| struct_block_build_start | Build operation started | `structs.struct.*` | -- |
| struct_block_ore_mine_start | Mining operation started | `structs.struct.*` | -- |
| struct_block_ore_refine_start | Refining operation started | `structs.struct.*` | -- |

### Player Events

| Event Name | Description | Subject Pattern | Schema |
|------------|-------------|-----------------|--------|
| player_consensus | Player consensus data updates | `structs.player.*` | `event-schemas.md#PlayerConsensusEvent` |
| player_meta | Player metadata updates | `structs.player.*` | `event-schemas.md#PlayerMetaEvent` |

### Address Events

| Event Name | Description | Subject Pattern |
|------------|-------------|-----------------|
| address_register | Address registration events | `structs.address.register.*` |

---

## Subject Patterns

| Entity | Pattern | Specific Format | Example |
|--------|---------|-----------------|---------|
| Player | `structs.player.*` | `structs.player.{guild_id}.{player_id}` | `structs.player.0-1.1-11` |
| Guild | `structs.guild.*` | `structs.guild.{guild_id}` | `structs.guild.0-1` |
| Planet | `structs.planet.*` | `structs.planet.{planet_id}` | `structs.planet.3-1` |
| Struct | `structs.struct.*` | `structs.struct.{struct_id}` | `structs.struct.5-1` |
| Fleet | `structs.fleet.*` | `structs.fleet.{fleet_id}` | `structs.fleet.7-1` |
| Address | `structs.address.register.*` | `structs.address.register.{code}` | `structs.address.register.ABC123` |
| Global | `structs.global` | `structs.global` | `structs.global` |

---

## Related Documentation

- `api/streaming/event-schemas.md` - Event schema definitions
- `api/streaming/subscription-patterns.md` - Subscription patterns
- `protocols/streaming.md` - Streaming protocol
- `api/streaming/README.md` - Streaming overview
