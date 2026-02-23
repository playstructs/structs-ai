# API Response Schemas

**Version**: 1.0.0
**Category**: api
**Schema**: JSON Schema Draft-07
**Description**: Complete catalog of all API response formats for AI agents. See `schemas/formats.md` for format specifications.

---

## General Responses

### SuccessResponse

Generic success response.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| success | boolean | Yes | Operation success status |
| message | string | No | Success message |

### ErrorResponse

Error response format.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| error | string | Yes | Error message |
| code | integer | No | Error code |
| details | array of string | No | Error details |

### PaginationResponse

Paginated response wrapper. Included alongside entity-specific data.

| Field | Type | Description |
|-------|------|-------------|
| pagination.next_key | string | Key for next page |
| pagination.total | string | Total count |

---

## Authentication Responses

### AuthResponse

Authentication response.

| Field | Type | Description |
|-------|------|-------------|
| success | boolean | Authentication success status |
| player | PlayerData | Player data (see below) |
| token | string | Authentication token (if applicable) |

### PlayerData

Player data structure, reused across multiple responses.

| Field | Type | Format | Description |
|-------|------|--------|-------------|
| id | string | entity-id | Player identifier in format `type-index` (e.g., `1-11`). Pattern: `^1-[0-9]+$`. Type 1 = Player. |
| username | string | | Player username |
| address | string | blockchain-address | Player blockchain address |

---

## Player Responses

### WebappPlayerResponse

Web application player response.

| Field | Type | Description |
|-------|------|-------------|
| player | PlayerData | Player data |
| guild | object | Guild information |
| stats | object | Player statistics |

### PlayerIdResponse

Player ID response.

| Field | Type | Format | Description |
|-------|------|--------|-------------|
| player_id | string | entity-id | Player identifier in format `type-index` (e.g., `1-11`). Pattern: `^1-[0-9]+$`. Type 1 = Player. |
| address | string | blockchain-address | Player blockchain address |
| guild_id | string | entity-id | Guild identifier in format `type-index` (e.g., `0-1`). Pattern: `^0-[0-9]+$`. Type 0 = Guild. |

### ActivationCodeResponse

Activation code information response.

| Field | Type | Description |
|-------|------|-------------|
| code | string | Activation code |
| valid | boolean | Whether code is valid |
| player_id | string (entity-id) | Associated player ID if applicable. Format: `type-index` (e.g., `1-11`). Pattern: `^1-[0-9]+$`. Type 1 = Player. |

---

## Planet Responses

### ShieldHealthResponse

Planetary shield health response.

| Field | Type | Format | Description |
|-------|------|--------|-------------|
| planet_id | string | entity-id | Planet identifier in format `type-index` (e.g., `2-1`). Pattern: `^2-[0-9]+$`. Type 2 = Planet. |
| health | integer | | Shield health value |
| max_health | integer | | Maximum shield health |

### ShieldResponse

Planetary shield information response.

| Field | Type | Format | Description |
|-------|------|--------|-------------|
| planet_id | string | entity-id | Planet identifier in format `type-index` (e.g., `2-1`). Pattern: `^2-[0-9]+$`. Type 2 = Planet. |
| shield | object | | Shield details |

---

## Guild Responses

### GuildNameResponse

Guild name response.

| Field | Type | Format | Description |
|-------|------|--------|-------------|
| guild_id | string | entity-id | Guild identifier in format `type-index` (e.g., `0-1`). Pattern: `^0-[0-9]+$`. Type 0 = Guild. |
| name | string | | Guild name |

### GuildNameListResponse

List of guild names. Response is an array of objects:

| Field | Type | Format | Description |
|-------|------|--------|-------------|
| guild_id | string | entity-id | Guild identifier in format `type-index` (e.g., `0-1`). Pattern: `^0-[0-9]+$`. Type 0 = Guild. |
| name | string | | Guild name |

### GuildRosterResponse

Guild roster response.

| Field | Type | Format | Description |
|-------|------|--------|-------------|
| guild_id | string | entity-id | Guild identifier in format `type-index` (e.g., `0-1`). Pattern: `^0-[0-9]+$`. Type 0 = Guild. |
| members | array of PlayerData | | List of guild members |
| member_count | integer | | Number of members |

### PowerStatsResponse

Power statistics response.

| Field | Type | Format | Description |
|-------|------|--------|-------------|
| guild_id | string | entity-id | Guild identifier in format `type-index` (e.g., `0-1`). Pattern: `^0-[0-9]+$`. Type 0 = Guild. |
| total_power | integer | | Total power |
| power_by_type | object | | Power breakdown by type |

---

## Ore and Stats Responses

### OreStatsResponse

Ore statistics response.

