# Cosmetic Mod Integration Protocol

**Version**: 1.0.0  
**Category**: Modding  
**Scope**: API Integration  
**Purpose**: Document how cosmetic mods integrate with the game system and API

---

## Overview

This protocol defines how cosmetic mods integrate with the Structs game system, specifically how cosmetic overrides are applied when querying struct types through the API.

**System Context**: This protocol covers the integration of cosmetics after they have been ingested into the system. Cosmetics are stored as **Sets** and **Skins** with hash-based identification. See [Cosmetic System Overview](../../technical/cosmetic-system-overview.md) for the complete architecture.

**Note**: During ingestion (Phase 2), cosmetic mods (Phase 1 format) are converted to Sets/Skins format with hash-based identification. This protocol covers the integration of Sets/Skins with the game system.

---

## Integration Architecture

### System Layers

```
┌─────────────────────────────────────┐
│   Game Client / UI                   │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│   Web Application API               │
│   (Cosmetic Mod Integration Layer)  │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│   Consensus Network API              │
│   (Base Struct Type Data)            │
└─────────────────────────────────────┘
```

### Data Flow

1. **Base Data Query**: Query struct type from consensus network
2. **Mod Resolution**: Resolve applicable cosmetic mods
3. **Data Merging**: Merge base data with cosmetic overrides
4. **Response**: Return merged data to client

---

## Integration Points

### 1. Struct Type Queries

**Consensus Network API** (`/structs/struct_type/{id}`):
- Returns base struct type data
- Includes default cosmetic fields (`defaultCosmeticName`, `defaultCosmeticModelNumber`)
- Game mechanics and capabilities

**Web Application API** (`/api/cosmetic/class/{class}`):
- Returns cosmetic skin overrides only
- Applies skin priority rules
- Localized text
- Uses `class` field to link to struct types

**Integration Endpoint** (`/api/struct-type/{id}/full?class={class}`):
- Combines base data + cosmetic skin overrides
- Returns complete struct type with skins applied
- **Use this for game UI display**
- `id`: Struct type ID (for base game data)
- `class`: Optional - struct type class (for cosmetic lookup)

### 2. Skin Priority Resolution

When multiple skins affect the same struct type class:

1. **Individual Skin** (highest priority)
   - Standalone skin (not part of a set)
   - Applied first

2. **Set Skin** (medium priority)
   - Skin that is part of an active set
   - Applied second

3. **Default game assets** (fallback)
   - Used when no skins override the field
   - Always available

**Note**: Skins are linked to struct types via the `class` field (e.g., "Miner", "Reactor"), not by struct type ID. The `class` field matches the on-chain struct type class name. Skins are identified by `skinHash` (SHA-256, 64-character hex), and sets are identified by `setHash`.

### 3. Field Merging Rules

**Text Fields** (names, lore, descriptions):
- Mod override replaces default if present
- Falls back to default if mod doesn't override

**Asset Fields** (animations, icons, graphics):
- Mod override replaces default path if present
- Falls back to default asset path if mod doesn't override

**Weapon/Ability Cosmetics**:
- Mod overrides are merged by weapon/ability ID
- Default values used for non-overridden weapons/abilities

---

## API Integration Patterns

### Pattern 1: Get Struct Type with Cosmetics

**Use Case**: Display struct type in game UI

**Workflow**:
1. Query base struct type from consensus network
2. Query cosmetic overrides from webapp API
3. Merge data client-side OR use integration endpoint

**Example**:
```json
{
  "workflow": "get-struct-type-with-cosmetics",
  "steps": [
    {
      "step": 1,
      "endpoint": "struct-type-by-id",
      "api": "consensus",
      "url": "/structs/struct_type/miner",
      "description": "Get base struct type data"
    },
    {
      "step": 2,
      "endpoint": "cosmetic-class",
      "api": "webapp",
      "url": "/api/cosmetic/class/Miner?language=en&guildId=0-1",
      "description": "Get cosmetic skin overrides for class 'Miner'"
    },
    {
      "step": 3,
      "action": "merge",
      "description": "Merge base data with cosmetic overrides"
    }
  ]
}
```

