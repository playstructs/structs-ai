# Query and Monitor Planet

**Version**: 1.0.0
**Workflow**: query-and-monitor-planet
**Category**: Monitoring

---

## Description

Query planet information and set up monitoring via streaming.

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

- `planet_id` from `response.body.id`
- `owner_id` from `response.body.owner_id`
- `planet_name` from `response.body.name`

**Expected Response**:

- **Status**: `200`
- **Schema**: `schemas/entities.md#/definitions/Planet`

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

- `shield_health` from `response.body.health`
- `shield_max_health` from `response.body.max_health`
- `shield_percentage` calculated as `response.body.health / response.body.max_health * 100`

**Expected Response**:

- **Status**: `200`
- **Schema**: `schemas/responses.md#/definitions/ShieldHealthResponse`

**Error Handling**:

| Status | Action |
|--------|--------|
| 404 | Planet not found or no shield data |

### 3. Check for Active Raids

- **Endpoint**: `webapp-planet-raid-active`
- **Method**: `GET`
- **URL**: `http://localhost:8080/api/planet/{planet_id}/raid/active`

**Parameters**:

| Parameter | Value |
|-----------|-------|
| planet_id | `{{step1.extract.planet_id}}` |

**Data Extraction**:

- `has_active_raid` from `response.body !== null`
- `raid_info` from `response.body`

**Expected Response**:

- **Status**: `200`
- **Schema**: `schemas/entities.md#/definitions/Raid`

Response may be null if no active raid.

**Error Handling**:

| Status | Action |
|--------|--------|
| 404 | Planet not found (null response is valid if no active raid) |

### 4. Get All Structs on Planet

- **Endpoint**: `webapp-struct-by-planet`
- **Method**: `GET`
- **URL**: `http://localhost:8080/api/struct/planet/{planet_id}`

**Parameters**:

| Parameter | Value |
|-----------|-------|
| planet_id | `{{step1.extract.planet_id}}` |

**Data Extraction**:

- `structs` from `response.body`
- `struct_count` from `response.body.length`

**Expected Response**:

- **Status**: `200`
- **Schema**: `schemas/entities.md#/definitions/Struct[]`

**Error Handling**:

| Status | Action |
|--------|--------|
| 404 | Planet not found or no structs |

### 5. Subscribe to Planet Updates via GRASS/NATS

Set up real-time monitoring via streaming.

- **Endpoint**: `grass-nats-protocol`
- **Method**: `NATS`
- **Connection URL**: `nats://localhost:4222`

**Subscription**:

- **Subject**: `structs.planet.{{step1.extract.planet_id}}`
- Subscribe to planet-specific events

**Events**:

- `raid_status`
- `fleet_arrive`
- `fleet_advance`
- `fleet_depart`

**Documentation**: See `protocols/streaming.md`

**Error Handling**:

| Error | Action |
|-------|--------|
| connection_error | NATS connection failed - check NATS server |
| subscription_error | Subscription failed - verify subject pattern |

## Result

```json
{
  "planet": {
    "id": "{{step1.extract.planet_id}}",
    "name": "{{step1.extract.planet_name}}",
    "owner_id": "{{step1.extract.owner_id}}",
    "shield": {
      "health": "{{step2.extract.shield_health}}",
      "max_health": "{{step2.extract.shield_max_health}}",
      "health_percentage": "{{step2.extract.shield_percentage}}"
    },
    "raid": {
      "active": "{{step3.extract.has_active_raid}}",
      "info": "{{step3.extract.raid_info}}"
    },
    "structs": {
      "count": "{{step4.extract.struct_count}}",
      "list": "{{step4.extract.structs}}"
    }
  },
  "monitoring": {
    "streaming_subject": "structs.planet.{{step1.extract.planet_id}}",
    "status": "subscribed"
  }
}
```

## Notes

This workflow demonstrates querying planet information and setting up real-time monitoring. Steps 2-4 can be executed in parallel for better performance. Step 5 establishes a streaming connection for real-time updates.
