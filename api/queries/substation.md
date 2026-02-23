# Substation Query Endpoints

**Version**: 1.0.0
**Category**: Query
**Entity**: Substation
**Base URL**: `http://localhost:1317`
**Base Path**: `/structs`

---

## Endpoint Summary

| Method | Path | Description | Auth | Paginated |
|--------|------|-------------|------|-----------|
| GET | `/structs/substation/{id}` | Get substation by ID | No | No |
| GET | `/structs/substation` | List all substations | No | Yes |

---

## Endpoint Details

### Get Substation by ID

`GET /structs/substation/{id}`

Returns a single substation by its entity ID.

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `id` | string | Yes | entity-id (`^4-[0-9]+$`) | Substation identifier in format 'type-index' (e.g., '4-3' for substation type 4, index 3). Type 4 = Substation. |

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities/substation.md`

---

### List All Substations

`GET /structs/substation`

Returns a paginated list of all substations.

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities/substation.md` (array)
