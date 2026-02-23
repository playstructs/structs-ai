# Structs Data Format Specifications

**Version**: 1.0.0
**Description**: Format specifications for all data types used in Structs APIs and schemas

---

## Entity ID

General object identifier used across all Structs APIs.

| Property | Value |
|----------|-------|
| Format | `type-index` |
| Pattern | `^[0-9]+-[0-9]+$` |
| Description | Object identifier where `type` is the object type code and `index` is the 1-based object index |

**Examples**: `0-1`, `1-11`, `2-1`, `4-3`

### Object Type Codes

| Type Code | Name | Description | Example |
|-----------|------|-------------|---------|
| 0 | Guild | Guild identifier | `0-1` |
| 1 | Player | Player identifier | `1-11` |
| 2 | Planet | Planet identifier | `2-1` |
| 3 | Reactor | Reactor identifier | `3-1` |
| 4 | Substation | Substation identifier | `4-3` |
| 5 | Struct | Struct identifier | `5-42` |
| 6 | Allocation | Allocation identifier | `6-1` |
| 7 | Infusion | Infusion identifier | `7-1` |
| 8 | Address | Address identifier | `8-1` |
| 9 | Fleet | Fleet identifier | `9-11` |
| 10 | Provider | Provider identifier | `10-1` |
| 11 | Agreement | Agreement identifier | `11-1` |

---

## Struct Type ID

| Property | Value |
|----------|-------|
| Type | integer |
| Format | integer (not entity-id) |
| Description | Struct type identifier (exception: uses regular integer, not entity-id format) |

**Examples**: `1`, `2`, `3`

> Struct types use regular integer IDs, not the entity-id format.

---

## Blockchain Address

| Property | Value |
|----------|-------|
| Format | bech32 |
| Pattern | `^structs1[a-z0-9]{38}$` |
| Description | Cosmos blockchain address |

**Example**: `structs1nffawa6ncl73d8hdcfh74f2sm5en4k8uqyupj0`

---

## Micrograms

| Property | Value |
|----------|-------|
| Type | string |
| Format | integer-string |
| Pattern | `^[0-9]+$` |
| Description | Alpha Matter amount in micrograms (uAlpha) |

**Example**: `"1000000"`

> 1 gram = 1,000,000 micrograms

---

## Watts

| Property | Value |
|----------|-------|
| Type | string |
| Format | integer-string |
| Pattern | `^[0-9]+$` |
| Description | Energy amount in kilowatts (kW) |

**Examples**: `"1000"`, `"500000"`

---

## Usage Guide

| Format | When to Use |
|--------|-------------|
| `entity-id` | All entity identifiers except struct_types |
| `struct-type-id` | Only for struct_type identifiers |
| `blockchain-address` | Cosmos addresses |
| `micrograms` | Alpha Matter amounts in API responses |
| `watts` | Energy amounts in API responses |
