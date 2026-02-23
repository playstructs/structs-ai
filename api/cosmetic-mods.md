# Cosmetic Sets and Skins API Endpoints

**Version**: 2.0.0
**Category**: modding
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`)
**Purpose**: API for managing cosmetic sets and skins, and querying cosmetic data for Struct Types

---

## Overview

This API allows clients to:
- Install cosmetic mods (converts to Sets/Skins during ingestion)
- Manage cosmetic sets and skins (using hash-based identification)
- Query cosmetic data by struct type class
- Validate mod files before installation
- Integrate cosmetic data with struct type queries

**Note**: This API uses the **Sets/Skins format** with hash-based identification for management endpoints. The install/validate endpoints accept the **mod file format** (which is converted to Sets/Skins during ingestion).

---

## Endpoints

### Set Management

| ID | Method | Path | Description |
|----|--------|------|-------------|
| cosmetic-set-list | GET | `/api/cosmetic-sets` | List all installed cosmetic sets |
| cosmetic-set-get | GET | `/api/cosmetic-sets/{setHash}` | Get detailed information about a specific cosmetic set |
| cosmetic-mod-install | POST | `/api/cosmetic-mods/install` | Install a cosmetic mod (mod file format) |
| cosmetic-set-delete | DELETE | `/api/cosmetic-sets/{setHash}` | Delete a cosmetic set |
| cosmetic-set-activate | POST | `/api/cosmetic-sets/{setHash}/activate` | Activate a cosmetic set |
| cosmetic-set-deactivate | POST | `/api/cosmetic-sets/{setHash}/deactivate` | Deactivate a cosmetic set |
| cosmetic-mod-validate | POST | `/api/cosmetic-mods/validate` | Validate a cosmetic mod file without installing |

### Cosmetic Data Queries

| ID | Method | Path | Description |
|----|--------|------|-------------|
| cosmetic-class | GET | `/api/cosmetic/class/{class}` | Get cosmetic data for a struct type class (with skin overrides) |
| cosmetic-classes-list | GET | `/api/cosmetic/classes` | Get cosmetic data for all struct type classes |

### Integration Endpoints

| ID | Method | Path | Description |
|----|--------|------|-------------|
| struct-type-with-cosmetics | GET | `/api/struct-type/{id}/full` | Get struct type data with cosmetic overrides applied |

---

## Endpoint Details

### `GET /api/cosmetic-sets` (cosmetic-set-list)

List all installed cosmetic sets.

| Parameter | Type | Required | Format | Description |
|-----------|------|----------|--------|-------------|
| guildId | string | No | `^0-[0-9]+$` | Filter sets by guild ID |
| active | boolean | No | -- | Filter to only active sets (default: true) |

```json
// Example request: GET /api/cosmetic-sets?active=true
// Example response:
{
  "sets": [
    {
      "setHash": "a1b2c3d4...123456",
      "name": {"en": "Guild Alpha Mining Set"},
      "version": "1.0.0",
      "author": "Guild Alpha",
      "guildId": "0-1",
      "active": true,
      "classes": ["Miner", "Reactor"],
      "languages": ["en", "es"]
    }
  ]
}
```

### `GET /api/cosmetic-sets/{setHash}` (cosmetic-set-get)

Get detailed information about a specific cosmetic set.

| Parameter | Type | Required | Format | Description |
|-----------|------|----------|--------|-------------|
| setHash | string | Yes | `^[a-f0-9]{64}$` | Set hash (SHA-256, 64-character hexadecimal) |

```json
// Example response:
{
  "setHash": "a1b2c3d4...123456",
  "name": {"en": "Guild Alpha Mining Set"},
  "version": "1.0.0",
  "author": "Guild Alpha",
  "guildId": "0-1",
  "active": true,
  "skins": [
    {
      "skinHash": "f1e2d3c4...123456",
      "class": "Miner",
      "version": "1.0.0"
    }
  ],
  "languages": ["en", "es"]
}
```

### `POST /api/cosmetic-mods/install` (cosmetic-mod-install)

Install a cosmetic mod (mod file format). Converts to Sets/Skins during ingestion.

This endpoint accepts the mod file format (Phase 1). The mod is converted to Sets/Skins format (Phases 2-4) during ingestion. Response includes setHash/skinHash.

- **Content-Type**: `multipart/form-data`

```
// Example request:
POST /api/cosmetic-mods/install
Content-Type: multipart/form-data

