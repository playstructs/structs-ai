# Cosmetic Mod Conflict

**Version**: 1.0.0
**Error**: `cosmetic-mod-conflict`
**Category**: Modding

---

Error handling example for attempting to install a cosmetic mod that conflicts with an already-installed mod. Mod conflicts occur when the same `modId` and version already exist.

## Scenario: Mod Already Installed

**Endpoint**: `cosmetic-mod-install`

**Request:**

```json
{
  "method": "POST",
  "url": "http://localhost:8080/api/cosmetic-mods/install",
  "body": {
    "file": "path/to/guild-alpha-miner-v1.zip",
    "validate": true,
    "activate": true
  }
}
```

**Response (409):**

```json
{
  "error": "Mod conflict",
  "code": 409,
  "details": [
    "Mod 'guild-alpha-miner-v1' version 1.0.0 already installed",
    "Existing mod path: ~/.structs/mods/guild-alpha-miner-v1",
    "Use uninstall endpoint to remove existing mod first"
  ]
}
```

---

## Error Handling

**Action**: Uninstall existing mod or use a different mod ID

### Recovery Steps

1. **Check existing mod** -- Query the existing mod to see its current version and status:
   `GET http://localhost:8080/api/cosmetic-mods/guild-alpha-miner-v1`

2. **Decide on resolution** -- Choose one of two options:

   **Option A: Uninstall existing mod**
   - `DELETE /api/cosmetic-mods/guild-alpha-miner-v1`
   - `POST /api/cosmetic-mods/install` (with the new mod)

   **Option B: Use a different ID or version**
   - Update the mod manifest with a new `modId` or bumped `version`
   - `POST /api/cosmetic-mods/install` (with the updated mod)

3. **Execute resolution** -- Perform the chosen option above

**Retry**: No (resolve the conflict first)

---

## Related Errors

- `COSMETIC_MOD_CONFLICT`

## Related Documentation

- [Error Codes](../../api/error-codes.md) (`COSMETIC_MOD_CONFLICT`)
- [Cosmetic Mod Install Endpoint](../../api/cosmetic-mods.md)
