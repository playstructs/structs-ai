# Hashing (Proof-of-Work)

**Purpose**: The single canonical reference for the Structs proof-of-work hashing mechanism. Covers the four hash types, the universal input format, the algorithm, age-based difficulty, per-type clocks, the permission model, and the CLI/client surfaces. If you only read one PoW doc, read this one. Build-specific framing lives in [building.md](building.md); strategy and job-tracking live in [async-operations.md](../../awareness/async-operations.md).

---

## What Hashing Is and Why It Exists

Four game actions are not finalized by a simple transaction — they are *committed* by a transaction and then *finalized* by submitting a valid proof-of-work hash:

- **Build** a struct
- **Mine** ore
- **Refine** ore into Alpha Matter
- **Raid** a planet

Each of these is a two-step action: an `initiate` (or equivalent state change) that starts a clock, followed by a `complete` message that carries a `proof` and a `nonce`. The chain re-derives the hash from on-chain state plus your nonce, checks it equals your proof, and checks it clears the current difficulty. Only then does the action finalize.

Hashing exists to make these high-value actions **cost real work or real time**, and to make that cost **decay with age**. A freshly initiated operation is effectively impossible to complete; an aged one is trivial. This is the engine behind the core tempo rule: **initiate early, compute later.** It is also what creates the ore-theft vulnerability window — refined Alpha is safe, but ore sits stealable for the entire ~34h refine clock. See [resources.md](resources.md) and [async-operations.md](../../awareness/async-operations.md).

---

## The Four Hash Types

All four share one algorithm and one validator. They differ only in the hash-input keyword, the ID they key off, which clock supplies `blockStart`, and which parameter supplies the difficulty range.

| Type | Complete message | Keyed on | Difficulty range source | Typical range |
|------|------------------|----------|-------------------------|---------------|
| Build | `MsgStructBuildComplete` | `structId` | `StructType.BuildDifficulty` | 200–5,000 (per struct type) |
| Mine | `MsgStructOreMinerComplete` | `structId` | `StructType.OreMiningDifficulty` | 14,000 (Ore Extractor) |
| Refine | `MsgStructOreRefineryComplete` | `structId` | `StructType.OreRefiningDifficulty` | 28,000 (Ore Refinery) |
| Raid | `MsgPlanetRaidComplete` | `fleetId` (+ target `planetId`) | planet `PlanetaryShield` | 25 base + defense contributions |

> The "difficulty range" is the tuning parameter the decay formula divides by. A **higher** range means difficulty decays **more slowly** (the operation stays hard for longer). It is *not* the difficulty itself.

Each `complete` message carries exactly two PoW fields plus the signer:

| Field | Type | Meaning |
|-------|------|---------|
| `creator` | address | Signer (injected at broadcast) |
| `structId` / `fleetId` | string | The object being completed |
| `proof` | string | Lowercase hex SHA-256 digest of the hash input |
| `nonce` | string | The value that made the proof clear difficulty |

---

## Universal Input Format

Every hash type builds its input string by concatenating known fields with **literal keyword separators** — no delimiters, no JSON, no length prefixes. The block height is rendered as a base-10 string, the nonce is appended as a string.

**Struct operations (build / mine / refine):**

```
hashInput = {id} + {KEYWORD} + {blockStart} + "NONCE" + {nonce}
```

where `{KEYWORD}` is one of `"BUILD"`, `"MINE"`, `"REFINE"`.

**Raid (the one exception — two IDs joined by `@`):**

```
hashInput = {fleetId} + "@" + {planetId} + "RAID" + {blockStart} + "NONCE" + {nonce}
```

### Worked examples

| Type | Inputs | Hash input string |
|------|--------|-------------------|
| Build | struct `5-1`, blockStart `1`, nonce `42` | `5-1BUILD1NONCE42` |
| Mine | struct `14-5`, blockStart `1283900`, nonce `7` | `14-5MINE1283900NONCE7` |
| Refine | struct `15-5`, blockStart `1290000`, nonce `7` | `15-5REFINE1290000NONCE7` |
| Raid | fleet `4-5`, planet `6-10`, blockStart `1300000`, nonce `7` | `4-5@6-10RAID1300000NONCE7` |

### Universal format rules