file: [ZIP file or directory path]
validate: true
```

```json
// Example response:
{
  "status": "success",
  "type": "set",
  "setHash": "a1b2c3d4...123456",
  "version": "1.0.0",
  "skins": [
    {
      "skinHash": "f1e2d3c4...123456",
      "class": "Miner"
    }
  ],
  "storagePath": "~/.structs/guilds/0-1/cosmetics/sets/a1b2c3d4...123456/",
  "validated": true
}
```

### `DELETE /api/cosmetic-sets/{setHash}` (cosmetic-set-delete)

Delete a cosmetic set.

| Parameter | Type | Required | Format | Description |
|-----------|------|----------|--------|-------------|
| setHash | string | Yes | `^[a-f0-9]{64}$` | Set hash (SHA-256, 64-character hexadecimal) |

```json
// Example response:
{
  "status": "success",
  "setHash": "a1b2c3d4...123456"
}
```

### `POST /api/cosmetic-sets/{setHash}/activate` (cosmetic-set-activate)

Activate a cosmetic set.

| Parameter | Type | Required | Format | Description |
|-----------|------|----------|--------|-------------|
| setHash | string | Yes | `^[a-f0-9]{64}$` | Set hash (SHA-256, 64-character hexadecimal) |

```json
// Example response:
{
  "status": "success",
  "setHash": "a1b2c3d4...123456",
  "active": true
}
```

### `POST /api/cosmetic-sets/{setHash}/deactivate` (cosmetic-set-deactivate)

Deactivate a cosmetic set.

| Parameter | Type | Required | Format | Description |
|-----------|------|----------|--------|-------------|
| setHash | string | Yes | `^[a-f0-9]{64}$` | Set hash (SHA-256, 64-character hexadecimal) |

```json
// Example response:
{
  "status": "success",
  "setHash": "a1b2c3d4...123456",
  "active": false
}
```

### `POST /api/cosmetic-mods/validate` (cosmetic-mod-validate)

Validate a cosmetic mod file (mod file format) without installing it.

This endpoint accepts the mod file format (Phase 1) and validates it. Does not convert to Sets/Skins.

- **Content-Type**: `multipart/form-data`

```json
// Example response:
{
  "valid": true,
  "errors": [],
  "warnings": [
    "Missing fallback language (en) in localizations"
  ],
  "modId": "guild-alpha-miner-v1",
  "version": "1.0.0"
}
```

### `GET /api/cosmetic/class/{class}` (cosmetic-class)

Get cosmetic data for a struct type class (with skin overrides applied).

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| class | string | Yes | -- | Struct type class name (e.g., `Miner`, `Reactor`, `Command Ship`). Must match `struct_type.class` field. |
| language | string | No | `en` | Language code (ISO 639-1, e.g., `en`, `es`) |
| guildId | string | No | -- | Guild ID for guild-specific skins (format: `^0-[0-9]+$`) |

```json
// Example request: GET /api/cosmetic/class/Miner?language=en&guildId=0-1
// Example response:
{
  "class": "Miner",
  "skinHash": "f1e2d3c4...123456",
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
    "idle": "/cosmetics/sets/.../skins/.../assets/animations/miner-idle.json",
    "active": "/cosmetics/sets/.../skins/.../assets/animations/miner-mining.json"
  },
  "icon": "/cosmetics/sets/.../skins/.../assets/icons/miner-alpha.png",
  "skinSource": {
    "skinHash": "f1e2d3c4...123456",
    "setHash": "a1b2c3d4...123456",
    "version": "1.0.0"
  }
}
```

### `GET /api/cosmetic/classes` (cosmetic-classes-list)

Get cosmetic data for all struct type classes (with skin overrides applied).

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| language | string | No | `en` | Language code (ISO 639-1) |
| guildId | string | No | -- | Guild ID for guild-specific skins (format: `^0-[0-9]+$`) |

### `GET /api/struct-type/{id}/full` (struct-type-with-cosmetics)

Get struct type data with cosmetic overrides applied (integration endpoint).

This endpoint combines struct type game data (from consensus network) with cosmetic skin overrides (from Sets/Skins system). Use this for displaying struct types in the game UI. The class parameter is optional -- if not provided, the class is looked up from the struct type's class field.

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| id | string | Yes | -- | Struct type ID (for base game data) |
| class | string | No | -- | Struct type class name (for cosmetic lookup). If not provided, class is looked up from struct type data. |
| language | string | No | `en` | Language code for cosmetic text |
| guildId | string | No | -- | Guild ID for guild-specific skins (format: `^0-[0-9]+$`) |

---

## Integration with Struct Type Queries

### How Skins Integrate

When querying struct types via the Consensus Network API (`/structs/struct_type/{id}`), cosmetic skins are applied by the Web Application API layer:

1. **Query Base Data**: Get struct type from consensus network
2. **Lookup Class**: Get `class` field from struct type
3. **Apply Skin Overrides**: Query cosmetic skins for the class
4. **Merge Data**: Combine base data with cosmetic overrides
5. **Return Result**: Return merged struct type data

### Priority Order

1. **Individual Skin** (highest priority -- if standalone skin exists for class)
2. **Set Skin** (if set is active and contains skin for class)
3. **Default game assets** (fallback)

### Example Integration Flow

```
1. GET /structs/struct_type/1-11 (Consensus Network API)
   -> Returns base struct type data
   -> Includes: { "class": "Miner", "defaultCosmeticName": "Miner" }

