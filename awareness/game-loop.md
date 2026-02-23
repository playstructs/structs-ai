# Game Loop

**Version**: 1.0.0  
**Purpose**: The continuous decision cycle. How to maintain tempo. Balancing reactive and proactive play.

---

## The Loop

```
Assess → Plan → Act → Verify → Repeat
```

Each full cycle is one "tick" of the game loop.

---

## Single Tick Anatomy

### 1. Assess

- Run [State Assessment](state-assessment.md) — Survival, resources, power, military, diplomacy, expansion
- Run [Threat Detection](threat-detection.md) — Fleet movements, ore exposure, power instability, hostile activity
- Run [Opportunity Identification](opportunity-identification.md) — Undefended planets, agreements, weakened opponents

**Tools**: `structs_query_player`, `structs_query_fleet`, `structs_query_planet`, `structs_query_planet_activity`, `structs_list_structs`, `structs_query_guild`

### 2. Plan

- Apply [Priority Framework](priority-framework.md) — Highest unmet tier wins
- Pick one concrete action (or small batch of dependent actions)
- Validate: `structs_validate_gameplay_requirements`, `structs_calculate_power`, `structs_calculate_damage` as needed

### 3. Act

- Execute the chosen action (build, mine, refine, attack, raid, move fleet, etc.)
- Use `structs_action_*` tools or submit transaction via `structs_action_submit_transaction`

### 4. Verify

- Query game state after action
- Confirm: struct built, ore refined, attack landed, fleet moved
- **Rule**: Transaction broadcast ≠ success. Always verify.

### 5. Repeat

- Loop. Tempo depends on context (see below).

---

## Tempo

| Mode | Loop Frequency | When |
|------|----------------|------|
| **Crisis** | Every 30–60 sec | Under attack, power critical |
| **Active** | Every 2–5 min | Normal play, mining, building |
| **Passive** | Every 10–30 min | Waiting for builds, low threat |
| **Idle** | On event or manual | Streaming events, user prompt |

---

## Reactive vs Proactive

### Reactive (Respond to Events)

- Raid detected → Defend or retreat
- Power critical → Deactivate or add capacity
- Ore exposed → Refine
- Fleet arrived → Assess intent, respond

**Trigger**: [Threat Detection](threat-detection.md) signals, streaming events, state changes.

### Proactive (Pursue Strategy)

- Build next struct in plan
- Explore when planet empty
- Scan for raid targets
- Open energy agreement
- Guild diplomacy

**Trigger**: [Priority Framework](priority-framework.md) Expansion/Dominance tier, planned sequence.

### Balance

- Survival and Security are mostly reactive
- Economy, Expansion, Dominance are mostly proactive
- Each tick: Check reactive first, then proactive if clear

---

## Context Limits

When approaching context limits, use [Context Handoff](context-handoff.md). Save state, hand off, resume in fresh session.

---

## See Also

- [State Assessment](state-assessment.md) — Assess step
- [Priority Framework](priority-framework.md) — Plan step
- [Context Handoff](context-handoff.md) — Session boundaries
- [Continuity](continuity.md) — Cross-session persistence
