# Webapp Permission Guild Rank API Endpoints

**Category**: webapp (catalog read)
**Entity**: PermissionGuildRank (`structs.permission_guild_rank`)
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Overview

Permission grants attached to a **guild rank** rather than to a specific player. Any player whose `player.guild_rank` is at or above the threshold inherits the grant on the object. See `knowledge/mechanics/permissions.md` for the rank-to-bitmask mapping.

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/permission-guild-rank/all/page/{page}` | List every guild-rank permission grant | Yes |
| GET | `/api/permission-guild-rank/object/{object_id}/page/{page}` | List rank grants on an object | Yes |
| GET | `/api/permission-guild-rank/guild/{guild_id}/page/{page}` | List rank grants belonging to a guild | Yes |

---

## Endpoint Details

### GET `/api/permission-guild-rank/all/page/{page}`

- **ID**: `webapp-permission-guild-rank-all`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/permission-guild-rank/object/{object_id}/page/{page}`

- **ID**: `webapp-permission-guild-rank-by-object`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `object_id` | string | Yes | entity-id | Target object identifier |
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/permission-guild-rank/guild/{guild_id}/page/{page}`

- **ID**: `webapp-permission-guild-rank-by-guild`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `guild_id` | string | Yes | guild-id | Guild identifier |
| `page` | integer | Yes | `\d+` | Page number |

---

Responses use the shared envelope (`{ "success": true, "errors": {}, "data": [ ...rows ] }`); catalog rows are returned **directly in `data` as a flat array** with a fixed page size of 100 — if `data.length === 100`, request the next page. See `protocols/webapp-api-protocol.md`.
