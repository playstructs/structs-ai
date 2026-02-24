# Planet Entity Schema

**Version**: 1.3.0
**Category**: core
**Entity**: Planet
**Endpoint**: `/structs/planet/{id}`
**Last Updated**: 2026-02-24

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

## Planet View (view.planet)

The planet view provides computed fields beyond the base table:

| Field | Type | Description |
|-------|------|-------------|
| buried_ore | numeric | Ore still underground on the planet |
| available_ore | numeric | Ore available for mining |
| planetary_shield | integer | Total planetary shield value |
| defensive_cannon_quantity | integer | Number of Planetary Defense Cannons |
| repair_network_quantity | integer | Number of repair network structs |
| coordinated_global_shield_network_quantity | integer | CGSN count |
| low_orbit_ballistics_interceptor_network_quantity | integer | LOBI count |
| advanced_low_orbit_ballistics_interceptor_network_quantity | integer | Advanced LOBI count |
| lobi_network_success_rate_numerator | integer | LOBI interception rate numerator |
| lobi_network_success_rate_denominator | integer | LOBI interception rate denominator |
| orbital_jamming_station_quantity | integer | Orbital jamming station count |
| advanced_orbital_jamming_station_quantity | integer | Advanced orbital jamming count |
| block_start_raid | integer | Block at which current raid started |

## Planet Raid (structs.planet_raid)

Tracks active raid status per planet. Separate from the planet table.

| Field | Type | Description |
|-------|------|-------------|
| planet_id | varchar | Planet ID (PK) |
| fleet_id | varchar | Raiding fleet ID |
| status | varchar | Raid status (active, victory, defeat, attackerRetreated) |
| updated_at | timestamptz | Last status change |
| seized_ore | numeric | Ore seized during raid |

`seized_ore` enables easier victory handling -- the amount of ore stolen is tracked directly on the raid record rather than requiring calculation from events.

## Relationships

| Relation | Entity | Schema |
|----------|--------|--------|
| owner | Player | [player.md](player.md) |
| structs (in slots) | Struct | [struct.md](struct.md) |
| raid | Planet Raid | `structs.planet_raid` |

## Verification

| Property | Value |
|----------|-------|
| Verified | Yes |
| Verified By | GameCodeAnalyst + DB verification |
| Verified Date | 2026-02-24 |
| Method | code-analysis + direct database inspection |
| Confidence | high |
| Code Reference | `x/structs/types/keys.go` (PlanetStartingOre = 5), `x/structs/keeper/planet_cache.go` |
| DB Reference | `structs.planet` (14 columns), `structs.planet_raid` (5 columns), `view.planet` (20 columns) verified |
| Verified Fields | maxOre, startingOre, status, remainingOre, seized_ore (planet_raid) |

API response schema. Starting properties verified: maxOre=5, slots=4 each. For code-based field definitions with formulas, see `schemas/entities.md#planet`.
