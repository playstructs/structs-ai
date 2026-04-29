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
| Command Ship | Any (movable) | Local only (flag 32 = current ambit) | — |
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
| weaponShots | Number of shots per attack (`primaryWeaponShots` / `secondaryWeaponShots`) |
| weaponShotSuccessRate | Per-shot success (Numerator/Denominator) |
| weaponGuaranteedShots | Minimum number of shots that hit before the success rate roll applies (`primaryWeaponGuaranteedShots` / `secondaryWeaponGuaranteedShots`, added in v0.16.0) |
| weaponDamage | Damage per successful shot |
| damageReduction | Defense reduction |
| health | Target current health |

**Algorithm**: For shot index `i` in `0..weaponShots`, the shot hits if `i < weaponGuaranteedShots` OR `IsSuccessful(weaponShotSuccessRate)`. The first `weaponGuaranteedShots` shots are auto-hits; only the remaining shots roll against the success rate. Sum the damage from successful shots, apply `damageReduction`. Minimum damage after reduction is 1. Cap at target health.

**Why guaranteed shots exist**: A weapon with `shots=3` and `successRate=1/3` has the same expected value as a single guaranteed hit, but its variance is much higher — most attacks would deal zero damage. Setting `guaranteedShots=1` floors the damage at one hit per volley while preserving the upside of the other rolls. This was the v0.16.0 fix for the Starfighter's Attack Run feeling unreliable. The chain currently uses guaranteed shots only on Starfighter Attack Run (secondary weapon, `secondaryWeaponGuaranteedShots = 1`); other weapons leave the field at 0, which means "no guarantee, all shots roll".

**Attack results**: Attack events include health results (remaining health after attack) in addition to damage amounts.

### Evasion

```
if weaponControl == guided then successRate = guidedDefensiveSuccessRate
else successRate = unguidedDefensiveSuccessRate
canEvade = IsSuccessful(successRate) if successRate.Numerator != 0
```

### Weapon Control vs Defense Type

The interaction between a weapon's control type (guided/unguided) and the target's defense type is the core of combat tactics. This matrix determines whether shots can be evaded:

| Target Defense | vs Guided | vs Unguided |
|----------------|-----------|-------------|
| Signal Jamming (Battleship, Pursuit Fighter, Cruiser) | **66% miss** | Full hit |
| Defensive Maneuver (High Alt Interceptor) | Full hit | **66% miss** |
| Armour (Tank) | Full hit, -1 damage | Full hit, -1 damage |
| Stealth Mode (Stealth Bomber, Submersible) | Same-ambit only | Same-ambit only |
| Indirect Combat Module (Mobile Artillery) | Full hit | Full hit |
| None | Full hit | Full hit |

**Tactical takeaways**: Use unguided weapons against Signal Jamming targets (Battleship, Pursuit Fighter, Cruiser). Use guided weapons against Defensive Maneuver targets (High Alt Interceptor). Armour always reduces damage by 1 regardless of weapon control.

### Stealth

Stealthed structs (Stealth Bomber, Submersible) are **not invisible** -- they can still be targeted by structs in the **same ambit**. Stealth blocks cross-ambit targeting only. A stealthed Submersible (water) can be attacked by other water structs, but air/land/space structs cannot target it.

- **Attacking breaks stealth**: When a stealthed struct attacks, its stealth is **instantly deactivated** (firing reveals position).
- **Re-activation**: Stealth must be manually re-activated after deactivation. Costs 1 charge.
- **Activation**: `struct-stealth-activate [struct-id]` (1 charge). Deactivation: `struct-stealth-deactivate [struct-id]`.

### Recoil Damage

Attacker takes damage after firing: `health = health - weaponRecoilDamage`. Recoil only applies if the attacker survives the entire shot sequence (including counter-attacks).

### Post-Destruction Damage

If `health == 0` and `postDestructionDamage > 0`, damage applies to surrounding structs.

### Blocking

```
if !evaded and defender exists and defender.operatingAmbit == target.operatingAmbit then
  if weapon.blockable and defender.ReadinessCheck() then
    canBlock = IsSuccessful(defender.blockingSuccessRate)
```

**Requirements** (all must be true):
1. The shot was NOT evaded -- block does not fire on evaded shots
2. Weapon must be blockable (`GetWeaponBlockable` returns true)
3. Defender must pass ReadinessCheck -- struct online AND owner online
4. Defender must be in the **same ambit as the target being defended** (not the attacker)

A struct cannot block for a friendly in a different ambit. Blocking is strictly same-ambit defense. Unlike counter-attacks, block is attempted on every shot (not limited to once per attack).

### Counter-Attack

Each struct can counter-attack **at most once per `struct-attack` invocation**. Counter-spent state is tracked per struct per attack command (not per target, not per shot). For a 3-shot Attack Run: the defender counters on the first shot only, but can attempt to block all 3 shots. The target counters once after all shots resolve.

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

**Two types of counter-attack**:
- **Defender counter-attack**: Fires before the block attempt, once per `struct-attack` invocation. Fires even on evaded shots.
- **Target counter-attack**: Fires after all shots resolve damage against the target, once per `struct-attack` invocation. Destroyed targets cannot counter.

Both the defender and the target can counter-attack -- an attacker may take damage from two sources per target.

### Planetary Defense Cannon

```
damage = planetaryShieldBase + sum(defenseCannon.damage for each cannon on planet)
```

