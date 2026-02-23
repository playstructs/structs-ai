# Struct Query Endpoints

**Version**: 1.0.0
**Category**: Query
**Entity**: Struct
**Base URL**: `http://localhost:1317`
**Base Path**: `/structs`

---

## Endpoint Summary

| Method | Path | Description | Auth | Paginated |
|--------|------|-------------|------|-----------|
| GET | `/structs/struct/{id}` | Get struct by ID | No | No |
| GET | `/structs/struct` | List all structs | No | Yes |

---

## Endpoint Details

### Get Struct by ID

`GET /structs/struct/{id}`

Returns a single struct by its entity ID.

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `id` | string | Yes | entity-id | Struct identifier |

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities/struct.md`

---

### List All Structs

`GET /structs/struct`

Returns a paginated list of all structs.

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `pagination.key` | string | No | - | Pagination key |
| `pagination.limit` | integer | No | - | Page size |

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities/struct.md` (array)
