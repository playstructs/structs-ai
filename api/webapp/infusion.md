# Webapp Infusion API Endpoints

**Version**: 1.1.0
**Category**: webapp
**Entity**: Infusion
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`)
**Last Updated**: January 1, 2026

---

## v0.8.0-beta Notes

**Reactor Staking & Validation Delegation**: The infusion endpoint may include reactor staking information and validation delegation status in v0.8.0-beta. See `reviews/webapp-v0.8.0-beta-review.md` for review status.

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

## Response Schema (v0.8.0-beta Considerations)

The infusion response may include reactor staking information:

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

**Note**: Response schema updates are under review. See `reviews/webapp-v0.8.0-beta-review.md` for verification status.

---

*Last Updated: January 1, 2026*
