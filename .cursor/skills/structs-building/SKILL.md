---
name: structs-building
description: Builds and manages structures in Structs. Handles construction, activation, deactivation, movement, defense positioning, and stealth. Use when constructing or managing structs.
---

# Structs Building

## Procedure

1. **Check requirements** — Player online, sufficient Alpha Matter, valid slot (0-3 per ambit), Command Ship online, fleet on station (for planet builds). Query player, planet, fleet.
2. **Initiate build** — `structsd tx structs struct-build-initiate [player-id] [struct-type-id] [operating-ambit] [slot] --from [key-name] --gas auto --gas-adjustment 1.5 -y`.
3. **Proof-of-work** — `structsd tx structs struct-build-compute [struct-id] -D 5 --from [key-name] --gas auto --gas-adjustment 1.5 -y`. This calculates the hash AND auto-submits the complete transaction. No separate `struct-build-complete` needed.
4. **Activate** — `structsd tx structs struct-activate [struct-id] --from [key-name] --gas auto --gas-adjustment 1.5 -y`.
5. **Optional** — Move, set defense, or activate stealth as needed.

## Compute vs Complete

`struct-build-compute` is a helper that performs proof-of-work and automatically submits `struct-build-complete` with the hash results. You only need `struct-build-complete` if you computed the hash through external tools and want to submit it manually.

## The -D Flag

The `-D` flag (range 1-64) tells compute to wait until difficulty drops to the specified level before starting the hash. Difficulty decreases logarithmically as the struct ages. **Use `-D 8`** — at D=8, the hash completes in seconds. At D=9+, hashing is effectively impossible.

## Expected Build Times

Time from initiation until compute completes (assuming 6 sec/block):

| Struct | Type ID | Build Difficulty | D=8 | D=5 |
|--------|---------|------------------|------|------|
| Command Ship | 1 | 200 | ~11 min | ~14 min |
| Starfighter | 3 | 250 | ~12 min | ~17 min |
| Ore Extractor | 14 | 700 | ~34 min | ~46 min |
| Ore Refinery | 15 | 700 | ~34 min | ~46 min |
| PDC | 19 | 2,880 | ~2.1 hr | ~2.9 hr |
| Ore Bunker | 18 | 3,600 | ~2.5 hr | ~3.5 hr |
| World Engine | 22 | 5,000 | ~3.5 hr | ~4.9 hr |

**Initiate early, compute later.** The age clock starts at initiation. Batch-initiate all planned builds, then launch compute in background terminals. Do other things while waiting. See `awareness/async-operations.md`.

## Commands Reference

| Action | CLI Command |
|--------|-------------|
| Initiate build | `structsd tx structs struct-build-initiate [player-id] [struct-type-id] [operating-ambit] [slot]` |
| Build compute (PoW + auto-complete) | `structsd tx structs struct-build-compute [struct-id] -D 5` |
| Build complete (manual, rarely needed) | `structsd tx structs struct-build-complete [struct-id]` |
| Build cancel | `structsd tx structs struct-build-cancel [struct-id]` |
| Activate | `structsd tx structs struct-activate [struct-id]` |
| Deactivate | `structsd tx structs struct-deactivate [struct-id]` |
| Move | `structsd tx structs struct-move [struct-id] [new-ambit] [new-slot] [new-location]` |
| Set defense | `structsd tx structs struct-defense-set [defender-struct-id] [protected-struct-id]` |
| Clear defense | `structsd tx structs struct-defense-clear [defender-struct-id]` |
| Stealth on | `structsd tx structs struct-stealth-activate [struct-id]` |
| Stealth off | `structsd tx structs struct-stealth-deactivate [struct-id]` |
| Generator infuse | `structsd tx structs struct-generator-infuse [struct-id] [amount]` |

**Limits**: 1 PDC per player, 1 Command Ship per player. Command Ship must be in fleet. Generator infusion is IRREVERSIBLE. Common tx flags: `--from [key-name] --gas auto --gas-adjustment 1.5 -y`.

## Verification

- `structsd query structs struct [id]` — status = Online (or Built/Offline if not activated)
- Struct appears in planet/fleet struct list

## Error Handling

- **"insufficient resources"** — Check Alpha Matter; use `structsd query structs player [id]`.
- **"power overload"** — Add capacity before activating; going offline blocks all actions.
- **"invalid slot"** — Slot 0–3 per ambit; check existing structs.
- **"Command Ship required"** — Command Ship must be online for planet builds.
- **"fleet not on station"** — Move fleet or wait before building on planet.

## See Also

- `knowledge/mechanics/building.md`
- `knowledge/mechanics/power.md`
- `knowledge/entities/struct-types.md`
- `knowledge/entities/entity-relationships.md`
- `awareness/async-operations.md` — Background PoW, pipeline strategy
