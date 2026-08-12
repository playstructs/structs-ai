---
description: "Query players on the consensus network: inventory, capacity and load, charge, guild membership, and current status."
---

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
    "fleetId": "11-11",
    "guildRank": "101"
  },
  "gridAttributes": {
    "capacity": "50000000",
    "load": "0",
    "structsLoad": "50000000",
    "connectionCapacity": "0",
    "lastAction": "12345",
    "ore": "0"
  },
  "playerInventory": {}
}
```

There is no `halted` field. Online = `(load + structsLoad) ≤ (capacity + connected substation connectionCapacity)`. Charge = current height − `gridAttributes.lastAction`.

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
