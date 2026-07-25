# Combat Bot Example

**Version**: 2.0.0  
**Category**: Gameplay  
**Purpose**: Point agents at the real combat/raid procedures (the previous fictional “planet capture” API is retired)

---

## Important corrections

- **You cannot capture or transfer planet ownership by attacking.** Attacks damage/destroy structs. Raids steal **all** of a player's unrefined ore (`storedOre` / `gridAttributes.ore`) and nothing else.
- **One Command Ship per player** (build limit 1). Fleet status is `onStation` / `away`.
- **Shields gate raids**: `planet-raid-complete` needs the defender vulnerable (fleet away, or Command Ship offline/destroyed). See [defense.md](../knowledge/mechanics/defense.md).
- Prefer live tools: Desktop `structs_intel` / `structs_action` / `structs_strike`, or CLI in the combat skill — not invented `chart` / `planetaryBattleship` payloads.

---

## Canonical workflows

| Goal | Follow |
|------|--------|
| Scout / go-no-go | [`structs-combat` skill](../.cursor/skills/structs-combat/SKILL.md) + [`structs-intel`](../.cursor/skills/structs-intel/SKILL.md); transcript [02-raid-go-no-go](transcripts/02-raid-go-no-go.md) |
| Attack / siege / raid | [combat.md](../knowledge/mechanics/combat.md) — destroy defender CMD to open `shieldsVulnerable`, then raid PoW |
| Defend under raid | [under-attack](../playbooks/situations/under-attack.md) — ≈4-minute budget; shoot raider CMD; restore shields |
| Team / autoresponse | [team-operations](../playbooks/meta/team-operations.md) + SAFETY Standing Automation Grants |

---

## Minimal raid checklist (attacker)

1. Confirm target holds meaningful `storedOre` and is (or can be made) shield-vulnerable.
2. Refine **your** ore first — leaving home drops **your** shields.
3. `fleet-move` → strip blockers → destroy defender Command Ship if needed → `planet-raid-compute -D 3` when `blockStartRaid != 0`.
4. Return home; refine seized ore immediately.
5. Verify with queries / dashboard — broadcast ≠ success.

---

## Minimal defense checklist

1. Stay online (capacity ≥ load).
2. If a refine is already completable, finish it; otherwise do **not** start a new 34h refine mid-raid.
3. Restore Command Ship online + fleet `onStation`, and/or destroy the raider's Command Ship within ~1.8 minutes.
4. Brief the commander if arming `autoresponse` (Tier 2).

---

## See Also

- [03-combat-and-raid transcript](transcripts/03-combat-and-raid.md)
- [SAFETY.md](../SAFETY.md) — battle orders and combat-loop grants
