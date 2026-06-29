# Glossary

**Purpose**: A lexical index for the whole corpus. Look a term up here when you know *what it's called* but not *which page explains it*. Each entry gives a one-line definition and a link to the canonical page that owns the detail. Where two similar terms are easy to confuse, a **Disambiguation** note separates them.

This page is a **finder, not a source of truth** — when a value or rule matters, follow the link and read the canonical page. Terms are alphabetical.

---

## Quick disambiguations (the traps)

These pairs cause the most integration and tactical errors:

- **Ambit enum (0–5) vs ambit reach bitmask (1/2/4/8/16/32)** — the message/`operatingAmbit` scale vs the `possibleAmbit`/weapon-reach scale. Conflating them throws `invalid int32`. See [Ambit enum](#ambit-enum) and [Ambit reach bitmask](#ambit-reach-bitmask).
- **Block vs counter** — block needs the defender in the *target's* ambit; counter needs the defender's weapon to reach the *attacker's* ambit. See [Block](#block) and [Counter-attack](#counter-attack).
- **Multi-shot vs multi-target** — multiple projectiles at one target vs hitting multiple targets. Every weapon is single-*target*. See [Multi-shot](#multi-shot) and [Multi-target](#multi-target).
- **`capacity_exceeded`: build-limit vs power** — one error string, two causes, told apart by the number magnitude. See [capacity_exceeded](#capacity_exceeded).
- **Charge as a threshold, not a balance** — actions need a minimum charge; they reset the bar to 0, they do not subtract. See [Charge](#charge).
- **`struct_attack` stub vs full detail** — large combat payloads stream without their shot detail. See [Stub](#stub).
- **Raid `attackerDefeated` vs defender loss** — `trigger_raid_defeat_by_destruction` defeats the *attacker*, not the defender. See [trigger_raid_defeat_by_destruction](#trigger_raid_defeat_by_destruction).

---

## A

### Alpha Matter
The refined, secure resource. Cannot be stolen by a raid (unlike ore). Produced by refining ore; used for builds, infusion, staking, and guild tokens. → [resources.md](../knowledge/mechanics/resources.md)

### Ambit
One of four combat layers — **Water, Land, Air, Space** — plus two special values (`none`, `local`). A struct operates in one ambit; weapons reach specific ambits. → [combat.md — Ambit Targeting](../knowledge/mechanics/combat.md#ambit-targeting)

### Ambit enum
The ambit numbering used by transaction messages and a struct's stored `operatingAmbit`: `none=0, water=1, land=2, air=3, space=4, local=5`. Pass this (or the CLI name `space|air|land|water`) when building or moving. → [building.md — Ambit Encoding](../knowledge/mechanics/building.md#ambit-encoding)

### Ambit reach bitmask
The ambit numbering used by `possibleAmbit` and weapon-reach fields, where `bit = 1 << enum`: `none=1, water=2, land=4, air=8, space=16, local=32`. Combined with OR (e.g. `6` = land+water). **Not** the enum. → [api/integration-notes.md — Ambit](../api/integration-notes.md#ambit-enum-vs-reach-bitmask)

### Armour
A unit defense (Tank, and the power generators) that reduces incoming damage by 1. Negated by armour-piercing weapons. → [combat.md — Weapon Control vs Defense Type](../knowledge/mechanics/combat.md#weapon-control-vs-defense-type)

### Armour-piercing
A weapon property (Battleship primary) that ignores the target's damage reduction. → [combat.md — Multi-Shot Damage](../knowledge/mechanics/combat.md#multi-shot-damage)

### attackerDefeated
A raid status: the raiding fleet's own Command Ship was destroyed while away, so the fleet is defeated and sent home. The result of [trigger_raid_defeat_by_destruction](#trigger_raid_defeat_by_destruction). → [combat.md — Raid statuses](../knowledge/mechanics/combat.md#raid-statuses)

### away
A fleet state: the fleet (and its Command Ship) has left its home planet. While away, you cannot build/mine at home, **and your home planet's shields are vulnerable**. Required to raid. → [fleet.md](../knowledge/mechanics/fleet.md)

## B

### Block
A defender soaking a hit meant for the struct it protects. Requires the defender be in the **target's** ambit, the weapon be blockable, and the defender pass a readiness check. Fires only on non-evaded shots, attempted every shot. → [combat.md — Blocking](../knowledge/mechanics/combat.md#blocking)

### block_raid_start
A GRASS category fired when a planet's raid vulnerability clock (`blockStartRaid`) is armed. → [api/streaming/event-types.md](../api/streaming/event-types.md#planet-events)

### blockStartBuild / blockStartOreMine / blockStartOreRefine / blockStartRaid
The per-operation clocks that drive proof-of-work difficulty. Build's clock is one-shot per struct; mine/refine clocks reset after each completion; raid's clock arms when the defender becomes vulnerable (`0` = not raidable). → [hashing.md — The Per-Type Clock](../knowledge/mechanics/hashing.md#the-per-type-clock-blockstart)

### Build
Constructing a struct: `struct-build-initiate` starts the clock, then a proof-of-work `struct-build-compute` completes and auto-activates it. → [building.md](../knowledge/mechanics/building.md)

### BuildDraw / PassiveDraw
A struct's power draw while building (`BuildDraw`) vs while online (`PassiveDraw`), in watts. Both must fit your capacity. → [power.md](../knowledge/mechanics/power.md)

### Build limit
The per-player cap on how many of a struct type you can own. Most planet structs and the Command Ship are 1; Orbital Shield Generator, Ore Bunker, and fleet combat structs are unlimited. Exceeding it raises [capacity_exceeded](#capacity_exceeded). → [building.md — Struct Limits](../knowledge/mechanics/building.md#struct-limits-per-player)

## C

### capacity / capacitySecondary
Your power capacity (primary plus secondary). Available power = `(capacity + capacitySecondary) − (load + structsLoad)`. → [power.md](../knowledge/mechanics/power.md)

### capacity_exceeded
The structured error key behind `cannot handle new load requirements (required: X, available: Y)`. **Two causes, told apart by magnitude**: tiny equal integers = build-limit hit; large values = power-capacity shortage (milliwatts). → [building.md — Build Validation Order](../knowledge/mechanics/building.md#build-validation-order), [troubleshooting](../troubleshooting/common-issues.md#building-fails-cannot-handle-new-load-requirements)

### Charge
A **per-player** resource = `currentBlock − lastActionBlock`. Each action's "cost" is a **minimum threshold** the bar must reach; acting resets the bar to 0. You cannot bank or burst charge. Refills ~1/block. → [building.md — Charge Accumulation](../knowledge/mechanics/building.md#charge-accumulation)

### Command Ship
The single movable struct (type 1, 1 per player, 6 HP). Required for planet ops; defends the home planet while the fleet is on station. Destroyable but rebuildable. → [struct-types.md](../knowledge/entities/struct-types.md), [combat.md — Struct Destruction](../knowledge/mechanics/combat.md#struct-destruction)

### Counter-attack
Return damage from a defender or the target, fired at most once per `struct-attack` invocation. Requires the counter-attacker's weapon to reach the **attacker's** ambit (ambit-independent of what it defends). Defenders take no counter damage. → [combat.md — Counter-Attack](../knowledge/mechanics/combat.md#counter-attack)

## D

### -D flag
The difficulty target on `*-compute` commands: the CLI waits until difficulty decays to `D` before hashing. `-D 3` is the default — instant hash, zero CPU wasted. → [building.md — The -D Flag](../knowledge/mechanics/building.md#the--d-flag)

### Defender
A struct assigned via `struct-defense-set` to protect another. Any co-located, built, online struct can be assigned regardless of ambit; ambit only governs whether it blocks (same ambit) or merely counters (cross ambit). → [combat.md — Assigning Defenders](../knowledge/mechanics/combat.md#assigning-defenders-struct-defense-set)

### Defensive Maneuver
A unit defense (High Altitude Interceptor) that evades **unguided** weapons 66% of the time. Beaten by guided weapons. → [combat.md — Weapon Control vs Defense Type](../knowledge/mechanics/combat.md#weapon-control-vs-defense-type)

### demilitarized
A raid status: the planet has no defenders to resolve against. → [combat.md — Raid statuses](../knowledge/mechanics/combat.md#raid-statuses)

### Difficulty
The proof-of-work target = number of leading hex zeros required. Decays with the operation's age from 64 (fresh, impossible) toward 1 (aged, instant). The D=8→D=9 jump is the "cliff". → [hashing.md — Difficulty and Decay](../knowledge/mechanics/hashing.md#difficulty-and-decay)

## E

### Evasion
A per-target roll where the target's defense type may dodge an entire volley. Guided vs Signal Jamming, or unguided vs Defensive Maneuver, miss 66% of the time. Planetary interceptors can also evade. → [combat.md — Evasion](../knowledge/mechanics/combat.md#evasion)

## F

### Fleet
Your mobile group of structs, including the Command Ship. States: `onStation` (home) or `away`. → [fleet.md](../knowledge/mechanics/fleet.md)

### fleet_advance
A category present in the enum but **not emitted** by the current indexer; fleet movement surfaces as `fleet_depart` then `fleet_arrive`. → [api/streaming/event-types.md](../api/streaming/event-types.md#planet-events)

## G

### Generators (Field / Continental Power Plant / World Engine)
Planet power structs (types 20/21/22). Hardened HP and carry `armour` (damage reduction 1). They raise capacity, not neighbours' HP. → [struct-types.md](../knowledge/entities/struct-types.md)

### GRASS
Game Real-time Application Streaming Service — real-time game events over NATS WebSocket, hosted per guild. → [structs-streaming SKILL](../.cursor/skills/structs-streaming/SKILL.md)

### Guaranteed shots
The minimum auto-hit shots before the success-rate roll applies. Only the Starfighter Attack Run secondary has one (`= 1`); the field is `omitempty` so it's absent (=0) on every other type. → [combat.md — Multi-Shot Damage](../knowledge/mechanics/combat.md#multi-shot-damage)

### Guided / Unguided
A weapon's control type. Guided weapons are evaded by Signal Jamming (66%); unguided weapons are evaded by Defensive Maneuver (66%). → [combat.md — Weapon Control vs Defense Type](../knowledge/mechanics/combat.md#weapon-control-vs-defense-type)

## H

### Hash types
The four proof-of-work operations: build, mine, refine, raid. Each shares one algorithm but keys off a different clock and difficulty range. → [hashing.md — The Four Hash Types](../knowledge/mechanics/hashing.md#the-four-hash-types)

### HP (Health)
A struct's hit points; reaches 0 → destroyed, no regeneration. Lives in `struct_attribute`, not the base struct row. → [combat.md — Health Points](../knowledge/mechanics/combat.md#health-points), [integration-notes.md](../api/integration-notes.md#where-struct-hp-and-status-live)

## I

### Indirect Combat Module
Mobile Artillery's unit defense: it cannot counter-attack when attacked. → [struct-types.md — Defensive Properties](../knowledge/entities/struct-types.md)

### Infusion
Converting Alpha Matter into reactor/generator power capacity. → [structs-energy SKILL](../.cursor/skills/structs-energy/SKILL.md)

## J

### Jamming Satellite
Planet struct (type 17, 1 per player, `noUnitDefenses`) that provides the planet's [low-orbit ballistic interceptor network](#low-orbit-ballistic-interceptor-network). It does **not** zero guided weapons. → [struct-types.md](../knowledge/entities/struct-types.md), [combat.md — Other Planetary Defense Structs](../knowledge/mechanics/combat.md#other-planetary-defense-structs)

## L

### Load
Current power consumption. If `load > capacity`, the player/struct goes offline. → [power.md](../knowledge/mechanics/power.md)

### local (ambit)
Enum 5 / bitmask 32. The Command Ship's "current ambit" weapon flag — it attacks whatever ambit it currently occupies. → [combat.md — Ambit Targeting](../knowledge/mechanics/combat.md#ambit-targeting)

### Low-orbit ballistic interceptor network
A planetary defense (from the Jamming Satellite) that evades an incoming attack when the **attacker is in air/space and the target struct is in land/water**, flagged `evadedByPlanetaryDefenses`. → [combat.md — Other Planetary Defense Structs](../knowledge/mechanics/combat.md#other-planetary-defense-structs)

## M

### Materialized / Built / Online
Struct lifecycle bits: Materialized (slot reserved, awaiting PoW) → Built (complete, offline) → Online (active). → [building.md — Struct State Machine](../knowledge/mechanics/building.md#struct-state-machine)

### Multi-shot
Multiple projectiles fired at **one** target in a single volley (`primaryWeaponShots`). Distinct from multi-target. → [combat.md — Targets per attack](../knowledge/mechanics/combat.md#targets-per-attack)

### Multi-target
Hitting more than one target per volley (`primaryWeaponTargets`). **No weapon does this** — every type is `targets = 1`. → [combat.md — Targets per attack](../knowledge/mechanics/combat.md#targets-per-attack)

## N

### NATS
The messaging system GRASS rides on; agents subscribe over WebSocket. → [structs-streaming SKILL](../.cursor/skills/structs-streaming/SKILL.md)

### Nonce / Proof
The two PoW fields on a `*-complete` message: `nonce` (the value found by brute force) and `proof` (the lowercase-hex SHA-256 digest that clears difficulty). → [hashing.md — Universal Input Format](../knowledge/mechanics/hashing.md#universal-input-format)

## O

### onStation
A fleet state: the fleet is at its home planet, so the Command Ship defends it (shields up). → [fleet.md](../knowledge/mechanics/fleet.md)

### Ore (storedOre / remainingOre)
`storedOre` is mined, stealable ore held by a player (the only raid loot). `remainingOre` is unmined ore on the planet. Refine `storedOre` to secure it as Alpha. → [resources.md](../knowledge/mechanics/resources.md)

## P

### PassiveDraw
See [BuildDraw / PassiveDraw](#builddraw--passivedraw).

### planet_activity
The PostgreSQL table whose inserts fire the GRASS stream; the source of full `struct_attack` shot detail when the live payload is [stubbed](#stub). → [structs-streaming SKILL](../.cursor/skills/structs-streaming/SKILL.md), [database-schema.md](../schemas/database-schema.md)

### Planetary Defense Cannon (PDC)
Planet struct (type 19, 1 per player) that auto-fires at any attacker of planetary structs after all targets resolve. Multiple players' PDCs stack. → [combat.md — Planetary Defense Cannon](../knowledge/mechanics/combat.md#planetary-defense-cannon)

### Planetary shield
A planet's raid-difficulty value = base 25 + online defense-struct contributions. Higher shield = harder raid PoW. Only matters while the planet is raidable. → [struct-types.md — Planetary Shield Contributions](../knowledge/entities/struct-types.md#planetary-shield-contributions)

### Proof-of-work (PoW)
The SHA-256 puzzle that finalizes build/mine/refine/raid. Difficulty decays with age. → [hashing.md](../knowledge/mechanics/hashing.md)

### Proxy signup
Guild-fronted player creation (`MsgGuildMembershipJoinProxy`): sign a payload, POST to the guild, poll for your player id. Idempotent — a repeat returns `resource_already_exists` (treat as success). → [integration-notes.md — Proxy signup](../api/integration-notes.md#proxy-signup-is-idempotent)

## R

### Raid
`planet-raid-complete` — a proof-of-work assault that seizes **all** of a vulnerable defender's `storedOre`. Does not destroy the player or their structs. → [combat.md — What a raid does](../knowledge/mechanics/combat.md#what-a-raid-does)

### Raid statuses
The `RaidStatus_*` lifecycle: `initiated` → `shieldsVulnerable` → (`raidSuccessful` | `attackerRetreated` | `attackerDefeated` | `ongoing` | `demilitarized`). → [combat.md — Raid statuses](../knowledge/mechanics/combat.md#raid-statuses)

### Recoil damage
Self-damage the attacker takes after firing, applied only if it survives the whole sequence (including counters). → [combat.md — Recoil Damage](../knowledge/mechanics/combat.md#recoil-damage)

## S

### shieldsVulnerable
The raid-winnable state: the defender's fleet is off-station, or their Command Ship is offline/destroyed/absent. The single most important raid gate. → [combat.md — Raid Phases and SHIELDS_VULNERABLE](../knowledge/mechanics/combat.md#raid-phases-and-shields_vulnerable)

### shield_change
A GRASS category fired when a planet's shield value changes. → [api/streaming/event-types.md](../api/streaming/event-types.md#planet-events)

### Signal Jamming
A unit defense (Battleship, Pursuit Fighter, Cruiser) that evades **guided** weapons 66% of the time. This — not the Jamming Satellite — is why guided weapons miss repeatedly. Beaten by unguided weapons. → [combat.md — Weapon Control vs Defense Type](../knowledge/mechanics/combat.md#weapon-control-vs-defense-type)

### Stealth Mode
A unit defense (Stealth Bomber, Submersible) that blocks cross-ambit targeting only; same-ambit structs can still hit. Attacking breaks stealth. → [combat.md — Stealth](../knowledge/mechanics/combat.md#stealth)

### Status (numeric)
A struct's `status` is a `StructState` **bit-flag**, not an enum: Materialized 1, Built 2, Online 4, Stored 8, Hidden 16, Destroyed 32, Locked 64. E.g. `7` = online, `35` = destroyed. → [building.md — Status field (numeric)](../knowledge/mechanics/building.md#status-field-numeric)

### Stub
The `{ "stub": true }` envelope the GRASS stream sends in place of a `struct_attack` (or other large) payload that exceeds ~7995 bytes. Pull the full shot detail from `planet_activity`. → [structs-streaming SKILL — Combat Event Payloads](../.cursor/skills/structs-streaming/SKILL.md#combat-event-payloads)

### struct_attack
The GRASS category for an attack, carrying per-shot `eventAttackShotDetail[]` — unless [stubbed](#stub). → [integration-notes.md — struct_attack event detail schema](../api/integration-notes.md#struct_attack-event-detail-schema)

### struct_health
The GRASS effect category for an HP change; always streams in full (use it to detect combat when `struct_attack` is stubbed). → [api/streaming/event-types.md](../api/streaming/event-types.md#struct-events)

### StructSweepDelay
The ~5-block window after destruction where a slot may still reference the dead struct ID. `destroyed_block` records the exact height. → [building.md — Struct State Machine](../knowledge/mechanics/building.md#struct-state-machine)

### Substation
Infrastructure that routes power capacity (via allocations/connections) between players and structs. → [structs-energy SKILL](../.cursor/skills/structs-energy/SKILL.md)

## T

### trigger_raid_defeat_by_destruction
A Command Ship property: when a Command Ship is destroyed **while away from home**, its fleet is defeated (`attackerDefeated`) and sent home. It defeats the **attacking** fleet — not the defender. → [combat.md — What a raid does](../knowledge/mechanics/combat.md#what-a-raid-does)

## U

### Unguided
See [Guided / Unguided](#guided--unguided).

---

## See Also

- [SITEMAP.md](../SITEMAP.md) — full file map of the repository
- [reference/gameplay-index.md](gameplay-index.md) — gameplay documentation index
- [reference/action-quick-reference.md](action-quick-reference.md) — every game action at a glance
- [knowledge/mechanics/combat.md](../knowledge/mechanics/combat.md) — the densest source of glossary terms
- [knowledge/mechanics/hashing.md](../knowledge/mechanics/hashing.md) — proof-of-work canonical reference
- [api/integration-notes.md](../api/integration-notes.md) — data-shape gotchas for integrators
