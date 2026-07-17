# Struct Types

**Purpose**: AI-readable reference for all buildable Structs. Stats, costs, power requirements, strategic role, and when to build. Struct types use **integer IDs** (not `type-index` format); query via `GET /structs/struct_type/{id}`.

> **Source-of-truth for the numbers:** the raw stat table is generated from the pinned chain
> source into [`generated/struct-types.md`](../../generated/struct-types.md) (provenance:
> `structsd v0.20.0`, regenerate with `scripts/gen-catalogs.py`). The prose below adds
> strategic context; if the two ever disagree, the generated catalog wins. CLI command names
> are catalogued separately in [`generated/commands.md`](../../generated/commands.md) (these
> are CLI names, distinct from proto message names).

---

## Complete Struct Type Table

All 22 struct types, verified from chain genesis. Power draws are in **watts** (the chain stores milliwatts; W = chain value ÷ 1,000 — see [energy.md — Units](../mechanics/energy.md#units)). **Limit** is the per-player build cap (`buildLimit`; `unlimited` = stackable).

| ID | Type | Category | Class | Build Diff | Build Draw | Passive Draw | Limit | Max HP | Possible Ambit | Ambits |
|----|------|----------|-------|------------|------------|--------------|-------|--------|----------------|--------|
| 1 | Command Ship | fleet | Command Ship | 200 | 50 W | 50 W | 1 | 6 | 30 | space, air, land, water |
| 2 | Battleship | fleet | Battleship | 765 | 135 W | 135 W | unlimited | 3 | 16 | space |
| 3 | Starfighter | fleet | Starfighter | 250 | 100 W | 100 W | unlimited | 3 | 16 | space |
| 4 | Frigate | fleet | Frigate | 450 | 75 W | 75 W | unlimited | 3 | 16 | space |
| 5 | Pursuit Fighter | fleet | Pursuit Fighter | 215 | 60 W | 60 W | unlimited | 3 | 8 | air |
| 6 | Stealth Bomber | fleet | Stealth Bomber | 455 | 125 W | 125 W | unlimited | 3 | 8 | air |
| 7 | High Altitude Interceptor | fleet | High Altitude Interceptor | 460 | 125 W | 125 W | unlimited | 3 | 8 | air |
| 8 | Mobile Artillery | fleet | Mobile Artillery | 305 | 75 W | 75 W | unlimited | 3 | 4 | land |
| 9 | Tank | fleet | Tank | 220 | 75 W | 75 W | unlimited | 3 | 4 | land |
| 10 | SAM Launcher | fleet | SAM Launcher | 450 | 75 W | 75 W | unlimited | 3 | 4 | land |
| 11 | Cruiser | fleet | Cruiser | 515 | 110 W | 110 W | unlimited | 3 | 2 | water |
| 12 | Destroyer | fleet | Destroyer | 600 | 100 W | 100 W | unlimited | 3 | 2 | water |
| 13 | Submersible | fleet | Submersible | 455 | 125 W | 125 W | unlimited | 3 | 2 | water |
| 14 | Ore Extractor | planet | Ore Extractor | 700 | 500 W | 500 W | 1 | 6 | 6 | land, water |
| 15 | Ore Refinery | planet | Ore Refinery | 700 | 500 W | 500 W | 1 | 6 | 6 | land, water |
| 16 | Orbital Shield Generator | planet | Orbital Shield Generator | 720 | 200 W | 200 W | unlimited | 6 | 16 | space |
| 17 | Jamming Satellite | planet | Jamming Satellite | 2,880 | 600 W | 600 W | 1 | 6 | 16 | space |
| 18 | Ore Bunker | planet | Ore Bunker | 3,600 | 750 W | 750 W | unlimited | 6 | 4 | land |
| 19 | Planetary Defense Cannon | planet | Planetary Defense Cannon | 2,880 | 600 W | 600 W | 1 | 6 | 6 | land, water |
| 20 | Field Generator | planet | Field Generator | 700 | 500 W | 500 W | 1 | 8 | 6 | land, water |
| 21 | Continental Power Plant | planet | Continental Power Plant | 1,440 | 10,000 W | 10,000 W | 1 | 10 | 6 | land, water |
| 22 | World Engine | planet | World Engine | 5,000 | 100,000 W | 100,000 W | 1 | 10 | 6 | land, water |

### Special Properties

| ID | Type | Special |
|----|------|---------|
| 1 | Command Ship | `is_command=true`, `movable=true` (only movable struct — can change ambits via `struct-move`), 1 per player, required for planet ops. **Can I rebuild after destruction? YES** — the old instance is gone, but you can build a brand new Command Ship (type 1, new struct ID, full PoW ~17 min at D=3). Choose starting ambit at build time. Until the replacement is online, the fleet cannot move, raid, or build in space. Protect at all costs. |
| 14 | Ore Extractor | `ore_mining_difficulty=14,000`, 1 per player |
| 15 | Ore Refinery | `ore_refining_difficulty=28,000`, 1 per player |
| 16 | Orbital Shield Generator | Shield contribution only (see below). Unlimited. |
| 17 | Jamming Satellite | 1 per player. Built in the space ambit. `noUnitDefenses`. Provides the planet's **low-orbit ballistic interceptor network** — a chance to **evade incoming _guided_ ordnance aimed at planetary structs on their own planet, regardless of attacker/target ambit**. Unguided ordnance passes through untouched. See [combat.md](../mechanics/combat.md#other-planetary-defense-structs) |
| 20 | Field Generator | `generating_rate=2` (2 kW per gram), 1 per player. `armour` unit defense, damage reduction 1. |
| 21 | Continental Power Plant | `generating_rate=5` (5 kW per gram), 1 per player. `armour` unit defense, damage reduction 1 |
| 22 | World Engine | `generating_rate=10` (10 kW per gram), 1 per player. `armour` unit defense, damage reduction 1 |

> The `generating_rate` values above (2/5/10) are the raw chain rate. In the Guild Stack DB this raw value is stored as `generating_rate_p`, and a `generating_rate` column is exposed as `generating_rate_p * 1000` — read `generating_rate_p` when you want the per-gram rate quoted here. See [integration-notes.md](../../api/integration-notes.md#struct_type-db-field-shapes).

Planet struct health: baseline planetary structs (Ore Extractor, Ore Refinery, Orbital Shield Generator, Jamming Satellite, Ore Bunker, Planetary Defense Cannon) have 6 HP; power generators are hardened higher (Field Generator 8, Continental Power Plant 10, World Engine 10) and carry `armour` (damage reduction 1), so disrupting a planet's power is a deliberate, costly raid objective. Armour-piercing weapons bypass that reduction (see Battleship). Fleet structs are unchanged: Command Ship 6 HP, all other fleet structs 3 HP.

### Planetary Shield Contributions

Planet structs that contribute to your planet's shield (a higher shield raises raid PoW difficulty for attackers). Shield values are scaled as fractions of the Command Ship rebuild window (BuildDifficulty 200), on top of a base shield of **25**:

| ID | Type | Shield Contribution | Build Limit |
|----|------|--------------------:|-------------|
| 16 | Orbital Shield Generator | 25 | unlimited |
| 17 | Jamming Satellite | 12 | 1 per player |
| 18 | Ore Bunker | 50 | unlimited |
| 19 | Planetary Defense Cannon | 13 | 1 per player |

A planet's shield = base 25 + the contributions of its **online** defense structs. One each of all four yields 25 + 25 + 12 + 50 + 13 = **125**. Orbital Shield Generator and Ore Bunker (the structs whose only effect is shield) are unlimited, so the practical maximum is power-gated — stack them to harden a planet. The shield only matters while the raid is winnable (the defender's Command Ship must be offline/destroyed — see [combat.md](../mechanics/combat.md)).

### Detailed Fleet Combat Properties

All fleet structs (IDs 1-13) deal 2 damage per primary weapon hit. DB-verified values below.

#### Attack Properties

| Struct | Charge | Weapon Type | Targets (Primary) | Secondary | Notes |
|--------|--------|-------------|--------------------|-----------| ------|
| Command Ship | 3 | guided | Local (current ambit only, flag 32) | — | Must `struct-move` to target's ambit first; "unreachable" error means wrong ambit |
| Battleship | 5 / 5 | unguided / guided | Land, Water | Space: 1 shot × 2 dmg | **Armour-piercing primary** (negates target damage reduction); anti-Tank/anti-generator on land + water. Guided secondary reaches space |
| Starfighter | 3 / 5 | guided / guided | Space / Space | Attack Run: 3 shots × 1 dmg (1 guaranteed hit + 2 shots @ 1/3) | Cheap primary; secondary floors at 1 hit per Attack Run (`secondaryWeaponGuaranteedShots = 1`) |
| Frigate | 5 | guided | Space, Air | — | Only space unit hitting air |
| Pursuit Fighter | 3 | guided | Air | — | Cheapest air offense |
| Stealth Bomber | 5 | guided | Land, Water | — | Stealth (2 charge to activate) |
| High Alt Interceptor | 5 | guided | Space, Air | — | Air-to-space capability |
| Mobile Artillery | 5 | unguided | Land, Water | — | Cannot counter-attack when attacked |
| Tank | 3 | unguided | Land | — | Damage reduction 1 (takes 3 normal hits to kill; armour-piercing ignores the reduction) |
| SAM Launcher | 5 | guided | Space, Air | — | Land-based anti-air/space |
| Cruiser | 5 / 3 | guided / unguided | Land, Water / Air | Secondary: 1 shot × 2 dmg (100% hit) | Most versatile; covers 3 ambits |
| Destroyer | 5 | guided | Air, Water | — | Enhanced counter-attack (2 dmg same-ambit) |
| Submersible | 5 | guided | Space, Water | — | Stealth (2 charge to activate) |

All primary weapons are blockable and counterable. **Armour-piercing** weapons (Battleship primary) negate the target's damage reduction during volley resolution. Armour-piercing is exposed on the struct type as explicit booleans (`primaryWeaponArmourPiercing` / `secondaryWeaponArmourPiercing`; chain v0.18.0), so read the flag rather than inferring from class. See [combat.md](../mechanics/combat.md) for full targeting and defense mechanics.

**Single-target**: every fleet weapon has `primaryWeaponTargets = 1` (and `secondaryWeaponTargets = 1` on the Battleship, Starfighter, and Cruiser) — one struct hit per volley. `struct-attack` accepts a comma list of target IDs, but a `targets = 1` weapon engages only one of them. This is distinct from multi-*shot* (`primaryWeaponShots`), which is multiple projectiles at a single target. See [combat.md](../mechanics/combat.md#targets-per-attack).

#### Defensive Properties

| Struct | Defense Type | Counter-Attack (cross / same) | Evasion | Dmg Reduction | Stealth | Notes |
|--------|-------------|-------------------------------|---------|---------------|---------|-------|
| Command Ship | `noUnitDefenses` | 2 / 2 | — | 0 | No | `trigger_raid_defeat_by_destruction` |
| Battleship | `signalJamming` | 1 / 1 | 66% vs guided | 0 | No | — |
| Starfighter | `noUnitDefenses` | 1 / 1 | — | 0 | No | — |
| Frigate | `noUnitDefenses` | 1 / 1 | — | 0 | No | — |
| Pursuit Fighter | `signalJamming` | 1 / 1 | 66% vs guided | 0 | No | — |
| Stealth Bomber | `stealthMode` | 1 / 1 | — | 0 | Yes | Same-ambit still targetable; attacking deactivates stealth |
| High Alt Interceptor | `defensiveManeuver` | 1 / 1 | 66% vs unguided | 0 | No | — |
| Mobile Artillery | `indirectCombatModule` | **none** | — | 0 | No | Cannot counter-attack when attacked |
| Tank | `armour` | 1 / 1 | — | **1** | No | Survives 3 hits instead of 2 |
| SAM Launcher | `noUnitDefenses` | 1 / 1 | — | 0 | No | — |
| Cruiser | `signalJamming` | 1 / 1 | 66% vs guided | 0 | No | — |
| Destroyer | `noUnitDefenses` | 1 / **2** | — | 0 | No | Best same-ambit counter-attacker |
| Submersible | `stealthMode` | 1 / 1 | — | 0 | Yes | Same-ambit still targetable; attacking deactivates stealth |

**Stealth Mode**: Stealthed structs can still be targeted by structs in the **same ambit** -- stealth only blocks cross-ambit targeting. Attacking instantly deactivates stealth (2 charge to re-activate).

#### Charge Costs (All Struct Types)

Charge is a single **per-player** bar (see [building.md](../mechanics/building.md#charge-accumulation)); these are the costs each action draws from it, not per-struct values.

| Action | Charge Cost |
|--------|-------------|
| Build initiate | 8 |
| Activate | 2 |
| Attack (primary) | 3-5 (varies per struct, see table above) |
| Attack (secondary) | 3-5 (Battleship/Starfighter 5, Cruiser 3) |
| Defend change | 1 |
| Move (Command Ship only) | 3 |
| Stealth activate | 2 |

At 1 charge per block (~6 seconds), plan ~30 seconds of idle accumulation between 5-charge actions. The bar is shared across all the player's structs.

### Weapon Target Ambits

Each weapon can only hit specific ambits. The `primaryWeaponAmbits` field is a bitmask (Space=16, Air=8, Land=4, Water=2).

#### Threatened-By Matrix

Which structs can attack into each ambit:

| Target Ambit | Threatened By |
|--------------|---------------|
| Space | Battleship (secondary), Starfighter, Frigate, High Alt Interceptor, SAM Launcher, Submersible |
| Air | Frigate, Pursuit Fighter, High Alt Interceptor, SAM Launcher, Cruiser (secondary), Destroyer |
| Land | Battleship, Stealth Bomber, Mobile Artillery, Tank, Cruiser |
| Water | Battleship, Stealth Bomber, Mobile Artillery, Cruiser, Destroyer, Submersible |

Battleship's armour-piercing primary covers Land and Water (ignoring damage reduction on Tanks and generators); its guided secondary reaches Space.

The Command Ship can attack into any ambit but must first move there via `struct-move`.

---

## Ambit Bit-Flag Encoding

The `possibleAmbit` field (and the weapon-reach fields `primaryWeaponAmbits` / `secondaryWeaponAmbits`) is a bit-flag integer encoding which ambits apply. Each bit is `1 << enum`:

| Ambit | Bit Value |
|-------|-----------|
| none | 1 |
| Water | 2 |
| Land | 4 |
| Air | 8 |
| Space | 16 |
| local | 32 |

The four combat ambits are Water/Land/Air/Space; `none` (1) is a placeholder and `local` (32) is the Command Ship's current-ambit flag. Values are combined. For example:
- `6` = Land (4) + Water (2) — most planet structs
- `8` = Air only — air fleet units
- `16` = Space only — space fleet units, orbital planet structs
- `30` = Space (16) + Air (8) + Land (4) + Water (2) — Command Ship only

This **reach bitmask** is a different scale from the **ambit enum** (none=0, water=1, land=2, air=3, space=4, local=5) used by transaction messages and a struct's stored `operatingAmbit`. When initiating a build or moving, pass the enum (the CLI accepts the name `space|air|land|water`), not the bitmask number. See [building.md — Ambit Encoding](../mechanics/building.md#ambit-encoding) and [api/integration-notes.md — Ambit](../../api/integration-notes.md#ambit-enum-vs-reach-bitmask).

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

`activateCharge` = 2, `buildCharge` = 8, `defendChangeCharge` = 1 for all struct types (charge is a per-player bar). Most planet structs and the Command Ship are limited to 1 per player; Orbital Shield Generator and Ore Bunker (shield-only) and fleet combat structs (IDs 2-13) have no build limit.

---

## Query

- **Single type**: `GET /structs/struct_type/{id}` (id = integer, e.g. `1`, `2`)
- **All types**: `GET /structs/struct_type`
- **CLI**: `structsd query structs struct-type [id]` or `structsd query structs struct-type-all`

---

## See Also

- [entity-relationships.md](entity-relationships.md) — Struct ownership, location
- [power.md](../mechanics/power.md) — BuildDraw, PassiveDraw, capacity
- [building.md](../mechanics/building.md) — Build process, proof-of-work, -D flag
- [building.md — Status field (numeric)](../mechanics/building.md#status-field-numeric) — Canonical decoder for the numeric struct `status` bitmask
- [resources.md](../mechanics/resources.md) — Conversion rates, ore flow
- [combat.md](../mechanics/combat.md) — Combat struct roles
- [valuation.md](../economy/valuation.md) — Struct valuation
- `schemas/entities/struct-type.md` — Full schema
- `reference/action-quick-reference.md` — Build actions
