# Webapp Struct Defender API Endpoints

**Category**: webapp (catalog read)
**Entity**: StructDefender (`structs.struct_defender`)
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Overview

Defender relationships between structs. A row `(defending_struct_id, protected_struct_id)` means the **defender** intercepts attacks against the **protected** target. See `knowledge/mechanics/combat.md` for the resolution order.

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/struct-defender/all/page/{page}` | List every defender relationship | No |
| GET | `/api/struct-defender/defending/{defending_struct_id}` | Get the relationship a defender has (returns one row) | No |
| GET | `/api/struct-defender/protected/{protected_struct_id}/page/{page}` | List defenders covering a protected struct | No |

---

## Endpoint Details

### GET `/api/struct-defender/all/page/{page}`

- **ID**: `webapp-struct-defender-all`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/struct-defender/defending/{defending_struct_id}`

A defender struct can only have one active assignment, so this endpoint returns a single row (no pagination).

- **ID**: `webapp-struct-defender-by-defending`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `defending_struct_id` | string | Yes | struct-id | Defender struct identifier |

---

### GET `/api/struct-defender/protected/{protected_struct_id}/page/{page}`

A protected struct can have many defenders.

- **ID**: `webapp-struct-defender-by-protected`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `protected_struct_id` | string | Yes | struct-id | Protected struct identifier |
| `page` | integer | Yes | `\d+` | Page number |

---

Responses use the standard catalog envelope (see `protocols/webapp-api-protocol.md`).
