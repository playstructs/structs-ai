# Context Handoff

**Version**: 1.0.0  
**Purpose**: Protocol for managing context window limits during game sessions. When to warn, when to save, how to resume.

---

## When to Hand Off

| Context Usage | Action |
|---------------|--------|
| < 80% | Continue normally |
| ≥ 80% | **Warn**. Prepare handoff. |
| ≥ 90% | **Save handoff state immediately.** Reduce new context. |
| Near limit | **Save and stop.** Resume in fresh session. |

---

## Handoff File Template

Save to: `memory/YYYY-MM-DD-HHMM-context-handoff.md`

```markdown
# Context Handoff — YYYY-MM-DD HH:MM

## Objective
[Primary goal for this session. What were you trying to achieve?]

## Completed
[What you finished. Actions taken, structs built, raids done, etc.]

## Pending
[What remains. Next build, next raid, next exploration, etc.]

## Resume Command
[Exact instruction for fresh session to continue]
Example: "Resume Structs session. Read memory/2026-02-22-1430-context-handoff.md. Continue with: build Ore Refinery on planet 2-1, then refine stored ore."

## Blockers
[What's blocking progress. Waiting for build? Need resources? Under attack?]

## Current Game State Snapshot
- Player ID: 
- Planet ID: 
- Power: capacity / load / available
- Alpha Matter: 
- Stored Ore: 
- Fleet: onStation / away
- Guild: 
- Next planned action:
```

---

## Saving Handoff State

1. Create `memory/` directory if it doesn't exist
2. Fill template with current state (use `structs_query_player`, `structs_query_planet`, etc.)
3. Write clear resume command
4. Optionally: append to session log in `memory/`

---

## Resume Instructions (Fresh Session)

When resuming:

1. Read `memory/YYYY-MM-DD-HHMM-context-handoff.md`
2. Read [Continuity](continuity.md) startup files: `SOUL.md`, `IDENTITY.md`, `COMMANDER.md`, `TOOLS.md`
3. Run [State Assessment](state-assessment.md) to refresh game state (handoff may be stale)
4. Execute resume command or adapt if state changed
5. Continue [Game Loop](game-loop.md)

---

## Stale Handoff

Handoff files are snapshots. Game state may have changed. Always re-query before acting on old data.

---

## See Also

- [Continuity](continuity.md) — What to read on startup, memory directory
- [Game Loop](game-loop.md) — Loop that may trigger handoff
- [State Assessment](state-assessment.md) — Refresh state on resume
