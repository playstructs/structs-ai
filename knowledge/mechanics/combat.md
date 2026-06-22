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
| Battleship | Space | Land, Water (armour-piercing) | Space |
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
| Space | Battleship (secondary), Starfighter, Frigate, High Altitude Interceptor, SAM Launcher, Submersible |
| Air | Frigate, Pursuit Fighter, High Altitude Interceptor, SAM Launcher, Cruiser (secondary), Destroyer |
| Land | Battleship, Stealth Bomber, Mobile Artillery, Tank, Cruiser |
| Water | Battleship, Stealth Bomber, Mobile Artillery, Cruiser, Destroyer, Submersible |

The Command Ship can attack into any ambit but must first move there (see below). The Battleship's armour-piercing primary covers Land and Water; its guided secondary reaches Space.

### Targets per attack

`struct-attack` accepts a **comma-separated list of target IDs**, but how many of those targets a weapon engages is governed by that weapon's `primaryWeaponTargets` / `secondaryWeaponTargets` value.

- **Every weapon is single-target** — `primaryWeaponTargets = 1` on all fleet hulls, and `secondaryWeaponTargets = 1` on the three hulls with a secondary (Battleship, Starfighter, Cruiser). Listing extra IDs does not let a `targets = 1` weapon spread its volley across them.
- This is distinct from **multi-shot** (`primaryWeaponShots`), which is how many projectiles a weapon fires *at a single target* (e.g. Starfighter Attack Run = 3 shots, 1 target).

### Command Ship Ambit Mobility

The Command Ship is the **only struct that can change ambits** (`movable=true`). All other structs are fixed in their operating ambit, and the chain rejects `struct-move` on a non-movable struct — only the Command Ship can be moved.

- **Offensive use**: Move the Command Ship to the target's ambit before attacking. It can only hit structs in its current ambit.
- **Defensive use**: If the enemy fleet can only target water, moving the Command Ship out of water protects it from direct attack.
- **CLI**: `structsd tx structs struct-move [cmd-ship-id] [new-ambit] [new-slot] [new-location] --from [key] --gas auto --gas-adjustment 1.5 -y`

---

## Health Points

Each struct has a Max HP that determines how much damage it can absorb before destruction.

| Struct | Max HP |
|--------|--------|
| Command Ship | 6 |
| Other fleet structs (IDs 2-13) | 3 |
| Baseline planetary structs (Ore Extractor, Ore Refinery, Orbital Shield Generator, Jamming Satellite, Ore Bunker, PDC) | 6 |
| Field Generator | 8 |
| Continental Power Plant | 10 |
| World Engine | 10 |

