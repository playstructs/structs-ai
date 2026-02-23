# Agreement Query Endpoints

**Version**: 1.0.0
**Category**: Query
**Entity**: Agreement
**Base URL**: `http://localhost:1317`
**Base Path**: `/structs`

---

## Endpoint Summary

| Method | Path | Description | Auth | Paginated |
|--------|------|-------------|------|-----------|
| GET | `/structs/agreement/{id}` | Get agreement by ID | No | No |
| GET | `/structs/agreement` | List all agreements | No | Yes |
| GET | `/structs/agreement_by_provider/{providerId}` | Get agreements by provider | No | No |

---

## Endpoint Details

### Get Agreement by ID

`GET /structs/agreement/{id}`

Returns a single agreement by its ID.

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `id` | string | Yes | agreement-id | Agreement identifier |

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities/agreement.md`

---

### List All Agreements

`GET /structs/agreement`

Returns a paginated list of all agreements.

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities/agreement.md` (array)

---

### Get Agreements by Provider

`GET /structs/agreement_by_provider/{providerId}`

Returns all agreements associated with a specific provider.

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `providerId` | string | Yes | provider-id | Provider identifier |

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities/agreement.md` (array)
