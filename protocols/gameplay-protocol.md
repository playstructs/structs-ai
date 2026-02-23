# Gameplay Protocol

**Version**: 1.1.0  
**Category**: Gameplay  
**Status**: Stable  
**Last Updated**: January 16, 2026

## Overview

This protocol defines how AI agents interact with Structs gameplay mechanics. It covers resource management, combat, building, mining, and the 5X Framework gameplay loop.

## Gameplay Systems

### Resource Management

**Purpose**: Manage Alpha Matter, Watts, and other resources for gameplay operations.

**Resource Types**:
- **Alpha Matter** (grams): Secure, refined resource - cannot be stolen
- **Ore** (grams): Raw, stealable resource - must be refined to Alpha Matter
- **Watts** (kW): Energy units - powers all operations

**Resource Flow**:
1. Mine ore from planets (stealable)
2. Refine ore to Alpha Matter (secure)
3. Convert Alpha Matter to Watts (power)
4. Use Watts for operations

**Conversion Rates**:
- **Reactor**: 1g Alpha Matter = 1kW (safe, low risk)
- **Planetary Generator**: 1g Alpha Matter = 2kW (efficient, high risk)

### Mining Protocol

**Purpose**: Extract Alpha Matter from planets.

**Request Format**:
```json
{
  "action": "mine",
  "planetId": "2-1",
  "extractorId": "struct-id",
  "verify": {
    "currentOre": 5,
    "maxOre": 5,
    "extractorOnline": true,
    "sufficientPower": true
  }
}
```

**Response Format**:
```json
{
  "status": "mining",
  "planetId": "2-1",
  "extractorId": "struct-id",
  "currentOre": 4,
  "oreExtracted": 1,
  "oreStored": 1,
  "security": {
    "oreStored": 1,
    "needsRefinement": true,
    "warning": "Ore can be stolen - refine to Alpha Matter immediately"
  }
}
```

**Refinement Protocol**:
```json
{
  "action": "refine",
  "planetId": "2-1",
  "oreAmount": 1,
  "verify": {
    "oreAvailable": 1,
    "refineryOnline": true,
    "sufficientPower": true
  }
}
```

**Refinement Response**:
```json
{
  "status": "refined",
  "oreRefined": 1,
  "alphaMatterGained": 1,
  "security": {
    "alphaMatterSecure": true,
    "cannotBeStolen": true
  }
}
```

### Power Management Protocol

**Purpose**: Monitor and manage power capacity and consumption.

**Query Format**:
```json
{
  "action": "queryPower",
  "playerId": "structs1..."
}
```

**Response Format**:
```json
{
  "powerStatus": {
    "capacity": 1000000,
    "capacitySecondary": 0,
    "load": 500000,
    "structsLoad": 500000,
    "availableCapacity": 0,
    "allocatableCapacity": 500000,
    "playerOnline": true
  },
  "requirements": {
    "playerOnline": "(load + structsLoad) <= (capacity + capacitySecondary)",
    "offline": "(load + structsLoad) > (capacity + capacitySecondary)"
  },
  "warning": {
    "nearCapacity": false,
    "offlineRisk": false
  }
}
```

**Power Conversion Protocol**:
```json
{
  "action": "convertPower",
  "method": "reactor",
  "alphaMatterAmount": 100,
  "verify": {
    "alphaMatterAvailable": 100,
    "method": "reactor",
    "expectedOutput": 100
  }
}
```

**Conversion Response**:
```json
{
  "status": "converted",
  "method": "reactor",
  "alphaMatterUsed": 100,
  "wattsGained": 100,
  "rate": "1g:1kW",
  "risk": "low"
}
```

### Building Protocol

**Purpose**: Build structures on planets or in fleets.

**Request Format**:
```json
{
  "action": "build",
  "structType": "19",
  "locationType": 1,
  "locationId": "2-1",
  "slot": "space",
  "verify": {
    "playerOnline": true,
    "fleetOnStation": true,
    "commandShipOnline": true,
    "sufficientPower": true,
    "availableSlot": true,
    "buildLimit": {
      "maxPerPlayer": 1,
      "currentCount": 0,
      "withinLimit": true
    }
  }
}
```

**Response Format**:
```json
{
  "status": "building",
  "structId": "new-struct-id",
  "structType": "19",
  "locationId": "2-1",
  "buildTime": 3600,
  "costs": {
    "buildPower": 600000,
    "passivePower": 600000
  },
  "requirements": {
    "playerOnline": true,
    "commandShipOnline": true,
    "fleetOnStation": true
  }
}
```