Planetary structs are hardened so a raider cannot casually demolish a planet's infrastructure; the power generators are the toughest (and carry `armour`, damage reduction 1), making a power kill a deliberate objective. Armour-piercing weapons (Battleship primary) bypass that reduction.

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
| weaponGuaranteedShots | Minimum number of shots that hit before the success rate roll applies (`primaryWeaponGuaranteedShots` / `secondaryWeaponGuaranteedShots`) |
| weaponDamage | Damage per successful shot |
| damageReduction | Defense reduction (target's `attackReduction`, e.g. Tank/generator armour = 1); **negated when the weapon is armour-piercing** |
| armourPiercing | If the weapon is armour-piercing (`primaryWeaponArmourPiercing` / `secondaryWeaponArmourPiercing`), the target's `damageReduction` is treated as 0 |
| health | Target current health |

**Algorithm**: For shot index `i` in `0..weaponShots`, the shot hits if `i < weaponGuaranteedShots` OR `IsSuccessful(weaponShotSuccessRate)`. The first `weaponGuaranteedShots` shots are auto-hits; only the remaining shots roll against the success rate. Sum the damage from successful shots, then apply `damageReduction` (unless the weapon is armour-piercing, in which case reduction is skipped). Minimum damage after reduction is 1. Cap at target health.

**Armour-piercing**: A weapon flagged armour-piercing negates the target's damage reduction during volley resolution. The Battleship's primary is armour-piercing — it deals full damage to Tanks and to power generators (which otherwise reduce incoming damage by 1). Each shot's piercing is reported on `EventAttackShotDetail.armourPiercing`.

**Why guaranteed shots exist**: A weapon with `shots=3` and `successRate=1/3` has the same expected value as a single guaranteed hit, but its variance is much higher — most attacks would deal zero damage. Setting `guaranteedShots=1` floors the damage at one hit per volley while preserving the upside of the other rolls. Guaranteed shots apply only to the Starfighter Attack Run (secondary weapon, `secondaryWeaponGuaranteedShots = 1`); other weapons leave the field at 0, which means "no guarantee, all shots roll".

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
| Armour (Tank, Field Generator, Continental Power Plant, World Engine) | Full hit, -1 damage | Full hit, -1 damage |
| Stealth Mode (Stealth Bomber, Submersible) | Same-ambit only | Same-ambit only |
| Indirect Combat Module (Mobile Artillery) | Full hit | Full hit |
| None | Full hit | Full hit |

**Tactical takeaways**: Use unguided weapons against Signal Jamming targets (Battleship, Pursuit Fighter, Cruiser). Use guided weapons against Defensive Maneuver targets (High Alt Interceptor). Armour reduces damage by 1 regardless of weapon control — **except** against armour-piercing weapons (Battleship primary), which ignore it entirely. The Battleship is the dedicated answer to Tanks and to armoured power generators.

### Stealth

Stealthed structs (Stealth Bomber, Submersible) are **not invisible** -- they can still be targeted by structs in the **same ambit**. Stealth blocks cross-ambit targeting only. A stealthed Submersible (water) can be attacked by other water structs, but air/land/space structs cannot target it.

- **Attacking breaks stealth**: When a stealthed struct attacks, its stealth is **instantly deactivated** (firing reveals position).
- **Re-activation**: Stealth must be manually re-activated after deactivation. Costs 2 charge (from the player's shared charge bar).
- **Activation**: `struct-stealth-activate [struct-id]` (2 charge). Deactivation: `struct-stealth-deactivate [struct-id]`.

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

Counter-attacks are **ambit-independent from the defended target**. A space-based defender can counter-attack a space-based attacker even while defending a land-based struct. **Defenders do not take counter-attack damage** — only the original attacker and target can be damaged by counters.

**Range rule**: A struct on a fleet that is `away` from the home planet cannot defend planetary structs at that planet. Only on-station fleet structs and planet-based structs can defend their home planet.

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

### Other Planetary Defense Structs

Two planetary defenses are wired to structs and affect combat: the Planetary Defense Cannon and the **low-orbit ballistic interceptor network** (provided by the Jamming Satellite struct).

- **Low-orbit ballistic interceptor network (the Jamming Satellite, type 17)** — the Jamming Satellite carries `noUnitDefenses`; its planetary effect gives the planet a chance to **evade an incoming attack when the attacker is in air or space and the target struct is in land or water**. On a successful evade the shot is flagged `evadedByPlanetaryDefenses: true` with cause `lowOrbitBallisticInterceptorNetwork`, dealing 0 damage (for example, a Battleship's space secondary against a land or water struct). It has no effect against water- or land-based attackers. Each additional interceptor on the planet compounds the evade chance.
- **Guided weapons that miss repeatedly** are evading the **unit-level** `signalJamming` defense carried by the *target struct* (Battleship, Pursuit Fighter, Cruiser — 66% guided miss). This is a per-struct defense, not a planetary field. See [Weapon Control vs Defense Type](#weapon-control-vs-defense-type).

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
| Operating struct online, and its owner online | ✓ | — |
| Raider player online (sufficient power) | — | ✓ |
| Sufficient charge | ✓ | — |
| Target struct built (a struct cannot be attacked until it finishes building) | ✓ | — |
| Raider fleet away (at the target) | — | ✓ |
| **Defender's shields vulnerable** (defender's fleet off-station, or their Command Ship offline / destroyed / non-existent) | — | ✓ |
| Raid clock started (`blockStartRaid` != 0) | — | ✓ |
| Proof-of-work | — | ✓ |

An attack action depends only on the attacking struct (and its owner) being online — the attacker's Command Ship does not need to be online, and the same holds for defensive changes (`struct-defense-set`) and stealth changes. The target must be a built struct; `struct-attack` against a struct that is still building is rejected (`unbuilt`), and a destroyed struct is rejected (`destroyed`). The target's online status is irrelevant.

Note: `planet-raid-complete` does **not** consume charge (it is a proof-of-work message, not a charge message). Direct `struct-attack` does consume the player's charge.

---

## Raid Phases and SHIELDS_VULNERABLE

A raid is only winnable while the **defending planet's shields are vulnerable**. Shields are vulnerable whenever the defender's **fleet is off-station** (the Command Ship only defends the home planet while the fleet is on station), or the defender's **Command Ship is offline, destroyed, or non-existent**. While the defender's fleet is on station with a built, online Command Ship, the planet's shields are up and `planet-raid-complete` is rejected (`shields_active`) no matter how much work the raider does. The single most effective raid defense is therefore keeping your fleet on station with the Command Ship online — and note that sending your own fleet away to raid someone else leaves your planet's shields vulnerable until it returns.

The `blockStartRaid` attribute is the **vulnerability clock**, and raid PoW age is measured from it:

- Set when the planet becomes vulnerable (the defending Command Ship goes offline or the defender's fleet leaves station), or when raiders arrive to find it already vulnerable.
- Cleared (back to 0) when the planet stops being vulnerable (the Command Ship comes back online with the fleet on station), and when the raid ends. With the clock at 0, raid completion is rejected (`raid_clock_unset`).

So a raider must catch the defender vulnerable *and* let the clock age before the puzzle becomes solvable. If the defender restores their shields mid-raid (Command Ship back online with the fleet on station), the clock resets and the raider must wait for the planet to become vulnerable again.

### Raid statuses

| Status | Meaning |
|--------|---------|
| initiated | Raider fleet has arrived at the planet |
| shieldsVulnerable | Defender's shields are down (fleet off-station, or Command Ship offline/destroyed) — the raid is now winnable and the clock is running |
| ongoing | Defender restored shields mid-raid (Command Ship back online with the fleet on station) — completion blocked |
| raidSuccessful | Raider won and seized all of the defender's stored ore |
| attackerDefeated | Raider's own Command Ship was destroyed while away (`trigger_raid_defeat_by_destruction`) — the raiding fleet is defeated and sent home |
| attackerRetreated | Raider withdrew before completion |
| demilitarized | Planet has no defenders to resolve against (`fleet.PeaceDeal()`) |

Status values are the `RaidStatus_*` enum emitted on `EventRaid`. The most a defender loses to a raid is all of their stored ore (`raidSuccessful`).

**Raid status** also includes `seizedOre` -- the amount of ore stolen during the raid, tracked on the `planet_raid` record. See `schemas/entities/planet.md` for the `planet_raid` table schema.

### What a raid does

A successful `planet-raid-complete` seizes **all** of the defender's `storedOre`, sends the raider's fleet home, and emits `raidSuccessful`. Ore is the only thing a raid takes — a raid does not destroy the defending player or their structs.

Destroying the defender's Command Ship (or catching their fleet off-station) makes the planet's shields vulnerable (`shieldsVulnerable`), which is the condition that lets a raid complete. If the defender restores their shields before completion — Command Ship back online with the fleet on station — the shields return and `planet-raid-complete` is rejected with `shields_active`. So the planet is either vulnerable at completion — and the raider takes all the ore — or shielded, and the raid is rejected.

`trigger_raid_defeat_by_destruction` is a property of the Command Ship. When a Command Ship is destroyed while **away from home** (its planet's owner differs from its own owner), its fleet is defeated: the raid ends with `attackerDefeated` and the fleet is sent home. This defeats an **attacking** fleet whose Command Ship dies during a raid.

**Raid attack doctrine:**

1. Strip **same-ambit blockers** so your attacks reach the Command Ship (cross-ambit defenders counter but cannot block — see [Blocking](#blocking)).
2. Destroy the defender's **Command Ship** to open the `shieldsVulnerable` window.
3. Complete the **raid** while it is down to seize all stored ore.
4. Expect an online defender to rebuild the Command Ship — a destroyed Command Ship can be rebuilt (see [Struct Destruction](#struct-destruction)), which shuts the window. Raids are most reliable against an **offline** defender who cannot restore it.

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
- **No defender cap**: there is no per-ambit limit on how many structs can defend another — `defense-set` only checks co-location, and attack resolution iterates every registered defender. The planet's **slot** structure provides 4 slots per ambit, which caps how many structs can exist per ambit, not how many can defend.
- **No charge banking before an attack**: Charge cannot be stockpiled for an alpha-strike. Any charge-consuming action resets the player's shared bar to 0 and it only refills linearly (~1/block); you cannot "burst" multiple expensive attacks back-to-back. See [building.md — Charge Accumulation](building.md#charge-accumulation).

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
