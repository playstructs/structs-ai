# Webapp Substation API Endpoints

**Category**: webapp (catalog read)
**Entity**: Substation (`structs.substation`)
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Overview

Substations route reactor power to connected players and structs. Each substation has an owning player. See `knowledge/mechanics/power.md` and `.cursor/skills/structs-energy/SKILL.md`.

> **Webapp vs consensus — no single-substation GET.** The webapp exposes substations as **catalog reads only** (`/api/substation/all|owner/.../page/{n}`). There is **no `GET /api/substation/{id}`** in Symfony. To fetch one substation over HTTP, scan/filter the catalog pages client-side. The single-entity path `GET /structs/substation/{id}` is the **consensus (chain REST)** API, not the webapp.

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/substation/all/page/{page}` | List every substation | Yes |
| GET | `/api/substation/owner/{owner}/page/{page}` | List substations owned by a player | Yes |

Player-substation connections are exposed via [`player.md`](player.md) (`/api/player/list/substation/{substation_id}/page/{page}`).

---

## Endpoint Details

### GET `/api/substation/all/page/{page}`

- **ID**: `webapp-substation-all`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/substation/owner/{owner}/page/{page}`

- **ID**: `webapp-substation-by-owner`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `owner` | string | Yes | player-id | Owning player identifier |
| `page` | integer | Yes | `\d+` | Page number |

---

Responses use the shared envelope (`{ "success": true, "errors": {}, "data": [ ...rows ] }`); catalog rows are returned **directly in `data` as a flat array** with a fixed page size of 100 — if `data.length === 100`, request the next page. See `protocols/webapp-api-protocol.md`.
