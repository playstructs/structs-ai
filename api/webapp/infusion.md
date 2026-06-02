# Webapp Infusion API Endpoints

**Category**: webapp
**Entity**: Infusion
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/infusion/player/{player_id}` | Get infusions for player (full reactor-staking detail) | Yes |
| GET | `/api/infusion/list/all/page/{page}` | List every infusion on the chain | Yes |
| GET | `/api/infusion/list/destination/{destination_id}/page/{page}` | List infusions targeting a destination object (e.g. a reactor) | Yes |
| GET | `/api/infusion/list/address/{address}/page/{page}` | List infusions made by a Cosmos address | Yes |
| GET | `/api/infusion/list/player/{player_id}/page/{page}` | Lightweight paginated list of infusions made by a player | Yes |

The single-player endpoint (`/api/infusion/player/{player_id}`) returns full reactor-staking context. The `/api/infusion/list/...` family returns paginated catalog rows for browsing or analytics; choose the variant by the filter you have.

---

## Endpoint Details

### GET `/api/infusion/player/{player_id}`

Get infusions for player.

- **ID**: `webapp-infusion-by-player`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `player_id` | string | Yes | player-id | Player identifier |

---

### GET `/api/infusion/list/all/page/{page}`

List every infusion on the chain, paginated.

- **ID**: `webapp-infusion-list-all`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `page` | integer | Yes | `\d+` | Page number, 1-indexed |

---

### GET `/api/infusion/list/destination/{destination_id}/page/{page}`

List infusions targeting a destination object.

- **ID**: `webapp-infusion-list-by-destination`

> **Multi-row, not a summary.** `structs.infusion` is keyed on `(destination_id, address)`, so this endpoint returns **one row per infusing address** at that destination — a reactor with many stakers returns many rows. **Do not treat `data[0]` as "the reactor's infusion"** — that silently drops every other staker. To get a destination's total you must aggregate across all rows (and all pages, since the page size is 100). There is **no** `/api/infusion/reactor/{id}` route in Symfony; use this `list/destination/{id}` path with the reactor ID as `destination_id`.

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `destination_id` | string | Yes | entity-id | Destination object identifier (e.g. a reactor `3-1` or generator) |
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/infusion/list/address/{address}/page/{page}`

List infusions made by a Cosmos address.

- **ID**: `webapp-infusion-list-by-address`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `address` | string | Yes | bech32 | Cosmos address (e.g. `structs1...`) |
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/infusion/list/player/{player_id}/page/{page}`

Paginated list of infusions made by a player. Use this when iterating large infusion sets — `/api/infusion/player/{player_id}` returns full staking context per row and is heavier.

- **ID**: `webapp-infusion-list-by-player`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `player_id` | string | Yes | player-id | Player identifier |
| `page` | integer | Yes | `\d+` | Page number |

---

## Response Schema

### Catalog rows (`/api/infusion/list/...`)

All four `list/*` endpoints select the same raw `structs.infusion` columns (snake_case) and return them **directly in `data` as a flat array** — one row per `(destination_id, address)`:

| Column | Description |
|--------|-------------|
| `destination_id` | Object being infused (e.g. reactor `3-1`) |
| `address` | Cosmos address that infused |
| `destination_type` | Destination kind (e.g. `reactor`, `struct`) |
| `player_id` | Player owning `address` |
| `fuel` / `fuel_p` | Fuel amount / pending fuel |
| `defusing` / `defusing_p` | Defusing amount / pending |
| `power` / `power_p` | Power contribution / pending |
| `ratio` / `ratio_p` | Share ratio / pending |
| `commission` | Commission rate |
| `created_at` / `updated_at` | Timestamps |

```json
{
  "success": true,
  "errors": {},
  "data": [
    {
      "destination_id": "3-1",
      "address": "structs1...",
      "destination_type": "reactor",
      "player_id": "1-11",
      "fuel": "1000000",
      "fuel_p": "0",
      "power": "1000000",
      "power_p": "0",
      "ratio": "...",
      "commission": "...",
      "created_at": "...",
      "updated_at": "..."
    }
  ]
}
```

Because the rows are multi-staker, derive a destination total by summing across **all** rows and pages — never from a single row.

### Bespoke single-player (`/api/infusion/player/{player_id}`)

This `InfusionController` endpoint joins infusion + reactor staking context for one player and returns it inside the envelope's `data` (richer than the raw catalog rows). Unwrap `data` after checking `success`.

The `/api/infusion/list/...` endpoints use the shared envelope with rows directly in `data` as a flat array (page size 100). See `protocols/webapp-api-protocol.md`.
