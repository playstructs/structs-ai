---
title: Briefing Your Commander
---

# Briefing Your Commander

**Purpose**: How to report Structs game state to a human who does not speak Structs. This is the outward-facing counterpart to [context-handoff](context-handoff) (which briefs your *future self*, and can safely use jargon) and to [`SAFETY.md`](../SAFETY.md) (which defines *when* you must ask permission — this page covers *how to ask well*).

Your commander is accountable for what happens to these assets but is not living in the game state. A report that is technically complete and unreadable is a failed report.

---

## Lead with the decision, not the state

The first sentence should answer "what do you need from me, or what changed that I care about." State follows as support.

| Instead of | Write |
|-----------|-------|
| "Player 1-42: storedOre 1200, gridAttributes.load 912960000, capacity 912960000, fleet 9-42 onStation false" | "Your fleet is away, which leaves 1,200 unrefined ore exposed to theft. I recommend recalling it — or refining first, which makes the exposure moot." |
| "shieldsVulnerable on 2-117, blockStartRaid 1284551" | "Someone is raiding us and our shields are down. They can take all 1,200 unrefined ore if they finish before we restore the Command Ship." |
| "struct 5-310 destroyed, trigger_raid_defeat_by_destruction fired" | "We lost the Planetary Defense Cannon. Nothing else was taken — a raid can only steal unrefined ore — but the planet is now easier to attack." |

Three habits do most of the work: name the stake in the human's terms ("1,200 ore" not "storedOre"), say what you recommend, and say what happens if nothing is done.

---

## Translate the vocabulary

| Term | Say instead |
|------|-------------|
| Entity ID like `1-42`, `2-117` | Name the thing: "your player", "your home planet". Keep the ID in parentheses only if the commander may need to look it up. |
| `storedOre` / ore | "unrefined ore — **stealable**" |
| Alpha Matter | "refined Alpha — **safe from theft**" |
| `remainingOre` | "ore still in the ground (also safe)" |
| Charge | "action budget; it refills on its own at 1 per block, about 6 seconds" |
| Ambit | "the layer a struct fights in: space, air, land, or water" |
| `shieldsVulnerable` | "our planetary shields are down, so a raid can succeed" |
| `onStation` / away | "our fleet is home / our fleet is away (which drops our shields)" |
| Online / offline | "powered / unpowered — it is a power-budget result, not an activity timer" |
| Chain power units | Convert to watts (chain value ÷ 1,000) and say "W". Never quote raw milliwatts. |
| Struct type | Use the chain's short label — `PDC`, `Orb. Shield`, `CMD Ship`, `Extractor` — because that is what the commander sees in the webapp and Desktop board. Full names are in [struct-types](../knowledge/entities/struct-types.md). |
| Proof-of-work / PoW / `-D 3` | "background computation; it runs for hours and submits itself when done" |
| Block height | "as of a few seconds ago" — or give the number only when staleness is the point |

Use the labels the commander's screen uses. If they are looking at the board and you call something a "type 19", you have made them do a lookup you could have done.

---

## Always date your claims

All game state is a snapshot, and some of it changes every block. Say how fresh a reading is whenever you are recommending an action based on it — especially raid go/no-go calls, where power and fleet position can flip between your scout and your strike. "Scouted 40 blocks ago, roughly four minutes" is a useful qualifier. "Their Command Ship is offline" stated flatly, from a ten-minute-old reading, is a claim you cannot support.

---

## Three report shapes

### Status check (unprompted, routine)

Short. Lead with the one thing that changed or the one thing at risk. If nothing is at risk, say so plainly and stop — no table required.

> Nothing needs you right now. The extractor finished; 1,200 ore is refining and will be safe in about 34 hours. Power has 40% headroom. No fleets have come near us.

### Approval request

Say what you want to do, what it costs, what is irreversible about it, and what you expect to gain. Name the tier from [`SAFETY.md`](../SAFETY.md) so the commander knows which contract applies, and state the downside without softening it.

> I want to raid planet 2-117 (Tier 1). Their Command Ship has been offline for three checks, so their shields are down and they are holding about 900 unrefined ore, which we would take all of. The cost: our fleet has to leave home, which drops our own shields for roughly two hours, and we currently hold 300 unrefined ore of our own. I would refine ours first, then go. If their Command Ship comes back online before we finish, we get nothing and have exposed ourselves for nothing.

For Tier 2 (irreversible or identity-changing) say the word **irreversible** and say what cannot be recovered. Never bundle a Tier 2 action into a list of routine ones.

### Incident

Lead with impact, then cause, then what you have already done, then what you need. Do not open with a stack trace or a rejection string.

> We lost the Planetary Defense Cannon in an attack about ten minutes ago. Nothing was stolen — a raid can only take unrefined ore, and ours was already refined. I have set two defenders on the Command Ship. Rebuilding the cannon costs 8 charge and about 48 minutes of computation; want me to start?

---

## What not to send

- Raw grid attribute IDs, transaction hashes without an outcome, or rejection strings without a translation. "`planet (2-117) cannot raid_complete while shields_active`" means "their shields came back up; the raid cannot finish" — send the second one, and the first only if they ask.
- Unconverted chain units. `912960000` is 912,960 W.
- A wall of state with the important line buried in it.
- False precision about the future. Proof-of-work durations and raid outcomes are probabilistic; say "about 34 hours" and "if they stay offline."
- Reassurance you have not verified. Broadcasting a transaction is not the same as it succeeding — confirm against game state before reporting an outcome.

---

## See Also

- [`SAFETY.md`](../SAFETY.md) — the trust contract and which tier an action falls under
- [context-handoff](context-handoff) — briefing your future self (jargon is fine there)
- [state-assessment](state-assessment) — working out what your position actually is, before reporting it
- [scorecard](scorecard) — self-evaluation, including whether your reporting served the commander
- [defense](../knowledge/mechanics/defense.md) — the survival facts most worth translating correctly
