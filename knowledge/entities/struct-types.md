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
| 1 | Command Ship | `is_command=true`, `movable=true` (only movable struct — can change ambits via `struct-move`), 1 per player, required for planet ops. If destroyed, the specific instance is gone forever and **cannot be repaired**. However, you **can build a new Command Ship** (type 1) as a replacement — full build PoW required. Until the replacement is online, the fleet cannot move, raid, or build in space. Protect at all costs. |
| 14 | Ore Extractor | `ore_mining_difficulty=14,000`, 1 per player |
| 15 | Ore Refinery | `ore_refining_difficulty=28,000`, 1 per player |
| 20 | Field Generator | `generating_rate=2` (2 kW per gram), 1 per player |
| 21 | Continental Power Plant | `generating_rate=5` (5 kW per gram), 1 per player |
| 22 | World Engine | `generating_rate=10` (10 kW per gram), 1 per player |

### Planetary Shield Contributions

Planet structs that contribute to your planet's shield (reduces raid PoW difficulty for attackers):

| ID | Type | Shield Contribution | Build Limit |
|----|------|--------------------:|-------------|
| 16 | Orbital Shield Generator | 1,500 | 1 per player |
| 17 | Jamming Satellite | 4,500 | 1 per player |
| 18 | Ore Bunker | **9,000** | 1 per player |
| 19 | Planetary Defense Cannon | 4,500 | 1 per player |

Total maximum shield per player: 19,500 (from all four). All planet structs have a build limit of 1 per player.

### Detailed Fleet Combat Properties

All fleet structs (IDs 1-13) deal 2 damage per primary weapon hit. DB-verified values below.

#### Attack Properties

| Struct | Charge | Weapon Type | Targets (Primary) | Secondary | Notes |
|--------|--------|-------------|--------------------|-----------| ------|
| Command Ship | 1 | guided | Current ambit only | — | Must `struct-move` to target's ambit first |
| Battleship | 20 | unguided | Space, Land, Water | — | Highest charge cost; broadest space coverage |
| Starfighter | 1 / 8 | guided / guided | Space / Space | Attack Run: 3 shots × 1 dmg (1/3 hit each) | Cheap primary; secondary is a gamble |
| Frigate | 8 | guided | Space, Air | — | Only space unit hitting air |
| Pursuit Fighter | 1 | guided | Air | — | Cheapest air offense |
| Stealth Bomber | 8 | guided | Land, Water | — | Stealth (1 charge to activate) |
| High Alt Interceptor | 8 | guided | Space, Air | — | Air-to-space capability |
| Mobile Artillery | 8 | unguided | Land, Water | — | Cannot counter-attack when attacked |
| Tank | 1 | unguided | Land | — | Damage reduction: 1 (takes 3 hits to kill) |
| SAM Launcher | 8 | guided | Space, Air | — | Land-based anti-air/space |
| Cruiser | 8 / 1 | guided / unguided | Land, Water / Air | Secondary: 1 shot × 2 dmg (100% hit) | Most versatile; covers 3 ambits |
| Destroyer | 8 | guided | Air, Water | — | Enhanced counter-attack (2 dmg same-ambit) |
| Submersible | 8 | guided | Space, Water | — | Stealth (1 charge to activate) |

All primary weapons are blockable and counterable. See [combat.md](../mechanics/combat.md) for full targeting and defense mechanics.

#### Defensive Properties

| Struct | Counter-Attack (cross / same ambit) | Evasion | Damage Reduction | Stealth | Special |
|--------|--------------------------------------|---------|------------------|---------|---------|
| Command Ship | 2 / 2 | — | 0 | No | `trigger_raid_defeat_by_destruction` |
| Battleship | 1 / 1 | 66% vs guided (2/3) | 0 | No | Signal jamming |
| Starfighter | 1 / 1 | — | 0 | No | — |
| Frigate | 1 / 1 | — | 0 | No | — |
| Pursuit Fighter | 1 / 1 | 66% vs guided (2/3) | 0 | No | Signal jamming |
| Stealth Bomber | 1 / 1 | — | 0 | Yes | Hidden until attacking |
| High Alt Interceptor | 1 / 1 | 66% vs unguided (2/3) | 0 | No | Armour vs unguided |
| Mobile Artillery | **none** | — | 0 | No | Pure offense; cannot counter-attack |
| Tank | 1 / 1 | — | **1** | No | Survives 3 hits instead of 2 |
| SAM Launcher | 1 / 1 | — | 0 | No | — |
| Cruiser | 1 / 1 | 66% vs guided (2/3) | 0 | No | Signal jamming |
| Destroyer | 1 / **2** | — | 0 | No | Best same-ambit counter-attacker |
| Submersible | 1 / 1 | — | 0 | Yes | Hidden until attacking |

#### Charge Costs (All Struct Types)

| Action | Charge Cost |
|--------|-------------|
| Build initiate | 8 |
| Activate | 1 |
| Attack (primary) | 1-20 (varies per struct, see table above) |
| Defend change | 1 |
| Move (Command Ship only) | 8 |
| Stealth activate | 1 |

At 1 charge per block (~6 seconds), plan ~48 seconds between actions costing 8 charge.

### Weapon Target Ambits

Each weapon can only hit specific ambits. The `primaryWeaponAmbits` field is a bitmask (Space=16, Air=8, Land=4, Water=2).

#### Threatened-By Matrix

Which structs can attack into each ambit:

| Target Ambit | Threatened By |
|--------------|---------------|
| Space | Battleship, Starfighter, Frigate, High Alt Interceptor, SAM Launcher, Submersible |
| Air | Frigate, Pursuit Fighter, High Alt Interceptor, SAM Launcher, Cruiser (secondary), Destroyer |
| Land | Battleship, Stealth Bomber, Mobile Artillery, Tank, Cruiser |
| Water | Battleship, Stealth Bomber, Mobile Artillery, Cruiser, Destroyer, Submersible |

The Command Ship can attack into any ambit but must first move there via `struct-move`.

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

`activateCharge` = 1, `buildCharge` = 8, `defendChangeCharge` = 1 for all struct types. All planet structs have a build limit of 1 per player. Command Ship is limited to 1 per player. Fleet combat structs (IDs 2-13) have no build limit.

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
