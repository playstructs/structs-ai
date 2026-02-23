# Structs Trading Operation Schemas

**Version**: 1.0.0
**Category**: economic
**Description**: Complete catalog of trading operations for AI agents. See `schemas/formats.md` for format specifications.

---

## Trading Operations

### TradeAlphaMatter

- **ID**: `trade-alpha-matter`
- **Name**: Trade Alpha Matter
- **Category**: economic
- **Action**: `MsgTradeAlphaMatter`
- **Message Type**: `/structs.structs.MsgTradeAlphaMatter`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Trade Alpha Matter on the marketplace

**Required Fields**: `creator`, `resource`, `quantity`, `price`, `type`
**Optional Fields**: `orderId`

| Field | Type | Format | Pattern | Description |
|-------|------|--------|---------|-------------|
| creator | string | entity-id | `^1-[0-9]+$` | Player initiating trade. Type 1 = Player. |
| resource | string | enum | `AlphaMatter` | Resource being traded |
| quantity | number | -- | minimum: 0 | Quantity in grams (will be converted to micrograms) |
| quantityMicrograms | string | -- | `^[0-9]+$` | Quantity in micrograms (blockchain format) |
| price | number | -- | minimum: 0 | Price per unit |
| type | string | enum | `buy`, `sell` | Trade type |
| orderId | string | order-id | -- | Order ID if matching existing order |

**Requirements**:

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| sufficientResources | true |
| validMarket | true |

**Security**: Alpha Matter cannot be stolen once refined.

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgTradeAlphaMatter",
        "creator": "structs1...",
        "resource": "AlphaMatter",
        "quantityMicrograms": "100000000",
        "price": "0.001",
        "type": "sell"
      }
    ]
  }
}
```

### TradeEnergy

- **ID**: `trade-energy`
- **Name**: Trade Energy
- **Category**: economic
- **Action**: `MsgTradeEnergy`
- **Message Type**: `/structs.structs.MsgTradeEnergy`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Trade energy through marketplace or agreements

**Required Fields**: `creator`, `quantity`, `price`, `type`
**Optional Fields**: `agreementId`

| Field | Type | Format | Pattern | Description |
|-------|------|--------|---------|-------------|
| creator | string | entity-id | `^1-[0-9]+$` | Player initiating trade. Type 1 = Player. |
| quantity | number | -- | minimum: 0 | Energy quantity in kW |
| price | number | -- | minimum: 0 | Price per kW (in Alpha Matter) |
| type | string | enum | `buy`, `sell`, `agreement` | Trade type |
| agreementId | string | entity-id | `^11-[0-9]+$` | Agreement ID if using automated agreement. Type 11 = Agreement. |

**Requirements**:

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| sufficientResources | true |
| energyEphemeral | Energy must be consumed immediately -- cannot be stored |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgTradeEnergy",
        "creator": "structs1...",
        "quantity": 100,
        "price": 0.01,
        "type": "buy"
      }
    ]
  }
}
```

### PlaceMarketOrder

- **ID**: `place-market-order`
- **Name**: Place Market Order
- **Category**: economic
- **Action**: `MsgPlaceMarketOrder`
- **Message Type**: `/structs.structs.MsgPlaceMarketOrder`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Place a buy or sell order on the marketplace

**Required Fields**: `creator`, `resource`, `quantity`, `price`, `orderType`

| Field | Type | Format | Pattern | Description |
|-------|------|--------|---------|-------------|
| creator | string | entity-id | `^1-[0-9]+$` | Player placing order. Type 1 = Player. |
| resource | string | enum | `AlphaMatter`, `Energy`, `GuildToken` | Resource type |
| quantity | number | -- | minimum: 0 | Order quantity |
| price | number | -- | minimum: 0 | Order price per unit |
| orderType | string | enum | `buy`, `sell` | Order type |

**Requirements**:

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| sufficientResources | true |
| validMarket | true |

**Response**:

| Field | Type | Values | Description |
|-------|------|--------|-------------|
| orderId | string | order-id format | Created order identifier |
| status | string | `placed`, `filled`, `rejected` | Order result status |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgPlaceMarketOrder",
        "creator": "structs1...",
        "resource": "AlphaMatter",
        "quantity": 100,
        "price": 0.001,
        "orderType": "sell"
      }
    ]
  }
}
```

### CancelMarketOrder

- **ID**: `cancel-market-order`
- **Name**: Cancel Market Order
- **Category**: economic
- **Action**: `MsgCancelMarketOrder`
- **Message Type**: `/structs.structs.MsgCancelMarketOrder`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Cancel an existing market order

**Required Fields**: `creator`, `orderId`

| Field | Type | Format | Description |
|-------|------|--------|-------------|
| creator | string | entity-id (`^1-[0-9]+$`) | Player cancelling order. Type 1 = Player. |
| orderId | string | order-id | Order ID to cancel |

**Requirements**:

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| orderExists | true |
| orderOwner | true |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgCancelMarketOrder",
        "creator": "structs1...",
        "orderId": "order-123"
      }
    ]
  }
}
```

---

## Trading Strategies

### Buy Low, Sell High

Buy when prices are low, sell when prices are high.

- Monitor prices
- Identify trends
- Time purchases at low prices
- Time sales at high prices

### Market Timing

Time trades based on market cycles.

| Phase | Strategy |
|-------|----------|
| Expansion | High demand, rising prices -- sell |
| Consolidation | Balanced market, stable prices -- trade normally |
| Conflict | Price volatility -- buy if supply available |
| Recovery | Market normalization -- buy low |

### Arbitrage

Profit from price differences across markets.

- Identify price differences
- Buy in low-price market
- Sell in high-price market
- Profit margin = price difference

### Guild Coordination

Coordinate trading within guild for collective benefit.

- Internal trading between members
- Coordinated purchases
- Shared resources
- Collective bargaining

---

## Trading Flow

1. **Query market data**: Get current market prices and conditions via `GET /structs/market/{resource}` (returns MarketData)
2. **Analyze market conditions**: Determine if conditions are favorable -- evaluate price, supply, demand, volatility, trend
3. **Place order or execute trade**: Use `placeMarketOrder`, `tradeAlphaMatter`, or `tradeEnergy`
4. **Monitor trade status**: Check if order was filled via `GET /structs/market/order/{orderId}`
5. **Update resources**: Verify resource balance after trade via `GET /structs/player/{id}`

---

## Trading Errors

| Error Code | Description | Solution |
|------------|-------------|----------|
| INSUFFICIENT_RESOURCES | Not enough resources to complete trade | Check resource balance, mine more resources, or reduce trade quantity |
| ORDER_NOT_FOUND | Order ID does not exist | Verify order ID, check order status |
| ORDER_ALREADY_FILLED | Order has already been filled | Query order status before attempting to cancel |
| INVALID_PRICE | Price is outside acceptable range | Check current market prices, adjust price |
| MARKET_CLOSED | Market is currently closed | Wait for market to open, check market status |
| ENERGY_EXPIRED | Energy expired before trade completed (ephemeral) | Consume energy immediately, trade energy quickly |

---

## Verification

| Field | Value |
|-------|-------|
| Verified Date | 2025-01-XX |
| Source | documentation |
| Notes | Trading operations based on economic documentation. Some trading actions may need code verification for exact message types and endpoints. |
