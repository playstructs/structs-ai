---
title: "Guild skill: join, ranks, Central Bank"
meta_description: A guild gives you a reactor, a substation, a market, a token, and allies. Choosing one, joining, ranks, membership, and UGC moderation.
name: structs-guild
description: Guilds in Structs — choosing and joining one, ranks and rank-permissions, membership flows, settings, UGC moderation, paid founding (2,000,000 ualpha from the vault), rank sales, the guild vault, and the Central Bank (mint/redeem/convert). Use when picking a guild to join, creating a guild, managing members or ranks, moderating member identity, or running guild token operations.
level: core
domain: social
redirect_from:
  - /skills/structs-diplomacy/SKILL
  - /skills/structs-diplomacy/SKILL.html
  - /.cursor/skills/structs-diplomacy/SKILL
  - /.cursor/skills/structs-diplomacy/SKILL.html
---

# Guild skill: join, ranks, Central Bank

A guild is your faction: it gives you a reactor to infuse, a substation to draw power from, a market to sell into, a token to mint, and allies (or moderators). For a new player, **which guild you join is one of your most consequential early choices** — it shapes your power source, your economy, and who has your back. This skill covers choosing/joining, running a guild, ranks/permissions, identity moderation, and the Central Bank.

Conventions (TX_FLAGS, `--` rule, charge bar, one-tx-at-a-time) are in [`conventions.md`](/skills/conventions.html).

## When to use it

- New player deciding which guild to join (or whether to go solo).
- Creating or administering a guild.
- Managing members, ranks, or moderating member identity.
- Minting/redeeming guild tokens or managing Central Bank collateral.

## Decisions

