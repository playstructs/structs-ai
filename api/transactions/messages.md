---
title: "structsd message catalog | Structs AI"
description: "Every live Msg RPC structsd accepts, with CLI verb and @type, verified against tx.proto v0.22.0."
permalink: /api/transactions/messages
---

# Message catalog (structsd)

**Verified against**: structsd `96cea3a` (v0.22.0) `proto/structs/structs/tx.proto` — 101 RPCs
**CLI names**: [generated/commands.md](https://github.com/playstructs/structs-ai/blob/main/generated/commands.md)

This is the write surface. [api/transactions/](./) is the **submit envelope**. There is no `MsgStructBuild` — builds are `struct-build-initiate` then complete (or `struct-build-compute`).

`@type` is `/structs.structs.MsgName`. Compute helpers (`*-compute`, `planet-raid-compute`) are CLI wrappers, not extra RPCs.

Skills: [play-structs](/skills/play-structs/SKILL.html) for the first path; pick the domain skill for the rest.

## Address and player

| Msg | CLI | Skill / notes |
|-----|-----|----------------|
| `MsgAddressRegister` | `address-register` | [permissions](/skills/structs-permissions/SKILL.html) |
| `MsgAddressRevoke` | `address-revoke` | |
| `MsgPlayerUpdatePrimaryAddress` | `player-update-primary-address` | Needs `PermAll` on the signer |
| `MsgPlayerUpdateGuildRank` | `player-update-guild-rank` | [guild](/skills/structs-guild/SKILL.html) |
| `MsgPlayerUpdateName` | `player-update-name` | [ugc-moderation](../../knowledge/mechanics/ugc-moderation.md) |
| `MsgPlayerUpdatePfp` | `player-update-pfp` | |
| `MsgPlayerUpdatePfpClientRenderAttributes` | `player-update-pfp-cr-attributes` | Owner-only; CLI abbreviates `cr` |
| `MsgPlayerSend` | `player-send` | Token send; `from` may be a vault address (needs `PermTokenTransfer` on the vault's owner) |
| `MsgVaultSend` | `vault-send` | `[owner-id] [recipient-owner-id] [amount]` — vault-to-vault transfer |

## Permissions

| Msg | CLI | Notes |
|-----|------|--------|
| `MsgPermissionGrantOnAddress` | `permission-grant-on-address` | [permissions.md](../../knowledge/mechanics/permissions.md) |
| `MsgPermissionGrantOnObject` | `permission-grant-on-object` | |
| `MsgPermissionRevokeOnAddress` | `permission-revoke-on-address` | |
| `MsgPermissionRevokeOnObject` | `permission-revoke-on-object` | |
| `MsgPermissionSetOnAddress` | `permission-set-on-address` | Replace mask |
| `MsgPermissionSetOnObject` | `permission-set-on-object` | |
| `MsgPermissionGuildRankSet` | `permission-guild-rank-set` | |
| `MsgPermissionGuildRankRevoke` | `permission-guild-rank-revoke` | |

## Guild

| Msg | CLI | Notes |
|-----|------|--------|
| `MsgGuildCreate` | `guild-create` | Paid founding: 2,000,000 ualpha from the founder's vault. `proof`, `nonce`, `founderPlayerId`, `address`, `proofPubKey` are deprecated fields — nonempty values are rejected (`legacy_charter_fields_not_supported`) |
| `MsgGuildBankMint` | `guild-bank-mint` | Spends the **guild vault**; [guild-banking](../../knowledge/economy/guild-banking.md) |
| `MsgGuildBankRedeem` | `guild-bank-redeem` | |
| `MsgGuildBankConvert` | `guild-bank-convert` | |
| `MsgGuildBankConvertToken` | `guild-bank-convert-token` | |
| `MsgGuildBankConfiscateAndBurn` | `guild-bank-confiscate-and-burn` | |
| `MsgGuildUpdateBankConvertInFee` | `guild-update-bank-convert-in-fee` | |
| `MsgGuildUpdateBankConvertOutFee` | `guild-update-bank-convert-out-fee` | |
| `MsgGuildUpdateOwnerId` | `guild-update-owner-id` | |
| `MsgGuildUpdateEntrySubstationId` | `guild-update-entry-substation-id` | New joins only |
| `MsgGuildUpdateEndpoint` | `guild-update-endpoint` | |
| `MsgGuildUpdatePrimaryReactor` | `guild-update-primary-reactor` | |
| `MsgGuildUpdateJoinInfusionMinimum` | `guild-update-join-infusion-minimum` | |
| `MsgGuildUpdateJoinInfusionMinimumBypassByInvite` | `guild-update-join-infusion-minimum-by-invite` | |
| `MsgGuildUpdateJoinInfusionMinimumBypassByRequest` | `guild-update-join-infusion-minimum-by-request` | |
| `MsgGuildUpdateEntryRank` | `guild-update-entry-rank` | |
| `MsgGuildUpdateRankPurchase` | `guild-update-rank-purchase` | `[guild-id] [base-price] [step-increase] [minimum-rank] [join-by-rank-purchase-enabled]`; prices in `uguild.<id>`; `PermAdmin` on guild |
| `MsgGuildRankPurchase` | `guild-rank-purchase` | `[guild-id] [target-rank] [max-price] [expected-rank]`; member buys a higher rank from their vault |
| `MsgGuildUpdateName` | `guild-update-name` | UGC |
| `MsgGuildUpdatePfp` | `guild-update-pfp` | |

### Membership

| Msg | CLI |
|-----|------|
| `MsgGuildMembershipInvite` | `guild-membership-invite` |
| `MsgGuildMembershipInviteApprove` | `guild-membership-invite-approve` |
| `MsgGuildMembershipInviteDeny` | `guild-membership-invite-deny` |
| `MsgGuildMembershipInviteRevoke` | `guild-membership-invite-revoke` |
| `MsgGuildMembershipJoin` | `guild-membership-join` |
| `MsgGuildMembershipJoinByRankPurchase` | `guild-membership-join-by-rank-purchase` |
| `MsgGuildMembershipJoinProxy` | `guild-membership-join-proxy` |
| `MsgGuildMembershipKick` | `guild-membership-kick` |
| `MsgGuildMembershipRequest` | `guild-membership-request` |
| `MsgGuildMembershipRequestApprove` | `guild-membership-request-approve` |
| `MsgGuildMembershipRequestDeny` | `guild-membership-request-deny` |
| `MsgGuildMembershipRequestRevoke` | `guild-membership-request-revoke` |

## Planet, fleet, combat

| Msg | CLI | Notes |
|-----|------|--------|
| `MsgPlanetExplore` | `planet-explore` | [onboarding](/skills/structs-onboarding/SKILL.html) |
| `MsgPlanetUpdateName` | `planet-update-name` | |
| `MsgPlanetRaidComplete` | `planet-raid-complete` | Prefer `planet-raid-compute`; [combat](/skills/structs-combat/SKILL.html) |
| `MsgFleetMove` | `fleet-move` | |
| `MsgStructAttack` | `struct-attack` | |

## Structs (build / status)

| Msg | CLI | Notes |
|-----|------|--------|
| `MsgStructBuildInitiate` | `struct-build-initiate` | [building](/skills/structs-building/SKILL.html) |
| `MsgStructBuildComplete` | `struct-build-complete` | Prefer `struct-build-compute` |
| `MsgStructBuildCancel` | `struct-build-cancel` | |
| `MsgStructTrash` | `struct-trash` | Irreversible |
| `MsgStructActivate` | `struct-activate` | |
| `MsgStructDeactivate` | `struct-deactivate` | |
| `MsgStructDeactivateBatch` | `struct-deactivate-batch` | ≤65 ids |
| `MsgStructDefenseSet` | `struct-defense-set` | |
| `MsgStructDefenseClear` | `struct-defense-clear` | |
| `MsgStructMove` | `struct-move` | Command Ship ambit |
| `MsgStructStealthActivate` | `struct-stealth-activate` | |
| `MsgStructStealthDeactivate` | `struct-stealth-deactivate` | |
| `MsgStructGeneratorInfuse` | `struct-generator-infuse` | |
| `MsgStructOreMinerComplete` | `struct-ore-mine-complete` | Prefer `struct-ore-mine-compute` |
| `MsgStructOreRefineryComplete` | `struct-ore-refine-complete` | Prefer `struct-ore-refine-compute` |

Commented out in proto (not live): `StructBuildCompleteAndStash`, `StructStorageStash`, `StructStorageRecall`.

## Energy, allocations, providers

| Msg | CLI | Notes |
|-----|------|--------|
| `MsgReactorInfuse` | `reactor-infuse` | `[reactor address] [amount]`; optional `ownerId` picks a player/guild vault (default: signer's own vault); `delegatorAddress` alone names a registered address that funds the stake from its own balance. [energy](/skills/structs-energy/SKILL.html) |
| `MsgReactorDefuse` | `reactor-defuse` | `[reactor address] [amount]`; cooldown; same `ownerId` / `delegatorAddress` semantics |
| `MsgReactorBeginMigration` | `reactor-begin-migration` | `[src] [dest] [amount]` |
| `MsgReactorCancelDefusion` | `reactor-cancel-defusion` | `[reactor address] [amount] [creation height]` |
| `MsgReactorRestart` | `reactor-restart` | After jail |
| `MsgAllocationCreate` | `allocation-create` | |
| `MsgAllocationUpdate` | `allocation-update` | Dynamic only |
| `MsgAllocationDelete` | `allocation-delete` | |
| `MsgAllocationTransfer` | `allocation-transfer` | `[allocation id] [new controller ownerId]` — player or guild |
| `MsgSubstationCreate` | `substation-create` | |
| `MsgSubstationDelete` | `substation-delete` | |
| `MsgSubstationAllocationConnect` | `substation-allocation-connect` | |
| `MsgSubstationAllocationDisconnect` | `substation-allocation-disconnect` | |
| `MsgSubstationPlayerConnect` | `substation-player-connect` | Needs `PermSubstationConnection` on player too |
| `MsgSubstationPlayerDisconnect` | `substation-player-disconnect` | |
| `MsgSubstationPlayerMigrate` | `substation-player-migrate` | |
| `MsgSubstationUpdateName` | `substation-update-name` | |
| `MsgSubstationUpdatePfp` | `substation-update-pfp` | |
| `MsgProviderCreate` | `provider-create` | Optional `ownerId` (guild-owned provider needs `PermSourceAllocation` on the guild). [commerce](/skills/structs-commerce/SKILL.html) |
| `MsgProviderDelete` | `provider-delete` | |
| `MsgProviderWithdrawBalance` | `provider-withdraw-balance` | |
| `MsgProviderUpdateCapacityMinimum` | `provider-update-capacity-minimum` | |
| `MsgProviderUpdateCapacityMaximum` | `provider-update-capacity-maximum` | |
| `MsgProviderUpdateDurationMinimum` | `provider-update-duration-minimum` | |
| `MsgProviderUpdateDurationMaximum` | `provider-update-duration-maximum` | |
| `MsgProviderUpdateAccessPolicy` | `provider-update-access-policy` | |

## Agreements

| Msg | CLI | Notes |
|-----|------|--------|
| `MsgAgreementOpen` | `agreement-open` | Collateral debited from the payer's vault; optional `ownerId` pays from another owner's vault (`PermTokenTransfer` on that owner) |
| `MsgAgreementClose` | `agreement-close` | |
| `MsgAgreementCapacityIncrease` | `agreement-capacity-increase` | |
| `MsgAgreementCapacityDecrease` | `agreement-capacity-decrease` | |
| `MsgAgreementDurationIncrease` | `agreement-duration-increase` | |

## Governance

| Msg | CLI | Notes |
|-----|------|--------|
| `MsgUpdateParams` | *(gov)* | Module params; not a player play action |

## Not in this catalog

- **CLI compute wrappers** — `struct-build-compute`, `struct-ore-mine-compute`, `struct-ore-refine-compute`, `planet-raid-compute`. See [conventions](/skills/conventions.html) and [generated/commands.md](https://github.com/playstructs/structs-ai/blob/main/generated/commands.md).
- **Stale docs** that still say 33 actions, list a `StructBuild` Msg, or describe a guild-charter compute/consent verb — ignore them; this page plus the generated CLI catalog win.
