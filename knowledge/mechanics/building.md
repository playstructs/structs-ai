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

> **Charge is NOT a pool you spend from.** It is `currentBlock - lastActionBlock`, recomputed every block. A per-action "cost" is a **minimum threshold** the bar must reach — not an amount subtracted from a balance. Any charge-consuming action resets the bar to **0**. You cannot bank charge, and you cannot burst several expensive actions back-to-back. A UI that shows "Charge: N" is showing the current `currentBlock - lastActionBlock`, not a wallet you can save up. Do one action, then wait for the bar to refill (~1/block). Reading it as a stockpile is how players lose engagements.

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

**Build cadence**: a build costs **8** charge and, like every action, resets the bar to 0. With the bar refilling at ~1/block, you can initiate **at most one build roughly every 8 blocks (~48 s)**. A second build attempted too soon fails with `required charge 8, only had 6` (or similar). This single fact governs how fast a base or fleet can be built out — batch-initiate paced ~48 s apart, then compute the proofs later.

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

Both the power-capacity check (4) and the build-limit check (6) reject with the **same** error string — `cannot handle new load requirements (required: X, available: Y)` (error key `capacity_exceeded`). Read the magnitude of the numbers to tell which gate you hit:

- **Tiny, often-equal integers** (e.g. `required: 1, available: 1`) — the **per-player build limit**: you already own the maximum of that struct type. `required` is the type's build limit, `available` is how many you already have. Most planet structs and the Command Ship cap at 1; only the Orbital Shield Generator, Ore Bunker, and fleet combat structs stack. Build the struct on a different player, or accept the cap.
- **Large values** (hundreds of thousands to millions) — the **power-capacity** check, in milliwatts: `required` is the struct's `BuildDraw`, `available` is your remaining capacity (`capacity + capacitySecondary − load − structsLoad`). Free capacity by adding generation or deactivating structs (see [power.md](power.md)).

**Common mistakes**: Building on planet before Command Ship is online. Building Command Ship on planet (must be in fleet, locationType = 2).

---

## Location Types

| Location | Fleet Required | Command Ship |
|----------|----------------|--------------|
| Planet | On station | Online |
| Fleet | N/A | Online |

Command Ship must be built in fleet (locationType = 2), not on planet. Power requirement: 50 W.

---

## Slots

Every planet and every fleet has **4 slots per ambit** — 4 each for space, air, land, and water (16 per location). Fleet-category structs (Command Ship + combat units, IDs 1-13) occupy **fleet** slots; planet-category structs (IDs 14-22) occupy **planet** slots, in an ambit allowed by the type's `possibleAmbit`.

- A build **reserves its slot immediately** at `struct-build-initiate` — even while the struct is still materializing (before its proof-of-work completes). The slot stays occupied for the whole build.
- A struct's position is exposed as `location_type` (planet/fleet), `operating_ambit`, and `slot` (0-3).
- Slot counts are **fixed at 4 per ambit**. Ore-storage capacity (Ore Bunker) and power capacity (generators) scale separately — they do **not** add build slots.
- After destruction a slot can still read occupied for a few blocks (see **StructSweepDelay** above).

Building into a full ambit fails with `struct slot unavailable` / `struct slot already occupied`. Verify free slots before initiating (it's check 5 in the validation order below).

---

## Ambit Encoding

There are **two distinct ambit numbering schemes**. Mixing them up is a common error that produces an `invalid int32` failure on build.

**1. Reach bitmask** — used by `StructType.possibleAmbit` and the weapon-reach fields (each bit is `1 << enum`):

| Ambit | Bit Value |
|-------|-----------|
| none | 1 |
| Water | 2 |
| Land | 4 |
| Air | 8 |
| Space | 16 |
| local | 32 |

The four combat ambits are Water/Land/Air/Space; `none` (1) is a placeholder and `local` (32) is the Command Ship's current-ambit flag. Bitmask values are combined. For example: `6` = land + water, `30` = space + air + land + water. This is how you read a struct type's `possibleAmbit` to learn where it can be built.

**2. Ambit enum** — used by transaction messages and a struct's stored `operatingAmbit`:

| Ambit | Enum |
|-------|------|
| none | 0 |
| water | 1 |
| land | 2 |
| air | 3 |
| space | 4 |
| local | 5 |

**When initiating a build (or moving), the `[operating-ambit]` argument is the ENUM, not the bitmask.** The CLI accepts the lowercase name — `space`, `air`, `land`, `water` (mapping to enum 4/3/2/1). Do **not** pass the bitmask value (e.g. `16` for space); passing a bitmask number where the enum is expected fails with `invalid int32` or targets the wrong ambit. The bitmask (2/4/8/16) is only for interpreting `possibleAmbit` and weapon-reach masks.

```
# Correct — enum name:
structsd tx structs struct-build-initiate TX_FLAGS -- 1-11 2 space 0
# Wrong — bitmask number (16) where the enum is expected:
structsd tx structs struct-build-initiate TX_FLAGS -- 1-11 2 16 0
```

See [struct-types.md](../entities/struct-types.md) for the full table with `possibleAmbit` per type, and [api/integration-notes.md — Ambit](../../api/integration-notes.md#ambit-enum-vs-reach-bitmask).

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
