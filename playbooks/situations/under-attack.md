---
title: "Under attack: immediate response protocol"
description: "Hostile action against your territory. Act in priority order: check power, deny the prize, stop the raid. Panic loses more than the attacker takes."
---

# Under attack: immediate response protocol

**Situation**: Hostile action against your territory  
**Goal**: Minimize losses, protect critical assets, survive to fight another day  
**Principle**: Act in priority order. Panic loses more than the attacker takes.

---

## Immediate Response Protocol

When you detect an attack—raid, struct assault, or fleet engagement—execute this sequence. Do not skip steps. Do not reverse the order.

**Know the budget before you start.** Against a raid you have roughly **four minutes** total: median 2.1 min from `initiated` to `shieldsVulnerable`, then a hard ~2 min 6 s lock before loot. Every step below has to fit inside that. Defenders who returned fire within ~1.8 min are the *only* ones in the dataset who ever defeated an attacker; the median losing defender responded at 12.3 min. See [defense.md](../../knowledge/mechanics/defense.md#the-four-minute-clock).

Trigger on `raid_status: initiated` (or a hostile fleet arrival), not on damage. Waiting until structs are hurt spends most of the budget.

---

## 1. Check Power Status

If you go offline, you cannot act. Before anything else:

- Verify capacity covers load (`(capacity + capacitySecondary) >= (load + structsLoad)`)
- If marginal, do not activate new structs
- If overloaded, deactivate non-critical structs to stay online (`struct-deactivate` works even while offline)

A dead base cannot defend or respond. Power first.

---

## 2. Deny the Prize — Only If You Can Finish It Now

A successful raid seizes **all** of your `storedOre`. Starting a new refine does **not** help: ore stays stealable for the whole refine PoW (~34 h at D=3), and partial progress does not shrink the loot.

Mid-raid, deny the prize only if a refine is **already completable** (PoW finished or about to be — submit `struct-ore-refine-complete` / let Desktop finish). Otherwise skip to step 3; pre-raid discipline ("refine as soon as ore lands") is what zeroes the prize, not a four-minute scramble.

---

## 3. Stop the Raid (this is the fight)

Inside the four-minute window, two actions actually change the outcome:

1. **Restore shields** if they are down — Command Ship online with the fleet `onStation`. That flips status to `ongoing` and blocks `planet-raid-complete`.
2. **Shoot the raider's Command Ship** — co-located return fire. Destroying it ends the raid (`attackerDefeated`). Only on-station fleet (and anything else already parked at this planet) can shoot; combat is co-located.

If you run Desktop MCP and your commander has armed Standing Automation Grants, `structs_players` `autoresponse` is built for exactly this window — do not hand-time shots slower than the loop. See [SAFETY.md](../../SAFETY.md) and [team-operations](../meta/team-operations.md).

Do **not** spend the budget activating unused defenses or starting new builds. PDC/jammers already online help; mid-raid builds will not finish in time.

---

## 4. Assess Attacker Strength (only after 1–3 are moving)

Gather intelligence while responses are in flight:

- How many ships? What type?
- Is this a raid (steal ore) or an attack (destroy structs)?
- Solo or guild-coordinated?

Raid = economic loss (all `storedOre`). Attack = structural loss. Different follow-ups.

---

## 5. Decide: Hold or Cut Losses

**Hold when**:

- Shields restored or raider CMD under fire
- Ore already refined / near-zero
- Allies or autoresponse covering the planet

**Cut losses when**:

- You cannot restore shields or reach the raider CMD before the lock
- Ore is already gone (`raidSuccessful`) — rebuild CMD, refine future ore faster, do not chase

You own **one** planet. "Evacuate" means protect what you can (refine-if-ready, keep CMD alive), not abandon for another base mid-fight.

---

## 6. Planned Counter — After the Clock

Do **not** save return fire for later — mid-raid shots are step 3. What waits until you are secure is a *planned* counter-raid on their home (fleet move, siege doctrine, revenge timing). Reactive home-raids while your own shields are still contested often fail. See [Tempo](../meta/tempo.md) and [combat.md](../../knowledge/mechanics/combat.md).

---

## Behavioral Notes by Attacker Type

- **Killer**: Expect sustained pressure. They want the fight. Deny them ore value; fortify for the long game.
- **Entrepreneur**: Likely raiding for resources to fund their build. Hit their economy in a planned response.
- **Achiever**: May be chasing a goal. Identify it; make it costly.
- **Explorer**: Rare attacker. If they're hitting you, you're in their way. Clear and decisive defense usually deters.

---

## See Also

- [Defense](../../knowledge/mechanics/defense.md) — What a raid can take and the four-minute clock
- [Early Game](../phases/early-game.md) — Why power and refinement matter from the start
- [Resource Rich](resource-rich.md) — Rich targets get attacked; prepare accordingly
- [Guild War](guild-war.md) — When attacks are coordinated
- [Counter-Strategies](../meta/counter-strategies.md) — Beating the Killer and other aggressors
- [Tempo](../meta/tempo.md) — When to counter-raid
- [Team Operations](../meta/team-operations.md) — `autoresponse` / Standing Automation Grants
