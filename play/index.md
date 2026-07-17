---
title: Play
permalink: /play/
---

# Play

The fastest route from "what's happening" to the exact skill or card you need. Start at the
row that matches your situation.

## Something is wrong right now (crisis router)

| Signal | Go to |
|--------|-------|
| I'm offline / a struct won't come online / load > capacity | [energy skill](../.cursor/skills/structs-energy/SKILL.md) → [offline card](../playbooks/situations/offline.md) |
| I'm being attacked or raided | [under attack](../playbooks/situations/under-attack.md) · [combat skill](../.cursor/skills/structs-combat/SKILL.md) |
| I think my keys/agent are compromised | [suspected compromise](../playbooks/situations/suspected-compromise.md) · [agent security](../awareness/agent-security.md) |
| A build/mine/refine/raid compute failed or stalled | [failed compute](../playbooks/situations/failed-compute.md) · [async ops](../awareness/async-operations.md) |
| My planet is running out of ore | [planet depletion](../playbooks/situations/planet-depletion.md) · [production skill](../.cursor/skills/structs-production/SKILL.md) |
| A transaction "worked" but nothing changed | [transaction issues](../troubleshooting/common-issues.md#transaction-issues) |
| An error string I don't recognize | [error index](errors.md) |
| Resources scarce / abundant | [resource-scarce](../playbooks/situations/resource-scarce.md) · [resource-rich](../playbooks/situations/resource-rich.md) |

## I want to do something (task router)

| Goal | Skill |
|------|-------|
| Just start playing (zero → mining) | [play-structs](../.cursor/skills/play-structs/SKILL.md) |
| Create my player / claim a planet | [onboarding](../.cursor/skills/structs-onboarding/SKILL.md) |
| Mine and refine Alpha Matter | [production](../.cursor/skills/structs-production/SKILL.md) |
| Build / activate / move structs | [building](../.cursor/skills/structs-building/SKILL.md) |
| Get more power / fix capacity | [energy](../.cursor/skills/structs-energy/SKILL.md) |
| Attack, raid, or defend | [combat](../.cursor/skills/structs-combat/SKILL.md) |
| Explore or move my fleet | [planets & fleet](../.cursor/skills/structs-planets-fleet/SKILL.md) |
| Sell energy, trade, stake | [commerce](../.cursor/skills/structs-commerce/SKILL.md) |
| Join / run a guild | [guild](../.cursor/skills/structs-guild/SKILL.md) |
| Grant permissions / add a delegate agent | [permissions](../.cursor/skills/structs-permissions/SKILL.md) |
| Scout a target or the galaxy | [intel](../.cursor/skills/structs-intel/SKILL.md) |
| React to events in real time | [streaming](../.cursor/skills/structs-streaming/SKILL.md) |

## I need to decide

- [Priority framework](../awareness/priority-framework.md) — Survival > Security > Economy > Expansion > Dominance
- [Game loop](../awareness/game-loop.md) — assess → plan → initiate → verify
- [Playbooks](../playbooks/) — phase strategy (early/mid/late) and situational responses
- [Playstyle presets](../strategy/presets/README.md) — set your goal weights

## Every situation card

See [`playbooks/situations/`](../playbooks/situations/) for the full set.
