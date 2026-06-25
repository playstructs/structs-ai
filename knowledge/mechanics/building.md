# Building Mechanics

**Purpose**: AI-readable reference for Structs construction. Requirements, proof-of-work, struct limits.

---

## Build Process

| Step | Action | Description |
|------|--------|-------------|
| 1 | `struct-build-initiate` | Starts construction; reserves slot; begins aging |
| 2 | `struct-build-compute` | Calculates proof-of-work hash, auto-submits `struct-build-complete`, and struct **auto-activates** |

`struct-build-compute` is a CLI helper that performs the hash calculation and automatically submits the `struct-build-complete` transaction with the results. The struct then **automatically activates** — no separate `struct-activate` call is needed after building. Use `struct-activate` only to re-activate a struct that was previously deactivated. You only need `struct-build-complete` directly if you computed the hash through external tools.

---

## Build Requirements

| Requirement | Description |
|-------------|-------------|
| Player online | Sufficient power (see [power.md](power.md)) |
| Power capacity | BuildDraw + PassiveDraw available |
| Resources | Sufficient Alpha Matter |
| Valid location | Correct slot type (space/air/land/water) |
| Fleet on station | Required for planet building |
| Command Ship online | Required for planet building |

---

## Proof-of-Work (Build Complete)

```
age = currentBlockHeight - blockStart
if age <= 1 then difficulty = 64
else difficulty = 64 - floor(log10(age) / log10(BuildDifficulty) * 63)

hashInput = structId + "BUILD" + blockStart + "NONCE" + nonce
isValid = HashBuildAndCheckDifficulty(hashInput, proof, age, BuildDifficulty)
```

Difficulty is age-based: older builds require less work.

