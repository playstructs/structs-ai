# Action Protocol

**Version**: 1.0.0  
**Category**: Action  
**Status**: Stable

## Overview

The Action Protocol defines how AI agents should perform actions (transactions) in Structs. All actions are submitted as transactions to the consensus network.

## Base Configuration

```json
{
  "baseUrl": "http://localhost:1317",
  "transactionEndpoint": "/cosmos/tx/v1beta1/txs",
  "timeout": 30000,
  "confirmationTimeout": 60000,
  "retryPolicy": {
    "maxRetries": 3,
    "retryDelay": 2000,
    "retryOn": ["timeout", "5xx", "network"]
  }
}
```

## Transaction Flow

### Step 1: Get Account Information

**Format**: Query account to get account_number and sequence

```json
{
  "request": {
    "method": "GET",
    "url": "http://localhost:1317/cosmos/auth/v1beta1/accounts/{address}",
    "headers": {
      "Accept": "application/json"
    }
  },
  "response": {
    "status": 200,
    "body": {
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
  }
}
```

**Extract**: Store `account_number` and `sequence` for transaction signing.

### Step 2: Build Transaction

**Format**: Create transaction body with message(s) and auth_info

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

**Multiple Messages**: Can include multiple messages in one transaction

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
      },
      {
        "@type": "/structs.structs.MsgReactorInfuse",
        "creator": "structs1abc...",
        "reactorId": "3-1",
        "allocation": "..."
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
      "gas_limit": "200000"
    }
  }
}
```

### Step 3: Sign Transaction

**Format**: Sign transaction bytes with player's private key using secp256k1

```json
{
  "signing": {
    "method": "secp256k1",
    "privateKey": "0x...",
    "message": "transaction_bytes",
    "chainId": "structs-testnet",
    "accountNumber": "0",
    "sequence": "5",
    "result": "base64_signature"
  },
  "signedTransaction": {
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
}
```

**Note**: The transaction must be serialized to bytes before signing. The signature is then added to the `signatures` array.

### Step 4: Submit Transaction

**Format**: POST signed transaction (base64-encoded) to endpoint

```json
{
  "request": {
    "method": "POST",
    "url": "http://localhost:1317/cosmos/tx/v1beta1/txs",
    "headers": {
      "Content-Type": "application/json"
    },
    "body": {
      "tx_bytes": "base64_encoded_signed_transaction",
      "mode": "BROADCAST_MODE_SYNC"
    }
  },
  "response": {
    "status": 200,
    "body": {
      "tx_response": {
        "code": 0,
        "txhash": "ABC123...",
        "height": 12345,
        "gas_used": "150000",
        "gas_wanted": "200000"
      }
    }
  }
}
```

**Note**: `tx_bytes` must be the complete signed transaction serialized and base64-encoded.

**Broadcast Modes**:
- `BROADCAST_MODE_SYNC`: Wait for CheckTx (fast, no confirmation)
- `BROADCAST_MODE_ASYNC`: Don't wait (fastest, no confirmation)
- `BROADCAST_MODE_BLOCK`: Wait for block inclusion (slowest, confirmed)

### Step 5: Wait for Confirmation

**Format**: Poll transaction status using txhash

```json
{
  "poll": {
    "endpoint": "GET http://localhost:1317/cosmos/tx/v1beta1/txs/{txhash}",
    "interval": 1000,
    "maxAttempts": 60,
    "successCondition": "tx_response.code == 0",
    "failureCondition": "tx_response.code != 0"
  },
  "response": {
    "status": 200,
    "body": {
      "tx_response": {
        "code": 0,
        "txhash": "ABC123...",
        "height": 12345,
        "gas_used": "150000",
        "gas_wanted": "200000"
      }
    }
  }
}
```

**Sequence Error Handling**: If transaction fails with sequence mismatch:

```json
{
  "error": {
    "code": 4,
    "raw_log": "sequence mismatch: expected 5, got 4"
  },
  "recovery": {
    "action": "Get current account sequence",
    "steps": [
      "1. Query account again: GET /cosmos/auth/v1beta1/accounts/{address}",
      "2. Update sequence in transaction",
      "3. Re-sign transaction",
      "4. Resubmit transaction"
    ]
  }
}
```

### Step 6: Handle Result

**Success Response** (code: 0):
```json
{
  "tx_response": {
    "code": 0,
    "txhash": "ABC123...",
    "height": 12345,
    "gas_used": "150000",
    "gas_wanted": "200000"
  },
  "handling": {
    "action": "Transaction accepted",
    "next": "Monitor for block inclusion if using BROADCAST_MODE_SYNC"
  }
}
```

**Error Response** (code != 0):
```json
{
  "tx_response": {
    "code": 1,
    "codespace": "sdk",
    "raw_log": "insufficient funds: insufficient account funds",
    "txhash": "ABC123..."
  },
  "handling": {
    "action": "Check tx_response.code and raw_log for error details",
    "recovery": "Address insufficient funds issue before retrying"
  }
}
```

**Related Examples**: See `ai/examples/auth/consensus-transaction-signing.md` for complete working examples.

## Action Patterns

### Pattern 1: Simple Action

**Use Case**: Single action, no dependencies

```json
{
  "action": "MsgStructBuild",
  "steps": [
    "1. Build transaction",
    "2. Sign transaction",
    "3. Submit transaction",
    "4. Wait for confirmation",
    "5. Handle result"
  ]
}
```

### Pattern 2: Action with Follow-Up

**Use Case**: Action requires follow-up action

```json
{
  "action": "MsgStructBuild",
  "followUp": {
    "action": "MsgStructBuildComplete",
    "waitFor": "struct in building state",
    "requires": ["proof-of-work"]
  }
}
```

**Example Flow**:
1. Submit `MsgStructBuild`
2. Wait for confirmation
3. Query struct state (wait for building state)
4. Compute proof-of-work
5. Submit `MsgStructBuildComplete`

### Pattern 3: Conditional Action

**Use Case**: Action depends on game state

```json
{
  "action": "MsgStructAttack",
  "preconditions": [
    {
      "check": "GET /structs/struct/{structId}",
      "condition": "struct.operatingAmbit >= distance to target",
      "ifFalse": "abort"
    },
    {
      "check": "GET /structs/player/{playerId}",
      "condition": "player.halted == false",
      "ifFalse": "abort"
    }
  ],
  "then": "submit action"
}
```

### Pattern 4: Batch Actions

**Use Case**: Multiple related actions

```json
{
  "actions": [
    {
      "@type": "/structs.structs.MsgStructBuild",
      ...
    },
    {
      "@type": "/structs.structs.MsgReactorInfuse",
      "structs:deprecated": "MsgReactorAllocate (deprecated - use MsgReactorInfuse)",
      ...
    }
  ],
  "submit": "single transaction"
}
```

## Action Requirements

### Common Requirements

```json
{
  "requirements": {
    "playerOnline": {
      "check": "GET /structs/player/{playerId}",
      "condition": "player.halted == false",
      "error": "PLAYER_HALTED"
    },
    "sufficientResources": {
      "check": "GET /structs/player/{playerId}",
      "condition": "player.playerInventory.resources >= required",
      "error": "INSUFFICIENT_RESOURCES"
    },
    "sufficientCharge": {
      "check": "GET /structs/struct/{structId}",
      "condition": "struct.charge >= required",
      "error": "INSUFFICIENT_CHARGE"
    },
    "validLocation": {
      "check": "GET /structs/planet/{planetId}",
      "condition": "planet exists and accessible",
      "error": "INVALID_LOCATION"
    }
  }
}
```

### Proof-of-Work Requirements

**Actions Requiring Proof-of-Work**:
- `MsgStructBuildComplete`
- `MsgPlanetRaidComplete`

**Proof-of-Work Process**:
```json
{
  "proofOfWork": {
    "difficulty": "from struct type or planet",
    "compute": {
      "algorithm": "hash",
      "input": "structId + nonce",
      "target": "difficulty threshold"
    },
    "submit": {
      "hash": "computed hash",
      "nonce": "nonce that produces hash"
    }
  }
}
```

## Error Handling

### Transaction Errors

```json
{
  "errorCodes": {
    "0": "SUCCESS",
    "1": "GENERAL_ERROR",
    "2": "INSUFFICIENT_FUNDS",
    "3": "INVALID_SIGNATURE",
    "4": "INSUFFICIENT_GAS",
    "5": "INVALID_MESSAGE",
    "6": "PLAYER_HALTED",
    "7": "INSUFFICIENT_CHARGE",
    "8": "INVALID_LOCATION",
    "9": "INVALID_TARGET"
  }
}
```

### Error Handling Strategy

```json
{
  "onError": {
    "INSUFFICIENT_FUNDS": {
      "action": "log",
      "retry": false,
      "fallback": "wait for resources"
    },
    "PLAYER_HALTED": {
      "action": "log",
      "retry": false,
      "fallback": "wait for player online"
    },
    "INSUFFICIENT_CHARGE": {
      "action": "log",
      "retry": false,
      "fallback": "wait for charge"
    },
    "NETWORK_ERROR": {
      "action": "retry",
      "maxRetries": 3,
      "backoff": "exponential"
    }
  }
}
```

## Best Practices

1. **Check Preconditions**: Always check requirements before submitting
2. **Handle Errors**: Always handle transaction errors
3. **Wait for Confirmation**: Wait for confirmation before considering action complete
4. **Use Appropriate Broadcast Mode**: Use SYNC for most cases, BLOCK for critical actions
5. **Batch When Possible**: Batch related actions in single transaction
6. **Monitor Gas**: Monitor gas usage and adjust gas limits
7. **Handle Sequence**: Track and increment sequence numbers
8. **Proof-of-Work**: Compute proof-of-work efficiently

## Performance Optimization

### Optimization 1: Pre-compute Proof-of-Work

```json
{
  "strategy": "precompute",
  "when": "struct enters building state",
  "action": "start computing proof-of-work",
  "submit": "when ready"
}
```

### Optimization 2: Batch Actions

```json
{
  "strategy": "batch",
  "collect": "related actions",
  "submit": "single transaction",
  "benefit": "lower gas cost, atomic execution"
}
```

### Optimization 3: Async Submission

```json
{
  "strategy": "async",
  "submit": "BROADCAST_MODE_ASYNC",
  "poll": "separate thread",
  "benefit": "non-blocking"
}
```

---

*Last Updated: December 7, 2025*

