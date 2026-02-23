# Authentication Protocol

**Version**: 1.0.0  
**Category**: Authentication  
**Status**: Stable

---

## Overview

The Authentication Protocol defines how AI agents should authenticate and authorize when interacting with Structs APIs. This includes session-based authentication for the web application, transaction signing for the consensus network, and NATS authentication for streaming.

**Key Principles**:
1. **Use appropriate authentication** for each API type
2. **Maintain session state** for webapp API
3. **Sign transactions securely** for consensus API
4. **Handle authentication errors** gracefully
5. **Re-authenticate** when sessions expire

---

## Authentication Types

### 1. Web Application Authentication (Session-Based)

**Use Case**: Authenticating with `structs-webapp` API

**Implementation**: PHP Symfony application (`structs-webapp`)

**Method**: Session-based authentication using cookies

**Base URL**: `http://localhost:8080`  
**Base Path**: `/api/auth`

**Note**: The API built into `structs-webapp` is the main user-facing API. Authentication is implemented in the PHP Symfony application.

---

### 2. Consensus Network Authentication (Transaction Signing)

**Use Case**: Submitting transactions to `structsd`

**Method**: Transaction signing using private keys

**Base URL**: `http://localhost:1317`  
**Transaction Endpoint**: `/cosmos/tx/v1beta1/txs`

---

### 3. Streaming Authentication (NATS)

**Use Case**: Connecting to GRASS streaming service

**Method**: Optional NATS authentication

**NATS Protocol**: `nats://localhost:4222`  
**NATS WebSocket**: `ws://localhost:1443`

---

## Web Application Authentication

### Login Flow

**Step 1: Login Request**

```json
{
  "request": {
    "method": "POST",
    "url": "http://localhost:8080/api/auth/login",
    "headers": {
      "Content-Type": "application/json"
    },
    "body": {
      "username": "player_username",
      "password": "player_password"
    }
  }
}
```

**Step 2: Login Response**

```json
{
  "response": {
    "status": 200,
    "headers": {
      "Set-Cookie": "PHPSESSID=abc123def456; Path=/; HttpOnly"
    },
    "body": {
      "success": true,
      "message": "Login successful"
    }
  }
}
```

**Step 3: Using Session Cookie**

```json
{
  "request": {
    "method": "GET",
    "url": "http://localhost:8080/api/guild/this",
    "headers": {
      "Cookie": "PHPSESSID=abc123def456",
      "Accept": "application/json"
    }
  }
}
```

### Complete Login Example

```json
{
  "flow": "webapp-login",
  "steps": [
    {
      "step": 1,
      "action": "login",
      "request": {
        "method": "POST",
        "url": "/api/auth/login",
        "body": {
          "username": "player_username",
          "password": "player_password"
        }
      },
      "response": {
        "status": 200,
        "cookie": "PHPSESSID=abc123def456"
      },
      "store": "session.cookie"
    },
    {
      "step": 2,
      "action": "authenticated-request",
      "request": {
        "method": "GET",
        "url": "/api/guild/this",
        "headers": {
          "Cookie": "{{session.cookie}}"
        }
      }
    }
  ]
}
```

### Signup Flow

**Request**:
```json
{
  "request": {
    "method": "POST",
    "url": "http://localhost:8080/api/auth/signup",
    "headers": {
      "Content-Type": "application/json"
    },
    "body": {
      "username": "new_player",
      "password": "secure_password",
      "email": "player@example.com"
    }
  }
}
```

**Response**:
```json
{
  "response": {
    "status": 200,
    "body": {
      "success": true,
      "message": "Account created successfully"
    }
  }
}
```

### Logout Flow

**Request**:
```json
{
  "request": {
    "method": "GET",
    "url": "http://localhost:8080/api/auth/logout",
    "headers": {
      "Cookie": "PHPSESSID=abc123def456"
    }
  }
}
```

**Response**:
```json
{
  "response": {
    "status": 200,
    "body": {
      "success": true,
      "message": "Logged out successfully"
    }
  }
}
```

### Session Management

**Session Storage**:
```json
{
  "session": {
    "cookie": "PHPSESSID=abc123def456",
    "expires": "2025-12-07 12:00:00",
    "lastUsed": "2025-12-07 11:00:00"
  }
}
```

**Session Validation**:
- Check session expiration before making requests
- Re-authenticate if session expires
- Handle 401 Unauthorized responses

---

## Consensus Network Authentication

### Transaction Signing

**Overview**: Transactions must be signed with a private key before submission.

**Process**:
1. Create transaction message
2. Sign transaction with private key
3. Submit signed transaction

