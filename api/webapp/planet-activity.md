# Webapp Planet Activity API Endpoints

**Category**: webapp (catalog read)
**Entity**: PlanetActivity (`structs.planet_activity`)
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Overview

Per-planet activity log — raids, attacks, builds, defender changes, struct health updates, etc. Categories include `raid_status`, `struct_attack`, `struct_health`, `fleet_arrive`, `fleet_depart`, and others; see `.cursor/skills/structs-streaming/SKILL.md` for the GRASS-side category names. Use this REST surface for historical browsing; use GRASS for real-time reaction.

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/planet-activity/all/page/{page}` | List every planet activity row | No |
| GET | `/api/planet-activity/planet/{planet_id}/page/{page}` | List activity for a planet | No |
| GET | `/api/planet-activity/category/{category}/page/{page}` | List activity by category | No |

---

## Endpoint Details

### GET `/api/planet-activity/all/page/{page}`

- **ID**: `webapp-planet-activity-all`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/planet-activity/planet/{planet_id}/page/{page}`

- **ID**: `webapp-planet-activity-by-planet`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `planet_id` | string | Yes | planet-id | Planet identifier |
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/planet-activity/category/{category}/page/{page}`

- **ID**: `webapp-planet-activity-by-category`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `category` | string | Yes | -- | Activity category (e.g. `raid_status`, `struct_attack`, `struct_health`, `fleet_arrive`, `fleet_depart`) |
| `page` | integer | Yes | `\d+` | Page number |

---

Responses use the standard catalog envelope (see `protocols/webapp-api-protocol.md`).
