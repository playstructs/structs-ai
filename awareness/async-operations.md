# Async Operations

**Purpose**: How to manage proof-of-work as background operations. The pipeline pattern. Job tracking. Multi-player orchestration.

---

## Why Async Matters

Every major action in Structs requires proof-of-work: building, mining, refining, raiding. PoW difficulty drops logarithmically with age — meaning the optimal strategy is to **initiate early** and **compute later**, not to initiate and immediately grind.

Real timescales (at ~6 sec/block, waiting for D=3):

| Operation | Base Difficulty | Time to D=3 |
|-----------|----------------|-------------|
| Build (Command Ship) | 200 | ~17 min |
| Build (Ore Extractor) | 700 | ~57 min |
| Build (PDC) | 2,880 | ~3.7 hr |
| Build (World Engine) | 5,000 | ~6.4 hr |
| Mine | 14,000 | ~17 hr |
| Refine | 28,000 | ~34 hr |

Mining takes 17+ hours. Refining takes 34+ hours. An agent that blocks on PoW — waiting synchronously for a single operation to complete — wastes enormous game time doing nothing. In a competitive multiplayer game, this is fatal.

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

## Transaction Sequencing

The Cosmos SDK tracks a **sequence number** per account. Each transaction increments the sequence. If two transactions from the same account are submitted before the first is included in a block (~6 seconds), the second fails with `account sequence mismatch`.

**Rule**: Submit transactions from the same account **sequentially** — wait ~6 seconds between TXs for the previous one to be included in a block.

Transactions from **different accounts** can run in parallel with no issues. This is why the multi-player pattern works: each player account submits independently while the agent orchestrates them all.

| Scenario | Parallel? | Notes |
|----------|-----------|-------|
| Two TXs from same account | No | Wait ~6s between submissions |
| TXs from different accounts | Yes | No sequence conflict |
| Queries (read-only) | Yes | No sequence tracking on reads |

If you hit `account sequence mismatch, expected N, got N-1`: wait for the pending TX to confirm, then retry.

---

## The Difficulty Cliff

The PoW difficulty formula is logarithmic:

```
difficulty = 64 - floor(log10(age) / log10(baseDifficulty) * 63)
```

At difficulty 8, a hash completes in seconds. At difficulty 9, it takes hours or is impossible. This cliff between D=8 and D=9 matters — but even at D=8 some CPU is burned on hashing.

**Use `-D 3` for all compute commands.** At D=3 the hash is trivially instant and zero CPU cycles are wasted. The extra wait over D=8 is modest for builds and well worth it for the compute savings.

---

## Difficulty Planning Table

Pre-calculated time from initiation to target difficulty (6 sec/block):

| Base Difficulty | Example | D=8 | D=5 | D=3 (recommended) |
|----------------|---------|------|------|------|
| 200 | Command Ship | 11 min | 14 min | 17 min |
| 250 | Starfighter | 12 min | 17 min | 20 min |
| 450 | Frigate | 22 min | 30 min | 37 min |
| 700 | Ore Extractor | 34 min | 46 min | 57 min |
| 2,880 | PDC | 2.0 hr | 2.9 hr | 3.7 hr |
| 3,600 | Ore Bunker | 2.4 hr | 3.6 hr | 4.6 hr |
| 5,000 | World Engine | 3.2 hr | 4.9 hr | 6.4 hr |
| 14,000 | Mine | 8.1 hr | 12.7 hr | 17.2 hr |
| 28,000 | Refine | 15.0 hr | 24.4 hr | 33.7 hr |

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

| Job | Struct | Action | Start Block | D=3 Est Block | Terminal | Status |
|-----|--------|--------|-------------|---------------|----------|--------|
| J1 | 5-715 | build | 23042 | ~23611 | term-3 | running |
| J2 | 5-716 | build | 23042 | ~23611 | term-4 | running |
| J3 | 5-715 | mine | 23500 | ~33840 | -- | pending (not yet launched) |

# Completed Jobs

| Job | Struct | Action | Completed Block | Result |
|-----|--------|--------|-----------------|--------|
| J0 | 5-714 | build | 23000 | success |
```

Update this file every game loop tick. On session resume, check all "running" jobs immediately using the procedure below — they may have completed, failed silently, or still be in flight.

---

## Reconnecting to a Long Job

Compute jobs run for minutes to ~34 hours. When you start a new session — or your terminal disconnected and you reattached — every running job in `memory/jobs/` is in one of four states: **still computing**, **completed and submitted**, **completed but submit failed**, or **the process died**. Find out which before you do anything else.

The four-state flowchart:

```
For each job in memory/jobs/ marked "running":

  1. Is the PID still alive?        → ps -p <pid>
       │
       ├── ALIVE     → still computing. Cross-check ETA against current block.
       │              If past ETA by > 30 min, attach the terminal (or read
       │              memory/jobs/<job>.log) and look for stuck output.
       │
       └── DEAD      → step 2.

  2. Did the auto-submit land on chain? Query the txhash if you logged one;
     otherwise query the affected entity (struct/planet/fleet/player) for
     the expected state delta:
       │
       ├── EXPECTED STATE   → Success. Mark complete in memory/jobs/.
       │                     If a follow-up action was queued (e.g. refine
       │                     after mine), start it now.
       │
       └── UNCHANGED STATE  → Submit failed silently. Step 3.

  3. Diagnose the silent failure:
       - Read memory/jobs/<job>.log for the last 50 lines
       - Check chain status for the signing key: `structsd q tx --events 'message.sender=<addr>'`
         (or query recent player activity in the guild stack)
       - Most common causes:
           • Sequence-number collision (another tx from the same key
             went out concurrently) → just re-launch the compute
           • Gas estimate too low for current chain load → re-launch
             with a higher `--gas-adjustment`
           • Game state changed (struct destroyed, planet released,
             agreement closed) → original consent is stale; re-verify
             before re-launching
```

### Suggested per-job log file

Whenever you launch a compute in the background, capture its stdout/stderr so this verification flow has a paper trail:

```
nohup structsd tx structs struct-ore-refine-compute -D 3 \
  --from agent-1-42 --gas auto --gas-adjustment 1.5 -y \
  -- 5-103 \
  > memory/jobs/refine-5-103.log 2>&1 &

echo $! > memory/jobs/refine-5-103.pid
```

The `.log` file plus the `.pid` file plus a `memory/jobs/<job>.md` metadata entry is the minimum viable kit for verifying a long expedition across sessions.

### Re-verifying the consent (especially for refines)

A 34-hour refine is deferred consent. By the time the proof lands, your planet may have been raided, your fleet may have moved, your power may have shifted. Before letting the auto-submit land — or immediately after it does — re-check:

- The refinery and extractor still belong to you
- Your power posture still accepts the auto-activated state changes
- No raid in flight is about to invalidate the result
- The `--from` key is still primary on your player (no `address-revoke` happened)

If the world has changed materially since you launched, the right action may be `kill <pid>` rather than letting the deferred submit go through. See [`SAFETY.md`](../SAFETY.md) "Background Expeditions" for the consent rule.

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

> **Ore is stealable. Refining takes ~34 hours at D=3. This creates a vulnerability window that drives all PvP conflict.**

After mining completes, your ore sits exposed for the entire refining duration. This window is where raids happen. Defenders must balance:

- **Patience**: At D=3 the hash is free but exposure is ~34 hours
- **Urgency**: Higher `-D` values reduce exposure time but waste CPU on harder hashes
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
