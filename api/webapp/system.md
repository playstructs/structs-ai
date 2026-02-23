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
| GET | `/api/timestamp` | Get current Unix timestamp | No |

---

## Endpoint Details

### GET `/api/timestamp`

Get current Unix timestamp.

- **ID**: `webapp-timestamp`
- **Response Schema**: `schemas/responses.md#TimestampResponse`
- **Content Type**: `application/json`

#### Example

**Request**: `GET http://localhost:8080/api/timestamp`

**Response**:

```json
{
  "timestamp": 1704067200,
  "iso": "2024-01-01T00:00:00Z"
}
```

---

*Last Updated: January 1, 2026*
