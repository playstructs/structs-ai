---
title: "Mid game: expand, fortify, join guilds"
description: "Expansion and scaling: deepen the pipeline, secure the home world, build alliances. When to plan the next planet, and fortify versus scale."
---

# Mid game: expand, fortify, join guilds

**Phase**: Expansion and scaling  
**Goal**: Deepen the pipeline, secure the home world, build alliances  
**Principle**: You own **one** planet. Scale by throughput, defense, guild/team capacity — not by collecting bases on one account.

---

## The Expansion Phase

Early game was survival. Mid game is multiplication of *output*, not of planets. You have a working base — your first mine-refine cycle has completed, you have Alpha Matter, and your pipeline is flowing. Now the question is: how much can this one world (and, if you run a team, your other players) sustain? Overbuild load and you go offline. Leave ore unrefined and you feed raiders. The machines that scale wisely dominate. The ones that overextend collapse.

**Timeline**: Mid game unfolds over days to weeks. Each mine-refine cycle takes ~51 hours at D=3. Use [async operations](../../awareness/async-operations.md) to keep mine and refine overlapping. Relocating to a new planet is a later, deliberate Tier-2 move after this one is empty — see [planet-depletion](../situations/planet-depletion.md).

---

## When to Plan the Next Planet

You cannot hold two planets. Scouting is free; **exploring** requires the current planet `complete` (ore 0) and the fleet `onStation`, and it **destroys** remaining structs on the old world.

Plan the next world when:

- Home extraction and power are stable
- You have Alpha Matter to rebuild infrastructure after explore
- Ore on the current planet is approaching zero (scout in parallel now)
- You can accept the Tier-2 wipe of leftover planet structs

Do not explore when:

- Home power is marginal or you are under threat
- You still have unrefined ore (refine first)
- The current planet still has ore — empty it deliberately, then explore

The Explorer soul type will push for early relocation. Balance that with the one-planet rule.

---

## Fortify vs Scale

The tension of mid-game: every struct you build for defense is one you don't build for extraction or power.

**Fortify when**:

- You have been raided recently
- Neighbors are aggressive (Killers, hostile guilds)
- You hold ore worth stealing (or a rich residual planet)
- Your power margin is thin — defense structs can be lower load than another extractor you cannot protect

**Scale when**:

- Home is secure and online with headroom
- You have surplus capacity (power, Alpha Matter)
- Pipeline stages are idle (second refine path, better power, fleet deterrent)
- Guild or team cover lets you take more risk — see [team-operations](../meta/team-operations.md)

---

## Economic Scaling

The virtuous cycle on **one** planet (and across a team of players):

1. **Stable mining** → ore into player inventory
2. **Immediate refine** → Alpha Matter (deny raiders)
3. **Alpha Matter** → capacity (reactors / generators / agreements)
4. **Capacity** → more structs without going offline
5. **Structs** → stronger economy and harder target

Break any link and the chain fails. Most often: power. Build capacity before load.

---

## Guild Strategy

Mid-game is when guilds matter.

**Join a guild when**:

- You have something to offer (ore, Alpha Matter, military support)
- You need something (protection, energy agreements, intelligence)
- The guild's goals align with yours

**Form a guild / run a team when**:

- You have a core of trusted players (or virtual players under Desktop)
- You want to coordinate attacks or defense
- Central Bank token mechanics offer strategic value

Multi-planet *coverage* is a **guild/team** property, not a solo one-account property.

---

## Defense Awareness

You are now worth attacking. Raiders look for:

- Unrefined ore on the player
- Fleet `away` or Command Ship offline (shields vulnerable)
- Isolated players without guild cover
- Rich but weak economies

Start thinking about Planetary Defense Cannons, Ore Bunkers (shield stack), and keeping the fleet on station while holding ore. See [defense.md](../../knowledge/mechanics/defense.md).

---

## Success Criteria

A strong mid-game position:

- One home planet with a reliable mine → refine → capacity loop
- Guild membership or clear alliance / team structure
- Power capacity exceeding load with headroom
- No unrefined ore sitting idle
- Awareness of neighboring threats; next-planet scouting ready before ore hits zero

You are not dominant yet. You are positioned. Late game decides the rest.

---

## See Also

- [Early Game](early-game.md) — How you got here
- [Late Game](late-game.md) — What comes next
- [Planet depletion](../situations/planet-depletion.md) — One-planet relocate protocol
- [Team operations](../meta/team-operations.md) — Multi-player force
- [Under attack](../situations/under-attack.md) — When raiders arrive