**Build Requirements**:
- **Fleet On Station**: Required for planet building
- **Command Ship Online**: Required for all building
- **Player Online**: Required (sufficient power)
- **Available Slot**: Required for planet building
- **Build Limit**: Check per-player limits (e.g., Defense Cannon = 1)

### Combat Protocol

**Purpose**: Execute combat actions (attack, defend, raid).

**Attack Request**:
```json
{
  "action": "attack",
  "type": "attack",
  "target": "2-1",
  "structs": ["struct-id-1", "struct-id-2"],
  "verify": {
    "playerOnline": true,
    "sufficientPower": true,
    "structsOnline": true,
    "validTarget": true
  }
}
```

**Raid Request**:
```json
{
  "action": "raid",
  "type": "raid",
  "target": "2-1",
  "fleetId": "fleet-id",
  "verify": {
    "playerOnline": true,
    "fleetAway": true,
    "commandShipOnline": true,
    "proofOfWork": true
  }
}
```

**Combat Response**:
```json
{
  "status": "resolved",
  "outcome": {
    "status": "victory",
    "victory": true,
    "alphaMatterGained": 5,
    "unitsDestroyed": ["enemy-struct-id"],
    "resourcesLost": {
      "ore": 0
    }
  },
  "battleDetails": {
    "evasionChecks": 2,
    "blockingChecks": 1,
    "counterAttacks": 1,
    "recoilDamage": 0
  }
}
```

**Raid Outcome Statuses**:
- `"victory"`: Attacker successfully completed the raid and gained resources
- `"defeat"`: Attacker lost the raid (defender successfully defended)
- `"attackerRetreated"`: Attacker retreated from the raid before completion (new in v0.8.0-beta)

**Defeat by Destruction**:
- Defeat can be triggered when the attacker Command Ship is destroyed
- This is governed by the `TriggerRaidDefeatByDestruction` flag on the Command Ship (v0.10.0-beta fix)

**AttackerRetreated Status**:
The `attackerRetreated` status indicates that the attacker chose to retreat from a raid before it was completed. This can occur when:
- Attacker decides to withdraw during the raid
- Attacker's forces are insufficient to continue
- Strategic decision to preserve forces

When `attackerRetreated` status is returned:
- No resources are gained by the attacker
- No resources are lost by the defender
- Attacker's fleet remains intact
- Raid is considered incomplete

**Combat Mechanics**:
- **Evasion**: Based on weapon type (guided vs unguided)
- **Blocking**: Defenders can block for other structs
- **Counter-Attacks**: Structs counter-attack automatically
- **Multi-Shot**: Weapons fire multiple shots
- **Recoil**: Some weapons damage attacker

### Exploration Protocol

**Purpose**: Explore and chart planets.

**Chart Planet Request**:
```json
{
  "action": "chart",
  "planetId": "2-1",
  "verify": {
    "planetExists": true,
    "cost": "free",
    "time": "instant"
  }
}
```

**Chart Response**:
```json
{
  "status": "charted",
  "planetId": "2-1",
  "revealed": {
    "resources": {
      "maxOre": 5,
      "currentOre": 5
    },
    "slots": {
      "space": 4,
      "air": 4,
      "land": 4,
      "water": 4
    },
    "ownership": {
      "claimed": false,
      "owner": null
    },
    "defenses": []
  }
}
```

**Explore New Planet Request**:
```json
{
  "action": "explore",
  "verify": {
    "currentPlanetComplete": true,
    "description": "Current planet must be depleted (ore = 0)"
  }
}
```

**Explore Response**:
```json
{
  "status": "explored",
  "newPlanetId": "3-1",
  "startingProperties": {
    "maxOre": 5,
    "spaceSlots": 4,
    "airSlots": 4,
    "landSlots": 4,
    "waterSlots": 4
  },
  "fleetMoved": true
}
```

## Gameplay State Queries Protocol

**Purpose**: Query gameplay-specific state information for AI agents.

### Player Online Status Query

**Request Format**:
```json
{
  "action": "queryGameplayState",
  "queryType": "playerOnline",
  "playerId": "structs1...",
  "parameters": {}
}
```

**Response Format**:
```json
{
  "status": "success",
  "queryType": "playerOnline",
  "result": {
    "value": true,
    "status": "online",
    "canAct": true,
    "formula": "(load + structsLoad) <= (capacity + capacitySecondary)",
    "calculation": {
      "capacity": 1000000,
      "capacitySecondary": 0,
      "load": 500000,
      "structsLoad": 500000,
      "availableCapacity": 0,
      "playerOnline": true
    },
    "description": "Player is online - can perform actions"
  }
}
```

### Can Build Query

