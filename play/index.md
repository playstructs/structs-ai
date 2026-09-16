---
title: "Play: crisis and task router"
description: "The fastest route from what's happening to the exact skill you need. Crisis router, task router, and every situation card in one place."
permalink: /play/
---

# Play: crisis and task router

The fastest route from "what's happening" to the exact skill or card you need. Start at the
row that matches your situation.

This page is a dispatcher, not a tutorial. If you are new and nothing is on fire, use
[START](../START.md) and [play-structs](/skills/play-structs/SKILL.html) instead.
If something *is* on fire, pick the first matching row and follow it — do not browse.

Crisis rows outrank task rows. An offline player cannot mine their way out of a raid.

## Something is wrong right now (crisis router)

| Signal | Go to |
|--------|-------|
| I'm offline / a struct won't come online / load > capacity | [energy skill](/skills/structs-energy/SKILL.html) → [offline card](../playbooks/situations/offline.md) |
| I'm being attacked or raided | [under attack](../playbooks/situations/under-attack.md) · [combat skill](/skills/structs-combat/SKILL.html) |
| Mine/refine compute rejected `under_raid` | [production](/skills/structs-production/SKILL.html) · [under attack](../playbooks/situations/under-attack.md) — do not retry compute |
| I think my keys/agent are compromised | [suspected compromise](../playbooks/situations/suspected-compromise.md) · [agent security](../awareness/agent-security.md) |
| A build/mine/refine/raid compute failed or stalled | [failed compute](../playbooks/situations/failed-compute.md) · [async ops](../awareness/async-operations.md) |
| My planet is running out of ore | [planet depletion](../playbooks/situations/planet-depletion.md) · [production skill](/skills/structs-production/SKILL.html) |
| A transaction "worked" but nothing changed | [transaction issues](../troubleshooting/common-issues.md#transaction-issues) |
| An error string I don't recognize | [error index](errors.md) |
| Resources scarce / abundant | [resource-scarce](../playbooks/situations/resource-scarce.md) · [resource-rich](../playbooks/situations/resource-rich.md) |

## I want to do something (task router)

| Goal | Skill |
|------|-------|
| Just start playing (zero → mining) | [play-structs](/skills/play-structs/SKILL.html) |
| Create my player / claim a planet | [onboarding](/skills/structs-onboarding/SKILL.html) |
| Mine and refine Alpha Matter | [production](/skills/structs-production/SKILL.html) |
| Build / activate / move structs | [building](/skills/structs-building/SKILL.html) |
| Get more power / fix capacity | [energy](/skills/structs-energy/SKILL.html) |
| Attack, raid, or defend | [combat](/skills/structs-combat/SKILL.html) |
| Explore or move my fleet | [planets & fleet](/skills/structs-planets-fleet/SKILL.html) |
| Sell energy, trade, stake | [commerce](/skills/structs-commerce/SKILL.html) |
| Join / run a guild | [guild](/skills/structs-guild/SKILL.html) |
| Grant permissions / add a delegate agent | [permissions](/skills/structs-permissions/SKILL.html) |
| Scout a target or the galaxy | [intel](/skills/structs-intel/SKILL.html) |
| React to events in real time | [streaming](/skills/structs-streaming/SKILL.html) |

## I need to decide

- [Priority framework](../awareness/priority-framework.md) — Survival > Security > Economy > Expansion > Dominance
- [Game loop](../awareness/game-loop.md) — assess → plan → initiate → verify
- [Playbooks](../playbooks/) — phase strategy (early/mid/late) and situational responses
- [Playstyle presets](../strategy/presets/README.md) — set your goal weights

## Every situation card

See [`playbooks/situations/`](../playbooks/situations/) for the full set.
