# Address Query Endpoints

**Version**: 1.0.0
**Category**: Query
**Entity**: Address
**Base URL**: `http://localhost:1317`
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
