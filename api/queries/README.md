# Query Endpoints

**Version**: 1.0.0  
**Purpose**: Query endpoints split from `endpoints.md` for context window efficiency

---

## Overview

This directory contains query endpoints organized by entity type. This allows AI agents to load only the endpoints they need, reducing context window usage.

**Use Case**: Load specific entity query endpoints when working with that entity, instead of loading the entire `endpoints.md` (1153 lines).

---

## Available Query Files

### Core Entity Queries

- **`player.md`** - Player query endpoints (~50 lines)
- **`planet.md`** - Planet query endpoints (~60 lines)
- **`struct.md`** - Struct query endpoints (~40 lines)
- **`fleet.md`** - Fleet query endpoints (~50 lines)
- **`guild.md`** - Guild query endpoints (~40 lines)

### Resource Entity Queries

- **`reactor.md`** - Reactor query endpoints (~40 lines) ✅
- **`substation.md`** - Substation query endpoints (~40 lines) ✅

### Economic Entity Queries

- **`provider.md`** - Provider query endpoints (~40 lines) ✅
- **`agreement.md`** - Agreement query endpoints (~60 lines) ✅
- **`allocation.md`** - Allocation query endpoints (~70 lines) ✅

### System Queries

- **`system.md`** - System queries (block-height, params, etc.) (~50 lines) ✅

### Other Queries

- **`address.md`** - Address query endpoints (~50 lines) ✅
- **`permission.md`** - Permission query endpoints (~70 lines) ✅

---

## Context Window Savings

### Before (Loading endpoints.md)

**To get Player endpoints**:
- Load: `api/endpoints.md` (1153 lines)
- Contains: All query, transaction, and webapp endpoints
- **Waste**: ~1100 lines of unused endpoints

### After (Loading entity query file)

**To get Player endpoints**:
- Load: `api/queries/player.md` (~50 lines)
- Contains: Only Player query endpoints
- **Savings**: 96% reduction (1100 lines saved)

---

## Usage

### Loading Entity Queries

```json
{
  "load": "api/queries/player.md"
}
```

### Loading Multiple Entities

```json
{
  "load": [
    "api/queries/player.md",
    "api/queries/planet.md"
  ]
}
```

---

## Related Documentation

- **Main Endpoints**: `../endpoints.md` - Complete endpoint catalog (index)
- **Transactions**: `../transactions/` - Transaction endpoints
- **Webapp**: `../webapp/` - Webapp API endpoints (if split)
- **Loading Strategy**: `../../LOADING_STRATEGY.md` - How to load efficiently

---

*Last Updated: January 2025*
