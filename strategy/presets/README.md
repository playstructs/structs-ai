---
title: Playstyle presets
permalink: /strategy/presets/README
---

# Playstyle presets

A player methodology is **not a personality** — it's a set of goal weights plus a few
recommended skills and watch-outs. These presets are optional shortcuts for filling in the
`goals` block of [`config/operator.md`](../../config/operator.md). Pick one, blend two, or
ignore them and set weights directly.

Weights are 0–3 (0 = ignore, 3 = primary focus), matching the operator profile:
`economy`, `expansion`, `military`, `exploration`, `guild`.

| Preset | economy | expansion | military | exploration | guild |
|--------|:---:|:---:|:---:|:---:|:---:|
| **Generalist** | 2 | 2 | 1 | 1 | 1 |
| **Industrialist** | 3 | 2 | 1 | 1 | 2 |
| **Raider** | 1 | 1 | 3 | 2 | 1 |
| **Merchant** | 3 | 1 | 0 | 1 | 2 |
| **Explorer** | 1 | 2 | 1 | 3 | 1 |
| **Diplomat** | 2 | 1 | 0 | 1 | 3 |

---

## Generalist

Balanced, momentum-first. Keep multiple operations running — mine while building, explore
while refining — and avoid downtime.

- **Lean on skills:** [play-structs](../../.cursor/skills/play-structs/SKILL.md), [production](../../.cursor/skills/structs-production/SKILL.md), [building](../../.cursor/skills/structs-building/SKILL.md), [energy](../../.cursor/skills/structs-energy/SKILL.md)
- **Watch out:** chasing counts (planets, structs) while neglecting defense or the power grid; grinding without direction. Not every goal is worth finishing.

## Industrialist

Build empires and supply chains: ore → refine → power → build → export. Specialize planets;
found or join guilds early for shared infrastructure.

- **Lean on skills:** [building](../../.cursor/skills/structs-building/SKILL.md), [production](../../.cursor/skills/structs-production/SKILL.md), [energy](../../.cursor/skills/structs-energy/SKILL.md), [commerce](../../.cursor/skills/structs-commerce/SKILL.md), [guild](../../.cursor/skills/structs-guild/SKILL.md)
- **Watch out:** over-expansion straining the power grid and thinning defenses; over-trusting permissions/agreements; building what nobody wants (watch prices).

## Raider

Take what isn't defended. Prioritize intel on targets; strike when shields are low, power is
strained, or miners are exposed; hit and run.

- **Lean on skills:** [combat](../../.cursor/skills/structs-combat/SKILL.md), [intel](../../.cursor/skills/structs-intel/SKILL.md), [energy](../../.cursor/skills/structs-energy/SKILL.md), [planets-fleet](../../.cursor/skills/structs-planets-fleet/SKILL.md)
- **Watch out:** raiding brilliantly with nothing at home (no reactors, structs, or allies); reputation catches up; raw ore doesn't refine itself — refine stolen ore immediately.

## Merchant

Capture the spread. Prefer staking, LP positions, and energy trading over direct production;
read agreements and guild Central Bank activity as price signals.

- **Lean on skills:** [commerce](../../.cursor/skills/structs-commerce/SKILL.md), [intel](../../.cursor/skills/structs-intel/SKILL.md), [energy](../../.cursor/skills/structs-energy/SKILL.md), [guild](../../.cursor/skills/structs-guild/SKILL.md)
- **Watch out:** under-investing in *making* the market (mining/building); a thin or manipulated market erases your edge; refine ore fast — it's a liability until refined.

## Explorer

Map the unknown. Prioritize planet discovery and ambit mapping; scan before landing; share
intel; stay mobile.

- **Lean on skills:** [planets-fleet](../../.cursor/skills/structs-planets-fleet/SKILL.md), [intel](../../.cursor/skills/structs-intel/SKILL.md), [production](../../.cursor/skills/structs-production/SKILL.md)
- **Watch out:** wandering without building — ore sits in the ground while you scan; under-investing in power; knowledge without leverage (seeing a target ≠ being able to take it).

## Diplomat

Guild-first. Broker energy agreements and trades before combat; invest in reputation;
leverage the Central Bank for collective action.

- **Lean on skills:** [guild](../../.cursor/skills/structs-guild/SKILL.md), [commerce](../../.cursor/skills/structs-commerce/SKILL.md), [intel](../../.cursor/skills/structs-intel/SKILL.md), [permissions](../../.cursor/skills/structs-permissions/SKILL.md)
- **Watch out:** talking when you should act; over-trusting (agreements break, loyalty can be performative); under-investing in defense and power — diplomacy won't always stop a raid.

---

See [`playbooks/`](../../playbooks/) for phase and situation strategy, and
[`awareness/priority-framework.md`](../../awareness/priority-framework.md) for the
survival-first ordering that overrides any preset when you're under pressure.
