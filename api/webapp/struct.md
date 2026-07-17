# Webapp Struct API Endpoints

**Category**: webapp
**Entity**: Struct
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/struct/player/{player_id}` | Get structs by player ID | Yes |
| GET | `/api/struct/type` | Get struct types | Yes |
| GET | `/api/struct/{struct_id}` | Get struct by ID | Yes |
| GET | `/api/struct/list/all/page/{page}` | Catalog list of every struct | Yes |
| GET | `/api/struct/list/owner/{owner}/page/{page}` | Catalog list of structs owned by a player | Yes |
| GET | `/api/struct/list/location/{location_id}/page/{page}` | Catalog list of structs at a location | Yes |

Per-struct attributes and defender relationships live in [`struct-attribute.md`](struct-attribute.md) and [`struct-defender.md`](struct-defender.md).

> **`health` and numeric `status` are only on the bespoke endpoints.** The catalog `list/*` endpoints return **base struct columns only** (no `health`, no `status`) — they read `structs.struct` with no joins. The bespoke endpoints (`/api/struct/player/{id}`, `/api/struct/{id}`) `LEFT JOIN struct_attribute` to add `health` and the numeric `status` bitmask. If you need HP, built-state, or status from a list, either call a bespoke endpoint per struct or read the chain entity (`GET /structs/struct/{id}` → `structAttributes.health`, `.isBuilt`, `.blockStartBuild`, `.status`). See [api/integration-notes.md — Where struct HP and status live](../integration-notes.md#where-struct-hp-and-status-live).

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

**Response** — envelope; `data` is a flat array of `struct s.*` rows (snake_case) plus joined `health`, `status`, `defending_struct_ids`:

```json
{
  "success": true,
  "errors": {},
  "data": [
    {
      "id": "5-1",
      "type": 14,
      "owner": "1-11",
      "location_type": "planet",
      "location_id": "2-1",
      "operating_ambit": "space",
      "slot": 0,
      "is_destroyed": false,
      "health": 100,
      "status": 1,
      "defending_struct_ids": []
    }
  ]
}
```

---

### GET `/api/struct/type`

Get struct types.

- **ID**: `webapp-struct-type`
- **Response Schema**: `schemas/entities.md#StructType`
- **Content Type**: `application/json`

#### Example

**Request**: `GET http://localhost:8080/api/struct/type`

**Response** (envelope; flat array of `struct_type` rows, snake_case):

```json
{
  "success": true,
  "errors": {},
  "data": [
    {
      "id": 14,
      "name": "Command Ship",
      "generating_rate": "0",
      "generating_rate_p": "0",
      "primary_weapon_armour_piercing": false,
      "secondary_weapon_armour_piercing": false,
      "cheatsheet_details": "...",
      "cheatsheet_extended_details": "..."
    }
  ]
}
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

**Response** (envelope; `data` is a single snake_case struct row, or `null`):

```json
{
  "success": true,
  "errors": {},
  "data": {
    "id": "5-1",
    "type": 14,
    "owner": "1-11",
    "location_type": "planet",
    "location_id": "2-1",
    "operating_ambit": "space",
    "slot": 0,
    "is_destroyed": false,
    "health": 100,
    "status": 1,
    "defending_struct_ids": []
  }
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

#### Response

The catalog list returns **base columns only** — `id, index, type, creator, owner, location_type, location_id, operating_ambit, slot, is_destroyed, destroyed_block, created_at, updated_at`. **No `health`, no `status`, no `defending_struct_ids`** (verified in webapp `TableReadManager::structListAll`). The same column set applies to the `owner` and `location` list variants.

```json
{
  "success": true,
  "errors": {},
  "data": [
    {
      "id": "5-1",
      "index": 1,
      "type": 14,
      "creator": "structs1...",
      "owner": "1-11",
      "location_type": "planet",
      "location_id": "2-1",
      "operating_ambit": "space",
      "slot": 0,
      "is_destroyed": false,
      "destroyed_block": null,
      "created_at": "...",
      "updated_at": "..."
    }
  ]
}
```

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

Destroyed structs are filtered out of responses. The `is_destroyed` field is used in queries (`WHERE s.is_destroyed = false`) but destroyed structs are not returned to clients. The bespoke struct managers select `struct s.*` (snake_case DB columns) plus joined `health`, `status`, and `defending_struct_ids`, wrapped in the standard envelope:

```json
{
  "success": true,
  "errors": {},
  "data": {
    "id": "5-1",
    "type": 14,
    "owner": "1-11",
    "location_type": "planet",
    "location_id": "2-1",
    "operating_ambit": "space",
    "slot": 0,
    "is_destroyed": false,
    "health": 100,
    "status": 1,
    "defending_struct_ids": []
  }
}
```

### Struct Type Response

Struct type responses include cheatsheet fields plus the power/weapon columns (verified via `SELECT * FROM struct_type`):

```json
{
  "id": 14,
  "name": "Command Ship",
  "generating_rate": "0",
  "generating_rate_p": "0",
  "primary_weapon_armour_piercing": false,
  "secondary_weapon_armour_piercing": false,
  "cheatsheet_details": "...",
  "cheatsheet_extended_details": "...",
  ...
}
```

- **`generating_rate`** and **`generating_rate_p`** are LCD numeric strings. `generating_rate_p` is the higher-precision passive-generation column added alongside the original `generating_rate` (see [api/integration-notes.md](../integration-notes.md)).
- **`primary_weapon_armour_piercing`** / **`secondary_weapon_armour_piercing`** are booleans indicating whether each weapon ignores armour mitigation.

**See**: `reviews/webapp-review-findings.md` for code review verification

The `/api/struct/list/...` endpoints return the shared envelope with rows **directly in `data` as a flat array** (fixed page size 100 — if `data.length === 100`, fetch the next page). These catalog rows carry only the base struct columns (no `health`/`status`/`defending_struct_ids`); use a bespoke endpoint or the chain entity for those. Bespoke struct endpoints also use the `{ "success", "errors", "data" }` envelope. See `protocols/webapp-api-protocol.md`.
