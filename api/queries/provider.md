# Provider Query Endpoints

**Version**: 1.0.0
**Category**: Query
**Entity**: Provider
**Base URL**: `http://localhost:1317`
**Base Path**: `/structs`

---

## Endpoint Summary

| Method | Path | Description | Auth | Paginated |
|--------|------|-------------|------|-----------|
| GET | `/structs/provider/{id}` | Get provider by ID | No | No |
| GET | `/structs/provider` | List all providers | No | Yes |

---

## Endpoint Details

### Get Provider by ID

`GET /structs/provider/{id}`

Returns a single provider by its ID.

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `id` | string | Yes | provider-id | Provider identifier |

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities/provider.md`

---

### List All Providers

`GET /structs/provider`

Returns a paginated list of all providers.

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities/provider.md` (array)