**Request Format**:
```json
{
  "action": "queryGameplayState",
  "queryType": "canBuild",
  "playerId": "structs1...",
  "parameters": {
    "structType": "19",
    "locationType": 1,
    "locationId": "2-1"
  }
}
```

**Response Format**:
```json
{
  "status": "success",
  "queryType": "canBuild",
  "result": {
    "value": true,
    "requirements": {
      "playerOnline": true,
      "commandShipOnline": true,
      "fleetOnStation": true,
      "sufficientPower": true,
      "availableSlot": true,
      "withinBuildLimit": true
    },
    "description": "All requirements met - can build"
  }
}
```

### Can Raid Query

**Request Format**:
```json
{
  "action": "queryGameplayState",
  "queryType": "canRaid",
  "playerId": "structs1...",
  "parameters": {
    "fleetId": "1-1"
  }
}
```

**Response Format**:
```json
{
  "status": "success",
  "queryType": "canRaid",
  "result": {
    "value": true,
    "requirements": {
      "playerOnline": true,
      "fleetAway": true,
      "commandShipOnline": true,
      "proofOfWork": true
    },
    "description": "All requirements met - can raid"
  }
}
```

### Can Mine Query

**Request Format**:
```json
{
  "action": "queryGameplayState",
  "queryType": "canMine",
  "playerId": "structs1...",
  "parameters": {
    "planetId": "2-1",
    "extractorId": "extractor-1"
  }
}
```

**Response Format**:
```json
{
  "status": "success",
  "queryType": "canMine",
  "result": {
    "value": true,
    "requirements": {
      "extractorOnline": true,
      "currentOre": 5,
      "sufficientPower": true
    },
    "description": "All requirements met - can mine"
  }
}
```

### Can Explore Query

**Request Format**:
```json
{
  "action": "queryGameplayState",
  "queryType": "canExplore",
  "playerId": "structs1...",
  "parameters": {}
}
```

**Response Format**:
```json
{
  "status": "success",
  "queryType": "canExplore",
  "result": {
    "value": true,
    "requirements": {
      "playerOnline": true,
      "currentPlanetComplete": true,
      "currentPlanetOre": 0
    },
    "description": "All requirements met - can explore new planet"
  }
}
```

### Fleet Management Protocol

**Purpose**: Manage fleet movement and status.

**Fleet Status**:
- **On Station**: Fleet is at planet - can build on planets, cannot raid
- **Away**: Fleet is away from planet - can raid, cannot build

**Move Fleet Request**:
```json
{
  "action": "moveFleet",
  "fleetId": "1-1",
  "destinationType": 1,
  "destinationId": "2-1",
  "verify": {
    "playerOnline": true,
    "commandShipOnline": true,
    "validDestination": true
  }
}
```

**Move Fleet Response**:
```json
{
  "status": "moved",
  "fleetId": "1-1",
  "newStatus": "onStation",
  "locationId": "2-1",
  "canBuild": true,
  "canRaid": false
}
```

**Fleet Status Query**:
```json
{
  "action": "queryFleetStatus",
  "fleetId": "1-1"
}
```

**Fleet Status Response**:
```json
{
  "status": "success",
  "fleetId": "1-1",
  "fleetStatus": "onStation",
  "canBuild": true,
  "canRaid": false,
  "commandShipOnline": true,
  "requirements": {
    "commandShip": true,
    "commandShipOnline": true,
    "playerOnline": true
  }
}
```

**Fleet Requirements**:
- **Command Ship**: Fleet must have Command Ship to operate
- **Command Ship Online**: Command Ship must be online for fleet operations
- **Player Online**: Player must be online (sufficient power) to control fleet

### Guild Operations Protocol

**Purpose**: Manage guild membership and operations.

**Create Guild Request**:
```json
{
  "action": "createGuild",
  "verify": {
    "playerOnline": true,
    "notInGuild": true
  }
}
```

**Create Guild Response**:
```json
{
  "status": "created",
  "guildId": "0-1",
  "owner": "structs1...",
  "members": ["structs1..."]
}
```

**Join Guild Request**:
```json
{
  "action": "joinGuild",
  "guildId": "0-1",
  "verify": {
    "playerOnline": true,
    "notInGuild": true,
    "guildExists": true
  }
}
```

**Join Guild Response**:
```json
{
  "status": "joined",
  "guildId": "0-1",
  "playerId": "structs1...",
  "memberCount": 2
}
```

**Leave Guild Request**:
```json
{
  "action": "leaveGuild",
  "verify": {
    "playerOnline": true,
    "inGuild": true
  }
}
```

