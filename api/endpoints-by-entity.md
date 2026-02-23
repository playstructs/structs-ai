# API Endpoints by Entity

**Version**: 1.0.0
**Last Updated**: 2025-01-XX
**Description**: API endpoints organized by entity type for easier discovery

---

## Player

Player entity endpoints.

### Queries

| ID | Method | Path | Base | Description |
|----|--------|------|------|-------------|
| player-by-id | GET | `/structs/player/{id}` | Consensus | Get player by ID |
| webapp-player-by-id | GET | `/api/player/{player_id}` | Webapp | Get player by ID |
| webapp-player-ore-stats | GET | `/api/player/{player_id}/ore/stats` | Webapp | Get player ore statistics |
| webapp-player-action-last-block | GET | `/api/player/{player_id}/action/last/block/height` | Webapp | Get player's last action block height |
| webapp-player-completed-planets | GET | `/api/player/{player_id}/planet/completed` | Webapp | Get player's completed planets |
| webapp-player-launched-raids | GET | `/api/player/{player_id}/raid/launched` | Webapp | Get player's launched raids |

### Actions

| ID | Method | Path | Base | Description |
|----|--------|------|------|-------------|
| webapp-player-username-update | PUT | `/api/player/username` | Webapp | Update player username |

### Dependencies

| Entity | Relationship | Description |
|--------|-------------|-------------|
| Guild | memberOf | Player may be a member of a guild |
| Planet | owns | Player may own planets |
| Struct | owns | Player may own structs |

### Streaming

| Subject | Events | Schema |
|---------|--------|--------|
| `structs.player.*` | player_consensus, player_meta | `api/streaming/event-schemas.md#PlayerConsensusEvent` |

---

## Planet

Planet entity endpoints.

### Queries

| ID | Method | Path | Base | Description |
|----|--------|------|------|-------------|
| planet-by-id | GET | `/structs/planet/{id}` | Consensus | Get planet by ID |
| planet-by-player | GET | `/structs/planet_by_player/{playerId}` | Consensus | Get planets owned by player |
| webapp-planet-by-id | GET | `/api/planet/{planet_id}` | Webapp | Get planet by ID |
| webapp-planet-shield-health | GET | `/api/planet/{planet_id}/shield/health` | Webapp | Get planetary shield health |
| webapp-planet-shield | GET | `/api/planet/{planet_id}/shield` | Webapp | Get planetary shield information |
| webapp-planet-raid-active | GET | `/api/planet/{planet_id}/raid/active` | Webapp | Get active raid for planet |

### Dependencies

| Entity | Relationship | Description |
|--------|-------------|-------------|
| Player | ownedBy | Planet is owned by a player |
| Struct | contains | Planet contains structs |
| Fleet | targetedBy | Planet may be targeted by fleets |

### Streaming

| Subject | Events | Schema |
|---------|--------|--------|
| `structs.planet.*` | raid_status, fleet_arrive, fleet_advance, fleet_depart | `api/streaming/event-schemas.md#PlanetRaidStatusEvent` |

---

## Guild

Guild entity endpoints.

### Queries

| ID | Method | Path | Base | Description | Auth |
|----|--------|------|------|-------------|------|
| guild-by-id | GET | `/structs/guild/{id}` | Consensus | Get guild by ID | No |
| webapp-guild-by-id | GET | `/api/guild/{guild_id}` | Webapp | Get guild by ID | No |
| webapp-guild-current | GET | `/api/guild/this` | Webapp | Get current guild for authenticated player | Required |
| webapp-guild-count | GET | `/api/guild/count` | Webapp | Get total guild count | No |
| webapp-guild-member-count | GET | `/api/guild/{guild_id}/members/count` | Webapp | Get guild member count | No |
| webapp-guild-power-stats | GET | `/api/guild/{guild_id}/power/stats` | Webapp | Get guild power statistics | No |
| webapp-guild-roster | GET | `/api/guild/{guild_id}/roster` | Webapp | Get guild roster | No |
| webapp-guild-directory | GET | `/api/guild/directory` | Webapp | Get guild directory (paginated) | No |

### Dependencies

| Entity | Relationship | Description |
|--------|-------------|-------------|
| Player | hasMembers | Guild has player members |

### Streaming

| Subject | Events | Schema |
|---------|--------|--------|
| `structs.guild.*` | guild_consensus, guild_meta, guild_membership | `api/streaming/event-schemas.md#GuildConsensusEvent` |

---

## Struct

Struct entity endpoints.

### Queries

| ID | Method | Path | Base | Description |
|----|--------|------|------|-------------|
| struct-by-id | GET | `/structs/struct/{id}` | Consensus | Get struct by ID |
| webapp-struct-by-id | GET | `/api/struct/{struct_id}` | Webapp | Get struct by ID |
| webapp-struct-by-planet | GET | `/api/struct/planet/{planet_id}` | Webapp | Get all structs on a planet |
| webapp-struct-types | GET | `/api/struct/type` | Webapp | Get all struct types |
| cosmetic-struct-type | GET | `/api/cosmetic/struct-type/{structTypeId}` | Webapp | Get cosmetic data for struct type |
| struct-type-with-cosmetics | GET | `/api/struct-type/{structTypeId}/full` | Webapp | Get struct type with cosmetic overrides merged |

### Dependencies

| Entity | Relationship | Description |
|--------|-------------|-------------|
| Planet | locatedOn | Struct is located on a planet |
| Player | ownedBy | Struct is owned by a player |

### Streaming

