# Webapp Planet API Endpoints

**Version**: 1.1.0
**Category**: webapp
**Entity**: Planet
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`)
**Last Updated**: January 1, 2026

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/planet/{planet_id}` | Get planet information from web application | No |
| GET | `/api/planet/{planet_id}/shield/health` | Get planet shield health | No |
| GET | `/api/planet/{planet_id}/shield` | Get planet shield information | No |
| GET | `/api/planet/{planet_id}/raid/active` | Get active raid for planet | No |
| GET | `/api/planet/raid/active/fleet/{fleet_id}` | Get active raid for fleet | No |

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

**Response**:

```json
{
  "id": "3-1",
  "owner_id": "1-11",
  "max_ore": 5,
  "space_slots": 4
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

**Request**: `GET http://localhost:8080/api/planet/3-1/shield/health`

**Response**:

```json
{
  "planet_id": "3-1",
  "health": 1000,
  "max_health": 1000
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

## Response Schema

Raid responses include the `attackerRetreated` status:

```json
{
  "raid": {
    "id": "...",
    "status": "attackerRetreated",
    "outcome": "attackerRetreated",
    ...
  }
}
```

---

*Last Updated: January 1, 2026*
