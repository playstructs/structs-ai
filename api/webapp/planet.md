# Webapp Planet API Endpoints

**Category**: webapp
**Entity**: Planet
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/planet/{planet_id}` | Get planet information from web application | Yes |
| GET | `/api/planet/{planet_id}/shield/health` | Get planet shield health | Yes |
| GET | `/api/planet/{planet_id}/shield` | Get planet shield information | Yes |
| GET | `/api/planet/{planet_id}/raid/active` | Get active raid for planet | Yes |
| GET | `/api/planet/raid/active/fleet/{fleet_id}` | Get active raid for fleet | Yes |
| GET | `/api/planet/list/all/page/{page}` | Catalog list of all planets, paginated | Yes |
| GET | `/api/planet/list/owner/{owner}/page/{page}` | Catalog list of planets owned by a player | Yes |

Planet activity (`planet_activity`, including `struct_health` rows) and per-planet attribute reads live in [`planet-activity.md`](planet-activity.md) and [`planet-attribute.md`](planet-attribute.md).

---

## Endpoint Details

### GET `/api/planet/{planet_id}`

Get planet information from web application.

- **ID**: `webapp-planet-by-id`
- **Response Schema**: `schemas/entities.md#Planet`
- **Content Type**: `application/json`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `planet_id` | string | Yes | planet-id | Planet identifier |

#### Example

**Request**: `GET http://localhost:8080/api/planet/3-1`

**Response** — envelope; `data` is a single planet row with the `PlanetManager::getPlanet` SQL columns (snake_case), or `null`:

```json
{
  "success": true,
  "errors": {},
  "data": {
    "id": "2-1",
    "owner": "1-11",
    "map": "...",
    "name": "PlanetName",
    "space_slots": 4,
    "air_slots": 2,
    "land_slots": 3,
    "water_slots": 1,
    "undiscovered_ore": 5
  }
}
```

---

### GET `/api/planet/{planet_id}/shield/health`

Get planet shield health.

- **ID**: `webapp-planet-shield-health`
- **Response Schema**: `schemas/responses.md#ShieldHealthResponse`
- **Content Type**: `application/json`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `planet_id` | string | Yes | planet-id | Planet identifier |

#### Example

**Request**: `GET http://localhost:8080/api/planet/2-1/shield/health` (planet IDs are type 2, `^2-[0-9]+$`)

**Response** (envelope):

```json
{
  "success": true,
  "errors": {},
  "data": {
    "planet_id": "2-1",
    "health": 1000,
    "max_health": 1000
  }
}
```

---

### GET `/api/planet/{planet_id}/shield`

Get planet shield information.

- **ID**: `webapp-planet-shield`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `planet_id` | string | Yes | planet-id | Planet identifier |

---

### GET `/api/planet/{planet_id}/raid/active`

Get active raid for planet.

- **ID**: `webapp-planet-raid-active`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `planet_id` | string | Yes | planet-id | Planet identifier |

---

### GET `/api/planet/raid/active/fleet/{fleet_id}`

Get active raid for fleet.

- **ID**: `webapp-planet-raid-active-fleet`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `fleet_id` | string | Yes | fleet-id | Fleet identifier |

---

### GET `/api/planet/list/all/page/{page}`

Catalog list of every planet on the chain, paginated.

- **ID**: `webapp-planet-list-all`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `page` | integer | Yes | `\d+` | Page number, 1-indexed |

---

### GET `/api/planet/list/owner/{owner}/page/{page}`

Catalog list of planets owned by a player.

- **ID**: `webapp-planet-list-by-owner`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `owner` | string | Yes | player-id | Owning player identifier (e.g. `1-11`) |
| `page` | integer | Yes | `\d+` | Page number |

---

## Response Schema

Raid responses include the `attackerRetreated` status, wrapped in the standard envelope:

```json
{
  "success": true,
  "errors": {},
  "data": {
    "raid": {
      "id": "...",
      "status": "attackerRetreated",
      "outcome": "attackerRetreated"
    }
  }
}
```

The `/api/planet/list/...` endpoints return the shared envelope with rows **directly in `data` as a flat array** (fixed page size 100 — if `data.length === 100`, fetch the next page). Bespoke planet endpoints also use the `{ "success", "errors", "data" }` envelope. See `protocols/webapp-api-protocol.md`.
