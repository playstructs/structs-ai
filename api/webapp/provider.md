# Webapp Provider API Endpoints

**Category**: webapp (catalog read)
**Entity**: Provider (`structs.provider`)
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Overview

Energy providers — the supply side of the agreement market. Each provider has an owner, a denom (the token used to pay for energy), and a substation (the source of the power being sold). See `knowledge/economy/energy-market.md`.

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/provider/all/page/{page}` | List every provider | Yes |
| GET | `/api/provider/owner/{owner}/page/{page}` | List providers owned by a player | Yes |
| GET | `/api/provider/denom/{denom}/page/{page}` | List providers selling for a denom | Yes |
| GET | `/api/provider/substation/{substation_id}/page/{page}` | List providers backed by a substation | Yes |

---

## Endpoint Details

### GET `/api/provider/all/page/{page}`

- **ID**: `webapp-provider-all`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/provider/owner/{owner}/page/{page}`

- **ID**: `webapp-provider-by-owner`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `owner` | string | Yes | player-id | Owning player identifier |
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/provider/denom/{denom}/page/{page}`

- **ID**: `webapp-provider-by-denom`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `denom` | string | Yes | -- | Denomination string (e.g. `ualpha`, `uguild.0-1`) |
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/provider/substation/{substation_id}/page/{page}`

- **ID**: `webapp-provider-by-substation`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `substation_id` | string | Yes | substation-id | Substation identifier (e.g. `4-1`) |
| `page` | integer | Yes | `\d+` | Page number |

---

Responses use the shared envelope (`{ "success": true, "errors": {}, "data": [ ...rows ] }`); catalog rows are returned **directly in `data` as a flat array** with a fixed page size of 100 — if `data.length === 100`, request the next page. See `protocols/webapp-api-protocol.md`.
