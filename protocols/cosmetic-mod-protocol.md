# Cosmetic Mod Protocol

**Version**: 1.0.0  
**Category**: Modding  
**Scope**: Guild Customization

---

## Overview

This protocol defines how AI agents should interact with the cosmetic modding system for Struct Types. Cosmetic mods allow customization of appearance and lore without changing game capabilities.

---

## Protocol Principles

1. **Cosmetic Only**: Cosmetics only affect appearance and text, not game mechanics
2. **Separate from Blockchain**: Cosmetics are off-chain, not stored in structsd
3. **Distributed System**: Each guild maintains their own cosmetics
4. **On-Demand Transfer**: Cosmetics are shared peer-to-peer when needed
5. **Caching**: Received cosmetics are cached for performance
6. **Hash-Based Identification**: Sets and skins use SHA-256 hashes (not IDs) for uniqueness
7. **Class-Based Linking**: Skins link to Struct Types via `class` field (on-chain/database)
8. **Two-Layer Structure**: Sets (collections) and Skins (individual cosmetics)
9. **Localization Support**: All text supports multiple languages
10. **File-Based**: Sets/skins are directory structures (distributed as ZIP)

---

## Set and Skin Structure

### Directory Layout

**For Sets**:
```
cosmetic-set/
├── set-manifest.json      # Required: Set metadata (with setHash)
├── skins/                 # Required: Individual skins
│   └── {skinHash}/
│       ├── skin-manifest.json
│       ├── struct-type.json
│       └── assets/
└── localizations/         # Optional: Set-level localizations
```

**For Standalone Skins**:
```
cosmetic-skin/
├── skin-manifest.json     # Required: Skin metadata (with skinHash)
├── struct-type.json       # Required: Struct type cosmetic data
├── animations/            # Optional: Lottie JSON files
├── icons/                 # Optional: Icon files
└── graphics/              # Optional: Other graphics
```

### Set Manifest Schema

**Location**: `set-manifest.json`  
**Schema**: `schemas/cosmetic-set.md`

**Required Fields**:
- `setHash` (string): SHA-256 hash (64-character hexadecimal) - **generated automatically**
- `version` (string): Semantic version
- `author` (string): Set author

**Optional Fields**:
- `name` (object): Set name by language
- `guildId` (string): Guild ID for guild-specific sets
- `description` (object): Set description by language
- `skins` (array): List of skins in the set

### Skin Manifest Schema

**Location**: `skin-manifest.json`  
**Schema**: `schemas/cosmetic-skin.md`

**Required Fields**:
- `skinHash` (string): SHA-256 hash (64-character hexadecimal) - **generated automatically**
- `class` (string): Struct Type class name (must match `struct_type.class`)
- `version` (string): Semantic version

**Optional Fields**:
- `name` (object): Skin name by language
- `setHash` (string): Parent set hash (if part of a set)
- `author` (string): Skin author
- `description` (object): Skin description by language

---

## Cosmetic Distribution System

### Architecture

The cosmetic system operates **separate from the blockchain** as a distributed, peer-to-peer network:

- **off-chain**: Cosmetics are not stored on the blockchain
- **Guild Storage**: Each guild maintains their own cosmetics
- **On-Demand Transfer**: Cosmetics are shared when players interact
- **Caching**: Received cosmetics are cached for faster future access

### Cosmetic Transfer Flow

**Scenario**: Player from Guild A visits planet of player from Guild B

1. **Detection**: Game detects Guild B structs on planet
2. **Cache Check**: Guild A checks local cache for Guild B cosmetics
3. **Request** (if not cached): Guild A requests cosmetics from Guild B
4. **Transfer**: Guild B sends cosmetic mods to Guild A
5. **Cache**: Guild A stores received cosmetics in cache
6. **Render**: Game renders Guild B structs with their custom appearance
7. **Future Visits**: Use cached cosmetics (faster)

### Priority Order

