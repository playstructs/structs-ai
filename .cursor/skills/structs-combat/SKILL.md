---
name: structs-combat
description: Combat and raiding in Structs — raids (the way to steal ore), direct struct attacks, and defense. Use when raiding a planet for ore, deciding whether a target is worth raiding, attacking enemy structs, defending your planet, or preparing for an incoming attack. The rule that governs everything: a planet is only raidable while its shields are vulnerable — the defender's fleet is off-station, or their Command Ship is offline/destroyed.
level: core
domain: combat
---

# Structs Combat

Combat exists to move ore. **Raiding** is how you take another player's mined ore; **attacks** soften defenses and kill structs; **defense** keeps your own ore and infrastructure alive. The single most important fact: **a planet can only be raided to completion while its shields are vulnerable** — the defender's **fleet is off-station**, or their **Command Ship is offline, destroyed, or non-existent**. Keep your fleet on station with the Command Ship online and you are effectively unraidable; to raid someone, you must catch them vulnerable. (The Command Ship only defends home while the fleet is on station, so sending your fleet away to raid exposes your own planet until it returns.)

Conventions (TX_FLAGS, `--` rule, `-D 3` PoW, the per-player charge bar, one-tx-at-a-time) come from [`conventions.md`](https://structs.ai/skills/conventions).

## When to use it

- You spotted a target with stored ore and want to raid it.
- You're under attack or expect to be (a refine window, a hostile fleet nearby).
- You need to kill a specific enemy struct (a generator, a defender, a Tank).
- You're setting up standing defense for your planet.

## Decisions

### Raid go/no-go (the most important decision)

A raid is only worth launching when **all** of these hold. Use `scripts/scout.sh [planet-id]` to get this as a structured go/no-go, or check manually:

1. **Defender's shields are vulnerable** — their fleet is off-station, or their Command Ship is offline / destroyed / absent. If their fleet is on station with the Command Ship online, the planet's shields are up and `planet-raid-complete` is rejected (`shields_active`) no matter how long you grind. This is the gate.
2. **There is ore to take** — defender's `storedOre > 0` (ideally a lot; a successful raid seizes **all** of it, not a share).
3. **The shield is low enough** that the raid PoW is feasible in the time you have (shield raises raid difficulty; base 25, +contributions of online defense structs).
4. **The defender's fleet is away / weak** so your fleet survives the resolution.

**When NOT to raid**: defender CMD ship online; little/no stored ore; a shield so high the PoW outlasts your window; or the target's guild will retaliate as a bloc for less ore than you'd lose. Raiding is an *expedition* — it costs you a fleet locked `away` and your home undefended by fleet. Expected ore must beat that cost.

### Defense doctrine

- **Keep your Command Ship online and your fleet on station — always.** That combination makes you unraidable. Most "I got raided" stories are "my CMD ship went offline (usually power) and I didn't notice" — or "I sent my fleet off to raid and left my own shields down." Watch for it (`scripts/watch-defense.mjs` alerts on your CMD ship dropping and on raids against you). Treat raiding with your own fleet as a deliberate trade: while it's away, your home is exposed.
- **Stack shields.** Orbital Shield Generator and Ore Bunker are unlimited — build several to push raid difficulty up as a second layer behind the CMD-ship gate.
- **Refine fast.** Defense protects *structs*, never *ore*. The only defense for ore is turning it into Alpha Matter ([`structs-production`](https://structs.ai/skills/structs-production/SKILL)).
- **Assign defenders** across ambits to protect the Command Ship and key structs.

Decisions live in [`playbooks/situations/under-attack`](https://structs.ai/playbooks/situations/under-attack), [`guild-war`](https://structs.ai/playbooks/situations/guild-war), and [`playbooks/meta/counter-strategies`](https://structs.ai/playbooks/meta/counter-strategies).

## How a raid resolves

`blockStartRaid` is the **defender's vulnerability clock**, and raid PoW age is measured from it:

- It starts when the defender's shields become vulnerable — their Command Ship goes offline or their fleet leaves station (or when you arrive to find it already vulnerable).
- It resets to 0 if the defender restores their shields (Command Ship back online with the fleet on station) — and completion is rejected (`raid_clock_unset` when 0; the raid status flips to `ongoing` with shields restored).
- Raid statuses you'll see: `initiated` → `shieldsVulnerable` (shields down, clock running, winnable) → `raidSuccessful` / `attackerRetreated`. `attackerDefeated` means your raiding Command Ship was destroyed while away. `demilitarized` means no defenders to resolve against.

So a raid is a race against the defender noticing and restoring their shields. Scout the CMD ship and fleet position first; don't move your fleet until they're vulnerable.

**A raid steals ore.** A successful raid seizes **all** of the defender's `storedOre` and nothing more — it does not destroy the player or their structs. Killing the defender's Command Ship opens the `shieldsVulnerable` window so the raid can complete; if the defender restores or rebuilds it before you finish, completion is rejected (`shields_active`) and you get **nothing**. Beware the reverse: `trigger_raid_defeat_by_destruction` is on the Command Ship, so if **your** raiding CMD ship is destroyed while away, your fleet is defeated (`attackerDefeated`) and sent home. Win path for ore: strip same-ambit blockers → destroy the defender's CMD ship → complete the raid before they rebuild it (most reliable vs an offline defender).

## Procedure — raid

1. **Scout** — `scripts/scout.sh [planet-id]` (or `structsd query structs planet [id]` + struct/player queries). Confirm the four go conditions above, especially the defender's **Command Ship status**.
2. **Optional stealth** — stealth a unit before approach (`struct-stealth-activate`, 2 charge); attacking later auto-drops it.
3. **Move fleet to the target** (instant). Your fleet (and your Command Ship) is now `away`; you can't build/mine at home while away, **and your own planet's shields are now vulnerable** until the fleet returns — refine your home ore before you leave.
   ```
   structsd tx structs fleet-move TX_FLAGS -- [fleet-id] [destination-location-id]
   ```
4. **Approval Block** — fleet is your raider and now at the target; defender's CMD ship is down (verified); your home ore is refined or below your theft tolerance; you accept an auto-submitted completion landing minutes-to-hours out.
5. **Raid compute** (expedition, auto-submits completion — the documented `-y` exception):
   ```bash
   nohup structsd tx structs planet-raid-compute -D 3 --from [key] --gas auto --gas-adjustment 1.5 -y -- [fleet-id] \
     > memory/jobs/raid-[fleet-id].log 2>&1 & echo $! > memory/jobs/raid-[fleet-id].pid
   ```
6. **Move fleet home and refine the stolen ore immediately** — it's stealable in *your* hands now too.

If the defender restores their Command Ship mid-raid, the clock resets — withdraw or wait for it to drop again.

## Procedure — direct attack

Scout the target's ambit and defense type, position (Command Ship only) into range, then fire. The attack needs only the attacking struct and its owner online — your Command Ship does not need to be online to attack, change defenders, or change stealth. The **target must be a built struct**: a struct that is still building cannot be attacked (`unbuilt`), and a destroyed one is rejected (`destroyed`); the target's online status is irrelevant. The CLI prompts; verify target IDs and that you aren't crossing guild lines you didn't intend to (attacking another guild's structs is a Tier 2 act of war). Note most weapons are single-target (`primaryWeaponTargets = 1`) — the comma list only spreads damage for weapons whose target count is > 1.

```
structsd tx structs struct-attack TX_FLAGS -- [operating-struct-id] [target-id,target-id2,...] [weapon-system]
```

Attacks cost 3-5 charge from your **per-player** bar; space repeated attacks accordingly.

## Procedure — defense setup

```
structsd tx structs struct-defense-set TX_FLAGS -- [defender-struct-id] [protected-struct-id]
structsd tx structs struct-defense-clear TX_FLAGS -- [defender-struct-id]
```

**Any** struct can be assigned as a defender (1 charge each; stagger ~6 s on one key) as long as it is **built, online, and co-located** with the protected struct — ambit is **not** required to *assign*. Ambit decides what the defender can do: **same-ambit** is required only to **block** (intercept a hit), while a **cross-ambit** defender still **counters** whenever its weapon can reach the attacker. Spread defenders across ambits for counter coverage; keep same-ambit defenders where you need real interception. Minimum viable defense: at least one combat struct per ambit guarding the Command Ship (6 HP; most fleet structs are 3 HP).

## Tactical reference

### Targeting (which struct hits which ambit)

| Struct | Lives In | Primary | Secondary |
|--------|----------|---------|-----------|
| Command Ship | Any (movable) | current ambit only | — |
| Battleship | Space | Land, Water (**armour-piercing**) | Space |
| Starfighter | Space | Space | Space (Attack Run, ≥1 hit) |
| Frigate | Space | Space, Air | — |
| Pursuit Fighter | Air | Air | — |
| Stealth Bomber | Air | Land, Water | — |
| High Alt Interceptor | Air | Space, Air | — |
| Mobile Artillery | Land | Land, Water | — |
| Tank | Land | Land | — |
| SAM Launcher | Land | Space, Air | — |
| Cruiser | Water | Land, Water | Air |
| Destroyer | Water | Air, Water | — |
| Submersible | Water | Space, Water | — |

The Command Ship is the only struct that can change ambits (`struct-move`); it attacks only its current ambit. Reposition it into range to attack, or out of range to hide.

### Weapon control vs defense (evasion + armour-piercing)

| Target Defense | vs Guided | vs Unguided |
|----------------|-----------|-------------|
| Signal Jamming (Battleship, Pursuit Fighter, Cruiser) | **66% miss** | full hit |
| Defensive Maneuver (High Alt Interceptor) | full hit | **66% miss** |
| Armour (Tank, Field Generator, Continental Power Plant, World Engine) | full hit, −1 dmg | full hit, −1 dmg |
| Stealth Mode (Stealth Bomber, Submersible) | same-ambit only | same-ambit only |
| Indirect Combat (Mobile Artillery) | full hit | full hit |
| None | full hit | full hit |

Use unguided vs Signal Jamming, guided vs Defensive Maneuver. **Armour reduces damage by 1 — except against armour-piercing weapons (the Battleship primary), which ignore it.** The Battleship is the dedicated answer to Tanks and to the (now armoured) power generators. Minimum damage after reduction is always 1.

### Combat resolution notes

- **Counters are ambit-gated, blocks are ambit-matched.** A defender counters whenever its weapon can reach the **attacker's** ambit (regardless of what it's defending); it can only **block** when it shares the **target's** ambit. Consequence: attacking land structs from air/water/space (an ambit the defenders can't reach) takes **zero counter damage** — the single biggest combat lever. Pick your attacking ambit to dodge counters.
- Each struct counters at most **once per `struct-attack` invocation** (not per target/shot). Defender counter fires before block and even on evaded shots; target counter fires after all shots (destroyed targets can't counter).
- Block only fires on non-evaded shots and only from a defender in the **target's** ambit.
- **Counters are a backstop, not a damage plan** — counter values are small (typically 1; Command Ship 2) and a cross-ambit attacker takes none at all. Win with active `struct-attack` volleys from a safe ambit, not by baiting counters.
- **Single-target**: every weapon has `primaryWeaponTargets = 1` (one struct per volley) — no multi-target weapon exists. The comma-list in `struct-attack` doesn't make a single-target weapon spread.
- **No charge banking**: any action resets your shared charge bar to 0 and it refills ~1/block — you cannot stockpile for a multi-attack burst. Plan combat as spaced single actions. Because the bar is **per-player**, the way to land many hits at once is **parallel**: coordinate multiple accounts to focus-fire one target — N players land N attacks per charge cycle. See [team-operations](https://structs.ai/playbooks/meta/team-operations).
- **Planetary defenses (attacking a planet)**: the **Jamming Satellite** runs a low-orbit ballistic interceptor network that can **evade your air/space attacks against the planet's land/water structs** (`evadedByPlanetaryDefenses`) — hit those land/water structs from land/water instead, or expect 0s from the air/space. Guided weapons that miss come from the target's unit-level `signalJamming`, not the satellite. The PDC and the interceptor network are the planetary defenses that affect combat.
- PDC auto-fires after all targets resolve (it does not counter); multiple players' PDCs stack.
- A successful raid seizes **all** of the defender's `storedOre` and nothing else — there is no player-elimination outcome (see raid section). Destroyed structs are gone forever but can be rebuilt (full PoW). Losing your Command Ship disables the whole fleet until you build a new one — protect it above all, and never let your raiding CMD ship die while away (`attackerDefeated`).

## Commands reference

| Action | CLI Command |
|--------|-------------|
| Attack | `structsd tx structs struct-attack TX_FLAGS -- [struct-id] [target-ids] [weapon-system]` |
| Raid compute (PoW + auto-complete) | `structsd tx structs planet-raid-compute -D 3 TX_FLAGS_APPROVED -- [fleet-id]` |
| Raid complete (manual, rare) | `structsd tx structs planet-raid-complete TX_FLAGS -- [fleet-id]` |
| Fleet move | `structsd tx structs fleet-move TX_FLAGS -- [fleet-id] [destination-location-id]` |
| Defense set / clear | `structsd tx structs struct-defense-set \| struct-defense-clear TX_FLAGS -- [defender-id] [protected-id]` |
| Stealth on / off | `structsd tx structs struct-stealth-activate \| struct-stealth-deactivate TX_FLAGS -- [struct-id]` |
| Move Command Ship (ambit) | `structsd tx structs struct-move TX_FLAGS -- [cmd-ship-id] [ambit] [slot] [location]` |

Raid flow: scout → (CMD ship down?) → fleet-move → raid-compute → fleet-move home → refine. `planet-raid-compute` is the documented `-y` exception; your Approval Block is the gate. `planet-raid-complete` does not consume charge.

**Requires**: [`structsd`](https://structs.ai/skills/structsd-install/SKILL) on PATH and a signing key.

## Verification

- `structsd query structs fleet [id]` — location and `onStation`/`away`.
- After a raid: `planet_raid` `seized_ore` shows what you took; your `storedOre` rose (refine it).
- After attacks: events include remaining-health values — use them to assess damage.
- Broadcast ≠ success: a raid can land but resolve as `defeat`/`ongoing`. Query the raid status.

## Errors

- **"shields_active" / raid rejected** — the defender's shields are up (fleet on station with the Command Ship online). You cannot win until they're vulnerable again. Stop grinding.
- **"raid_clock_unset"** — `blockStartRaid` is 0 (the defender is not currently vulnerable). Wait for their CMD ship to drop or their fleet to leave station.
- **"unbuilt" / "destroyed" (attack)** — the target struct isn't a valid combat target: it's still building or already destroyed. Pick a built target.
- **"unreachable" / "out_of_range"** — your weapon can't reach that ambit; reposition the Command Ship or use a different struct.
- **"fleet not away"** — move the fleet to the target first.
- **"insufficient charge"** — per-player bar too low; wait (see conventions).
- **Stolen-from** — your CMD ship went offline mid-window. Restore it; refine ore faster next time.

## See also

- [knowledge/mechanics/combat](https://structs.ai/knowledge/mechanics/combat) — damage, evasion, raid phases, SHIELDS_VULNERABLE
- [knowledge/mechanics/fleet](https://structs.ai/knowledge/mechanics/fleet) — fleet status, raid window
- [playbooks/situations/under-attack](https://structs.ai/playbooks/situations/under-attack) / [guild-war](https://structs.ai/playbooks/situations/guild-war) / [counter-strategies](https://structs.ai/playbooks/meta/counter-strategies)
- [structs-intel](https://structs.ai/skills/structs-intel/SKILL) — scouting + raid-worthiness scoring; [structs-production](https://structs.ai/skills/structs-production/SKILL) — refine to protect ore
