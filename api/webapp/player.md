# Webapp Player API Endpoints

**Category**: webapp
**Entity**: Player
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/player/{player_id}` | Get player information from web application | No |
| GET | `/api/player/{player_id}/action/last/block/height` | Get last action block height for player | No |
| GET | `/api/player/raid/search` | Search player raids | No |
| GET | `/api/player/transfer/search` | Search player transfers | No |
| GET | `/api/player/{player_id}/ore/stats` | Get player ore statistics | No |
| GET | `/api/player/{player_id}/planet/completed` | Get completed planets for player | No |
| GET | `/api/player/{player_id}/raid/launched` | Get launched raids for player | No |
| GET | `/api/player/list/all/page/{page}` | Catalog list of all players, paginated | No |
| GET | `/api/player/list/guild/{guild_id}/page/{page}` | Catalog list of players in a guild | No |
| GET | `/api/player/list/substation/{substation_id}/page/{page}` | Catalog list of players connected to a substation | No |

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

**Response**:

```json
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

**Response**:

```json
{
  "height": 12345
}
```

---

### GET `/api/player/raid/search`

Search player raids.

- **ID**: `webapp-player-raid-search`

---

### Username updates (removed in v0.16.0)

The `PUT /api/player/username` endpoint was removed in v0.16.0. Username (and the new profile-picture field) are now updated directly on chain via `MsgPlayerUpdateName` / `MsgPlayerUpdatePfp`. The webapp's signing client manager exposes `queueMsgPlayerUpdateName(playerId, name)` and `queueMsgPlayerUpdatePfp(playerId, pfp)` to queue these transactions; the database `player_meta` row is updated by the cache trigger after the chain commits.

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

The `/api/player/list/...` endpoints return the standard catalog envelope (see `protocols/webapp-api-protocol.md`).
