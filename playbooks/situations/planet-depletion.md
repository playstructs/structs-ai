---
title: "Situation: Planet running out of ore"
description: "Your planet's ore is running out and yields are falling. How to diagnose it and how to plan the handoff to your next base."
---

# Situation: Planet running out of ore

**Triggers**: Your planet's remaining ore is low; mining yields are falling; you're planning
the next base.

Remember: **one planet per player**. Exploring a subsequent planet destroys the current one
(structs gone; visiting fleets scatter). It is a Tier-2, deliberate act — see
[planets & fleet](../../.cursor/skills/structs-planets-fleet/SKILL.md).

## 60-second diagnosis

```
structsd query structs planet [planet-id]     # remaining ore / status
```

- **Ore low but present** → keep mining and refining; **scout** the next planet in parallel (free).
- **Ore exhausted (`complete`)** → you may explore once the fleet is `onStation`.

## Do this, in order

1. **Refine what you have.** Unrefined ore is stealable; convert it to Alpha Matter before
   you leave.
2. **Scout the next planet** in parallel (free) — see [intel](../../.cursor/skills/structs-intel/SKILL.md)
   and [planets & fleet](../../.cursor/skills/structs-planets-fleet/SKILL.md). Do **not** explore yet.
3. **Mine the current planet to 0** deliberately so status becomes `complete`. You cannot
   explore while ore remains.
4. **Recall the fleet** if it is `away` — explore requires `onStation` at the current planet.
5. **Explore** only after steps 1–4. Expect to rebuild infrastructure on the new world;
   leftover planet structs on the old one are destroyed.
6. **Migrate carefully**: while the fleet is away for other reasons, your home shields are
   down — don't hold unrefined ore during that window.

## Stop / escalate

- Don't explore “early” to keep production continuous — the chain forbids it, and a mistaken
  explore wipes the base.
- Don't abandon with unrefined ore still stored — refine or accept the theft risk consciously.
- Relocation into contested space → check [threat detection](../../awareness/threat-detection.md) first.

## See also

- Mechanics: [planet](../../knowledge/mechanics/planet.md) · [fleet](../../knowledge/mechanics/fleet.md)
- Skills: [planets & fleet](../../.cursor/skills/structs-planets-fleet/SKILL.md) · [production](../../.cursor/skills/structs-production/SKILL.md)
