# Webapp Player API Endpoints

**Category**: webapp
**Entity**: Player
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 29, 2026

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/player/{player_id}` | Get player information from web application | Yes |
| GET | `/api/player/{player_id}/action/last/block/height` | Get last action block height for player | Yes |
| GET | `/api/player/raid/search` | Search player raids | Yes |
| GET | `/api/player/transfer/search` | Search player transfers | Yes |
| GET | `/api/player/{player_id}/ore/stats` | Get player ore statistics | Yes |
| GET | `/api/player/{player_id}/planet/completed` | Get completed planets for player | Yes |
| GET | `/api/player/{player_id}/raid/launched` | Get launched raids for player | Yes |
| GET | `/api/player/list/all/page/{page}` | Catalog list of all players, paginated | Yes |
| GET | `/api/player/list/guild/{guild_id}/page/{page}` | Catalog list of players in a guild | Yes |
| GET | `/api/player/list/substation/{substation_id}/page/{page}` | Catalog list of players connected to a substation | Yes |

---

## Endpoint Details

### GET `/api/player/{player_id}`

Get player information from web application.

- **ID**: `webapp-player-by-id`
- **Response Schema**: `schemas/responses.md#WebappPlayerResponse`
- **Content Type**: `application/json`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `player_id` | string | Yes | entity-id (pattern: `^1-[0-9]+$`) | Player identifier in format 'type-index' (e.g., '1-11' for player type 1, index 11). Type 1 = Player. |

#### Example

**Request**: `GET http://localhost:8080/api/player/1-11`

**Response** — envelope; `data` is a **single flat object whose keys are the SQL columns** from `PlayerManager::getPlayer` (snake_case), not nested `{player, guild, stats}`. Representative shape (column set may grow):

```json
{
  "success": true,
  "errors": {},
  "data": {
    "id": "1-11",
    "primary_address": "structs1...",
    "guild_id": "0-1",
    "guild_name": "GuildName",
    "tag": "GLD",
    "substation_id": "4-1",
    "planet_id": "2-1",
    "fleet_id": "9-11",
    "fleet": { "...": "row_to_json of the fleet" },
    "username": "PlayerName",
    "pfp": "...",
    "alpha": "1000000",
    "ore": "1000",
    "load": "5"
  }
}
```

Guild fields are type 0 (`0-1`). Always unwrap `data` after checking `success`; treat keys as SQL column names.

---

### GET `/api/player/{player_id}/action/last/block/height`

Get last action block height for player.

- **ID**: `webapp-player-action-last-block`
- **Response Schema**: `schemas/responses.md#BlockHeightResponse`
- **Content Type**: `application/json`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `player_id` | string | Yes | player-id | Player identifier |

#### Example

**Request**: `GET http://localhost:8080/api/player/1-11/action/last/block/height`

**Response** (envelope):

```json
{
  "success": true,
  "errors": {},
  "data": { "height": 12345 }
}
```

---

### GET `/api/player/raid/search`

Search player raids.

- **ID**: `webapp-player-raid-search`

---

### Username and profile picture

Username and PFP are chain UGC fields on `structs.player` (`username`, `pfp` columns). They are set at signup via `MsgGuildMembershipJoinProxy.playerName` / `playerPfp`, or updated later via `MsgPlayerUpdateName` / `MsgPlayerUpdatePfp`. The webapp queues these through `queueMsgPlayerUpdateName(playerId, name)` and `queueMsgPlayerUpdatePfp(playerId, pfp)`.

The HTTP `PUT /api/player/username` endpoint no longer exists — all identity updates go through chain transactions.

See `knowledge/mechanics/ugc-moderation.md` for the full UGC update flow and validation rules.

---

### GET `/api/player/transfer/search`

Search player transfers.

- **ID**: `webapp-player-transfer-search`

---

### GET `/api/player/{player_id}/ore/stats`

Get player ore statistics.

- **ID**: `webapp-player-ore-stats`
- **Response Schema**: `schemas/responses.md#OreStatsResponse`
- **Content Type**: `application/json`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `player_id` | string | Yes | player-id | Player identifier |

#### Example

**Request**: `GET http://localhost:8080/api/player/1-11/ore/stats`

**Response**:

```json
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

---

### GET `/api/player/{player_id}/planet/completed`

Get completed planets for player.

- **ID**: `webapp-player-planet-completed`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `player_id` | string | Yes | player-id | Player identifier |

---

### GET `/api/player/{player_id}/raid/launched`

Get launched raids for player.

- **ID**: `webapp-player-raid-launched`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `player_id` | string | Yes | player-id | Player identifier |

---

### GET `/api/player/list/all/page/{page}`

Catalog list of every player on the chain, paginated.

- **ID**: `webapp-player-list-all`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `page` | integer | Yes | `\d+` | Page number, 1-indexed |

---

### GET `/api/player/list/guild/{guild_id}/page/{page}`

Catalog list of players in a guild.

- **ID**: `webapp-player-list-by-guild`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `guild_id` | string | Yes | guild-id | Guild identifier (e.g. `0-1`) |
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/player/list/substation/{substation_id}/page/{page}`

Catalog list of players connected to a substation.

- **ID**: `webapp-player-list-by-substation`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `substation_id` | string | Yes | substation-id | Substation identifier (e.g. `4-1`) |
| `page` | integer | Yes | `\d+` | Page number |

---

## Response Schema

Player responses include reactor staking summary:

```json
{
  "player": {
    "id": "1-11",
    "username": "PlayerName",
    ...
  },
  "reactorStaking": {
    "totalStaked": "...",
    "delegationStatus": "active",
    "reactors": [...]
  },
  ...
}
```

The `/api/player/list/...` endpoints return the shared envelope with rows **directly in `data` as a flat array** (fixed page size 100 — if `data.length === 100`, fetch the next page). Bespoke `/api/player/{player_id}` endpoints also use the `{ "success", "errors", "data" }` envelope; their `data` holds the SQL column names from the backing query (snake_case). See `protocols/webapp-api-protocol.md`.
