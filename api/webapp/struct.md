# Webapp Struct API Endpoints

**Category**: webapp
**Entity**: Struct
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/struct/player/{player_id}` | Get structs by player ID | No |
| GET | `/api/struct/planet/{planet_id}` | Get structs on planet | No |
| GET | `/api/struct/type` | Get struct types | No |
| GET | `/api/struct/{struct_id}` | Get struct by ID | No |
| GET | `/api/struct/list/all/page/{page}` | Catalog list of every struct | No |
| GET | `/api/struct/list/owner/{owner}/page/{page}` | Catalog list of structs owned by a player | No |
| GET | `/api/struct/list/location/{location_id}/page/{page}` | Catalog list of structs at a location | No |

Per-struct attributes and defender relationships live in [`struct-attribute.md`](struct-attribute.md) and [`struct-defender.md`](struct-defender.md).

---

## Endpoint Details

### GET `/api/struct/player/{player_id}`

Get structs by player ID.

- **ID**: `webapp-struct-by-player`
- **Response Schema**: `schemas/entities.md#Struct`
- **Content Type**: `application/json`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `player_id` | string | Yes | player-id | Player identifier |

#### Example

**Request**: `GET http://localhost:8080/api/struct/player/1-11`

**Response**:

```json
[
  {
    "id": "5-1",
    "structTypeId": 14,
    "owner": "1-11",
    "locationId": "2-1",
    "health": 100
  }
]
```

---

### GET `/api/struct/planet/{planet_id}`

Get structs on planet.

- **ID**: `webapp-struct-by-planet`
- **Response Schema**: `schemas/entities.md#Struct`
- **Content Type**: `application/json`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `planet_id` | string | Yes | planet-id | Planet identifier |

#### Example

**Request**: `GET http://localhost:8080/api/struct/planet/2-1`

**Response**:

```json
[
  {
    "id": "5-1",
    "structTypeId": 14,
    "owner": "1-11",
    "locationId": "2-1",
    "health": 100
  }
]
```

---

### GET `/api/struct/type`

Get struct types.

- **ID**: `webapp-struct-type`
- **Response Schema**: `schemas/entities.md#StructType`
- **Content Type**: `application/json`

#### Example

**Request**: `GET http://localhost:8080/api/struct/type`

**Response**:

```json
[
  {
    "id": 14,
    "name": "Command Ship",
    "cheatsheet_details": "...",
    "cheatsheet_extended_details": "..."
  }
]
```

---

### GET `/api/struct/{struct_id}`

Get struct by ID.

- **ID**: `webapp-struct-by-id`
- **Response Schema**: `schemas/entities.md#Struct`
- **Content Type**: `application/json`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `struct_id` | string | Yes | struct-id | Struct identifier |

#### Example

**Request**: `GET http://localhost:8080/api/struct/5-1`

**Response**:

```json
{
  "id": "5-1",
  "structTypeId": 14,
  "owner": "1-11",
  "locationId": "2-1",
  "health": 100
}
```

---

### GET `/api/struct/list/all/page/{page}`

Catalog list of every struct on the chain, paginated.

- **ID**: `webapp-struct-list-all`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `page` | integer | Yes | `\d+` | Page number, 1-indexed |

---

### GET `/api/struct/list/owner/{owner}/page/{page}`

Catalog list of structs owned by a player.

- **ID**: `webapp-struct-list-by-owner`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `owner` | string | Yes | player-id | Owning player identifier (e.g. `1-11`) |
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/struct/list/location/{location_id}/page/{page}`

Catalog list of structs sitting on a given location object (planet, fleet, or other container).

- **ID**: `webapp-struct-list-by-location`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `location_id` | string | Yes | entity-id | Location object identifier (e.g. planet `2-1` or fleet `9-11`) |
| `page` | integer | Yes | `\d+` | Page number |

---

## Response Schema

### Struct Response

Destroyed structs are filtered out of responses. The `is_destroyed` field is used in queries (`WHERE s.is_destroyed = false`) but destroyed structs are not returned to clients.

```json
{
  "id": "5-1",
  "structTypeId": 14,
  "owner": "1-11",
  "locationId": "2-1",
  "health": 100,
  "is_building": false
}
```

### Struct Type Response

Struct type responses include cheatsheet fields (verified via `SELECT * FROM struct_type`):

```json
{
  "id": 14,
  "name": "Command Ship",
  "cheatsheet_details": "...",
  "cheatsheet_extended_details": "...",
  ...
}
```

**See**: `reviews/webapp-review-findings.md` for code review verification

The `/api/struct/list/...` endpoints return the standard catalog envelope (see `protocols/webapp-api-protocol.md`).
