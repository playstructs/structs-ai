# Power (Quick Reference)

**Purpose**: Fast formula card for capacity, load, and online status. For the full system — units, infusion 96/4, substation `connectionCapacity` dilution, allocations, and the `GridCascade` brownout — see [energy.md](energy.md). For workflows (infusing, wiring substations, offline recovery) see the [structs-energy skill](https://structs.ai/skills/structs-energy/SKILL).

---

## Units

The chain stores power in **milliwatts**: 1 W = 1,000 chain units, 1 kW = 1,000,000. Player base draw is `25000` = **25 W**; **1 ualpha infused = 1 mW**, so **1 gram of Alpha = 1 kW**. See [energy.md — Units](energy.md#units).

---

## Core formulas

```
online         = (load + structsLoad) <= (capacity + capacitySecondary)
availablePower = (capacity + capacitySecondary) - (load + structsLoad)
allocatable    = capacity - load
```

| Term | Meaning |
|------|---------|
| `capacity` | Your own generation (infusions). The only capacity you can allocate **out**. |
| `capacitySecondary` | Received from a substation you're connected to (its `connectionCapacity`). Not re-allocatable. |
| `load` | Power you've allocated out. |
| `structsLoad` | Player passive draw (25 W) + sum of `passiveDraw` of your online structs. |

If `load + structsLoad` exceeds `capacity + capacitySecondary`, the player goes **offline** and cannot act until load is reduced (deactivate structs) or capacity raised (infuse/agreement). Online is checked **per message**; recovery actions are never gated. **Energy is per-block and ephemeral** — idle capacity is waste, not savings.

---

## Struct power requirements

Each struct needs `BuildDraw` while building **and** `PassiveDraw` once online (both must fit available capacity). Examples (watts):

| Struct | Build | Passive | Total while building |
|--------|-------|---------|----------------------|
| Ore Extractor | 500 W | 500 W | 1,000 W |
| Planetary Defense Cannon | 600 W | 600 W | 1,200 W |
| Ore Bunker | 750 W | 750 W | 1,500 W |

Build draw is temporary and releases when the build completes. Full per-struct draws and build limits: [struct-types.md](../entities/struct-types.md#complete-struct-type-table).

---

## New player power budget

New players usually start with zero personal `capacity` and rely on `capacitySecondary` from their guild substation. Cumulative load through the standard onboarding build order:

| Item | Build Draw | Passive Draw | Cumulative Load |
|------|------------|--------------|-----------------|
| Player (base) | — | 25 W | 25 W |
| Command Ship (build) | 50 W | — | 75 W |
| Command Ship (online) | — | 50 W | 75 W |
| Ore Extractor (build) | 500 W | — | 575 W |
| Ore Extractor (online) | — | 500 W | 575 W |
| Ore Refinery (build) | 500 W | — | 1,075 W |
| Ore Refinery (online) | — | 500 W | 1,075 W |

Worst-case load during onboarding is ~1,075 W (all three structs online plus a build in progress). **Minimum viable capacity**: ~575 W for player + Command Ship + Ore Extractor online. If the guild substation provides less, activate the Command Ship first, then build one struct at a time.

---

## Power states

| Entity | Online When |
|--------|-------------|
| Player | `availablePower ≥ 0` |
| Struct | available capacity `≥ struct.passiveDraw` |

**False positive**: a player on a substation pool can show `capacity = 0` while structs run fine — the substation supplies `capacitySecondary`. Use `structsLoad > 0` as the real "functioning" signal, not `capacity > 0`.

---

## Increasing capacity

Reactor infusion (safe, reversible, you keep ~96%), generator infusion (more kW/gram but irreversible and raidable), or buying via an agreement. Rates, the 96/4 split, and substation distribution are in [energy.md](energy.md#increasing-your-own-capacity).

---

## See Also

- [energy.md](energy.md) — Full energy system: units, infusion split, substations, allocations, brownout
- [building.md](building.md) — Build power requirements
- [struct-types.md](../entities/struct-types.md) — Per-struct BuildDraw/PassiveDraw, limits
- [resources.md](resources.md) — Energy from Alpha Matter
- [structs-energy skill](https://structs.ai/skills/structs-energy/SKILL) — Infusion, substations, offline recovery
