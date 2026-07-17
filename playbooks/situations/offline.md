---
title: "Situation: Offline / can't act"
---

# Situation: Offline (load > capacity)

**Triggers**: A struct won't come online; actions fail with power/online errors; your player
shows load exceeding capacity. Offline = you cannot build, mine, fight, or defend.

## 60-second diagnosis

```
structsd query structs player [player-id]      # compare load vs capacity, online status
```

- **load > capacity** → you're in brownout; the grid shed you. Reduce load or add capacity.
- **capacity dropped** → a reactor/generator/agreement went offline (maybe a raid, a defused
  reactor, or an expired agreement).
- **a single struct won't start** → its activation would push load over capacity.

## Do this, in order

1. **Shed load fast (free, works offline):** deactivate non-essential structs —
   `struct-deactivate` / `struct-deactivate-batch` cost 0 charge and work while offline.
   Priority to keep: defense and your Command Ship.
2. **Recover capacity:** if a reactor/agreement dropped, restore it. If you have Alpha,
   infuse for more capacity (see [energy skill](../../.cursor/skills/structs-energy/SKILL.md)).
3. **Re-balance:** bring structs back online one at a time, checking headroom after each.
4. **Verify:** re-query the player; confirm `online` and load < capacity.

## Stop / escalate

- If capacity loss came from a **raid or reactor defuse**, treat it as a security event →
  [under attack](under-attack.md).
- If infusion would exceed your operator's Tier-1 caps → escalate per
  [`config/operator.md`](../../config/operator.md).

## See also

- Skill: [energy](../../.cursor/skills/structs-energy/SKILL.md)
- Mechanics: [power](../../knowledge/mechanics/power.md) · [energy](../../knowledge/mechanics/energy.md)
