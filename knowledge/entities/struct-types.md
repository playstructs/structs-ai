# Struct Types

**Purpose**: AI-readable reference for all buildable Structs. Stats, costs, power requirements, strategic role, and when to build. Struct types use **integer IDs** (not `type-index` format); query via `GET /structs/struct_type/{id}`.

---

## Complete Struct Type Table

All 22 struct types, verified from the database. Draw values are in kW (multiply by 1,000 for in-game watts).

| ID | Type | Category | Class | Build Diff | Build Draw | Passive Draw | Max HP | Possible Ambit | Ambits |
|----|------|----------|-------|------------|------------|--------------|--------|----------------|--------|
| 1 | Command Ship | fleet | Command Ship | 200 | 50 kW | 50 kW | 6 | 30 | space, air, land, water |
| 2 | Battleship | fleet | Battleship | 765 | 135 kW | 135 kW | 3 | 16 | space |
| 3 | Starfighter | fleet | Starfighter | 250 | 100 kW | 100 kW | 3 | 16 | space |
| 4 | Frigate | fleet | Frigate | 450 | 75 kW | 75 kW | 3 | 16 | space |
| 5 | Pursuit Fighter | fleet | Pursuit Fighter | 215 | 60 kW | 60 kW | 3 | 8 | air |
| 6 | Stealth Bomber | fleet | Stealth Bomber | 455 | 125 kW | 125 kW | 3 | 8 | air |
| 7 | High Altitude Interceptor | fleet | High Altitude Interceptor | 460 | 125 kW | 125 kW | 3 | 8 | air |
| 8 | Mobile Artillery | fleet | Mobile Artillery | 305 | 75 kW | 75 kW | 3 | 4 | land |
| 9 | Tank | fleet | Tank | 220 | 75 kW | 75 kW | 3 | 4 | land |
| 10 | SAM Launcher | fleet | SAM Launcher | 450 | 75 kW | 75 kW | 3 | 4 | land |
| 11 | Cruiser | fleet | Cruiser | 515 | 110 kW | 110 kW | 3 | 2 | water |
| 12 | Destroyer | fleet | Destroyer | 600 | 100 kW | 100 kW | 3 | 2 | water |
| 13 | Submersible | fleet | Submersible | 455 | 125 kW | 125 kW | 3 | 2 | water |
| 14 | Ore Extractor | planet | Ore Extractor | 700 | 500 kW | 500 kW | 3 | 6 | land, water |
| 15 | Ore Refinery | planet | Ore Refinery | 700 | 500 kW | 500 kW | 3 | 6 | land, water |
| 16 | Orbital Shield Generator | planet | Orbital Shield Generator | 720 | 200 kW | 200 kW | 3 | 16 | space |
| 17 | Jamming Satellite | planet | Jamming Satellite | 2,880 | 600 kW | 600 kW | 3 | 16 | space |
| 18 | Ore Bunker | planet | Ore Bunker | 3,600 | 750 kW | 750 kW | 3 | 4 | land |
| 19 | Planetary Defense Cannon | planet | Planetary Defense Cannon | 2,880 | 600 kW | 600 kW | 3 | 6 | land, water |
| 20 | Field Generator | planet | Field Generator | 700 | 500 kW | 500 kW | 3 | 6 | land, water |
| 21 | Continental Power Plant | planet | Continental Power Plant | 1,440 | 10,000 kW | 10,000 kW | 3 | 6 | land, water |
| 22 | World Engine | planet | World Engine | 5,000 | 100,000 kW | 100,000 kW | 3 | 6 | land, water |

### Special Properties

| ID | Type | Special |
|----|------|---------|
| 1 | Command Ship | `is_command=true`, 1 per player, required for planet ops. If destroyed, fleet is inoperable until a replacement is built (full PoW). Protect at all costs. |
| 14 | Ore Extractor | `ore_mining_difficulty=14,000` |
| 15 | Ore Refinery | `ore_refining_difficulty=28,000` |
| 19 | PDC | 1 per player, planetary shield contribution |
| 20 | Field Generator | `generating_rate=2` (2 kW per gram) |
| 21 | Continental Power Plant | `generating_rate=5` (5 kW per gram) |
| 22 | World Engine | `generating_rate=10` (10 kW per gram) |

### Combat Stats (Fleet)

All fleet structs (IDs 1-13) have `primary_weapon_damage=2`. Only Starfighter (3) and Cruiser (11) have `secondary_weapon_damage` (1 and 2 respectively).

---

## Ambit Bit-Flag Encoding

The `possibleAmbit` field is a bit-flag integer encoding which ambits a struct can operate in:

| Ambit | Bit Value |
|-------|-----------|
| Space | 16 |
| Air | 8 |
| Land | 4 |
| Water | 2 |

Values are combined. For example:
- `6` = Land (4) + Water (2) — most planet structs
- `8` = Air only — air fleet units
- `16` = Space only — space fleet units, orbital planet structs
- `30` = Space (16) + Air (8) + Land (4) + Water (2) — Command Ship only

When initiating a build, the `[operating-ambit]` argument must be one of the valid ambits for that struct type.

---

## Categories

### Fleet (IDs 1-13)

Fleet structs are combat units that operate in the fleet. The Command Ship (type 1) is special: only 1 per player, required for all planet operations, and can operate in any ambit.

| Ambit | Units |
|-------|-------|
| Space | Command Ship, Battleship, Starfighter, Frigate |
| Air | Pursuit Fighter, Stealth Bomber, High Altitude Interceptor |
| Land | Mobile Artillery, Tank, SAM Launcher |
| Water | Cruiser, Destroyer, Submersible |

### Planet (IDs 14-22)

Planet structs are infrastructure built on a claimed planet. Require fleet on station and Command Ship online.

| Role | Units |
|------|-------|
| Resource extraction | Ore Extractor, Ore Refinery, Ore Bunker |
| Defense | Planetary Defense Cannon, Orbital Shield Generator, Jamming Satellite |
| Power generation | Field Generator, Continental Power Plant, World Engine |

---

## Build Requirements Summary

| Requirement | Notes |
|-------------|-------|
| Power | BuildDraw + PassiveDraw available; see [power.md](../mechanics/power.md) |
| Resources | Alpha Matter for build cost |
| Location | Correct ambit per `possibleAmbit`; slot 0-3 |
| Fleet on station | For planet building |
| Command Ship online | For planet building |
| Proof-of-work | `struct-build-compute` handles hash + submit |

`activateCharge` = 1 for all struct types. Build limits: 1 PDC and 1 Command Ship per player.

---

## Query

- **Single type**: `GET /structs/struct_type/{id}` (id = integer, e.g. `1`, `2`)
- **All types**: `GET /structs/struct_type`
- **CLI**: `structsd query structs struct-type [id]` or `structsd query structs struct-type-all`
- **With cosmetics**: Webapp `GET /api/struct-type/{id}/full?class={class}`

---

## See Also

- [entity-relationships.md](entity-relationships.md) — Struct ownership, location
- [power.md](../mechanics/power.md) — BuildDraw, PassiveDraw, capacity
- [building.md](../mechanics/building.md) — Build process, proof-of-work, -D flag
- [resources.md](../mechanics/resources.md) — Conversion rates, ore flow
- [combat.md](../mechanics/combat.md) — Combat struct roles
- [valuation.md](../economy/valuation.md) — Struct valuation
- `schemas/entities/struct-type.md` — Full schema
- `reference/action-quick-reference.md` — Build actions
