# Submit Transaction

**Version**: 1.0.0
**Last Updated**: 2025-01-XX
**Base URL**: `http://localhost:1317`
**Base Path**: `/cosmos/tx/v1beta1`
**Category**: transaction

---

## Endpoint

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| POST | `/cosmos/tx/v1beta1/txs` | Submit transaction to blockchain | Required |

All game actions are submitted through this endpoint. See `schemas/actions.md` for message types.

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| body | object | Yes | Transaction body with messages |

**Request schema**: `schemas/requests.md#Transaction`
**Response schema**: `schemas/responses.md#TransactionResponse`
**Content-Type**: `application/json`

---

## Example

### Request

```json
// POST /cosmos/tx/v1beta1/txs
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgStructBuild",
        "creator": "structs1...",
        "structType": "1",
        "locationType": 1,
        "locationId": "2-1"
      }
    ]
  }
}
```

### Response

```json
{
  "tx_response": {
    "code": 0,
    "txhash": "...",
    "height": 12345
  }
}
```

A `code` of `0` indicates success. Non-zero codes indicate errors -- see `api/error-codes.md` for the complete error catalog.

---

## Related Documentation

- `schemas/actions.md` - Action/message type definitions
- `schemas/requests.md` - Request schema definitions
- `schemas/responses.md` - Response schema definitions
- `api/error-codes.md` - Error code catalog
- `protocols/action-protocol.md` - Action protocol guide
- `reference/action-quick-reference.md` - Action quick reference
- `api/transactions/README.md` - Transaction overview
