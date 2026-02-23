# Player Query Endpoints

**Version**: 1.0.0
**Category**: Query
**Entity**: Player
**Base URL**: `http://localhost:1317`
**Base Path**: `/structs`

---

## Endpoint Summary

| Method | Path | Description | Auth | Paginated |
|--------|------|-------------|------|-----------|
| GET | `/structs/player/{id}` | Get player by ID | No | No |
| GET | `/structs/player` | List all players | No | Yes |
| GET | `/structs/player_halted` | List all halted players | No | No |

---

## Endpoint Details

### Get Player by ID

`GET /structs/player/{id}`

Returns a single player by their entity ID.

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `id` | string | Yes | entity-id (`^1-[0-9]+$`) | Player identifier in format 'type-index' (e.g., '1-11' for player type 1, index 11). Type 1 = Player. |

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities/player.md`

#### Example

**Request**: `GET /structs/player/1-11`

**Response**:

```json
{
  "Player": {
    "id": "1-11",
    "index": "11",
    "guildId": "0-1",
    "substationId": "",
    "creator": "structs1...",
    "primaryAddress": "structs1...",
    "planetId": "2-1",
    "fleetId": "11-11"
  },
  "gridAttributes": {},
  "playerInventory": {},
  "halted": false
}
```

---

### List All Players

`GET /structs/player`

Returns a paginated list of all players.

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `pagination.key` | string | No | - | Pagination key |
| `pagination.limit` | integer | No | - | Page size |

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities/player.md` (array)

---

### List All Halted Players

`GET /structs/player_halted`

Returns a list of all halted players.

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities/player.md` (array)
