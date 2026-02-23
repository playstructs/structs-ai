---
name: structs-guild
description: Manages guild operations in Structs. Covers creation, membership, settings, and Central Bank token operations. Use when working with guilds, managing tokens, or coordinating with other players.
---

# Structs Guild

## Procedure

1. **Discover guilds** — `structsd query structs guild-all` or `structsd query structs guild [id]`.
2. **Create guild** — Requires associated reactor. `structsd tx structs guild-create [endpoint] [substation-id] TX_FLAGS`.
3. **Membership** — Join: `guild-membership-join [guild-id] [infusion-id,infusion-id2,...]` (use `--player-id`, `--substation-id` if needed). Proxy join: `guild-membership-join-proxy [guild-id] [player-id] [infusion-ids]`. Invite flow: `guild-membership-invite [guild-id] [player-id]` → invitee runs `guild-membership-invite-approve` or `guild-membership-invite-deny`. Request flow: `guild-membership-request [guild-id]` → owner runs `guild-membership-request-approve` or `guild-membership-request-deny`. Kick: `guild-membership-kick [guild-id] [player-id]`.
4. **Settings** — `guild-update-endpoint`, `guild-update-entry-substation-id`, `guild-update-join-infusion-minimum`, `guild-update-join-infusion-minimum-by-invite`, `guild-update-join-infusion-minimum-by-request`, `guild-update-owner-id`.
5. **Central Bank** — Mint: `guild-bank-mint [guild-id] [amount] TX_FLAGS`. Redeem: `guild-bank-redeem [guild-id] [amount]`. Confiscate and burn: `guild-bank-confiscate-and-burn [guild-id] [address] [amount]`.

## Commands Reference

| Action | Command |
|--------|---------|
| Create | `structsd tx structs guild-create [endpoint] [substation-id]` |
| Join | `structsd tx structs guild-membership-join [guild-id] [infusion-ids]` |
| Join proxy | `structsd tx structs guild-membership-join-proxy [guild-id] [player-id] [infusion-ids]` |
| Invite | `structsd tx structs guild-membership-invite [guild-id] [player-id]` |
| Invite approve/deny | `structsd tx structs guild-membership-invite-approve/deny [guild-id]` |
| Invite revoke | `structsd tx structs guild-membership-invite-revoke [guild-id] [player-id]` |
| Request | `structsd tx structs guild-membership-request [guild-id]` |
| Request approve/deny | `structsd tx structs guild-membership-request-approve/deny [guild-id] [player-id]` |
| Request revoke | `structsd tx structs guild-membership-request-revoke [guild-id]` |
| Kick | `structsd tx structs guild-membership-kick [guild-id] [player-id]` |
| Update endpoint | `structsd tx structs guild-update-endpoint [guild-id] [endpoint]` |
| Update entry substation | `structsd tx structs guild-update-entry-substation-id [guild-id] [substation-id]` |
| Update infusion minimums | `structsd tx structs guild-update-join-infusion-minimum/minimum-by-invite/minimum-by-request [guild-id] [value]` |
| Update owner | `structsd tx structs guild-update-owner-id [guild-id] [new-owner-player-id]` |
| Bank mint | `structsd tx structs guild-bank-mint [guild-id] [amount]` |
| Bank redeem | `structsd tx structs guild-bank-redeem [guild-id] [amount]` |
| Bank confiscate | `structsd tx structs guild-bank-confiscate-and-burn [guild-id] [address] [amount]` |

**TX_FLAGS**: `--from [key-name] --gas auto --gas-adjustment 1.5 -y`

## Verification

- **Guild**: `structsd query structs guild [id]` — members, settings, owner.
- **Membership applications**: `structsd query structs guild-membership-application-all` or by ID.
- **Bank collateral**: `structsd query structs guild-bank-collateral-address [guild-id]` — verify reserves.

## Error Handling

- **Insufficient infusion**: Guild may require minimum infusion to join. Query guild for `joinInfusionMinimum`; meet requirement or get invite (bypass).
- **Already member**: Cannot join twice. Check `guild-membership-application` status.
- **Mint/redeem failed**: Verify guild has sufficient Alpha Matter collateral for mint; sufficient tokens for redeem.
- **Permission denied**: Only guild owner (or delegated address) can update settings, approve requests, mint/redeem.

## See Also

- `knowledge/economy/guild-banking.md` — Central Bank, collateral, token lifecycle
- `knowledge/economy/energy-market.md` — Provider guild access
- `knowledge/lore/factions.md` — Guild politics
