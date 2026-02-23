# Webapp Struct API Endpoints

**Version**: 1.1.0
**Category**: webapp
**Entity**: Struct
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`)
**Last Updated**: January 1, 2026

---

## v0.8.0-beta Notes

**Struct Lifecycle Changes** (Verified):
- **Destroyed Field**: Struct queries filter out destroyed structs (`is_destroyed = false`). Destroyed structs are not returned in API responses, consistent with StructSweepDelay behavior (destroyed structs persist for 5 blocks in database but are filtered from queries).
- **StructSweepDelay**: Destroyed structs persist for 5 blocks before being fully removed from database.
- **Struct Type Fields**: Struct type endpoint includes `cheatsheet_details` and `cheatsheet_extended_details` fields (via `SELECT * FROM struct_type`).

**See**: `reviews/webapp-review-findings.md` for code review findings

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/struct/player/{player_id}` | Get structs by player ID | No |
| GET | `/api/struct/planet/{planet_id}` | Get structs on planet | No |
| GET | `/api/struct/type` | Get struct types | No |
| GET | `/api/struct/{struct_id}` | Get struct by ID | No |

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

## Response Schema (v0.8.0-beta Verified)

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

---

*Last Updated: January 1, 2026*
