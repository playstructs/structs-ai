# Allocation Query Endpoints

**Version**: 1.0.0
**Category**: Query
**Entity**: Allocation
**Base URL**: `http://localhost:1317`
**Base Path**: `/structs`

---

## Endpoint Summary

| Method | Path | Description | Auth | Paginated |
|--------|------|-------------|------|-----------|
| GET | `/structs/allocation/{id}` | Get allocation by ID | No | No |
| GET | `/structs/allocation` | List all allocations | No | Yes |
| GET | `/structs/allocation_by_source/{sourceId}` | Get allocations by source | No | No |
| GET | `/structs/allocation_by_destination/{destinationId}` | Get allocations by destination | No | No |

---

## Endpoint Details

### Get Allocation by ID

`GET /structs/allocation/{id}`

Returns a single allocation by its ID.

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `id` | string | Yes | allocation-id | Allocation identifier |

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities/allocation.md`

---

### List All Allocations

`GET /structs/allocation`

Returns a paginated list of all allocations.

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities/allocation.md` (array)

---

### Get Allocations by Source

`GET /structs/allocation_by_source/{sourceId}`

Returns all allocations originating from a specific source.

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `sourceId` | string | Yes | - | Source identifier |

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities/allocation.md` (array)

---

### Get Allocations by Destination

`GET /structs/allocation_by_destination/{destinationId}`

Returns all allocations directed to a specific destination.

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `destinationId` | string | Yes | - | Destination identifier |

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities/allocation.md` (array)
