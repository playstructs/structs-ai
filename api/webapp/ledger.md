# Webapp Ledger API Endpoints

**Version**: 1.1.0
**Category**: webapp
**Entity**: Ledger
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`)
**Last Updated**: January 1, 2026

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/ledger/player/{player_id}/page/{page}` | Get ledger page for player | No |
| GET | `/api/ledger/player/{player_id}/count` | Get ledger count for player | No |
| GET | `/api/ledger/{tx_id}` | Get ledger entry by transaction ID | No |

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

*Last Updated: January 1, 2026*
