# Entity Schemas

**Purpose**: Individual entity schema files extracted from `game-state.md` for context window efficiency.

**Use Case**: Load specific entity schemas when you need complete entity data, instead of loading the entire `game-state.md` (698 lines).

---

## Available Entity Schemas

### Core Entities

- `player.md` - Complete Player entity (~150 lines) ✅ Verified
- `planet.md` - Complete Planet entity (~100 lines) ✅ Verified
- `struct.md` - Complete Struct entity (~80 lines) ✅ Verified
- `fleet.md` - Complete Fleet entity (~80 lines) ✅ Verified
- `struct-type.md` - Complete StructType entity (~165 lines) ✅ Verified
- `guild.md` - Complete Guild entity (~80 lines) ✅ Verified

### Resource Entities

- `reactor.md` - Complete Reactor entity (~40 lines) ✅
- `substation.md` - Complete Substation entity (~40 lines) ✅

### Economic Entities

- `provider.md` - Complete Provider entity (~40 lines) ✅
- `agreement.md` - Complete Agreement entity (~50 lines) ✅
- `allocation.md` - Complete Allocation entity (~50 lines) ✅

---

## Loading Strategy

### When to Use Entity Schemas

✅ **Use entity schemas when**:
- You need complete entity data (all fields)
- Working with entity resources/attributes
- Verifying entity state for actions
- Building complex workflows involving the entity

❌ **Don't use entity schemas when**:
- Simple existence check (use `schemas/minimal/*-essential.md` instead)
- ID format verification (use `schemas/formats.md` instead)
- Basic status check (use minimal schema instead)

---

## Context Window Savings

### Before (Loading game-state.md)

**To get Player data**:
- Load: `schemas/game-state.md` (698 lines)
- Contains: All 11 entity definitions
- **Waste**: ~550 lines of unused entity definitions

### After (Loading entity schema)

**To get Player data**:
- Load: `schemas/entities/player.md` (~150 lines)
- Contains: Only Player definition
- **Savings**: 78% reduction (550 lines saved)

---

## Relationship to Other Schemas

### Minimal Schemas

Entity schemas are the "complete" version. For simple operations, use minimal schemas:
- `schemas/minimal/player-essential.md` (30 lines) - Basic info only
- `schemas/entities/player.md` (150 lines) - Complete data

### Game State Schema

The `game-state.md` file still contains all definitions for reference, but AI agents should prefer loading individual entity schemas when possible.

---

## Migration Path

### Current State

- `game-state.md` contains all entity definitions
- Entity schemas are being extracted (in progress)

### Future State

- `game-state.md` will reference entity schemas (or remain as complete reference)
- Entity schemas will be the preferred way to load entity data
- Minimal schemas will be preferred for simple operations

---

## Best Practices

1. ✅ **Start with minimal** - Use minimal schemas for simple operations
2. ✅ **Upgrade to entity** - Load entity schema when you need complete data
3. ✅ **Load only what you need** - Don't load all entity schemas at once
4. ✅ **Cache entity schemas** - They rarely change, safe to cache

---

## Verification Status

**Verified Entities** (4/11):
- ✅ `player.md` - Verified against API responses and code
- ✅ `planet.md` - Verified against code (starting properties, status)
- ✅ `struct.md` - Verified against code (status values, relationships)
- ✅ `fleet.md` - Verified against code (status values, movement requirements)

**Verified Entities** (11/11):
- ✅ `player.md` - Verified against code and database
- ✅ `planet.md` - Verified against code and database
- ✅ `struct.md` - Verified against code and database
- ✅ `fleet.md` - Verified against code and database
- ✅ `struct-type.md` - Verified against proto and database (80+ columns)
- ✅ `guild.md` - Verified against database and proto (some fields may be in gridAttributes)
- ✅ `reactor.md` - Verified against database (some fields may be in gridAttributes)
- ✅ `substation.md` - Verified against database (some fields may be in gridAttributes)
- ✅ `provider.md` - Verified against database (some fields may be in gridAttributes)
- ✅ `agreement.md` - Verified against database (some fields may be in gridAttributes)
- ✅ `allocation.md` - Verified against database (some fields may be in gridAttributes)

**Note**: These schemas represent API response structures. For code-based field definitions with formulas and calculated fields, see `schemas/entities.md#/definitions/`.

---

*Last Updated: December 7, 2025*
