---
title: Guild banking and Central Banks
description: "Central Bank mint, redeem, and convert: collateral ratios, uguild send limits, and how guild tokens differ from going it alone."
---

# Guild banking and Central Banks

**Purpose**: AI-readable reference for Structs Central Bank mechanics, token minting, collateral management, and guild token lifecycle.

---

## Overview

Guilds operate **Central Banks** that mint tokens backed by Alpha Matter collateral. This creates guild-specific economies—members can transact in tokens rather than raw Alpha Matter. The system is **trust-based**: token value derives from collateral ratio and guild credibility. Control of a Central Bank is control of a guild's economic engine.

---

## Core Mechanics

| Concept | Description |
|---------|-------------|
| **Collateral** | Alpha Matter held in the guild bank module account; backs token value |
| **Collateral ratio** | Live `collateral / supply`. Convert and redeem both read this ratio at action time |
| **Minting** | Guild-privileged: deposits Alpha and issues tokens at a chosen amount (`guild-bank-mint`) |
| **Convert** | Open path: anyone with `PermTokenTransfer` can turn `ualpha` into an existing `uguild.{id}` at the live ratio (`guild-bank-convert`). Convert-in fee stays in that guild's collateral. `minAmountToken` is the required slippage floor |
| **Convert-token** | Atomic token→alpha→other token (`guild-bank-convert-token`). Source guild keeps convert-out fee; target guild keeps convert-in fee |
| **Redemption** | Payout is `floor(amount * collateral / supply)` (`guild-bank-redeem`); CLI requires `min-amount-alpha` |
| **Send restriction** | `uguild.*` may only go to a registered player, the structs module account, or an indexed provider pool — **not IBC**, not an unregistered address (`recipient_not_eligible`) |

---

## Token Lifecycle

| Phase | Action | Notes |
|-------|--------|-------|
| **Minting** | Guild deposits Alpha; mints tokens | Privileged; ratio captured at action time |
| **Convert in** | Holder spends `ualpha` for tokens at the live ratio | Open market path; fee stays in collateral |
| **Circulation** | Tokens used for payments, agreements, internal trade | Trust in guild still determines acceptance |
| **Convert across** | `guild-bank-convert-token` redeems source then mints target | Both guilds keep their fees |
| **Redemption** | Token holders redeem for Alpha | `floor` against current collateral and supply; CLI requires `min-amount-alpha` slippage |

---

## Strategic Importance

| Factor | Implication |
|--------|-------------|
| Strong reserves | Guild can extend credit, pay mercenaries, fund operations in token |
| Raids on reserves | Drain Alpha Matter → weaken token backing → credibility collapse |
| Guild stability | Agents should evaluate collateral health when assessing guild viability |
| Independent operators | No token access unless trading for them; must use Alpha Matter |

---

## Guild vs. Independent Economics

| Aspect | Guild (with Central Bank) | Independent |
|--------|---------------------------|-------------|
| Token access | Yes | No (must trade) |
| Payment options | Alpha Matter or guild tokens | Alpha Matter only |
| Credit extension | Possible via token | No |
| Mercenary payment | Token or Alpha Matter | Alpha Matter only |

---

## Collateral Management

- **Reserve health**: Monitor Alpha Matter reserves vs. token circulation.
- **Raid vulnerability**: Alpha Matter in reserve is on-chain and not stealable; but raids on member planets can drain guild's ability to maintain reserves if members contribute from mined ore.
- **Redemption pressure**: Sudden redemptions can strain reserves; over-minting increases risk.

---

## Agent Considerations

- Evaluate guild stability before recommending token acceptance or guild membership.
- Collateral ratio is a key metric for guild economic health.
- Raids that drain guild Alpha Matter reserves weaken token backing.
- Mercenary contracts may specify payment in guild tokens; verify guild credibility.

**Security warning**: Guild tokens are trust-based. Guilds have full control over their Central Bank. There are no technical safeguards preventing a guild from revoking tokens or mismanaging collateral. Token revocation can be used as economic warfare -- but damages reputation.

> **HTTP bank read.** Mint, redeem, and convert are still chain transactions. Live collateral, supply, and ratio are on the guild webapp: `GET /api/guild-bank` (every guild) and `GET /api/guild-bank/{guild_id}/history?bucket=` (30-day mint/burn/infuse volume). Holder balances: `GET /api/inventory/denom/{denom}/page/{n}` or `GET /api/inventory/owner/{owner_type}/{owner_id}`. Format amounts from `GET /api/denom`. Charting map: [`api/webapp/analytics.md`](../../api/webapp/analytics.md). Chain `bank` queries remain authoritative if the indexer lags (`meta.height` vs `/api/block`).

Commands: [`structs-guild`](https://structs.ai/skills/structs-guild/SKILL) and [`structs-commerce`](https://structs.ai/skills/structs-commerce/SKILL).

---

## See Also

- [energy-market.md](energy-market.md) — Energy agreements, provider economics
- [trading.md](trading.md) — Alpha Matter exchange, marketplace
- [valuation.md](valuation.md) — Asset valuation framework
- [factions.md](../lore/factions.md) — Guild vs. independent, Central Banks
- [alpha-matter.md](../lore/alpha-matter.md) — Token backing substance
- `schemas/entities.md` — Guild entity definition
