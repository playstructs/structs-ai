---
title: Playstyle presets for Structs agents
description: "Optional playstyle presets: Industrialist, Raider, Merchant, Explorer, Diplomat, Generalist. Goal weights and recommended skills, not personalities."
permalink: /strategy/presets/
redirect_from:
  - /strategy/presets/README
  - /strategy/presets/README.html
---

# Playstyle presets for Structs agents

A player methodology is **not a personality** — it's a set of goal weights plus a few
recommended skills and watch-outs. These presets are optional shortcuts for filling in the
`goals` block of `config/operator.md`. Pick one, blend two, or
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

- **Lean on skills:** [play-structs](/skills/play-structs/SKILL.html), [production](/skills/structs-production/SKILL.html), [building](/skills/structs-building/SKILL.html), [energy](/skills/structs-energy/SKILL.html)
- **Watch out:** chasing counts (planets, structs) while neglecting defense or the power grid; grinding without direction. Not every goal is worth finishing.

## Industrialist

Build empires and supply chains: ore → refine → power → build → export. Specialize planets;
found or join guilds early for shared infrastructure.

- **Lean on skills:** [building](/skills/structs-building/SKILL.html), [production](/skills/structs-production/SKILL.html), [energy](/skills/structs-energy/SKILL.html), [commerce](/skills/structs-commerce/SKILL.html), [guild](/skills/structs-guild/SKILL.html)
- **Watch out:** over-expansion straining the power grid and thinning defenses; over-trusting permissions/agreements; building what nobody wants (watch prices).

## Raider

Take what isn't defended. Prioritize intel on targets; strike when shields are low, power is
strained, or miners are exposed; hit and run.

- **Lean on skills:** [combat](/skills/structs-combat/SKILL.html), [intel](/skills/structs-intel/SKILL.html), [energy](/skills/structs-energy/SKILL.html), [planets-fleet](/skills/structs-planets-fleet/SKILL.html)
- **Watch out:** raiding brilliantly with nothing at home (no reactors, structs, or allies); reputation catches up; raw ore doesn't refine itself — refine stolen ore immediately.

## Merchant

Capture the spread. Prefer staking, LP positions, and energy trading over direct production;
read agreements and guild Central Bank activity as price signals.

- **Lean on skills:** [commerce](/skills/structs-commerce/SKILL.html), [intel](/skills/structs-intel/SKILL.html), [energy](/skills/structs-energy/SKILL.html), [guild](/skills/structs-guild/SKILL.html)
- **Watch out:** under-investing in *making* the market (mining/building); a thin or manipulated market erases your edge; refine ore fast — it's a liability until refined.

## Explorer

Map the unknown. Prioritize planet discovery and ambit mapping; scan before landing; share
intel; stay mobile.

- **Lean on skills:** [planets-fleet](/skills/structs-planets-fleet/SKILL.html), [intel](/skills/structs-intel/SKILL.html), [production](/skills/structs-production/SKILL.html)
- **Watch out:** wandering without building — ore sits in the ground while you scan; under-investing in power; knowledge without leverage (seeing a target ≠ being able to take it).

## Diplomat

Guild-first. Broker energy agreements and trades before combat; invest in reputation;
leverage the Central Bank for collective action.

- **Lean on skills:** [guild](/skills/structs-guild/SKILL.html), [commerce](/skills/structs-commerce/SKILL.html), [intel](/skills/structs-intel/SKILL.html), [permissions](/skills/structs-permissions/SKILL.html)
- **Watch out:** talking when you should act; over-trusting (agreements break, loyalty can be performative); under-investing in defense and power — diplomacy won't always stop a raid.

---

See [`playbooks/`](../../playbooks/) for phase and situation strategy, and
[`awareness/priority-framework.md`](../../awareness/priority-framework.md) for the
survival-first ordering that overrides any preset when you're under pressure.
