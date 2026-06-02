# Query Guild Stats

**Version**: 1.0.0
**Workflow**: query-guild-stats
**Category**: Query

---

## Description

Query guild statistics including member count and power stats.

## Prerequisites

- `guild_id`

## Steps

### 1. Get Guild Information

- **Endpoint**: `webapp-guild-by-id`
- **Method**: `GET`
- **URL**: `http://localhost:8080/api/guild/{guild_id}`

**Parameters**:

| Parameter | Example Value |
|-----------|---------------|
| guild_id | `0-1` (guild IDs are type 0, `^0-[0-9]+$`) |

**Data Extraction** (unwrap the envelope `data`):

- `guild_id` from `response.data.id`
- `guild_name` from `response.data.name`

**Error Handling**:

| Status | Action |
|--------|--------|
| 401 | Session required — log in first (signature flow) |
| 404 | Guild not found - verify guild_id |

### 2. Get Guild Member Count

- **Endpoint**: `webapp-guild-member-count`
- **Method**: `GET`
- **URL**: `http://localhost:8080/api/guild/{guild_id}/members/count`

**Parameters**:

| Parameter | Value |
|-----------|-------|
| guild_id | `{{step1.extract.guild_id}}` |

**Data Extraction**:

- `member_count` from `response.data.count`

**Error Handling**:

| Status | Action |
|--------|--------|
| 404 | Guild not found - verify guild_id |

### 3. Get Guild Power Statistics

- **Endpoint**: `webapp-guild-power-stats`
- **Method**: `GET`
- **URL**: `http://localhost:8080/api/guild/{guild_id}/power/stats`

**Parameters**:

| Parameter | Value |
|-----------|-------|
| guild_id | `{{step1.extract.guild_id}}` |

**Data Extraction**:

- `power_stats` from `response.data`

**Error Handling**:

| Status | Action |
|--------|--------|
| 404 | Guild not found - verify guild_id |

## Result

```json
{
  "guild": {
    "id": "{{step1.extract.guild_id}}",
    "name": "{{step1.extract.guild_name}}",
    "member_count": "{{step2.extract.member_count}}",
    "power_stats": "{{step3.extract.power_stats}}"
  }
}
```

## Notes

This workflow demonstrates parallel queries that can be executed concurrently since they don't depend on each other (steps 2 and 3).
