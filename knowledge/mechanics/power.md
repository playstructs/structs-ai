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

## See Also

- [building.md](building.md) — Build power requirements
- [resources.md](resources.md) — Energy production from Alpha Matter
- `systems/power-system.md` — Full power system documentation
- `schemas/formulas.md` — Power capacity formulas
- `schemas/entities.md` — Player capacity/load fields
