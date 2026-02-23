# Structs Code Structures

**Version**: 1.0.0
**Category**: code
**Verified**: yes (high confidence)
**Description**: Verified code structures, data types, and patterns for AI agents

---

## Verification

| Property | Value |
|----------|-------|
| Verified by | GameCodeAnalyst |
| Verified date | 2025-01 |
| Method | code-analysis |
| Confidence | high |

**Repository**: `structsd` at `ProductManagement/GameCodeAnalyst/repositories/structsd` (branch: main)

---

## PlayerCache

**Type**: struct
**File**: `x/structs/keeper/player_cache.go`

Player cache structure for game state management.

### Fields

| Field | Type | Unit | Description |
|-------|------|------|-------------|
| Capacity | uint64 | milliwatts | Primary power capacity |
| CapacitySecondary | uint64 | milliwatts | Secondary power capacity |
| Load | uint64 | milliwatts | Current power load |
| StructsLoad | uint64 | milliwatts | Load from structs |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| GetAvailableCapacity | uint64 | Calculate available power capacity. Formula: `(Capacity + CapacitySecondary) - (Load + StructsLoad)`. Unit: milliwatts. |
| GetAllocatableCapacity | uint64 | Calculate allocatable capacity (primary only). Formula: `Capacity - Load`. Unit: milliwatts. |
| CanSupportLoadAddition | bool | Check if player can support additional load. |
| StoredOreIncrement | void | Increment stored ore by 1 (fixed increment per operation). |
| StoredOreDecrement | void | Decrement stored ore by 1. |
| DepositRefinedAlpha | void | Deposit refined Alpha Matter (mints 1,000,000 ualpha = 1 gram). |

---

## StructCache

**Type**: struct
**File**: `x/structs/keeper/struct_cache.go`

Struct cache structure for struct state management.

### Methods

| Method | Returns | Description | Code Reference |
|--------|---------|-------------|----------------|
| TakeAttackDamage | void | Calculate and apply attack damage (multi-shot system with damage reduction) | `struct_cache.go:956-1015` |
| CanEvade | bool | Check if struct can evade attack (guided vs unguided weapon evasion) | `struct_cache.go:911-954` |
| TakeRecoilDamage | void | Apply recoil damage to attacker | `struct_cache.go:1018-1043` |
| TakePostDestructionDamage | void | Apply post-destruction damage | `struct_cache.go:1045-1070` |
| CanBlock | bool | Check if defender can block attack (defender blocking with ambit check) | `struct_cache.go:1072-1105` |
| TakeCounterAttackDamage | void | Apply counter-attack damage (same-ambit vs different-ambit damage) | `struct_cache.go:1107-1135` |
| IsSuccessful | bool | Check if action succeeds based on success rate (random value from block hash and player nonce) | `struct_cache.go:1167-1185` |
| GoOnline | void | Activate struct (bring online) | `struct_cache.go` |
| GoOffline | void | Deactivate struct (take offline) | `struct_cache.go` |

### GoOnline Effects

- Increments StructsLoad
- Resets mining/refining timers
- Increments planetary defenses
- Sets StatusAddOnline()

### GoOffline Effects

- Decrements StructsLoad
- Clears timers
- Decrements planetary defenses
- Sets StatusRemoveOnline()

---

## FleetCache

**Type**: struct
**File**: `x/structs/keeper/fleet_cache.go`

Fleet cache structure for fleet state management.

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| PlanetMoveReadinessCheck | error | Check if fleet is ready to move to planet |

**PlanetMoveReadinessCheck** validates:

1. Owner is online (not offline)
2. Fleet has command struct
3. Command struct is online

---

## PlanetCache

**Type**: struct
**File**: `x/structs/keeper/planet_cache.go`

Planet cache structure for planet state management.

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| AttemptComplete | void | Attempt to complete planet (when ore is depleted) |
| IsEmptyOfOre | bool | Check if planet has no ore remaining |

**AttemptComplete** conditions:

1. Planet is empty of ore (IsEmptyOfOre())
2. Sets status to complete
3. Destroys structs
4. Sends fleets away

---

## Player

**Type**: struct
**File**: `x/structs/keeper/player.go`

Player structure for player state management.

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| GetPlayerCharge | uint64 | Get player's current charge. Formula: `charge = CurrentBlockHeight - LastActionBlock` |
| DischargePlayer | void | Discharge player (update last action block) |
| AttemptPlanetExplore | void | Attempt to explore new planet |

**AttemptPlanetExplore** effects:

1. Creates new planet
2. Sets planet as player's planet
3. Initializes PlanetStartingOre = 5

---

## Work (Package)

