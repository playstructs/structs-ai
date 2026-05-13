# Webapp Setting API Endpoints

**Category**: webapp (catalog read)
**Entity**: Setting (`structs.setting`)
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Overview

Live tunables that control chain economy and gameplay constants. The table is `(name, value)` keyed on `name` and seeded with the values listed in `knowledge/infrastructure/database-schema.md`. Clients read this once at startup to pick up the current `REACTOR_RATIO`, `PLAYER_RESUME_CHARGE`, `PLANETARY_SHIELD_BASE`, `PLAYER_PASSIVE_DRAW`, `PLANET_STARTING_ORE`, `PLANET_STARTING_SLOTS`, etc.

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/setting` | Return every setting as a name/value map | No |

---

## Endpoint Details

### GET `/api/setting`

Return every setting in a single payload. There are no path or query parameters.

- **ID**: `webapp-setting-all`

#### Example

**Request**: `GET http://localhost:8080/api/setting`

**Response** (shape):

```json
{
  "settings": [
    { "name": "REACTOR_RATIO", "value": "..." },
    { "name": "PLAYER_RESUME_CHARGE", "value": "..." },
    { "name": "PLANETARY_SHIELD_BASE", "value": "..." },
    { "name": "PLAYER_PASSIVE_DRAW", "value": "..." },
    { "name": "PLANET_STARTING_ORE", "value": "..." },
    { "name": "PLANET_STARTING_SLOTS", "value": "..." }
  ]
}
```

The exact key list grows over time — treat the response as an open name/value map and match by `name`.

---

The response uses the standard envelope (see `protocols/webapp-api-protocol.md`).
