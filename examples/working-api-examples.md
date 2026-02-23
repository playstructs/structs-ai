# Working API Examples

**Version**: 1.0.0
**Verified**: All examples verified against actual code repositories and live deployments

---

## Overview

These are working API examples for all Structs APIs: the consensus network API, the web application API, the RPC API, NATS streaming, and client libraries in TypeScript and Python. Each example has been verified against real deployments.

## Consensus Network API

Base URL: `http://localhost:1317`
Base path: `/structs`

### Query Player (Direct HTTP)

```json
{
  "method": "GET",
  "url": "http://localhost:1317/structs/player/1-1",
  "headers": {
    "Accept": "application/json"
  }
}
```

Response:

```json
{
  "player": {
    "id": "1-1",
    "primaryAddress": "structs1...",
    "playerId": "1-1"
  },
  "gridAttributes": {},
  "playerInventory": {},
  "halted": false
}
```

### Query Player (curl)

```bash
curl -s http://localhost:1317/structs/player/1-1 | jq
```

### Query Planets by Player

```json
{
  "method": "GET",
  "url": "http://localhost:1317/structs/planet_by_player/1-1",
  "headers": {
    "Accept": "application/json"
  }
}
```

Response:

```json
{
  "planet": [
    {
      "id": "1-1",
      "ownerId": "1-1"
    }
  ]
}
```

### Query Block Height

```json
{
  "method": "GET",
  "url": "http://localhost:1317/blockheight",
  "headers": {
    "Accept": "application/json"
  }
}
```

Response:

```json
{
  "height": 12345
}
```

### List Players (Paginated)

```json
{
  "method": "GET",
  "url": "http://localhost:1317/structs/player?pagination.key=&pagination.limit=100",
  "headers": {
    "Accept": "application/json"
  }
}
```

Response:

```json
{
  "player": [],
  "pagination": {
    "next_key": null,
    "total": "0"
  }
}
```

## Web Application API

Base URL: `http://localhost:8080`
Base path: `/api`

### Query Player (Webapp)

```json
{
  "method": "GET",
  "url": "http://localhost:8080/api/player/1-1",
  "headers": {
    "Accept": "application/json"
  }
}
```

### Query Guild (Webapp)

```json
{
  "method": "GET",
  "url": "http://localhost:8080/api/guild/0-1",
  "headers": {
    "Accept": "application/json"
  }
}
```

### Query Planet Shield Health

```json
{
  "method": "GET",
  "url": "http://localhost:8080/api/planet/1-1/shield/health",
  "headers": {
    "Accept": "application/json"
  }
}
```

### Login (Webapp)

```json
{
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
```

Response:

```json
{
  "status": 200,
  "headers": {
    "Set-Cookie": "PHPSESSID=..."
  },
  "body": {
    "success": true
  }
}
```

## RPC API

Base URL: `http://localhost:26657`

### RPC Status

```json
{
  "method": "GET",
  "url": "http://localhost:26657/status",
  "headers": {
    "Accept": "application/json"
  }
}
```

Response:

```json
{
  "jsonrpc": "2.0",
  "id": -1,
  "result": {
    "node_info": {},
    "sync_info": {},
    "validator_info": {}
  }
}
```

### RPC Block by Height

```json
{
  "method": "GET",
  "url": "http://localhost:26657/block?height=12345",
  "headers": {
    "Accept": "application/json"
  }
}
```

## Streaming (NATS)

GRASS uses NATS messaging for real-time streaming. Connect via native NATS protocol or WebSocket wrapper.

### Connect via NATS Protocol

Connection URL: `nats://localhost:4222`

Subscribe to player updates on subject `structs.player.1`.

### Connect via WebSocket

Connection URL: `ws://localhost:1443`

```javascript
const ws = new WebSocket('ws://localhost:1443');

ws.send(JSON.stringify({
  action: 'subscribe',
  subjects: ['structs.player.1', 'structs.planet.1-1']
}));

ws.onmessage = (event) => {
  const message = JSON.parse(event.data);
  console.log('Subject:', message.subject);
  console.log('Data:', message.data);
};
```

### NATS Subject Patterns

