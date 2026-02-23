# Structs Formula Definitions

**Version**: 1.0.0
**Category**: formulas
**Verified**: yes (all formulas verified against codebase)
**Description**: Complete catalog of all verified game formulas for AI agents

---

## Verification Status

| Metric | Value |
|--------|-------|
| Total formulas | 20 |
| Verified | 20 |
| Percentage | 100% |

---

## Battle Formulas

### Damage Calculation (Multi-Shot System)

**ID**: `damage-calculation`
**Code reference**: `x/structs/keeper/struct_cache.go:956-1015` (TakeAttackDamage)

Calculates damage from multi-shot weapon systems.

```
damage = sum(successful_shots) - damageReduction
if damage >= health then health = 0
else health = health - damage
```

**Algorithm**:

1. Initialize damage = 0
2. For each shot in weaponShots:
   - If IsSuccessful(weaponShotSuccessRate): damage += weaponDamage
3. If damage > 0:
   - If damageReduction > damage: damage = 0
   - Else: damage = damage - damageReduction
4. If damage >= health: health = 0
5. Else: health = health - damage

| Variable | Type | Description |
|----------|------|-------------|
| weaponShots | integer | Number of shots fired by weapon |
| weaponShotSuccessRate | object | Success rate for each shot (Numerator/Denominator) |
| weaponDamage | integer | Damage per successful shot |
| damageReduction | integer | Damage reduction from defenses |
| health | integer | Current health of target |

### Evasion Calculation

**ID**: `evasion-calculation`
**Code reference**: `x/structs/keeper/struct_cache.go:911-954` (CanEvade)

Determines if target can evade attack based on weapon type.

```
if weaponControl == guided then
  successRate = guidedDefensiveSuccessRate
else
  successRate = unguidedDefensiveSuccessRate

canEvade = IsSuccessful(successRate) if successRate.Numerator != 0
```

| Variable | Type | Description |
|----------|------|-------------|
| weaponControl | enum: `guided`, `unguided` | Weapon control type |
| guidedDefensiveSuccessRate | object | Success rate against guided weapons (Numerator/Denominator) |
| unguidedDefensiveSuccessRate | object | Success rate against unguided weapons (Numerator/Denominator) |

### Recoil Damage

**ID**: `recoil-damage`
**Code reference**: `x/structs/keeper/struct_cache.go:1018-1043` (TakeRecoilDamage)

Damage taken by attacker from weapon recoil.

```
damage = weaponRecoilDamage
if damage > health then health = 0
else health = health - damage
```

| Variable | Type | Description |
|----------|------|-------------|
| weaponRecoilDamage | integer | Recoil damage from weapon |
| health | integer | Current health of attacker |

### Post-Destruction Damage

**ID**: `post-destruction-damage`
**Code reference**: `x/structs/keeper/struct_cache.go:1045-1070` (TakePostDestructionDamage)

Damage applied after struct is destroyed.

```
if health == 0 and postDestructionDamage > 0 then
  apply postDestructionDamage to surrounding structs
```

| Variable | Type | Description |
|----------|------|-------------|
| health | integer | Current health (0 = destroyed) |
| postDestructionDamage | integer | Damage to apply after destruction |

### Blocking Calculation

**ID**: `blocking-calculation`
**Code reference**: `x/structs/keeper/struct_cache.go:1072-1105` (CanBlock)

Determines if defender blocks attack.

```
if defender exists and defender.operatingAmbit == attacker.operatingAmbit then
  canBlock = IsSuccessful(defender.blockingSuccessRate)
```

| Variable | Type | Description |
|----------|------|-------------|
| defender | object | Defender struct assigned to protect target |
| attacker | object | Attacking struct |
| blockingSuccessRate | object | Success rate for blocking (Numerator/Denominator) |

### Counter-Attack Damage

**ID**: `counter-attack-damage`
**Code reference**: `x/structs/keeper/struct_cache.go:1107-1135` (TakeCounterAttackDamage)

Damage from counter-attack after blocking.

```
if blocked and defender.operatingAmbit == attacker.operatingAmbit then
  counterDamage = defender.counterAttackDamage
else
  counterDamage = defender.counterAttackDamage / 2
```

| Variable | Type | Description |
|----------|------|-------------|
| blocked | boolean | Whether attack was blocked |
| defender | object | Defender struct |
| attacker | object | Attacking struct |
| counterAttackDamage | integer | Counter-attack damage from defender |

