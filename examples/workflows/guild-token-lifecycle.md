---
title: "Guild token lifecycle: mint, convert, redeem"
description: A worked economic workflow covering mint, convert, redeem, and the uguild send restriction end to end.
---

# Guild Token Lifecycle Workflow

**ID**: guild-token-lifecycle
**Category**: Economic

---

## Prerequisites

- Player online, with a signing key that holds `PermTokenTransfer`
- Mint/confiscate need guild bank privileges (`PermGuildTokenMint` / `PermGuildTokenBurn`)
- Alpha Matter on the signing address for mint or convert-in
- Target guild already exists (convert cannot create a denom)

## Security Warning

Guild tokens are trust-based. Guilds control mint, redeem policy, and confiscate-and-burn. Convert is the open market path; mint/redeem remain guild-privileged.

## Steps

### 1. Read collateral and supply

Guild webapp (session cookie): `GET /api/guild-bank` for every guild's `collateral`, `supply`, and `ratio`; `GET /api/inventory/denom/uguild.{guild-id}/page/1` for holders. See [`api/webapp/analytics.md`](../../api/webapp/analytics.md).

Chain fallback (authoritative if the indexer lags):

```
structsd query structs guild-bank-collateral-address [guild-id]
structsd query bank balances [collateral-address]
structsd query bank denom-owners uguild.[guild-id]
```

### 2. Mint (guild-privileged)

```
structsd tx structs guild-bank-mint TX_FLAGS -- [alpha-amount] [token-amount]
```

Ratio is captured at action time. Signer's guild is implicit.

### 3. Convert ualpha → token (open path)

Anyone with `PermTokenTransfer` can buy an existing guild token at the live collateral ratio. Convert-in fee stays in that guild's collateral. `min-amount-token` is the required slippage floor:

```
structsd tx structs guild-bank-convert TX_FLAGS -- [guild-id] [alpha-amount] [min-amount-token]
```

### 4. Convert token → token

Atomic source redeem then target convert. Both guilds keep their fees:

```
structsd tx structs guild-bank-convert-token TX_FLAGS -- [amount]uguild.[source-id] [target-guild-id] [min-amount-token]
```

### 5. Redeem for Alpha

Payout is `floor(amount * collateral / supply)` and must clear `min-amount-alpha`:

```
structsd tx structs guild-bank-redeem TX_FLAGS -- [amount]uguild.[guild-id] [min-amount-alpha]
```

### 6. Send restriction

`uguild.*` may only go to a registered player, the structs module account, or an indexed provider pool. IBC and unregistered addresses reject with `recipient_not_eligible`. Prefer `player-send` between registered players.

### 7. Confiscate and burn (Tier 2)

```
structsd tx structs guild-bank-confiscate-and-burn TX_FLAGS -- [amount]uguild.[guild-id] [address]
```

Audited forever. Damages reputation.

## Risks

| Risk | Result | Prevention |
|------|--------|------------|
| Over-minting | Thin collateral, convert/redeem slip | Watch collateral vs supply before mint |
| Slippage miss | Convert rejected | Set `min-amount-token` from the live ratio |
| Send to IBC / raw address | `recipient_not_eligible` | Send only to registered players or provider pools |
| Confiscate-and-burn | Holder balance gone, reputation hit | Rank revocation is usually enough |

`TX_FLAGS` per [`conventions.md`](/skills/conventions.html). Canonical economics: [`knowledge/economy/guild-banking.md`](../../knowledge/economy/guild-banking.md).
