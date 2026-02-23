# Structs Market Data Structures

**Version**: 1.0.0
**Category**: economic
**Description**: Complete catalog of market data structures for AI agents. See `schemas/formats.md` for format specifications.

---

## Market Data Structures

### MarketPrice

- **ID**: `market-price`
- **Category**: economic
- **Description**: Current market price for a resource

| Field | Type | Format | Constraints | Description |
|-------|------|--------|-------------|-------------|
| resource | string | enum | `AlphaMatter`, `Energy`, `GuildToken` | Resource type being priced |
| price | number | -- | minimum: 0 | Current market price |
| unit | string | -- | -- | Price unit (e.g., 'grams per kW', 'kW per gram') |
| timestamp | string | date-time | -- | When this price was recorded |
| source | string | -- | -- | Source of price data (marketplace, agreement, etc.) |
| volume | number | -- | minimum: 0 | Trading volume for this price |

### MarketData

- **ID**: `market-data`
- **Category**: economic
- **Description**: Complete market data snapshot

| Field | Type | Format | Constraints | Description |
|-------|------|--------|-------------|-------------|
| resource | string | enum | `AlphaMatter`, `Energy`, `GuildToken` | Resource type |
| currentPrice | MarketPrice | ref | -- | Current market price (see MarketPrice above) |
| high24h | number | -- | minimum: 0 | 24-hour high price |
| low24h | number | -- | minimum: 0 | 24-hour low price |
| volume24h | number | -- | minimum: 0 | 24-hour trading volume |
| supply | number | -- | minimum: 0 | Current market supply |
| demand | number | -- | minimum: 0 | Current market demand |
| volatility | number | -- | minimum: 0 | Price volatility indicator |
| trend | string | enum | `rising`, `falling`, `stable` | Price trend direction |
| timestamp | string | date-time | -- | When this data was recorded |

### TradingHistory

- **ID**: `trading-history`
- **Category**: economic
- **Description**: Historical trading data

| Field | Type | Format | Constraints | Description |
|-------|------|--------|-------------|-------------|
| resource | string | enum | `AlphaMatter`, `Energy`, `GuildToken` | Resource type |
| trades | array | Trade[] | -- | List of trades (see Trade below) |
| period | string | enum | `1h`, `24h`, `7d`, `30d`, `all` | Time period for history |

### Trade

- **ID**: `trade`
- **Category**: economic
- **Description**: Individual trade record

| Field | Type | Format | Pattern | Description |
|-------|------|--------|---------|-------------|
| id | string | trade-id | -- | Unique trade identifier |
| resource | string | enum | `AlphaMatter`, `Energy`, `GuildToken` | Resource type traded |
| quantity | number | -- | minimum: 0 | Quantity traded |
| price | number | -- | minimum: 0 | Price per unit |
| total | number | -- | minimum: 0 | Total trade value |
| buyer | string | entity-id | `^1-[0-9]+$` | Buyer player ID. Type 1 = Player. |
| seller | string | entity-id | `^1-[0-9]+$` | Seller player ID. Type 1 = Player. |
| timestamp | string | date-time | -- | When trade occurred |
| type | string | enum | `marketplace`, `agreement`, `direct` | Trade type |

### MarketOrder

- **ID**: `market-order`
- **Category**: economic
- **Description**: Market buy or sell order

| Field | Type | Format | Constraints | Description |
|-------|------|--------|-------------|-------------|
| id | string | order-id | -- | Unique order identifier |
| type | string | enum | `buy`, `sell` | Order type |
| resource | string | enum | `AlphaMatter`, `Energy`, `GuildToken` | Resource type |
| quantity | number | -- | minimum: 0 | Order quantity |
| price | number | -- | minimum: 0 | Order price per unit |
| status | string | enum | `open`, `filled`, `cancelled`, `partial` | Order status |
| player | string | entity-id (`^1-[0-9]+$`) | -- | Player who placed order. Type 1 = Player. |
| created | string | date-time | -- | When order was created |
| filled | string | date-time | -- | When order was filled (if filled) |

### GuildTokenMarketData

- **ID**: `guild-token-market-data`
- **Category**: economic
- **Description**: Market data specific to guild tokens

