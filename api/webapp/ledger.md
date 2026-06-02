# Webapp Ledger API Endpoints

**Category**: webapp
**Entity**: Ledger
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/ledger/player/{player_id}/page/{page}` | Get ledger page for a player | Yes |
| GET | `/api/ledger/player/{player_id}/count` | Get ledger count for a player | Yes |
| GET | `/api/ledger/{tx_id}` | Get ledger entry by transaction ID | Yes |
| GET | `/api/ledger/list/all/page/{page}` | List every ledger entry on the chain | Yes |
| GET | `/api/ledger/list/player/{player_id}/page/{page}` | Catalog list of ledger entries for a player | Yes |
| GET | `/api/ledger/list/address/{address}/page/{page}` | List ledger entries for a Cosmos address | Yes |

The `/api/ledger/list/...` family is the catalog read interface and is namespaced under `/list/` so it does not shadow the single-entry `GET /api/ledger/{tx_id}` route.

---

## Endpoint Details

### GET `/api/ledger/player/{player_id}/page/{page}`

Get ledger page for player.

- **ID**: `webapp-ledger-player-page`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `player_id` | string | Yes | player-id | Player identifier |
| `page` | integer | Yes | -- | Page number |

---

### GET `/api/ledger/player/{player_id}/count`

Get ledger count for player.

- **ID**: `webapp-ledger-player-count`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `player_id` | string | Yes | player-id | Player identifier |

---

### GET `/api/ledger/{tx_id}`

Get ledger entry by transaction ID.

- **ID**: `webapp-ledger-by-tx`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `tx_id` | string | Yes | transaction-hash | Transaction identifier |

---

### GET `/api/ledger/list/all/page/{page}`

List every ledger entry on the chain, paginated.

- **ID**: `webapp-ledger-list-all`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `page` | integer | Yes | `\d+` | Page number, 1-indexed |

---

### GET `/api/ledger/list/player/{player_id}/page/{page}`

Catalog list of ledger entries for a player. This is the catalog-read variant — use it when you need consistent paging metadata across entity types.

- **ID**: `webapp-ledger-list-by-player`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `player_id` | string | Yes | player-id | Player identifier |
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/ledger/list/address/{address}/page/{page}`

List ledger entries for a Cosmos address.

- **ID**: `webapp-ledger-list-by-address`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `address` | string | Yes | bech32 | Cosmos address (e.g. `structs1...`) |
| `page` | integer | Yes | `\d+` | Page number |

---

## Response Shape

All ledger endpoints — catalog and bespoke — use the shared `{ "success", "errors", "data" }` envelope (see `protocols/webapp-api-protocol.md`):

- `/api/ledger/list/...` and `/api/ledger/player/{player_id}/page/{page}` → `data` is a **flat array** of ledger rows (page size 100; fetch the next page when `data.length === 100`).
- `/api/ledger/player/{player_id}/count` → `data` is a single object `{ "count": N }`.
- `/api/ledger/{tx_id}` → `data` is a single ledger row object (or `null`).

The `/list/` path prefix is required so the catalog routes don't shadow `GET /api/ledger/{tx_id}`.
