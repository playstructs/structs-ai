# Energy Agreement Setup Workflow

**Version**: 1.0.0
**ID**: energy-agreement-setup
**Category**: Economic
**Estimated Time**: 5-10 minutes

---

## Prerequisites

- Player must be online
- Player has a provider or needs energy

## Steps

### 1. Query Energy Market

Get current energy market data and available providers.

- **Method**: `GET`
- **Endpoint**: `/structs/market/Energy`
- **Response Schema**: `schemas/markets.md#/markets/EnergyMarketData`

**Expected Response**:

```json
{
  "currentPrice": "number",
  "supply": "number",
  "demand": "number",
  "agreements": "array",
  "providers": "array"
}
```

### 2. Find Energy Provider

Find suitable energy provider for agreement.

- **Method**: `GET`
- **Endpoint**: `/structs/provider`
- **Response Schema**: `schemas/entities.md#/entities/Provider`

**Selection Criteria**:

| Criterion | Description |
|-----------|-------------|
| rate | Energy rate (kW per unit) |
| price | Price per unit |
| available | Available energy capacity |
| penaltyProtection | Whether penalty protection is enabled |
| reputation | Provider reputation |

### 3. Query Provider Details

Get detailed provider information.

- **Method**: `GET`
- **Endpoint**: `/structs/provider/{providerId}`
- **Response Schema**: `schemas/entities.md#/entities/Provider`

**Expected Response**:

```json
{
  "id": "string",
  "rate": "number",
  "capacity": "number",
  "penaltyProtection": "boolean",
  "automatic": "boolean"
}
```

### 4. Create Energy Agreement

Create automated energy agreement with provider.

- **Method**: `POST`
- **Endpoint**: `/cosmos/tx/v1beta1/txs`
- **Message Type**: `/structs.structs.MsgAgreementCreate`
- **Schema**: `schemas/actions.md#/actions/MsgAgreementCreate`

**Required Fields**:

```json
{
  "creator": "player-id",
  "providerId": "provider-id",
  "terms": {
    "energyAmount": "number",
    "price": "number",
    "duration": "number"
  }
}
```

**Request Example**:

```json
{
  "body": {
    "body": {
      "messages": [
        {
          "@type": "/structs.structs.MsgAgreementOpen",
          "creator": "structs1...",
          "providerId": "1-1",
          "terms": {
            "energyAmount": 100,
            "price": 0.01,
            "duration": 1000
          }
        }
      ]
    }
  }
}
```

**Expected Result**:

```json
{
  "agreementCreated": true,
  "agreementId": "string",
  "automatic": true,
  "penaltyProtection": true
}
```

### 5. Verify Agreement Status

Verify agreement was created and is active.

- **Method**: `GET`
- **Endpoint**: `/structs/agreement/{agreementId}`
- **Response Schema**: `schemas/economics.md#/entities/EnergyAgreement`

**Verification Checks**:

- `status` should be `active`
- `penaltyProtection` should be `true`
- `automatic` should be `true`

### 6. Monitor Agreement

Monitor agreement performance and energy supply.

- **Method**: `GET`
- **Endpoint**: `/structs/agreement/{agreementId}`
- **Response Schema**: `schemas/economics.md#/entities/EnergyAgreement`

**Monitoring Targets**:

| Target | Description |
|--------|-------------|
| energyAmount | Track energy received |
| status | Monitor agreement status |
| penalties | Check for any penalties applied |

## Agreement Properties

| Property | Description | Benefit |
|----------|-------------|---------|
| automatic | Agreement executes automatically on-chain | No manual intervention needed |
| penaltyProtection | Automatic, on-chain penalty enforcement | Protection for both parties (enforcement is automatic by code on blockchain) |
| persistent | Long-term energy supply arrangement | Consistent energy supply |
| selfEnforcing | Terms enforced automatically by blockchain | Trustless, automatic enforcement |

## Error Handling

| Error | Code | Step | Solution | Retryable |
|-------|------|------|----------|-----------|
| Provider not found | `PROVIDER_NOT_FOUND` | 2 | Verify provider ID, check provider list | Yes |
| Invalid terms | `INVALID_TERMS` | 4 | Check provider requirements, adjust terms | Yes |
| Insufficient resources | `INSUFFICIENT_RESOURCES` | 4 | Check resource balance, ensure sufficient funds | Yes |

## Best Practices

- **Choose reputable provider**: Select provider with good reputation
- **Enable penalty protection**: Always use agreements with penalty protection
- **Monitor agreement**: Regularly monitor agreement performance
- **Renew successful agreements**: Renew agreements that work well
