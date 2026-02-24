---
name: structs-combat
description: Executes combat operations in Structs. Covers attacks, raids, defense setup, and stealth positioning. Use when engaging in or preparing for combat.
---

# Structs Combat

## Procedure

1. **Scout** — `structsd query structs planet [id]`, `structsd query structs struct [id]` for targets, shield, defenses.
2. **Optional stealth** — `structsd tx structs struct-stealth-activate [struct-id] --from [key-name] --gas auto --gas-adjustment 1.5 -y` before attack.
3. **Attack structs** — `structsd tx structs struct-attack [operating-struct-id] [target-struct-id,target-id2,...] [weapon-system] --from [key-name] --gas auto --gas-adjustment 1.5 -y`. Can target multiple structs.
4. **Raid flow** — Move fleet to target: `structsd tx structs fleet-move [fleet-id] [destination-location-id] --from [key-name] --gas auto --gas-adjustment 1.5 -y`. Then `structsd tx structs planet-raid-compute [fleet-id] -D 5 --from [key-name] --gas auto --gas-adjustment 1.5 -y`. Compute auto-submits the complete transaction. Move fleet home. Refine stolen ore immediately.
5. **Defense setup** — `structsd tx structs struct-defense-set [defender-struct-id] [protected-struct-id]` to assign; `struct-defense-clear [defender-struct-id]` to remove.

## Commands Reference

| Action | CLI Command |
|--------|-------------|
| Attack | `structsd tx structs struct-attack [operating-struct-id] [target-ids] [weapon-system]` |
| Raid compute (PoW + auto-complete) | `structsd tx structs planet-raid-compute [fleet-id] -D 5` |
| Raid complete (manual, rarely needed) | `structsd tx structs planet-raid-complete [fleet-id]` |
| Fleet move | `structsd tx structs fleet-move [fleet-id] [destination-location-id]` |
| Set defense | `structsd tx structs struct-defense-set [defender-id] [protected-id]` |
| Clear defense | `structsd tx structs struct-defense-clear [defender-id]` |
| Stealth on | `structsd tx structs struct-stealth-activate [struct-id]` |
| Stealth off | `structsd tx structs struct-stealth-deactivate [struct-id]` |

Raid flow: fleet-move → planet-raid-compute (auto-submits complete) → fleet-move home → refine stolen ore. Common tx flags: `--from [key-name] --gas auto --gas-adjustment 1.5 -y`.

## Raid Timing

`planet-raid-compute` uses `-D` flag (range 1-64) to wait until difficulty drops before hashing. With `-D 5`, expect ~20-40 minutes depending on chain load. Compute auto-submits the complete transaction.

## Verification

- Query planet shield, struct health
- Query fleet location (onStation vs away)
- Stolen ore: refine immediately; verify with struct/player queries
- Attack results include health values (remaining health after attack) -- use to assess damage dealt
- Raid `seized_ore` is tracked on `planet_raid` record -- query to see total ore stolen

## Combat Notes

- Minimum damage after reduction is 1 -- attacks always deal at least 1 damage
- Offline/destroyed structs cannot counter-attack
- Each struct can only commit once per attack action (no double-commit)
- Target struct existence is validated before attack proceeds
- Hashing for raid-compute is open by default -- any valid proof accepted

## Error Handling

- **"insufficient charge"** — Weapon needs charge; check struct state.
- **"target invalid"** — Target may be destroyed, stealthed, or out of range.
- **"fleet not away"** — Raids require fleet away; move fleet first.
- **"proof invalid"** — Re-run raid-compute with correct difficulty.
- **Stolen ore** — Refine immediately; ore is stealable until refined.

## See Also

- `knowledge/mechanics/combat.md`
- `knowledge/mechanics/fleet.md`
- `knowledge/mechanics/resources.md`
