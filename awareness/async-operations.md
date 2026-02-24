# Async Operations

**Purpose**: How to manage proof-of-work as background operations. The pipeline pattern. Job tracking. Multi-player orchestration.

---

## Why Async Matters

Every major action in Structs requires proof-of-work: building, mining, refining, raiding. PoW difficulty drops logarithmically with age — meaning the optimal strategy is to **initiate early** and **compute later**, not to initiate and immediately grind.

Real timescales (at ~6 sec/block, waiting for D=8):

| Operation | Base Difficulty | Time to D=8 |
|-----------|----------------|-------------|
| Build (Command Ship) | 200 | ~11 min |
| Build (Ore Extractor) | 700 | ~34 min |
| Build (PDC) | 2,880 | ~2.1 hr |
| Build (World Engine) | 5,000 | ~3.5 hr |
| Mine | 14,000 | ~8.1 hr |
| Refine | 28,000 | ~15.0 hr |

Mining takes 8+ hours. Refining takes 15+ hours. An agent that blocks on PoW — waiting synchronously for a single operation to complete — wastes enormous game time doing nothing. In a competitive multiplayer game, this is fatal.

---

## The Pipeline Pattern

Instead of sequential operations:

```
initiate build → wait 34 min → compute → initiate mine → wait 8 hr → compute → ...
```

Run a **pipeline** of parallel operations:

```
initiate build A, build B, build C → scout players → check threats →
  → compute A (ready!) → activate A → initiate mine on A →
  → compute B (ready!) → activate B →
  → scout more → compute C (ready!) → ...
```

### Rules

1. **Initiate everything immediately.** Initiation is cheap (just gas). It starts the age clock. Every block you delay initiation is a block of wasted aging.
2. **Launch compute in background.** Use background terminal processes. Poll for completion.
3. **Always have something aging.** If nothing is aging, you are losing tempo. After completing a mine, immediately initiate the next one.
4. **Batch-initiate at session start.** When you begin a session, initiate every action you plan to take. Then do strategic work while they age.
5. **Check jobs first every turn.** Before assessing state or making decisions, check what background PoW has completed since last check.

---

## The Difficulty Cliff

The PoW difficulty formula is logarithmic:

```
difficulty = 64 - floor(log10(age) / log10(baseDifficulty) * 63)
```

At difficulty 8, a hash completes in seconds. At difficulty 9, it takes hours or is impossible. **This cliff between D=8 and D=9 is the most important tactical fact in PoW.** Always wait until D <= 8.

Use `-D 8` for all compute commands. The marginal benefit of waiting for D=5 (a few hours more) is negligible — the hash is already instant at D=8.

---

## Difficulty Planning Table

Pre-calculated time from initiation to target difficulty (6 sec/block):

| Base Difficulty | Example | D=8 | D=7 | D=6 | D=5 |
|----------------|---------|------|------|------|------|
| 200 | Command Ship | 11 min | 12 min | 13 min | 14 min |
| 250 | Starfighter | 12 min | 14 min | 15 min | 17 min |
| 450 | Frigate | 22 min | 24 min | 27 min | 30 min |
| 700 | Ore Extractor | 34 min | 37 min | 41 min | 46 min |
| 2,880 | PDC | 2.1 hr | 2.3 hr | 2.6 hr | 2.9 hr |
| 3,600 | Ore Bunker | 2.5 hr | 2.8 hr | 3.2 hr | 3.5 hr |
| 5,000 | World Engine | 3.5 hr | 3.8 hr | 4.3 hr | 4.9 hr |
| 14,000 | Mine | 8.1 hr | 9.2 hr | 10.8 hr | 12.7 hr |
| 28,000 | Refine | 15.0 hr | 17.3 hr | 20.6 hr | 24.4 hr |

To calculate for any base difficulty and target D:
```
age_blocks = 10 ^ ((64 - D) * log10(baseDifficulty) / 63)
time_seconds = age_blocks * 6
```

---

## Background PoW Management

### Launching Background Compute

Launch compute commands in background terminals. The CLI's `-D` flag handles the waiting internally — it polls the chain for current block height and starts hashing when difficulty drops to the target.

After launching, track the job in `memory/jobs.md` (see template below) and periodically check the terminal for completion.

### Polling Strategy

- Check job terminals every game loop tick
- Look for exit codes: 0 = success, non-zero = failure
- On success, immediately proceed with next action (activate, initiate next operation)
- On failure, diagnose and re-launch

---

## Job Tracker

Maintain `memory/jobs.md` to track all background PoW across sessions:

```markdown
# Active Jobs

| Job | Struct | Action | Start Block | D=8 Est Block | Terminal | Status |
|-----|--------|--------|-------------|---------------|----------|--------|
| J1 | 5-715 | build | 23042 | ~23379 | term-3 | running |
| J2 | 5-716 | build | 23042 | ~23379 | term-4 | running |
| J3 | 5-715 | mine | 23500 | ~28342 | -- | pending (not yet launched) |

# Completed Jobs

| Job | Struct | Action | Completed Block | Result |
|-----|--------|--------|-----------------|--------|
| J0 | 5-714 | build | 23000 | success |
```