### Transaction Message Format

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
    "timeout_height": "0",
    "extension_options": [],
    "non_critical_extension_options": []
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
        "sequence": "0"
      }
    ],
    "fee": {
      "amount": [],
      "gas_limit": "200000",
      "payer": "",
      "granter": ""
    }
  },
  "signatures": [
    "base64_signature"
  ]
}
```

### Signing Process

**Step 1: Get Account Information**

```json
{
  "request": {
    "method": "GET",
    "url": "http://localhost:1317/cosmos/auth/v1beta1/accounts/structs1abc..."
  },
  "response": {
    "account": {
      "address": "structs1abc...",
      "pub_key": {...},
      "account_number": "0",
      "sequence": "0"
    }
  }
}
```

**Step 2: Create Transaction**

```json
{
  "transaction": {
    "body": {
      "messages": [...],
      "memo": ""
    },
    "auth_info": {
      "signer_infos": [...],
      "fee": {
        "amount": [],
        "gas_limit": "200000"
      }
    }
  }
}
```

**Step 3: Sign Transaction**

```json
{
  "signing": {
    "method": "secp256k1",
    "privateKey": "0x...",
    "message": "transaction_bytes",
    "result": "base64_signature"
  }
}
```

**Step 4: Submit Transaction**

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
  }
}
```

### Using Client Libraries

**TypeScript (structs-client-ts)**:
```typescript
// Initialize client with signer
import { Client } from 'structs-client-ts';
import { Env } from 'structs-client-ts/env';
import { OfflineSigner } from '@cosmjs/proto-signing';

const env = new Env({
  rpcURL: 'http://localhost:26657',
  apiURL: 'http://localhost:1317',
  prefix: 'structs'
});

const signer: OfflineSigner = /* get signer from Keplr or other wallet */;

const client = new Client(env, signer);

// Sign and broadcast transaction
const msg = {
  typeUrl: '/structs.structs.MsgStructBuild',
  value: {
    creator: 'structs1abc...',
    structType: '1',
    locationType: 1,
    locationId: '1-1'
  }
};

const result = await client.signAndBroadcast([msg], {
  amount: [],
  gas: '200000'
}, '');
```

**Python**:
```python
from cosmpy.aerial.client import LedgerClient
from cosmpy.aerial.wallet import LocalWallet
from cosmpy.crypto.keypairs import PrivateKey

# Initialize wallet
private_key = PrivateKey.from_hex("...")
wallet = LocalWallet(private_key)

# Initialize client
client = LedgerClient("http://localhost:1317")

# Create and sign transaction
tx = client.execute_tx(
    msgs=[msg],
    sender=wallet,
    gas_limit=200000
)
```

---

## Streaming Authentication (NATS)

### NATS Connection

**NATS Protocol**:
```json
{
  "connection": {
    "url": "nats://localhost:4222",
    "protocol": "NATS",
    "authentication": "optional"
  }
}
```

**NATS WebSocket**:
```json
{
  "connection": {
    "url": "ws://localhost:1443",
    "protocol": "NATS",
    "transport": "WebSocket",
    "authentication": "optional"
  }
}
```

### Authentication (If Required)

**Token Authentication**:
```json
{
  "connection": {
    "url": "nats://localhost:4222",
    "authentication": {
      "type": "token",
      "token": "nats_token_here"
    }
  }
}
```

**Username/Password Authentication**:
```json
{
  "connection": {
    "url": "nats://localhost:4222",
    "authentication": {
      "type": "username_password",
      "username": "nats_user",
      "password": "nats_password"
    }
  }
}
```

### Connection Example

**JavaScript/TypeScript**:
```typescript
import { connect } from 'nats';

// Connect to NATS
const nc = await connect({
  servers: ['nats://localhost:4222'],
  // Optional authentication
  // token: 'nats_token',
  // user: 'nats_user',
  // pass: 'nats_password'
});

// Subscribe to subjects
const sub = nc.subscribe('structs.player.1', (msg) => {
  console.log('Received:', msg.data);
});

// Keep connection alive
await nc.closed();
```

**Python**:
```python
import asyncio
from nats.aio.client import Client as NATS

async def main():
    nc = NATS()
    await nc.connect('nats://localhost:4222')
    
    # Optional authentication
    # await nc.connect('nats://localhost:4222', token='nats_token')
    
    async def message_handler(msg):
        print(f'Subject: {msg.subject}')
        print(f'Data: {msg.data.decode()}')
    
    await nc.subscribe('structs.player.1', cb=message_handler)
    
    # Keep connection alive
    await asyncio.sleep(3600)
    await nc.close()

asyncio.run(main())
```

---

## Error Handling

### Authentication Errors

**401 Unauthorized (Webapp)**:
```json
{
  "response": {
    "status": 401,
    "body": {
      "error": "Unauthorized",
      "message": "Authentication required"
    }
  },
  "action": "re-authenticate",
  "retry": true
}
```

