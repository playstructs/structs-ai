# Trading

**Purpose**: AI-readable reference for Structs marketplace mechanics, Alpha Matter exchange, tradeable assets, and on-chain precision.

---

## Overview

Trading enables resource exchange between players. **Alpha Matter** is the primary tradeable asset—refined, on-chain, and non-stealable. Energy agreements provide another tradeable dimension (capacity subscriptions). A marketplace exists for various assets.

---

## Alpha Matter

| Property | Value |
|----------|-------|
| Unit | grams |
| On-chain precision | 1 gram = 1,000,000 micrograms (ualpha) |
| Stealable | No (refined Alpha Matter is secure) |
| Uses | Energy production, trading, guild collateral |

**Format**: Amounts in API responses use micrograms (string integer). Example: `"1000000"` = 1 gram.

---

## Tradeable Assets

| Asset | Tradeable | Notes |
|-------|-----------|-------|
| Alpha Matter | Yes | Primary medium of exchange |
| Energy (capacity) | Yes | Via energy agreements; see [energy-market.md](energy-market.md) |
| Guild tokens | Yes | Backed by collateral; trust-dependent |
| Ore (unrefined) | Indirect | Mined then refined; ore itself not directly traded on marketplace |

---

## Marketplace

- Marketplace exists for various assets.
- Alpha Matter exchange is core.
- Energy agreements can be set up between providers and consumers.
- Payment for mercenary services: typically Alpha Matter or guild tokens.

---

## On-Chain Precision

| Unit | Micrograms | Use Case |
|------|------------|----------|
| 1 gram | 1,000,000 | Standard unit |
| 0.000001 g | 1 | Minimum precision |

All Alpha Matter amounts use integer micrograms for on-chain consistency. Avoid floating-point; use string representation for large values.

---

## See Also

- [energy-market.md](energy-market.md) — Energy agreements as tradeable capacity
- [guild-banking.md](guild-banking.md) — Guild tokens in trade
- [valuation.md](valuation.md) — Valuing tradeable assets
- [resources.md](../mechanics/resources.md) — Alpha Matter lifecycle
- `schemas/formats.md` — Micrograms format specification
