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
| `insufficient funds` naming a `structs1…` address you don't recognise | Your **vault** is short, not your key — infusion, generator fuel, agreements, Central Bank and rank purchases all pay from the vault | Check `playerInventory.rocks`; fund the vault with `player-send` to `query structs vault [your-id]`. [energy.md — Vaults](../knowledge/mechanics/energy.md#vaults-where-game-alpha-lives). |
| `insufficient funds` / fee on a free action | Tx fell off the free path (mixed modules) | Keep a tx purely Structs; don't mix bank/gov messages. See [transactions](../knowledge/mechanics/transactions.md). |
| `address is not registered as a player` (ante 2010) | Fresh key tried `reactor-infuse` or another gameplay message before a player exists | Bootstrap with `structsd tx staking delegate` or a guild proxy signup. [onboarding](/skills/structs-onboarding/SKILL.html). |
| `already used their charge action this block` (2021) / `multiple charge-consuming messages` (2020) | One charge-consuming message per player per block/tx | Space build-initiates, trash, activate and attacks one block apart. [building.md](../knowledge/mechanics/building.md#charge-accumulation). |
| `exceeded per-block message cap` (2040) / `CheckTx free-tx cap` (2041) | 40 messages per player per block, 5 queued free txs per address | Spread submissions across blocks; a stuck mempool clears next block. [transactions](../knowledge/mechanics/transactions.md). |
| `reactor stake cap exceeded` (1613) | Reactor already holds ≥30% of bonded stake | Pick another reactor; check `reactor-stake-share` headroom first. [energy skill](/skills/structs-energy/SKILL.html). |
| `vault_owner_mismatch` | Both `--owner-id` and `--delegator-address` given, and the address is not that owner's vault | Drop one flag; default is your own vault. |
| `unsupported_supply` | Allocation/substation admission found a cycle, an overloaded or jailed ancestor, or >2,048 upstream objects | Source from a healthier supply; simplify the chain. [energy.md](../knowledge/mechanics/energy.md). |
| `deletion_pending` | Substation is mid-delete; new connections refused | Connect to another substation (or the guild's new entry substation). |
| `expiration_height_full` | 256 agreements already expire at that end height | Shift `duration` by a block. [commerce skill](/skills/structs-commerce/SKILL.html). |
| `duplicate_infusion` / wrong coin on generator | `struct-generator-infuse` takes exactly one coin (`ualpha` or `alpha`) | Pass a single denomination. |
| `primary_full_access_required` | Tried to narrow the primary address below `PermAll` | Register a second key for the limited role instead. [permissions](/skills/structs-permissions/SKILL.html). |
| `self_defense` | Struct set to defend itself | Pick a different, co-located fleet struct. |
| `unknown command` / `unknown flag` | Wrong CLI name or an ID parsed as a flag | Check the command name; put `--` before entity IDs (`... -- 4-5`). See [conventions](/skills/conventions.html). |
| `not online` / power / capacity | You're offline (load > capacity) | [Offline card](../playbooks/situations/offline.md). |
| `under_raid` | A visitor heads the planet fleet queue; mine/refine compute and complete reject | Do not retry compute. [Production](/skills/structs-production/SKILL.html) · [under attack](../playbooks/situations/under-attack.md). |
| `queue_full` | Visiting-fleet slot full (`1 + locationListExtra`, default extra `0` → one visitor) | Wait for a departure or send a fleet home. [fleet.md](../knowledge/mechanics/fleet.md). |
| `cannot defend` / `StructCannotDefend` | Target type has `canDefend: false` (planetary types, including Ore Bunker) | Assign a fleet-type defender only. [combat.md](../knowledge/mechanics/combat.md). |
| `is_owner` | Founder already owns a guild | Transfer that guild before founding another. [guild skill](/skills/structs-guild/SKILL.html). |
| `recipient_not_eligible` | `uguild.*` send to IBC, escrow, or an unregistered address | Send only to a registered player, a player/guild vault, the structs module, or a provider pool. [guild-banking](../knowledge/economy/guild-banking.md). |
| `legacy_charter_fields_not_supported` | `guild-create` sent with proof/nonce/founder fields | Send only `[reactor id] [endpoint] [substation id]`; founding costs 2,000,000 ualpha from your vault. [guild skill](/skills/structs-guild/SKILL.html). |
| `rank_purchase_disabled` / `outside_purchase_range` / `quoted_price_exceeded` / `rank_changed` / `membership_changed` / `rank_purchase_admission_disabled` | Rank-sale guard tripped | Re-read `guild [id]` (`rankPurchase*`, your current rank), raise `max-price`, or pick a rank in range. [guild skill](/skills/structs-guild/SKILL.html). |
| `work-failure` | A `*-compute` hash was rejected at submit (clock moved, raid pause, someone else completed) | Check object state and relaunch. [failed compute](../playbooks/situations/failed-compute.md). |
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