| Subject | Events | Schema |
|---------|--------|--------|
| `structs.struct.*` | struct_status, struct_move, struct_attack, struct_block_build_start | `api/streaming/event-schemas.md#StructStatusEvent` |

---

## Fleet

Fleet entity endpoints.

### Queries

| ID | Method | Path | Base | Description |
|----|--------|------|------|-------------|
| fleet-by-id | GET | `/structs/fleet/{id}` | Consensus | Get fleet by ID |
| fleet-by-index | GET | `/structs/fleet_by_index/{index}` | Consensus | Get fleet by index |

### Dependencies

| Entity | Relationship | Description |
|--------|-------------|-------------|
| Player | ownedBy | Fleet is owned by a player |
| Planet | targets | Fleet may target planets |

### Streaming

| Subject | Events | Schema |
|---------|--------|--------|
| `structs.fleet.*` | fleet_arrive, fleet_advance, fleet_depart | `api/streaming/event-schemas.md#FleetArriveEvent` |

---

## Reactor

Reactor entity endpoints.

### Queries

| ID | Method | Path | Base | Description |
|----|--------|------|------|-------------|
| reactor-by-id | GET | `/structs/reactor/{id}` | Consensus | Get reactor by ID |

### Dependencies

| Entity | Relationship | Description |
|--------|-------------|-------------|
| Planet | locatedOn | Reactor is located on a planet |
| Player | ownedBy | Reactor is owned by a player |

---

## Substation

Substation entity endpoints.

### Queries

| ID | Method | Path | Base | Description |
|----|--------|------|------|-------------|
| substation-by-id | GET | `/structs/substation/{id}` | Consensus | Get substation by ID |

### Dependencies

| Entity | Relationship | Description |
|--------|-------------|-------------|
| Planet | locatedOn | Substation is located on a planet |
| Player | ownedBy | Substation is owned by a player |

---

## Provider

Provider entity endpoints.

### Queries

| ID | Method | Path | Base | Description |
|----|--------|------|------|-------------|
| provider-by-id | GET | `/structs/provider/{id}` | Consensus | Get provider by ID |

### Dependencies

| Entity | Relationship | Description |
|--------|-------------|-------------|
| Substation | partOf | Provider is part of a substation |

---

## Agreement

Agreement entity endpoints.

### Queries

| ID | Method | Path | Base | Description |
|----|--------|------|------|-------------|
| agreement-by-id | GET | `/structs/agreement/{id}` | Consensus | Get agreement by ID |
| agreement-by-provider | GET | `/structs/agreement_by_provider/{providerId}` | Consensus | Get agreements by provider |

### Dependencies

| Entity | Relationship | Description |
|--------|-------------|-------------|
| Provider | associatedWith | Agreement is associated with a provider |

---

## Allocation

Allocation entity endpoints.

### Queries

| ID | Method | Path | Base | Description |
|----|--------|------|------|-------------|
| allocation-by-id | GET | `/structs/allocation/{id}` | Consensus | Get allocation by ID |
| allocation-by-source | GET | `/structs/allocation_by_source/{sourceId}` | Consensus | Get allocations by source |
| allocation-by-destination | GET | `/structs/allocation_by_destination/{destinationId}` | Consensus | Get allocations by destination |

### Dependencies

| Entity | Relationship | Description |
|--------|-------------|-------------|
| Struct | sourceFrom | Allocation sources from a struct |
| Struct | destinedTo | Allocation is destined to a struct |

---

## Address

Address entity endpoints.

### Queries

| ID | Method | Path | Base | Description |
|----|--------|------|------|-------------|
| address-by-address | GET | `/structs/address/{address}` | Consensus | Get address by blockchain address |
| address-by-player | GET | `/structs/address_by_player/{playerId}` | Consensus | Get addresses by player |

### Dependencies

| Entity | Relationship | Description |
|--------|-------------|-------------|
| Player | associatedWith | Address is associated with a player |

---

## Permission

Permission entity endpoints.

### Queries

| ID | Method | Path | Base | Description |
|----|--------|------|------|-------------|
| permission-by-id | GET | `/structs/permission/{permissionId}` | Consensus | Get permission by ID |
| permission-by-object | GET | `/structs/permission/object/{objectId}` | Consensus | Get permissions by object |
| permission-by-player | GET | `/structs/permission/player/{playerId}` | Consensus | Get permissions by player |

### Dependencies

| Entity | Relationship | Description |
|--------|-------------|-------------|
| Player | grantedTo | Permission is granted to a player |
| Struct | appliesTo | Permission applies to a struct or other object |

---

## Transaction

Transaction endpoints.

### Actions

| ID | Method | Path | Base | Description | Auth |
|----|--------|------|------|-------------|------|
| submit-transaction | POST | `/cosmos/tx/v1beta1/txs` | Consensus | Submit a transaction | Required |

---

## BlockHeight

Block height endpoint.

### Queries

| ID | Method | Path | Base | Description |
|----|--------|------|------|-------------|
| block-height | GET | `/blockheight` | Consensus | Get current block height |

---

## Params

Module parameters endpoint.

### Queries

| ID | Method | Path | Base | Description |
|----|--------|------|------|-------------|
| params | GET | `/structs/params` | Consensus | Get module parameters |

---

## Related Documentation

- `api/endpoints.md` - Master endpoint list
- `schemas/entities.md` - Entity definitions
- `schemas/responses.md` - Response definitions
- `schemas/requests.md` - Request definitions
- `api/streaming/event-schemas.md` - Event schemas
- `api/streaming/event-types.md` - Event type definitions
