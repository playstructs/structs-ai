# GRASS Event Types

**Version**: 1.1.0
**Last Updated**: 2026-07-07
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
| guild_rank_permission | Guild rank permissions set or revoked | `structs.guild.*` | `event-schemas.md#EventGuildRankPermission` |

### Planet Events

These are `planet_activity` rows; they arrive on the **planet subject** `structs.planet.{planet_id}.{player_id}` (the owning player id was appended 2026-07-07; subscribe with `structs.planet.{planet_id}.*`). Every payload also carries a top-level `player_id` (or `noPlayer` when unresolved).

| Event Name | Description | Subject Pattern | Schema |
|------------|-------------|-----------------|--------|
| raid_status | Raid status changes | `structs.planet.*.*` | `event-schemas.md#PlanetRaidStatusEvent` |
| shield_change | Planetary shield value changed (`planetary_shield` / `planetary_shield_old`) | `structs.planet.*.*` | -- |
| block_raid_start | Raid vulnerability clock (`blockStartRaid`) armed | `structs.planet.*.*` | -- |
| planet_activity | Generic planet activity wrapper from the `planet_activity` table | `structs.planet.*.*` | `event-schemas.md#PlanetActivityEvent` |
| fleet_arrive | Fleet arrival | `structs.planet.*.*` | `event-schemas.md#FleetArriveEvent` |
| fleet_depart | Fleet departure | `structs.planet.*.*` | -- |

> `fleet_advance` exists in the category enum but is **not emitted** by the current indexer — fleet movement surfaces as `fleet_depart` then `fleet_arrive`. Do not wait on `fleet_advance`.

### Struct Events

These are `planet_activity` rows and arrive on the **planet subject** `structs.planet.{planet_id}.{player_id}` (not the struct subject; subscribe `structs.planet.{planet_id}.*`). See [struct_attack stubbing](#struct_attack-payload-stubbing) below.

| Event Name | Description | Subject Pattern | Schema |
|------------|-------------|-----------------|--------|
| struct_attack | Struct attack (per-shot `detail`; **stubbed when large** — see below) | `structs.planet.*.*` | -- |
| struct_health | Struct HP changed (`health` / `health_old`) | `structs.planet.*.*` | -- |
| struct_defense_remove | Defense structure removed | `structs.planet.*.*` | -- |
| struct_defense_add | Defense structure added | `structs.planet.*.*` | -- |
| struct_defender_clear | Defense relationships cleared from a struct | `structs.planet.*.*` | -- |
| struct_status | Struct status changes (online / offline / destroyed) | `structs.planet.*.*` | `event-schemas.md#StructStatusEvent` |
| struct_move | Struct movement | `structs.planet.*.*` | -- |
| struct_block_build_start | Build operation started | `structs.planet.*.*` | -- |
| struct_block_ore_mine_start | Mining operation started | `structs.planet.*.*` | -- |
| struct_block_ore_refine_start | Refining operation started | `structs.planet.*.*` | -- |

#### struct_attack payload stubbing

`struct_attack` is published live, but the NATS NOTIFY payload is capped at ~8000 bytes. When a `planet_activity` row's payload exceeds 7995 bytes, the stream sends a **stub** — `{ "subject": "structs.planet.{planet_id}.{player_id}", "planet_id": ..., "player_id": ..., "seq": ..., "category": "struct_attack", "time": ..., "stub": "true" }` with **no `detail`** (note `stub` is the string `"true"`). Detect combat from the effect events (`struct_health`, `struct_status`, `shield_change`, `raid_status`), then pull the full shot detail from the Guild API `planet-activity` feed keyed by `seq`/`planet_id`. Small attacks ship `detail` inline.

### Player Events

| Event Name | Description | Subject Pattern | Schema |
|------------|-------------|-----------------|--------|
| player_consensus | Player state updates, including UGC `username`/`pfp` on `structs.player` | `structs.player.>` | `event-schemas.md#PlayerConsensusEvent` |
| player_address | Address added to / changed on a player | `structs.player.>` | -- |
| player_address_pending | Pending address registration appeared | `structs.player.>` | -- |

### Address Events

| Event Name | Description | Subject Pattern |
|------------|-------------|-----------------|
| address_register | Address registration events | `structs.address.register.*` |

### UGC Moderation Events (Cosmos chain events, not GRASS)

`ugc_moderated` is emitted as a regular Cosmos `sdk.Event` by the keeper (not by the GRASS DB-trigger pipeline) whenever a UGC name/pfp update is performed by an actor who is not the target object's owner. Subscribe via Tendermint event subscriptions (`tx.events`/`block_events`), not via NATS.

| Event Name | Description | Source | Schema |
|------------|-------------|--------|--------|
| ugc_moderated | A guild moderator overwrote another player's name/pfp, or the name/pfp of a planet/substation owned by a guild-mate | Cosmos chain event (`sdk.Event`, type `ugc_moderated`) | `event-schemas.md#UGCModeratedEvent` |

The chain only emits this event when `actor_player_id != target_owner_player_id`. Self-service updates (a player renaming themselves, a guild owner renaming their own guild) are silent.

The corresponding `player_consensus` GRASS events fire when sync-state commits UGC updates to `structs.player`. `guild_meta` fires for off-chain guild config on `structs.guild_meta`. Chain UGC on `structs.guild`, `structs.planet`, and `structs.substation` surface through chain events and `planet_activity`.

---

## Subject Patterns

| Entity | Pattern | Specific Format | Example |
|--------|---------|-----------------|---------|
| Player | `structs.player.>` | `structs.player.{guild_id}.{player_id}` | `structs.player.0-1.1-11` |
| Guild | `structs.guild.*` | `structs.guild.{guild_id}` | `structs.guild.0-1` |
| Planet | `structs.planet.>` | `structs.planet.{planet_id}.{player_id}` | `structs.planet.3-1.1-11` |
| Struct | `structs.struct.*` | `structs.struct.{struct_id}` | `structs.struct.5-1` |
| Fleet | `structs.fleet.*` | `structs.fleet.{fleet_id}` | `structs.fleet.7-1` |
| Address | `structs.address.register.*` | `structs.address.register.{code}` | `structs.address.register.ABC123` |
| Grid | `structs.grid.>` | `structs.grid.{object_type}.{object_id}.{player_id}` | `structs.grid.struct.5-1.1-11` |
| Global | `structs.global` | `structs.global` | `structs.global` |

> **NATS wildcard rule**: `*` matches exactly one token; `>` matches one or more trailing tokens. Since grid and planet subjects now end with the owner `player_id`, `structs.planet.*` (two tokens) no longer matches — use `structs.planet.{planet_id}.*` for one planet or `structs.planet.>` for all. The player subject is three tokens (`structs.player.{guild_id}.{player_id}`), so use `structs.player.>`. Payloads for grid/planet events also carry a top-level `player_id` (or `noPlayer`).

---

## Related Documentation

- `api/streaming/event-schemas.md` - Event schema definitions
- `api/streaming/subscription-patterns.md` - Subscription patterns
- `protocols/streaming.md` - Streaming protocol
- `api/streaming/README.md` - Streaming overview
