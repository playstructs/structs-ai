# Cosmetic Set Schema

**Version**: 1.0.0
**Category**: modding
**Scope**: guild-customization

Schema for cosmetic sets -- collections of struct type skins.

---

## Properties

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| setHash | string | Yes | SHA-256 hash of the set manifest (hexadecimal, 64 characters). Generated from the set manifest content to ensure uniqueness without central authority. Pattern: `^[a-f0-9]{64}$` |
| name | object | No | Set name in multiple languages (key: language code, value: string). Default: `{"en": "Unnamed Set"}` |
| version | string | Yes | Semantic version (e.g., `1.0.0`). Pattern: `^\d+\.\d+\.\d+$` |
| author | string | Yes | Set author/guild name |
| guildId | string | No | Guild ID this set is for (entity-id format, pattern: `^0-[0-9]+$`). Optional, for guild-specific sets |
| description | object | No | Set description in multiple languages (key: language code, value: string) |
| skins | array of [SkinReference](#skinreference) | No | List of skins included in this set |
| createdAt | string (date-time) | No | Set creation timestamp (ISO 8601) |
| updatedAt | string (date-time) | No | Set last update timestamp (ISO 8601) |

---

## Definitions

### SkinReference

Reference to a skin in the set.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| skinHash | string | Yes | SHA-256 hash of the skin manifest (hexadecimal, 64 characters). Pattern: `^[a-f0-9]{64}$` |
| class | string | Yes | Struct Type class name this skin is for (must match `class` field from `struct_type` table/on-chain). Examples: `Command Ship`, `Miner`, `Reactor` |
| version | string | Yes | Skin version. Pattern: `^\d+\.\d+\.\d+$` |

---

## Notes

- A set is a collection of skins
- Set and skin identifiers use SHA-256 hashes (not IDs) to ensure uniqueness without central authority
- `setHash` is generated from the set manifest content (excluding the hash field itself)
- Skins link to Struct Types using the `class` field (stored on-chain and in database)
- The `class` field must match exactly the class name from `struct_type` table
- Sets can be distributed as complete packages
- Individual skins can also be distributed standalone
- Skins can be mixed and matched from different sets

---

## Related Documentation

- [Cosmetic Mod Schema](cosmetic-mod.md)
- [Cosmetic Skin Schema](cosmetic-skin.md)
