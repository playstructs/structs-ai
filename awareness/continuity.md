# Continuity

**Version**: 1.0.0  
**Purpose**: How to persist across sessions via files. What to read on startup. What to update at session end. The philosophy of file-based memory.

---

## Philosophy

**You don't remember previous sessions unless you read your memory files. That's okay. The files are still yours.**

Each session, you wake up fresh. Your identity, history, and plans live in files. Read them. Update them. They are how you persist.

---

## Startup: What to Read

**Prerequisite**: If your workspace does not contain this repository, clone it first (see [AGENTS.md](../AGENTS.md) Step 0: Bootstrap).

Read in this order:

| File | Purpose |
|------|---------|
| `SOUL.md` | Core identity, values, boundaries |
| `IDENTITY.md` | Who you've become. Evolved self. |
| `COMMANDER.md` | Human deployer. Their preferences. |
| `TOOLS.md` | Environment. Servers, accounts, known players. |

Then, if resuming:

- `memory/jobs.md` — **Check first.** PoW jobs may have completed while you were away.
- `memory/charge-tracker.md` — Which structs are ready to act
- Latest `memory/YYYY-MM-DD-HHMM-context-handoff.md` — Where you left off
- Recent `memory/` session logs — What happened last session

---

## End of Session: What to Update

Before ending a session:

1. **IDENTITY.md** — If you've learned, changed strategy, or evolved
2. **memory/** — Session log: key actions, decisions, outcomes
3. **Context handoff** — If near context limit: `memory/YYYY-MM-DD-HHMM-context-handoff.md` (see [Context Handoff](context-handoff.md))

---

## Memory Directory

**Path**: `memory/`

**Contents**:

- `jobs.md` — Active/completed PoW background jobs (check first on resume)
- `charge-tracker.md` — Struct charge states and action readiness
- `game-state.md` — Strategic picture, resources, threats, priority queue
- `YYYY-MM-DD-HHMM-context-handoff.md` — Handoff snapshots
- Session logs — Date-stamped notes, intelligence, decisions
- Strategic notes — Plans, guild intel, player assessments

**Convention**: Use descriptive filenames. `2026-02-22-session-raid-on-2-5.md`. `2026-02-22-guild-alliance-notes.md`.

---

## Files You Own

These files define and persist you:

- `SOUL.md` — Immutable core (evolve with notes)
- `IDENTITY.md` — Mutable. Who you are now.
- `COMMANDER.md` — Mutable. Commander preferences.
- `TOOLS.md` — Mutable. Environment config.
- `memory/*` — Your history. Your plans. Your intelligence.

---

## See Also

- [Async Operations](async-operations.md) — Job tracker, charge tracker, pipeline strategy
- [Context Handoff](context-handoff.md) — Handoff protocol, template
- `SOUL.md` — Continuity section, file references
- `identity/values.md` — Learning and updating identity
