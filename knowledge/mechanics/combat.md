# Combat Mechanics

**Purpose**: AI-readable reference for Structs combat. Consolidates formulas, requirements, outcomes, and edge cases.

---

## Combat Actions

| Action | Message | Description |
|--------|---------|-------------|
| Attack | `struct-attack` | Direct struct-to-struct combat |
| Defend | `struct-defense-set` | Set struct to defense mode (blocking) |
| Raid | `planet-raid-complete` | Planet assault; steals unrefined ore |

---

## Health Points

Each struct has a Max HP that determines how much damage it can absorb before destruction.

| Struct | Max HP |
|--------|--------|
| Command Ship | 6 |
| All other structs | 3 |

- Damage reduces current HP. At 0 HP the struct is destroyed (see Struct Destruction below).
- **HP does not regenerate.** A damaged struct stays damaged.
- Defenders absorb attacks directed at the struct they protect — the protected struct only takes damage after the defender is destroyed or fails to block.

---

## Damage Formulas

### Multi-Shot Damage

```
damage = sum(successful_shots) - damageReduction
if damage >= health then health = 0
else health = health - damage
```

| Variable | Description |
|----------|-------------|
| weaponShots | Number of shots per attack |
| weaponShotSuccessRate | Per-shot success (Numerator/Denominator) |
| weaponDamage | Damage per successful shot |
| damageReduction | Defense reduction |
| health | Target current health |

**Algorithm**: For each shot, `IsSuccessful(weaponShotSuccessRate)`; if true, add `weaponDamage`. Apply `damageReduction` to total. Minimum damage after reduction is 1. Cap at target health.

**Attack results**: Attack events include health results (remaining health after attack) in addition to damage amounts.

### Evasion

```
if weaponControl == guided then successRate = guidedDefensiveSuccessRate
else successRate = unguidedDefensiveSuccessRate
canEvade = IsSuccessful(successRate) if successRate.Numerator != 0
```

### Recoil Damage

Attacker takes damage after firing: `health = health - weaponRecoilDamage`.

### Post-Destruction Damage

If `health == 0` and `postDestructionDamage > 0`, damage applies to surrounding structs.

### Blocking

```
if defender exists and defender.operatingAmbit == attacker.operatingAmbit then
  canBlock = IsSuccessful(defender.blockingSuccessRate)
```

Requires: defender assigned, defender online, same ambit as target.

### Counter-Attack

| Scenario | Damage |
|----------|--------|
| Same ambit | `counterAttackDamage` (full) |
| Different ambit | `counterAttackDamage / 2` |

**Requirements**: Counter-attack requires a full readiness check. Offline structs cannot counter-attack. The counter-attack also validates weapon system existence on the defending struct.

### Planetary Defense Cannon

```
damage = planetaryShieldBase + sum(defenseCannon.damage for each cannon on planet)
```

- **Limit**: 1 Planetary Defense Cannon per player
- Special damage when planet is attacked

---

## Requirements

| Requirement | Attack | Raid |
|-------------|--------|------|
| Player online | ✓ | ✓ |
| Sufficient power | ✓ | ✓ |
| Sufficient charge | ✓ | ✓ |
| Fleet away | — | ✓ |
| Command Ship online | — | ✓ |
| Proof-of-work | — | ✓ |

---

## Outcomes

| Outcome | Description |
|---------|-------------|
| victory | Attacker/raider wins |
| defeat | Defender wins |
| attackerRetreated | Attacker withdrew |

**Raid status**: Raid status includes `seizedOre` -- the amount of ore stolen during the raid. This is tracked on the `planet_raid` record and simplifies victory handling. See `schemas/entities/planet.md` for the `planet_raid` table schema.

---

## Edge Cases

- **Raid loot**: Only the player's mined ore (`storedOre`) can be stolen — not unmined ore on the planet (`remainingOre`). Alpha Matter is secure. A successful raid seizes **all** of the target player's `storedOre`, not a partial amount. One raid = total loss.
- **Success rate**: `IsSuccessful` uses `hash(blockHash, playerNonce) % Denominator < Numerator`
- **Damage overflow**: Post-destruction damage carries over to adjacent structs
- **Blocking**: Defender must be in same operating ambit as attacker for full counter-attack
- **Minimum damage**: After damage reduction, minimum damage is 1 -- attacks always deal at least 1 damage
- **Offline counter-attack**: Offline/destroyed structs cannot counter-attack
- **Multi-commit prevention**: Each struct can only commit once per attack action (prevents double-commit on same target)
- **Target validation**: Target struct existence is validated before attack proceeds
- **Defense vs ore**: Defensive posture protects structs from being destroyed during raids, but does NOT prevent ore seizure. Defense saves your structures; only refining saves your ore.

---

## Struct Destruction

When a struct reaches 0 HP, it is **destroyed** and removed from the game. The specific instance cannot be restored. However, a new struct of the same type can be built to replace it (full build PoW required).

**Command Ship loss is especially costly.** Without an online Command Ship, the fleet cannot operate -- no planet building, no mining, no raiding. Rebuilding requires a full PoW cycle (~17 min at D=3). Assign defenders to your Command Ship via `struct-defense-set` before engaging in any offensive operations.

| Consequence | Detail |
|-------------|--------|
| Destroyed struct | Removed permanently; must build a replacement |
| Lost defenders | Each destroyed defender must be individually rebuilt |
| Command Ship destroyed | Fleet inoperable until replacement is built and online |
| Rebuild cost | Full PoW + power draw, same as original build |

---

## See Also

- [resources.md](resources.md) — Ore vs Alpha Matter security
- [power.md](power.md) — Power requirements for combat
- [fleet.md](fleet.md) — Fleet status for raids
- `schemas/formulas.md` — Verified formula definitions
- `reference/action-quick-reference.md` — Combat action endpoints
- `protocols/action-protocol.md` — Transaction flow
