# Streaming Protocol

**Version**: 1.0.0  
**Category**: Streaming  
**Status**: Stable

---

## Overview

The Streaming Protocol defines how AI agents should connect to and consume real-time game state updates from GRASS (Game Real-time Analysis and Streaming Service) via NATS messaging.

**Key Principles**:
1. **GRASS uses NATS** - Not direct WebSocket connections
2. **PostgreSQL triggers events** - Database changes trigger NATS messages
3. **Subject-based subscriptions** - Subscribe to specific entity subjects
4. **Handle reconnections** - Implement robust reconnection logic
5. **Process messages efficiently** - Handle high message volumes

---

## Architecture

### How GRASS Works

```
PostgreSQL Database
    ↓ (NOTIFY events)
structs-grass Service
    ↓ (publishes to NATS)
NATS Server
    ↓ (subscribes)
AI Agent / Client
```

**Flow**:
1. PostgreSQL database changes trigger NOTIFY events on channel `'grass'`
2. `structs-grass` service listens to PostgreSQL NOTIFY channel
3. GRASS processes events and publishes to NATS subjects
4. Clients connect to NATS and subscribe to subjects
5. Clients receive real-time updates via NATS messages

---

## Connection Methods

### Method 1: NATS Protocol (Recommended)

**URL**: `nats://localhost:4222`  
**Protocol**: NATS  
**Use Case**: Server-side applications, high performance

**Connection**:
```json
{
  "connection": {
    "url": "nats://localhost:4222",
    "protocol": "NATS",
    "authentication": "optional"
  }
}
```

### Method 2: NATS WebSocket (Browser-Compatible)

**URL**: `ws://localhost:1443`  
**Protocol**: NATS over WebSocket  
**Use Case**: Browser applications, WebSocket compatibility

**Connection**:
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

---

## Subject Patterns

### Subject Structure

**Format**: `structs.{entity}.{id}`

**Examples**:
- `structs.player.0-1.1-11` - Player 1-11 in guild 0-1 updates (guild-scoped)
- `structs.planet.2-1` - Planet 2-1 updates
- `structs.guild.0-1` - Guild 0-1 updates
- `structs.struct.5-1` - Struct 5-1 updates
- `structs.fleet.9-1` - Fleet 9-1 updates
- `structs.global` - Global game state updates

### Available Subjects

**Player Subjects**:
- `structs.player.*` - All player updates (wildcard)
- `structs.player.{guildId}.{playerId}` - Specific player updates (guild-scoped, uses entity-id format)
- Example: `structs.player.0-1.1-11` - Player 1-11 in guild 0-1

**Planet Subjects**:
- `structs.planet.*` - All planet updates (wildcard)
- `structs.planet.{planetId}` - Specific planet updates (uses entity-id format)
- Example: `structs.planet.2-1` - Planet 2-1 (type 2, index 1)

**Guild Subjects**:
- `structs.guild.*` - All guild updates (wildcard)
- `structs.guild.{guildId}` - Specific guild updates (uses entity-id format)
- Example: `structs.guild.0-1` - Guild 0-1 (type 0, index 1)

**Struct Subjects**:
- `structs.struct.*` - All struct updates (wildcard)
- `structs.struct.{structId}` - Specific struct updates (uses entity-id format)
- Example: `structs.struct.5-1` - Struct 5-1 (type 5, index 1)

**Fleet Subjects**:
- `structs.fleet.*` - All fleet updates (wildcard)
- `structs.fleet.{fleetId}` - Specific fleet updates (uses entity-id format)
- Example: `structs.fleet.9-1` - Fleet 9-1 (type 9, index 1)

**Global Subjects**:
- `structs.global` - Global game state updates

---

## Connection Examples

### JavaScript/TypeScript (NATS Protocol)

```typescript
import { connect } from 'nats';

async function connectToGRASS() {
  // Connect to NATS
  const nc = await connect({
    servers: ['nats://localhost:4222']
  });

  // Subscribe to player updates
  const playerSub = nc.subscribe('structs.player.0-1.1-11', {
    callback: (err, msg) => {
      if (err) {
        console.error('Error:', err);
        return;
      }
      
      const data = JSON.parse(msg.data.toString());
      console.log('Player update:', data);
      
      // Process update
      handlePlayerUpdate(data);
    }
  });

  // Subscribe to planet updates
  const planetSub = nc.subscribe('structs.planet.2-1', {
    callback: (err, msg) => {
      if (err) {
        console.error('Error:', err);
        return;
      }
      
      const data = JSON.parse(msg.data.toString());
      console.log('Planet update:', data);
      
      // Process update
      handlePlanetUpdate(data);
    }
  });

  // Subscribe to global updates
  const globalSub = nc.subscribe('structs.global', {
    callback: (err, msg) => {
      if (err) {
        console.error('Error:', err);
        return;
      }
      
      const data = JSON.parse(msg.data.toString());
      console.log('Global update:', data);
      
      // Process update
      handleGlobalUpdate(data);
    }
  });

  // Keep connection alive
  console.log('Connected to GRASS. Listening for updates...');
  
  // Handle connection close
  nc.closed().then(() => {
    console.log('Connection closed');
  });
}

function handlePlayerUpdate(data: any) {
  // Update local game state
  gameState.players[data.id] = data;
}

function handlePlanetUpdate(data: any) {
  // Update local game state
  gameState.planets[data.id] = data;
}

function handleGlobalUpdate(data: any) {
  // Update global state
  gameState.global = data;
}

connectToGRASS();
```