2. GET /api/cosmetic/class/Miner?guildId=0-1 (Web Application API)
   -> Returns cosmetic skin data for class "Miner"
   -> Includes: { "name": "Alpha Extractor", "skinHash": "f1e2d3c4..." }

3. Merge data:
   - Base: { "id": "1-11", "class": "Miner", "defaultCosmeticName": "Miner" }
   - Skin: { "name": "Alpha Extractor", "skinHash": "f1e2d3c4..." }
   - Result: { "id": "1-11", "class": "Miner", "cosmeticName": "Alpha Extractor", "skinHash": "f1e2d3c4..." }
```

**Key Point**: Skins are linked to struct types via the `class` field, not by struct type ID.

---

## Error Codes

See `api/error-codes.md` for complete error code reference.

**Mod-Specific Errors**:
- `COSMETIC_MOD_NOT_FOUND` (404): Mod not found
- `COSMETIC_MOD_INVALID` (400): Mod validation failed
- `COSMETIC_MOD_INSTALL_FAILED` (500): Mod installation failed
- `COSMETIC_MOD_CONFLICT` (409): Mod conflicts with existing mod
- `COSMETIC_MOD_UNSUPPORTED_VERSION` (400): Mod version incompatible

---

## Related Documentation

### Mod File Format (Phase 1: Creation)
- **Schema**: `schemas/cosmetic-mod.md` - Mod file schema (input format)
- **User Guide**: `users/modding/cosmetic-mods.md` - Human-readable guide
- **Examples**: `examples/cosmetic-mod-example/` - Example mod files

### Sets/Skins Format (Phases 2-4: System)
- **Set Schema**: `schemas/cosmetic-set.md` - Set schema (system format)
- **Skin Schema**: `schemas/cosmetic-skin.md` - Skin schema (system format)
- **Protocol**: `protocols/cosmetic-mod-protocol.md` - Sets/Skins protocol
- **Hash System**: `technical/cosmetic-hash-system.md` - Hash generation
- **Sets and Skins**: `technical/cosmetic-sets-and-skins.md` - Architecture

### System Architecture
- **Overview**: `technical/cosmetic-system-overview.md` - Four phases
- **Ingestion**: `technical/cosmetic-ingestion.md` - How mods become Sets/Skins
- **Distribution**: `technical/cosmetic-distribution.md` - Peer-to-peer transfer

---

*Last Updated: January 2025*
