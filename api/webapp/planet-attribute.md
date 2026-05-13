# Webapp Planet Attribute API Endpoints

**Category**: webapp (catalog read)
**Entity**: PlanetAttribute (`structs.planet_attribute`)
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Overview

Per-planet typed attributes (shield health, ore reserves, slot counts, defensive metadata, etc.). Cache rows are deleted when the chain attribute reaches zero — missing rows mean "no value", not "value of zero".

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/planet-attribute/all/page/{page}` | List every planet attribute row | No |
| GET | `/api/planet-attribute/object/{object_id}/page/{page}` | List attributes on a planet | No |
| GET | `/api/planet-attribute/type/{attribute_type}/page/{page}` | List one attribute type across every planet | No |

---

## Endpoint Details

### GET `/api/planet-attribute/all/page/{page}`

- **ID**: `webapp-planet-attribute-all`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/planet-attribute/object/{object_id}/page/{page}`

- **ID**: `webapp-planet-attribute-by-object`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `object_id` | string | Yes | planet-id | Planet identifier (e.g. `2-1`) |
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/planet-attribute/type/{attribute_type}/page/{page}`

- **ID**: `webapp-planet-attribute-by-type`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `attribute_type` | string | Yes | -- | Attribute type name (e.g. `shield_health`, `ore`, `slots`) |
| `page` | integer | Yes | `\d+` | Page number |

---

Responses use the standard catalog envelope (see `protocols/webapp-api-protocol.md`).
