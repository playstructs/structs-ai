---
description: "Query system-level state on the consensus network: chain parameters, guild charter puzzle, and signature validation."
---

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
| GET | `/structs/structs/params` | Get module parameters | No | No |
| GET | `/structs/structs/guild_charter` | Guild charter puzzle | No | No |
| GET | `/structs/validate_signature/{address}/{proofPubKey}/{proofSignature}/{message}` | Validate a signature | No | No |

---

## Endpoint Details

### Get Current Block Height

`GET /blockheight`

Returns the current block height of the blockchain.

#### Response

- **Content-Type**: `application/json`
- **Schema**: [BlockHeight](../../schemas/entities.md)

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

`GET /structs/structs/params`

Returns the current module parameters for the Structs module.

#### Response

- **Content-Type**: `application/json`
- **Schema**: [Params](../../schemas/entities.md)

---

### Guild Charter

`GET /structs/structs/guild_charter`

Global charter puzzle: current **anchor** and difficulty. **CLI**: `guild-charter`. See [hashing.md — Guild Charter](../../knowledge/mechanics/hashing.md#guild-charter).

### Validate Signature

`GET /structs/validate_signature/{address}/{proofPubKey}/{proofSignature}/{message}`

**CLI**: `validate-signature`. Used by guild proxy signup verification, not gameplay.
