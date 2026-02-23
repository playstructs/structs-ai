# Fleet Query Endpoints

**Version**: 1.0.0
**Category**: Query
**Entity**: Fleet
**Base URL**: `http://localhost:1317`
**Base Path**: `/structs`

---

## Endpoint Summary

| Method | Path | Description | Auth | Paginated |
|--------|------|-------------|------|-----------|
| GET | `/structs/fleet/{id}` | Get fleet by ID | No | No |
| GET | `/structs/fleet` | List all fleets | No | Yes |
| GET | `/structs/fleet_by_index/{index}` | Get fleet by index | No | No |

---

## Endpoint Details

### Get Fleet by ID

`GET /structs/fleet/{id}`

Returns a single fleet by its entity ID.

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `id` | string | Yes | entity-id | Fleet identifier |

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities/fleet.md`

---

### List All Fleets

`GET /structs/fleet`

Returns a paginated list of all fleets.

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities/fleet.md` (array)

---

### Get Fleet by Index

`GET /structs/fleet_by_index/{index}`

Returns a fleet by its index value.

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `index` | string | Yes | - | Fleet index |

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities/fleet.md`