| Pattern | Description | Example |
|---------|-------------|---------|
| `structs.player.*` | Player-specific updates | `structs.player.1` |
| `structs.planet.*` | Planet-specific updates | `structs.planet.1-1` |
| `structs.guild.*` | Guild-specific updates | `structs.guild.1` |
| `structs.struct.*` | Struct-specific updates | `structs.struct.1` |
| `structs.fleet.*` | Fleet-specific updates | `structs.fleet.1` |
| `structs.global` | Global game state updates | N/A |

## TypeScript Client

Package: `structs-client-ts` (Ignite-generated). May not be published to npm -- install from source.

### Initialize Client

```typescript
import { Client } from 'structs-client-ts';
import { Env } from 'structs-client-ts/env';

const env = new Env({
  rpcURL: 'https://rpc.structs.network:26657',
  apiURL: 'https://api.structs.network:1317',
  prefix: 'structs'
});

const client = await Client.connect(env);
```

### Query Player (TypeScript)

```typescript
const playerResponse = await client.StructsStructs.query.queryPlayer({
  id: '1'
});

console.log('Player:', playerResponse.data.player);
```

### Query Planet (TypeScript)

```typescript
const planetResponse = await client.StructsStructs.query.queryPlanet({
  id: '1-1'
});

console.log('Planet:', planetResponse.data.planet);
```

### Direct HTTP (Recommended)

For more reliable operation, use direct HTTP requests instead of the client library:

```typescript
const response = await fetch('http://localhost:1317/structs/player/1-1');
const data = await response.json();

console.log('Player:', data.player);
```

## Python Examples

### Query Player (Python)

```python
import requests

response = requests.get('http://localhost:1317/structs/player/1-1')
data = response.json()

print('Player:', data['player'])
```

### Query Block Height (Python)

```python
import requests

response = requests.get('http://localhost:1317/blockheight')
data = response.json()

print('Block Height:', data['height'])
```

### NATS Streaming (Python)

```python
import asyncio
from nats.aio.client import Client as NATS

async def main():
    nc = NATS()
    await nc.connect('nats://localhost:4222')

    async def message_handler(msg):
        print(f'Subject: {msg.subject}')
        print(f'Data: {msg.data.decode()}')

    await nc.subscribe('structs.player.1', cb=message_handler)

    await asyncio.sleep(3600)
    await nc.close()

asyncio.run(main())
```

## Common Patterns for AI Agents

### Incremental State Building

Build game state step by step:

1. Query block height: `GET /blockheight` -- store as `gameState.blockHeight`
2. Query all players (paginated): `GET /structs/player` -- store as `gameState.players`
3. For each player, query planets: `GET /structs/planet_by_player/{playerId}` -- store as `gameState.planets[playerId]`

### Error Handling Pattern

```typescript
async function queryWithRetry(url, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(url);
      if (response.ok) {
        return await response.json();
      }
      if (response.status === 404) {
        return null;
      }
      if (response.status >= 500 && i < maxRetries - 1) {
        await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
        continue;
      }
      throw new Error(`HTTP ${response.status}`);
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
    }
  }
}
```

### Caching Strategy

**Static data** (TTL: 3600s, safe to cache):
- `GET /structs/struct_type`
- `GET /api/struct/type`
- `GET /api/guild/directory`

**Dynamic data** (do not cache):
- `GET /blockheight`
- `GET /api/player/{player_id}/ore/stats`
- `GET /api/planet/{planet_id}/shield/health`

## Important Notes

- All consensus API endpoints use the `/structs/` prefix (not `/cosmos/game/v1beta1/`)
- All webapp API endpoints use the `/api/` prefix (not `/api/v1/`)
- GRASS uses NATS messaging (not direct WebSocket). Connect to `nats://localhost:4222` or `ws://localhost:1443`
- `structs-client-ts` is Ignite-generated and may not be published to npm. Use direct HTTP requests for reliability.

## Cross-References

- API quick reference: [reference/api-quick-reference.md](../reference/api-quick-reference.md)
- Streaming protocol: [protocols/streaming.md](../protocols/streaming.md)
- NATS connection examples: [examples/auth/nats-connection.md](auth/nats-connection.md)
- Caching patterns: [patterns/caching.md](../patterns/caching.md)
- Rate limiting: [patterns/rate-limiting.md](../patterns/rate-limiting.md)
