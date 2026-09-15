---
title: Entity schemas split one file per type
description: Individual entity schemas split into one file each, so an agent can load a single definition rather than the whole catalog.
permalink: /schemas/entities/
redirect_from:
  - /schemas/entities/README
  - /schemas/entities/README.html
---

# Entity schemas split one file per type

**Purpose**: Individual entity schema files extracted from `game-state.md` for context window efficiency.

**Use Case**: Load specific entity schemas when you need complete entity data, instead of loading the entire `game-state.md` (698 lines).

---

## Available Entity Schemas

### Core Entities

- [player.md](player.md) — Player
- [planet.md](planet.md) — Planet
- [struct.md](struct.md) — Struct
- [fleet.md](fleet.md) — Fleet
- [struct-type.md](struct-type.md) — StructType
- [guild.md](guild.md) — Guild
- [address.md](address.md) — Address (type code 8)
- [permission.md](permission.md) — Permission and guild-rank records

### Resource Entities

- [reactor.md](reactor.md) — Reactor
- [substation.md](substation.md) — Substation

### Economic Entities

- [provider.md](provider.md) — Provider
- [agreement.md](agreement.md) — Agreement
- [allocation.md](allocation.md) — Allocation
- [infusion.md](infusion.md) — Infusion (type code 7)

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
- Contains: Combined entity dump
- **Waste**: unused types when you only needed one

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

Split files are the preferred load. `game-state.md` remains a combined dump.

---

## Best Practices

1. ✅ **Start with minimal** - Use minimal schemas for simple operations
2. ✅ **Upgrade to entity** - Load entity schema when you need complete data
3. ✅ **Load only what you need** - Don't load all entity schemas at once
4. ✅ **Cache entity schemas** - They rarely change, safe to cache

---

## Verification Status

Split pages exist for player, planet, struct, fleet, struct-type, guild, reactor, substation, provider, agreement, allocation, infusion, permission, and address. Prefer these over `game-state.md`. Cross-check live LCD against [api/queries/](../../api/queries/).

**Note**: These schemas represent API response structures. For code-based field definitions with formulas and calculated fields, see `schemas/entities.md#/definitions/`.

---

*Last Updated: September 15, 2026*
