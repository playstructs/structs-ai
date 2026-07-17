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
| GET | `/api/fleet/list/all/page/{page}` | List every fleet | Yes |
| GET | `/api/fleet/list/location/{location_id}/page/{page}` | List fleets at a location | Yes |
| GET | `/api/fleet/player/{player_id}` | Get a player's fleet | Yes |

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

### GET `/api/fleet/player/{player_id}`

Get the fleet belonging to a single player. Not paginated.

- **ID**: `webapp-fleet-by-player`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `player_id` | string | Yes | `\d+-\d+` | Player identifier (e.g. `1-5`) |

---

Responses use the shared envelope (`{ "success": true, "errors": {}, "data": [ ...rows ] }`); catalog rows are returned **directly in `data` as a flat array** with a fixed page size of 100 — if `data.length === 100`, request the next page. See `protocols/webapp-api-protocol.md`.