### Planetary Defense Cannon Damage

**ID**: `planetary-defense-cannon-damage`
**Code reference**: `x/structs/keeper/struct_cache.go:1137-1165` (TakePlanetaryDefenseCannonDamage)

Damage from planetary defense cannons when planet is attacked.

```
damage = planetaryShieldBase + sum(defenseCannon.damage for each defense cannon on planet)
```

| Variable | Type | Description |
|----------|------|-------------|
| planetaryShieldBase | integer | Base planetary shield damage |
| defenseCannons | array | List of defense cannons on planet |

### Success Rate Probability (IsSuccessful)

**ID**: `success-rate-probability`
**Code reference**: `x/structs/keeper/struct_cache.go:1167-1185` (IsSuccessful)

Determines if action succeeds based on success rate and randomness.

```
randomValue = hash(blockHash, playerNonce) % successRate.Denominator
isSuccessful = randomValue < successRate.Numerator
```

| Variable | Type | Description |
|----------|------|-------------|
| successRate | object | Success rate (Numerator/Denominator) |
| blockHash | string | Current block hash |
| playerNonce | string | Player nonce for randomness |

---

## Economic Formulas

### Reactor Energy Production

**ID**: `reactor-energy-production`
**Code reference**: `x/structs/types/keys.go:88` (ReactorFuelToEnergyConversion = 1)

Energy output from reactor based on Alpha Matter input.

```
Energy Output (milliwatts) = Alpha Matter Input (micrograms) x 1
```

| Unit | Description |
|------|-------------|
| Input | micrograms (1 gram = 1,000,000 micrograms) |
| Output | milliwatts (1 watt = 1,000 milliwatts) |
| Rate | 1 |

**Example**: 1 gram of alpha (1,000,000 micrograms) = 1,000 watts of energy (1,000,000 milliwatts)

### Generator Energy Production

**ID**: `generator-energy-production`
**Code reference**: `genesis_struct_type.go` (GeneratingRate: 2, 5, 10)

Energy output from generators (multiple types with different rates).

```
Energy Output = Base Energy x GeneratingRate
```

| Generator | Rate | Description |
|-----------|------|-------------|
| Field Generator | 2 | Energy output = Base Energy x 2 |
| Continental Power Plant | 5 | Energy output = Base Energy x 5 |
| World Engine | 10 | Energy output = Base Energy x 10 |

### Player Passive Draw

**ID**: `player-passive-draw`
**Code reference**: `x/structs/types/keys.go:129` (PlayerPassiveDraw = 25000)

Base power consumption for player when online.

```
Passive Draw = 25,000 milliwatts (25 watts)
```

---

## Struct Building Formulas

### Charge Accumulation

**ID**: `charge-accumulation`
**Code reference**: `x/structs/keeper/player.go` (GetPlayerCharge)

Charge accumulates over time based on blocks since last action.

```
charge = CurrentBlockHeight - LastActionBlock
```

| Variable | Type | Description |
|----------|------|-------------|
| charge | integer | Current charge value |
| CurrentBlockHeight | integer | Current blockchain block height |
| LastActionBlock | integer | Block height of last action |

### Power Capacity Calculation

**ID**: `power-capacity`
**Code reference**: `x/structs/keeper/player_cache.go` (GetAvailableCapacity)

Available power capacity for player.

```
availableCapacity = (Capacity + CapacitySecondary) - (Load + StructsLoad)
```

| Variable | Type | Unit | Description |
|----------|------|------|-------------|
| availableCapacity | integer | milliwatts | Available power capacity |
| Capacity | integer | milliwatts | Primary capacity |
| CapacitySecondary | integer | milliwatts | Secondary capacity |
| Load | integer | milliwatts | Current load |
| StructsLoad | integer | milliwatts | Load from structs |

### Allocatable Capacity Calculation

**ID**: `allocatable-capacity`
**Code reference**: `x/structs/keeper/player_cache.go` (GetAllocatableCapacity)

Capacity available for allocation (primary capacity only).

```
allocatableCapacity = Capacity - Load
```

| Variable | Type | Unit | Description |
|----------|------|------|-------------|
| allocatableCapacity | integer | milliwatts | Allocatable capacity |
| Capacity | integer | milliwatts | Primary capacity |
| Load | integer | milliwatts | Current load |

