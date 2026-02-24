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

- Lower `-D` values = longer wait, but hash completes quickly (less CPU work)
- Higher `-D` values = starts sooner, but hash takes much longer
- **Recommended: `-D 5`** for most operations

### Expected Build Times (with -D 5)

| Struct | Build Difficulty | Approx Time |
|--------|------------------|-------------|
| Command Ship | 200 | ~2-5 min |
| Starfighter | 250 | ~3-5 min |
| Ore Extractor | 700 | ~10-20 min |
| Ore Refinery | 700 | ~10-20 min |
| Small Arms | 700 | ~10-20 min |
| PDC | 2,880 | ~30-45 min |
| Ore Bunker | 3,600 | ~30-45 min |
| World Engine | 5,000 | ~45-60 min |

Mining and refining also use proof-of-work:
- Mine compute: difficulty 14,000 → ~15-30 min
- Refine compute: difficulty 28,000 → ~30-45 min

---

## Charge Accumulation

```
charge = CurrentBlockHeight - LastActionBlock
```

Charge required for activate; `ActivateCharge` = 1 for all struct types.

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
- `reference/action-quick-reference.md` — struct-build-initiate, struct-build-complete
- `schemas/formulas.md` — Build difficulty, charge accumulation
- `knowledge/entities/struct-types.md` — Struct types, power requirements
