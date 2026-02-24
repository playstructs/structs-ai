# StructType Entity Schema

**Version**: 1.1.0
**Category**: core
**Entity**: StructType
**Endpoint**: `/structs/struct_type/{id}`
**Last Updated**: 2026-01-16

---

## Properties

### Identity

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string (struct-type-id) | Yes | Struct type identifier (integer as string, e.g., `1`, `2`, `3`). Note: StructType IDs use regular integers, not `type-index` format. |
| type | string | Yes | Struct type name (e.g., `Command Ship`, `Miner`, `Reactor`) |
| class | string | Yes | Struct class identifier (e.g., `Command Ship`, `Miner`, `Reactor`). Used for cosmetic mod linking. |
| classAbbreviation | string | No | Abbreviated class name (e.g., `CMD Ship`) |
| category | string | Yes | Struct category. One of: `fleet`, `mining`, `refining`, `power`, `combat`, `defense`, `utility` |

### Cosmetics

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| defaultCosmeticModelNumber | string | No | Default cosmetic model number (e.g., `ST-21`) |
| defaultCosmeticName | string | No | Default cosmetic name (e.g., `Spearpoint`) |

### Build Properties

| Field | Type | Unit | Description |
|-------|------|------|-------------|
| buildLimit | string | | Maximum number of this struct type that can be built |
| buildDifficulty | string | | Proof-of-work difficulty for building |
| buildDraw | string | milliwatts | Power draw during building |
| buildCharge | string | | Charge cost to build struct |

### Combat Properties

| Field | Type | Description |
|-------|------|-------------|
| maxHealth | string | Maximum health points |

### Power Properties

| Field | Type | Unit | Description |
|-------|------|------|-------------|
| passiveDraw | string | milliwatts | Power draw when active |
| generatingRate | string | | Energy generation rate for generators (if applicable) |

### Placement Properties

| Field | Type | Description |
|-------|------|-------------|
| possibleAmbit | string | Possible operating ambit (space/air/land/water) -- bitmask |
| movable | boolean | Whether struct can be moved |
| slotBound | boolean | Whether struct is bound to a slot (planet/fleet) |

### Primary Weapon

| Field | Type | Description |
|-------|------|-------------|
| primaryWeapon | string | Primary weapon type (e.g., `guidedWeaponry`, `noActiveWeaponry`) |
| primaryWeaponControl | string | Primary weapon control type (e.g., `guided`) |
| primaryWeaponCharge | string | Charge cost for primary weapon |
| primaryWeaponAmbits | string | Primary weapon operating ambits -- bitmask |
| primaryWeaponTargets | string | Number of targets primary weapon can hit |
| primaryWeaponShots | string | Number of shots primary weapon can fire |
| primaryWeaponDamage | string | Primary weapon damage |
| primaryWeaponBlockable | boolean | Whether primary weapon damage can be blocked |
| primaryWeaponCounterable | boolean | Whether primary weapon can be countered |

### Secondary Weapon

| Field | Type | Description |
|-------|------|-------------|
| secondaryWeapon | string | Secondary weapon type (e.g., `noActiveWeaponry`) |

### Charge Costs

| Field | Type | Description |
|-------|------|-------------|
| activateCharge | string | Charge cost to activate struct. Genesis sets activateCharge = 1 for all struct types. |
| oreMiningCharge | string | Charge cost for ore mining (if applicable) |
| oreRefiningCharge | string | Charge cost for ore refining (if applicable) |
| oreMiningDifficulty | string | Proof-of-work difficulty for ore mining (if applicable) |
| oreRefiningDifficulty | string | Proof-of-work difficulty for ore refining (if applicable) |

### Stealth

| Field | Type | Description |
|-------|------|-------------|
| hasStealthSystem | boolean | Whether struct has stealth system capability |
| stealthActivateCharge | string | Charge cost to activate stealth (if applicable) |

## Relationships

| Relation | Entity | Schema |
|----------|--------|--------|
| instances | Struct | [struct.md](struct.md) |

## Verification

| Property | Value |
|----------|-------|
| Verified | Yes |
| Verified By | GameCodeAnalyst |
| Verified Date | 2025-01-XX |
| Method | code-analysis |
| Confidence | high |
| Code Reference | `proto/structs/structs/struct.proto:26`, `x/structs/types/struct.pb.go` |
| Database Reference | `structs.struct_type` table (80+ columns covering all struct properties: build, weapons, defenses, economics, charges, etc.) |

### Database Notes

- Columns include `cheatsheet_details` and `cheatsheet_extended_details` for UI display
- Deprecated charge columns for mine and refine have been removed

Cheatsheet details added for better struct type documentation. Deprecated charge columns removed from database.