1. **Own Guild Cosmetics** (if viewing own structs)
2. **Cached Cosmetics** (if viewing other guild's structs - from cache)
3. **Requested Cosmetics** (if not cached - request from source guild)
4. **Default game assets** (fallback if no cosmetics available)

### Request Cosmetics from Another Guild

```json
{
  "action": "requestCosmetics",
  "parameters": {
    "fromGuildId": "0-2",
    "classes": ["Miner", "Reactor"],
    "cachedHashes": {
      "Miner": "f1e2d3c4b5a6789012345678901234567890abcdef1234567890abcdef123456",
      "Reactor": null
    }
  }
}
```

**Response**:
```json
{
  "status": "success",
  "guildId": "0-2",
  "skins": [
    {
      "skinHash": "f1e2d3c4b5a6789012345678901234567890abcdef1234567890abcdef123456",
      "class": "Miner",
      "version": "1.0.1",
      "needsUpdate": true,
      "skin": { /* cosmetic skin data */ }
    }
  ],
  "assetUrls": {
    "miner-idle.json": "https://guild-b.example.com/cosmetics/assets/miner-idle.json"
  },
  "cached": false
}
```

### Check Cosmetic Cache

```json
{
  "action": "checkCosmeticCache",
  "parameters": {
    "guildId": "0-2",
    "classes": ["Miner", "Reactor"]
  }
}
```

**Response**:
```json
{
  "cached": true,
  "guildId": "0-2",
  "hashes": {
    "Miner": "f1e2d3c4b5a6789012345678901234567890abcdef1234567890abcdef123456",
    "Reactor": "e1d2c3b4a56789012345678901234567890abcdef1234567890abcdef1234567"
  },
  "cachePath": "~/.structs/guilds/0-1/cosmetics/cache/guild-0-2",
  "expiresAt": "2025-01-16T10:00:00Z"
}
```

---

## Querying Mods

### Get Available Mods

```json
{
  "action": "listCosmeticMods",
  "parameters": {}
}
```

**Response**:
```json
{
  "mods": [
    {
      "modId": "guild-alpha-miner-v1",
      "name": {"en": "Guild Alpha Miner Pack"},
      "version": "1.0.0",
      "author": "Guild Alpha",
      "guildId": "0-1",
      "structTypes": ["miner"],
      "languages": ["en", "es"]
    }
  ]
}
```

### Get Set Details

```json
{
  "action": "getCosmeticSet",
  "parameters": {
    "setHash": "a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456"
  }
}
```

**Response**:
```json
{
  "setHash": "a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456",
  "set": { /* full set manifest */ },
  "skins": [ /* skin references */ ]
}
```

### Get Skin Details

```json
{
  "action": "getCosmeticSkin",
  "parameters": {
    "skinHash": "f1e2d3c4b5a6789012345678901234567890abcdef1234567890abcdef123456"
  }
}
```

**Response**:
```json
{
  "skinHash": "f1e2d3c4b5a6789012345678901234567890abcdef1234567890abcdef123456",
  "skin": { /* full skin manifest */ }
}
```

### Get Struct Type Cosmetics by Class

```json
{
  "action": "getStructTypeCosmetics",
  "parameters": {
    "class": "Miner",
    "language": "en"
  }
}
```

**Response**:
```json
{
  "class": "Miner",
  "skinHash": "f1e2d3c4b5a6789012345678901234567890abcdef1234567890abcdef123456",
  "name": "Alpha Extractor",
  "lore": "Guild Alpha's signature mining unit...",
  "weapons": [
    {
      "weaponType": "primary",
      "name": "Plasma Drill",
      "description": "High-powered plasma drilling system"
    }
  ],
  "abilities": [
    {
      "abilityId": "mine",
      "name": "Deep Extraction",
      "description": "Extract resources from planetary deposits"
    }
  ],
  "animations": {
    "idle": "animations/miner-idle.json",
    "active": "animations/miner-mining.json"
  },
  "icon": "icons/miner-alpha.png"
}
```

---

## Creating Mods

### Validate Set/Skin Structure

```json
{
  "action": "validateCosmeticSet",
  "parameters": {
    "setPath": "path/to/set"
  }
}
```

**Response**:
```json
{
  "valid": true,
  "setHash": "a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456",
  "errors": [],
  "warnings": [
    "Missing fallback language (en) in localizations"
  ]
}
```

### Validate Skin

```json
{
  "action": "validateCosmeticSkin",
  "parameters": {
    "skinPath": "path/to/skin"
  }
}
```

**Response**:
```json
{
  "valid": true,
  "skinHash": "f1e2d3c4b5a6789012345678901234567890abcdef1234567890abcdef123456",
  "errors": [],
  "warnings": []
}
```

### Create Set Manifest

```json
{
  "action": "createCosmeticSet",
  "parameters": {
    "name": {"en": "Guild Alpha Mining Set"},
    "version": "1.0.0",
    "author": "Guild Alpha",
    "guildId": "0-1"
  }
}
```

**Response**:
```json
{
  "status": "success",
  "setHash": "a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456",
  "setPath": "~/.structs/guilds/0-1/cosmetics/sets/a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456",
  "manifestPath": "~/.structs/guilds/0-1/cosmetics/sets/a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456/set-manifest.json"
}
```

### Add Skin to Set

```json
{
  "action": "addSkinToSet",
  "parameters": {
    "setHash": "a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456",
    "class": "Miner",
    "cosmetic": {
      "name": {"en": "Alpha Extractor"},
      "lore": {"en": "Guild Alpha's signature mining unit..."},
      "animations": {
        "idle": "miner-idle.json"
      }
    }
  }
}
```

**Response**:
```json
{
  "status": "success",
  "skinHash": "f1e2d3c4b5a6789012345678901234567890abcdef1234567890abcdef123456",
  "skinPath": "~/.structs/guilds/0-1/cosmetics/sets/a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456/skins/f1e2d3c4b5a6789012345678901234567890abcdef1234567890abcdef123456"
}
```

---

## Localization

### Language Codes

Use ISO 639-1 language codes:
- `en`: English
- `es`: Spanish
- `fr`: French
- `de`: German
- etc.

### Fallback

Always provide English (`en`) as fallback language.

### Localization Structure

```json
{
  "en": {
    "miner.description": "Mining unit",
    "miner.weapon.primary": "Drill"
  },
  "es": {
    "miner.description": "Unidad de minería",
    "miner.weapon.primary": "Taladro"
  }
}
```

---

## Asset Management

### Animation Files

- **Format**: Lottie JSON
- **Location**: `animations/` directory
- **Reference**: Use relative paths in struct type definitions
- **Validation**: Must be valid Lottie JSON

### Icon Files

- **Format**: PNG or SVG
- **Location**: `icons/` directory
- **Reference**: Use relative paths in struct type definitions
- **Recommended Size**: 64x64 to 256x256 pixels

### Graphics Files

- **Format**: PNG, SVG, or other supported formats
- **Location**: `graphics/` directory
- **Reference**: Use relative paths in struct type definitions

---

## Error Handling

### Invalid Hash

```json
{
  "error": "invalid_hash",
  "message": "Hash validation failed",
  "details": {
    "field": "setHash",
    "issue": "Hash mismatch: expected a1b2c3d4..., got f1e2d3c4..."
  }
}
```

### Invalid Hash Format

```json
{
  "error": "invalid_hash_format",
  "message": "Hash format validation failed",
  "details": {
    "field": "skinHash",
    "issue": "Invalid format: must be 64-character hexadecimal string"
  }
}
```

### Missing Struct Type Class

```json
{
  "error": "struct_type_class_not_found",
  "message": "Struct type class not found in game",
  "details": {
    "class": "InvalidClass"
  }
}
```

### Missing Asset

```json
{
  "error": "asset_not_found",
  "message": "Referenced asset file not found",
  "details": {
    "path": "animations/miner-idle.json",
    "skinHash": "f1e2d3c4b5a6789012345678901234567890abcdef1234567890abcdef123456"
  }
}
```

---

## Best Practices

1. **Always validate** mods before distribution
2. **Include fallback language** (English) in all mods
3. **Use relative paths** for all asset references
4. **Test animations** in game before distribution
5. **Version mods** using semantic versioning
6. **Document changes** in mod description
7. **Optimize assets** for performance

---

## Related Documentation

- Schema: `schemas/cosmetic-set.md` (Sets)
- Schema: `schemas/cosmetic-skin.md` (Skins)
- Hash System: `technical/cosmetic-hash-system.md`
- Human Guide: `users/modding/cosmetic-mods.md`
- Sets and Skins: `technical/cosmetic-sets-and-skins.md`

---

*Protocol Version: 1.0.0*