| Field | Type | Format | Description |
|-------|------|--------|-------------|
| player_id | string | entity-id | Player identifier in format `type-index` (e.g., `1-11`). Pattern: `^1-[0-9]+$`. Type 1 = Player. |
| total_ore | integer | | Total ore mined |
| ore_by_type | object | | Ore counts by type |

### BlockHeightResponse

Block height response.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| height | integer | Yes | Block height |

### CountResponse

Count response.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| count | integer | Yes | Count value |

### TimestampResponse

Unix timestamp response.

| Field | Type | Required | Format | Description |
|-------|------|----------|--------|-------------|
| timestamp | integer | Yes | | Unix timestamp |
| iso | string | No | date-time | ISO 8601 formatted timestamp |

---

## Transaction Responses

### TransactionResponse

Transaction submission response (Cosmos SDK format).

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| tx_response | object | Yes | Transaction response envelope |

The `tx_response` object:

| Field | Type | Description |
|-------|------|-------------|
| code | integer | Transaction result code (0 = success) |
| txhash | string | Transaction hash |
| height | integer | Block height |
| raw_log | string | Raw log output |

### RPCStatusResponse

RPC node status response.

| Field | Type | Description |
|-------|------|-------------|
| result.node_info | object | Node information |
| result.sync_info | object | Sync information |

---

## Cosmetic Mod Responses (Deprecated)

These responses use the older mod-based system. Use the Cosmetic Set equivalents instead.

### CosmeticModListResponse

**DEPRECATED**: Use CosmeticSetListResponse.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| mods | array of CosmeticModSummary | Yes | List of installed cosmetic mods |

### CosmeticModSummary

**DEPRECATED**: Use CosmeticSetSummary.

| Field | Type | Required | Pattern | Description |
|-------|------|----------|---------|-------------|
| modId | string | Yes | `^[a-z0-9-]+$` | Mod identifier |
| name | object | No | | Mod name by language (string values keyed by language code) |
| version | string | Yes | `^\d+\.\d+\.\d+$` | Mod version |
| author | string | Yes | | Mod author |
| guildId | string | No | `^0-[0-9]+$` | Guild ID (if guild-specific, entity-id format) |
| active | boolean | Yes | | Whether mod is active |
| structTypes | array of string | No | | Struct type IDs this mod affects |
| languages | array of string | No | `^[a-z]{2}$` each | Supported language codes |

### CosmeticModResponse

**DEPRECATED**: Use CosmeticSetResponse.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| modId | string | Yes | Pattern: `^[a-z0-9-]+$` |
| manifest | object | Yes | See `schemas/cosmetic-mod.md` manifest definition |
| active | boolean | Yes | Whether mod is active |
| structTypes | array of string | No | Struct type IDs |
| languages | array of string | No | Language codes (pattern: `^[a-z]{2}$` each) |

### CosmeticModUninstallResponse

**DEPRECATED**: Use CosmeticSetDeleteResponse.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| status | string | Yes | `success` or `error` |
| modId | string | Yes | Pattern: `^[a-z0-9-]+$` |

### CosmeticModActivateResponse

**DEPRECATED**: Use CosmeticSetActivateResponse.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| status | string | Yes | `success` or `error` |
| modId | string | Yes | Pattern: `^[a-z0-9-]+$` |
| active | boolean | Yes | Whether mod is active |

### CosmeticModDeactivateResponse

**DEPRECATED**: Use CosmeticSetDeactivateResponse.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| status | string | Yes | `success` or `error` |
| modId | string | Yes | Pattern: `^[a-z0-9-]+$` |
| active | boolean | Yes | Whether mod is active |

---

## Cosmetic Set Responses

### CosmeticSetListResponse

List of cosmetic sets response.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| sets | array of CosmeticSetSummary | Yes | List of installed cosmetic sets |

### CosmeticSetSummary

Summary information about a cosmetic set.

| Field | Type | Required | Pattern | Description |
|-------|------|----------|---------|-------------|
| setHash | string | Yes | `^[a-f0-9]{64}$` | Set hash (SHA-256, 64-character hexadecimal) |
| name | object | No | | Set name by language (string values keyed by language code) |
| version | string | Yes | `^\d+\.\d+\.\d+$` | Set version |
| author | string | Yes | | Set author |
| guildId | string | No | `^0-[0-9]+$` | Guild ID (if guild-specific, entity-id format) |
| active | boolean | Yes | | Whether set is active |
| classes | array of string | No | | Struct type classes this set affects (e.g., `Miner`, `Reactor`) |
| languages | array of string | No | `^[a-z]{2}$` each | Supported language codes |

### CosmeticSetResponse

Detailed cosmetic set information response.

