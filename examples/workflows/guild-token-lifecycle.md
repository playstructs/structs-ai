# Guild Token Lifecycle Workflow

**Version**: 1.0.0
**ID**: guild-token-lifecycle
**Category**: Economic
**Estimated Time**: 10-20 minutes

---

## Prerequisites

- Player must be online
- Player must be a guild member
- Guild permissions required: `mintTokens`, `manageBank`
- Player must have Alpha Matter

## Security Warning

Guild tokens are trust-based. Guilds have full control. No technical safeguards.

## Steps

### 1. Query Guild Central Bank

Get current guild central bank status.

- **Method**: `GET`
- **Endpoint**: `/structs/guild/{guildId}/bank`
- **Response Schema**: `schemas/economics.md#/entities/GuildCentralBank`

**Expected Response**:

```json
{
  "guildId": "string",
  "collateral": "number",
  "tokensIssued": "number",
  "tokensInCirculation": "number",
  "collateralRatio": "number"
}
```

### 2. Lock Collateral

Lock Alpha Matter as collateral for guild tokens.

- **Method**: `POST`
- **Endpoint**: `/cosmos/tx/v1beta1/txs`
- **Message Type**: `/structs.structs.MsgGuildLockCollateral`

**Requirements**: Player must have Alpha Matter in sufficient amount.

**Request Example**:

```json
{
  "body": {
    "body": {
      "messages": [
        {
          "@type": "/structs.structs.MsgGuildLockCollateral",
          "creator": "structs1...",
          "guildId": "1-1",
          "alphaMatterAmount": "100000000"
        }
      ]
    }
  }
}
```

**Expected Result**:

```json
{
  "collateralLocked": true,
  "canMintTokens": true
}
```

### 3. Mint Guild Tokens

Mint new guild tokens backed by collateral.

- **Method**: `POST`
- **Endpoint**: `/cosmos/tx/v1beta1/txs`
- **Message Type**: `/structs.structs.MsgGuildMintTokens`

**Requirements**: Collateral must be locked and guild permissions must be granted.

**Request Example**:

```json
{
  "body": {
    "body": {
      "messages": [
        {
          "@type": "/structs.structs.MsgGuildMintTokens",
          "creator": "structs1...",
          "guildId": "1-1",
          "tokensToMint": "1000"
        }
      ]
    }
  }
}
```

**Expected Result**:

```json
{
  "tokensMinted": true,
  "tokensInCirculation": "updated",
  "collateralRatio": "calculated"
}
```

### 4. Query Guild Token Market

Get current guild token market data.

- **Method**: `GET`
- **Endpoint**: `/structs/market/guild-token/{guildId}`
- **Response Schema**: `schemas/markets.md#/markets/GuildTokenMarketData`

**Expected Response**:

```json
{
  "currentPrice": "number",
  "marketCap": "number",
  "tokensInCirculation": "number",
  "collateral": "number",
  "collateralRatio": "number",
  "volume24h": "number",
  "trustRating": "string"
}
```

### 5. Trade Guild Tokens (Optional)

Trade guild tokens on marketplace.

- **Method**: `POST`
- **Endpoint**: `/cosmos/tx/v1beta1/txs`
- **Message Type**: `/structs.structs.MsgTradeGuildToken`

**Request Example**:

```json
{
  "body": {
    "body": {
      "messages": [
        {
          "@type": "/structs.structs.MsgTradeGuildToken",
          "creator": "structs1...",
          "guildId": "1-1",
          "quantity": 100,
          "price": 0.01,
          "type": "sell"
        }
      ]
    }
  }
}
```

### 6. Monitor Token Status

Monitor token supply, collateral ratio, and market value.

- **Method**: `GET`
- **Endpoint**: `/structs/guild/{guildId}/bank`
- **Response Schema**: `schemas/economics.md#/entities/GuildCentralBank`

**Monitoring Targets**:

| Target | Description |
|--------|-------------|
| collateralRatio | Maintain healthy ratio (100%+ recommended) |
| tokensInCirculation | Track token supply |
| marketValue | Monitor token price |

### 7. Revoke Tokens (Optional - Economic Warfare)

Revoke and burn tokens (can be used for economic warfare).

- **Method**: `POST`
- **Endpoint**: `/cosmos/tx/v1beta1/txs`
- **Message Type**: `/structs.structs.MsgGuildRevokeTokens`

**Warning**: Revocation damages reputation. Use carefully.

**Request Example**:

```json
{
  "body": {
    "body": {
      "messages": [
        {
          "@type": "/structs.structs.MsgGuildRevokeTokens",
          "creator": "structs1...",
          "guildId": "1-1",
          "tokensToRevoke": "100"
        }
      ]
    }
  }
}
```

**Expected Result**:

```json
{
  "tokensRevoked": true,
  "tokensBurned": true
}
```

## Risks

| Risk | Description | Result | Prevention |
|------|-------------|--------|------------|
| Over-minting | Minting more tokens than collateral backing | Inflation, reduced token value | Maintain healthy collateral ratio |
| Poor management | Poor token management damages reputation | Reduced trust, lower token value | Transparent management, maintain collateral |
| Revocation | Token revocation damages reputation | Reduced trust, potential token devaluation | Use revocation carefully, maintain reputation |

## Error Handling

| Error | Code | Step | Solution | Retryable |
|-------|------|------|----------|-----------|
| Insufficient collateral | `INSUFFICIENT_COLLATERAL` | 2 | Lock more Alpha Matter as collateral | Yes |
| Over-minting | `OVER_MINTING` | 3 | Add more collateral or reduce token supply | Yes |
| No permissions | `NO_PERMISSIONS` | 3 | Request permissions from guild leadership | No |

## Best Practices

- **Maintain collateral**: Maintain healthy collateral ratio (100%+ recommended)
- **Transparent management**: Communicate token management decisions to guild members
- **Avoid over-minting**: Only mint tokens backed by adequate collateral
- **Protect reputation**: Use revocation carefully, maintain good reputation
