# Structs Economic Entity Definitions

**Version**: 1.1.0
**Category**: economic
**Description**: Complete catalog of economic entities and resources for AI agents. See `schemas/formats.md` for format specifications.

---

## Alpha Ore

| Property | Value |
|----------|-------|
| ID | `alpha-ore` |
| Category | economic |
| Unit | grams |
| Blockchain unit | micrograms (uAlpha) |
| Stealable | yes |
| Refinement required | yes |
| Refines to | Alpha Matter |

Raw material mined from planets. Once mined and held in a player's inventory (`storedOre`), it can be stolen by raiders. Unmined ore on planets (`remainingOre`) is not stealable. Must be refined to Alpha Matter before secure use.

### Conversion

1 gram Alpha Ore = 1 gram Alpha Matter (after refinement)

### Properties

| Field | Type | Description | Default |
|-------|------|-------------|---------|
| amount | number | Amount in grams (min: 0) | -- |
| location | string (entity-id) | Where the ore is located (planet ID, player inventory, etc.) | -- |
| stealable | boolean | Whether this ore can be stolen | `true` |

---

## Alpha Matter

| Property | Value |
|----------|-------|
| ID | `alpha-matter` |
| Category | economic |
| Unit | grams |
| Blockchain unit | micrograms (uAlpha) |
| Stealable | no |
| Refined from | Alpha Ore |

Refined Alpha Ore. Cannot be stolen. Used for energy production, trading, and guild token collateral.

### Standard

- 1 Alpha = 1 gram of Alpha Matter
- 1 gram = 1,000,000 micrograms (blockchain precision)

### Uses

- Energy production
- Trading
- Guild token collateral
- Marketplace

### Properties

| Field | Type | Format/Pattern | Description | Default |
|-------|------|----------------|-------------|---------|
| amount | number | -- | Amount in grams (min: 0) | -- |
| owner | string | entity-id `^1-[0-9]+$` | Owner player ID (Type 1 = Player) | -- |
| locked | boolean | -- | Whether this Alpha Matter is locked (e.g., as collateral) | `false` |
| lockedFor | string | enum: `guild-token`, `agreement`, `other` | What this Alpha Matter is locked for | -- |

### Energy Conversion Rates

| Facility | Rate | Formula |
|----------|------|---------|
| Reactor | 1 kW/g | 1 gram Alpha Matter = 1 kW energy |
| Field Generator | 2 kW/g | 1 gram Alpha Matter = 2 kW energy |
| Continental Power Plant | 5 kW/g | 1 gram Alpha Matter = 5 kW energy |
| World Engine | 10 kW/g | 1 gram Alpha Matter = 10 kW energy |

---

## Energy

| Property | Value |
|----------|-------|
| ID | `energy` |
| Category | economic |
| Unit | kilowatts (kW) |
| Ephemeral | yes |
| Shared | yes |

Energy measured in Watts (kilowatts). Ephemeral -- must be consumed immediately upon production. Shared across connected Structs.

### Properties

| Field | Type | Format/Pattern | Description | Default |
|-------|------|----------------|-------------|---------|
| amount | number | -- | Amount in kilowatts (min: 0) | -- |
| source | string | entity-id | Source of energy (reactor ID, generator ID, agreement ID) | -- |
| consumed | boolean | -- | Whether this energy has been consumed | `false` |
| sharedWith | array | entity-id `^5-[0-9]+$` | List of Struct IDs that share this energy (Type 5 = Struct) | -- |

### Production from Alpha Matter

| Facility | Formula | Rate | Risk |
|----------|---------|------|------|
| Reactor | Energy (kW) = Alpha Matter (grams) x 1 | 1 | low |
| Field Generator | Energy (kW) = Alpha Matter (grams) x 2 | 2 | high |
| Continental Power Plant | Energy (kW) = Alpha Matter (grams) x 5 | 5 | high |
| World Engine | Energy (kW) = Alpha Matter (grams) x 10 | 10 | high |

---

## Reactor

| Property | Value |
|----------|-------|
| ID | `reactor` |
| Category | economic |
| Risk | low |
| Design intent | network stability |
| Endpoint | `/structs/reactor/{id}` |
| List endpoint | `/structs/reactor` |

