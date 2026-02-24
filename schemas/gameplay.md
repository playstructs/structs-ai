# Structs Gameplay Schema

**Version**: 1.1.0
**Category**: gameplay
**Schema**: JSON Schema Draft-07
**Description**: Gameplay mechanics, systems, and patterns for AI agents.

---

## Definitions

### Resource

Game resource definition.

| Field | Type | Required | Values | Description |
|-------|------|----------|--------|-------------|
| type | string | Yes | `alphaMatter`, `watts`, `ore`, `computingPower`, `arms` | Resource type |
| amount | number | Yes | minimum: 0 | Resource amount |
| unit | string | Yes | | Resource unit (grams, kW, etc.) |
| security | string | Yes | `secure`, `stealable` | Whether resource can be stolen (ore = stealable, alphaMatter = secure) |

### ResourceConversion

Resource conversion definition.

| Field | Type | Required | Values | Description |
|-------|------|----------|--------|-------------|
| from | string | Yes | `alphaMatter`, `ore` | Source resource type |
| to | string | Yes | `alphaMatter`, `watts` | Target resource type |
| method | string | Yes | `reactor`, `planetaryGenerator` | Conversion method |
| rate | object | Yes | | Conversion rate (see below) |
| risk | string | Yes | `low`, `high` | Conversion risk level (reactor = low, generator = high) |

#### rate

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| input | number | Yes | Input amount |
| output | number | Yes | Output amount |
| unit | string | Yes | Rate unit (e.g., `1g:1kW` for reactor) |

### CombatAction

Combat action definition.

| Field | Type | Required | Values | Description |
|-------|------|----------|--------|-------------|
| type | string | Yes | `attack`, `defend`, `raid` | Combat action type |
| attacker | string | Yes | | Attacker player ID |
| target | string | Yes | | Target planet ID or struct ID |
| structs | array of string | No | | Struct IDs participating in combat |
| requirements | object | No | | Combat requirements (see below) |
| outcome | object | No | | Combat outcome (see below) |

#### requirements

| Field | Type | Description |
|-------|------|-------------|
| playerOnline | boolean | Player must be online |
| sufficientPower | boolean | Sufficient Watts available |
| fleetAway | boolean | Fleet must be away (for raids) |
| proofOfWork | boolean | Proof-of-work required (for raids) |

#### outcome

| Field | Type | Values | Description |
|-------|------|--------|-------------|
| status | string | `victory`, `defeat`, `attackerRetreated` | Combat outcome status |
| victory | boolean | | Whether attacker won (deprecated: use `status` instead) |
| alphaMatterGained | number | | Alpha Matter gained by victor |
| unitsDestroyed | array of string | | Struct IDs destroyed |
| resourcesLost | object | | Resources lost by defender (e.g., `ore` amount stolen in raids) |

### BuildingAction

Building/construction action.

| Field | Type | Required | Values | Description |
|-------|------|----------|--------|-------------|
| structType | string | Yes | | Struct type ID to build |
| locationType | integer | Yes | 1 = planet, 2 = fleet, 3 = substation, 4 = reactor | Location type |
| locationId | string | Yes | | Location ID (planet ID, fleet ID, etc.) |
| slot | string | No | `space`, `air`, `land`, `water` | Planet slot type (if building on planet) |
| requirements | object | No | | Building requirements (see below) |
| costs | object | No | | Building costs (see below) |

#### requirements

| Field | Type | Description |
|-------|------|-------------|
| playerOnline | boolean | Player must be online |
| fleetOnStation | boolean | Fleet must be on station (for planet building) |
| commandShipOnline | boolean | Command Ship must be online |
| sufficientPower | boolean | Sufficient Watts for build and operation |
| availableSlot | boolean | Available slot on planet |
| buildLimit | object | Build limit check with `maxPerPlayer` and `currentCount` |

#### costs

| Field | Type | Description |
|-------|------|-------------|
| buildPower | number | Watts required to build |
| passivePower | number | Watts required to operate (passive draw) |
| buildTime | number | Build time in seconds |

### MiningOperation

Mining operation definition.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| planetId | string | Yes | Planet ID being mined |
| extractorId | string | Yes | Ore Extractor struct ID |
| currentOre | number | Yes | Current ore on planet |
| maxOre | number | Yes | Maximum ore on planet |
| extractionRate | number | No | Ore extracted per time unit |
| security | object | No | Mining security status (see below) |

#### security

| Field | Type | Description |
|-------|------|-------------|
| oreStored | number | Ore stored (stealable) |
| alphaMatterRefined | number | Alpha Matter refined (secure) |
| needsRefinement | boolean | Whether ore needs to be refined |

