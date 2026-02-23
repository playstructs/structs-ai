# Endpoint Index

**Version**: 1.1.0
**Last Updated**: 2026-01-01
**Description**: Complete index of all API endpoints for AI agents

---

## Categories

| Category | Description |
|----------|-------------|
| query | Read-only operations to query game state |
| transaction | Write operations to perform actions |
| webapp | Web Application API endpoints (PHP/Symfony) |
| modding | Cosmetic mod management and integration endpoints |

## Query Patterns

| Pattern | Description |
|---------|-------------|
| single | Get single entity by ID |
| list | List all entities (with pagination) |
| filtered | Get entities filtered by relationship |
| transaction | Submit transaction to perform action |

---

## Consensus Network API Endpoints

Base URL: `http://localhost:1317`

### Player

| ID | Method | Path | Paginated | Entity | Schema | Protocol |
|----|--------|------|-----------|--------|--------|----------|
| player-by-id | GET | `/structs/player/{id}` | No | Player | [entities.md](../schemas/entities.md#player) | [query-protocol.md](../protocols/query-protocol.md#pattern-1) |
| player-list | GET | `/structs/player` | Yes | Player | [entities.md](../schemas/entities.md#player) | [query-protocol.md](../protocols/query-protocol.md#pattern-2) |

### Planet

| ID | Method | Path | Paginated | Entity | Schema | Protocol |
|----|--------|------|-----------|--------|--------|----------|
| planet-by-id | GET | `/structs/planet/{id}` | No | Planet | [entities.md](../schemas/entities.md#planet) | [query-protocol.md](../protocols/query-protocol.md#pattern-1) |
| planet-list | GET | `/structs/planet` | Yes | Planet | [entities.md](../schemas/entities.md#planet) | [query-protocol.md](../protocols/query-protocol.md#pattern-2) |
| planet-by-player | GET | `/structs/planet_by_player/{playerId}` | No | Planet | [entities.md](../schemas/entities.md#planet) | [query-protocol.md](../protocols/query-protocol.md#pattern-3) |

### Struct

| ID | Method | Path | Paginated | Entity | Schema | Protocol |
|----|--------|------|-----------|--------|--------|----------|
| struct-by-id | GET | `/structs/struct/{id}` | No | Struct | [entities.md](../schemas/entities.md#struct) | [query-protocol.md](../protocols/query-protocol.md#pattern-1) |
| struct-list | GET | `/structs/struct` | Yes | Struct | [entities.md](../schemas/entities.md#struct) | [query-protocol.md](../protocols/query-protocol.md#pattern-2) |

### Fleet

| ID | Method | Path | Paginated | Entity | Schema | Protocol |
|----|--------|------|-----------|--------|--------|----------|
| fleet-by-id | GET | `/structs/fleet/{id}` | No | Fleet | [entities.md](../schemas/entities.md#fleet) | [query-protocol.md](../protocols/query-protocol.md#pattern-1) |
| fleet-list | GET | `/structs/fleet` | Yes | Fleet | [entities.md](../schemas/entities.md#fleet) | [query-protocol.md](../protocols/query-protocol.md#pattern-2) |

### Guild

| ID | Method | Path | Paginated | Entity | Schema | Protocol |
|----|--------|------|-----------|--------|--------|----------|
| guild-by-id | GET | `/structs/guild/{id}` | No | Guild | [entities.md](../schemas/entities.md#guild) | [query-protocol.md](../protocols/query-protocol.md#pattern-1) |
| guild-list | GET | `/structs/guild` | Yes | Guild | [entities.md](../schemas/entities.md#guild) | [query-protocol.md](../protocols/query-protocol.md#pattern-2) |

### Reactor

| ID | Method | Path | Paginated | Entity | Schema | Protocol |
|----|--------|------|-----------|--------|--------|----------|
| reactor-by-id | GET | `/structs/reactor/{id}` | No | Reactor | [entities.md](../schemas/entities.md#reactor) | [query-protocol.md](../protocols/query-protocol.md#pattern-1) |
| reactor-list | GET | `/structs/reactor` | Yes | Reactor | [entities.md](../schemas/entities.md#reactor) | [query-protocol.md](../protocols/query-protocol.md#pattern-2) |

### Substation

| ID | Method | Path | Paginated | Entity | Schema | Protocol |
|----|--------|------|-----------|--------|--------|----------|
| substation-by-id | GET | `/structs/substation/{id}` | No | Substation | [entities.md](../schemas/entities.md#substation) | [query-protocol.md](../protocols/query-protocol.md#pattern-1) |
| substation-list | GET | `/structs/substation` | Yes | Substation | [entities.md](../schemas/entities.md#substation) | [query-protocol.md](../protocols/query-protocol.md#pattern-2) |

### Provider

| ID | Method | Path | Paginated | Entity | Schema | Protocol |
|----|--------|------|-----------|--------|--------|----------|
| provider-by-id | GET | `/structs/provider/{id}` | No | Provider | [entities.md](../schemas/entities.md#provider) | [query-protocol.md](../protocols/query-protocol.md#pattern-1) |
| provider-list | GET | `/structs/provider` | Yes | Provider | [entities.md](../schemas/entities.md#provider) | [query-protocol.md](../protocols/query-protocol.md#pattern-2) |

### Agreement

| ID | Method | Path | Paginated | Entity | Schema | Protocol |
|----|--------|------|-----------|--------|--------|----------|
| agreement-by-id | GET | `/structs/agreement/{id}` | No | Agreement | [entities.md](../schemas/entities.md#agreement) | [query-protocol.md](../protocols/query-protocol.md#pattern-1) |
| agreement-list | GET | `/structs/agreement` | Yes | Agreement | [entities.md](../schemas/entities.md#agreement) | [query-protocol.md](../protocols/query-protocol.md#pattern-2) |
| agreement-by-provider | GET | `/structs/agreement_by_provider/{providerId}` | No | Agreement | [entities.md](../schemas/entities.md#agreement) | [query-protocol.md](../protocols/query-protocol.md#pattern-3) |

### Allocation

| ID | Method | Path | Paginated | Entity | Schema | Protocol |
|----|--------|------|-----------|--------|--------|----------|
| allocation-by-id | GET | `/structs/allocation/{id}` | No | Allocation | [entities.md](../schemas/entities.md#allocation) | [query-protocol.md](../protocols/query-protocol.md#pattern-1) |
| allocation-list | GET | `/structs/allocation` | Yes | Allocation | [entities.md](../schemas/entities.md#allocation) | [query-protocol.md](../protocols/query-protocol.md#pattern-2) |
| allocation-by-source | GET | `/structs/allocation_by_source/{sourceId}` | No | Allocation | [entities.md](../schemas/entities.md#allocation) | [query-protocol.md](../protocols/query-protocol.md#pattern-3) |
| allocation-by-destination | GET | `/structs/allocation_by_destination/{destinationId}` | No | Allocation | [entities.md](../schemas/entities.md#allocation) | [query-protocol.md](../protocols/query-protocol.md#pattern-3) |

### Address

| ID | Method | Path | Paginated | Entity | Schema | Protocol |
|----|--------|------|-----------|--------|--------|----------|
| address-by-address | GET | `/structs/address/{address}` | No | Address | [entities.md](../schemas/entities.md#address) | [query-protocol.md](../protocols/query-protocol.md#pattern-1) |
| address-list | GET | `/structs/address` | Yes | Address | [entities.md](../schemas/entities.md#address) | [query-protocol.md](../protocols/query-protocol.md#pattern-2) |
| address-by-player | GET | `/structs/address_by_player/{playerId}` | No | Address | [entities.md](../schemas/entities.md#address) | [query-protocol.md](../protocols/query-protocol.md#pattern-3) |

### Permission

| ID | Method | Path | Paginated | Entity | Schema | Protocol |
|----|--------|------|-----------|--------|--------|----------|
| permission-by-id | GET | `/structs/permission/{permissionId}` | No | Permission | [entities.md](../schemas/entities.md#permission) | [query-protocol.md](../protocols/query-protocol.md#pattern-1) |
| permission-list | GET | `/structs/permission` | Yes | Permission | [entities.md](../schemas/entities.md#permission) | [query-protocol.md](../protocols/query-protocol.md#pattern-2) |
| permission-by-object | GET | `/structs/permission/object/{objectId}` | No | Permission | [entities.md](../schemas/entities.md#permission) | [query-protocol.md](../protocols/query-protocol.md#pattern-3) |
| permission-by-player | GET | `/structs/permission/player/{playerId}` | No | Permission | [entities.md](../schemas/entities.md#permission) | [query-protocol.md](../protocols/query-protocol.md#pattern-3) |

### System

| ID | Method | Path | Paginated | Entity | Schema | Protocol |
|----|--------|------|-----------|--------|--------|----------|
| block-height | GET | `/blockheight` | No | BlockHeight | [game-state.md](../schemas/game-state.md#blockheight) | [query-protocol.md](../protocols/query-protocol.md#pattern-1) |
| params | GET | `/structs/params` | No | Params | [entities.md](../schemas/entities.md#params) | [query-protocol.md](../protocols/query-protocol.md#pattern-1) |

### Transaction

| ID | Method | Path | Entity | Schema | Protocol |
|----|--------|------|--------|--------|----------|
| submit-transaction | POST | `/cosmos/tx/v1beta1/txs` | Transaction | [actions.md](../schemas/actions.md) | [action-protocol.md](../protocols/action-protocol.md) |

---

## Web Application API Endpoints

Base URL: `http://localhost:8080`

| ID | Method | Path | Entity | Schema | Protocol |
|----|--------|------|--------|--------|----------|
| webapp-player-by-id | GET | `/api/player/{player_id}` | Player | [responses.md](../schemas/responses.md#webappplayerresponse) | [query-protocol.md](../protocols/query-protocol.md#pattern-1) |
| webapp-player-ore-stats | GET | `/api/player/{player_id}/ore/stats` | Player | [responses.md](../schemas/responses.md#orestatsresponse) | [query-protocol.md](../protocols/query-protocol.md#pattern-1) |
| webapp-planet-by-id | GET | `/api/planet/{planet_id}` | Planet | [entities.md](../schemas/entities.md#planet) | [query-protocol.md](../protocols/query-protocol.md#pattern-1) |
| webapp-planet-shield-health | GET | `/api/planet/{planet_id}/shield/health` | Planet | [responses.md](../schemas/responses.md#shieldhealthresponse) | [query-protocol.md](../protocols/query-protocol.md#pattern-1) |
| webapp-guild-by-id | GET | `/api/guild/{guild_id}` | Guild | [entities.md](../schemas/entities.md#guild) | [query-protocol.md](../protocols/query-protocol.md#pattern-1) |
| webapp-guild-count | GET | `/api/guild/count` | Guild | [responses.md](../schemas/responses.md#countresponse) | [query-protocol.md](../protocols/query-protocol.md#pattern-1) |
| webapp-struct-by-id | GET | `/api/struct/{struct_id}` | Struct | [entities.md](../schemas/entities.md#struct) | [query-protocol.md](../protocols/query-protocol.md#pattern-1) |
| webapp-timestamp | GET | `/api/timestamp` | Timestamp | [responses.md](../schemas/responses.md#timestampresponse) | [query-protocol.md](../protocols/query-protocol.md#pattern-1) |

---

## Modding API Endpoints

Base URL: `http://localhost:8080`

| ID | Method | Path | Entity | Schema | Protocol |
|----|--------|------|--------|--------|----------|
| cosmetic-mod-list | GET | `/api/cosmetic-mods` | CosmeticMod | [responses.md](../schemas/responses.md#cosmeticmodlistresponse) | [cosmetic-mod-integration.md](../protocols/cosmetic-mod-integration.md#pattern-1) |
| cosmetic-mod-get | GET | `/api/cosmetic-mods/{modId}` | CosmeticMod | [responses.md](../schemas/responses.md#cosmeticmodresponse) | [cosmetic-mod-integration.md](../protocols/cosmetic-mod-integration.md#pattern-1) |
| cosmetic-mod-install | POST | `/api/cosmetic-mods/install` | CosmeticMod | [responses.md](../schemas/responses.md#cosmeticmodinstallresponse) | [cosmetic-mod-integration.md](../protocols/cosmetic-mod-integration.md#pattern-3) |
| cosmetic-mod-validate | POST | `/api/cosmetic-mods/validate` | CosmeticMod | [responses.md](../schemas/responses.md#cosmeticmodvalidateresponse) | [cosmetic-mod-integration.md](../protocols/cosmetic-mod-integration.md#pattern-3) |
| cosmetic-struct-type | GET | `/api/cosmetic/struct-type/{structTypeId}` | StructType | [responses.md](../schemas/responses.md#structtypecosmeticresponse) | [cosmetic-mod-integration.md](../protocols/cosmetic-mod-integration.md#pattern-1) |
| struct-type-with-cosmetics | GET | `/api/struct-type/{structTypeId}/full` | StructType | [responses.md](../schemas/responses.md#structtypefullresponse) | [cosmetic-mod-integration.md](../protocols/cosmetic-mod-integration.md#pattern-1) |
