# Webapp Substation API Endpoints

**Category**: webapp (catalog read)
**Entity**: Substation (`structs.substation`)
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Overview

Substations route reactor power to connected players and structs. Each substation has an owning player. See `knowledge/mechanics/power.md` and `.cursor/skills/structs-power/SKILL.md`.

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/substation/all/page/{page}` | List every substation | No |
| GET | `/api/substation/owner/{owner}/page/{page}` | List substations owned by a player | No |

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

Responses use the standard catalog envelope (see `protocols/webapp-api-protocol.md`).