### GameplayLoop

5X Framework gameplay loop.

| Field | Type | Required | Values | Description |
|-------|------|----------|--------|-------------|
| phase | string | Yes | `explore`, `extract`, `expand`, `exterminate`, `exchange` | Current gameplay phase |
| actions | array | Yes | | Actions available in this phase |
| nextPhase | string | No | `explore`, `extract`, `expand`, `exterminate`, `exchange` | Next phase in loop |

Each action in the `actions` array:

| Field | Type | Description |
|-------|------|-------------|
| actionType | string | Action type (chart, mine, build, attack, trade) |
| target | string | Target ID (planet, struct, player) |
| requirements | object | Action requirements |

### PowerManagement

Power capacity and consumption.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| capacity | number | Yes | Primary power capacity (from substation) |
| capacitySecondary | number | Yes | Secondary power capacity (from secondary substation) |
| load | number | Yes | Current power consumption (active operations) |
| structsLoad | number | Yes | Total power consumption from all structs (passive draw) |
| availableCapacity | number | No | Available: `(capacity + capacitySecondary) - (load + structsLoad)` |
| allocatableCapacity | number | No | Allocatable: `capacity - load` |
| playerOnline | boolean | Yes | Online status: `(load + structsLoad) <= (capacity + capacitySecondary)` |

### PlanetCompletion

Planet completion mechanics.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| planetId | string | Yes | Planet ID |
| currentOre | number | Yes | Current ore remaining |
| isComplete | boolean | Yes | Whether planet is complete (ore depleted) |
| consequences | object | No | What happens when planet completes (see below) |

#### consequences

| Field | Type | Description |
|-------|------|-------------|
| structsDestroyed | boolean | All structs on planet are destroyed |
| fleetsSentAway | boolean | All fleets are sent away (peace deal) |
| planetStatus | string | Planet status after completion: `active` or `complete` |

### GameplayQuery

Gameplay-specific state query definition.

| Field | Type | Required | Values | Description |
|-------|------|----------|--------|-------------|
| queryType | string | Yes | `playerOnline`, `canBuild`, `canRaid`, `canMine`, `canExplore` | Type of gameplay query |
| playerId | string | Yes | | Player ID to query |
| parameters | object | No | | Query-specific parameters |
| result | object | No | | Query result with `value` (boolean), `reason` (string), and `requirements` (object) |

---

## Constants

### StructSweepDelay

| Property | Value |
|----------|-------|
| Value | 5 |
| Unit | blocks |
| Description | Block-based delay before struct slots are cleared after destruction |

Struct sweeping has a block-based delay. Planet/fleet back references for slots are not cleared until the delay is met. Slots may appear occupied for 5 blocks after struct destruction.

---

## Resource Types

| ID | Name | Unit | Security | Description |
|----|------|------|----------|-------------|
| alphaMatter | Alpha Matter | grams | secure | Refined Alpha Matter -- secure, cannot be stolen |
| ore | Alpha Ore | grams | stealable | Raw ore -- can be stolen in raids, must be refined |
| watts | Watts | kW | secure | Energy units -- powers all operations |

### Alpha Matter

- **Sources**: mining, raids, trading, guild
- **Uses**: convert to Watts, trading, advanced operations

### Alpha Ore

- **Sources**: mining
- **Uses**: refine to Alpha Matter

### Watts

- **Sources**: conversion, generation, trading, guild
- **Uses**: power operations, building, combat, trading

---

## Conversion Rates

| Method | From | To | Input | Output | Rate | Risk | Description |
|--------|------|----|-------|--------|------|------|-------------|
| Reactor | alphaMatter | watts | 1 | 1 | 1g:1kW | low | Safe, reliable conversion |
| Planetary Generator | alphaMatter | watts | 1 | 2 | 1g:2kW | high | Efficient conversion (higher risk) |

---

## Power Requirements

| Struct Type | Passive Draw | Build Draw | Description |
|-------------|-------------|------------|-------------|
| Command Ship | 50,000 | 50,000 | Command Ship power requirements |
| Planetary Battleship | 135,000 | 135,000 | Planetary Battleship power requirements |
| Ore Extractor | 500,000 | 500,000 | Ore Extractor -- high power needed |
| Ore Refinery | 500,000 | 500,000 | Ore Refinery -- high power needed |
| Planetary Defense Cannon | 600,000 | 600,000 | Planetary Defense Cannon power requirements |
| Ore Bunker | 200,000 | 200,000 | Ore Bunker power requirements |

---

## Build Limits

| Struct Type | Max Per Player | Description |
|-------------|---------------|-------------|
| Planetary Defense Cannon | 1 | Only 1 Planetary Defense Cannon per player total |
| Command Ship | 1 | Only 1 Command Ship per player |

