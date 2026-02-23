# Struct Essential Schema

**Version**: 1.0.0
**Category**: core
**Minimal**: Yes
**Complete Schema**: [schemas/entities/struct.md](../entities/struct.md)

---

## Description

Minimal struct schema for simple lookups and basic operations. Use this for ID format checks, existence verification, and basic struct queries. For complete struct data, use the full [Struct entity schema](../entities/struct.md).

## Properties

| Field | Type | Format | Pattern | Required | Description |
|-------|------|--------|---------|----------|-------------|
| id | string | entity-id | `^5-[0-9]+$` | Yes | Struct identifier in format `type-index` (e.g., `5-42` for struct type 5, index 42). |
| structType | integer | -- | -- | Yes | Struct type ID (e.g., 1 = Ore Extractor, 2 = Ore Refinery, etc.). |
| owner | string | entity-id | `^1-[0-9]+$` | No | Player ID who owns this struct, empty string if unowned. |
| locationType | integer | -- | -- | No | Location type (1 = Planet, 2 = Fleet). |
| locationId | string | entity-id | -- | No | Location ID (planet ID or fleet ID depending on locationType). |
| slot | string | -- | -- | No | Slot type on planet: `space`, `air`, `land`, `water`, or empty string if on fleet. |

## Use Cases

- Check if struct exists
- Verify struct ID format
- Check struct ownership
- Get basic struct location
- Quick struct lookup

## When to Use

Use this schema for simple operations that don't require full struct data (attributes, power requirements, build costs, etc.).

## When Not to Use

Don't use this schema if you need: struct attributes, power requirements, build costs, struct status, or any detailed struct state.
