---
title: "Error index: match the string to a fix"
description: "Match the error substring you're seeing to its fix. Fuller explanations live in the troubleshooting guides."
permalink: /play/errors
---

# Error index: match the string to a fix

Match the substring you see to the fix. Fuller explanations live in
[`troubleshooting/`](../troubleshooting/common-issues.md).

| Error substring | Meaning | Fix |
|-----------------|---------|-----|
| `account sequence mismatch` | Two txs from one key before the first landed | One tx per key at a time; wait ~6s (one block). Never run two `*-compute` jobs on one key. |
| `out of gas` | Missing/low gas, or estimate exceeded the meter | Always pass `--gas auto --gas-adjustment 1.5`. Free gameplay txs still need it. |
| `insufficient funds` / fee | Tx fell off the free path (mixed modules) | Keep a tx purely Structs; don't mix bank/gov messages. See [transactions](../knowledge/mechanics/transactions.md). |
| `unknown command` / `unknown flag` | Wrong CLI name or an ID parsed as a flag | Check the command name; put `--` before entity IDs (`... -- 4-5`). See [conventions](/skills/conventions.html). |
| `not online` / power / capacity | You're offline (load > capacity) | [Offline card](../playbooks/situations/offline.md). |
| `under_raid` | A visitor heads the planet fleet queue; mine/refine compute and complete reject | Do not retry compute. [Production](/skills/structs-production/SKILL.html) · [under attack](../playbooks/situations/under-attack.md). |
| `queue_full` | Visiting-fleet slot full (`1 + locationListExtra`, default extra `0` → one visitor) | Wait for a departure or send a fleet home. [fleet.md](../knowledge/mechanics/fleet.md). |
| `cannot defend` / `StructCannotDefend` | Target type has `canDefend: false` (planetary types, including Ore Bunker) | Assign a fleet-type defender only. [combat.md](../knowledge/mechanics/combat.md). |
| `is_owner` | Founder already owns a guild | Transfer that guild before founding another. [guild skill](/skills/structs-guild/SKILL.html). |
| `recipient_not_eligible` | `uguild.*` send to IBC, escrow, or an unregistered address | Send only to a registered player, the structs module, or a provider pool. [guild-banking](../knowledge/economy/guild-banking.md). |
| charter / `work-failure` / guild-create proof | Charter nonce died (anchor moved) or entitlement checks failed | Re-query `guild-charter`; restart compute against the new anchor. [hashing.md](../knowledge/mechanics/hashing.md). |
| primary-address / `PermAll` | `player-update-primary-address` signed by a limited key | Sign from an address that holds `PermAll`. [permissions](../knowledge/mechanics/permissions.md) · [agent security](../awareness/agent-security.md). |
| `not onStation` / fleet | Fleet must be on station to build/act there | Move the fleet and verify status before committing. |
| planner says `no ... can reach` / `unreachable`, but raw state says legal | `structs_strike` reach planning can false-negative on stale or normalized attacker/fleet state | Refresh the attacker, target, and fleets. Verify attacker Online, matching weapon reach, and actual planet co-location (resolve fleet `locationId` to its planet). If those live checks hold, use the ordinary chain attack preflight; the planner refusal is advisory. [combat skill](/skills/structs-combat/SKILL.html). |
| `no available slots` | Planet/ambit slot full | Free a slot or build elsewhere. See [building](../knowledge/mechanics/building.md). |
| shield / raid completion rejected | The live fleet/Command Ship raidability gate closed; this is not determined by the displayed shield number | Re-scout the on-station fleet and Command Ship state. [failed compute](../playbooks/situations/failed-compute.md). |
| broadcast ok but nothing changed | Broadcast ≠ success; a precondition failed | Query state to confirm. [transaction issues](../troubleshooting/common-issues.md#transaction-issues). |
| permission / unauthorized | Missing permission bit for the action | [permissions](../knowledge/mechanics/permissions.md); skill: [permissions](/skills/structs-permissions/SKILL.html). |

Not here? Search [`troubleshooting/common-issues.md`](../troubleshooting/common-issues.md),
[`troubleshooting/error-codes.md`](../troubleshooting/error-codes.md), and
[`troubleshooting/edge-cases.md`](../troubleshooting/edge-cases.md).
