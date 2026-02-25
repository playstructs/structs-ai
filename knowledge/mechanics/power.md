# Power Mechanics

**Purpose**: AI-readable reference for Structs power system. Capacity, load, online status, struct requirements.

---

## Core Formulas

### Capacity

```
totalCapacity = capacity + capacitySecondary
```

| Term | Source |
|------|--------|
| capacity | Primary (substation connection) |
| capacitySecondary | Secondary (additional substation) |

### Load

```
totalLoad = load + structsLoad
```

| Term | Source |
|------|--------|
| load | Base player load (active operations) |
| structsLoad | Sum of all online struct PassiveDraw |

### Available Power

```
availablePower = (capacity + capacitySecondary) - (load + structsLoad)
```

### Online Status

```
playerOnline = (load + structsLoad) <= (capacity + capacitySecondary)
```

If offline: player halted, cannot perform actions.

---

## Player Passive Draw

```
playerPassiveDraw = 25,000 milliwatts (25 watts)
```

Base consumption when player is online.

---

## Struct Power Requirements

Each struct has:

| Requirement | When Applied |
|-------------|--------------|
| BuildDraw | During building |
| PassiveDraw | When struct is online |

**Total for new struct**: `buildPower + passivePower` must be available.

### Example Struct Requirements

| Struct | Build | Passive | Total |
|--------|-------|---------|-------|
| Ore Extractor | 500,000 W | 500,000 W | 1,000,000 W |
| Planetary Defense Cannon | 600,000 W | 600,000 W | 1,200,000 W |
| Ore Bunker | 200,000 W | 200,000 W | 400,000 W |

---

## Allocatable Capacity

```
allocatableCapacity = capacity - load
```

Primary capacity only; used for allocation to reactors/generators.

---

## Power States

| Entity | Online When |
|--------|-------------|
| Player | availablePower > 0 |
| Struct | availablePower >= struct.passiveDraw |

---

## New Player Power Budget

New players receive power capacity through their guild's substation connection. The available capacity depends on what the guild allocates. Here is the load budget for the standard onboarding build order:

| Item | Build Draw | Passive Draw | Cumulative Load |
|------|------------|--------------|-----------------|
| Player (base) | — | 25 kW | 25 kW |
| Command Ship (build) | 50 kW | — | 75 kW |
| Command Ship (online) | — | 50 kW | 75 kW |
| Ore Extractor (build) | 500 kW | — | 575 kW |
| Ore Extractor (online) | — | 500 kW | 575 kW |
| Ore Refinery (build) | 500 kW | — | 1,075 kW |
| Ore Refinery (online) | — | 500 kW | 1,075 kW |

Build draw is temporary (only during construction) and releases when the build completes. The worst-case load during onboarding is ~1,075 kW with all three structs online plus a build in progress.

**Minimum viable capacity**: ~575 kW to have player + Command Ship + Ore Extractor online. If the guild substation provides less, prioritize activating Command Ship first, then build one struct at a time.

If total load ever exceeds total capacity, the player goes **offline** and cannot perform any actions until load is reduced (deactivate structs) or capacity is increased.

---

## Increasing Capacity

Three methods to increase a player's available capacity:

| Method | How | Rate | Risk | Reversible |
|--------|-----|------|------|------------|
| Reactor infusion | `reactor-infuse [your-addr] [reactor-addr] [amount-ualpha]` | 1g ≈ 1 kW (minus commission) | Low | Yes (defuse with cooldown) |
| Generator infusion | `struct-generator-infuse [struct-id] [amount-ualpha]` | 1g = 2-10 kW depending on type | High (raidable) | **No** |
| Buy via agreement | `agreement-open [provider-id] [duration] [capacity]` | Varies by provider | Medium (ongoing cost) | Yes (close agreement) |

### Reactor Commission

When infusing Alpha Matter into a reactor, the generated power is split between the player and the reactor based on the reactor's **commission rate**:

```
playerCapacityGain = power * (1 - commission)
reactorCapacityGain = power * commission
```

The player's capacity increases **automatically** — no allocation or substation setup needed. This makes reactor infusion the simplest path to more capacity.

Example: 3,000,000 ualpha infused into a reactor with 4% commission generates 3,000,000 mW. The reactor keeps 120,000 mW (4%), the player receives 2,880,000 mW (96%) added directly to their capacity.

### Allocation Sources

Allocations can be created from Reactors, Players, and Substations. Allocations can only be **connected to** Substations.

For full energy management workflows, see `.cursor/skills/structs-energy/SKILL.md`.

---

## See Also

- [building.md](building.md) — Build power requirements
- [resources.md](resources.md) — Energy production from Alpha Matter
- `systems/power-system.md` — Full power system documentation
- `schemas/formulas.md` — Power capacity formulas
- `schemas/entities.md` — Player capacity/load fields
