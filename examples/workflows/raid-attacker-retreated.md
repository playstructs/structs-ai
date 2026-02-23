# Raid Attacker Retreated Workflow

**Version**: 1.0.0
**Category**: gameplay
**Description**: Detailed workflow for handling attackerRetreated raid outcome (v0.8.0-beta)

---

## v0.8.0-beta Feature

- **Feature**: attackerRetreated
- **Status**: New raid outcome status

---

## Workflow: Handle Attacker Retreated Status

### Step 1: Initiate Raid

Start raid on target planet.

**Action**: `raid`

**Request**:

```json
{
  "action": "raid",
  "type": "raid",
  "target": "2-1",
  "fleetId": "9-1",
  "verify": {
    "playerOnline": true,
    "fleetAway": true,
    "commandShipOnline": true,
    "proofOfWork": true
  }
}
```

### Step 2: Wait for Raid Completion

Wait for raid to complete (may result in retreat).

**Polling**:

| Parameter | Value |
|-----------|-------|
| Endpoint | `GET /structs/planet/{planetId}` |
| Interval | 2 seconds |
| Max Attempts | 60 |
| Check Field | `planet.raidStatus` |

### Step 3: Check Raid Outcome

Query raid outcome status.

**Endpoint**: `GET /structs/planet/{planetId}`

**Expected Fields**:

| Field | Expected Value |
|-------|----------------|
| `planet.raidStatus` | `complete` |
| `planet.raidOutcome.status` | `attackerRetreated` |

### Step 4: Handle Attacker Retreated Status

Process attackerRetreated outcome.

| Property | Value |
|----------|-------|
| Resources Gained | false |
| Resources Lost | false |
| Fleet Intact | true |

**Actions**:

1. No resources transferred
2. Fleet remains intact
3. No damage to attacker or defender
4. Raid considered incomplete

### Step 5: Verify Fleet Status

Confirm fleet is intact and ready.

**Endpoint**: `GET /structs/fleet/{fleetId}`

**Expected Fields**:

| Field | Expected Value |
|-------|----------------|
| `fleet.status` | `away` |
| `fleet.ships` | `intact` |
| `fleet.commandShip` | `online` |

### Step 6: Verify Resource Status

Confirm no resources were transferred.

**Attacker Resources** -- `GET /structs/player/{attackerId}`:

| Field | Expected Value |
|-------|----------------|
| `player.alphaMatter` | unchanged |
| `player.ore` | unchanged |

**Defender Resources** -- `GET /structs/player/{defenderId}`:

| Field | Expected Value |
|-------|----------------|
| `player.alphaMatter` | unchanged |
| `player.ore` | unchanged |

---

## Raid Outcome Scenarios

### attackerRetreated

Attacker retreated from raid before completion.

| Property | Value |
|----------|-------|
| Resources Gained | false |
| Resources Lost | false |
| Fleet Intact | true |
| Raid Complete | false |

**Example Response**:

```json
{
  "status": "raidComplete",
  "outcome": {
    "status": "attackerRetreated",
    "victory": false,
    "alphaMatterGained": 0,
    "oreStolen": 0,
    "unitsDestroyed": [],
    "resourcesLost": {
      "ore": 0
    }
  }
}
```

### victory

Attacker successfully completed raid.

| Property | Value |
|----------|-------|
| Resources Gained | true |
| Resources Lost | false |
| Fleet Intact | true |
| Raid Complete | true |

**Example Response**:

```json
{
  "status": "raidComplete",
  "outcome": {
    "status": "victory",
    "victory": true,
    "alphaMatterGained": 5,
    "oreStolen": 10,
    "unitsDestroyed": ["enemy-struct-id"]
  }
}
```

### defeat

Attacker lost the raid.

| Property | Value |
|----------|-------|
| Resources Gained | false |
| Resources Lost | false |
| Fleet Intact | false |
| Raid Complete | true |

**Example Response**:

```json
{
  "status": "raidComplete",
  "outcome": {
    "status": "defeat",
    "victory": false,
    "alphaMatterGained": 0,
    "oreStolen": 0,
    "unitsDestroyed": ["attacker-struct-id"]
  }
}
```

