# Webapp Infusion API Endpoints

**Version**: 1.1.0
**Category**: webapp
**Entity**: Infusion
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`)
**Last Updated**: January 1, 2026

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/infusion/player/{player_id}` | Get infusions for player | No |

---

## Endpoint Details

### GET `/api/infusion/player/{player_id}`

Get infusions for player.

- **ID**: `webapp-infusion-by-player`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `player_id` | string | Yes | player-id | Player identifier |

---

## Response Schema

The infusion response includes reactor staking information:

```json
{
  "infusions": [
    {
      "destinationId": "3-1",
      "address": "cosmos1...",
      "fuel": "1000000",
      "power": "1000000",
      "staking": {
        "delegationStatus": "active",
        "validationDelegation": {
          "validator": "...",
          "amount": "..."
        }
      }
    }
  ]
}
```

---

*Last Updated: January 1, 2026*
