---
description: "Query energy providers on the consensus network: what they sell, at what price, and the agreements they have open."
---

# Provider Query Endpoints

**Version**: 1.0.0
**Category**: Query
**Entity**: Provider
**Base URL**: `http://localhost:1317`
**Base Path**: `/structs`

---

## Endpoint Summary

| Method | Path | Description | Auth | Paginated |
|--------|------|-------------|------|-----------|
| GET | `/structs/provider/{id}` | Get provider by ID | No | No |
| GET | `/structs/provider` | List all providers | No | Yes |
| GET | `/structs/provider_collateral_address/{providerId}` | Collateral module account | No | No |
| GET | `/structs/provider_collateral_address` | List collateral addresses | No | Yes |
| GET | `/structs/provider_earnings_address/{providerId}` | Earnings module account | No | No |
| GET | `/structs/provider_earnings_address` | List earnings addresses | No | Yes |

---

## Endpoint Details

### Get Provider by ID

`GET /structs/provider/{id}`

Returns a single provider by its ID.

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `id` | string | Yes | provider-id | Provider identifier |

#### Response

- **Content-Type**: `application/json`
- **Schema**: [provider](../../schemas/entities/provider.md)

---

### List All Providers

`GET /structs/provider`

Returns a paginated list of all providers.

#### Response

- **Content-Type**: `application/json`
- **Schema**: [provider](../../schemas/entities/provider.md) (array)

---

### Provider Collateral and Earnings Addresses

`GET /structs/provider_collateral_address/{providerId}` · `GET /structs/provider_collateral_address`

`GET /structs/provider_earnings_address/{providerId}` · `GET /structs/provider_earnings_address`

Module accounts for provider collateral and earnings pools. **CLI**: `provider-collateral-address`, `provider-collateral-address-all`, `provider-earnings-address`, `provider-earnings-address-all`. Reverse lookup RPCs are commented out in proto.