Standard energy production facility. Converts Alpha Matter to energy at 1 kW per gram. Lower risk, designed for network stability. Supports validation delegation staking.

### Production Rate

```
Energy (kW) = Alpha Matter (grams) x 1
```

Input: Alpha Matter (grams) | Output: Energy (kW) | Rate: 1

### Staking

Reactor staking functionality with player-level management. Validation delegation is abstracted via Reactor Infuse/Defuse actions.

| Action | Description |
|--------|-------------|
| Infuse | Delegates validation stake via Reactor Infuse |
| Defuse | Undelegates validation stake via Reactor Defuse |
| Begin Migration | Begins redelegation process |
| Cancel Defusion | Cancels undelegation process |

**Delegation statuses**: active (actively delegated to validator), undelegating (in undelegation period), migrating (in migration/redelegation process)

### Properties

| Field | Type | Format/Pattern | Description |
|-------|------|----------------|-------------|
| id | string | entity-id `^3-[0-9]+$` | Reactor identifier (Type 3 = Reactor) |
| owner | string | entity-id `^1-[0-9]+$` | Player identifier (Type 1 = Player) |
| location | string | entity-id `^2-[0-9]+$` | Planet identifier (Type 2 = Planet) |
| active | boolean | -- | Whether the reactor is active |
| alphaMatterInput | number | -- | Alpha Matter input in grams (min: 0) |
| energyOutput | number | -- | Energy output in kW (min: 0) |

### Relationships

- Owned by: Player
- Located on: Planet
- Produces: Energy

---

## Generator

| Property | Value |
|----------|-------|
| ID | `generator` |
| Category | economic |
| Risk | high |
| Design intent | higher returns / inflation control |

High-yield energy production facility. Multiple types with different rates. Higher risk, designed for higher returns and inflation control.

### Generator Types

| Type | ID | Rate | Efficiency | Formula |
|------|----|------|------------|---------|
| Field Generator | `field-generator` | 2 | 200% of Reactor | Energy (kW) = Alpha Matter (grams) x 2 |
| Continental Power Plant | `continental-power-plant` | 5 | 500% of Reactor | Energy (kW) = Alpha Matter (grams) x 5 |
| World Engine | `world-engine` | 10 | 1000% of Reactor | Energy (kW) = Alpha Matter (grams) x 10 |

> Verified from code (January 2025). Previous documentation said "2 kW/g" for all generators, but code has 3 generator types with rates 2, 5, and 10.

### Properties

| Field | Type | Format/Pattern | Description |
|-------|------|----------------|-------------|
| id | string | entity-id `^[0-9]+-[0-9]+$` | Generator identifier (type codes vary by generator type) |
| type | string | enum: `fieldGenerator`, `continentalPowerPlant`, `worldEngine` | Generator type |
| owner | string | entity-id `^1-[0-9]+$` | Player identifier (Type 1 = Player) |
| location | string | entity-id `^2-[0-9]+$` | Planet identifier (Type 2 = Planet) |
| active | boolean | -- | Whether the generator is active |
| alphaMatterInput | number | -- | Alpha Matter input in grams (min: 0) |
| energyOutput | number | -- | Energy output in kW (min: 0) |

### Relationships

- Owned by: Player
- Located on: Planet
- Produces: Energy

---

## Guild Central Bank

| Property | Value |
|----------|-------|
| ID | `guild-central-bank` |
| Category | economic |
| Endpoint | `/structs/guild/{id}/bank` |
| Trust-based | yes |
| Technical safeguards | none |
| Minimum collateral | none |
| Max supply | none |
| Guild control | full |

Economic institution for minting guild tokens collateralized by Alpha Matter. Trust-based system with no technical safeguards.

> **Warning**: Guild tokens are trust-based. Guilds have full control. No technical safeguards against inflation or revocation. Reliance on reputation.

### Properties

