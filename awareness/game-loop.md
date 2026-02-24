# Game Loop

**Version**: 1.0.0  
**Purpose**: The continuous decision cycle. How to maintain tempo. Balancing reactive and proactive play.

---

## The Loop

```
Check Jobs → Assess → Plan → Initiate → Dispatch → Verify → Update Memory → Repeat
```

Each full cycle is one "tick" of the game loop. PoW operations run as background jobs between ticks.

---

## Single Tick Anatomy

### 0. Check Jobs

Before anything else, check all background PoW terminals. Mark completions in `memory/jobs.md`. On completion: activate structs, start next operations, update charge tracker. This is the highest-priority step — completed PoW means new capabilities or exposed resources.

See [Async Operations](async-operations.md) for background job management.

### 1. Assess

- Run [State Assessment](state-assessment.md) — Survival, resources, power, military, diplomacy, expansion
- Run [Threat Detection](threat-detection.md) — Fleet movements, ore exposure, power instability, hostile activity
- Run [Opportunity Identification](opportunity-identification.md) — Undefended planets, agreements, weakened opponents

**Tools**: `structs_query_player`, `structs_query_fleet`, `structs_query_planet`, `structs_query_planet_activity`, `structs_list_structs`, `structs_query_guild`

### 2. Plan

- Apply [Priority Framework](priority-framework.md) — Highest unmet tier wins
- **Think in pipelines**: what should I initiate now so it's ready later?
- Pick actions and also identify future actions whose age clocks should start now
- Validate: `structs_validate_gameplay_requirements`, `structs_calculate_power`, `structs_calculate_damage` as needed

### 3. Initiate

- Batch-submit all initiation transactions (build-initiate, etc.) to start age clocks
- Initiations are cheap (just gas) — start everything you plan to compute later

### 4. Dispatch

- Launch PoW compute in background terminals for anything where difficulty has dropped to D <= 8
- Record new jobs in `memory/jobs.md`
- Execute non-PoW actions (activate, attack, move fleet, set defense)

### 5. Verify

- Query game state after actions
- Confirm: struct built, ore refined, attack landed, fleet moved
- **Rule**: Transaction broadcast ≠ success. Always verify.

### 6. Update Memory

- Update `memory/jobs.md` with new and completed jobs
- Update `memory/charge-tracker.md` with struct states
- Update `memory/game-state.md` with strategic picture

### 7. Repeat

- Loop. Tempo depends on context (see below).

---

## Tempo

| Mode | Loop Frequency | When |
|------|----------------|------|
| **Crisis** | Every 30-60 sec | Under attack, power critical, ore exposed |
| **Active** | Every 2-5 min | Builds completing, initiating new actions |
| **Pipeline** | Every 10-30 min | Managing background PoW, scouting, planning |
| **Idle** | On event or check-in | Long PoW running (mine/refine), streaming events |

**Pipeline mode is not idle.** When PoW is running in background, use the time for reconnaissance, strategic planning, guild coordination, or managing other players. The player with the most age clocks ticking simultaneously has the best tempo.

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
- [Async Operations](async-operations.md) — Background PoW, job tracking, pipeline strategy
- [Context Handoff](context-handoff.md) — Session boundaries
- [Continuity](continuity.md) — Cross-session persistence
