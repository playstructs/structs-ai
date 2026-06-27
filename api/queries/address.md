# Address Query Endpoints

**Version**: 1.0.0
**Category**: Query
**Entity**: Address
**Base URL**: local devnet `http://localhost:1317`; public testnet `https://public.testnet.structs.network` (HTTPS, no port — there is no `:1317` on the public host)
**Base Path**: `/structs`

---

## Endpoint Summary

| Method | Path | Description | Auth | Paginated |
|--------|------|-------------|------|-----------|
| GET | `/structs/address/{address}` | Get address by blockchain address | No | No |
| GET | `/structs/address` | List all addresses | No | Yes |
| GET | `/structs/address_by_player/{playerId}` | Get addresses by player | No | No |

---

## Endpoint Details

### Get Address by Blockchain Address

`GET /structs/address/{address}`

Returns address information for a specific blockchain address.

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `address` | string | Yes | blockchain-address | Blockchain address |

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities.md#Address`

The response is a **flat** object with `playerId` at the top level (camelCase) — not nested under an `Address` wrapper. `permissions` is a `uint64` and is serialized as a **string** in proto JSON:

```json
{
  "address": "structs1...",
  "playerId": "1-11",
  "permissions": "1"
}
```

(Verified in `proto/structs/structs/query.proto` `QueryAddressResponse`.) A common polling bug is looking for the player id under a nested `Address` key; it is top-level `playerId`.

---

### List All Addresses

`GET /structs/address`

Returns a paginated list of all addresses.

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities.md#Address` (array)

---

### Get Addresses by Player

`GET /structs/address_by_player/{playerId}`

Returns all addresses associated with a specific player.

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `playerId` | string | Yes | entity-id (`^1-[0-9]+$`) | Player identifier in format 'type-index' (e.g., '1-11' for player type 1, index 11). Type 1 = Player. |

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities.md#Address` (array)