**Type**: package
**File**: `x/structs/types/work.go`

Proof-of-work functions.

### Functions

#### HashBuildAndCheckDifficulty

```go
func HashBuildAndCheckDifficulty(input string, proof string, age uint64, difficultyRange uint64) bool
```

Check if proof-of-work hash meets difficulty requirement.

**Used by**: Struct building, Ore mining, Ore refining, Planet raids

---

## Keys (Package)

**Type**: package
**File**: `x/structs/types/keys.go`

Key constants and values.

### Constants

| Constant | Value | Type | Unit | Description | Code Reference |
|----------|-------|------|------|-------------|----------------|
| ReactorFuelToEnergyConversion | 1 | uint64 | -- | Reactor conversion rate: 1 gram alpha = 1,000 watts | `keys.go:88` |
| PlayerPassiveDraw | 25000 | uint64 | milliwatts | Base power consumption for player when online | `keys.go:129` |
| PlanetStartingOre | 5 | uint64 | ore | Initial ore amount for all planets | `keys.go` |

---

## StructType

**Type**: struct
**File**: `genesis_struct_type.go`

Struct type definitions with properties.

### Fields

| Field | Type | Unit | Description | Known Values |
|-------|------|------|-------------|--------------|
| BuildDifficulty | uint64 | -- | Proof-of-work difficulty for building | -- |
| BuildDraw | uint64 | milliwatts | Power draw during building | -- |
| PassiveDraw | uint64 | milliwatts | Power draw when active | -- |
| OreMiningDifficulty | uint64 | -- | Proof-of-work difficulty for ore mining | 14000 |
| OreRefiningDifficulty | uint64 | -- | Proof-of-work difficulty for ore refining | 28000 |
| GeneratingRate | uint64 | -- | Energy generation rate for generators | Field Generator: 2, Continental Power Plant: 5, World Engine: 10 |
| ActivateCharge | uint64 | -- | Charge cost to activate struct | -- |
| BuildCharge | uint64 | -- | Charge cost to build struct | -- |
| OreMiningCharge | uint64 | -- | Charge cost for ore mining | -- |
| OreRefiningCharge | uint64 | -- | Charge cost for ore refining | -- |
| StealthActivateCharge | uint64 | -- | Charge cost to activate stealth | -- |

---

## Data Flows

### Struct Building Flow

Complete struct building flow.

**Step 1 -- MsgStructBuildInitiate**
- Handler: `msg_server_struct_build_initiate.go:18-88`
- State change: Struct status = building
- Requirements: Player online, sufficient resources, valid location

**Step 2 -- MsgStructBuildComplete**
- Handler: `msg_server_struct_build_complete.go:11-85`
- State change: Struct status = built
- Requirements: Player online, struct in building state, proof-of-work (HashBuildAndCheckDifficulty), sufficient charge

**Code references**: initiate (`x/structs/keeper/msg_server_struct_build_initiate.go:18-88`), complete (`x/structs/keeper/msg_server_struct_build_complete.go:11-85`), proof-of-work (`x/structs/types/work.go`)

### Resource Extraction Flow

Complete resource extraction flow (mining then refining).

**Step 1 -- MsgStructOreMinerComplete**
- Handler: `msg_server_struct_ore_miner_complete.go`
- State change: StoredOreIncrement(1)
- Requirements: Player online, struct online, sufficient charge (OreMiningCharge), proof-of-work (OreMiningDifficulty: 14000)

**Step 2 -- MsgStructOreRefineryComplete**
- Handler: `msg_server_struct_ore_refinery_complete.go`
- State change: DepositRefinedAlpha (mints 1,000,000 ualpha)
- Requirements: Player online, struct online, stored ore available, sufficient charge (OreRefiningCharge), proof-of-work (OreRefiningDifficulty: 28000)

**Code references**: mining (`x/structs/keeper/msg_server_struct_ore_miner_complete.go`), refining (`x/structs/keeper/msg_server_struct_ore_refinery_complete.go`), proof-of-work (`x/structs/types/work.go`)

### Power Management Flow

Power capacity and load management.

1. **Query**: Get player via `GET /structs/player/{id}` -- extract Capacity, CapacitySecondary, Load, StructsLoad
2. **Calculate**: GetAvailableCapacity = `(Capacity + CapacitySecondary) - (Load + StructsLoad)` (code: `x/structs/keeper/player_cache.go`)
3. **Check**: CanSupportLoadAddition (code: `x/structs/keeper/player_cache.go`)

**Code references**: capacity (`x/structs/keeper/player_cache.go` GetAvailableCapacity), allocatable (`x/structs/keeper/player_cache.go` GetAllocatableCapacity)