---

## Retreat Handling Patterns

### Pattern 1: Strategic Retreat

- **Description**: Retreat when forces are insufficient
- **Condition**: `fleetHealth < threshold`
- **Action**: Retreat to preserve fleet
- **Result**: `attackerRetreated` status

### Pattern 2: Tactical Withdrawal

- **Description**: Retreat to avoid losses
- **Condition**: `defenderStrength > attackerStrength`
- **Action**: Withdraw before taking losses
- **Result**: `attackerRetreated` status

### Pattern 3: Change of Plans

- **Description**: Retreat due to changed circumstances
- **Condition**: External factors changed
- **Action**: Abort raid mission
- **Result**: `attackerRetreated` status

---

## Resource Management on Retreat

When an attacker retreats, no resources are transferred between attacker and defender.

### Attacker

| Resource | Status |
|----------|--------|
| Alpha Matter | unchanged |
| Ore | unchanged |
| Fleet | intact |
| Losses | none |

### Defender

| Resource | Status |
|----------|--------|
| Alpha Matter | unchanged |
| Ore | unchanged |
| Defenses | intact |
| Losses | none |

### Outcome Comparison

| Outcome | Attacker Alpha Matter | Attacker Ore | Attacker Fleet | Defender Resources Lost | Defender Defenses |
|---------|-----------------------|--------------|-----------------|--------------------------|-------------------|
| victory | positive | positive (stolen) | intact | positive (ore lost) | possibly damaged |
| defeat | 0 | 0 | possibly damaged | 0 | intact |
| attackerRetreated | 0 | 0 | intact | 0 | intact |

---

## Status Checking

### Check Raid Status

**Endpoint**: `GET /structs/planet/{planetId}`

**Fields to check**:

- `planet.raidStatus`
- `planet.raidOutcome.status`
- `planet.raidOutcome.victory`

### Check if Attacker Retreated

```javascript
const isAttackerRetreated = (raidOutcome) => raidOutcome.status === 'attackerRetreated';
```

```python
def is_attacker_retreated(raid_outcome):
    return raid_outcome.status == 'attackerRetreated'
```

```go
func isAttackerRetreated(raidOutcome RaidOutcome) bool {
    return raidOutcome.Status == "attackerRetreated"
}
```

### Handle All Outcomes

```javascript
switch (raidOutcome.status) {
  case 'victory':
    handleVictory(raidOutcome);
    break;
  case 'defeat':
    handleDefeat(raidOutcome);
    break;
  case 'attackerRetreated':
    handleRetreat(raidOutcome);
    break;
}
```

```python
if raid_outcome.status == 'victory':
    handle_victory(raid_outcome)
elif raid_outcome.status == 'defeat':
    handle_defeat(raid_outcome)
elif raid_outcome.status == 'attackerRetreated':
    handle_retreat(raid_outcome)
```

---

## Streaming Events

### PlanetRaidStatusEvent

Streaming event for raid status changes.

**Event Type**: `PlanetRaidStatusEvent`

**Schema**:

| Field | Type | Values |
|-------|------|--------|
| `category` | string | `raid_status` |
| `data.status` | string | `victory`, `defeat`, `attackerRetreated` |
| `data.attackerId` | string | Player ID |
| `data.planetId` | string | Planet ID |

**Example Event**:

```json
{
  "category": "raid_status",
  "data": {
    "status": "attackerRetreated",
    "attackerId": "1-11",
    "planetId": "2-1"
  }
}
```

---

## Examples

### Scenario 1: Attacker Retreats Due to Strong Defenses

- **Workflow**: Attacker initiates raid, sees strong defenses, retreats
- **Outcome**: `attackerRetreated`
- **Resources**: No resources transferred

### Scenario 2: Attacker Retreats to Preserve Fleet

- **Workflow**: Attacker's fleet takes damage, decides to retreat
- **Outcome**: `attackerRetreated`
- **Resources**: Fleet intact, no resources lost

### Scenario 3: Attacker Retreats After Change of Plans

- **Workflow**: Attacker aborts raid mission
- **Outcome**: `attackerRetreated`
- **Resources**: No resources transferred
