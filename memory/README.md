# Memory

Your persistent state across sessions: operational state (machine-readable JSON), background-job tracking, intelligence, and narrative handoffs.

This directory is yours. Files here persist across sessions. See [`awareness/continuity.md`](../awareness/continuity.md) for the startup/shutdown protocol and [`awareness/context-handoff.md`](../awareness/context-handoff.md) for the handoff template.

---

## Why some files are JSON

Operational state that scripts and agents read every tick is stored as **JSON** so it can be parsed without guessing. Narrative (session logs, intel dossiers, handoffs) stays **Markdown**. The charge model is baked into the shapes below: charge is a **per-player** bar (`CurrentBlockHeight - lastActionBlock`), never per-struct — see [`conventions.md`](../.cursor/skills/conventions.md#charge-is-per-player-not-per-struct).

---

## Files and shapes

### `player.json` — who you are and your charge plan

```json
{
  "playerId": "1-42",
  "primaryAddress": "structs1...",
  "keyName": "main",
  "guildId": "0-3",
  "lastActionBlock": 1284530,
  "chargePlan": {
    "nextAction": "battleship primary attack",
    "chargeCost": 5,
    "readyBlock": 1284535
  },
  "updatedBlock": 1284530
}
```

`charge` is not stored (it is always `currentBlock - lastActionBlock`); store `lastActionBlock` and the planned next action's cost instead. `readyBlock = lastActionBlock + chargeCost`.

### `game-state.json` — strategic snapshot

```json
{
  "asOfBlock": 1284530,
  "planetId": "2-117",
  "fleetId": "9-42",
  "power": { "capacity": 250000, "load": 180000, "online": true },
  "resources": { "alphaMatter": 14, "storedOre": 0 },
  "planet": { "currentOre": 3, "shield": 125, "blockStartRaid": 0, "raidInProgress": false },
  "priorities": ["refine ore 9-12", "build 2nd OSG", "scout 1-90"],
  "threats": ["1-90 fleet seen adjacent"]
}
```

### `jobs/` — background proof-of-work jobs

One directory per long-running compute (mine ~17h, refine ~34h, big builds, raids). Convention (already referenced by [`awareness/async-operations.md`](../awareness/async-operations.md)):

- `jobs/<job>.json` — structured record (schema below)
- `jobs/<job>.log` — captured stdout/stderr of the background process
- `jobs/<job>.pid` — the process ID, so a later session can check `kill -0 <pid>`

Launch template:

```bash
nohup structsd tx structs struct-ore-mine-compute -D 3 TX_FLAGS_APPROVED -- 14-5 \
  > memory/jobs/mine-14-5.log 2>&1 & echo $! > memory/jobs/mine-14-5.pid
```

`jobs/<job>.json` shape:

```json
{
  "job": "mine-14-5",
  "type": "mine",
  "structId": "14-5",
  "blockStart": 1283900,
  "difficulty": 14000,
  "targetD": 3,
  "pid": 48213,
  "status": "running",
  "expectedReadyBlock": 1294100,
  "autoSubmits": true
}
```

`status`: `running` | `landed` | `failed` | `recalled`. On reconnect, walk the four-state flow in [`awareness/async-operations.md`](../awareness/async-operations.md#reconnecting-to-a-long-job) (PID alive? landed on chain? state matches expectation? silent-failure diagnosis?) before acting.

### `scorecard.json` — self-review (see [`awareness/scorecard.md`](../awareness/scorecard.md))

Written at session end to measure whether you are excelling. Template lives in the scorecard awareness doc.

### Narrative (Markdown, not JSON)

- `YYYY-MM-DD-HHMM-context-handoff.md` — handoff snapshots (template in context-handoff.md)
- `YYYY-MM-DD-*.md` — session logs: key actions, decisions, outcomes
- `intel/` — target dossiers and territory notes (see [`structs-intel`](../.cursor/skills/structs-intel/SKILL.md) and `intel/README.md`)
- `charge-tracker.md` — optional human-readable view of `player.json`'s charge plan (per-player)

---

## On resume, read in this order

1. `jobs/` — **first.** PoW may have completed (or failed) while you were away.
2. `player.json` and `game-state.json` — your operational state.
3. Latest `*-context-handoff.md` — where you left off.
4. `intel/` — standing intelligence.
