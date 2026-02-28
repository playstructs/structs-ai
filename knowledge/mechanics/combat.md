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

## Ambit Targeting

Combat in Structs revolves around four ambits. Each struct operates in one ambit, and each weapon can only target specific ambits. This creates a strategic mesh where fleet composition and positioning determine what you can hit and what can hit you.

| Ambit | Bit Value |
|-------|-----------|
| Water | 2 |
| Land | 4 |
| Air | 8 |
| Space | 16 |

### Weapon Target Matrix

Which ambits each struct's primary weapon can hit:

| Struct | Lives In | Targets (Primary) | Targets (Secondary) |
|--------|----------|--------------------|---------------------|
| Command Ship | Any (movable) | Current ambit only | — |
| Battleship | Space | Space, Land, Water | — |
| Starfighter | Space | Space | Space |
| Frigate | Space | Space, Air | — |
| Pursuit Fighter | Air | Air | — |
| Stealth Bomber | Air | Land, Water | — |
| High Altitude Interceptor | Air | Space, Air | — |
| Mobile Artillery | Land | Land, Water | — |
| Tank | Land | Land | — |
| SAM Launcher | Land | Space, Air | — |
| Cruiser | Water | Land, Water | Air |
| Destroyer | Water | Air, Water | — |
| Submersible | Water | Space, Water | — |

### Threatened-By Matrix

Which structs can attack into each ambit:

| Target Ambit | Threatened By |
|--------------|---------------|
| Space | Battleship, Starfighter, Frigate, High Altitude Interceptor, SAM Launcher, Submersible |
| Air | Frigate, Pursuit Fighter, High Altitude Interceptor, SAM Launcher, Cruiser (secondary), Destroyer |
| Land | Battleship, Stealth Bomber, Mobile Artillery, Tank, Cruiser |
| Water | Battleship, Stealth Bomber, Mobile Artillery, Cruiser, Destroyer, Submersible |

The Command Ship can attack into any ambit but must first move there (see below).

### Command Ship Ambit Mobility

The Command Ship is the **only struct that can change ambits**. All other structs are fixed in their operating ambit.

- **Offensive use**: Move the Command Ship to the target's ambit before attacking. It can only hit structs in its current ambit.
- **Defensive use**: If the enemy fleet can only target water, moving the Command Ship out of water protects it from direct attack.
- **CLI**: `structsd tx structs struct-move [cmd-ship-id] [new-ambit] [new-slot] [new-location] --from [key] --gas auto --gas-adjustment 1.5 -y`

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
if defender exists and defender.operatingAmbit == target.operatingAmbit then
  if weapon.blockable and defender.ReadinessCheck() then
    canBlock = IsSuccessful(defender.blockingSuccessRate)
```

**Requirements** (all must be true):
1. Weapon must be blockable (`GetWeaponBlockable` returns true)
2. Defender must pass ReadinessCheck — struct online AND owner online
3. Defender must be in the **same ambit as the target being defended** (not the attacker)

A struct cannot block for a friendly in a different ambit. Blocking is strictly same-ambit defense.

### Counter-Attack

Counter-attacks are **ambit-independent from the defended target**. A space-based defender can counter-attack a space-based attacker even while defending a land-based struct.

| Scenario | Damage |
|----------|--------|
| Same ambit as attacker | `counterAttackDamage` (full) |
| Different ambit from attacker | `counterAttackDamage / 2` |

**Requirements** (all must be true):
1. Weapon must be counterable (`GetWeaponCounterable` returns true)
2. Neither counter-attacker nor attacker is destroyed
3. Defender's weapons must be able to target the **attacker's ambit** (via `CanCounterTargetAmbit`)
4. Location reachability to the attacker:
   - If defender on planet: attacker's fleet must be at that planet
   - If defender on fleet on-station: attacker must be reachable at the planet
   - If defender on fleet away: attacker must be on same planet or adjacent in location list

Defensive counter-attack is **in addition to** the normal counter-attack most fleet structs have. Most structs will deal at least 1 damage in return to an attacker if their weapons can reach the attacker's ambit.

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
- **Blocking**: Defender must be in the same ambit as the **target being defended** to block. Counter-attacks are separate -- they require the defender's weapons to reach the attacker's ambit.
- **Minimum damage**: After damage reduction, minimum damage is 1 -- attacks always deal at least 1 damage
- **Offline counter-attack**: Offline/destroyed structs cannot counter-attack
- **Multi-commit prevention**: Each struct can only commit once per attack action (prevents double-commit on same target)
- **Target validation**: Target struct existence is validated before attack proceeds
- **Defense vs ore**: Defensive posture protects structs from being destroyed during raids, but does NOT prevent ore seizure. Defense saves your structures; only refining saves your ore.

---

## Struct Destruction

When a struct reaches 0 HP, it is **destroyed** and removed from the game. The destroyed instance is gone forever and **cannot be repaired**. However, you **can build a new struct** of the same type as a replacement — full build PoW required.

**Command Ship loss is especially costly.** The destroyed Command Ship cannot be repaired, but you **can build a new Command Ship** (type 1) to replace it. Until the replacement is online, the fleet cannot move, raid, or build in space. Rebuilding requires a full PoW cycle (~17 min at D=3). Assign defenders to your Command Ship via `struct-defense-set` before engaging in any offensive operations.

| Consequence | Detail |
|-------------|--------|
| Destroyed struct | Instance gone forever; build a replacement (full PoW) |
| Lost defenders | Each destroyed defender must be individually rebuilt |
| Command Ship destroyed | Fleet inoperable until a **new** Command Ship is built and online |
| Rebuild cost | Full PoW + power draw, same as original build |

---

## See Also

- [resources.md](resources.md) — Ore vs Alpha Matter security
- [power.md](power.md) — Power requirements for combat
- [fleet.md](fleet.md) — Fleet status for raids
- `schemas/formulas.md` — Verified formula definitions
- `reference/action-quick-reference.md` — Combat action endpoints
- `protocols/action-protocol.md` — Transaction flow
