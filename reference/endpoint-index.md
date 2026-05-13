# Endpoint Index

**Last Updated**: May 13, 2026
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

Base URL: `http://localhost:1317` (local) or `https://public.testnet.structs.network` (public testnet, SSL).

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

Base URL: `http://localhost:8080` (local) or `http://crew.oh.energy` (public Orbital Hydro guild webapp).

### Bespoke entity endpoints (selected)

| ID | Method | Path | Entity | Per-entity doc |
|----|--------|------|--------|----------------|
| webapp-player-by-id | GET | `/api/player/{player_id}` | Player | [webapp/player.md](../api/webapp/player.md) |
| webapp-player-ore-stats | GET | `/api/player/{player_id}/ore/stats` | Player | [webapp/player.md](../api/webapp/player.md) |
| webapp-planet-by-id | GET | `/api/planet/{planet_id}` | Planet | [webapp/planet.md](../api/webapp/planet.md) |
| webapp-planet-shield-health | GET | `/api/planet/{planet_id}/shield/health` | Planet | [webapp/planet.md](../api/webapp/planet.md) |
| webapp-guild-by-id | GET | `/api/guild/{guild_id}` | Guild | [webapp/guild.md](../api/webapp/guild.md) |
| webapp-guild-count | GET | `/api/guild/count` | Guild | [webapp/guild.md](../api/webapp/guild.md) |
| webapp-struct-by-id | GET | `/api/struct/{struct_id}` | Struct | [webapp/struct.md](../api/webapp/struct.md) |
| webapp-timestamp | GET | `/api/timestamp` | Timestamp | [webapp/system.md](../api/webapp/system.md) |
| webapp-setting-all | GET | `/api/setting` | Setting | [webapp/setting.md](../api/webapp/setting.md) |
| webapp-stat-range-by-object | GET | `/api/stat/{metric}/object/{object_key}/range/page/{page}` | Stat | [webapp/stat.md](../api/webapp/stat.md) |

### Catalog read endpoints (paginated `/api/{entity}[/{filter}]/page/{page}`)

| Entity | Doc | Filters |
|--------|-----|---------|
| address-tag | [webapp/address-tag.md](../api/webapp/address-tag.md) | `all`, `address` |
| agreement | [webapp/agreement.md](../api/webapp/agreement.md) | `all`, `provider`, `allocation`, `creator`, `owner` |
| allocation | [webapp/allocation.md](../api/webapp/allocation.md) | `all`, `source`, `destination`, `creator`, `controller` |
| banned-word | [webapp/banned-word.md](../api/webapp/banned-word.md) | `all` |
| defusion | [webapp/defusion.md](../api/webapp/defusion.md) | `all`, `validator`, `delegator` |
| fleet | [webapp/fleet.md](../api/webapp/fleet.md) | `list/all`, `list/location` |
| grid | [webapp/grid.md](../api/webapp/grid.md) | `all`, `object`, `attribute-type` |
| guild list | [webapp/guild.md](../api/webapp/guild.md) | `list/all`, `list/primary-reactor`, `list/entry-substation`, `list/owner` |
| guild-membership-application | [webapp/guild-membership-application.md](../api/webapp/guild-membership-application.md) | `all`, `guild`, `player` |
| infusion list | [webapp/infusion.md](../api/webapp/infusion.md) | `list/all`, `list/destination`, `list/address`, `list/player` |
| ledger list | [webapp/ledger.md](../api/webapp/ledger.md) | `list/all`, `list/player`, `list/address` |
| permission | [webapp/permission.md](../api/webapp/permission.md) | `all`, `object`, `player` |
| permission-guild-rank | [webapp/permission-guild-rank.md](../api/webapp/permission-guild-rank.md) | `all`, `object`, `guild` |
| planet list | [webapp/planet.md](../api/webapp/planet.md) | `list/all`, `list/owner` |
| planet-activity | [webapp/planet-activity.md](../api/webapp/planet-activity.md) | `all`, `planet`, `category` |
| planet-attribute | [webapp/planet-attribute.md](../api/webapp/planet-attribute.md) | `all`, `object`, `type` |
| player list | [webapp/player.md](../api/webapp/player.md) | `list/all`, `list/guild`, `list/substation` |
| provider | [webapp/provider.md](../api/webapp/provider.md) | `all`, `owner`, `denom`, `substation` |
| reactor | [webapp/reactor.md](../api/webapp/reactor.md) | `all`, `validator`, `guild`, `owner` |
| struct list | [webapp/struct.md](../api/webapp/struct.md) | `list/all`, `list/owner`, `list/location` |
| struct-attribute | [webapp/struct-attribute.md](../api/webapp/struct-attribute.md) | `all`, `object`, `type` |
| struct-defender | [webapp/struct-defender.md](../api/webapp/struct-defender.md) | `all`, `defending`, `protected` |
| substation | [webapp/substation.md](../api/webapp/substation.md) | `all`, `owner` |

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
