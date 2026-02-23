# API Endpoints

**Version**: 1.0.0
**Last Updated**: 2025-01-XX

---

## Base URLs

| API | Base URL | Base Path |
|-----|----------|-----------|
| Consensus Network | `http://localhost:1317` | `/structs` |
| Web Application | `http://localhost:8080` | `/api` |
| RPC | `http://localhost:26657` | `/` |

---

## Query Endpoints (Consensus Network)

All query endpoints use the Consensus Network API (`http://localhost:1317`).

### Player Queries

| Method | Path | Description | Pagination |
|--------|------|-------------|------------|
| GET | `/structs/player/{id}` | Get player by ID | No |
| GET | `/structs/player` | List all players | Yes |

**`GET /structs/player/{id}`** (`player-by-id`)

| Parameter | Type | Required | Format | Description |
|-----------|------|----------|--------|-------------|
| id | string | Yes | `^1-[0-9]+$` | Player identifier in format `type-index` (e.g., `1-11`). Type 1 = Player. |

Response schema: `schemas/entities.md#Player`

```json
// Example request: GET /structs/player/1
// Example response:
{
  "player": {...},
  "gridAttributes": {...},
  "playerInventory": {...},
  "halted": false
}
```

**`GET /structs/player`** (`player-list`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| pagination.key | string | No | Pagination key |
| pagination.limit | integer | No | Page size |

Response schema: `schemas/entities.md#Player[]`

### Planet Queries

| Method | Path | Description | Pagination |
|--------|------|-------------|------------|
| GET | `/structs/planet/{id}` | Get planet by ID | No |
| GET | `/structs/planet` | List all planets | Yes |
| GET | `/structs/planet_by_player/{playerId}` | Get planets owned by player | No |

**`GET /structs/planet/{id}`** (`planet-by-id`)

| Parameter | Type | Required | Format | Description |
|-----------|------|----------|--------|-------------|
| id | string | Yes | `^2-[0-9]+$` | Planet identifier in format `type-index` (e.g., `2-1`). Type 2 = Planet. |

Response schema: `schemas/entities.md#Planet`

**`GET /structs/planet_by_player/{playerId}`** (`planet-by-player`)

| Parameter | Type | Required | Format | Description |
|-----------|------|----------|--------|-------------|
| playerId | string | Yes | `^1-[0-9]+$` | Player identifier in format `type-index` (e.g., `1-11`). Type 1 = Player. |

Response schema: `schemas/entities.md#Planet[]`

### Struct Queries

| Method | Path | Description | Pagination |
|--------|------|-------------|------------|
| GET | `/structs/struct/{id}` | Get struct by ID | No |
| GET | `/structs/struct` | List all structs | Yes |

**`GET /structs/struct/{id}`** (`struct-by-id`)

| Parameter | Type | Required | Format | Description |
|-----------|------|----------|--------|-------------|
| id | string | Yes | `^5-[0-9]+$` | Struct identifier in format `type-index` (e.g., `5-42`). Type 5 = Struct. |

Response schema: `schemas/entities.md#Struct`

### Fleet Queries

| Method | Path | Description | Pagination |
|--------|------|-------------|------------|
| GET | `/structs/fleet/{id}` | Get fleet by ID | No |
| GET | `/structs/fleet` | List all fleets | Yes |
| GET | `/structs/fleet_by_index/{index}` | Get fleet by index | No |

**`GET /structs/fleet/{id}`** (`fleet-by-id`)

| Parameter | Type | Required | Format | Description |
|-----------|------|----------|--------|-------------|
| id | string | Yes | `^9-[0-9]+$` | Fleet identifier in format `type-index` (e.g., `9-11`). Type 9 = Fleet. |

Response schema: `schemas/entities.md#Fleet`

**`GET /structs/fleet_by_index/{index}`** (`fleet-by-index`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| index | integer | Yes | Fleet index |

Response schema: `schemas/entities.md#Fleet`

### Guild Queries

| Method | Path | Description | Pagination |
|--------|------|-------------|------------|
| GET | `/structs/guild/{id}` | Get guild by ID | No |
| GET | `/structs/guild` | List all guilds | Yes |

**`GET /structs/guild/{id}`** (`guild-by-id`)

| Parameter | Type | Required | Format | Description |
|-----------|------|----------|--------|-------------|
| id | string | Yes | `^0-[0-9]+$` | Guild identifier in format `type-index` (e.g., `0-1`). Type 0 = Guild. |

Response schema: `schemas/entities.md#Guild`

### Reactor Queries

| Method | Path | Description | Pagination |
|--------|------|-------------|------------|
| GET | `/structs/reactor/{id}` | Get reactor by ID | No |
| GET | `/structs/reactor` | List all reactors | Yes |

**`GET /structs/reactor/{id}`** (`reactor-by-id`)

| Parameter | Type | Required | Format | Description |
|-----------|------|----------|--------|-------------|
| id | string | Yes | `^3-[0-9]+$` | Reactor identifier in format `type-index` (e.g., `3-1`). Type 3 = Reactor. |

Response schema: `schemas/entities.md#Reactor`

### Substation Queries

| Method | Path | Description | Pagination |
|--------|------|-------------|------------|
| GET | `/structs/substation/{id}` | Get substation by ID | No |
| GET | `/structs/substation` | List all substations | Yes |

**`GET /structs/substation/{id}`** (`substation-by-id`)

| Parameter | Type | Required | Format | Description |
|-----------|------|----------|--------|-------------|
| id | string | Yes | `^4-[0-9]+$` | Substation identifier in format `type-index` (e.g., `4-3`). Type 4 = Substation. |

Response schema: `schemas/entities.md#Substation`

### Provider Queries

| Method | Path | Description | Pagination |
|--------|------|-------------|------------|
| GET | `/structs/provider/{id}` | Get provider by ID | No |
| GET | `/structs/provider` | List all providers | Yes |

**`GET /structs/provider/{id}`** (`provider-by-id`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | Yes | Provider identifier |

Response schema: `schemas/entities.md#Provider`

### Agreement Queries

| Method | Path | Description | Pagination |
|--------|------|-------------|------------|
| GET | `/structs/agreement/{id}` | Get agreement by ID | No |
| GET | `/structs/agreement` | List all agreements | Yes |
| GET | `/structs/agreement_by_provider/{providerId}` | Get agreements by provider | No |

**`GET /structs/agreement/{id}`** (`agreement-by-id`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | Yes | Agreement identifier |

Response schema: `schemas/entities.md#Agreement`

**`GET /structs/agreement_by_provider/{providerId}`** (`agreement-by-provider`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| providerId | string | Yes | Provider identifier |

Response schema: `schemas/entities.md#Agreement[]`

### Allocation Queries

| Method | Path | Description | Pagination |
|--------|------|-------------|------------|
| GET | `/structs/allocation/{id}` | Get allocation by ID | No |
| GET | `/structs/allocation` | List all allocations | Yes |
| GET | `/structs/allocation_by_source/{sourceId}` | Get allocations by source | No |
| GET | `/structs/allocation_by_destination/{destinationId}` | Get allocations by destination | No |

**`GET /structs/allocation/{id}`** (`allocation-by-id`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | Yes | Allocation identifier |

Response schema: `schemas/entities.md#Allocation`

**`GET /structs/allocation_by_source/{sourceId}`** (`allocation-by-source`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| sourceId | string | Yes | Source identifier |

Response schema: `schemas/entities.md#Allocation[]`

**`GET /structs/allocation_by_destination/{destinationId}`** (`allocation-by-destination`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| destinationId | string | Yes | Destination identifier |

Response schema: `schemas/entities.md#Allocation[]`

### Address Queries

| Method | Path | Description | Pagination |
|--------|------|-------------|------------|
| GET | `/structs/address/{address}` | Get address by blockchain address | No |
| GET | `/structs/address` | List all addresses | Yes |
| GET | `/structs/address_by_player/{playerId}` | Get addresses by player | No |

**`GET /structs/address/{address}`** (`address-by-address`)

| Parameter | Type | Required | Format | Description |
|-----------|------|----------|--------|-------------|
| address | string | Yes | blockchain-address | Blockchain address |

Response schema: `schemas/entities.md#Address`

**`GET /structs/address_by_player/{playerId}`** (`address-by-player`)

| Parameter | Type | Required | Format | Description |
|-----------|------|----------|--------|-------------|
| playerId | string | Yes | `^1-[0-9]+$` | Player identifier in format `type-index` (e.g., `1-11`). Type 1 = Player. |

Response schema: `schemas/entities.md#Address[]`

### Permission Queries

| Method | Path | Description | Pagination |
|--------|------|-------------|------------|
| GET | `/structs/permission/{permissionId}` | Get permission by ID | No |
| GET | `/structs/permission` | List all permissions | Yes |
| GET | `/structs/permission/object/{objectId}` | Get permissions by object | No |
| GET | `/structs/permission/player/{playerId}` | Get permissions by player | No |

**`GET /structs/permission/{permissionId}`** (`permission-by-id`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| permissionId | string | Yes | Permission identifier |

Response schema: `schemas/entities.md#Permission`

**`GET /structs/permission/object/{objectId}`** (`permission-by-object`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| objectId | string | Yes | Object identifier |

Response schema: `schemas/entities.md#Permission[]`

**`GET /structs/permission/player/{playerId}`** (`permission-by-player`)

| Parameter | Type | Required | Format | Description |
|-----------|------|----------|--------|-------------|
| playerId | string | Yes | `^1-[0-9]+$` | Player identifier in format `type-index` (e.g., `1-11`). Type 1 = Player. |

Response schema: `schemas/entities.md#Permission[]`

### Block Height and Parameters

| Method | Path | Description |
|--------|------|-------------|
| GET | `/blockheight` | Get current block height |
| GET | `/structs/params` | Get module parameters |

**`GET /blockheight`** (`block-height`)

Response schema: `schemas/entities.md#BlockHeight`

```json
// Example request: GET /blockheight
// Example response:
{
  "height": 12345
}
```

**`GET /structs/params`** (`params`)

Response schema: `schemas/entities.md#Params`

---

## Transaction Endpoints

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| POST | `/cosmos/tx/v1beta1/txs` | Submit a transaction | Required |

**`POST /cosmos/tx/v1beta1/txs`** (`submit-transaction`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| body | object | Yes | Transaction body with messages (see `schemas/actions.md`) |

Request schema: `schemas/actions.md`
Response schema: `schemas/responses.md#TransactionResponse`

```json
// Example request:
// POST /cosmos/tx/v1beta1/txs
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgStructBuild",
        "creator": "structs1...",
        "structType": "1",
        "locationType": 1,
        "locationId": "1-1"
      }
    ]
  }
}
```

```json
// Example response:
{
  "tx_response": {
    "code": 0,
    "txhash": "...",
    "height": 12345
  }
}
```

---

## Web Application API Endpoints

All webapp endpoints use the Web Application API (`http://localhost:8080`).

### Player Endpoints

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| GET | `/api/player/{player_id}` | Get player information | No |
| GET | `/api/player/{player_id}/action/last/block/height` | Get last action block height | No |
| GET | `/api/player/raid/search` | Search player raids | No |
| PUT | `/api/player/username` | Update player username | Required |
| GET | `/api/player/transfer/search` | Search player transfers | No |
| GET | `/api/player/{player_id}/ore/stats` | Get player ore statistics | No |
| GET | `/api/player/{player_id}/planet/completed` | Get completed planets for player | No |
| GET | `/api/player/{player_id}/raid/launched` | Get launched raids for player | No |

**`GET /api/player/{player_id}`** (`webapp-player-by-id`)

| Parameter | Type | Required | Format | Description |
|-----------|------|----------|--------|-------------|
| player_id | string | Yes | `^1-[0-9]+$` | Player identifier in format `type-index` (e.g., `1-11`). Type 1 = Player. |

Response schema: `schemas/responses.md#WebappPlayerResponse`

```json
// Example request: GET http://localhost:8080/api/player/1-11
// Example response:
{
  "player": {
    "id": "1-11",
    "username": "PlayerName",
    "address": "cosmos1..."
  },
  "guild": {
    "id": "2-1",
    "name": "GuildName"
  },
  "stats": {
    "total_ore": 1000,
    "planets_completed": 5
  }
}
```

**`GET /api/player/{player_id}/action/last/block/height`** (`webapp-player-action-last-block`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| player_id | string | Yes | Player identifier |

Response schema: `schemas/responses.md#BlockHeightResponse`

```json
// Example response:
{
  "height": 12345
}
```

**`GET /api/player/{player_id}/ore/stats`** (`webapp-player-ore-stats`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| player_id | string | Yes | Player identifier |

Response schema: `schemas/responses.md#OreStatsResponse`

```json
// Example response:
{
  "player_id": "1-11",
  "total_ore": 1000,
  "ore_by_type": {
    "iron": 500,
    "copper": 300,
    "silver": 200
  }
}
```

### Planet Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/planet/{planet_id}` | Get planet information |
| GET | `/api/planet/{planet_id}/shield/health` | Get planet shield health |
| GET | `/api/planet/{planet_id}/shield` | Get planet shield information |
| GET | `/api/planet/{planet_id}/raid/active` | Get active raid for planet |
| GET | `/api/planet/raid/active/fleet/{fleet_id}` | Get active raid for fleet |

**`GET /api/planet/{planet_id}`** (`webapp-planet-by-id`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| planet_id | string | Yes | Planet identifier |

Response schema: `schemas/entities.md#Planet`

```json
// Example response:
{
  "id": "3-1",
  "owner_id": "1-11",
  "max_ore": 5,
  "space_slots": 4
}
```

**`GET /api/planet/{planet_id}/shield/health`** (`webapp-planet-shield-health`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| planet_id | string | Yes | Planet identifier |

Response schema: `schemas/responses.md#ShieldHealthResponse`

```json
// Example response:
{
  "planet_id": "3-1",
  "health": 1000,
  "max_health": 1000
}
```

### Guild Endpoints

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| GET | `/api/guild/this` | Get current user's guild | Required |
| GET | `/api/guild/name` | Get guild name | No |
| GET | `/api/guild/{guild_id}/name` | Get guild name by ID | No |
| GET | `/api/guild/{guild_id}/members/count` | Get guild member count | No |
| GET | `/api/guild/count` | Get total guild count | No |
| GET | `/api/guild/directory` | Get guild directory | No |
| GET | `/api/guild/{guild_id}` | Get guild by ID | No |
| GET | `/api/guild/{guild_id}/power/stats` | Get guild power statistics | No |
| GET | `/api/guild/{guild_id}/roster` | Get guild roster | No |
| GET | `/api/guild/{guild_id}/planet/complete/count` | Get completed planet count for guild | No |

**`GET /api/guild/{guild_id}`** (`webapp-guild-by-id`)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| guild_id | string | Yes | Guild identifier |

Response schema: `schemas/entities.md#Guild`

```json
// Example response:
{
  "id": "2-1",
  "name": "GuildName",
  "member_count": 10
}
```

**`GET /api/guild/count`** (`webapp-guild-count`)

Response schema: `schemas/responses.md#CountResponse`

```json
// Example response:
{
  "count": 42
}
```

### Auth Endpoints

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| POST | `/api/auth/signup` | Sign up new user | None |
| POST | `/api/auth/login` | Login user | None |
| GET | `/api/auth/logout` | Logout user | Required |

### Struct Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/struct/planet/{planet_id}` | Get structs on planet |
| GET | `/api/struct/type` | Get struct types |
| GET | `/api/struct/{struct_id}` | Get struct by ID |

### Ledger Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/ledger/player/{player_id}/page/{page}` | Get ledger page for player |
| GET | `/api/ledger/player/{player_id}/count` | Get ledger count for player |
| GET | `/api/ledger/{tx_id}` | Get ledger entry by transaction ID |

### Infusion Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/infusion/player/{player_id}` | Get infusions for player |

### Timestamp Endpoint

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/timestamp` | Get current Unix timestamp |

Response schema: `schemas/responses.md#TimestampResponse`

```json
// Example response:
{
  "timestamp": 1704067200,
  "iso": "2024-01-01T00:00:00Z"
}
```

---

## RPC Endpoints

All RPC endpoints use `http://localhost:26657`.

| Method | Path | Description | Parameters |
|--------|------|-------------|------------|
| GET | `/status` | Get node status | None |
| GET | `/block` | Get block by height | `height` (integer, optional) |
| GET | `/block_results` | Get block results | `height` (integer, optional) |
| GET | `/commit` | Get commit for block | `height` (integer, optional) |
| GET | `/validators` | Get validators | `height` (integer, optional) |

Response schema: `schemas/responses.md#RPCStatusResponse`

---

## Streaming Endpoints (GRASS via NATS)

### NATS Protocol (`grass-nats-protocol`)

- **Method**: NATS
- **URL**: `nats://localhost:4222`
- **Authentication**: Optional

GRASS uses NATS messaging system:
1. PostgreSQL NOTIFY events trigger GRASS
2. GRASS publishes to NATS subjects
3. Clients connect to NATS and subscribe to subjects

**Documentation**: `protocols/streaming.md`, `api/streaming/event-schemas.md`, `api/streaming/event-types.md`, `api/streaming/subscription-patterns.md`

#### Subject Patterns

| Pattern | Description | Example | Schema |
|---------|-------------|---------|--------|
| `structs.player.*` | Player-specific updates | `structs.player.0-1.1-11` | `api/streaming/event-schemas.md#PlayerConsensusEvent` |
| `structs.planet.*` | Planet-specific updates (includes raid_status, planet_activity with struct_health details) | `structs.planet.3-1` | `api/streaming/event-schemas.md#PlanetRaidStatusEvent` |
| `structs.guild.*` | Guild-specific updates | `structs.guild.0-1` | `api/streaming/event-schemas.md#GuildConsensusEvent` |
| `structs.struct.*` | Struct-specific updates | `structs.struct.5-1` | `api/streaming/event-schemas.md#StructStatusEvent` |
| `structs.fleet.*` | Fleet-specific updates | `structs.fleet.7-1` | `api/streaming/event-schemas.md#FleetArriveEvent` |
| `structs.global` | Global game state updates | `structs.global` | `api/streaming/event-schemas.md#BlockEvent` |

```json
// Subscribe example:
{
  "subject": "structs.player.0-1.1-11",
  "subject": "structs.planet.3-1"
}

// Message example:
{
  "subject": "structs.player.0-1.1-11",
  "category": "player_consensus",
  "id": "1-11",
  "updated_at": "2025-01-01T00:00:00Z",
  "data": {...}
}
```

### NATS WebSocket (`grass-nats-websocket`)

- **Method**: WebSocket
- **URL**: `ws://localhost:1443`
- **Authentication**: Optional

NATS WebSocket wrapper for browser compatibility. Requires NATS server WebSocket support.

Supports the same subject patterns as the NATS protocol endpoint.

```json
// Subscribe example:
{
  "action": "subscribe",
  "subjects": ["structs.player.0-1.1-11", "structs.planet.3-1"]
}

// Message example:
{
  "subject": "structs.player.0-1.1-11",
  "category": "player_consensus",
  "id": "1-11",
  "updated_at": "2025-01-01T00:00:00Z",
  "data": {...}
}
```

---

## Related Documentation

- `schemas/entities.md` - Entity definitions
- `schemas/actions.md` - Action definitions
- `schemas/responses.md` - Response definitions
- `reference/api-quick-reference.md` - API quick reference
- `api/streaming/event-types.md` - Event type definitions
- `api/streaming/subscription-patterns.md` - Subscription patterns
- `api/error-codes.md` - Error code catalog
- `api/rate-limits.md` - Rate limit configuration
