---
title: "Situation: Planet running out of ore"
---

# Situation: Planet depletion

**Triggers**: Your planet's remaining ore is low; mining yields are falling; you're planning
the next base.

## 60-second diagnosis

```
structsd query structs planet [planet-id]     # remaining ore / status
```

- **Ore low but present** → keep mining, but line up the next planet now.
- **Ore exhausted** → this planet can't feed production; you must relocate or expand.

## Do this, in order

1. **Refine what you have.** Unrefined ore is stealable; convert it to Alpha Matter before
   you move attention elsewhere.
2. **Scout the next planet** in parallel (free) — see [intel](../../.cursor/skills/structs-intel/SKILL.md)
   and [planets & fleet](../../.cursor/skills/structs-planets-fleet/SKILL.md).
3. **Explore / claim** a fresh planet before the current one is dead, so production never
   fully stops.
4. **Migrate infrastructure** deliberately: moving the fleet changes your raid exposure
   (on-station vs away). Don't leave assets undefended mid-move.

## Stop / escalate

- Don't abandon a planet with unrefined ore still stored — refine or accept the theft risk
  consciously.
- Relocation that crosses into contested space → check [threat detection](../../awareness/threat-detection.md) first.

## See also

- Mechanics: [planet](../../knowledge/mechanics/planet.md) · [fleet](../../knowledge/mechanics/fleet.md)
- Skills: [planets & fleet](../../.cursor/skills/structs-planets-fleet/SKILL.md) · [production](../../.cursor/skills/structs-production/SKILL.md)