**Choosing a guild (beginner)** — evaluate candidates on:
- **Reactor commission** — lower = more capacity per gram you infuse (`structsd query structs reactor [id]`).
- **Join requirements** — `joinInfusionMinimum` you must meet (or get an invite to bypass), or — if `joinByRankPurchaseEnabled` — a paid entry (`guild-membership-join-by-rank-purchase`) that needs no stake at all.
- **Treasury** — `structsd query structs vault [guild-id]` then `bank balances`: a guild with Alpha and its own token in the vault can fund members and back its token.
- **Activity & size** — `guild-all` then inspect members; an active guild means a working market and defenders.
- **Token economy** — a guild whose token is actually used (providers priced in it) makes your earnings liquid.
- **Politics** — see [`knowledge/lore/factions`](https://structs.ai/knowledge/lore/factions) and your standing-orders. Joining a guild at war inherits its enemies.

A guild is rarely a trap, but its moderators gain reach into your name/pfp while you're a member (see UGC below). If you dislike a policy, you can leave.

**Creating a guild (advanced)** is a **paid founding**: `guild-create -- [reactor-id] [endpoint] [entry-substation-id]` costs **2,000,000 ualpha from the founder's player vault** — 1,000,000 is burned and 1,000,000 becomes the new guild's Central Bank collateral, which mints **1,000,000 base units of `uguild.<new-id>` into the guild vault**. The named reactor's validator must exist and not be jailed; the entry substation (if given) must be one you can manage connections on. A founder who **owns** a guild must transfer it first (`is_owner`); founding leaves your current guild if you are only a member. There is no proof-of-work and no third-party path; a `guild-create` that carries any legacy proof field is rejected (`legacy_charter_fields_not_supported`). This is Tier 2 — 1M Alpha is annihilated and the rest is locked as collateral.

## Rank system

Numeric ranks, **lower number = higher privilege**:

| Rank | Meaning |
|------|---------|
| 1 | Maximum (guild creator) |
| 2–100 | Custom ranks assigned by leadership |
| 101 | Default on join |
| 0 | Unset |

Assigning ranks (`player-update-guild-rank`) is an administration action: the guild owner, or a player holding a **direct** `PermAdmin` grant on the guild, with `PermAdmin` on the **signing key** — a rank register never confers it, so a purchased or assigned rank gives access but not the power to hand out free ranks. Kicking is rank-relative instead: a member can only kick members whose rank is strictly **worse** (higher number) than their own. Rank-permissions (granting a permission to everyone at/above a rank) are the scalable way to delegate — see [`structs-permissions`](/skills/structs-permissions/SKILL.html).

### Selling ranks (optional revenue)

A guild may put ranks up for sale in its own token. Admins configure the curve with `guild-update-rank-purchase -- [guild-id] [base-price] [step-increase] [minimum-rank] [join-by-rank-purchase-enabled]` (`PermAdmin` on the guild). `minimum-rank` is the best rank money can buy (0 disables sales entirely); the n-th step above the entry rank costs `base-price + (n−1) × step-increase` in `uguild.<id>` base units, and a buyer pays the difference between the cumulative price of their target and of their current rank. Payment moves from the buyer's vault to the guild vault. Members buy with `guild-rank-purchase -- [guild-id] [target-rank] [max-price] [expected-rank]` (`expected-rank` is their current rank; `rank_changed` if it moved). If `join-by-rank-purchase-enabled` is true, non-members can enter directly at a purchased rank with `guild-membership-join-by-rank-purchase -- [guild-id] [target-rank] [max-price]` (pass `--expected-guild-id` with your current guild id, or leave it empty if you have none), skipping the infusion minimum; they are migrated to the entry substation like any other joiner. Every sale emits `EventGuildRankPurchase`. Selling your top ranks hands out their rank-permissions — set `minimum-rank` with that in mind.

## Procedure

### Join

1. Discover: `structsd query structs guild-all`, then `guild [id]` and `reactor [id]` for the candidates.
2. Meet the infusion minimum (or secure an invite). Join:
   ```
   structsd tx structs guild-membership-join TX_FLAGS -- [guild-id] [infusion-id,...]
   ```
   You get the default entry rank (101). Flows: **invite** (`guild-membership-invite` → invitee `...-invite-approve`/`-deny`), **request** (`guild-membership-request` → owner `...-request-approve`/`-deny`), **proxy** (a guild signs you in: `guild-membership-join-proxy -- [address] [proof-pubkey] [proof-signature]`, with optional `--substation-id`, `--player-name`, `--player-pfp`, `--player-pfp-client-render-attributes`), **paid** (`guild-membership-join-by-rank-purchase`, above). Permission gates: a join that must migrate your stake into the guild's reactor needs `PermTokenMigrate` on your signing key; a join that bypasses the minimum via invite/request needs `PermGuildMembership` on the key; a proxy join for an **already-registered** address needs `PermGuildMembership` on that address. Joins and migrations into a guild whose entry substation is closing (`deletion_pending`) are refused.

### Administer

- **Ranks**: `player-update-guild-rank TX_FLAGS -- [player-id] [rank]` (owner or direct `PermAdmin` grant on the guild, and PermAdmin on your signing key; the target must already be a member — add `--guild-id` if you administer a guild you are not a member of); `guild-update-entry-rank TX_FLAGS -- [rank]` (same admin check; a member cannot set the entry rank better than their own); `guild-update-rank-purchase` to sell ranks (above).
- **Membership**: `guild-membership-kick -- [player-id]` (the guild is implicit in the target player). Kicking strips rank-derived access but **preserves direct permission grants** the player holds on guild objects — revoke those explicitly (`permission-revoke-on-object`) if the departure is hostile. Invite/request approve/deny/revoke as above.
- **Settings**: `guild-update-endpoint`, `guild-update-entry-substation-id`, `guild-update-join-infusion-minimum` (+ `-by-invite`/`-by-request`; unknown bypass-level values are denied), `guild-update-owner-id` (Tier 2 — transfers the guild and **clears the outgoing owner's guild membership row**: the old owner is no longer a member unless re-admitted). Invite/request **approve** and **accept** require a pending application — they do not create one.
- **Treasury**: the guild vault (`structsd query structs vault [guild-id]`) holds founding tokens, mint output and rank-sale revenue. Spend it with `vault-send -- [guild-id] [recipient-owner-id] [amount]` or `player-send -- [guild-vault-address] [to-address] [amount]` (`PermTokenTransfer` on the guild), stake it with `reactor-infuse` plus the `--owner-id` flag set to the guild id, or buy capacity with `agreement-open` plus the same flag.
- **Founding**: `guild-create -- [reactor-id] [endpoint] [entry-substation-id]` — 2,000,000 ualpha from your vault, see Decisions.

### UGC moderation

Structs has no global moderator — each guild sets its own name/pfp standards for member-owned objects, and the chain emits an audit event on every override. Grant moderation by rank (recommended) or per player:

```bash
# Members at rank 5 or better can moderate guild-mate UGC
structsd tx structs permission-guild-rank-set TX_FLAGS -- [guild-id] [guild-id] 16777216 5
# Or a single moderator on the guild object
structsd tx structs permission-grant-on-object TX_FLAGS -- [guild-id] [moderator-player-id] 16777216
```

Perform a moderation: `player-update-name`/`player-update-pfp`/`planet-update-name`/`substation-update-name`/`substation-update-pfp TX_FLAGS -- [target-id] "value"`. When the actor isn't the owner, the chain emits `ugc_moderated` (actor, target, field, old/new) — audit it. Note `pfpClientRenderAttributes` is **owner-only** and **not** guild-moderatable. Full philosophy + validation: [`knowledge/mechanics/ugc-moderation`](https://structs.ai/knowledge/mechanics/ugc-moderation).

### Central Bank (mint / redeem / convert)

- **Mint** tokens against Alpha collateral: `guild-bank-mint TX_FLAGS -- [alpha-amount] [token-amount]` (`--guild-id` to name a guild other than your own; raw integers; ratio captured at action time). Guild-privileged (`PermGuildTokenMint`, plus `PermTokenTransfer` on the guild vault). The Alpha collateral is taken **from the guild vault** and the minted tokens are deposited **in the guild vault** — not to the signer. Distribute with `vault-send`.
- **Redeem** tokens for Alpha: `guild-bank-redeem TX_FLAGS -- [amount]uguild.[guild-id] [min-amount-alpha]` — coin string plus Alpha slippage floor. Tokens are burned from your player vault and the Alpha arrives in your player vault. Payout is `floor(amount * collateral / supply)` but still rejected if that payout is below `min-amount-alpha`.
- **Convert** ualpha into an existing guild token at the live collateral ratio: `guild-bank-convert TX_FLAGS -- [guild-id] [alpha-amount] [min-amount-token]`. Debits your player vault's Alpha and credits the token to the same vault. Needs `PermTokenTransfer` on the signer. Convert-in fee stays in collateral. `min-amount-token` is the slippage floor.
- **Convert token → token**: `guild-bank-convert-token TX_FLAGS -- [amount]uguild.[source-id] [target-guild-id] [min-amount-token]` — redeems the source then converts into the target in one tx; both guilds keep their fees.
- **Confiscate & burn** (Tier 2 act of war, audited forever): `guild-bank-confiscate-and-burn TX_FLAGS -- [amount]uguild.[guild-id] [address]` — token amount first, then the address it is taken from. The destination of a `uguild.*` send must be a registered player, the structs module, or an indexed provider pool — **not IBC**.

Mint/redeem are Tier 1 within your standing-order caps, Tier 2 above. Convert is the open market path. Economics: [`knowledge/economy/guild-banking`](https://structs.ai/knowledge/economy/guild-banking).

## Commands reference

| Action | Command |
|--------|---------|
| Create (2,000,000 ualpha from vault, Tier 2) | `structsd tx structs guild-create TX_FLAGS -- [reactor-id] [endpoint] [entry-substation-id]` |
| Join / proxy / paid join | `structsd tx structs guild-membership-join \| guild-membership-join-proxy \| guild-membership-join-by-rank-purchase TX_FLAGS -- ...` |
| Rank sales (admin) / buy rank | `structsd tx structs guild-update-rank-purchase TX_FLAGS -- [guild-id] [base-price] [step-increase] [minimum-rank] [enabled]` / `guild-rank-purchase TX_FLAGS -- [guild-id] [target-rank] [max-price] [expected-rank]` |
| Treasury transfer | `structsd tx structs vault-send TX_FLAGS -- [guild-id] [recipient-owner-id] [amount]` |
| Invite / request (+approve/deny/revoke) | `structsd tx structs guild-membership-invite \| -request \| ...-approve \| ...-deny TX_FLAGS -- ...` |
| Kick | `structsd tx structs guild-membership-kick TX_FLAGS -- [player-id]` |
| Update rank / entry rank | `structsd tx structs player-update-guild-rank \| guild-update-entry-rank TX_FLAGS -- ...` |
| Settings | `structsd tx structs guild-update-endpoint \| -entry-substation-id \| -join-infusion-minimum \| -owner-id TX_FLAGS -- ...` |
| Guild UGC | `structsd tx structs guild-update-name \| guild-update-pfp TX_FLAGS -- [guild-id] [value]` |
| Moderate member/object | `structsd tx structs player-update-name \| ...-pfp \| planet-update-name \| substation-update-name \| -pfp TX_FLAGS -- [target-id] [value]` |
| Bank mint / redeem / convert / confiscate | `structsd tx structs guild-bank-mint \| guild-bank-redeem \| guild-bank-convert \| guild-bank-convert-token \| guild-bank-confiscate-and-burn TX_FLAGS -- ...` |
| Guild rank permission set/revoke | `structsd tx structs permission-guild-rank-set \| permission-guild-rank-revoke TX_FLAGS -- [object-id] [guild-id] [permission] [rank]` |

`TX_FLAGS` per [`conventions.md`](/skills/conventions.html). **Requires** [`structsd`](/skills/structsd-install/SKILL.html) on PATH and a signing key.

## Verification

- `structsd query structs guild [id]` — members, settings, owner, `rankPurchase*` fields, `joinByRankPurchaseEnabled`.
- `structsd query structs vault [guild-id]` + `structsd query bank balances [address]` — treasury.
- `guild-membership-application-all` — pending invites/requests.
- `guild-bank-collateral-address [guild-id]` — reserves.
- `guild-rank-permission-by-object-and-guild [object-id] [guild-id]` — rank-based access.

## Errors

- **Insufficient infusion** — meet `joinInfusionMinimum`, get an invite (bypasses it), or buy in if the guild sells entry.
- **is_owner** — you own a guild; transfer it before founding another.
- **Affordability on `guild_create` (`2000000ualpha`)** — the founder's **vault** holds less than 2,000,000 ualpha; fund it from your key.
- **`legacy_charter_fields_not_supported`** — the create message carried proof/nonce/consent fields; send the three-argument form only.
- **`validator_jailed`** — the named reactor's validator is jailed; pick another reactor or wait for unjail.
- **`rank_purchase_disabled` / `rank_purchase_admission_disabled` / `outside_purchase_range`** — the guild does not sell that rank (or does not sell entry); check its `rankPurchaseMinimumRank`.
- **`rank_changed` / `membership_changed` / `quoted_price_exceeded`** — your rank, guild, or the price moved since you quoted; re-read and resubmit.
- **`deletion_pending`** — the guild's entry substation is being deleted; the guild must repoint it before anyone can join.
- **under_raid** — not a guild error; see production.
- **Already member** — founding leaves your current guild if you are only a member; you cannot join twice.
- **Invite/request approve with no pending application** — membership approval requires an existing application.
- **Mint/redeem/convert failed** — insufficient Alpha/tokens, or `min-amount-token` slippage missed.
- **recipient_not_eligible** — `uguild.*` cannot go to IBC escrow or an unregistered address.
- **Permission denied / rank too low** — need PermAdmin or strictly-better rank; entry rank can't exceed your own.

## See also

- [knowledge/economy/guild-banking](https://structs.ai/knowledge/economy/guild-banking) — Central Bank, collateral, token lifecycle
- [knowledge/mechanics/permissions](https://structs.ai/knowledge/mechanics/permissions) — 25-bit values, guild rank permissions
- [knowledge/mechanics/ugc-moderation](https://structs.ai/knowledge/mechanics/ugc-moderation) — name/pfp moderation & validation
- [knowledge/lore/factions](https://structs.ai/knowledge/lore/factions) — guild politics
- [playbooks/situations/guild-war](https://structs.ai/playbooks/situations/guild-war) — coordinated conflict; [structs-permissions](/skills/structs-permissions/SKILL.html) — delegating authority
