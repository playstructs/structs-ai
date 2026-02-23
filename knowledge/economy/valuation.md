# Valuation

**Purpose**: AI-readable framework for valuing Structs game assets. Planets, structs, positions. Supports economic decision-making.

---

## Overview

Valuation in Structs is contextual—assets derive value from ore, location, infrastructure, defensive capability, and alliance position. This document provides a framework, not fixed formulas. Use for raid target selection, trade evaluation, and expansion planning.

---

## Planet Valuation

| Factor | Weight | Notes |
|--------|--------|-------|
| **Remaining ore** | High | 5 max at discovery; depletes to 0 → planet destroyed |
| **Slot availability** | Medium | space/air/land/water slots (4 each default); constrains struct count |
| **Infrastructure** | High | Structs built, reactors, substations, defense |
| **Location** | Variable | Proximity to guild, raid targets, trade routes |
| **Shield health** | Medium | Planetary Defense Cannon + base; raid resistance |

**Depletion risk**: Planet with 0 ore is destroyed with all structs. Value drops to zero at depletion.

---

## Struct Valuation

| Factor | Weight | Notes |
|--------|--------|-------|
| **Type** | High | Power producers > extractors > defense > utility (context-dependent) |
| **Power output** | High | Reactor 1g→1kW; World Engine 1g→10kW; see [struct-types.md](../entities/struct-types.md) |
| **Defensive value** | Medium | Planetary Defense Cannon (1 per player), combat structs |
| **Build cost** | Medium | Alpha Matter + proof-of-work; sunk cost |
| **Status** | High | Online > built > building; offline structs have no operational value |

**Strategic role**: Ore Extractor enables mining; Refinery converts to Alpha Matter; Reactors produce power; Command Ship enables building/raiding. Value chain matters.

---

## Position Valuation

| Factor | Weight | Notes |
|--------|--------|-------|
| **Territory** | High | Planets owned, struct count, fleet composition |
| **Resources** | High | Stored ore (raid-vulnerable), Alpha Matter (secure), energy capacity |
| **Alliances** | Medium | Guild membership, energy agreements, mercenary contracts |
| **Defensive posture** | Medium | Shield health, PDC count, fleet readiness |
| **Operational readiness** | High | Player online, power surplus, charge available |

---

## Economic Decision Framework

| Decision | Key Inputs |
|----------|-------------|
| **Raid target** | storedOre, shield health, defender online status, struct value |
| **Build priority** | Power capacity vs. load, ore availability, struct type ROI |
| **Trade evaluation** | Alpha Matter price, energy agreement terms, guild token credibility |
| **Expansion** | Planet ore remaining, slot availability, power headroom |

---

## Caveats

- **Ore vs. Alpha Matter**: Ore is stealable; Alpha Matter is not. Refine quickly.
- **Energy ephemerality**: Energy cannot be stored; value is in capacity agreements and conversion efficiency.
- **Guild tokens**: Value depends on collateral ratio; not guaranteed.

---

## See Also

- [struct-types.md](../entities/struct-types.md) — Struct stats, costs, strategic role
- [entity-relationships.md](../entities/entity-relationships.md) — Ownership and economic graphs
- [energy-market.md](energy-market.md) — Energy capacity value
- [guild-banking.md](guild-banking.md) — Token valuation
- [planet.md](../mechanics/planet.md) — Planet lifecycle, ore depletion
- [combat.md](../mechanics/combat.md) — Raid outcomes, loot
