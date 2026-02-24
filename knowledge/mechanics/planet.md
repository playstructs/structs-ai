# Planet Mechanics

**Purpose**: AI-readable reference for Structs planet system. Lifecycle, ore depletion, exploration, charting.

---

## Planet Lifecycle

| Status | Condition |
|--------|-----------|
| active | Has remaining ore |
| complete | Ore depleted (0) |

---

## Ore Depletion

When planet ore reaches 0:

- Planet status becomes `complete`
- All structs on the planet are destroyed
- All fleets are automatically sent away (peace deal)
- Player must explore a new planet to continue

**Strategy options before depletion**: Keep some ore in reserve. Move critical operations before the last ore is mined. Accept completion and rebuild elsewhere.

---

## Starting Properties

| Property | Value |
|----------|-------|
| maxOre | 5 |
| spaceSlots | 4 |
| airSlots | 4 |
| landSlots | 4 |
| waterSlots | 4 |

All newly explored planets start with identical properties.

---

## Exploration

- Creates new planet with fresh ore and slots
- Fleet moves to new planet
- Old planet released (old structures remain if ore remains; other players can claim it)
- Chart new planet to reveal resource attributes before committing
- **Requirement**: Current planet must be complete (ore depleted) before exploring
- **Ownership**: One planet per player at a time

---

## Charting

- Planet attributes queryable via `planet_attribute` endpoints
- Resource charting informs mining strategy

---

## Raid Vulnerability

- Unrefined ore (storedOre) on player can be stolen during raids
- Ore on planet is mined by owner; raiders steal from player's storedOre after successful raid
- **Seized ore tracking**: The `planet_raid` table includes a `seized_ore` field that records the amount of ore stolen during a raid, simplifying victory determination and activity feeds.
- See [combat.md](combat.md), [resources.md](resources.md)

---

## See Also

- [resources.md](resources.md) — Ore mining, planet starting ore
- [fleet.md](fleet.md) — Exploration, fleet movement
- [combat.md](combat.md) — Raids, planet defense
- `schemas/entities.md` — Planet entity, ownership rules
- `api/queries/planet.md` — Planet query endpoints
- `schemas/formats.md` — Planet ID format (2-{index})
