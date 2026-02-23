# Building Mechanics

**Purpose**: AI-readable reference for Structs construction. Requirements, proof-of-work, struct limits.

---

## Two-Step Build Process

| Step | Action | Proof-of-Work |
|------|--------|---------------|
| 1 | `struct-build-initiate` | No |
| 2 | `struct-build-complete` | Yes (age-based) |

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

---

## Charge Accumulation

```
charge = CurrentBlockHeight - LastActionBlock
```

Charge required for activate; `ActivateCharge` = 1 for all struct types (v0.10.0-beta).

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

**StructSweepDelay**: After destruction, the slot may appear occupied for 5 blocks. Planet/fleet slot arrays may still reference the destroyed struct ID during this delay.

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

## See Also

- [power.md](power.md) — Power capacity for building
- [fleet.md](fleet.md) — Fleet status, Command Ship rules
- [combat.md](combat.md) — Planetary Defense Cannon
- `reference/action-quick-reference.md` — struct-build-initiate, struct-build-complete
- `schemas/formulas.md` — Build difficulty, charge accumulation
- `knowledge/entities/struct-types.md` — Struct types, power requirements
