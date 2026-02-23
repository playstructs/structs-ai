# NATS Streaming Connection

**Version**: 1.0.0
**Category**: Authentication / Streaming
**Purpose**: Connection, subscription, message handling, and reconnection examples for NATS

---

## Overview

Structs uses NATS messaging (via GRASS) for real-time game state streaming. Clients can connect using the native NATS protocol or a WebSocket wrapper. This document covers connection setup, subject subscription, message processing, and reconnection handling with code examples in JavaScript and Python.

## Connect via NATS Protocol

Connect directly to the NATS server using the native protocol. Authentication is optional.

Connection URL: `nats://localhost:4222`

JavaScript:

```javascript
import { connect } from 'nats';

const nc = await connect({
  servers: ['nats://localhost:4222']
});
```

Python:

```python
import asyncio
from nats.aio.client import Client as NATS

nc = NATS()
await nc.connect('nats://localhost:4222')
```

After connecting, subscribe to the desired subjects for real-time updates.

## Connect via WebSocket

Connect using the WebSocket wrapper for browser-based clients.

Connection URL: `ws://localhost:1443`

```javascript
const ws = new WebSocket('ws://localhost:1443');

ws.onopen = () => {
  ws.send(JSON.stringify({
    action: 'subscribe',
    subjects: ['structs.player.1']
  }));
};
```

After the connection opens, send a subscribe message to begin receiving updates.

## Subscribe to Subjects

Subscribe to NATS subjects to receive real-time updates for specific entities.

Available subjects:
- `structs.player.1` -- Player-specific updates
- `structs.planet.1-1` -- Planet-specific updates
- `structs.global` -- Global game state updates

JavaScript:

```javascript
const playerSub = nc.subscribe('structs.player.1', {
  callback: (err, msg) => {
    if (err) {
      console.error('Error:', err);
      return;
    }
    const data = JSON.parse(msg.data.toString());
    handlePlayerUpdate(data);
  }
});
```

Python:

```python
async def player_handler(msg):
    data = json.loads(msg.data.decode())
    handle_player_update(data)

await nc.subscribe('structs.player.1', cb=player_handler)
```

## Handle NATS Messages

When a message arrives, it contains a subject and data payload. Process messages by parsing the data, validating the format, updating local game state, and then acting on the update.

Example message:

```json
{
  "subject": "structs.player.1",
  "data": {
    "id": "1",
    "primaryAddress": "structs1abc...",
    "playerId": "1",
    "updatedAt": "2025-01-XX 12:00:00"
  }
}
```

Message handling steps:
1. Parse message data from the raw payload
2. Validate the message format
3. Update local game state with the new data
4. Process the update (trigger any dependent logic)

JavaScript:

```javascript
function handlePlayerUpdate(data) {
  gameState.players[data.id] = data;
  processPlayerUpdate(data);
}
```

## Handle Reconnection

If the connection to NATS is lost, implement reconnection with exponential backoff and re-subscribe to all subjects after reconnecting.

JavaScript:

```javascript
nc.closed().then(() => {
  console.log('Connection closed, reconnecting...');

  setTimeout(async () => {
    nc = await connect({ servers: ['nats://localhost:4222'] });
    await resubscribeAll();
  }, 2000);
});
```

Reconnection procedure:
1. Detect the disconnection event
2. Wait for a reconnection delay (start with 2 seconds, increase with backoff)
3. Reconnect to the NATS server
4. Re-subscribe to all previously subscribed subjects
5. Resume message processing

## Cross-References

- Streaming protocol: [protocols/streaming.md](../../protocols/streaming.md)
- Event types: [api/streaming/event-types.md](../../api/streaming/event-types.md)
- Working API examples (streaming section): [examples/working-api-examples.md](../working-api-examples.md)
- Event schemas: [api/streaming/event-schemas.md](../../api/streaming/event-schemas.md)
