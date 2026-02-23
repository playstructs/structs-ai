# Planet Query Endpoints

**Version**: 1.0.0
**Category**: Query
**Entity**: Planet
**Base URL**: `http://localhost:1317`
**Base Path**: `/structs`

---

## Endpoint Summary

| Method | Path | Description | Auth | Paginated |
|--------|------|-------------|------|-----------|
| GET | `/structs/planet/{id}` | Get planet by ID | No | No |
| GET | `/structs/planet` | List all planets | No | Yes |
| GET | `/structs/planet_by_player/{playerId}` | Get planets owned by player | No | No |

---

## Endpoint Details

### Get Planet by ID

`GET /structs/planet/{id}`

Returns a single planet by its entity ID.

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `id` | string | Yes | entity-id (`^2-[0-9]+$`) | Planet identifier in format 'type-index' (e.g., '2-1' for planet type 2, index 1). Type 2 = Planet. |

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities/planet.md`

#### Example

**Request**: `GET /structs/planet/2-1`

**Response**:

```json
{
  "Planet": {
    "id": "2-1",
    "maxOre": "5",
    "creator": "structs1...",
    "owner": "1-11",
    "space": ["", "", "", ""],
    "air": ["", "", "", ""],
    "land": ["", "", "", ""],
    "water": ["", "", "", ""]
  },
  "map": {}
}
```

---

### List All Planets

`GET /structs/planet`

Returns a paginated list of all planets.

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `pagination.key` | string | No | - | Pagination key |
| `pagination.limit` | integer | No | - | Page size |

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities/planet.md` (array)

---

### Get Planets by Player

`GET /structs/planet_by_player/{playerId}`

Returns planets owned by a specific player.

> **Note**: Players can only own one planet at a time, so this typically returns 0 or 1 planet.

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `playerId` | string | Yes | entity-id (`^1-[0-9]+$`) | Player identifier in format 'type-index' (e.g., '1-11' for player type 1, index 11). Type 1 = Player. |

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities/planet.md` (array)
