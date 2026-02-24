# Building Mechanics

**Purpose**: AI-readable reference for Structs construction. Requirements, proof-of-work, struct limits.

---

## Build Process

| Step | Action | Description |
|------|--------|-------------|
| 1 | `struct-build-initiate` | Starts construction; reserves slot; begins aging |
| 2 | `struct-build-compute` | Calculates proof-of-work hash AND auto-submits `struct-build-complete` |

`struct-build-compute` is a CLI helper that performs the hash calculation and automatically submits the `struct-build-complete` transaction with the results. You only need `struct-build-complete` directly if you computed the hash through external tools.

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

**Open hashing**: Hashing is open by default for all proof-of-work operations (build, mine, refine, raid). Any valid proof is accepted regardless of submitter.

### The -D Flag

The `-D` flag (range 1-64) on compute commands tells the CLI to wait until difficulty drops to the target level before starting the hash.

- Lower `-D` values = longer wait, but hash completes instantly (less CPU work)
- Higher `-D` values = starts sooner, but hash takes exponentially longer
- **Recommended: `-D 8`** for builds, `-D 8` for mine/refine (the sweet spot where hashes are feasible)

### The Difficulty Cliff

At difficulty 8, a hash completes in seconds to minutes. At difficulty 9, it takes hours. At difficulty 10+, it is effectively impossible. **This cliff between D=8 and D=9 is the most important tactical fact in the PoW system.** Always wait until D <= 8 before computing.

### Difficulty Decay Table

Time from initiation until difficulty drops to target level (assuming 6 sec/block):

| Base Difficulty | D=8 | D=7 | D=6 | D=5 |
|----------------|------|------|------|------|
| 200 (Command Ship) | ~11 min | ~12 min | ~13 min | ~14 min |
| 250 (Starfighter) | ~12 min | ~14 min | ~15 min | ~17 min |
| 700 (Ore Ext/Ref) | ~34 min | ~37 min | ~41 min | ~46 min |
| 2,880 (PDC) | ~2.1 hr | ~2.3 hr | ~2.6 hr | ~2.9 hr |
| 3,600 (Ore Bunker) | ~2.5 hr | ~2.8 hr | ~3.2 hr | ~3.5 hr |
| 5,000 (World Engine) | ~3.5 hr | ~3.8 hr | ~4.3 hr | ~4.9 hr |
| 14,000 (Mine) | ~8.1 hr | ~9.2 hr | ~10.8 hr | ~12.7 hr |
| 28,000 (Refine) | ~15.0 hr | ~17.3 hr | ~20.6 hr | ~24.4 hr |

At D=8, the hash itself takes seconds. The wait IS the time. At D=5, slightly longer wait but the hash is trivially instant.

### Strategic Implications

**Initiate early, compute later.** The age clock starts at initiation. Waiting to initiate wastes time. The optimal pattern:

1. Initiate all planned builds/mines/refines immediately (costs only gas)
2. Do other things while age accumulates (scout, plan, build other structs)
3. Come back and compute when difficulty has dropped to D <= 8

**Mining and refining are multi-hour background operations.** A full mine-refine cycle takes ~23-37 hours depending on target difficulty. These should always run as background processes. See [async-operations.md](../awareness/async-operations.md) for the async pattern.

**Never block on PoW.** Launch compute in a background terminal and poll for completion. An agent that waits synchronously for a 12-hour mine compute is wasting 12 hours of game time.

---

## Charge Accumulation

```
charge = CurrentBlockHeight - LastActionBlock
```

Charge accumulates passively from the last action. Different actions consume different amounts:

| Action | Charge Cost | Notes |
|--------|------------|-------|
| Activate | 1 | Same for all struct types |
| Build complete | 8 | Same for all struct types |
| Defend change | 1 | Set or clear defense assignment |
| Move | 8 | Command Ship only |
| Primary weapon | 1-20 | Varies by struct type (1 for fast attackers, 8-20 for heavy) |
| Secondary weapon | 1-8 | Only Starfighter, Cruiser |
| Stealth activate | 1 | Only Stealth Bomber, Submersible |

At ~6 sec/block, 8 blocks of charge = ~48 seconds. Charge is not a bottleneck for most actions but matters for rapid repeated attacks.

---

## Struct Limits (Per Player)

| Struct Type | Limit |
|-------------|-------|
| Planetary Defense Cannon | 1 |
| Command Ship | 1 |

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

---

## Build Validation Order

1. Player online
2. Command Ship online (if building on planet)
3. Fleet onStation (if building on planet)
4. Sufficient power capacity (BuildDraw + PassiveDraw)
5. Available slots (correct type: space/air/land/water)
6. Per-player limits (1 PDC, 1 Command Ship)

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

- [power.md](power.md) — Power capacity for building
- [fleet.md](fleet.md) — Fleet status, Command Ship rules
- [combat.md](combat.md) — Planetary Defense Cannon
- [async-operations.md](../awareness/async-operations.md) — Background PoW, job tracking, pipeline strategy
- `reference/action-quick-reference.md` — struct-build-initiate, struct-build-complete
- `schemas/formulas.md` — Build difficulty, charge accumulation
- `knowledge/entities/struct-types.md` — Struct types, power requirements