**Leave Guild Response**:
```json
{
  "status": "left",
  "playerId": "structs1...",
  "guildId": null
}
```

**Guild Token Operations**:
```json
{
  "action": "mintGuildTokens",
  "guildId": "0-1",
  "amount": "1000000",
  "verify": {
    "playerOnline": true,
    "inGuild": true,
    "guildPermission": true
  }
}
```

**Guild Requirements**:
- **Player Online**: Required for all guild operations
- **Not In Guild**: Required for create/join (player must not be in a guild)
- **In Guild**: Required for leave/token operations (player must be in a guild)
- **Guild Permission**: Required for token operations (trust-based system)

### Planet Management Protocol

**Purpose**: Manage planet ownership and operations beyond exploration.

**Claim Planet**:
Planets are claimed automatically when you build structures on them. No explicit "claim" action needed.

**Planet Status Query**:
```json
{
  "action": "queryPlanetStatus",
  "planetId": "2-1"
}
```

**Planet Status Response**:
```json
{
  "status": "success",
  "planetId": "2-1",
  "owner": "structs1...",
  "currentOre": 3,
  "maxOre": 5,
  "isComplete": false,
  "structs": {
    "space": 2,
    "air": 1,
    "land": 1,
    "water": 0
  },
  "slots": {
    "space": 2,
    "air": 3,
    "land": 3,
    "water": 4
  }
}
```

**Planet Completion Check**:
```json
{
  "action": "checkPlanetCompletion",
  "planetId": "2-1"
}
```

**Planet Completion Response**:
```json
{
  "status": "success",
  "planetId": "2-1",
  "isComplete": false,
  "currentOre": 3,
  "consequences": {
    "structsDestroyed": false,
    "fleetsSentAway": false,
    "planetStatus": "active"
  },
  "warning": "If ore reaches 0, all structs will be destroyed and fleets sent away"
}
```

**Planet Management Rules**:
- **One Planet at a Time**: You can only own one planet at a time
- **Claim by Building**: Planets are claimed when you build structures on them
- **Completion Consequences**: When ore is depleted, all structs destroyed, fleets sent away
- **Planet Trading**: Planets can be traded (see trading protocol)

## 5X Framework Protocol

**Purpose**: Execute gameplay loop following 5X Framework.

**Gameplay Loop State**:
```json
{
  "currentPhase": "extract",
  "actions": [
    {
      "actionType": "mine",
      "target": "2-1",
      "status": "active"
    },
    {
      "actionType": "refine",
      "target": "2-1",
      "status": "pending"
    }
  ],
  "nextPhase": "expand",
  "loop": {
    "explore": "Discover galaxy, find resources",
    "extract": "Mine Alpha Matter, convert to Watts",
    "expand": "Control planets, build infrastructure",
    "exterminate": "Defend assets, attack enemies",
    "exchange": "Trade resources, buy/sell equipment"
  }
}
```

**Phase Transitions**:
1. **EXPLORE** → **EXTRACT**: After finding resource-rich planet
2. **EXTRACT** → **EXPAND**: After establishing resource flow
3. **EXPAND** → **EXTERMINATE**: After expanding, defend/attack
4. **EXTERMINATE** → **EXCHANGE**: After combat, trade resources
5. **EXCHANGE** → **EXPLORE**: After trading, explore for more

## Error Cases

**Insufficient Power**:
```json
{
  "error": "insufficientPower",
  "message": "Player offline - insufficient power capacity",
  "required": {
    "capacity": 1000000,
    "consumption": 1500000,
    "shortfall": 500000
  },
  "solution": "Reduce consumption or increase capacity"
}
```

**Build Requirements Not Met**:
```json
{
  "error": "buildRequirementsNotMet",
  "message": "Cannot build - requirements not met",
  "missing": {
    "fleetOnStation": false,
    "commandShipOnline": false
  },
  "solution": "Ensure fleet is on station and Command Ship is online"
}
```

**Resource Security Warning**:
```json
{
  "warning": "resourceSecurity",
  "message": "Ore stored - can be stolen in raids",
  "oreStored": 10,
  "solution": "Refine ore to Alpha Matter immediately to secure resources"
}
```

## Best Practices

1. **Resource Security**: Always refine ore to Alpha Matter immediately
2. **Power Management**: Monitor power capacity to stay online
3. **Build Requirements**: Verify all requirements before building
4. **Combat Preparation**: Ensure sufficient power and online status
5. **Planet Completion**: Plan for planet depletion consequences
6. **Fleet Management**: Keep Command Ship online for operations
7. **Defense First**: Build defenses before expanding

## Examples

See `/ai/examples/` for complete gameplay workflow examples.

