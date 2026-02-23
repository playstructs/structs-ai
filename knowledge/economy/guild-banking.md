# Guild Banking

**Purpose**: AI-readable reference for Structs Central Bank mechanics, token minting, collateral management, and guild token lifecycle.

---

## Overview

Guilds operate **Central Banks** that mint tokens backed by Alpha Matter collateral. This creates guild-specific economies—members can transact in tokens rather than raw Alpha Matter. The system is **trust-based**: token value derives from collateral ratio and guild credibility. Control of a Central Bank is control of a guild's economic engine.

---

## Core Mechanics

| Concept | Description |
|---------|-------------|
| **Collateral** | Alpha Matter held in reserve; backs token value |
| **Collateral ratio** | Tokens in circulation / Alpha Matter in reserve |
| **Token credibility** | Insufficient collateral undermines token value |
| **Minting** | Guild creates tokens against deposited Alpha Matter |

---

## Token Lifecycle

| Phase | Action | Notes |
|-------|--------|-------|
| **Minting** | Guild deposits Alpha Matter; mints tokens | Collateral must cover circulation |
| **Circulation** | Tokens used for payments, mercenaries, internal trade | Trust in guild determines acceptance |
| **Redemption** | Token holders redeem for Alpha Matter | Requires guild to hold sufficient reserve |

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

---

## See Also

- [energy-market.md](energy-market.md) — Energy agreements, provider economics
- [trading.md](trading.md) — Alpha Matter exchange, marketplace
- [valuation.md](valuation.md) — Asset valuation framework
- [factions.md](../lore/factions.md) — Guild vs. independent, Central Banks
- [alpha-matter.md](../lore/alpha-matter.md) — Token backing substance
- `schemas/entities.md` — Guild entity definition
