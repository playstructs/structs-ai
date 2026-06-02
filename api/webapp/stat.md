# Webapp Stat API Endpoints

**Category**: webapp (catalog read)
**Entity**: Stat (per-object time-series metrics)
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Overview

Range query against per-object time-series stat tables. Pick a metric name and an object key, then page through the rows that fall within the window `[start_time, end_time)` (unix seconds — start inclusive, end exclusive).

### Metric families and `object_key` rules

**Family one** (any object type): `ore`, `fuel`, `capacity`, `load`, `power`.

**Family two** restricts `object_key` to a specific entity type (the table omits `object_type`, so the wrong key would silently return nothing — the server returns `400 object_key_invalid` instead):

| Metric | Required `object_key` type |
|--------|----------------------------|
| `structs_load` | player (`1-…`) |
| `connection_count` | substation (`4-…`) |
| `connection_capacity` | substation (`4-…`) |
| `struct_health` | struct (`5-…`) |
| `struct_status` | struct (`5-…`) |

### Constraints & errors (HTTP 400, keyed `errors`)

- `start_time_end_time_required` — `start_time`/`end_time` query params missing.
- `time_range_invalid` — `end_time` must be greater than `start_time`.
- `time_range_too_large` — window may not exceed **604800 seconds (7 days)**.
- `object_key_invalid` — `object_key` not `{type}-{index}`, or wrong type for a family-two metric.

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/stat/{metric}/object/{object_key}/range/page/{page}?start_time={unix}&end_time={unix}` | Range stats for one object | Yes |

---

## Endpoint Details

### GET `/api/stat/{metric}/object/{object_key}/range/page/{page}`

Return rows of `metric` recorded against `object_key` between `start_time` and `end_time` (inclusive), paginated.

- **ID**: `webapp-stat-range-by-object`

#### Path parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `metric` | string | Yes | -- | Metric name (e.g. `power`, `ore`, `load`) |
| `object_key` | string | Yes | entity-id | Object key (player ID, struct ID, planet ID, etc.) |
| `page` | integer | Yes | `\d+` | Page number, 1-indexed |

#### Query parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `start_time` | string | Yes | unix seconds | Inclusive lower bound for the row timestamp |
| `end_time` | string | Yes | unix seconds | Inclusive upper bound for the row timestamp |

If either `start_time` or `end_time` is missing, the endpoint returns `400 Bad Request` with `errors.start_time_end_time_required` set to `start_time and end_time query params are required (unix seconds)`.

#### Example

**Request**:

```
GET http://localhost:8080/api/stat/power/object/1-11/range/page/1?start_time=1715000000&end_time=1715600000
```

**Response** (envelope; `data` is a **flat array of `{time, value}`** — the column is `time` (a timestamp), not `ts`):

```json
{
  "success": true,
  "errors": {},
  "data": [
    { "time": "2024-05-06T14:18:20Z", "value": 1024 },
    { "time": "2024-05-06T14:23:20Z", "value": 1018 }
  ]
}
```

Page size is fixed at 100 — if `data.length === 100`, request the next page (still within the same 7-day window).

**Validation failure example** (window too large):

```json
{
  "success": false,
  "errors": { "time_range_too_large": "Time range exceeds maximum allowed window" },
  "data": null
}
```

---

Responses use the shared envelope with `data` as a flat array of `{time, value}` rows (page size 100). See `protocols/webapp-api-protocol.md`.
