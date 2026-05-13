# Webapp Permission API Endpoints

**Category**: webapp (catalog read)
**Entity**: Permission (`structs.permission`)
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Overview

Per-object, per-player permission grants. The chain stores a 25-bit permission mask per `(object_id, player_id)` pair; bits are documented in `knowledge/mechanics/permissions.md`. For grants tied to a guild rank rather than a specific player, see [`permission-guild-rank.md`](permission-guild-rank.md).

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/permission/all/page/{page}` | List every permission grant | No |
| GET | `/api/permission/object/{object_id}/page/{page}` | List grants on an object | No |
| GET | `/api/permission/player/{player_id}/page/{page}` | List grants held by a player | No |

---

## Endpoint Details

### GET `/api/permission/all/page/{page}`

- **ID**: `webapp-permission-all`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/permission/object/{object_id}/page/{page}`

- **ID**: `webapp-permission-by-object`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `object_id` | string | Yes | entity-id | Target object identifier |
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/permission/player/{player_id}/page/{page}`

- **ID**: `webapp-permission-by-player`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `player_id` | string | Yes | player-id | Player identifier |
| `page` | integer | Yes | `\d+` | Page number |

---

Responses use the standard catalog envelope (see `protocols/webapp-api-protocol.md`).
