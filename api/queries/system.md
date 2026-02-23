# System Query Endpoints

**Version**: 1.0.0
**Category**: Query
**Entity**: System
**Base URL**: `http://localhost:1317`
**Base Path**: `/structs`

---

## Endpoint Summary

| Method | Path | Description | Auth | Paginated |
|--------|------|-------------|------|-----------|
| GET | `/blockheight` | Get current block height | No | No |
| GET | `/structs/params` | Get module parameters | No | No |

---

## Endpoint Details

### Get Current Block Height

`GET /blockheight`

Returns the current block height of the blockchain.

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities.md#BlockHeight`

#### Example

**Request**: `GET /blockheight`

**Response**:

```json
{
  "height": 12345
}
```

---

### Get Module Parameters

`GET /structs/params`

Returns the current module parameters for the Structs module.

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities.md#Params`
