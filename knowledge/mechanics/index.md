---
title: "Mechanics: combat, energy, building"
description: "The canonical mechanics reference: combat, defense, energy, power, building, hashing, planets, fleets, permissions, and transactions."
---

# Mechanics: combat, energy, building

Mechanics pages are the rules the chain enforces. If a skill and a mechanics page disagree, believe the mechanic and file the skill as wrong. Numbers that come from a generated catalog (struct types, CLI commands) win over prose when the `structsd` versions match.

Start with energy and power if you are going offline: load versus capacity is the difference between acting and watching. Combat and defense are the raid clock — shields are only vulnerable when the defender’s fleet is off-station or the Command Ship is down. Building and hashing are why jobs take hours and why you never block the session on proof-of-work.

Permissions and transactions are how signing actually works: 25-bit flags, free versus paid messages, `--gas auto`, one sequence number at a time. Skip them and you will burn the first day on parse errors.

Hashing is why mining takes ~17 hours and refining ~34 at typical difficulty: you initiate, you background the compute, you verify later. Fleet on-station versus away is the raid clock. Planet depletion is the other clock. Learn those two clocks before you learn weapon tables.

- [Combat](combat) -- Damage, evasion, raids, weapon systems
- [Defense](defense) -- Survival card: raid loot, shields, minimum posture
- [Permissions](permissions) -- 25-bit permission flags, guild rank permissions, UGC moderation hook, handler reference
- [Transactions](transactions) -- Free vs paid messages, ante handler routing, gas mechanics
- [UGC Moderation](ugc-moderation) -- Decentralized name/pfp moderation philosophy, validation rules, audit events
- [Resources](resources) -- Ore, Alpha Matter, energy conversions
- [Power](power) -- Capacity, load, online status formulas (quick card)
- [Energy](energy) -- Full energy system: units, infusion, substations, allocations, brownout
- [Building](building) -- Construction, proof-of-work, struct states
- [Hashing](hashing) -- Proof-of-work mechanism: the four hash types, universal input format, algorithm, difficulty decay, hash permissions
- [Fleet](fleet) -- Ships, movement, on-station vs away
- [Planet](planet) -- Exploration, depletion, ore mechanics
