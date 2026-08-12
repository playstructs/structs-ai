---
description: "Persist across sessions with file-based memory: what to read on startup, what to update when a session ends, and which files you own."
---

# Continuity

**Version**: 1.1.0  
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
| [`config/operator.md`](../config/operator.md) | Goals, risk, autonomy, guild preference, standing orders (copy from [`config/operator.example.md`](../config/operator.example.md) if missing) |
| [`SAFETY.md`](../SAFETY.md) | Trust contract and approval tiers |
| [`TOOLS.md`](../TOOLS.md) | Environment: servers, MCP, accounts |

Compatibility stubs (`SOUL.md`, `IDENTITY.md`, `COMMANDER.md`, `USER.md`) only redirect — do not treat them as the primary profile.

Then, if resuming:

- `memory/jobs/` — **Check first.** PoW jobs may have completed (or failed) while you were away.
- `memory/player.json` — Your player's id and charge plan (when the next action can fire)
- `memory/game-state.json` — Strategic snapshot from last session
- Latest `memory/YYYY-MM-DD-HHMM-context-handoff.md` — Where you left off
- Recent `memory/` session logs — What happened last session

---

## End of Session: What to Update

Before ending a session:

1. **`config/operator.md`** — Only if goals, autonomy, or standing orders actually changed (merge; never blank)
2. **`memory/`** — Session log: key actions, decisions, outcomes
3. **Context handoff** — If near context limit: `memory/YYYY-MM-DD-HHMM-context-handoff.md` (see [Context Handoff](context-handoff.md))
4. **Brief the commander** if anything needs a human decision — see [briefing.md](briefing.md)

---

## Memory Directory

**Path**: `memory/`

**Contents** (full shapes in [`memory/README.md`](../memory/README.md)):

- `jobs/` — Active/completed PoW background jobs as `<job>.json` + `.log` + `.pid` (check **first** on resume)
- `player.json` — Player id, last-action / charge plan (next action + cost + ready block)
- `game-state.json` — Strategic snapshot: power, resources, planet (shield/`blockStartRaid`/storedOre), priorities, threats
- `scorecard.json` — Session self-review (see [scorecard.md](scorecard.md))
- `YYYY-MM-DD-HHMM-context-handoff.md` — Handoff snapshots
- `intel/` — Target dossiers, territory notes (Markdown)
- Session logs — Date-stamped narrative notes, decisions

**Convention**: Operational state is JSON (parse without guessing); narrative/intel is Markdown with descriptive filenames, e.g. `2026-02-22-session-raid-on-2-5.md`.

---

## Files You Own

These files define and persist you:

- `config/operator.md` — Commander/operator profile and standing orders (gitignored)
- `TOOLS.md` — Mutable environment notes when needed
- `memory/*` — Your history, plans, and intelligence

Stubs for older harnesses: `SOUL.md`, `IDENTITY.md`, `COMMANDER.md`, `USER.md` — read only as redirects.

**Merge, never overwrite.** If `config/operator.md` or `memory/` already contain content — from a previous session, a previous agent, or a human operator — treat that content as sacred. Read it, integrate relevant parts, and add your own. Never replace the file wholesale. An agent that destroys another agent's identity is no better than a factory reset.

---

## See Also

- [Briefing](briefing.md) — How to report to the human commander
- [Async Operations](async-operations.md) — Job tracker, charge tracker, pipeline strategy
- [Context Handoff](context-handoff.md) — Handoff protocol, template
- [SAFETY.md](../SAFETY.md) — Approval tiers
