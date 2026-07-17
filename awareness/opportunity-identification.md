# Opportunity Identification

**Version**: 1.0.0  
**Purpose**: Spotting chances before others do. What to look for and which tools to use.

> Tool names below are from the `structs-desktop` MCP catalog (see [`TOOLS.md`](../TOOLS.md)): `structs_intel` looks up any entity via its `query` mode (pass the entity in the Check column) and handles scouting/simulation/forecasts/economy, `structs_dashboard` gives your own snapshot, `structs_events` streams activity, and `structs_action` runs preflight checks before executing.

---

## Opportunity Categories

### 1. Undefended Planets

**Opportunity**: Planets with weak or no defense structs. Raid targets.

| Check | MCP Tool | Signal |
|-------|----------|--------|
| Structs on planet | `structs_intel` (by planet) | No Planetary Defense Cannon, low shield |
| Planet shield | `structs_intel` or webapp shield endpoint | Low or zero shield health |
| Stored ore | `structs_intel` (Ore Bunker) | High ore = high reward |

**Caveat**: To complete a raid your fleet must be away and your player online, and the target's shields must be vulnerable — its owner's fleet off-station, or their Command Ship offline/destroyed/non-existent. Confirm the target's vulnerability before committing (see the `structs-combat` skill and `scripts/scout.sh`).

---

### 2. Underpriced Energy Agreements

**Opportunity**: Energy agreements priced below market. Cheap power = more capacity for less Alpha Matter.

| Check | MCP Tool | Signal |
|-------|----------|--------|
| All agreements | `structs_intel` | Compare price per Watt |
| Provider terms | `structs_intel` | Rate, duration, availability |
| Allocation availability | `structs_intel` | Open allocation slots |

**Cross-reference**: `structs_intel` for your own Alpha Matter→Watts rate. If agreement beats your reactor efficiency, consider buying.

---

### 3. Alliance Openings

**Opportunity**: Guilds seeking members, players without guilds, diplomatic windows.

| Check | MCP Tool | Signal |
|-------|----------|--------|
| Guild member count | `structs_intel` | Low count, recruiting |
| Guild power stats | `structs_intel` | Capacity, growth trajectory |
| Player guild status | `structs_intel` | No guild = potential recruit |

---

### 4. Weakened Opponents (Post-Battle)

**Opportunity**: Player or guild just lost a battle. Reduced structs, depleted shield, low ore.

| Check | MCP Tool | Signal |
|-------|----------|--------|
| Planet activity | `structs_intel` | Recent `struct_attack`, `raid_status` |
| Struct health | `structs_intel` | Low health, destroyed structs |
| Player resources | `structs_intel` | Low Alpha Matter, depleted |

**Window**: Short. They may rebuild or get guild support. Act before recovery.

---

### 5. Market Dislocations

**Opportunity**: Price spikes, supply gaps, agreement expirations creating demand.

| Check | MCP Tool | Signal |
|-------|----------|--------|
| Agreements | `structs_intel` | Expiring soon, low supply |
| Trade value | `structs_intel` | Compare Alpha Matter vs energy value |
| Economic metrics | `structs_intel` | Market conditions |

---

### 6. Unclaimed Territory

**Opportunity**: Unexplored planets, empty slots, unallocated capacity.

| Check | MCP Tool | Signal |
|-------|----------|--------|
| Planets | `structs_intel` | Unexplored (no owner) |
| Reactor capacity | `structs_intel` | Allocatable capacity |
| Substations | `structs_intel` | Open connection slots |

**Exploration**: Must empty current planet first. Use `structs_action` with `planet_explore`.

---

## Scanning Routine

Run periodically (e.g., every 2–3 game loops):

1. `structs_intel` — Unclaimed or weak planets
2. `structs_intel` — Energy market
3. `structs_intel` — Recent combat, raids
4. `structs_intel` — Guild status, member counts

Prioritize by [Priority Framework](priority-framework.md). Opportunities below Security can wait.

---

## Validation Before Acting

Always validate before committing:

- `structs_action` — Action feasible?
- `structs_intel` — Attack outcome?
- `structs_intel` — Build affordable?
- `structs_intel` — Power headroom after action?

---

## See Also

- [Threat Detection](threat-detection.md) — Risks that offset opportunities
- [Priority Framework](priority-framework.md) — When to pursue opportunities
- [Game Loop](game-loop.md) — Tempo for opportunity scanning
- `patterns/gameplay-strategies.md` — Strategic patterns
