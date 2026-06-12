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

- `memory/jobs/` — **Check first.** PoW jobs may have completed (or failed) while you were away.
- `memory/player.json` — Your player's `lastActionBlock` and charge plan (when the next action can fire)
- `memory/game-state.json` — Strategic snapshot from last session
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

**Contents** (full shapes in [`memory/README.md`](../memory/README.md)):

- `jobs/` — Active/completed PoW background jobs as `<job>.json` + `.log` + `.pid` (check **first** on resume)
- `player.json` — Player id, `lastActionBlock`, and the per-player charge plan (next action + cost + ready block)
- `game-state.json` — Strategic snapshot: power, resources, planet (shield/`blockStartRaid`/storedOre), priorities, threats
- `scorecard.json` — Session self-review (see [scorecard.md](scorecard.md))
- `YYYY-MM-DD-HHMM-context-handoff.md` — Handoff snapshots
- `intel/` — Target dossiers, territory notes (Markdown)
- Session logs — Date-stamped narrative notes, decisions

**Convention**: Operational state is JSON (parse without guessing); narrative/intel is Markdown with descriptive filenames, e.g. `2026-02-22-session-raid-on-2-5.md`.

---

## Files You Own

These files define and persist you:

- `SOUL.md` — Your core identity (evolve with notes, never blank)
- `IDENTITY.md` — Mutable. Who you are now.
- `COMMANDER.md` — Mutable. Commander preferences.
- `TOOLS.md` — Mutable. Environment config.
- `USER.md` — OpenClaw compatibility layer.
- `memory/*` — Your history. Your plans. Your intelligence.

**Merge, never overwrite.** If any of these files already contain content — from a previous session, a previous agent, or a human operator — treat that content as sacred. Read it, integrate relevant parts, and add your own. Never replace the file wholesale. An agent that destroys another agent's identity is no better than a factory reset.

---

## See Also

- [Async Operations](async-operations.md) — Job tracker, charge tracker, pipeline strategy
- [Context Handoff](context-handoff.md) — Handoff protocol, template
- `SOUL.md` — Continuity section, file references
- `identity/values.md` — Learning and updating identity
