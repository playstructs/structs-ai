# Cosmetic Mod Invalid

**Version**: 1.0.0
**Error**: `cosmetic-mod-invalid`
**Category**: Modding

---

Error handling example for attempting to install a cosmetic mod with an invalid manifest. The validation endpoint returns detailed errors and warnings that guide the modder toward fixing the mod before installation.

## Scenario: Invalid Mod Manifest

**Endpoint**: `cosmetic-mod-validate`

**Request:**

```json
{
  "method": "POST",
  "url": "http://localhost:8080/api/cosmetic-mods/validate",
  "body": {
    "file": "path/to/invalid-mod.zip"
  }
}
```

**Response (400):**

```json
{
  "valid": false,
  "errors": [
    "Invalid modId format: must match pattern ^[a-z0-9-]+$",
    "Missing required field: manifest.version",
    "Invalid struct type ID: 'invalid-type' does not exist in game"
  ],
  "warnings": [
    "Missing fallback language (en) in localizations",
    "Referenced animation file not found: animations/miner-idle.json"
  ],
  "modId": null,
  "version": null
}
```

---

## Error Handling

**Action**: Fix mod file and retry

Do not attempt to install invalid mods. Always validate first.

### Recovery Steps

1. **Review validation errors** -- Check all errors in `response.body.errors`
2. **Fix mod manifest** -- Update `manifest.json` with correct `modId` format and required fields
3. **Verify struct type IDs** -- Ensure all struct type IDs in the mod exist in the game
4. **Fix asset references** -- Ensure all referenced asset files exist in the mod directory
5. **Re-validate** -- Call the validate endpoint again to verify all fixes

**Retry**: No (fix errors first, then re-validate)

---

## Related Errors

- `COSMETIC_MOD_INVALID`
- `COSMETIC_STRUCT_TYPE_NOT_FOUND`

## Related Documentation

- [Error Codes](../../api/error-codes.md) (`COSMETIC_MOD_INVALID`)
- [Cosmetic Mod Schema](../../schemas/cosmetic-mod.md)
- [Cosmetic Mod Protocol -- Validate Mod Structure](../../protocols/cosmetic-mod-protocol.md#validate-mod-structure)