---

## Combat Mechanics

### Evasion

Structs can evade attacks based on weapon type.

| Weapon Type | Uses | Description |
|-------------|------|-------------|
| Guided weapons | guidedDefensiveSuccessRate | Target uses guided defensive success rate |
| Unguided weapons | unguidedDefensiveSuccessRate | Target uses unguided defensive success rate |

### Blocking

Defenders can block attacks for other structs.

| Requirement | Description |
|-------------|-------------|
| defenderAssigned | Defender must be assigned to protect struct |
| defenderOnline | Defender must be online |
| sameAmbit | Defender must be in same ambit as target |

### Counter-Attack

Structs can counter-attack when attacked.

| Scenario | Uses | Description |
|----------|------|-------------|
| Same ambit | counterAttackSameAmbit | Damage when countering at same ambit |
| Different ambit | counterAttack | Damage when countering at different ambit |

### Multi-Shot

Weapons can fire multiple shots per attack.

- Each shot has an independent success chance, determined by `weaponShotSuccessRate`.

### Recoil

Weapons can deal damage to the attacker. Recoil damage is applied after all shots complete, using `weaponRecoilDamage`.

---

## Fleet Mechanics

### Fleet Status

| Status | Description | Can Build | Can Raid |
|--------|-------------|-----------|----------|
| onStation | Fleet is at planet | Yes | No |
| away | Fleet is away from planet | No | Yes |

### Fleet Requirements

| Requirement | Required | Description |
|-------------|----------|-------------|
| commandShip | Yes | Fleet must have Command Ship to operate |
| commandShipOnline | Yes | Command Ship must be online for fleet operations |
| playerOnline | Yes | Player must be online (sufficient power) to control fleet |

---

## Planet Mechanics

### Exploration

Create new planets. You can only own one planet at a time -- must complete current planet first.

**Requirements**: Current planet must be complete (ore depleted).

**Starting Properties**:

| Property | Value |
|----------|-------|
| maxOre | 5 |
| spaceSlots | 4 |
| airSlots | 4 |
| landSlots | 4 |
| waterSlots | 4 |

### Charting

Survey planets to reveal resources.

- **Cost**: Free
- **Time**: Instant
- **Reveals**: resources, slot availability, ownership, defenses

### Completion

When planet ore is depleted:

- All structs on planet are destroyed
- All fleets are sent away (peace deal)
- Planet status changes to `complete`

---

## Gameplay Queries

### Player Online Status

**ID**: `player-online`

Check if player is online (sufficient power capacity).

**Formula**: `(load + structsLoad) <= (capacity + capacitySecondary)`

**Properties used**: `capacity`, `capacitySecondary`, `load`, `structsLoad`

| Result | Status | Can Act | Description |
|--------|--------|---------|-------------|
| true | online | Yes | Player can perform actions |
| false | offline | No | Player cannot perform actions |

### Can Build Check

**ID**: `can-build`

Check if player can build structures.

| Requirement | Check | Condition |
|-------------|-------|-----------|
| playerOnline | `powerStatus.playerOnline == true` | Always |
| commandShipOnline | `fleet.commandShip.status == 'online'` | Always |
| fleetOnStation | `fleet.status == 'onStation'` | Only when `locationType == 1` (planet) |
| sufficientPower | `availableCapacity >= (buildPower + passivePower)` | Always |
| availableSlot | `planetSlots[slotType] > 0` | Only when `locationType == 1` (planet) |
| withinBuildLimit | `currentCount < maxPerPlayer` | Only when struct type has build limit |

### Can Raid Check

**ID**: `can-raid`

Check if player can raid planets.

| Requirement | Check |
|-------------|-------|
| playerOnline | `powerStatus.playerOnline == true` |
| fleetAway | `fleet.status == 'away'` |
| commandShipOnline | `fleet.commandShip.status == 'online'` |
| proofOfWork | `proofOfWorkAvailable == true` |

### Can Mine Check

**ID**: `can-mine`

Check if player can mine ore.

| Requirement | Check |
|-------------|-------|
| extractorOnline | `extractor.status == 'online'` |
| currentOre > 0 | `planet.currentOre > 0` |
| sufficientPower | `availableCapacity >= extractor.passivePower` |

### Can Explore Check

**ID**: `can-explore`

Check if player can explore new planet.

| Requirement | Check | Description |
|-------------|-------|-------------|
| playerOnline | `powerStatus.playerOnline == true` | Player must be online |
| currentPlanetComplete | `currentPlanet.currentOre == 0` | Current planet must be depleted (ore = 0) |
