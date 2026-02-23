# State Assessment

**Version**: 1.0.0  
**Purpose**: How to evaluate your current position in Structs. What to check, in what order, what the numbers mean.

---

## Assessment Order

Run these checks in sequence. Each layer builds on the previous. Stop and act if any critical issue appears.

### 1. Survival (Do I exist?)

| Check | MCP Tool | What to Look For |
|-------|----------|------------------|
| Player online | `structs_query_player` | `halted === false` |
| Power status | `structs_query_player` | `(capacity + capacitySecondary) - (load + structsLoad) > 0` |
| Command Ship | `structs_query_fleet` | Fleet has Command Ship struct, online |

**Power formula**: `availablePower = (capacity + capacitySecondary) - (load + structsLoad)`. If load exceeds capacity, you go offline and cannot act. Use `structs_calculate_power` to model Alpha Matter → Watts conversion before building.

**Critical**: If halted or offline, nothing else matters. Fix power or wait for recovery.

---

### 2. Resources

| Check | MCP Tool | What to Look For |
|-------|----------|------------------|
| Alpha Matter | `structs_query_player` | `alphaMatter` or equivalent balance |
| Ore (unrefined) | `structs_query_struct` (Ore Bunker, Miner) | Stored ore = liability until refined |
| Charge | `structs_query_struct` | Structs need charge for mining, attacking, activating |

**Ore rule**: Ore is stealable. Alpha Matter is not. Refine immediately via `struct-ore-refinery-complete`. Unrefined ore = raid target.

---

### 3. Power Headroom

| Metric | Interpretation |
|--------|-----------------|
| Available power > 20% of capacity | Healthy. Room to build. |
| Available power 5–20% | Warning. One new struct could tip you offline. |
| Available power < 5% | Critical. Deactivate non-essential structs or add capacity. |

Use `structs_calculate_power` before building to ensure new struct's passive draw fits. Use `structs_validate_gameplay_requirements` with `struct_build_initiate` to pre-check build feasibility.

---

### 4. Military Strength

| Check | MCP Tool | What to Look For |
|-------|----------|------------------|
| Fleet status | `structs_query_fleet` | `onStation` vs `away` — raids require fleet away |
| Command Ship | `structs_query_fleet` | Online, present |
| Defensive structs | `structs_list_structs` (filter by planet) | Planetary Defense Cannons, shield health |
| Damage potential | `structs_calculate_damage` | Model attack outcomes before committing |

**Fleet rule**: Building on planet requires fleet on station. Raiding requires fleet away. Command Ship must be online for both.

---

### 5. Diplomatic Standing

| Check | MCP Tool | What to Look For |
|-------|----------|------------------|
| Guild membership | `structs_query_player` → guild ref | Guild ID, member count |
| Guild power | `structs_query_guild` | Guild capacity, alliances |
| Alliances | `structs_query_guild` | Allied guilds, hostile guilds |

---

### 6. Expansion Progress

| Check | MCP Tool | What to Look For |
|-------|----------|------------------|
| Current planet | `structs_query_player` → planet ref | Planet ID, ore remaining |
| Structs on planet | `structs_list_structs` (by planet) | Miner, Refinery, Bunker, defense |
| Planet ore | `structs_query_planet` | `maxOre`, remaining ore |
| Exploration readiness | `structs_query_player` | Current planet empty (0 ore) before exploring |

**Exploration rule**: You can only own one planet. Must empty current planet before exploring new one.

---

## Quick Assessment Script

```
1. structs_query_player({ player_id }) → survival, resources, power
2. structs_query_fleet({ fleet_id }) → military readiness
3. structs_query_planet({ planet_id }) → expansion state
4. structs_query_guild({ guild_id }) → if guild member
5. structs_list_structs (by planet) → struct inventory
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
