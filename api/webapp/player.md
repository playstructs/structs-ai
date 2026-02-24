# Webapp Player API Endpoints

**Version**: 1.1.0
**Category**: webapp
**Entity**: Player
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`)
**Last Updated**: January 1, 2026

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/player/{player_id}` | Get player information from web application | No |
| GET | `/api/player/{player_id}/action/last/block/height` | Get last action block height for player | No |
| GET | `/api/player/raid/search` | Search player raids | No |
| PUT | `/api/player/username` | Update player username | Yes |
| GET | `/api/player/transfer/search` | Search player transfers | No |
| GET | `/api/player/{player_id}/ore/stats` | Get player ore statistics | No |
| GET | `/api/player/{player_id}/planet/completed` | Get completed planets for player | No |
| GET | `/api/player/{player_id}/raid/launched` | Get launched raids for player | No |

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

### PUT `/api/player/username`

Update player username.

- **ID**: `webapp-player-username`
- **Authentication**: Required

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

---

*Last Updated: January 1, 2026*