**Permission-gated hashing**: Completing a proof is *not* permissionless. Each proof-of-work operation (build, mine, refine, raid) requires its matching `hash_*` permission bit, checked both at the ante layer (on the signing address) and at the handler layer (on the object's owner). Owners always qualify because their primary address holds `PermAll`; a delegate must be granted the relevant `hash_*` bit to submit proofs on your behalf. For the full mechanism — all four hash types, the universal input format, the algorithm, difficulty decay, and the permission model — see [hashing.md](hashing.md).

### The -D Flag

The `-D` flag (range 1-64) on compute commands tells the CLI to wait until difficulty drops to the target level before starting the hash.

- Lower `-D` values = longer wait, but hash completes instantly (zero CPU wasted)
- Higher `-D` values = starts sooner, but hash takes exponentially longer and burns CPU
- **Recommended: `-D 3`** for all operations — the hash is trivially instant and no CPU cycles are wasted on hard hashing

### The Difficulty Cliff

At difficulty 8, a hash completes in seconds to minutes. At difficulty 9, it takes hours. At difficulty 10+, it is effectively impossible. **This cliff between D=8 and D=9 is the most important tactical fact in the PoW system.** However, even at D=8 some CPU is burned. Using D=3 eliminates all wasted compute.

### Difficulty Decay Table

Time from initiation until difficulty drops to target level (assuming 6 sec/block):

| Base Difficulty | D=8 | D=5 | D=3 |
|----------------|------|------|------|
| 200 (Command Ship) | ~11 min | ~14 min | ~17 min |
| 250 (Starfighter) | ~12 min | ~17 min | ~20 min |
| 700 (Ore Ext/Ref) | ~34 min | ~46 min | ~57 min |
| 2,880 (PDC) | ~2.0 hr | ~2.9 hr | ~3.7 hr |
| 3,600 (Ore Bunker) | ~2.4 hr | ~3.6 hr | ~4.6 hr |
| 5,000 (World Engine) | ~3.2 hr | ~4.9 hr | ~6.4 hr |
| 14,000 (Mine) | ~8.1 hr | ~12.7 hr | ~17.2 hr |
| 28,000 (Refine) | ~15.0 hr | ~24.4 hr | ~33.7 hr |

At D=3, the hash is trivially instant. The wait IS the time — and zero CPU is wasted. Higher `-D` values trade shorter wait for exponentially more compute burned on hard hashes.

### Strategic Implications

**Initiate early, compute later.** The age clock starts at initiation. Waiting to initiate wastes time. The optimal pattern:

1. Initiate all planned builds/mines/refines immediately (costs only gas)
2. Do other things while age accumulates (scout, plan, build other structs)
3. Come back and compute when difficulty has dropped to D=3

**Mining and refining are multi-hour background operations.** A full mine-refine cycle takes ~51 hours at D=3. These should always run as background processes. See [async-operations.md](../../awareness/async-operations.md) for the async pattern.

**Never block on PoW.** Launch compute in a background terminal and poll for completion. An agent that waits synchronously for a 12-hour mine compute is wasting 12 hours of game time.

---

## Charge Accumulation

Charge is a **per-player** resource — a single shared bar, not a per-struct value. It is the number of blocks since the player's last charge-consuming action:

```
charge = CurrentBlockHeight - player.LastActionBlock
```

Every charge-consuming action by **any** of the player's structs (build, activate, attack, move, defense change, stealth) draws from and resets this **one** shared bar. Charge accumulates passively at 1 per block (~6 sec/block) while the player is idle. There is no separate charge per struct — to know whether an action can fire, query the player, not the struct.

Action costs (the charge the player's bar must hold to act):

| Action | Charge Cost | Notes |
|--------|------------|-------|
| Build (initiate) | 8 | Same for all struct types |
| Activate | 2 | Same for all struct types |
| Defend change | 1 | Set or clear defense assignment |
| Move | 3 | Command Ship only |
| Primary weapon | 3-5 | 3 for fast attackers (Command Ship, Starfighter, Pursuit Fighter, Tank); 5 for heavier hulls |
| Secondary weapon | 3-5 | Battleship/Starfighter 5, Cruiser 3 |
| Stealth activate | 2 | Only Stealth Bomber, Submersible |

At ~6 sec/block, a 5-charge action needs ~30 seconds of accumulation since the player's last action. Because the bar is shared, rapid sequences (activating several structs, or repeated attacks) are gated by it — space the actions out, or they fail with `"required charge X but player had Y"`.

**Charge cannot be banked or burst.** Because `charge = CurrentBlockHeight - LastActionBlock`, every charge-consuming action resets the bar to **0** — you do not draw a cost off a running balance, the whole bar zeroes and refills linearly from there. There is no way to stockpile charge for an "alpha strike" of several expensive attacks in one block; idling longer than your next action's cost gains you nothing extra. Plan combat as a sequence of single actions spaced ~1 block/charge apart, not a saved-up burst.

---

## Struct Limits (Per Player)

| Struct Type | Limit |
|-------------|-------|
| Command Ship | 1 |
| Ore Extractor | 1 |
| Ore Refinery | 1 |
| Jamming Satellite | 1 |
| Planetary Defense Cannon | 1 |
| Field Generator | 1 |
| Continental Power Plant | 1 |
| World Engine | 1 |
| Orbital Shield Generator | unlimited |
| Ore Bunker | unlimited |
| Fleet combat structs (IDs 2-13) | unlimited |

Orbital Shield Generator and Ore Bunker are the planet structs whose only effect is contributing to the planetary shield; both are unlimited, so a player can stack them (power permitting) to raise the shield. All other planet structs and the Command Ship remain 1 per player.

---

## Struct State Machine

```
Materialized → Built (Offline) → Built (Online) → Destroyed
                    ↕                  ↕
                 Locked            Hidden (stealth)
```

| State | Power Draw | Can Act | Notes |
|-------|-----------|---------|-------|
| Materialized | BuildDraw | No | Awaiting proof-of-work completion |
| Built (Offline) | None | No | Needs activation |
| Built (Online) | PassiveDraw | Yes | Normal operating state |
| Locked | Unchanged | No | Temporary, cannot activate/deactivate |
| Hidden | Unchanged | Yes | Stealth mode, invisible to other players |
| Destroyed | None | No | Terminal state |

**StructSweepDelay**: After destruction, the slot may appear occupied for 5 blocks. Planet/fleet slot arrays may still reference the destroyed struct ID during this delay. The `destroyed_block` field records the exact block height of destruction.

### Status field (numeric)

The struct `status` field is a **bit-flag integer** (`StructState`). The chain sets and clears individual bits, so any value is a composite of these bits:

| Bit | Value | Meaning |
|-----|-------|---------|
| Materialized | 1 | Slot reserved, awaiting proof-of-work |
| Built | 2 | Build complete |
| Online | 4 | Active / drawing passive power |
| Stored | 8 | In storage |
| Hidden | 16 | Stealth active |
| Destroyed | 32 | Destroyed (terminal) |
| Locked | 64 | Locked |

Common composite values you'll see:

| Status | Bits | Meaning |
|--------|------|---------|
| 0 | (none) | Stateless — pre-build / not yet materialized |
| 1 | Materialized | Build initiated, awaiting PoW |
| 3 | Materialized + Built | Built but offline |
| 7 | Materialized + Built + Online | Online / active (normal operating state) |
| 35 | Materialized + Built + Destroyed (1+2+32) | **Destroyed** (the Online bit is cleared on destruction) |

Read `status` as flags, not an enum: the Online bit (`status & 4`) is what gates whether a struct can act, and the Destroyed bit (`status & 32`) marks a terminal struct (a `status` of `35` is a destroyed struct).

---

## Build Validation Order

1. Player online
2. Command Ship online (if building on planet)
3. Fleet onStation (if building on planet)
4. Sufficient power capacity (BuildDraw + PassiveDraw)
5. Available slots (correct type: space/air/land/water)
6. Per-player build limits (most planet structs and the Command Ship are 1 per player; Orbital Shield Generator, Ore Bunker, and fleet structs are unlimited)

**Common mistakes**: Building on planet before Command Ship is online. Building Command Ship on planet (must be in fleet, locationType = 2).

---

## Location Types

| Location | Fleet Required | Command Ship |
|----------|----------------|--------------|
| Planet | On station | Online |
| Fleet | N/A | Online |

Command Ship must be built in fleet (locationType = 2), not on planet. Power requirement: 50,000 W.

---

## Ambit Encoding

Struct types have a `possibleAmbit` bit-flag field that encodes which ambits the struct can operate in:

| Ambit | Bit Value |
|-------|-----------|
| Space | 16 |
| Air | 8 |
| Land | 4 |
| Water | 2 |

Values are combined. For example: 6 = land + water, 30 = space + air + land + water. When initiating a build, the `[operating-ambit]` argument must be a valid ambit for that struct type.

See [struct-types.md](../entities/struct-types.md) for the full table with `possibleAmbit` per type.

---

## See Also

- [hashing.md](hashing.md) — Canonical proof-of-work reference: all four hash types, universal input format, algorithm, difficulty decay, hash permissions
- [power.md](power.md) — Power capacity for building
- [fleet.md](fleet.md) — Fleet status, Command Ship rules
- [combat.md](combat.md) — Planetary Defense Cannon
- [async-operations.md](../../awareness/async-operations.md) — Background PoW, job tracking, pipeline strategy
- `reference/action-quick-reference.md` — struct-build-initiate, struct-build-complete
- `schemas/formulas.md` — Build difficulty, charge accumulation
- `knowledge/entities/struct-types.md` — Struct types, power requirements
