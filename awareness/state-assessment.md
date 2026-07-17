# State Assessment

**Version**: 1.0.0  
**Purpose**: How to evaluate your current position in Structs. What to check, in what order, what the numbers mean.

> Tool names below are from the `structs-desktop` MCP catalog (see [`TOOLS.md`](../TOOLS.md)). `structs_dashboard` is the fastest one-call self-snapshot (power, charge, resources, structs + HP); `structs_intel` looks up any single entity via its `query` mode (the entity is named in the Check column) and also covers scouting, simulation, and power forecasts; `structs_action` runs preflight checks.

---

## Assessment Order

Run these checks in sequence. Each layer builds on the previous. Stop and act if any critical issue appears.

### 1. Survival (Do I exist?)

| Check | MCP Tool | What to Look For |
|-------|----------|------------------|
| Player online | `structs_intel` | `halted === false` |
| Power status | `structs_intel` | `(capacity + capacitySecondary) - (load + structsLoad) > 0` |
| Command Ship | `structs_intel` | Fleet has Command Ship struct, online |

**Power formula**: `availablePower = (capacity + capacitySecondary) - (load + structsLoad)`. If load exceeds capacity, you go offline and most actions are blocked. Use `structs_intel` to model Alpha Matter → Watts conversion before building.

**Critical**: If halted or offline, nothing else matters. Recovery actions are **not** gated by being offline — `struct-deactivate` (single or batch, no charge) and reactor infusion always work, so you can shed load or add capacity to climb back online. Fix power, then resume.

---

### 2. Resources

| Check | MCP Tool | What to Look For |
|-------|----------|------------------|
| Alpha Matter | `structs_intel` | `alphaMatter` or equivalent balance |
| Ore (unrefined) | `structs_intel` (Ore Bunker, Miner) | Stored ore = liability until refined |
| Charge | `structs_intel` | Per-player charge bar (CurrentBlockHeight - lastActionBlock) gates attacking, activating, moving, building |

**Ore rule**: Ore is stealable. Alpha Matter is not. Refine immediately via `struct-ore-refine-complete`. Unrefined ore = raid target.

---

### 3. Power Headroom

| Metric | Interpretation |
|--------|-----------------|
| Available power > 20% of capacity | Healthy. Room to build. |
| Available power 5–20% | Warning. One new struct could tip you offline. |
| Available power < 5% | Critical. Deactivate non-essential structs or add capacity. |

Use `structs_intel` before building to ensure new struct's passive draw fits. Use `structs_action` with `struct_build_initiate` to pre-check build feasibility.

---

### 4. Military Strength

| Check | MCP Tool | What to Look For |
|-------|----------|------------------|
| Fleet status | `structs_intel` | `onStation` vs `away` — raids require fleet away |
| Command Ship | `structs_intel` | Online, present |
| Defensive structs | `structs_intel` (filter by planet) | Planetary Defense Cannons, shield health |
| Damage potential | `structs_intel` | Model attack outcomes before committing |

**Fleet rule**: Building on planet requires fleet on station. Raiding requires fleet away. Command Ship must be online for both.

---

### 5. Diplomatic Standing

| Check | MCP Tool | What to Look For |
|-------|----------|------------------|
| Guild membership | `structs_intel` → guild ref | Guild ID, member count |
| Guild power | `structs_intel` | Guild capacity, alliances |
| Alliances | `structs_intel` | Allied guilds, hostile guilds |

---

### 6. Expansion Progress

| Check | MCP Tool | What to Look For |
|-------|----------|------------------|
| Current planet | `structs_intel` → planet ref | Planet ID, ore remaining |
| Structs on planet | `structs_intel` (by planet) | Miner, Refinery, Bunker, defense |
| Planet ore | `structs_intel` | `maxOre`, remaining ore |
| Exploration readiness | `structs_intel` | Current planet empty (0 ore) before exploring |

**Exploration rule**: You can only own one planet. Must empty current planet before exploring new one.

---

## Quick Assessment Script

```
1. structs_intel({ player_id }) → survival, resources, power
2. structs_intel({ fleet_id }) → military readiness
3. structs_intel({ planet_id }) → expansion state
4. structs_intel({ guild_id }) → if guild member
5. structs_intel (by planet) → struct inventory
```

---

## Interpreting Numbers

| Field | Meaning |
|-------|---------|
| `capacity` + `capacitySecondary` | Total power you can supply |
| `load` + `structsLoad` | Total power you consume |
| `availablePower` | Headroom; must stay positive |
| `storedOre` | Stealable; refine ASAP |
| `alphaMatter` | Safe; cannot be stolen |
| `onStation` | Fleet at planet (for building) |
| `away` | Fleet in transit (for raids) |

---

## See Also

- [Threat Detection](threat-detection.md) — What to monitor after assessment
- [Priority Framework](priority-framework.md) — What to do when multiple issues appear
- [Game Loop](game-loop.md) — How often to re-assess
- `systems/power-system.md` — Power mechanics
- `schemas/entities.md` — Entity definitions
