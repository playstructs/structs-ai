# Opportunity Identification

**Version**: 1.0.0  
**Purpose**: Spotting chances before others do. What to look for and which tools to use.

---

## Opportunity Categories

### 1. Undefended Planets

**Opportunity**: Planets with weak or no defense structs. Raid targets.

| Check | MCP Tool | Signal |
|-------|----------|--------|
| Structs on planet | `structs_list_structs` (by planet) | No Planetary Defense Cannon, low shield |
| Planet shield | `structs_query_planet` or webapp shield endpoint | Low or zero shield health |
| Stored ore | `structs_query_struct` (Ore Bunker) | High ore = high reward |

**Caveat**: Fleet must be away. Command Ship online. Use `structs_validate_gameplay_requirements` with `planet_raid_complete` before raiding.

---

### 2. Underpriced Energy Agreements

**Opportunity**: Energy agreements priced below market. Cheap power = more capacity for less Alpha Matter.

| Check | MCP Tool | Signal |
|-------|----------|--------|
| All agreements | `structs_list_agreements` | Compare price per Watt |
| Provider terms | `structs_query_provider` | Rate, duration, availability |
| Allocation availability | `structs_query_allocation` | Open allocation slots |

**Cross-reference**: `structs_calculate_power` for your own Alpha Matter→Watts rate. If agreement beats your reactor efficiency, consider buying.

---

### 3. Alliance Openings

**Opportunity**: Guilds seeking members, players without guilds, diplomatic windows.

| Check | MCP Tool | Signal |
|-------|----------|--------|
| Guild member count | `structs_query_guild` | Low count, recruiting |
| Guild power stats | `structs_query_guild` | Capacity, growth trajectory |
| Player guild status | `structs_query_player` | No guild = potential recruit |

---

### 4. Weakened Opponents (Post-Battle)

**Opportunity**: Player or guild just lost a battle. Reduced structs, depleted shield, low ore.

| Check | MCP Tool | Signal |
|-------|----------|--------|
| Planet activity | `structs_query_planet_activity` | Recent `struct_attack`, `raid_status` |
| Struct health | `structs_query_struct` | Low health, destroyed structs |
| Player resources | `structs_query_player` | Low Alpha Matter, depleted |

**Window**: Short. They may rebuild or get guild support. Act before recovery.

---

### 5. Market Dislocations

**Opportunity**: Price spikes, supply gaps, agreement expirations creating demand.

| Check | MCP Tool | Signal |
|-------|----------|--------|
| Agreements | `structs_list_agreements` | Expiring soon, low supply |
| Trade value | `structs_calculate_trade_value` | Compare Alpha Matter vs energy value |
| Economic metrics | `structs_calculate_economic_metrics` | Market conditions |

---

### 6. Unclaimed Territory

**Opportunity**: Unexplored planets, empty slots, unallocated capacity.

| Check | MCP Tool | Signal |
|-------|----------|--------|
| Planets | `structs_list_planets` | Unexplored (no owner) |
| Reactor capacity | `structs_query_reactor` | Allocatable capacity |
| Substations | `structs_list_substations` | Open connection slots |

**Exploration**: Must empty current planet first. Use `structs_validate_gameplay_requirements` with `planet_explore`.

---

## Scanning Routine

Run periodically (e.g., every 2–3 game loops):

1. `structs_list_planets` — Unclaimed or weak planets
2. `structs_list_agreements` — Energy market
3. `structs_query_planet_activity` — Recent combat, raids
4. `structs_list_guilds` — Guild status, member counts

Prioritize by [Priority Framework](priority-framework.md). Opportunities below Security can wait.

---

## Validation Before Acting

Always validate before committing:

- `structs_validate_gameplay_requirements` — Action feasible?
- `structs_calculate_damage` — Attack outcome?
- `structs_calculate_cost` — Build affordable?
- `structs_calculate_power` — Power headroom after action?

---

## See Also

- [Threat Detection](threat-detection.md) — Risks that offset opportunities
- [Priority Framework](priority-framework.md) — When to pursue opportunities
- [Game Loop](game-loop.md) — Tempo for opportunity scanning
- `patterns/gameplay-strategies.md` — Strategic patterns
