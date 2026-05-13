# Webapp Infusion API Endpoints

**Category**: webapp
**Entity**: Infusion
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/infusion/player/{player_id}` | Get infusions for player (full reactor-staking detail) | No |
| GET | `/api/infusion/list/all/page/{page}` | List every infusion on the chain | No |
| GET | `/api/infusion/list/destination/{destination_id}/page/{page}` | List infusions targeting a destination object (e.g. a reactor) | No |
| GET | `/api/infusion/list/address/{address}/page/{page}` | List infusions made by a Cosmos address | No |
| GET | `/api/infusion/list/player/{player_id}/page/{page}` | Lightweight paginated list of infusions made by a player | No |

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

`/api/infusion/player/{player_id}` includes reactor staking information:

```json
{
  "infusions": [
    {
      "destinationId": "3-1",
      "address": "cosmos1...",
      "fuel": "1000000",
      "power": "1000000",
      "staking": {
        "delegationStatus": "active",
        "validationDelegation": {
          "validator": "...",
          "amount": "..."
        }
      }
    }
  ]
}
```

The `/api/infusion/list/...` endpoints return the standard catalog envelope (see `protocols/webapp-api-protocol.md`).