| Field | Type | Required | Pattern | Description |
|-------|------|----------|---------|-------------|
| setHash | string | Yes | `^[a-f0-9]{64}$` | Set hash (SHA-256, 64-character hexadecimal) |
| name | object | No | | Set name by language |
| version | string | Yes | `^\d+\.\d+\.\d+$` | Set version |
| author | string | Yes | | Set author |
| guildId | string | No | `^0-[0-9]+$` | Guild ID (if guild-specific) |
| description | object | No | | Set description by language |
| active | boolean | Yes | | Whether set is active |
| skins | array | No | | List of skins in this set (see `schemas/cosmetic-set.md` SkinReference definition) |
| languages | array of string | No | `^[a-z]{2}$` each | Supported language codes |

### CosmeticSetDeleteResponse

Cosmetic set deletion response.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| status | string | Yes | `success` or `error` |
| setHash | string | Yes | Deleted set hash. Pattern: `^[a-f0-9]{64}$` |

### CosmeticSetActivateResponse

Cosmetic set activation response.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| status | string | Yes | `success` or `error` |
| setHash | string | Yes | Activated set hash. Pattern: `^[a-f0-9]{64}$` |
| active | boolean | Yes | Whether set is now active |

### CosmeticSetDeactivateResponse

Cosmetic set deactivation response.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| status | string | Yes | `success` or `error` |
| setHash | string | Yes | Deactivated set hash. Pattern: `^[a-f0-9]{64}$` |
| active | boolean | Yes | Whether set is now active (should be false) |

---

## Cosmetic Install and Validate Responses

### CosmeticModInstallResponse

Cosmetic mod installation response. Mod is converted to Sets/Skins during ingestion.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| status | string | Yes | `success` or `error` |
| type | string | Yes | Type of cosmetic installed: `set` or `skin` |
| setHash | string | No | Set hash if type is `set`. Pattern: `^[a-f0-9]{64}$` |
| skinHash | string | No | Skin hash if type is `skin`. Pattern: `^[a-f0-9]{64}$` |
| version | string | No | Version. Pattern: `^\d+\.\d+\.\d+$` |
| skins | array | No | List of skins if type is `set` (each with `skinHash` and `class`) |
| storagePath | string | No | Path where cosmetic was stored (hash-based directory structure) |
| validated | boolean | No | Whether mod was validated |
| activated | boolean | No | Whether cosmetic was activated |

Each entry in `skins` (when type is `set`):

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| skinHash | string | Yes | Pattern: `^[a-f0-9]{64}$` |
| class | string | Yes | Struct type class |

### CosmeticModValidateResponse

Cosmetic mod validation response.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| valid | boolean | Yes | Whether mod is valid |
| errors | array of string | Yes | Validation errors |
| warnings | array of string | Yes | Validation warnings |
| modId | string | No | Mod identifier (if valid). Pattern: `^[a-z0-9-]+$` |
| version | string | No | Mod version (if valid). Pattern: `^\d+\.\d+\.\d+$` |

---

## Struct Type Cosmetic Responses

### StructTypeCosmeticResponse

Cosmetic data for a struct type class (with skin overrides applied).

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| class | string | Yes | Struct type class name (e.g., `Miner`, `Reactor`, `Command Ship`). Must match `struct_type.class` field. |
| skinHash | string | Yes | Skin hash (SHA-256, 64-character hexadecimal). Pattern: `^[a-f0-9]{64}$` |
| name | string | No | Cosmetic name (localized) |
| lore | string | No | Lore/description (localized) |
| weapons | array | No | Weapon cosmetic overrides (see `schemas/cosmetic-skin.md` WeaponCosmetic definition) |
| abilities | array | No | Ability cosmetic overrides (see `schemas/cosmetic-skin.md` AbilityCosmetic definition) |
| animations | object | No | Animation file paths (string values keyed by animation name) |
| icon | string | No | Icon file path |
| skinSource | object | No | Source skin information (see below) |

#### skinSource

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| skinHash | string | Yes | Skin hash (SHA-256). Pattern: `^[a-f0-9]{64}$` |
| setHash | string | No | Parent set hash (if skin is part of a set). Pattern: `^[a-f0-9]{64}$` |
| version | string | No | Skin version. Pattern: `^\d+\.\d+\.\d+$` |

### StructTypeCosmeticListResponse

List of struct type cosmetics.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| structTypes | array of StructTypeCosmeticResponse | Yes | List of struct type cosmetic entries |

### StructTypeFullResponse

Struct type data with cosmetic overrides applied (integration endpoint).

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| structType | object | Yes | Base struct type data from consensus network |
| cosmetic | StructTypeCosmeticResponse | Yes | Cosmetic override data |
| merged | object | No | Merged data combining base and cosmetic |
