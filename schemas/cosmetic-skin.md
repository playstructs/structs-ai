# Cosmetic Skin Schema

**Version**: 1.0.0
**Category**: modding
**Scope**: guild-customization

Schema for cosmetic skins -- specific struct type cosmetics.

---

## Properties

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| skinHash | string | Yes | SHA-256 hash of the skin manifest (hexadecimal, 64 characters). Generated from the skin manifest content to ensure uniqueness without central authority. Pattern: `^[a-f0-9]{64}$` |
| class | string | Yes | Struct Type class name this skin is for (must match `class` field from `struct_type` table/on-chain). Examples: `Command Ship`, `Miner`, `Reactor`, `Fleet` |
| name | object | No | Skin name in multiple languages (key: language code, value: string) |
| version | string | Yes | Semantic version (e.g., `1.0.0`). Pattern: `^\d+\.\d+\.\d+$` |
| author | string | No | Skin author/guild name |
| setHash | string | No | Parent set hash (optional, for skins that are part of a set). Must match the `setHash` of the containing set. Pattern: `^[a-f0-9]{64}$` |
| description | object | No | Skin description in multiple languages (key: language code, value: string) |
| lore | object | No | Lore/backstory text in multiple languages |
| weapons | array of [WeaponCosmetic](#weaponcosmetic) | No | Weapon cosmetic overrides |
| abilities | array of [AbilityCosmetic](#abilitycosmetic) | No | Ability cosmetic overrides |
| animations | object | No | Animation file paths (Lottie JSON files). See [Animations](#animations) |
| icon | string | No | Path to icon file (relative to `icons/` directory) |
| graphics | object | No | Additional graphics files (key: name, value: path) |
| createdAt | string (date-time) | No | Skin creation timestamp (ISO 8601) |
| updatedAt | string (date-time) | No | Skin last update timestamp (ISO 8601) |

---

## Definitions

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

---

## Notes

- A skin is a specific struct type cosmetic
- Skin identifiers use SHA-256 hashes (not IDs) to ensure uniqueness without central authority
- `skinHash` is generated from the skin manifest content (excluding the hash field itself)
- Skins link to Struct Types using the `class` field (stored on-chain and in database)
- The `class` field must match exactly the class name from `struct_type` table
- Skins can be part of a set or standalone
- Skins override default cosmetics for their struct type
- Animation files must be valid Lottie JSON format
- Icon files should be PNG or SVG format

---

## Related Documentation

- [Cosmetic Set Schema](cosmetic-set.md)
- [Cosmetic Mod Schema](cosmetic-mod.md)
