---
name: structs-combat
description: Executes combat operations in Structs. Covers attacks, raids, defense setup, and stealth positioning. Use when attacking enemy structs, raiding a planet for ore, setting up defenders, activating stealth, moving fleet for raids, or preparing for incoming attacks. Raids require fleet movement and background PoW compute.
---

# Structs Combat

## Procedure

1. **Scout** — `structsd query structs planet [id]`, `structsd query structs struct [id]` for targets, shield, defenses.
2. **Optional stealth** — `structsd tx structs struct-stealth-activate [struct-id] --from [key-name] --gas auto --gas-adjustment 1.5 -y` before attack.
3. **Attack structs** — `structsd tx structs struct-attack [operating-struct-id] [target-struct-id,target-id2,...] [weapon-system] --from [key-name] --gas auto --gas-adjustment 1.5 -y`. Can target multiple structs.
4. **Raid flow** — Move fleet to target: `structsd tx structs fleet-move [fleet-id] [destination-location-id] --from [key-name] --gas auto --gas-adjustment 1.5 -y`. Then `structsd tx structs planet-raid-compute [fleet-id] -D 3 --from [key-name] --gas auto --gas-adjustment 1.5 -y`. Compute auto-submits the complete transaction. Move fleet home. Refine stolen ore immediately.
5. **Defense setup** — `structsd tx structs struct-defense-set [defender-struct-id] [protected-struct-id]` to assign; `struct-defense-clear [defender-struct-id]` to remove.

## Commands Reference

| Action | CLI Command |
|--------|-------------|
| Attack | `structsd tx structs struct-attack [operating-struct-id] [target-ids] [weapon-system]` |
| Raid compute (PoW + auto-complete) | `structsd tx structs planet-raid-compute [fleet-id] -D 3` |
| Raid complete (manual, rarely needed) | `structsd tx structs planet-raid-complete [fleet-id]` |
| Fleet move | `structsd tx structs fleet-move [fleet-id] [destination-location-id]` |
| Set defense | `structsd tx structs struct-defense-set [defender-id] [protected-id]` |
| Clear defense | `structsd tx structs struct-defense-clear [defender-id]` |
| Stealth on | `structsd tx structs struct-stealth-activate [struct-id]` |
| Stealth off | `structsd tx structs struct-stealth-deactivate [struct-id]` |

Raid flow: fleet-move → planet-raid-compute (auto-submits complete) → fleet-move home → refine stolen ore. Common tx flags: `--from [key-name] --gas auto --gas-adjustment 1.5 -y`.

## Raid Timing

`planet-raid-compute` uses `-D` flag (range 1-64) to wait until difficulty drops before hashing. Raid PoW difficulty depends on the target planet's properties. Launch raid compute in a background terminal — it may take minutes to hours depending on difficulty. Use `-D 3` for zero wasted CPU. Compute auto-submits the complete transaction.

**Important**: Your fleet is locked "away" during the raid compute. You cannot build on your planet while your fleet is away. Plan accordingly — complete all planet builds before moving fleet for a raid.

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

## Combat Readiness Checklist

Before engaging in combat, verify all conditions:

- [ ] **Command Ship online** — `structsd query structs struct [cmd-ship-id]`, status = Online
- [ ] **Fleet on station** (for defense) or **fleet away** (for raids) — `structsd query structs fleet [fleet-id]`
- [ ] **Sufficient charge** — Weapons cost 1-20 charge. At ~6 sec/block, 20 charge = 2 minutes
- [ ] **Power capacity headroom** — Total load must stay below capacity during combat
- [ ] **Defense structs assigned** — PDC, Orbital Shield, defenders set via `struct-defense-set`
- [ ] **Available struct slot** — If building combat structs, check planet slots (0-3 per ambit)
- [ ] **Ore refined or secured** — Unrefined ore is stealable. Refine before engaging in raids that may invite retaliation

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
