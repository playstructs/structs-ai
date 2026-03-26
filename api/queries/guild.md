# Guild Query Endpoints

**Version**: 1.0.0
**Category**: Query
**Entity**: Guild
**Base URL**: `http://localhost:1317`
**Base Path**: `/structs`

---

## Endpoint Summary

| Method | Path | Description | Auth | Paginated |
|--------|------|-------------|------|-----------|
| GET | `/structs/guild/{id}` | Get guild by ID | No | No |
| GET | `/structs/guild` | List all guilds | No | Yes |

---

## Endpoint Details

### Get Guild by ID

`GET /structs/guild/{id}`

Returns a single guild by its entity ID.

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `id` | string | Yes | entity-id (`^0-[0-9]+$`) | Guild identifier in format 'type-index' (e.g., '0-1' for guild type 0, index 1). Type 0 = Guild. |

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities/guild.md`

#### Example

**Request**: `GET /structs/guild/0-1`

**Response**:

```json
{
  "Guild": {
    "id": "0-1",
    "creator": "structs1...",
    "entrySubstationId": "4-1",
    "joinInfusionMinimum": "0",
    "entryInfusion": "0",
    "entryRank": "101"
  }
}
```

The `entryRank` field (uint64) is the default guild rank assigned to new members on join. Default is 101 on guild creation. Lower values = more privileged.

---

### List All Guilds

`GET /structs/guild`

Returns a paginated list of all guilds.

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities/guild.md` (array)