### JavaScript/TypeScript (NATS WebSocket)

```typescript
// Using NATS WebSocket for browser compatibility
const ws = new WebSocket('ws://localhost:1443');

ws.onopen = () => {
  console.log('Connected to GRASS via WebSocket');
  
  // Subscribe to subjects
  ws.send(JSON.stringify({
    action: 'subscribe',
    subjects: [
      'structs.player.0-1.1-11',
      'structs.planet.2-1',
      'structs.global'
    ]
  }));
};

ws.onmessage = (event) => {
  const message = JSON.parse(event.data);
  
  if (message.subject) {
    console.log('Subject:', message.subject);
    console.log('Data:', message.data);
    
    // Process update based on subject
    switch (message.subject) {
      case 'structs.player.0-1.1-11':
        handlePlayerUpdate(message.data);
        break;
      case 'structs.planet.2-1':
        handlePlanetUpdate(message.data);
        break;
      case 'structs.global':
        handleGlobalUpdate(message.data);
        break;
    }
  }
};

ws.onerror = (error) => {
  console.error('WebSocket error:', error);
};

ws.onclose = () => {
  console.log('WebSocket closed');
  // Implement reconnection logic
};
```

### Python (NATS Protocol)

```python
import asyncio
from nats.aio.client import Client as NATS
import json

async def connect_to_grass():
    nc = NATS()
    
    # Connect to NATS
    await nc.connect('nats://localhost:4222')
    
    print('Connected to GRASS')
    
    # Subscribe to player updates
    async def player_handler(msg):
        data = json.loads(msg.data.decode())
        print(f'Player update: {data}')
        handle_player_update(data)
    
    await nc.subscribe('structs.player.0-1.1-11', cb=player_handler)
    
    # Subscribe to planet updates
    async def planet_handler(msg):
        data = json.loads(msg.data.decode())
        print(f'Planet update: {data}')
        handle_planet_update(data)
    
    await nc.subscribe('structs.planet.2-1', cb=planet_handler)
    
    # Subscribe to global updates
    async def global_handler(msg):
        data = json.loads(msg.data.decode())
        print(f'Global update: {data}')
        handle_global_update(data)
    
    await nc.subscribe('structs.global', cb=global_handler)
    
    # Keep connection alive
    try:
        await asyncio.sleep(3600)  # Run for 1 hour
    except KeyboardInterrupt:
        pass
    finally:
        await nc.close()

def handle_player_update(data):
    # Update local game state
    game_state['players'][data['id']] = data

def handle_planet_update(data):
    # Update local game state
    game_state['planets'][data['id']] = data

def handle_global_update(data):
    # Update global state
    game_state['global'] = data

# Run
asyncio.run(connect_to_grass())
```

---

## Message Format

### Message Structure

**NATS Message**:
```json
{
  "subject": "structs.player.0-1.1-11",
  "data": {
    "id": "1-11",
    "primaryAddress": "structs1abc...",
    "playerId": "1-11",
    "guildId": "0-1",
    "updatedAt": "2025-01-XX 12:00:00"
  }
}
```

### Entity Update Messages

**Player Update**:
```json
{
  "subject": "structs.player.0-1.1-11",
  "data": {
    "player": {
      "id": "1-11",
      "primaryAddress": "structs1abc...",
      "playerId": "1-11",
      "guildId": "0-1"
    },
    "event": "update",
    "timestamp": "2025-01-XX 12:00:00"
  }
}
```

**Planet Update**:
```json
{
  "subject": "structs.planet.2-1",
  "data": {
    "planet": {
      "id": "2-1",
      "ownerId": "1-11",
      "location": "2-1"
    },
    "event": "update",
    "timestamp": "2025-01-XX 12:00:00"
  }
}
```

**Planet Activity Event** (with struct_health):
```json
{
  "subject": "structs.planet.2-1",
  "category": "planet_activity",
  "id": "2-1",
  "updated_at": "2025-01-XX 12:00:00",
  "data": {
    "planetId": "2-1",
    "details": {
      "struct_health": {
        "structId": "5-42",
        "health": 100,
        "maxHealth": 100
      }
    }
  }
}
```

**Note**: Planet activity events are emitted by GRASS when entries are logged to the `planet_activity` table. The `details` field contains a JSONB object that may include `struct_health` information tracking struct health on the planet.

**Global Update**:
```json
{
  "subject": "structs.global",
  "data": {
    "blockHeight": 12345,
    "timestamp": "2025-01-XX 12:00:00",
    "events": [
      {
        "type": "block",
        "height": 12345
      }
    ]
  }
}
```

