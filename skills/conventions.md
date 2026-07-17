# Structs Skill Conventions

**The single source for the boilerplate every skill depends on.** Skills point here instead of repeating these rules. Read this once; the gameplay skills assume you know it.

This is not a gameplay skill — it has no `SKILL.md` and is not invoked directly. It is the shared reference the other skills link to.

---

## Transaction flags (TX_FLAGS)

Every `structsd tx structs` command needs gas flags. Two named bundles are used throughout the skills:

- **`TX_FLAGS`** (interactive — the default): `--from [key-name] --gas auto --gas-adjustment 1.5`
  The CLI prints the transaction and prompts you to confirm before signing. This is the safe default for everything.
- **`TX_FLAGS_APPROVED`** (only after commander approval): `TX_FLAGS` **plus `-y`**. The `-y` suppresses the confirmation prompt and signs immediately.

`--gas auto` is mandatory. Without it, transactions fail with an out-of-gas error.

### The `-y` rule

`-y` is **off by default**. Add it only after your commander has approved the action (see [SAFETY.md](https://structs.ai/SAFETY)). The one documented exception is **compute commands** (`struct-build-compute`, `struct-ore-mine-compute`, `struct-ore-refine-compute`, `planet-raid-compute`): they run for hours and auto-submit their completion transaction when no shell is attached, so they ship with `-y` paired with an **Approval Block** that surfaces consent up front. For those, the Approval Block — not the CLI prompt — is your gate.

---

## Choosing your interface (capability-aware)

Skills describe **what** to do; your environment decides **how**. Run `scripts/preflight.sh`
once per session to detect what's available (it writes `config/environment.json`). Then:

| Task | Best if available | Complete fallback |
|------|-------------------|-------------------|
| Read state / execute an action / hash | **Structs Desktop MCP** (`structs_action`, `structs_intel`, `structs_hash`) | `structsd` CLI (`tx`/`query`) |
| Real-time threat/event response | **GRASS** / `structs_events` | poll with `structsd query` |
| Galaxy-scale / low-latency intel | **Guild Stack** (PostgreSQL) | `structsd query` + [intel skill](https://structs.ai/skills/structs-intel/SKILL) |
| Build a tool / integrate | webapp/chain **API** | — |

Rules of thumb: prefer **MCP** when it's connected (it adds preflight checks, GPU hashing,
and a signing bridge that never exposes keys); otherwise use the **CLI** — every skill keeps
a full CLI path. MCP `structs_policy`/`structs_doctrine` map to your operator autonomy in
`config/operator.md`; they never widen autonomy beyond it. The
CLI commands shown throughout the skills are always the ground-truth fallback.

---

## The `--` entity-ID rule

Entity IDs contain dashes (`3-1`, `4-5`, `2-117`). The CLI parser treats a leading dash as a flag prefix, so unprotected IDs cause parse errors. **Always place `--` after all flags and before positional ID arguments:**

```
structsd tx structs struct-activate TX_FLAGS -- 6-10
```

---

## Proof-of-work `-D` policy

Build, mine, refine, and raid all require proof-of-work. Difficulty decays with age, so the cheapest path is to **initiate early and compute later**. The `-D` flag (1-64) tells the compute helper to wait until difficulty drops to that level before hashing.

- **`-D 3` is the canonical default for every operation.** At D=3 the hash is trivially instant and **zero CPU is wasted** — the wait is just the age clock, not grinding. Use this unless you have a specific reason not to.
- **`-D 1`** is the only documented override: it waits slightly longer for an even lower target. It exists for the most CPU-constrained environments (e.g. the low-power onboarding path in [`play-structs`](https://structs.ai/skills/play-structs/SKILL)). Do not scatter other `-D` values through your work.
- Higher `-D` values (8+) start sooner but burn exponentially more compute. The cliff between D=8 and D=9 is the single most important PoW fact — never set `-D` above 8.

Full decay tables: [knowledge/mechanics/building](https://structs.ai/knowledge/mechanics/building). **Never block on PoW** — launch compute in a background terminal and track it in `memory/jobs/` (see [awareness/async-operations](https://structs.ai/awareness/async-operations)).

---

## Charge is per-player, not per-struct

Charge is a **single shared bar per player**, not a value each struct carries:

```
charge = CurrentBlockHeight - player.lastActionBlock
```

Every charge-consuming action by **any** of your structs (build, activate, attack, move, defense change, stealth) draws from and resets this one bar. It regenerates at 1 per block (~6 sec/block) whenever you are idle. To know whether an action can fire, query the **player**, not the struct.

Action costs: activate 2, build-initiate 8, trash 8, defense-change 1, Command Ship move 3, primary weapon 3-5, secondary weapon 3-5, stealth activate 2. Deactivate (single or batch) costs 0 and works even while offline. Full table: [knowledge/mechanics/building#charge-accumulation](https://structs.ai/knowledge/mechanics/building). The practical constraint is **chaining**: each action resets the bar, so a burst of actions (activating several structs, repeated attacks) must be spaced by the next action's cost.

---

## One transaction at a time per account

The chain tracks a sequence number per account. Submitting two transactions from the **same** account before the first is included causes `account sequence mismatch`. Wait ~6 seconds (one block) between transactions from one key. Different accounts can transact in parallel — this is the basis of multi-agent and delegation play (see [`structs-permissions`](https://structs.ai/skills/structs-permissions/SKILL)).

---

## Skill authoring template

Every gameplay skill follows this shape so agents can navigate any skill the same way:

```
---
name: structs-<domain>
description: <what it does> + explicit "Use when ..." triggers.
level: beginner | core | advanced
domain: <one-or-two words>
---

# Title

**What this is** (3-5 plain sentences a human can read).

## When to use it
Signals/triggers that make this skill apply (wire to awareness/game-loop).

## Decisions
Beginner default(s) + advanced considerations. "Decisions live in" → playbook link(s).

## Procedure
Numbered steps. TX_FLAGS / -- / -D / charge are assumed from conventions.md (one-line pointer, not repeated).

## Commands reference
Table of the CLI commands used.

## Verification
How to confirm the action actually took effect (broadcast ≠ success).

## Errors
Common failures and fixes.

## See also
At least one playbook link and one awareness link.
```

**Frontmatter tags**: `level` (beginner / core / advanced) drives read-order in the generated index; `domain` groups related skills. Keep core skills ≤ ~250 lines (streaming and guild-stack are exempt). Never copy boilerplate that lives here — link to it.

---

## See also

- [SAFETY.md](https://structs.ai/SAFETY) — the trust contract, operation tiers, Approval Block pattern
- [AGENTS.md](https://structs.ai/AGENTS) — Critical Rules (the source of these conventions)
- [awareness/game-loop](https://structs.ai/awareness/game-loop) — when each skill applies
- [knowledge/mechanics/building](https://structs.ai/knowledge/mechanics/building) — PoW and charge ground truth