- **Limit**: 1 Planetary Defense Cannon per player
- PDC fires automatically **after all targets are resolved**, not as a counter-attack
- PDC does NOT counter-attack -- it only auto-fires at the end of the attack sequence
- Multiple players' PDCs on the same planet stack correctly

---

## Attack Resolution Sequence

When `struct-attack` is executed, the following steps occur in order per target:

1. **Validation** -- Verify weapon ambits can reach target ambit. Stealthed targets are only targetable from the same ambit. Verify target struct exists.
2. **Stealth break** -- If the attacker has stealth active, it is instantly deactivated (attacking reveals position).
3. **Evasion check** (per-target, not per-shot) -- Evaluate weapon control (guided/unguided) vs target defense type. If evaded, ALL shots against this target miss but counters still fire.
4. **Per-shot loop** (inside `ResolveDefenders`) -- For each projectile:
   - **Defender counter-attack** (once per `struct-attack` invocation) -- fires regardless of evasion. Only on the first shot where the defender hasn't already countered.
   - **Block attempt** (only if NOT evaded) -- weapon must be blockable, defender must be in the same ambit as the target.
   - **Damage** (only if NOT evaded) -- per-shot success rate applied, damage reduction from armor. Minimum damage after reduction is 1.
5. **Target counter-attack** (once per `struct-attack` invocation) -- fires after all shots resolve. Destroyed targets cannot counter.
6. **Early termination** -- If the attacker is destroyed mid-sequence, remaining targets do not process.

After **all targets** are resolved:

7. **Recoil damage** -- Applied to attacker if it survived all shots
8. **Planetary Defense Cannon auto-fire** -- If any target was a planetary struct, PDCs fire against the attacker

### Per-Projectile Events

Each projectile gets its own `EventAttackShotDetail` row. For a 3-shot Attack Run, the attack event contains 3 separate shot detail entries with per-projectile hit/miss breakdowns. `targetPlayerId` is on `EventAttackShotDetail` (not `EventAttackDetail`).

**Key implications**:
- Evasion is per-target (entire volley evaded), while shot accuracy is per-projectile
- Both the **defender** and the **target** can counter-attack -- an attacker may take damage from two sources per target
- Each struct counters at most once per `struct-attack` invocation, regardless of how many shots or targets
- Counter-attacks fire even on evaded shots (defender counter) -- only block is suppressed by evasion
- If the attacker is destroyed during the target loop, remaining targets do not process
- PDC fires against any attacker of planetary structs, not only during raids

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

- **Raid loot**: Only the player's mined ore (`storedOre`) can be stolen -- not unmined ore on the planet (`remainingOre`). Alpha Matter is secure. A successful raid seizes **all** of the target player's `storedOre`, not a partial amount. One raid = total loss.
- **Success rate**: `IsSuccessful` uses `hash(blockHash, playerNonce) % Denominator < Numerator`
- **Damage overflow**: Post-destruction damage carries over to adjacent structs
- **Blocking**: Defender must be in the same ambit as the **target being defended** to block. Block does NOT fire on evaded shots. Counter-attacks are separate -- they require the defender's weapons to reach the attacker's ambit.
- **Minimum damage**: After damage reduction, minimum damage is 1 -- attacks always deal at least 1 damage
- **Offline counter-attack**: Offline/destroyed structs cannot counter-attack
- **Counter-attack limit**: Each struct can counter-attack at most once per `struct-attack` invocation. For multi-shot weapons (Attack Run with 3 projectiles), the defender counters on the first shot only but can attempt to block all 3 shots. The target counters once after all shots.
- **Counter on evaded shots**: Defender counter-attacks fire even when the shot is evaded. Only the block attempt is suppressed by evasion.
- **EvadedCause**: Only set on successful evasion. Not populated on failed evasion attempts.
- **Target validation**: Target struct existence is validated before attack proceeds
- **Defense vs ore**: Defensive posture protects structs from being destroyed during raids, but does NOT prevent ore seizure. Defense saves your structures; only refining saves your ore.
- **PDC stacking**: Multiple players' Planetary Defense Cannons on the same planet stack correctly.

---

## Struct Destruction

When a struct reaches 0 HP, it is **destroyed** and removed from the game. The destroyed instance is gone forever and **cannot be repaired**. However, you **can build a new struct** of the same type as a replacement — full build PoW required.

| Consequence | Detail |
|-------------|--------|
| Destroyed struct | Instance gone forever; build a replacement (full PoW) |
| Lost defenders | Each destroyed defender must be individually rebuilt |
| Rebuild cost | Full PoW + power draw, same as original build |

### FAQ: Can I rebuild a destroyed Command Ship?

**YES.** A destroyed Command Ship cannot be repaired, but you **can build a brand new Command Ship** (type 1) to replace it. The new Command Ship gets a new struct ID and requires full build PoW (~17 min at D=3). You choose the starting ambit at build time.

Until the replacement is online, the fleet **cannot move, raid, or build in space**. This downtime is the real cost of losing a Command Ship. Always assign defenders to protect it via `struct-defense-set` before engaging in offensive operations.

---

## See Also

- [resources.md](resources.md) — Ore vs Alpha Matter security
- [power.md](power.md) — Power requirements for combat
- [fleet.md](fleet.md) — Fleet status for raids
- `schemas/formulas.md` — Verified formula definitions
- `reference/action-quick-reference.md` — Combat action endpoints
- `protocols/action-protocol.md` — Transaction flow
