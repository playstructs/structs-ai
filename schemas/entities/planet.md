# Planet Entity Schema

**Version**: 1.0.0
**Category**: core
**Entity**: Planet
**Endpoint**: `/structs/planet/{id}`

---

## Planet Core Data

| Field | Type | Format | Pattern | Required | Description |
|-------|------|--------|---------|----------|-------------|
| id | string | entity-id | `^2-[0-9]+$` | Yes | Unique planet identifier in format `type-index` (e.g., `2-1` for planet type 2, index 1). Type 2 = Planet. |
| maxOre | string | | | Yes | Maximum ore capacity (string representation of integer, typically `5`) |
| creator | string | blockchain-address | | Yes | Blockchain address that created this planet |
| owner | string | entity-id | `^1-[0-9]+$` | No | Player ID who owns this planet, empty string if unowned. Format: `type-index` (e.g., `1-11` for player type 1, index 11). Type 1 = Player. |

### Slot Arrays

Planets have four slot arrays (space, air, land, water), each containing 4 slots for structs. Each slot holds a struct ID in `type-index` format (e.g., `5-42` for struct type 5, index 42) or an empty string if unoccupied.

| Slot Array | Slots | Item Format | Pattern | Description |
|------------|-------|-------------|---------|-------------|
| space | 4 | entity-id | `^5-[0-9]+$` | Space slot array (struct IDs or empty strings) |
| air | 4 | entity-id | `^5-[0-9]+$` | Air slot array (struct IDs or empty strings) |
| land | 4 | entity-id | `^5-[0-9]+$` | Land slot array (struct IDs or empty strings) |
| water | 4 | entity-id | `^5-[0-9]+$` | Water slot array (struct IDs or empty strings) |

## Map

The `map` field contains planet map data stored as JSONB. It accepts additional properties of any structure.

## Starting Properties

| Property | Default Value |
|----------|---------------|
| maxOre | 5 |
| spaceSlots | 4 |
| airSlots | 4 |
| landSlots | 4 |
| waterSlots | 4 |

## Relationships

| Relation | Entity | Schema |
|----------|--------|--------|
| owner | Player | [player.md](player.md) |
| structs (in slots) | Struct | [struct.md](struct.md) |

## Verification

| Property | Value |
|----------|-------|
| Verified | Yes |
| Verified By | GameCodeAnalyst |
| Verified Date | 2025-01-XX |
| Method | code-analysis |
| Confidence | high |
| Code Reference | `x/structs/types/keys.go` (PlanetStartingOre = 5), `x/structs/keeper/planet_cache.go` |
| Verified Fields | maxOre, startingOre, status, remainingOre |

API response schema. Starting properties verified: maxOre=5, slots=4 each. For code-based field definitions with formulas, see `schemas/entities.md#planet`.
