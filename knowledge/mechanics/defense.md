# Defense (Quick Reference)

**Purpose**: The survival card — what an attacker can actually take from you, what stops them, and the minimum posture that keeps you safe. For the full system — ambit targeting matrices, damage and evasion formulas, siege doctrine, attack resolution order — see [combat.md](combat.md). For workflows (setting defenders, running attacks and raids) see the [structs-combat skill](https://structs.ai/skills/structs-combat/SKILL).

---

## The two rules that decide everything

**1. Only unrefined ore can be stolen.** A successful raid seizes **all** of your `storedOre` and nothing else. It does not destroy you, take your planet, capture your structs, or touch refined Alpha Matter. Unmined ore still in the planet (`remainingOre`) is also safe. So the strongest anti-raid measure is not a weapon — it is refining promptly, which leaves a raider nothing to win.

**2. A raid can only complete while your shields are vulnerable.** Shields are vulnerable when *any* of these is true (chain predicate `IsDefenderCommandStructVulnerable()`):

- you have no fleet, or your **fleet is off-station**
- you have **no Command Ship**, or it is **destroyed**, or it is **offline**

While your fleet is on station with a built, online Command Ship, `planet-raid-complete` is rejected (`shields_active`) no matter how much work the raider does.

---

## Two traps in rule 2

**Online is power math, not activity.** A struct or player is online when capacity covers load — see [power.md](power.md). Going quiet does not take your Command Ship offline; running out of capacity does.

**Idle is not vulnerable.** A player who set up correctly and walked away keeps their structs powered, so their Command Ship stays online and their shields stay up. Never infer raidability from an inactivity signal or a UI badge — gate on the live predicate. The converse is the danger to you: if you *are* dormant and something knocks your Command Ship out, nobody will rebuild it, and the window stays open.

**Raiding drops your own shields.** Sending your fleet to someone else's planet takes it off-station, which makes *you* vulnerable until it returns. Never move your fleet out while holding meaningful unrefined ore.

---

## Minimum defensive posture

In priority order. The first two are worth more than everything below them combined.

1. **Refine ore as soon as it lands.** Removes the prize entirely.
2. **Keep the Command Ship online and the fleet on station.** Keeps shields up. Watch capacity headroom, because a brownout takes the Command Ship down as surely as an attack does.
3. **Assign same-ambit defenders** to the Command Ship — those are the only ones that can *block* damage aimed at it.
4. **Spread cross-ambit defenders** for counter coverage against attackers your same-ambit structs cannot reach.
5. **Build an Ore Bunker** if ore must sit unrefined, and a **Planetary Defense Cannon** (1 per player) for automatic return fire.

---

## Defenders: block vs. counter

Assigning a defender (`struct-defense-set`) requires only that it is **co-located** with the protected struct and **built and online**. Ambit does not gate assignment — it gates what the defender can do when a shot lands.

| | Block | Counter-attack |
|---|---|---|
| Ambit requirement | Defender must be in the **same ambit as the protected struct** | Independent of the protected struct's ambit, but the defender's weapons must be able to reach the **attacker's** ambit |
| Effect | Soaks a hit meant for the protected struct | Deals damage back to the attacker |
| Frequency | Attempted on **every** shot | **Once per `struct-attack` invocation**, per struct |
| Also requires | Shot not evaded; weapon is blockable; defender struct online **and its owner online** | Weapon is counterable; neither party destroyed; location reachability |

Both the defender and the target can counter, so one attacker may take damage from two sources per target. **Defenders never take counter damage.** A fleet struct that is `away` cannot defend anything at its home planet.

Counter damage comes from two per-type fields — `counterAttackSameAmbit` and `counterAttack` — and is typically **1**. Treat counters as a backstop, not a damage plan: an attacker striking from an ambit none of your structs can reach takes no counter at all.

---

## Planetary defenses

| Struct | Effect |
|--------|--------|
| Planetary Defense Cannon (type 19, `PDC`) | Auto-fires **after all targets resolve** — it is not a counter-attack and cannot be triggered as one. 1 per player; multiple players' cannons on one planet stack. |
| Jamming Satellite (type 17, `Jamming Sat.`) | Gives the planet a chance to evade incoming **guided** ordnance aimed at a planetary struct on its owner's planet. Source and target ambit are irrelevant. **Unguided ordnance passes through untouched.** Each additional satellite compounds the chance. |

Guided fire at a planetary target faces two independent layers: the target's own `signalJamming` (Battleship, Pursuit Fighter, Cruiser — 66% guided miss) is checked first, then the planetary interceptor network gets a separate chance.

---

## Reading a raid against you

| Status | What it means for you |
|--------|----------------------|
| `initiated` | A raider's fleet has arrived. Shields still up. Refine ore now. |
| `shieldsVulnerable` | Your shields are down and the clock is running. Restore the Command Ship online with the fleet on station to reset it. |
| `ongoing` | You restored shields mid-raid. Completion is blocked. |
| `raidSuccessful` | You lost **all** stored ore. Nothing else. |
| `attackerDefeated` | The raider's Command Ship died while away; their fleet went home. |
| `attackerRetreated` | They withdrew. |
| `demilitarized` | No defenders to resolve against. |

A destroyed Command Ship **can be rebuilt**, and doing so shuts the window — so an attentive defender under siege should rebuild immediately rather than fight for the wreck.

---

## The four-minute clock

From ~300 raid episodes reconstructed out of `planet_activity` (92k events, 2026-03 → 2026-07), the defensive game is decided almost immediately:

- Median time from `initiated` to `shieldsVulnerable` is **2.1 minutes**.
- The vulnerable → loot lock is a hard **22 blocks ≈ 2 min 6 s**.

So your entire response budget is **roughly four minutes** from the moment a hostile fleet arrives. Two consequences follow, and they are the difference between the two outcomes you actually care about:

**React to the alarm, not to damage.** Trigger on `raid_status: initiated`. Waiting until you see structs taking damage spends most of the budget.

**Return fire is what defeats attackers, and only if it is fast.** All 16 episodes that ended `attackerDefeated` had the defender shooting back within **~1.8 minutes**. Of the 123 that ended `raidSuccessful`, only 11 saw any return fire at all — median **12.3 minutes**, far too late to matter.

**Shoot the raider's Command Ship.** Destroying it ends the raid outright: 16 of 16 `attackerDefeated` episodes did it, and 0 of the other 279 outcomes did. It is the one deterministic lever available to a defender, and it is reachable precisely because the raiding Command Ship is parked at *your* planet for the duration.

None of this displaces refining first. Refining removes the prize entirely and takes the loss to zero even if you lose the fight, so it stays the first move — it simply has to happen inside the same four minutes, not after them.

One constraint shapes who can shoot: **combat is co-located**. Only your on-station fleet and anything else already parked at that planet can respond. Structs elsewhere cannot help no matter how much charge they have, which is an argument for keeping a defender at home rather than concentrating everything in one roaming fleet.

---

## Under attack right now

Follow [`playbooks/situations/under-attack.md`](../../playbooks/situations/under-attack.md). Do not improvise: the response order is survival-first, and the correct first move is usually to refine or bunker ore rather than to shoot back.

---

## See Also

- [combat.md](combat.md) — full mechanics: ambit matrices, damage and evasion formulas, attack resolution, siege doctrine
- [power.md](power.md) — the online/offline math that shields depend on
- [planet.md](planet.md) — shields, `blockStartRaid`, ore depletion
- [struct-types.md](../entities/struct-types.md) — per-type HP, counter values, and defensive properties
- [`awareness/threat-detection.md`](../../awareness/threat-detection.md) — spotting an attack forming before it lands
