# Webapp Stat API Endpoints

**Category**: webapp (catalog read)
**Entity**: Stat (per-object time-series metrics)
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Overview

Range query against per-object time-series stat tables. Pick a metric name and an object key, then page through the rows that fall within `[start_time, end_time]` (unix seconds).

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/stat/{metric}/object/{object_key}/range/page/{page}?start_time={unix}&end_time={unix}` | Range stats for one object | No |

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

**Response** (shape):

```json
{
  "rows": [
    { "ts": 1715000300, "value": 1024 },
    { "ts": 1715000600, "value": 1018 }
  ],
  "page": 1,
  "page_size": 100
}
```

---

Responses use the standard catalog envelope (see `protocols/webapp-api-protocol.md`).
