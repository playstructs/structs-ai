# Work and proof-of-work

**Purpose**: How a client computes the SHA-256 proofs that mining, refining, building and
raiding require — and why the reference client spends most of its time deliberately idle.

For the protocol itself — what the chain validates, the decay maths, the CLI path — see
[knowledge/mechanics/hashing.md](../../knowledge/mechanics/hashing.md). This page is the
client implementation.

---

## The hash

Single-pass SHA-256 over an ASCII string, hex digest, checked for leading zeros. The
webapp uses `js-sha256` rather than `SubtleCrypto`, because the loop needs to be
synchronous and run millions of times.

**Input format** — concatenation, no separators except the raid target delimiter:

```
{objectId}{TASK_TYPE}{blockStart}NONCE{nonce}          build, mine, refine
{fleetId}@{planetId}RAID{blockStart}NONCE{nonce}       raid
```

Built as a prefix once, then completed per attempt:

```js
// src/js/factories/TaskStateFactory.js
task_state.prefix = task_state.object_id + task_state.task_type
                  + task_state.block_start + TASK.NONCE_PREFIX;

// src/js/models/TaskState.js
getMessage(nonce) { return this.prefix + nonce + this.postfix; }
```

`postfix` is always empty. `TASK.IDENTITY_PREFIX` exists in the constants and is never
used — dead code, not a protocol feature.

Worked examples:

| Type | Full input for nonce `42` |
|---|---|
| Build | `5-1BUILD1283900NONCE42` |
| Mine | `14-5MINE1283900NONCE42` |
| Refine | `15-5REFINE1290000NONCE42` |
| Raid | `4-5@6-10RAID1300000NONCE42` |

**Difficulty is a count of leading hex zeros**, not a target integer:

```js
// src/js/workers/TaskWorker.js
function difficultyCheck(hash, difficulty) {
    for (let position = 1; position <= difficulty; position++) {
        if (hash[position - 1] !== "0") {
            return false;
        }
    }
    return true;
}
```

This matches `HashBuildAndCheckDifficulty` in the chain's `x/structs/types/work.go`
exactly, which is what makes any conformant client interoperable.

**Nonces start at a random point**, unlike the CLI which starts at 1:

```js
this.nonce_start = Math.floor(Math.random() * 10000000000);
this.nonce_current = this.nonce_start;
```

Any nonce is valid, so this is purely a choice. It does mean two clients working the same
task will not duplicate each other's effort.

---

## Difficulty decays, so waiting is cheaper than working

```js
// src/js/models/TaskState.js
getCurrentDifficulty(){
  const age = this.getCurrentAgeEstimate();
  if (age <= 1) {
    return 64;
  }
  let difficulty = 64 - Math.floor(Math.log10(age) / Math.log10(this.difficulty_target) * 63);
  return Math.max(1, difficulty)
}
```

`age` is blocks since the on-chain anchor. `difficulty_target` is the per-operation range
(`build_difficulty`, `ore_mining_difficulty`, `ore_refining_difficulty`, or the planet's
`planetary_shield` for raids). At `age <= 1` difficulty is 64, which is unreachable in
practice; it falls to 1 once age reaches the range.

**The client estimates age from the wall clock**, not by querying each iteration:

```js
getCurrentAgeEstimate() {
  const current_time = new Date();
  const estimated_blocks_past = Math.floor((current_time - this.block_checkpoint_time) / TASK.ESTIMATED_BLOCK_TIME);
  this.block_current_estimated = Math.floor(this.block_checkpoint + estimated_blocks_past);
  return this.block_current_estimated - this.block_start;
}
```

At 6,000ms per block, anchored to a checkpoint refreshed from real block height. It can
drift, which is exactly why the result is re-checked before submission.

### The idle policy

The worker refuses to start while difficulty is above 10, polling every ten seconds:

```js
if (state.status === TASK_STATUS.WAITING){
    while (difficulty > TASK.DIFFICULTY_START) {   // DIFFICULTY_START = 10
        await new Promise(r => setTimeout(r, TASK.DIFFICULTY_START_SLEEP_DELAY));
        difficulty = state.getCurrentDifficulty();
    }
    state.setStatus(TASK_STATUS.RUNNING);
    postMessage([state]);
}
```

This is a **policy choice, not a protocol rule** — and it is a different choice from the
`-D 3` this documentation recommends for the CLI. Difficulty 10 is 10 leading hex zeros,
around 2^40 expected attempts; difficulty 3 is around 4,096. The webapp starts hashing
far earlier than the CLI would and burns considerably more CPU for it.

For an agent, `-D 3` remains the right default: initiate early, come back later, hash for
milliseconds. `forceRun(pid)` is the escape hatch if you ever need a proof now regardless
of cost.

---

## The worker loop

