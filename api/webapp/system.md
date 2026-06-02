# Webapp System API Endpoints

**Version**: 1.1.0
**Category**: webapp
**Entity**: Timestamp
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`)
**Last Updated**: January 1, 2026

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/timestamp` | Get current Unix timestamp | No (public) |

`/api/timestamp` is one of the four public routes (`/api/auth/*`, `/api/guild/this`, `/api/timestamp`, `/api/setting`); it needs no session cookie. Use it to obtain server time for the login `unix_timestamp` (must be within 600s of server time).

---

## Endpoint Details

### GET `/api/timestamp`

Get current Unix timestamp.

- **ID**: `webapp-timestamp`
- **Response Schema**: `schemas/responses.md#TimestampResponse`
- **Content Type**: `application/json`

#### Example

**Request**: `GET http://localhost:8080/api/timestamp`

**Response** (standard envelope; `data` holds the SQL/column key `unix_timestamp`):

```json
{
  "success": true,
  "errors": {},
  "data": { "unix_timestamp": 1704067200 }
}
```

---

*Last Updated: January 1, 2026*