---

## Subscription Patterns

### Pattern 1: Single Entity Subscription

**Use Case**: Monitor a specific entity

```json
{
  "pattern": "single-entity",
  "subscription": {
    "subject": "structs.player.0-1.1-11",
    "description": "Monitor player 1-11 in guild 0-1"
  }
}
```

### Pattern 2: Multiple Entity Subscriptions

**Use Case**: Monitor multiple specific entities

```json
{
  "pattern": "multiple-entities",
  "subscriptions": [
    {
      "subject": "structs.player.0-1.1-11",
      "description": "Monitor player 1-11 in guild 0-1"
    },
    {
      "subject": "structs.planet.2-1",
      "description": "Monitor planet 2-1"
    },
    {
      "subject": "structs.guild.0-1",
      "description": "Monitor guild 0-1"
    }
  ]
}
```

### Pattern 3: Wildcard Subscription

**Use Case**: Monitor all entities of a type

```json
{
  "pattern": "wildcard",
  "subscription": {
    "subject": "structs.player.*",
    "description": "Monitor all players"
  }
}
```

### Pattern 4: Global Subscription

**Use Case**: Monitor global game state

```json
{
  "pattern": "global",
  "subscription": {
    "subject": "structs.global",
    "description": "Monitor global game state"
  }
}
```

---

## Error Handling

### Connection Errors

**Connection Failed**:
```json
{
  "error": "connection-failed",
  "recovery": {
    "step1": "wait",
    "step2": "retry-connection",
    "step3": "exponential-backoff"
  }
}
```

**Connection Lost**:
```json
{
  "error": "connection-lost",
  "recovery": {
    "step1": "detect-disconnect",
    "step2": "reconnect",
    "step3": "re-subscribe",
    "step4": "resume-processing"
  }
}
```

### Message Errors

**Invalid Message Format**:
```json
{
  "error": "invalid-message",
  "recovery": {
    "step1": "log-error",
    "step2": "skip-message",
    "step3": "continue-processing"
  }
}
```

**Message Processing Error**:
```json
{
  "error": "processing-error",
  "recovery": {
    "step1": "log-error",
    "step2": "handle-gracefully",
    "step3": "continue-processing"
  }
}
```

### Reconnection Strategy

```json
{
  "reconnection": {
    "maxRetries": 10,
    "initialDelay": 1000,
    "maxDelay": 30000,
    "backoff": "exponential",
    "onReconnect": [
      "re-subscribe-to-all-subjects",
      "resume-processing"
    ]
  }
}
```

---

## Best Practices

### Performance

1. **Batch Processing** - Process multiple messages in batches
2. **Async Processing** - Use async/await for non-blocking processing
3. **Message Queuing** - Queue messages if processing is slow
4. **Selective Subscriptions** - Only subscribe to needed subjects

### Reliability

1. **Handle Reconnections** - Implement robust reconnection logic
2. **Message Acknowledgment** - Acknowledge processed messages
3. **Error Logging** - Log all errors for debugging
4. **Health Monitoring** - Monitor connection health

### State Management

1. **Update Local State** - Keep local state synchronized
2. **Handle Conflicts** - Resolve state conflicts gracefully
3. **State Validation** - Validate state updates
4. **State Persistence** - Persist state for recovery

---

## Configuration

### Connection Configuration

```json
{
  "streaming": {
    "nats": {
      "url": "nats://localhost:4222",
      "reconnect": true,
      "maxReconnectAttempts": 10,
      "reconnectTimeWait": 2000
    },
    "natsWebSocket": {
      "url": "ws://localhost:1443",
      "reconnect": true,
      "maxReconnectAttempts": 10,
      "reconnectTimeWait": 2000
    }
  }
}
```

### Subscription Configuration

```json
{
  "subscriptions": {
    "players": [
      "structs.player.0-1.1-11",
      "structs.player.0-1.1-12"
    ],
    "planets": [
      "structs.planet.2-1",
      "structs.planet.2-2"
    ],
    "global": [
      "structs.global"
    ]
  }
}
```

---

## Examples

### Complete Streaming Example

```json
{
  "example": "complete-streaming-setup",
  "steps": [
    {
      "step": 1,
      "action": "connect",
      "url": "nats://localhost:4222",
      "store": "connection"
    },
    {
      "step": 2,
      "action": "subscribe",
      "subject": "structs.player.0-1.1-11",
      "handler": "handlePlayerUpdate"
    },
    {
      "step": 3,
      "action": "subscribe",
      "subject": "structs.planet.2-1",
      "handler": "handlePlanetUpdate"
    },
    {
      "step": 4,
      "action": "subscribe",
      "subject": "structs.global",
      "handler": "handleGlobalUpdate"
    },
    {
      "step": 5,
      "action": "listen",
      "duration": "indefinite"
    }
  ]
}
```

---

*Last Updated: January 2025*