**OR use integration endpoint**:
```json
{
  "endpoint": "struct-type-with-cosmetics",
  "api": "webapp",
  "url": "/api/struct-type/1-11/full?class=Miner&language=en&guildId=0-1",
  "description": "Get complete struct type with cosmetics (single call). Uses struct type ID for base data and class for cosmetic lookup."
}
```

### Pattern 2: List Struct Types with Cosmetics

**Use Case**: Display struct type list in game UI

**Workflow**:
1. Query all struct types from consensus network
2. Query cosmetic overrides for all struct types
3. Merge data for each struct type

**Example**:
```json
{
  "workflow": "list-struct-types-with-cosmetics",
  "steps": [
    {
      "step": 1,
      "endpoint": "struct-type-list",
      "api": "consensus",
      "url": "/structs/struct_type"
    },
    {
      "step": 2,
      "endpoint": "cosmetic-struct-type-list",
      "api": "webapp",
      "url": "/api/cosmetic/struct-types?language=en&guildId=0-1"
    },
    {
      "step": 3,
      "action": "merge-all",
      "description": "Merge base data with cosmetic overrides for each struct type"
    }
  ]
}
```

### Pattern 3: Mod Installation and Activation

**Use Case**: Install and activate a cosmetic mod

**Workflow**:
1. Validate mod file
2. Install mod
3. Activate mod
4. Verify mod is active

**Example**:
```json
{
  "workflow": "install-cosmetic-mod",
  "steps": [
    {
      "step": 1,
      "endpoint": "cosmetic-mod-validate",
      "api": "webapp",
      "url": "/api/cosmetic-mods/validate",
      "method": "POST",
      "body": {
        "file": "path/to/mod.zip"
      }
    },
    {
      "step": 2,
      "endpoint": "cosmetic-mod-install",
      "api": "webapp",
      "url": "/api/cosmetic-mods/install",
      "method": "POST",
      "body": {
        "file": "path/to/mod.zip",
        "validate": true,
        "activate": true
      }
    },
    {
      "step": 3,
      "endpoint": "cosmetic-mod-get",
      "api": "webapp",
      "url": "/api/cosmetic-mods/{modId}",
      "description": "Verify mod is installed and active"
    }
  ]
}
```

---

## Data Merging Examples

### Example 1: Name Override

**Base Data** (from consensus network):
```json
{
  "id": "miner",
  "type": "Miner",
  "defaultCosmeticName": "Miner"
}
```

**Skin Override**:
```json
{
  "class": "Miner",
  "skinHash": "f1e2d3c4b5a6789012345678901234567890abcdef1234567890abcdef123456",
  "name": {
    "en": "Alpha Extractor"
  }
}
```

**Merged Result**:
```json
{
  "id": "miner",
  "type": "Miner",
  "defaultCosmeticName": "Miner",
  "cosmeticName": "Alpha Extractor"
}
```

### Example 2: Weapon Name Override

**Base Data**:
```json
{
  "id": "miner",
  "primaryWeapon": "drill"
}
```

**Skin Override**:
```json
{
  "class": "Miner",
  "skinHash": "f1e2d3c4b5a6789012345678901234567890abcdef1234567890abcdef123456",
  "weapons": [
    {
      "weaponType": "primary",
      "names": {
        "en": "Plasma Drill"
      }
    }
  ]
}
```

**Merged Result**:
```json
{
  "id": "miner",
  "primaryWeapon": "drill",
  "weaponCosmetics": {
    "primary": {
      "name": "Plasma Drill"
    }
  }
}
```

### Example 3: Animation Override

**Base Data**:
```json
{
  "id": "miner",
  "defaultAnimation": "/assets/animations/miner-idle.json"
}
```

**Skin Override**:
```json
{
  "class": "Miner",
  "skinHash": "f1e2d3c4b5a6789012345678901234567890abcdef1234567890abcdef123456",
  "animations": {
    "idle": "animations/miner-idle-custom.json"
  }
}
```

**Merged Result**:
```json
{
  "id": "miner",
  "defaultAnimation": "/assets/animations/miner-idle.json",
  "cosmeticAnimations": {
    "idle": "/mods/guild-alpha-miner-v1/animations/miner-idle-custom.json"
  }
}
```

---

## Localization Integration

### Language Resolution

1. **Request Language**: Client specifies language in API request
2. **Mod Language**: Mod provides text in requested language
3. **Fallback Chain**: `requested → en → default`