| Field | Type | Format | Constraints | Description |
|-------|------|--------|-------------|-------------|
| guildId | string | entity-id | `^0-[0-9]+$` | Guild identifier. Type 0 = Guild. |
| tokenSymbol | string | -- | -- | Guild token symbol |
| currentPrice | number | -- | minimum: 0 | Current token price in Alpha Matter |
| marketCap | number | -- | minimum: 0 | Market capitalization (tokens in circulation x price) |
| tokensInCirculation | number | -- | minimum: 0 | Tokens currently in circulation |
| collateral | number | -- | minimum: 0 | Locked Alpha Matter collateral |
| collateralRatio | number | -- | minimum: 0 | Collateral ratio (collateral / tokens in circulation) |
| volume24h | number | -- | minimum: 0 | 24-hour trading volume |
| volatility | number | -- | minimum: 0 | Price volatility |
| trustRating | string | enum | `high`, `medium`, `low`, `unknown` | Trust rating based on guild reputation |
| warning | string | -- | -- | Warning about trust-based nature (no technical safeguards) |
| timestamp | string | date-time | -- | When this data was recorded |

### EnergyMarketData

- **ID**: `energy-market-data`
- **Category**: economic
- **Description**: Market data specific to energy trading

| Field | Type | Format | Constraints | Description |
|-------|------|--------|-------------|-------------|
| currentPrice | number | -- | minimum: 0 | Current energy price (Alpha Matter per kW) |
| supply | number | -- | minimum: 0 | Available energy supply (kW) |
| demand | number | -- | minimum: 0 | Energy demand (kW) |
| agreements | array | EnergyAgreementMarketData[] | -- | Available energy agreements |
| providers | array | entity-id[] | `^10-[0-9]+$` | Active energy provider IDs. Type 10 = Provider. |
| ephemeral | boolean | -- | default: true | Energy is ephemeral (must be consumed immediately) |
| timestamp | string | date-time | -- | When this data was recorded |

### EnergyAgreementMarketData

- **ID**: `energy-agreement-market-data`
- **Category**: economic
- **Description**: Market data for energy agreements

| Field | Type | Format | Pattern | Description |
|-------|------|--------|---------|-------------|
| agreementId | string | entity-id | `^11-[0-9]+$` | Agreement identifier. Type 11 = Agreement. |
| providerId | string | entity-id | `^10-[0-9]+$` | Provider identifier. Type 10 = Provider. |
| rate | number | -- | minimum: 0 | Energy rate (kW per unit) |
| price | number | -- | minimum: 0 | Price per unit |
| available | number | -- | minimum: 0 | Available energy (kW) |
| penaltyProtection | boolean | -- | default: true | Whether penalty protection is enabled |
| automatic | boolean | -- | default: true | Whether agreement is automatic/on-chain |
| status | string | enum | `active`, `inactive`, `full` | Agreement status |

---

## Market Operations

### queryMarketPrice

- **Description**: Query current market price for a resource
- **Parameter**: `resource` -- one of `AlphaMatter`, `Energy`, `GuildToken`
- **Response**: MarketPrice

### queryMarketData

- **Description**: Query complete market data for a resource
- **Parameter**: `resource` -- one of `AlphaMatter`, `Energy`, `GuildToken`
- **Response**: MarketData

### queryTradingHistory

- **Description**: Query trading history for a resource
- **Parameters**: `resource` (AlphaMatter/Energy/GuildToken), `period` (1h/24h/7d/30d/all)
- **Response**: TradingHistory

### placeOrder

- **Description**: Place a market order
- **Request**: MarketOrder
- **Response**: `orderId` (order-id format), `status` (placed/filled/rejected)

### queryGuildTokenMarket

- **Description**: Query guild token market data
- **Parameter**: `guildId` -- entity-id format `^0-[0-9]+$`
- **Response**: GuildTokenMarketData

### queryEnergyMarket

- **Description**: Query energy market data
- **Response**: EnergyMarketData

---

## Market Patterns

### Price Discovery

Prices are player-driven. Exact formula depends on market implementation.

**Factors**:
- Supply and demand
- Guild activities
- Combat outcomes
- Resource discoveries
- Player-driven trading

### Volatility

**Factors**:
- Supply changes
- Demand changes
- Market events
- Guild activities

### Trading Strategies

- Buy low, sell high
- Market timing
- Arbitrage opportunities
- Guild coordination

---

## Verification

| Field | Value |
|-------|-------|
| Verified Date | 2025-01-XX |
| Source | documentation |
| Notes | Market data structures based on economic documentation. Some market mechanics may need code verification. |
