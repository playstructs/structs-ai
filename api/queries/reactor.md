# Reactor Query Endpoints

**Version**: 1.0.0
**Category**: Query
**Entity**: Reactor
**Base URL**: `http://localhost:1317`
**Base Path**: `/structs`

---

## Endpoint Summary

| Method | Path | Description | Auth | Paginated |
|--------|------|-------------|------|-----------|
| GET | `/structs/reactor/{id}` | Get reactor by ID | No | No |
| GET | `/structs/reactor` | List all reactors | No | Yes |

---

## Endpoint Details

### Get Reactor by ID

`GET /structs/reactor/{id}`

Returns a single reactor by its entity ID.

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `id` | string | Yes | entity-id (`^3-[0-9]+$`) | Reactor identifier in format 'type-index' (e.g., '3-1' for reactor type 3, index 1). Type 3 = Reactor. |

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities/reactor.md`

---

### List All Reactors

`GET /structs/reactor`

Returns a paginated list of all reactors.

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities/reactor.md` (array)