```js
let sessionIterations = 1;
while (true) {
    const nonce = state.getNextNonce();
    const message = state.getMessage(nonce);
    const hash = sha256(message);

    if (difficultyCheck(hash, difficulty)){
        state.setResult(nonce, message, hash, difficulty);
        postMessage([state]);
        break;
    }

    if (state.iterations % TASK.CHECKPOINT_COMMIT === 0) {
        state.iterations_since_last_start = sessionIterations;
        postMessage([state]);
    }

    if (state.iterations % TASK.DIFFICULTY_RECALCULATE === 0) {
        difficulty = state.getCurrentDifficulty();

        // Check to see if a previous hash result is now relevant again
        if (state.result_exists && state.result_difficulty >= difficulty) {
            state.setPreviousResult(difficulty);
            postMessage([state]);
            break;
        }
    }
    sessionIterations++;
}
```

Every five million iterations it reports progress and recomputes difficulty. That second
job enables a neat trick: if you previously found a hash at difficulty 12, and decay has
since brought the requirement down to 12 or below, that old hash is **now good enough**
and the task completes without hashing again.

### Orchestration

One `Worker` per task, capped at five concurrent (`MAX_CONCURRENT_PROCESSES`); the rest
queue. There is **no nonce-range partitioning** — each worker picks its own random start
and never coordinates. Progress arrives on the main thread as periodic state snapshots,
so the UI stays responsive even with five workers saturating cores.

Cancellation is explicit. Mine and refine tasks are killed automatically when GRASS
reports the cycle cleared (`block === 0`); raid tasks are killed when the raid ends or
the target's shields come back up.

---

## Restoring after a reload

**Proof-of-work progress is not persisted.** Nonce position, iteration counts and partial
results are all lost on reload. But the *tasks* survive, because they are reconstructed
from the server:

```js
async restoreTasksFromDB() {
  if (Object.keys(this.processes).length || this.running_queue.length || this.waiting_queue.length) {
    return;
  }
  const work = await this.guildAPI.getWorkByPlayerId(this.gameState.keyPlayers[PLAYER_TYPES.PLAYER].id);
  work.forEach((workTask) => {
    const task = this.taskStateFactory.initTaskFromWork(workTask);
    this.spawn(task);
  });
}
```

`GET /api/work/player/{id}` reads the guild stack's `view.work`, which derives outstanding
work from chain state. Losing nonce progress costs nothing in expectation — every attempt
is independent, so a restarted search has exactly the same expected remaining work as one
that had been running for an hour.

The lesson for your own client: **the chain already knows what work you owe**. You do not
need to persist a task list, only to ask.

---

## Completion

Before submitting, the client re-checks the proof against current difficulty:

```js
checkResultHashDifficulty() {
  return this.result_difficulty >= this.getCurrentDifficulty();
}
```

Because age is estimated from the wall clock, a proof found near a difficulty boundary can
be stale by the time it surfaces. If it is, the task **respawns** rather than submitting a
transaction that would fail on-chain. Worth copying.

Valid proofs go out on the **immediate lane** — no charge cost:

| Task | Message | Payload |
|---|---|---|
| Build | `/structs.structs.MsgStructBuildComplete` | `{ structId, proof, nonce }` |
| Mine | `/structs.structs.MsgStructOreMinerComplete` | `{ structId, proof, nonce }` |
| Refine | `/structs.structs.MsgStructOreRefineryComplete` | `{ structId, proof, nonce }` |
| Raid | `/structs.structs.MsgPlanetRaidComplete` | `{ fleetId, proof, nonce }` |

`proof` is the hex digest, `nonce` the winning integer. The raid message carries only the
fleet ID — the chain reconstructs the planet from fleet position, so a mismatch there is
not something you can paper over client-side.

---

## Task lifecycle

```
INITIATED → STARTING → WAITING → RUNNING → COMPLETED
                          ↑         ↓
                        PAUSED ←────┘        (capacity, or manager offline)
              any state → TERMINATED         (kill, sweep, cycle cleared)
              COMPLETED → STARTING           (proof went stale, respawn)
```

Tasks are spawned by GRASS events rather than by the code that requested the action:
`struct_block_build_start`, `struct_block_ore_mine_start`,
`struct_block_ore_refine_start`, and a shield-vulnerable raid status. The chain tells you
when there is work; you do not assume it from your own transaction.

The manager itself starts `OFFLINE` and comes online eight seconds after page load, which
keeps five hashing workers from competing with initial render.

---

*Verified against structs-webapp `6eec7f7` (2026-07-21): `src/js/workers/TaskWorker.js`,
`src/js/managers/TaskManager.js`, `src/js/models/TaskState.js`,
`src/js/factories/TaskStateFactory.js`. Cross-checked against
`structsd/x/structs/types/work.go`.*
