# Cosmetic Mod Schema

**Version**: 1.0.0
**Category**: modding
**Scope**: guild-customization

Schema for Struct Type cosmetic modding -- allows guilds to customize appearance and lore without changing game capabilities.

---

## Top-Level Properties

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| manifest | object | Yes | Mod metadata and information |
| structTypes | array of [StructTypeCosmetic](#structtypecosmetic) | No | Cosmetic overrides for struct types |
| localizations | object | No | Localization data by language code. Values are [Localization](#localization) objects |

---

## Manifest

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| modId | string | Yes | Unique mod identifier (e.g., `guild-alpha-miner-v1`). Pattern: `^[a-z0-9-]+$` |
| name | object | No | Mod name in multiple languages (key: language code, value: string). Default: `{"en": "Unnamed Mod"}` |
| version | string | Yes | Semantic version (e.g., `1.0.0`). Pattern: `^\d+\.\d+\.\d+$` |
| author | string | Yes | Mod author/guild name |
| guildId | string | No | Guild ID this mod is for (entity-id format, pattern: `^0-[0-9]+$`) |
| description | object | No | Mod description in multiple languages (key: language code, value: string) |
| compatibleGameVersion | string | No | Game version compatibility (e.g., `1.0.0`) |
| createdAt | string (date-time) | No | Mod creation timestamp (ISO 8601) |
| updatedAt | string (date-time) | No | Mod last update timestamp (ISO 8601) |

---

## Definitions

### StructTypeCosmetic

Cosmetic overrides for a specific struct type.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| class | string | Yes | Struct Type class name (must match `class` field from `struct_type` table/on-chain). Examples: `Command Ship`, `Miner`, `Reactor`, `Fleet`. Case-sensitive. |
| names | object | No | Cosmetic names in multiple languages (key: language code, value: string) |
| lore | object | No | Lore/description text in multiple languages |
| weapons | array of [WeaponCosmetic](#weaponcosmetic) | No | Weapon cosmetic overrides |
| abilities | array of [AbilityCosmetic](#abilitycosmetic) | No | Ability cosmetic overrides |
| animations | object | No | Animation file paths (Lottie JSON files). See [Animations](#animations) |
| icon | string | No | Path to icon file (relative to `icons/` directory) |
| graphics | object | No | Additional graphics files (key: name, value: path) |

### Animations

| Field | Type | Description |
|-------|------|-------------|
| idle | string | Path to idle animation (relative to `animations/` directory) |
| active | string | Path to active animation |
| building | string | Path to building animation |
| attacking | string | Path to attack animation |
| defending | string | Path to defense animation |
| custom | object | Custom animation mappings (key: name, value: path) |

### WeaponCosmetic

Cosmetic override for a weapon.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| weaponType | string | Yes | `primary` or `secondary` |
| names | object | No | Weapon names in multiple languages |
| description | object | No | Weapon description in multiple languages |
| animation | string | No | Path to weapon animation (Lottie JSON) |
| icon | string | No | Path to weapon icon |

### AbilityCosmetic

Cosmetic override for an ability.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| abilityId | string | Yes | Ability identifier (must match game ability) |
| names | object | No | Ability names in multiple languages |
| description | object | No | Ability description in multiple languages |
| animation | string | No | Path to ability animation (Lottie JSON) |
| icon | string | No | Path to ability icon |

### Localization

Localization data for a specific language. A flat object of key-value string pairs.

---

## Notes

- Mods only override cosmetic appearance and text -- game capabilities remain unchanged
- The `class` field must match exactly the class name from `struct_type` table (on-chain). Examples: `Command Ship`, `Miner`, `Reactor`, `Fleet`. Case-sensitive.
- Animation files must be valid Lottie JSON format
- Icon files should be PNG or SVG format
- Localization keys should follow language codes (`en`, `es`, `fr`, etc.)
- Mods are converted to Sets/Skins format during ingestion (Phase 2)
- After ingestion, cosmetics use hash-based identification (`setHash`, `skinHash`)

---

## Related Documentation

- [Cosmetic Set Schema](cosmetic-set.md)
- [Cosmetic Skin Schema](cosmetic-skin.md)
