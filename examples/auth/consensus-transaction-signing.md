# Consensus Transaction Signing

**Version**: 1.0.0
**Category**: Authentication
**Purpose**: Examples for signing and submitting transactions to the consensus network

---

## Overview

Transactions in Structs follow the Cosmos SDK signing flow: retrieve account information (including the current sequence number), construct the transaction message, sign it with the account's private key using secp256k1, and submit the signed transaction to the consensus network. This document walks through each step with request/response examples.

## Step 1: Get Account Information

Before signing, retrieve the account's current sequence number. The sequence must match when the transaction is submitted.

Request:

```json
{
  "method": "GET",
  "url": "http://localhost:1317/cosmos/auth/v1beta1/accounts/structs1abc...",
  "headers": {
    "Accept": "application/json"
  }
}
```

Response:

```json
{
  "account": {
    "@type": "/cosmos.auth.v1beta1.BaseAccount",
    "address": "structs1abc...",
    "pub_key": {
      "@type": "/cosmos.crypto.secp256k1.PubKey",
      "key": "base64_public_key"
    },
    "account_number": "0",
    "sequence": "5"
  }
}
```

After receiving the response, store the `account.sequence` value (in this case `"5"`). The sequence must match the current account sequence when the transaction is submitted.

## Step 2: Create Transaction

Construct the transaction message. This example builds a struct:

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgStructBuild",
        "creator": "structs1abc...",
        "structType": "1",
        "locationType": 1,
        "locationId": "1-1"
      }
    ],
    "memo": "",
    "timeout_height": "0"
  },
  "auth_info": {
    "signer_infos": [
      {
        "public_key": {
          "@type": "/cosmos.crypto.secp256k1.PubKey",
          "key": "base64_public_key"
        },
        "mode_info": {
          "single": {
            "mode": "SIGN_MODE_DIRECT"
          }
        },
        "sequence": "5"
      }
    ],
    "fee": {
      "amount": [],
      "gas_limit": "200000",
      "payer": "",
      "granter": ""
    }
  }
}
```

The `sequence` in `signer_infos` must match the value retrieved in Step 1.

## Step 3: Sign Transaction

Sign the transaction body with the account's private key using secp256k1.

| Field | Value |
|-------|-------|
| Signing method | secp256k1 |
| Private key | Account's private key (`0x...`) |
| Input | Serialized transaction bytes |
| Output | Base64-encoded signature |

The signed transaction includes the original body, auth_info, and the signature:

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgStructBuild",
        "creator": "structs1abc...",
        "structType": "1",
        "locationType": 1,
        "locationId": "1-1"
      }
    ],
    "memo": ""
  },
  "auth_info": {
    "signer_infos": [
      {
        "public_key": {
          "@type": "/cosmos.crypto.secp256k1.PubKey",
          "key": "base64_public_key"
        },
        "mode_info": {
          "single": {
            "mode": "SIGN_MODE_DIRECT"
          }
        },
        "sequence": "5"
      }
    ],
    "fee": {
      "amount": [],
      "gas_limit": "200000"
    }
  },
  "signatures": [
    "base64_signature"
  ]
}
```

## Step 4: Submit Transaction

Submit the signed transaction to the consensus network.

Request:

```json
{
  "method": "POST",
  "url": "http://localhost:1317/cosmos/tx/v1beta1/txs",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": {
    "tx_bytes": "base64_encoded_signed_transaction",
    "mode": "BROADCAST_MODE_SYNC"
  }
}
```

Response (success):

```json
{
  "tx_response": {
    "code": 0,
    "txhash": "ABC123...",
    "height": 12345,
    "gas_used": "150000",
    "gas_wanted": "200000"
  }
}
```

### Response Handling

**Code 0**: Transaction accepted successfully. The `txhash` can be used to look up the transaction later. Note that a successful broadcast does not guarantee the action succeeded -- always verify game state afterward.

**Non-zero code**: Transaction failed. Check `tx_response.code` and `tx_response.raw_log` for error details.

## Handling Sequence Errors

If the transaction is rejected due to an incorrect sequence number, the response will look like:

Request (same as Step 4).

Response:

```json
{
  "tx_response": {
    "code": 4,
    "txhash": "ABC123...",
    "raw_log": "sequence mismatch: expected 5, got 4"
  }
}
```

Recovery procedure:
1. Query the account again to get the current sequence number
2. Update the sequence in the transaction
3. Re-sign the transaction with the corrected sequence
4. Resubmit the transaction

Sequence mismatches typically occur when multiple transactions are submitted concurrently or when a previous transaction was submitted but the local sequence counter was not updated.

## Cross-References

- API quick reference: [reference/api-quick-reference.md](../../reference/api-quick-reference.md)
- Action protocol: [protocols/action-protocol.md](../../protocols/action-protocol.md)
- Permission examples: [examples/auth/permission-examples.md](permission-examples.md)
- Error handling: [protocols/error-handling.md](../../protocols/error-handling.md)
- Security patterns: [patterns/security.md](../../patterns/security.md)
