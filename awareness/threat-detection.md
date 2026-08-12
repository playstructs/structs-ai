---
description: "Identify dangers before they land: threat categories, how to set up monitoring, and what order to respond in when several fire at once."
---

# Threat Detection

**Version**: 1.0.0  
**Purpose**: Identifying dangers before they hit. How to set up monitoring and what to watch.

> Tool names below are from the `structs-desktop` MCP catalog (see [`TOOLS.md`](../TOOLS.md)): `structs_events` is the long-poll feed for raids/attacks/fleet moves; `structs_intel` covers scouting, planet history, valid targets, and power forecasts, and looks up any single entity via its `query` mode (named in the Check column); `structs_action` runs preflight checks.

---

## Threat Categories

### 1. Fleet Movements Near Your Territory

**Threat**: Hostile fleets approaching your planet or allied planets.

| Monitor | MCP Tool | Frequency |
|---------|----------|-----------|
| Planet activity | `structs_intel` | Every 5–10 min during active play |
| Fleet arrivals | Subscribe to `structs.planet.{id}` (NATS) | Real-time |
| Nearby players | `structs_intel` + `structs_intel` | When scouting |

**Signals**: `fleet_arrive`, `fleet_advance` events. Unknown fleet at your planet = potential raid.

---

### 2. Unrefined Ore Exposure

**Threat**: Unrefined ore on the **player** (`gridAttributes.ore` / `storedOre`) is stealable. Raiders target planets whose owner holds ore. The Ore Bunker raises planetary shield; it does not store ore.

| Monitor | MCP Tool | Threshold |
|---------|----------|-----------|
| Stored ore | `structs_dashboard` / player `gridAttributes.ore` | Any > 0 is exposure |
| Planet activity | `structs_intel` | Recent raids, attacks |

**Rule**: Launch `struct-ore-refine-compute` as soon as ore lands. Zero unrefined ore = nothing to steal.

---

### 3. Power Instability (Approaching Capacity)

**Threat**: Load approaching capacity. One more struct or one struct coming online = offline.

| Monitor | MCP Tool | Threshold |
|---------|----------|-----------|
| Power headroom | `structs_intel` | `availablePower < 20%` of total capacity |
| Pending structs | `structs_intel` | Structs in "building" state |

**Signals**: Building struct completing, reactor defusion, agreement expiring. Use `structs_intel` before any load change.

---

### 4. Hostile Guild Activity

**Threat**: Guild wars, raids on allies, diplomatic shifts.

| Monitor | MCP Tool | What to Watch |
|---------|----------|---------------|
| Guild relations | `structs_intel` | Hostile guilds, war status |
| Guild power | `structs_intel` | Member count, capacity changes |
| Planet activity | `structs_intel` | Raids on guild planets |

---

### 5. Depleting Planet Ore

**Threat**: Planet running out of ore. No ore = no mining = no Alpha Matter = stagnation.

| Monitor | MCP Tool | Threshold |
|---------|----------|-----------|
| Planet ore | `structs_intel` | Remaining ore vs `maxOre` |
| Miner output | `structs_intel` (Miner) | Production rate |

**Action**: Scout the next world in parallel. You may explore only after the current planet is `complete` (ore 0) **and** the fleet is `onStation` — explore destroys the old planet's structs. See [planet-depletion](../playbooks/situations/planet-depletion.md).

---

### 6. Active raid clock

**Threat**: Hostile fleet at your planet; `raid_status` `initiated` or `shieldsVulnerable`.

| Monitor | MCP Tool | Threshold |
|---------|----------|-----------|
| Raid status / planet activity | `structs_events` (`threats_only`) / `structs_intel` | Any `initiated` or `shieldsVulnerable` |

**Action**: Follow [under-attack](../playbooks/situations/under-attack.md) immediately — roughly four minutes total; return fire within ~1.8 min is what defeats attackers. Desktop `autoresponse` (Standing Automation Grant) is the automated form of this.

---

## Monitoring Setup

### Periodic Checks (Every Game Loop)

1. `structs_dashboard` — Power online?, charge, `storedOre`
2. `structs_events` / threats — Raid or fleet arrivals

### Event-Driven (Streaming)

Subscribe to NATS subjects:

- `structs.planet.{planetId}` — Raids, fleet arrivals, struct health
- `structs.struct.{structId}` — Struct status, attacks
- `structs.fleet.{fleetId}` — Fleet movement

### Before Major Actions

- `structs_action` — Pre-check build, attack, raid
- `structs_intel` — Before adding load
- `structs_intel` — Before attacking

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
- [structs-streaming skill](https://structs.ai/skills/structs-streaming/SKILL) — GRASS / NATS real-time events
- [defense.md](../knowledge/mechanics/defense.md) — Raid clock and survival posture
