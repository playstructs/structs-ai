# Combat Bot Example

**Version**: 1.1.0
**Category**: Gameplay
**Purpose**: Scout targets, assemble forces, and execute attacks

---

## Overview

This bot implements three combat workflows: a full attack sequence for capturing enemy planets, a raid workflow for stealing resources, and a defense workflow for protecting owned planets. Each workflow includes prerequisite verification, execution, and post-combat actions.

## Attack Workflow

### Step 1: Scout Target

Chart the enemy planet to assess its defenses and ownership.

Request:

```json
{
  "action": "chart",
  "planetId": "enemy-planet-id"
}
```

Expected response:

```json
{
  "status": "charted",
  "revealed": {
    "defenses": [
      { "type": "planetaryDefenseCannon", "count": 1 }
    ],
    "structs": [
      { "type": "planetaryBattleship", "count": 1 }
    ],
    "ownership": {
      "claimed": true,
      "owner": "enemy-player-id"
    }
  }
}
```

### Step 2: Assess Combat Requirements

Evaluate the enemy defenses and determine the required forces.

```json
{
  "enemyDefenses": {
    "defenseCannon": 1,
    "battleships": 1
  },
  "requiredForces": {
    "commandShips": 2,
    "powerNeeded": 100000
  },
  "risk": "medium"
}
```

### Step 3: Prepare Forces

Verify that the player has sufficient power and forces.

Request:

```json
{
  "action": "queryPower",
  "playerId": "self"
}
```

Expected response:

```json
{
  "powerStatus": {
    "availableCapacity": 200000,
    "playerOnline": true
  }
}
```

Both `sufficientPower` and `forcesReady` must be true before proceeding.

### Step 4: Execute Attack

Launch the attack with verified forces.

Request:

```json
{
  "action": "attack",
  "type": "attack",
  "target": "enemy-planet-id",
  "structs": ["command-ship-1", "command-ship-2"],
  "verify": {
    "playerOnline": true,
    "sufficientPower": true,
    "structsOnline": true,
    "validTarget": true
  }
}
```

Expected response (victory):

```json
{
  "status": "resolved",
  "outcome": {
    "victory": true,
    "alphaMatterGained": 5,
    "unitsDestroyed": ["enemy-battleship-1"],
    "resourcesLost": {
      "ore": 0
    }
  },
  "battleDetails": {
    "evasionChecks": 2,
    "blockingChecks": 1,
    "counterAttacks": 1
  }
}
```

### Step 5: Secure Captured Planet

After a successful attack, build defenses on the captured planet.

```json
{
  "action": "build",
  "structType": "planetaryDefenseCannon",
  "locationType": 1,
  "locationId": "enemy-planet-id",
  "slot": "space"
}
```

## Raid Workflow

Raids steal resources from enemy planets without capturing them. The fleet must be moved away from station before raiding.

### Step 1: Move Fleet

Move the fleet away from station to enable raiding.

Request:

```json
{
  "action": "moveFleet",
  "fleetId": "fleet-id",
  "status": "away"
}
```

Verify that the fleet is away and the Command Ship is online before proceeding.

### Step 2: Execute Raid

Launch the raid against the target planet.

Request:

```json
{
  "action": "raid",
  "type": "raid",
  "target": "target-planet-id",
  "fleetId": "fleet-id",
  "verify": {
    "playerOnline": true,
    "fleetAway": true,
    "commandShipOnline": true,
    "proofOfWork": true
  }
}
```

Expected response (victory):

```json
{
  "status": "raidComplete",
  "outcome": {
    "status": "victory",
    "victory": true,
    "oreStolen": 10,
    "alphaMatterGained": 0
  }
}
```

### Possible Raid Outcomes

**Victory**: The attacker successfully completed the raid and gained resources.

**Defeat**: The attacker lost the raid and gained no resources.

**Attacker Retreated** (v0.8.0-beta): The attacker retreated from the raid. No resources are gained or lost, and the fleet remains intact. The fleet can immediately be used for another raid attempt.

When the attacker retreats:
1. Query the fleet to confirm it is intact
2. Confirm no resources were transferred
3. Decide whether to attempt another raid

For a detailed retreat workflow, see [examples/workflows/raid-attacker-retreated.md](workflows/raid-attacker-retreated.md).

## Defense Workflow

### Step 1: Build Defenses

Build defensive structures on the planet.

```json
{
  "action": "build",
  "structType": "planetaryDefenseCannon",
  "locationType": 1,
  "locationId": "planet-id",
  "slot": "space"
}
```

### Step 2: Monitor for Attacks

Periodically query the planet to detect incoming attacks.

```json
{
  "action": "queryPlanet",
  "planetId": "planet-id"
}
```

### Step 3: Respond Automatically

Defensive structures fire automatically when the planet is attacked. No manual intervention is required.

## Error Handling

**Insufficient power**: Convert Alpha Matter to Watts before attempting combat operations.

**Fleet not away**: Move the fleet away from station before initiating a raid. Raids require the fleet to be in the "away" status.

**Command Ship offline**: Activate the Command Ship before any combat operations. Both attacks and raids require the Command Ship to be online.

## Cross-References

- Action quick reference: [reference/action-quick-reference.md](../reference/action-quick-reference.md)
- Raid retreat workflow: [examples/workflows/raid-attacker-retreated.md](workflows/raid-attacker-retreated.md)
- Gameplay protocol: [protocols/gameplay-protocol.md](../protocols/gameplay-protocol.md)
- Error handling: [protocols/error-handling.md](../protocols/error-handling.md)
