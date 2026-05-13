# Webapp Grid API Endpoints

**Category**: webapp (catalog read)
**Entity**: Grid attribute (`structs.grid_attribute` / GRASS `grid` events)
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Overview

The grid table holds per-object scalar attributes (`capacity`, `connectionCapacity`, `connectionCount`, `fuel`, `lastAction`, `load`, `nonce`, `ore`, `power`, `proxyNonce`, `structsLoad`, etc.). The same data drives the GRASS `structs.grid.{object_id}` event stream — see `.cursor/skills/structs-streaming/SKILL.md`. These read endpoints expose the current snapshot for browsing or analytics.

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/grid/all/page/{page}` | List every grid attribute row | No |
| GET | `/api/grid/object/{object_id}/page/{page}` | List all grid attributes for one object | No |
| GET | `/api/grid/attribute-type/{attribute_type}/page/{page}` | List one attribute type across every object | No |

---

## Endpoint Details

### GET `/api/grid/all/page/{page}`

- **ID**: `webapp-grid-all`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/grid/object/{object_id}/page/{page}`

- **ID**: `webapp-grid-by-object`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `object_id` | string | Yes | entity-id | Object identifier (player, planet, struct, etc.) |
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/grid/attribute-type/{attribute_type}/page/{page}`

List one attribute type across every object that has it. Useful for "show me every entity with `ore > 0`" style scans (after client-side filtering).

- **ID**: `webapp-grid-by-attribute-type`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `attribute_type` | string | Yes | -- | Attribute type name (e.g. `ore`, `capacity`, `load`, `fuel`, `power`) |
| `page` | integer | Yes | `\d+` | Page number |

---

Responses use the standard catalog envelope (see `protocols/webapp-api-protocol.md`).