Update this file every game loop tick. On session resume, check all "running" jobs immediately — they may have completed while you were away.

---

## Charge Tracker

Maintain `memory/charge-tracker.md` to know when structs can act:

```markdown
# Struct Charge Status

| Struct | Type | Last Action Block | Next Action | Charge Needed | Ready Block |
|--------|------|-------------------|-------------|---------------|-------------|
| 5-714 | CMD | 23000 | attack | 1 | 23001 |
| 5-715 | Ext | 23500 | mine | 8 (build) | 23508 |
| 5-716 | Ref | 23500 | refine | 8 (build) | 23508 |
```

At ~6 sec/block, most charge costs are trivial (8 blocks = 48 seconds). But rapid repeated attacks on heavy weapons (charge 20) take 2 minutes between shots.

---

## The Async Game Loop

Modified from the standard [game loop](game-loop.md):

```
Check Jobs → Assess → Plan → Initiate → Dispatch → Verify → Update Memory → Repeat
```

### 0. Check Jobs

Before anything else, check all background terminals for completed PoW. Mark completions in job tracker. Proceed with post-completion actions (activate struct, start next operation).

### 1. Assess

Standard state assessment. Power, resources, threats, opportunities.

### 2. Plan

Decide actions. **Think in pipelines**: what should I initiate now so it's ready later?

### 3. Initiate

Batch all initiation transactions. Start age clocks on everything you plan to compute later. Initiations are cheap.

### 4. Dispatch

Launch compute commands in background terminals for anything where difficulty has dropped to D <= 8. Record in job tracker.

### 5. Verify

Query game state for completed actions. Confirm structs built, ore mined, etc.

### 6. Update Memory

Write job tracker, charge tracker, game state. This is what your next session (or next loop tick) will read first.

---

## Multi-Player Orchestration

An agent can control multiple players simultaneously, dramatically increasing throughput.

### Workspace Structure

```
workspace/
├── SOUL.md                    # Shared identity framework
├── AGENTS.md                  # Shared reference
├── players/
│   ├── alpha/
│   │   ├── IDENTITY.md        # Player-specific identity
│   │   ├── TOOLS.md           # Player-specific config (address, servers)
│   │   └── memory/
│   │       ├── jobs.md        # Player-specific job tracker
│   │       ├── charge-tracker.md
│   │       └── game-state.md
│   ├── beta/
│   │   ├── IDENTITY.md
│   │   ├── TOOLS.md
│   │   └── memory/
│   └── gamma/
│       └── ...
├── shared/
│   ├── intel/                 # Shared reconnaissance
│   ├── strategy.md            # Coordinated strategy
│   └── comms.md               # Inter-player coordination log
└── knowledge/                 # Shared game knowledge
```

### Coordination Patterns

**Staggered resource pipeline**: Player A mines while Player B builds. When A's mine completes, B refines while A builds. No player is ever idle.

**Shared defense**: Players in the same guild share power infrastructure. One player builds PDC while another builds Ore Bunker. Cover each other's weaknesses.

**Scouting rotation**: One player scouts while others execute. Rotate the scout role each cycle.

**Raid coordination**: One player moves fleet for raid, another defends home. Time raid compute to complete when defense is strongest.

### Per-Player Loop

When controlling multiple players, run the game loop for each player in round-robin:

1. Check all players' job statuses
2. For each player: assess, plan, initiate, dispatch
3. Update all memory files
4. Move to next loop tick

Prioritize the player with the most urgent pending action (completed PoW, exposed ore, incoming threat).

---

## Strategic Timing Insight

The most important strategic tension in the PoW system:

> **Ore is stealable. Refining takes ~15 hours. This creates a vulnerability window that drives all PvP conflict.**

After mining completes, your ore sits exposed for the entire refining duration. This window is where raids happen. Defenders must balance:

- **Patience**: Wait for lower refine difficulty = faster hash, less CPU, but longer exposure
- **Urgency**: Refine at D=8 immediately = ~15 hr exposure instead of ~24 hr at D=5
- **Deception**: Use stealth, shields, and misdirection to survive the window

See [resources.md](../knowledge/mechanics/resources.md) for the full ore vulnerability analysis.

---

## See Also

- [Game Loop](game-loop.md) — The standard loop this extends
- [Context Handoff](context-handoff.md) — Persisting job state across sessions
- [Continuity](continuity.md) — Memory file management
- [Building Mechanics](../knowledge/mechanics/building.md) — PoW formula, difficulty table
- [Resources](../knowledge/mechanics/resources.md) — Ore vulnerability window
- [Tempo](../playbooks/meta/tempo.md) — Strategic timing
