# Get Player and Planets

**Version**: 1.0.0
**Workflow**: get-player-and-planets
**Category**: Query

---

## Description

Get player information and their planets - Multi-step API workflow.

## Prerequisites

None.

## Steps

### 1. Get Player Information

- **Endpoint**: `webapp-player-by-id`
- **Method**: `GET`
- **URL**: `http://localhost:8080/api/player/{player_id}`

**Parameters**:

| Parameter | Example Value |
|-----------|---------------|
| player_id | `1-11` |

**Data Extraction**:

- `player_id` from `response.player.id`
- `guild_id` from `response.guild.id`

**Expected Response**:

- **Status**: `200`
- **Schema**: `schemas/responses.md#/definitions/WebappPlayerResponse`

**Error Handling**:

| Status | Action |
|--------|--------|
| 404 | Player not found - verify player_id |
| 500 | Server error - retry with exponential backoff |

### 2. Get Planets Owned by Player

- **Endpoint**: `planet-by-player`
- **Method**: `GET`
- **URL**: `http://localhost:1317/structs/planet_by_player/{playerId}`

**Parameters**:

| Parameter | Value |
|-----------|-------|
| playerId | `{{step1.extract.player_id}}` |

**Data Extraction**:

- `planets` from `response.Planet`

**Expected Response**:

- **Status**: `200`
- **Schema**: `schemas/entities.md#/definitions/Planet[]`

**Error Handling**:

| Status | Action |
|--------|--------|
| 404 | No planets found for player (may be empty array) |
| 500 | Server error - retry with exponential backoff |

## Result

```json
{
  "player": "{{step1.response.player}}",
  "guild": "{{step1.response.guild}}",
  "planets": "{{step2.extract.planets}}"
}
```

## Notes

This workflow demonstrates chaining API calls where step 2 depends on data from step 1.
