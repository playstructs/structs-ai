# Struct Types

**Purpose**: AI-readable reference for all buildable Structs. Stats, costs, power requirements, strategic role, and when to build. Struct types use **integer IDs** (not `type-index` format); query via `GET /structs/struct_type/{id}`.

---

## Categories

Struct types belong to categories: `fleet`, `mining`, `refining`, `power`, `combat`, `defense`, `utility`. Each struct has `buildDraw`, `passiveDraw`, `buildDifficulty`, `activateCharge`, and category-specific properties.

---

## Resource Extraction (mining)

| Struct | Class | Build | Passive | Strategic Role | When to Build |
|--------|-------|-------|---------|----------------|---------------|
| **Ore Extractor** | Miner | 500,000 W | 500,000 W | Mines ore from planet; 1 ore per operation | First priority on new planet; enables refinement chain |
| **Ore Bunker** | — | 200,000 W | 200,000 W | Stores ore (stealable); buffers mining output | After Extractor; before Refinery; ore is raid-vulnerable |

**Mining**: `struct-ore-miner-complete` with proof-of-work (difficulty 14,000). Ore → storedOre (player) → refine to Alpha Matter.

---

## Refining (refining)

| Struct | Class | Strategic Role | When to Build |
|--------|-------|----------------|---------------|
| **Ore Refinery** | — | Converts ore → Alpha Matter (1:1); proof-of-work (28,000) | Immediately after Extractor; refine ASAP to secure ore |

**Refining**: `struct-ore-refinery-complete`. Alpha Matter is non-stealable; ore is not.

---

## Energy Production (power)

| Struct | Class | Rate | Risk | Strategic Role | When to Build |
|--------|-------|------|------|----------------|---------------|
| **Reactor** | Reactor | 1g = 1 kW | Low | Baseline power; reliable | First power struct; redundancy |
| **Field Generator** | — | 1g = 2 kW | High | 2× efficiency | When risk acceptable; diversify |
| **Continental Power Plant** | — | 1g = 5 kW | High | 5× efficiency | High output needs; backup recommended |
| **World Engine** | — | 1g = 10 kW | High | 10× efficiency | Maximum output; single point of failure risk |

**Reactor vs. Generators**: Reactors are safe but inefficient. Generators offer 2–10× output per gram but carry failure risk. Balance redundancy vs. efficiency.

---

## Defense (defense)

| Struct | Class | Build | Passive | Limit | Strategic Role | When to Build |
|--------|-------|-------|---------|-------|----------------|---------------|
| **Planetary Defense Cannon** | — | 600,000 W | 600,000 W | 1 per player | Planet shield damage; raid defense | After power grid; before high-value structs |

**Shield**: `planetaryShieldBase + sum(PDC damage)`. Limit: 1 PDC per player globally.

---

## Fleet (fleet)

| Struct | Class | Limit | Strategic Role | When to Build |
|--------|-------|-------|----------------|---------------|
| **Command Ship** | Command Ship | 1 per player | Enables building on planet, raids; must be online | Required for planet ops; build early |

**Requirements**: Fleet on station + Command Ship online = build on planet. Fleet away + Command Ship online = raid. Without Command Ship, neither possible.

---

## Combat (combat)

Combat structs have `primaryWeapon`, `primaryWeaponDamage`, `maxHealth`, evasion/blocking. Deploy on fleet for raids or planet defense. See [combat.md](../mechanics/combat.md) for damage formulas.

---

## Utility

| Struct | Role |
|--------|------|
| **Substation** | Power distribution; connects reactors to players; not a struct type—separate entity (type 4) |

Substations are entities (ID `4-{index}`), not structs. Reactors (type 3) feed substations; players connect via `substation-player-connect`.

---

## Build Requirements Summary

| Requirement | Notes |
|-------------|-------|
| Power | BuildDraw + PassiveDraw available; see [power.md](../mechanics/power.md) |
| Resources | Alpha Matter for build cost |
| Location | Correct slot (space/air/land/water) per `possibleAmbit` |
| Fleet on station | For planet building |
| Command Ship online | For planet building |
| Proof-of-work | `struct-build-complete`; age-based difficulty |

**Charge**: `activateCharge` = 1 for all struct types (v0.10.0-beta).

---

## Query

- **Single type**: `GET /structs/struct_type/{id}` (id = integer, e.g. `1`, `2`)
- **All types**: `GET /structs/struct_type`
- **With cosmetics**: Webapp `GET /api/struct-type/{id}/full?class={class}`

---

## See Also

- [entity-relationships.md](entity-relationships.md) — Struct ownership, location
- [power.md](../mechanics/power.md) — BuildDraw, PassiveDraw, capacity
- [building.md](../mechanics/building.md) — Two-step build, proof-of-work
- [resources.md](../mechanics/resources.md) — Conversion rates, ore flow
- [combat.md](../mechanics/combat.md) — Combat struct roles
- [valuation.md](../economy/valuation.md) — Struct valuation
- `schemas/entities/struct-type.md` — Full schema
- `reference/action-quick-reference.md` — Build actions