| Aspect | Convention |
|--------|------------|
| Separators | Literal keywords `BUILD` / `MINE` / `REFINE` / `RAID` and `NONCE`, concatenated with no extra delimiter |
| Raid only | `@` between `fleetId` and `planetId` |
| Block height | Decimal string (Go `strconv.FormatUint(..., 10)`) — no zero-padding |
| Nonce | A **string** on the wire. The CLI/clients brute-force decimal integers (`"1"`, `"2"`, …) |
| Proof | **Lowercase hex** SHA-256 digest, 64 chars, must equal the recomputed hash exactly (case-sensitive) |
| Encoding | No base64, no raw bytes — `proof` and `nonce` are plain protobuf `string` fields |

If you compute proofs with an external tool, you **must** reproduce this exact concatenation and lowercase-hex encoding, or the chain will reject the proof.

---

## The Algorithm

```
hash       = sha256( utf8_bytes(hashInput) )        # single SHA-256
proofHex   = lowercase_hex(hash)                     # 64 chars, [0-9a-f]
isValid    = (submittedProof == proofHex)
             AND (first `difficulty` hex chars of proofHex are all '0')
```

Key facts:

- **One SHA-256 pass.** No double-hash, no keccak, no salt beyond the input string itself.
- **Difficulty is counted in leading hex zeros**, not bits and not bytes. A difficulty of `D` requires the digest to begin with `D` consecutive `0` hex characters, so the per-attempt success probability is `1 / 16^D`.
- **The proof must match exactly.** The chain recomputes the hash from on-chain state + your nonce; if your submitted `proof` is not byte-identical to that recomputation, it fails before the difficulty check.
- **Max difficulty is 64** (the full digest length).

The validator (`HashBuildAndCheckDifficulty`) returns both validity and the `achievedDifficulty` (how many leading zeros the digest actually had), which is emitted in the `EventHashSuccess` event.

---

## Difficulty and Decay

Difficulty is **age-based** and drops logarithmically as the operation's clock ages:

```
age = currentBlockHeight - blockStart

if age <= 1:
    difficulty = 64                                  # effectively impossible
else:
    difficulty = 64 - floor( log10(age) / log10(range) * 63 )
    difficulty = max(difficulty, 1)                  # never below 1
```