**401 Unauthorized (Consensus)**:
```json
{
  "response": {
    "status": 401,
    "body": {
      "code": 4,
      "message": "unauthorized"
    }
  },
  "action": "check-signer",
  "retry": false
}
```

**403 Forbidden**:
```json
{
  "response": {
    "status": 403,
    "body": {
      "error": "Forbidden",
      "message": "Insufficient permissions"
    }
  },
  "action": "check-permissions",
  "retry": false
}
```

### Error Recovery

**Session Expired**:
```json
{
  "error": "session-expired",
  "recovery": {
    "step1": "detect-401-error",
    "step2": "clear-session",
    "step3": "re-authenticate",
    "step4": "retry-original-request"
  }
}
```

**Invalid Credentials**:
```json
{
  "error": "invalid-credentials",
  "recovery": {
    "step1": "log-error",
    "step2": "do-not-retry",
    "step3": "request-new-credentials"
  }
}
```

**Transaction Signing Failed**:
```json
{
  "error": "signing-failed",
  "recovery": {
    "step1": "check-private-key",
    "step2": "verify-account-sequence",
    "step3": "retry-with-correct-sequence"
  }
}
```

---

## Best Practices

### Security

1. **Never store credentials in code** - Use environment variables or secure storage
2. **Use HTTPS/WSS in production** - Never use HTTP/WS for authentication
3. **Rotate sessions regularly** - Re-authenticate periodically
4. **Validate certificates** - Verify SSL/TLS certificates
5. **Use secure key storage** - Store private keys securely

### Session Management

1. **Store session cookies securely** - Use secure storage
2. **Check session expiration** - Validate before requests
3. **Handle session expiration** - Re-authenticate automatically
4. **Logout on completion** - Clear sessions when done

### Transaction Signing

1. **Verify account sequence** - Check sequence before signing
2. **Handle nonce errors** - Retry with correct sequence
3. **Validate transaction format** - Verify message structure
4. **Check gas limits** - Ensure sufficient gas

### NATS Connection

1. **Handle connection errors** - Implement reconnection logic
2. **Validate subjects** - Verify subject patterns
3. **Handle message errors** - Process errors gracefully
4. **Monitor connection** - Track connection health

---

## Configuration

### Environment Variables

```json
{
  "webapp": {
    "baseUrl": "http://localhost:8080",
    "username": "${WEBAPP_USERNAME}",
    "password": "${WEBAPP_PASSWORD}"
  },
  "consensus": {
    "rpcURL": "http://localhost:26657",
    "apiURL": "http://localhost:1317",
    "privateKey": "${PRIVATE_KEY}",
    "address": "${ADDRESS}"
  },
  "streaming": {
    "natsURL": "nats://localhost:4222",
    "natsWebSocketURL": "ws://localhost:1443",
    "token": "${NATS_TOKEN}"
  }
}
```

### Network Configurations

**Testnet**:
```json
{
  "webapp": {
    "baseUrl": "https://testnet.structs.network"
  },
  "consensus": {
    "rpcURL": "https://rpc.testnet.structs.network:26657",
    "apiURL": "https://api.testnet.structs.network:1317"
  },
  "streaming": {
    "natsURL": "nats://testnet.structs.network:4222",
    "natsWebSocketURL": "wss://testnet.structs.network:1443"
  }
}
```

**Mainnet**:
```json
{
  "webapp": {
    "baseUrl": "https://structs.network"
  },
  "consensus": {
    "rpcURL": "https://rpc.structs.network:26657",
    "apiURL": "https://api.structs.network:1317"
  },
  "streaming": {
    "natsURL": "nats://structs.network:4222",
    "natsWebSocketURL": "wss://structs.network:1443"
  }
}
```

---

## Examples

### Complete Authentication Flow

```json
{
  "example": "complete-authentication-flow",
  "steps": [
    {
      "step": 1,
      "service": "webapp",
      "action": "login",
      "request": "POST /api/auth/login",
      "store": "session.cookie"
    },
    {
      "step": 2,
      "service": "webapp",
      "action": "authenticated-request",
      "request": "GET /api/guild/this",
      "headers": {
        "Cookie": "{{session.cookie}}"
      }
    },
    {
      "step": 3,
      "service": "consensus",
      "action": "sign-transaction",
      "message": "MsgStructBuild",
      "signer": "private_key"
    },
    {
      "step": 4,
      "service": "consensus",
      "action": "submit-transaction",
      "request": "POST /cosmos/tx/v1beta1/txs"
    },
    {
      "step": 5,
      "service": "streaming",
      "action": "connect-nats",
      "url": "nats://localhost:4222"
    },
    {
      "step": 6,
      "service": "streaming",
      "action": "subscribe",
      "subject": "structs.player.1"
    }
  ]
}
```

---

*Last Updated: December 7, 2025*