### Build Difficulty (Proof-of-Work)

**ID**: `build-difficulty`
**Code reference**: `x/structs/types/work.go:49-62` (CalculateDifficulty), `x/structs/types/work.go` (HashBuildAndCheckDifficulty)

Age-based proof-of-work difficulty for struct building using dynamic difficulty.

```
age = currentBlockHeight - blockStart
if age <= 1 then
  difficulty = 64
else
  difficulty = 64 - floor(log10(age) / log10(BuildDifficulty) * 63)

hashInput = structId + "BUILD" + blockStart + "NONCE" + nonce
isValid = HashBuildAndCheckDifficulty(hashInput, proof, age, BuildDifficulty)
```

| Variable | Type | Description |
|----------|------|-------------|
| BuildDifficulty | integer | Base difficulty range for struct type (difficultyRange in code) |
| currentBlockHeight | integer | Current blockchain block height |
| blockStart | integer | Block height when build operation started |
| age | integer | Blocks since build operation started |
| nonce | string | Proof-of-work nonce |
| proof | string | Proof-of-work hash |

---

## Resource Formulas

### Ore Mining Difficulty

**ID**: `ore-mining-difficulty`
**Code reference**: `genesis_struct_type.go` (OreMiningDifficulty: 14000), `x/structs/types/work.go:49-62` (CalculateDifficulty)

Dynamic proof-of-work difficulty for ore mining based on age. Difficulty value: **14000**.

```
age = currentBlockHeight - blockStart
if age <= 1 then
  difficulty = 64
else
  difficulty = 64 - floor(log10(age) / log10(14000) * 63)

hashInput = structId + "MINE" + blockStart + "NONCE" + nonce
isValid = HashBuildAndCheckDifficulty(hashInput, proof, age, 14000)
```

### Ore Refining Difficulty

**ID**: `ore-refining-difficulty`
**Code reference**: `genesis_struct_type.go` (OreRefiningDifficulty: 28000), `x/structs/types/work.go:49-62` (CalculateDifficulty)

Dynamic proof-of-work difficulty for ore refining based on age. Difficulty value: **28000**.

```
age = currentBlockHeight - blockStart
if age <= 1 then
  difficulty = 64
else
  difficulty = 64 - floor(log10(age) / log10(28000) * 63)

hashInput = structId + "REFINE" + blockStart + "NONCE" + nonce
isValid = HashBuildAndCheckDifficulty(hashInput, proof, age, 28000)
```

### Ore Extraction Rate

**ID**: `ore-extraction-rate`
**Code reference**: `x/structs/keeper/msg_server_struct_ore_miner_complete.go` (StoredOreIncrement(1))

Fixed extraction rate: 1 ore per mining operation.

```
oreExtracted = 1 (fixed per operation)
```

> Fixed rate, not variable based on planet characteristics.

### Ore to Alpha Matter Conversion

**ID**: `ore-refining-conversion`
**Code reference**: `x/structs/keeper/msg_server_struct_ore_refinery_complete.go` (DepositRefinedAlpha mints 1,000,000 ualpha)

Conversion rate: 1 ore = 1 Alpha Matter (1,000,000 micrograms).

```
alphaMatter = 1,000,000 micrograms per ore
```

| Direction | Unit | Amount |
|-----------|------|--------|
| Input | ore | 1 |
| Output | micrograms | 1,000,000 (equivalent: 1 gram) |

### Planet Starting Ore

**ID**: `planet-starting-ore`
**Code reference**: `x/structs/types/keys.go` (PlanetStartingOre = 5)

Initial ore amount for all planets.

```
startingOre = 5 (fixed for all planets)
```

---

## Formula Categories

| Category | Formulas |
|----------|----------|
| Battle | damage-calculation, evasion-calculation, recoil-damage, post-destruction-damage, blocking-calculation, counter-attack-damage, planetary-defense-cannon-damage, success-rate-probability |
| Economic | reactor-energy-production, generator-energy-production, player-passive-draw |
| Struct Building | charge-accumulation, power-capacity, allocatable-capacity, build-difficulty |
| Resource | ore-mining-difficulty, ore-refining-difficulty, ore-extraction-rate, ore-refining-conversion, planet-starting-ore |
