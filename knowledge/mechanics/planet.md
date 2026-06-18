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
- Optional planet name at explore time: `planet-explore [player-id] [name]` — validated before explore burns state (same rules as `MsgPlanetUpdateName`)
- Explore does not consume the player's charge bar
- Old planet released (old structures remain if ore remains; other players can claim it)
- Chart new planet to reveal resource attributes before committing
- **Requirement (existing players)**: Current planet must be complete (ore depleted) before exploring AND the fleet must be `onStation` at the current planet, not `away`. Recall the fleet first if needed via `fleet-move`.
- **Requirement (first-time players)**: No fleet check applies — a brand-new player with no current planet can call `planet-explore` immediately after creation. The chain only enforces the fleet/ore checks for players who already own a planet.
- **Ownership**: One planet per player at a time

---

## Charting

- Planet attributes queryable via `planet_attribute` endpoints
- Resource charting informs mining strategy

---

## Raid Vulnerability

- **What gets stolen**: The player's `storedOre` (mined but unrefined ore). Raids seize ore from the player who owns the planet, not from the planet itself.
- **What is NOT at risk**: The planet's `remainingOre` (unmined ore still in the ground). Unmined ore can only be extracted by an Ore Extractor — raiders cannot touch it.
- Once ore is refined into Alpha Matter, it is cryptographically secure and cannot be stolen.
- **Shields gate the raid**: A planet can only be raided to completion while the owner's **Command Ship is offline, destroyed, or non-existent** (`shieldsVulnerable`). While your Command Ship is online, raids against you are rejected. Keeping the Command Ship online — and well defended — is the primary raid defense. See the raid phases in [combat.md](combat.md#raid-phases-and-shields_vulnerable).
- **A raid only steals ore**: A successful raid seizes **all** `storedOre` and nothing more — it does not destroy the player or their structs. Killing the defender's Command Ship opens the `shieldsVulnerable` window that lets the raid complete; if the defender restores or rebuilds the Command Ship before completion, the raid is rejected (`shields_active`). The `trigger_raid_defeat_by_destruction` property defeats an attacking fleet: if the **raider's** Command Ship is destroyed while away from home, the raiding fleet is defeated (`attackerDefeated`). See [combat.md — what a raid does](combat.md#what-a-raid-does).
- **Planetary defense beyond shields**: The Jamming Satellite struct provides a low-orbit ballistic interceptor network that can **evade air/space attacks against the planet's land/water structs** (`evadedByPlanetaryDefenses`). See [combat.md — Other Planetary Defense Structs](combat.md#other-planetary-defense-structs).
- **Seized ore tracking**: The `planet_raid` table includes a `seized_ore` field that records the amount of ore stolen from the player during a raid.
- See [combat.md](combat.md), [resources.md](resources.md)

---

## See Also

- [resources.md](resources.md) — Ore mining, planet starting ore
- [fleet.md](fleet.md) — Exploration, fleet movement
- [combat.md](combat.md) — Raids, planet defense
- `schemas/entities.md` — Planet entity, ownership rules
- `api/queries/planet.md` — Planet query endpoints
- `schemas/formats.md` — Planet ID format (2-{index})