- `age` is in blocks (~6 sec/block).
- `range` is the per-type difficulty source from the table above (`BuildDifficulty`, `OreMiningDifficulty`, `OreRefiningDifficulty`, or the planet's `PlanetaryShield`).
- At `age <= 1` the difficulty is pinned to 64, so you cannot complete on the same block you initiated.
- A larger `range` makes the curve fall more slowly — bigger operations stay hard longer.

### The difficulty cliff

| Difficulty | Hash time (rough) |
|-----------|-------------------|
| ≤ 8 | seconds to minutes |
| 9 | hours |
| 10+ | effectively impossible |

The jump between **D=8 and D=9** is the single most important tactical fact in PoW. But even D=8 burns CPU. The recommendation is to wait for **D=3**, where the hash is trivially instant and **zero** CPU is wasted — the wait *is* the cost.

### Time-to-difficulty table (6 sec/block)

| Range | Example | D=8 | D=5 | D=3 (recommended) |
|-------|---------|-----|-----|-------------------|
| 200 | Command Ship build | ~11 min | ~14 min | ~17 min |
| 250 | Starfighter build | ~12 min | ~17 min | ~20 min |
| 700 | Ore Ext/Ref build | ~34 min | ~46 min | ~57 min |
| 2,880 | PDC build | ~2.0 hr | ~2.9 hr | ~3.7 hr |
| 5,000 | World Engine build | ~3.2 hr | ~4.9 hr | ~6.4 hr |
| 14,000 | Mine | ~8.1 hr | ~12.7 hr | ~17.2 hr |
| 28,000 | Refine | ~15.0 hr | ~24.4 hr | ~33.7 hr |

To compute for any range and target D:

```
age_blocks   = 10 ^ ( (64 - D) * log10(range) / 63 )
time_seconds = age_blocks * 6
```

---

## The Per-Type Clock (`blockStart`)

The age that drives difficulty is measured from a clock specific to each operation. Knowing when each clock starts (and resets) tells you when a proof becomes cheap.

| Type | Clock field | Starts / resets when |
|------|-------------|----------------------|
| Build | `blockStartBuild` | Set when the struct is created (build initiated). One-shot per struct. |
| Mine | `blockStartOreMine` | Set when the miner goes online; cleared when offline; **reset after each successful mine** so the next cycle starts fresh. |
| Refine | `blockStartOreRefine` | Same pattern as mining: set on online, cleared offline, reset after each successful refine. |
| Raid | `blockStartRaid` | Set when the defending Command Ship becomes raid-vulnerable. **`0` means the planet is not raidable** — a raid proof is rejected outright until the clock is armed (this prevents a trivial difficulty collapse). |

Because mining and refining clocks reset every cycle, a long-running extractor/refinery re-ages from scratch after each completion — you re-wait the full decay each time.

---

## Permissions Relating to Hashing

**Hashing is *not* permissionless.** Completing a proof is gated at two independent layers, and each of the four types requires its **own** matching permission bit (not all four).

### Layer 1 — Address permission (ante handler)

Before a `complete` message reaches its handler, the ante decorator checks the **signing address** holds the matching bit:

| Message | Required bit |
|---------|--------------|
| `MsgStructBuildComplete` | `PermHashBuild` |
| `MsgStructOreMinerComplete` | `PermHashMine` |
| `MsgStructOreRefineryComplete` | `PermHashRefine` |
| `MsgPlanetRaidComplete` | `PermHashRaid` |

An unregistered address, or a registered address lacking the bit, is rejected here.

### Layer 2 — Object permission (keeper handler)

The handler then verifies the caller may act on the **owner** of the object via `CanBuildHashedBy` / `CanMineHashedBy` / `CanRefineHashedBy` / `CanRaidHashedBy`, each of which runs a `PermissionCheck` for the same single bit (`PermHashBuild` / `PermHashMine` / `PermHashRefine` / `PermHashRaid`). The check passes if the caller:

1. is the **owner** of the object, **or**
2. holds object-level permission for that bit on the owner, **or**
3. meets the **guild-rank** threshold for that permission.

### The permission bits

| Bit | Value | Label | Gates |
|-----|-------|-------|-------|
| `PermHashBuild` | 1,048,576 | `hash_build` | Build completion |
| `PermHashMine` | 2,097,152 | `hash_mine` | Mine completion |
| `PermHashRefine` | 4,194,304 | `hash_refine` | Refine completion |
| `PermHashRaid` | 8,388,608 | `hash_raid` | Raid completion |
| `PermHashAll` | 15,728,640 | — | Composite of all four |

A player's **primary address** receives `PermAll`, so owners can always complete their own work. The interesting case is delegation.

### Delegation recipe (open-but-granted hashing)

Because completing a proof requires only the relevant `hash_*` bit, you can hand the grind to a low-trust worker key without exposing your play/transfer permissions:

```
# Grant a worker address play + all hash permissions (and nothing else)
structsd tx structs permission-set-on-address cosmos1worker... 15728641 \
  --from primary --gas auto -y
# 15728641 = PermPlay (1) | PermHashAll (15728640)
```

That worker can now submit `*-complete` proofs on your behalf but cannot move tokens or restructure your account. See [structs-permissions](../../.cursor/skills/structs-permissions/SKILL.md) for the full delegation model.

### Throttle

The ante also throttles proofs to **one attempt per object per block** (keyed by the struct/fleet ID). Spamming proofs for the same object in a single block is rejected.

---

## CLI and Client Surfaces

### CLI — compute vs complete

| Command | What it does | Flags |
|---------|--------------|-------|
| `struct-build-compute [struct id]` | Waits for difficulty to reach target, brute-forces the nonce locally, then auto-submits the `complete` message | `-D` / `--difficulty_target_start` (1–64) + standard tx flags |
| `struct-ore-mine-compute [struct id]` | Same, for mining | same |
| `struct-ore-refine-compute [struct id]` | Same, for refining | same |
| `planet-raid-compute [fleet id]` | Same, for raids | same |
| `struct-build-complete [struct id] [proof] [nonce]` | Submits a proof you computed externally | standard tx flags (no `-D`) |
| `struct-ore-mine-complete [struct id] [proof] [nonce]` | Manual mine completion | same |
| `struct-ore-refine-complete [struct id] [proof] [nonce]` | Manual refine completion | same |
| `planet-raid-complete [fleet id] [proof] [nonce]` | Manual raid completion | same |

The **`-D` flag** tells `*-compute` not to start hashing until difficulty has dropped to that level. The CLI polls block height and sleeps until the target is reached. **Use `-D 3`** for instant, zero-waste hashing. The `*-compute` commands auto-submit hours later, so they always run in the auto-approved form — see [conventions](../../.cursor/skills/conventions.md) and [SAFETY.md](../../SAFETY.md).

### Client — the webapp TaskManager

The web client implements the **identical** scheme: a `TaskManager` spawns a Web Worker per task that loops `sha256(prefix + nonce)` until the leading-hex-zero check passes, then submits the matching `Msg*Complete` (proof = the hex digest, nonce = decimal string). It builds the same input strings (`{id}{KEYWORD}{blockStart}NONCE{nonce}`, raid uses `@`), uses the same `64 - floor(log10(age)/log10(range)*63)` difficulty formula, waits at `age <= 1` (difficulty 64), and re-checks difficulty before submitting so a stale proof restarts rather than failing on-chain. Any conformant client — CLI, webapp, or your own bot — interoperates because the input format and algorithm are fixed.

---

## Not Proof-of-Work (Disambiguation)

Several other game flows use the words "proof" or "hash" but are **not** this SHA-256 PoW:

| Flow | Mechanism | Notes |
|------|-----------|-------|
| Address registration | **secp256k1 signature** over `PLAYER{playerId}ADDRESS{address}` | A signature proof of key ownership, not a difficulty hash |
| Guild-join proxy / signup | **secp256k1 signature** (`proofPubKey` + `proofSignature`) | Authorization, not PoW |
| Combat randomness (`IsSuccessful`) | `hash(blockHash, playerNonce) % denominator` | Uses hashing for RNG, but is not a submitted proof |
| Planet explore / allocation / player create (`ReactorInfuse`) | No proof at all | Single-step transactions |

Only **build, mine, refine, and raid** use the submitted-SHA-256-proof mechanism described in this doc.

---

## Source References

For verification against the chain and client implementations.

**structsd (chain):**

| Concern | Location |
|---------|----------|
| Hash + difficulty utilities | `x/structs/types/work.go` — `HashBuild`, `CalculateDifficulty`, `HashBuildAndCheckDifficulty` |
| Build handler | `x/structs/keeper/msg_server_struct_build_complete.go` |
| Mine handler | `x/structs/keeper/msg_server_struct_ore_miner_complete.go` |
| Refine handler | `x/structs/keeper/msg_server_struct_ore_refinery_complete.go` |
| Raid handler | `x/structs/keeper/msg_server_planet_raid_complete.go` |
| Object permission checks | `x/structs/keeper/player_cache.go` — `CanBuildHashedBy` / `CanMineHashedBy` / `CanRefineHashedBy` / `CanRaidHashedBy` |
| Address permission map (ante) | `app/ante/maps.go` (PoW message → `PermHash*`) |
| Proof throttle | `app/ante/throttle.go` (`ProofMessages`) |
| Permission bit constants | `x/structs/types/permissions.go` (`PermHashBuild/Mine/Refine/Raid/All`) |
| Compute CLI | `x/structs/client/cli/tx_struct_build_compute.go` (and mine/refine/raid equivalents) |
| Complete CLI (autocli) | `x/structs/module/autocli.go` |
| Message protos | `proto/structs/structs/tx.proto` (`MsgStructBuildComplete`, etc.) |

**structs-webapp (client):**

| Concern | Location |
|---------|----------|
| Orchestration, queues, submission | `src/js/managers/TaskManager.js` |
| Message construction, difficulty/age math | `src/js/models/TaskState.js` |
| SHA-256 nonce loop (Web Worker) | `src/js/workers/TaskWorker.js` |
| Per-type input prefix construction | `src/js/factories/TaskStateFactory.js` |
| Complete message queueing | `src/js/managers/SigningClientManager.js` |

---

## See Also

- [building.md](building.md) — Build-specific PoW framing, struct states, charge
- [async-operations.md](../../awareness/async-operations.md) — Background compute, the pipeline pattern, job tracking
- [combat.md](combat.md) — Raids, shield vulnerability, the raid clock
- [resources.md](resources.md) — Ore vulnerability window driven by the refine clock
- [permissions.md](permissions.md) — Full 25-bit permission model and handler reference
- [schemas/formulas.md](../../schemas/formulas.md) — Difficulty formulas alongside other game math
- [conventions](../../.cursor/skills/conventions.md) — Proof-of-work policy and the `-D 3` default
