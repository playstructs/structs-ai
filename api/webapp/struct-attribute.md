# Webapp Struct Attribute API Endpoints

**Category**: webapp (catalog read)
**Entity**: StructAttribute (`structs.struct_attribute`)
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Overview

Per-struct typed attributes — health, ambit, build state, and other scalar properties that vary per struct. Cache rows are deleted when the chain attribute reaches zero — missing rows mean "no value", not "value of zero".

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/struct-attribute/all/page/{page}` | List every struct attribute row | Yes |
| GET | `/api/struct-attribute/object/{object_id}/page/{page}` | List attributes on a struct | Yes |
| GET | `/api/struct-attribute/type/{attribute_type}/page/{page}` | List one attribute type across every struct | Yes |

---

## Endpoint Details

### GET `/api/struct-attribute/all/page/{page}`

- **ID**: `webapp-struct-attribute-all`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/struct-attribute/object/{object_id}/page/{page}`

- **ID**: `webapp-struct-attribute-by-object`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `object_id` | string | Yes | struct-id | Struct identifier (e.g. `5-1`) |
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/struct-attribute/type/{attribute_type}/page/{page}`

- **ID**: `webapp-struct-attribute-by-type`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `attribute_type` | string | Yes | -- | Attribute type name (e.g. `health`, `ambit`) |
| `page` | integer | Yes | `\d+` | Page number |

---

Responses use the shared envelope (`{ "success": true, "errors": {}, "data": [ ...rows ] }`); catalog rows are returned **directly in `data` as a flat array** with a fixed page size of 100 — if `data.length === 100`, request the next page. See `protocols/webapp-api-protocol.md`.
