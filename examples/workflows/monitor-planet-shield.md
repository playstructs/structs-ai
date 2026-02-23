# Monitor Planet Shield

**Version**: 1.0.0
**Workflow**: monitor-planet-shield
**Category**: Monitoring

---

## Description

Monitor planet shield health and information.

## Prerequisites

- `planet_id`

## Steps

### 1. Get Planet Information

- **Endpoint**: `webapp-planet-by-id`
- **Method**: `GET`
- **URL**: `http://localhost:8080/api/planet/{planet_id}`

**Parameters**:

| Parameter | Example Value |
|-----------|---------------|
| planet_id | `3-1` |

**Data Extraction**:

- `planet_id` from `response.id`
- `owner_id` from `response.owner_id`

**Error Handling**:

| Status | Action |
|--------|--------|
| 404 | Planet not found - verify planet_id |

### 2. Get Planetary Shield Health

- **Endpoint**: `webapp-planet-shield-health`
- **Method**: `GET`
- **URL**: `http://localhost:8080/api/planet/{planet_id}/shield/health`

**Parameters**:

| Parameter | Value |
|-----------|-------|
| planet_id | `{{step1.extract.planet_id}}` |

**Data Extraction**:

- `health` from `response.health`
- `max_health` from `response.max_health`

**Error Handling**:

| Status | Action |
|--------|--------|
| 404 | Planet not found or no shield data |

### 3. Get Planetary Shield Information

- **Endpoint**: `webapp-planet-shield`
- **Method**: `GET`
- **URL**: `http://localhost:8080/api/planet/{planet_id}/shield`

**Parameters**:

| Parameter | Value |
|-----------|-------|
| planet_id | `{{step1.extract.planet_id}}` |

**Data Extraction**:

- `shield_info` from `response.shield`

**Error Handling**:

| Status | Action |
|--------|--------|
| 404 | Planet not found or no shield data |

## Result

```json
{
  "planet": {
    "id": "{{step1.extract.planet_id}}",
    "owner_id": "{{step1.extract.owner_id}}",
    "shield": {
      "health": "{{step2.extract.health}}",
      "max_health": "{{step2.extract.max_health}}",
      "health_percentage": "{{step2.extract.health}} / {{step2.extract.max_health}} * 100",
      "details": "{{step3.extract.shield_info}}"
    }
  }
}
```

## Notes

This workflow demonstrates monitoring a planet's shield status. Steps 2 and 3 can be executed in parallel.
