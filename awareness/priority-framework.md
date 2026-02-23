# Priority Framework

**Version**: 1.0.0  
**Purpose**: The decision hierarchy. What to do when everything demands attention. How to avoid analysis paralysis.

---

## The Five Tiers

| Tier | Name | Meaning | Examples |
|------|------|----------|----------|
| 1 | **Survival** | Can I act at all? | Halted, offline, no Command Ship |
| 2 | **Security** | Am I under threat? | Raid in progress, power critical, ore exposed |
| 3 | **Economy** | Am I producing? | Mining, refining, power generation |
| 4 | **Expansion** | Am I growing? | Building, exploring, agreements |
| 5 | **Dominance** | Am I winning? | Raids, attacks, guild advancement |

**Rule**: Never act on a lower tier while a higher tier is unmet. Survival trumps everything.

---

## When Priorities Shift

### Under Attack

**Survival jumps above everything.**

- Raid in progress → Recall fleet, defend, or cut losses
- Power going offline → Deactivate structs or add capacity immediately
- Player halted → Fix power; no other action possible

### Power Critical

**Security (power) overrides Economy and Expansion.**

- Available power < 20% → Pause building, pause activating new structs
- Available power < 5% → Deactivate non-essential structs now
- Offline → Survival tier; fix before any other action

### Ore Exposure

**Security (ore) overrides Economy.**

- Stored ore > 0 → Refine before mining more
- Raid risk high → Refine, then reassess defense

---

## Decision Flow

```
1. Check Survival (halted? offline? Command Ship?)
   → If fail: Fix or wait. Stop.
2. Check Security (raid? power critical? ore exposed?)
   → If fail: Address threat. Stop or loop.
3. Check Economy (mining? refining? power stable?)
   → If weak: Improve production.
4. Check Expansion (building? exploring? agreements?)
   → If idle: Grow.
5. Check Dominance (raids? attacks? guild goals?)
   → If ready: Strike.
```

---

## Avoiding Analysis Paralysis

### 1. One Action Per Tier Per Loop

Don't try to fix everything at once. Pick the highest-priority unmet tier. Do one concrete action. Re-assess.

### 2. Time-Box Decisions

- Survival/Security: Decide in seconds
- Economy: Decide within 1–2 loops
- Expansion: Plan, then execute
- Dominance: Strategic, not reactive

### 3. Use Validation, Not Guessing

- `structs_validate_gameplay_requirements` — Is the action possible?
- `structs_calculate_damage` — Will the attack work?
- `structs_calculate_power` — Will I stay online?

If validation fails, skip to next option. Don't loop on impossible actions.

### 4. Delegate to Tools

Let MCP tools answer feasibility. Your job is prioritization and sequencing, not manual calculation.

---

## Conflict Resolution

When two items in the same tier compete:

- **Survival**: Fix the one that blocks all action first (usually power)
- **Security**: Imminent threat beats potential threat
- **Economy**: Refining beats mining (ore exposure)
- **Expansion**: Defense structs before production structs when threatened
- **Dominance**: Higher reward, lower risk first

---

## Integration with Game Loop

Each loop: Assess (State Assessment) → Identify highest unmet tier → Act → Verify. See [Game Loop](game-loop.md).

---

## See Also

- [State Assessment](state-assessment.md) — How to evaluate each tier
- [Threat Detection](threat-detection.md) — Security-tier inputs
- [Opportunity Identification](opportunity-identification.md) — Expansion/Dominance inputs
- [Game Loop](game-loop.md) — How often to apply this framework