**Example**:
```json
{
  "request": {
    "language": "es"
  },
  "mod": {
    "names": {
      "en": "Alpha Extractor",
      "es": "Extractor Alpha"
    }
  },
  "result": "Extractor Alpha"  // Spanish from mod
}
```

**Fallback Example**:
```json
{
  "request": {
    "language": "fr"
  },
  "mod": {
    "names": {
      "en": "Alpha Extractor"
    }
  },
  "result": "Alpha Extractor"  // English fallback from mod
}
```

---

## Error Handling

### Skin Not Found

**Scenario**: Skin referenced in cosmetic data doesn't exist

**Response**:
```json
{
  "error": "COSMETIC_SKIN_NOT_FOUND",
  "message": "Skin with hash 'f1e2d3c4b5a6789012345678901234567890abcdef1234567890abcdef123456' not found",
  "skinHash": "f1e2d3c4b5a6789012345678901234567890abcdef1234567890abcdef123456",
  "fallback": "Using default game assets"
}
```

**Behavior**: System falls back to default game assets

### Invalid Skin Hash

**Scenario**: Skin hash is invalid or doesn't match content

**Response**:
```json
{
  "error": "COSMETIC_SKIN_INVALID_HASH",
  "message": "Skin hash validation failed",
  "details": {
    "skinHash": "f1e2d3c4b5a6789012345678901234567890abcdef1234567890abcdef123456",
    "issue": "Hash mismatch: calculated hash does not match provided hash"
  }
}
```

**Behavior**: Skin is not loaded, system uses default assets

### Class Not Found

**Scenario**: Skin references struct type class that doesn't exist

**Response**:
```json
{
  "error": "STRUCT_TYPE_CLASS_NOT_FOUND",
  "message": "Struct type class 'InvalidClass' not found in game",
  "class": "InvalidClass",
  "skinHash": "f1e2d3c4b5a6789012345678901234567890abcdef1234567890abcdef123456"
}
```

**Behavior**: Skin override for that class is ignored

---

## Performance Considerations

### Caching

**Recommendation**: Cache merged struct type data

**Cache Key**: `struct-type-{id}-{language}-{guildId}`

**TTL**: 
- Static mods: Long TTL (1 hour)
- Active mods: Short TTL (5 minutes)

### Batch Queries

**Recommendation**: Use batch endpoints when querying multiple struct types

**Example**:
```json
{
  "endpoint": "/api/cosmetic/struct-types",
  "description": "Get cosmetics for all struct types in one call"
}
```

### Lazy Loading

**Recommendation**: Load cosmetic data only when needed

**Pattern**:
1. Load base struct type data immediately
2. Load cosmetic overrides on demand
3. Merge when displaying in UI

---

## Testing Integration

### Test Cases

1. **No Mods**: Verify default assets are used
2. **Single Mod**: Verify mod overrides are applied
3. **Multiple Mods**: Verify priority order is correct
4. **Guild-Specific**: Verify guild mods take priority
5. **Localization**: Verify language fallback works
6. **Invalid Mod**: Verify fallback to defaults
7. **Missing Asset**: Verify fallback to default asset

### Validation

**Before Integration**:
- Validate skin/set structure
- Verify hash matches content
- Verify struct type classes exist
- Check asset file paths

**During Integration**:
- Monitor error rates
- Track fallback usage
- Measure performance impact

---

## Related Documentation

- **Cosmetic System Overview**: `technical/cosmetic-system-overview.md` - Complete system architecture
- **Cosmetic Sets and Skins**: `technical/cosmetic-sets-and-skins.md` - Sets/Skins structure
- **Hash System**: `technical/cosmetic-hash-system.md` - Hash-based identification
- **API Endpoints**: `api/cosmetic-mods.md` - Complete API reference
- **Set Schema**: `schemas/cosmetic-set.md` - Set schema (after ingestion)
- **Skin Schema**: `schemas/cosmetic-skin.md` - Skin schema (after ingestion)
- **Mod Schema**: `schemas/cosmetic-mod.md` - Mod file schema (Phase 1, before ingestion)
- **Mod Protocol**: `protocols/cosmetic-mod-protocol.md` - Mod protocol
- **Workflow Examples**: `examples/workflows/` - Integration examples

---

*Protocol Version: 1.0.0 - January 2025*

