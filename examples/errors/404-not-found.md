# 404 Not Found

**Version**: 1.0.0
**Error Type**: `404-not-found`
**HTTP Status**: 404

---

Resource not found error examples across both the Web Application API and the Consensus Network API. Note that these two APIs handle missing resources differently.

## Scenario: Player Not Found

**Endpoint**: `webapp-player-by-id`

**Request:**

```json
{
  "method": "GET",
  "url": "http://localhost:8080/api/player/1-999",
  "headers": {
    "Accept": "application/json"
  }
}
```

**Response (404):**

```json
{
  "error": "Player not found",
  "code": 404,
  "details": [
    "Player ID 1-999 does not exist"
  ]
}
```

### Error Handling

- **Action**: Verify resource ID and try again
- **Retry**: No
- **Recovery**: Check if `player_id` is correct, or query the player list to find valid IDs

---

## Scenario: Planet Not Found

**Endpoint**: `webapp-planet-by-id`

**Request:**

```json
{
  "method": "GET",
  "url": "http://localhost:8080/api/planet/2-999",
  "headers": {
    "Accept": "application/json"
  }
}
```

**Response (404):**

```json
{
  "error": "Planet not found",
  "code": 404,
  "details": [
    "Planet ID 2-999 does not exist"
  ]
}
```

### Error Handling

- **Action**: Verify `planet_id` and try again
- **Retry**: No
- **Recovery**: Check if `planet_id` is correct, or query the planet list to find valid IDs

---

## Scenario: Consensus Network - Object Not Found

The Consensus Network API returns HTTP 200 even for missing resources. The error is indicated in the response body's `code` field.

**Endpoint**: `player-by-id`

**Request:**

```json
{
  "method": "GET",
  "url": "http://localhost:1317/structs/player/1-999",
  "headers": {
    "Accept": "application/json"
  }
}
```

**Response (200 -- with error in body):**

```json
{
  "code": 2,
  "message": "codespace structs code 1900: object not found",
  "details": []
}
```

### Error Handling

- **Action**: Verify resource ID and try again
- **Retry**: No
- **Recovery**: The Consensus Network returns 200 with an error code rather than 404. Always check the `response.code` field.

---

## Related Documentation

- [Error Response Schema](../../schemas/responses.md)
- [Error Handling Protocol](../../protocols/error-handling.md)
- [API Quick Reference](../../reference/api-quick-reference.md)
