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

The `-D` flag (range 1-64) tells compute to wait until difficulty drops to the specified level before starting the hash. Difficulty decreases over time as the struct ages (more blocks since initiation).

- **`-D 5`** (recommended): waits longer, but hash completes quickly once started
- **`-D 10`**: starts sooner, hash takes a bit longer
- **`-D 20`+**: starts quickly, but hash is computationally expensive (10+ minutes)

## Expected Build Times (with -D 5)

| Struct | Type ID | Build Difficulty | Approx Time |
|--------|---------|------------------|-------------|
| Command Ship | 1 | 200 | ~2-5 min |
| Starfighter | 3 | 250 | ~3-5 min |
| Ore Extractor | 14 | 700 | ~10-20 min |
| Ore Refinery | 15 | 700 | ~10-20 min |
| PDC | 19 | 2880 | ~30-45 min |
| Ore Bunker | 18 | 3600 | ~30-45 min |
| World Engine | 22 | 5000 | ~45-60 min |

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
