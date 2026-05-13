# Webapp Fleet API Endpoints

**Category**: webapp (catalog read)
**Entity**: Fleet
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Overview

Catalog list of fleets. For per-fleet detail use the chain query at `/structs/fleet/{id}` (see `api/queries/fleet.md`); this webapp surface is for paginated listing only.

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/fleet/list/all/page/{page}` | List every fleet | No |
| GET | `/api/fleet/list/location/{location_id}/page/{page}` | List fleets at a location | No |

---

## Endpoint Details

### GET `/api/fleet/list/all/page/{page}`

- **ID**: `webapp-fleet-list-all`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/fleet/list/location/{location_id}/page/{page}`

List fleets currently at a location. The location is typically a planet ID (`2-x`).

- **ID**: `webapp-fleet-list-by-location`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `location_id` | string | Yes | entity-id | Location object identifier (planet, etc.) |
| `page` | integer | Yes | `\d+` | Page number |

---

Responses use the standard catalog envelope (see `protocols/webapp-api-protocol.md`).
