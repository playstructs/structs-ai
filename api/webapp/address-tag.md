# Webapp Address Tag API Endpoints

**Category**: webapp (catalog read)
**Entity**: AddressTag (`structs.address_tag`)
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Overview

Labelled address records — used by guild webapps to attach human-readable tags (and an `entry` field for ordering) to Cosmos addresses. Backed by `structs.address_tag (address, label)` PK with a reverse-lookup index on `(label, entry)`.

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/address-tag/all/page/{page}` | List every address tag, paginated | Yes |
| GET | `/api/address-tag/address/{address}/page/{page}` | List tags attached to a specific address | Yes |

---

## Endpoint Details

### GET `/api/address-tag/all/page/{page}`

List every address tag.

- **ID**: `webapp-address-tag-all`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `page` | integer | Yes | `\d+` | Page number, 1-indexed |

---

### GET `/api/address-tag/address/{address}/page/{page}`

List tags attached to a specific Cosmos address.

- **ID**: `webapp-address-tag-by-address`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `address` | string | Yes | bech32 | Cosmos address (e.g. `structs1...`) |
| `page` | integer | Yes | `\d+` | Page number |

---

Responses use the shared envelope (`{ "success": true, "errors": {}, "data": [ ...rows ] }`); catalog rows are returned **directly in `data` as a flat array** with a fixed page size of 100 — if `data.length === 100`, request the next page. See `protocols/webapp-api-protocol.md`.
