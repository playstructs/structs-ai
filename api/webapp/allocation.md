# Webapp Allocation API Endpoints

**Category**: webapp (catalog read)
**Entity**: Allocation (`structs.allocation`)
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Overview

Energy allocations route power between sources and destinations. Each allocation has a source object, a destination object, a creator, and a controller (which is a player ID — see `knowledge/mechanics/power.md`).

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/allocation/all/page/{page}` | List every allocation | Yes |
| GET | `/api/allocation/source/{source_id}/page/{page}` | List allocations from a source object | Yes |
| GET | `/api/allocation/destination/{destination_id}/page/{page}` | List allocations targeting a destination object | Yes |
| GET | `/api/allocation/creator/{creator}/page/{page}` | List allocations created by a player | Yes |
| GET | `/api/allocation/controller/{controller}/page/{page}` | List allocations whose controller is a player | Yes |

---

## Endpoint Details

### GET `/api/allocation/all/page/{page}`

- **ID**: `webapp-allocation-all`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/allocation/source/{source_id}/page/{page}`

- **ID**: `webapp-allocation-by-source`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `source_id` | string | Yes | entity-id | Source object identifier (e.g. a substation `4-1`) |
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/allocation/destination/{destination_id}/page/{page}`

- **ID**: `webapp-allocation-by-destination`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `destination_id` | string | Yes | entity-id | Destination object identifier |
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/allocation/creator/{creator}/page/{page}`

- **ID**: `webapp-allocation-by-creator`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `creator` | string | Yes | player-id | Creator player identifier |
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/allocation/controller/{controller}/page/{page}`

The controller of an allocation is the **player** authorised to mutate it.

- **ID**: `webapp-allocation-by-controller`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `controller` | string | Yes | player-id | Controller player identifier |
| `page` | integer | Yes | `\d+` | Page number |

---

Responses use the shared envelope (`{ "success": true, "errors": {}, "data": [ ...rows ] }`); catalog rows are returned **directly in `data` as a flat array** with a fixed page size of 100 — if `data.length === 100`, request the next page. See `protocols/webapp-api-protocol.md`.