| Field | Type | Format/Pattern | Description |
|-------|------|----------------|-------------|
| guildId | string | entity-id `^0-[0-9]+$` | Guild identifier (Type 0 = Guild) |
| collateral | number | -- | Locked Alpha Matter as collateral in grams (min: 0) |
| tokensIssued | number | -- | Total tokens issued (min: 0) |
| tokensInCirculation | number | -- | Tokens currently in circulation (min: 0) |
| collateralRatio | number | -- | Collateral ratio: Locked Alpha Matter / Total Tokens Issued (min: 0) |

### Operations

| Operation | Description | Notes |
|-----------|-------------|-------|
| Mint | Mint new guild tokens | Requires collateral |
| Revoke | Revoke and burn tokens | Enemy-held tokens can be revoked; results in tokens-burned |

---

## Energy Agreement

| Property | Value |
|----------|-------|
| ID | `energy-agreement` |
| Category | economic |
| Endpoint | `/structs/agreement/{id}` |
| Enforcement | automatic, on-chain |
| Self-enforcing | yes |
| Penalty protection | yes |

Self-enforcing, persistent energy subscription with automatic, on-chain penalty protections.

### Properties

| Field | Type | Format/Pattern | Description | Default |
|-------|------|----------------|-------------|---------|
| id | string | entity-id `^11-[0-9]+$` | Agreement identifier (Type 11 = Agreement) | -- |
| provider | string | entity-id `^10-[0-9]+$` | Provider identifier (Type 10 = Provider) | -- |
| consumer | string | entity-id `^1-[0-9]+$` | Player identifier (Type 1 = Player) | -- |
| energyAmount | number | -- | Energy amount in kW (min: 0) | -- |
| price | number | -- | Price per unit (min: 0) | -- |
| duration | number | -- | Agreement duration (min: 0) | -- |
| active | boolean | -- | Whether the agreement is active | -- |
| penaltyProtection | boolean | -- | Whether penalty protection is enabled | `true` |

### Relationships

- Provided by: Provider
- Consumed by: Player

---

## Formulas

### Alpha Matter to Energy Conversion

| Facility | Formula | Rate | Risk | Implementation Note |
|----------|---------|------|------|---------------------|
| Reactor | Energy (kW) = Alpha Matter (grams) x 1 | 1 | low | Deterministic -- conversion is guaranteed at specified rate |
| Field Generator | Energy (kW) = Alpha Matter (grams) x 2 | 2 | high | Current code is deterministic (verified January 2025). Risk may refer to strategic uncertainty or future implementation. |
| Continental Power Plant | Energy (kW) = Alpha Matter (grams) x 5 | 5 | high | Current code is deterministic (verified January 2025). Risk may refer to strategic uncertainty or future implementation. |
| World Engine | Energy (kW) = Alpha Matter (grams) x 10 | 10 | high | Current code is deterministic (verified January 2025). Risk may refer to strategic uncertainty or future implementation. |

**Code verification**: Verified 2025-01 by GameCodeAnalyst. Generator conversion is deterministic. Alpha Matter is burned and converted to energy at the specified rate. No risk calculation or probability of loss is implemented in current code. Code reference: `x/structs/keeper/msg_server_struct_generator_infuse.go`

### Energy Production Cost

| Facility | Formula |
|----------|---------|
| Reactor | Cost per kW = Alpha Matter Cost / 1 |
| Field Generator | Cost per kW = Alpha Matter Cost / 2 |
| Continental Power Plant | Cost per kW = Alpha Matter Cost / 5 |
| World Engine | Cost per kW = Alpha Matter Cost / 10 |

### Other Formulas

| Formula | Expression |
|---------|------------|
| Production Efficiency | Efficiency = (Energy Output / Alpha Matter Input) x 100% |
| Guild Token Collateral Ratio | Collateral Ratio = (Locked Alpha Matter / Total Tokens Issued) x 100% |
| Trading Profit | Profit = (Sell Price - Buy Price) x Quantity |
| Profit Margin | Profit Margin = ((Sell Price - Buy Price) / Buy Price) x 100% |

---

## Verification

| Property | Value |
|----------|-------|
| Date | 2025-01 |
| Source | code-verification |
| Notes | Generator rates verified from code. Previous documentation said "2 kW/g" for all generators, but code has 3 generator types with rates 2, 5, and 10. |
