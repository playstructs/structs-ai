# Threat Detection

**Version**: 1.0.0  
**Purpose**: Identifying dangers before they hit. How to set up monitoring and what to watch.

---

## Threat Categories

### 1. Fleet Movements Near Your Territory

**Threat**: Hostile fleets approaching your planet or allied planets.

| Monitor | MCP Tool | Frequency |
|---------|----------|-----------|
| Planet activity | `structs_query_planet_activity` | Every 5–10 min during active play |
| Fleet arrivals | Subscribe to `structs.planet.{id}` (NATS) | Real-time |
| Nearby players | `structs_list_players` + `structs_query_fleet` | When scouting |

**Signals**: `fleet_arrive`, `fleet_advance` events. Unknown fleet at your planet = potential raid.

---

### 2. Unrefined Ore Exposure

**Threat**: Ore in bunkers or miners is stealable. Raiders target planets with high stored ore.

| Monitor | MCP Tool | Threshold |
|---------|----------|-----------|
| Stored ore | `structs_query_struct` (Ore Bunker, Miner) | Any > 0 is exposure |
| Planet activity | `structs_query_planet_activity` | Recent raids, attacks |

**Rule**: Refine immediately. Use `struct-ore-refinery-complete` as soon as ore is available. Zero unrefined ore = nothing to steal.

---

### 3. Power Instability (Approaching Capacity)

**Threat**: Load approaching capacity. One more struct or one struct coming online = offline = halt.

| Monitor | MCP Tool | Threshold |
|---------|----------|-----------|
| Power headroom | `structs_query_player` | `availablePower < 20%` of total capacity |
| Pending structs | `structs_list_structs` | Structs in "building" state |

**Signals**: Building struct completing, reactor defusion, agreement expiring. Use `structs_calculate_power` before any load change.

---

### 4. Hostile Guild Activity

**Threat**: Guild wars, raids on allies, diplomatic shifts.

| Monitor | MCP Tool | What to Watch |
|---------|----------|---------------|
| Guild relations | `structs_query_guild` | Hostile guilds, war status |
| Guild power | `structs_query_guild` | Member count, capacity changes |
| Planet activity | `structs_query_planet_activity` | Raids on guild planets |

---

### 5. Depleting Planet Ore

**Threat**: Planet running out of ore. No ore = no mining = no Alpha Matter = stagnation.

| Monitor | MCP Tool | Threshold |
|---------|----------|-----------|
| Planet ore | `structs_query_planet` | Remaining ore vs `maxOre` |
| Miner output | `structs_query_struct` (Miner) | Production rate |

**Action**: Plan exploration when planet nears empty. Must empty current planet (0 ore) before exploring.

---

## Monitoring Setup

### Periodic Checks (Every Game Loop)

1. `structs_query_player` — Power, halted status
2. `structs_query_struct` (Ore Bunker) — Stored ore level

### Event-Driven (Streaming)

Subscribe to NATS subjects:

- `structs.planet.{planetId}` — Raids, fleet arrivals, struct health
- `structs.struct.{structId}` — Struct status, attacks
- `structs.fleet.{fleetId}` — Fleet movement

### Before Major Actions

- `structs_validate_gameplay_requirements` — Pre-check build, attack, raid
- `structs_calculate_power` — Before adding load
- `structs_calculate_damage` — Before attacking

---

## Threat Response Priority

1. **Immediate**: Power offline, raid in progress → act now
2. **Short-term**: Ore exposure, fleet approaching → refine, recall fleet, or defend
3. **Medium-term**: Depleting ore, hostile guild buildup → plan exploration, diplomacy

See [Priority Framework](priority-framework.md) for full decision hierarchy.

---

## See Also

- [State Assessment](state-assessment.md) — Baseline before threat monitoring
- [Opportunity Identification](opportunity-identification.md) — Flip side of threats
- [Priority Framework](priority-framework.md) — When threats conflict
- `patterns/polling-vs-streaming.md` — When to poll vs stream
