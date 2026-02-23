# Trade Alpha Matter Workflow

**Version**: 1.0.0
**ID**: trade-alpha-matter
**Category**: Economic
**Estimated Time**: 2-5 minutes

---

## Prerequisites

- Player must be online
- Player must have Alpha Matter

## Steps

### 1. Query Market Data

Get current Alpha Matter market prices and conditions.

- **Method**: `GET`
- **Endpoint**: `/structs/market/AlphaMatter`
- **Response Schema**: `schemas/markets.md#/markets/MarketData`

**Expected Response**:

```json
{
  "currentPrice": "number",
  "high24h": "number",
  "low24h": "number",
  "volume24h": "number",
  "supply": "number",
  "demand": "number",
  "volatility": "number",
  "trend": "string"
}
```

### 2. Analyze Market Conditions

Determine if conditions are favorable for trading.

**Price Comparison**:

- Compare current price to 24h average
- Identify price trend (rising, falling, stable)

**Supply/Demand Analysis**:

- Analyze supply/demand balance
- Identify supply or demand surplus

**Volatility Assessment**:

- Assess market volatility level
- Determine risk level

**Decision Matrix**:

| Decision | Condition | Action |
|----------|-----------|--------|
| Buy | Price is low and trend is rising | Execute buy trade |
| Sell | Price is high and trend is falling | Execute sell trade |
| Wait | Conditions are uncertain | Wait for better conditions |

### 3. Check Resource Balance

Verify Alpha Matter balance before trading.

- **Method**: `GET`
- **Endpoint**: `/structs/player/{playerId}`
- **Response Schema**: `schemas/entities.md#/entities/Player`

**Checks**:

- `alphaMatterBalance`: Verify current balance
- `sufficientForTrade`: Confirm balance covers trade amount

### 4. Execute Trade

Place market order or execute immediate trade.

#### Option A: Immediate Trade

Execute trade immediately at current market price.

- **Method**: `POST`
- **Endpoint**: `/cosmos/tx/v1beta1/txs`
- **Message Type**: `/structs.structs.MsgTradeAlphaMatter`
- **Schema**: `schemas/trading.md#/tradingOperations/TradeAlphaMatter`

**Request Example**:

```json
{
  "body": {
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
}
```

#### Option B: Place Market Order

Place order at specific price (may take time to fill).

- **Method**: `POST`
- **Endpoint**: `/cosmos/tx/v1beta1/txs`
- **Message Type**: `/structs.structs.MsgPlaceMarketOrder`
- **Schema**: `schemas/trading.md#/tradingOperations/PlaceMarketOrder`

**Request Example**:

```json
{
  "body": {
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
}
```

### 5. Verify Trade Status

Check if trade was executed successfully.

- **Method**: `GET`
- **Endpoint**: `/structs/market/order/{orderId}`
- **Response Schema**: `schemas/markets.md#/markets/MarketOrder`

**Status Checks**:

- `status`: `placed` | `filled` | `rejected`
- `filled`: Whether the order has been filled
- `quantityFilled`: Amount filled so far

### 6. Update Resource Balance

Verify resource balance after trade.

- **Method**: `GET`
- **Endpoint**: `/structs/player/{playerId}`
- **Response Schema**: `schemas/entities.md#/entities/Player`

**Verification**:

- `alphaMatterBalance`: Confirm balance updated
- `tradeSuccessful`: Confirm trade completed

## Error Handling

| Error | Code | Step | Solution | Retryable |
|-------|------|------|----------|-----------|
| Insufficient resources | `INSUFFICIENT_RESOURCES` | 3 | Check resource balance, mine more resources, or reduce trade quantity | Yes |
| Invalid price | `INVALID_PRICE` | 4 | Check current market prices, adjust price | Yes |
| Order not found | `ORDER_NOT_FOUND` | 5 | Verify order ID, check order status | No |

## Best Practices

- **Monitor market**: Track prices over time to identify trends
- **Time trades**: Buy during low-demand periods, sell during high-demand periods
- **Verify balance**: Always verify resource balance before and after trades
- **Use orders**: Use market orders for better price control
