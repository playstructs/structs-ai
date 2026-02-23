---
name: structs-building
description: Builds and manages structures in Structs. Handles construction, activation, deactivation, movement, defense positioning, and stealth. Use when constructing or managing structs.
---

# Structs Building

## Procedure

1. **Check requirements** — Player online, sufficient Alpha Matter, valid slot (0–3 per ambit), Command Ship online, fleet on station (for planet builds). Query player, planet, fleet.
2. **Initiate build** — `structsd tx structs struct-build-initiate [player-id] [struct-type-id] [operating-ambit] [slot] --from [key-name] --gas auto --gas-adjustment 1.5 -y`.
3. **Proof-of-work** — `structsd tx structs struct-build-compute [struct-id] -D [difficulty] --from [key-name] --gas auto --gas-adjustment 1.5 -y`.
4. **Complete build** — `structsd tx structs struct-build-complete [struct-id] --from [key-name] --gas auto --gas-adjustment 1.5 -y`.
5. **Activate** — `structsd tx structs struct-activate [struct-id] --from [key-name] --gas auto --gas-adjustment 1.5 -y`.
6. **Optional** — Move, set defense, or activate stealth as needed.

## Commands Reference

| Action | CLI Command |
|--------|-------------|
| Initiate build | `structsd tx structs struct-build-initiate [player-id] [struct-type-id] [operating-ambit] [slot]` |
| Build compute (PoW) | `structsd tx structs struct-build-compute [struct-id] -D [difficulty]` |
| Build complete | `structsd tx structs struct-build-complete [struct-id]` |
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
