# Install and Use Cosmetic Mod Workflow

**Version**: 1.0.0
**Category**: modding
**Description**: Install a cosmetic mod and use it to display struct types with custom cosmetics

---

## Prerequisites

- `mod_file_path` -- path to the mod file
- `guild_id` (optional)

---

## Workflow Steps

### Step 1: Validate Mod File

Validate mod file before installation.

**Endpoint**: `cosmetic-mod-validate`
**Method**: `POST`
**URL**: `http://localhost:8080/api/cosmetic-mods/validate`

**Request**:

```json
{
  "file": "{{mod_file_path}}"
}
```

**Headers**: `Content-Type: multipart/form-data`

**Extracted Fields**:

| Field | Source |
|-------|--------|
| `valid` | `response.body.valid` |
| `mod_id` | `response.body.modId` |
| `version` | `response.body.version` |
| `errors` | `response.body.errors` |
| `warnings` | `response.body.warnings` |

**Expected Response**: `200` -- schema: `schemas/responses.md#CosmeticModValidateResponse`

**Condition**: If `valid` is false, stop workflow and report errors.

**Error Handling**:

| Status | Action |
|--------|--------|
| 400 | Invalid mod file -- check errors |
| 500 | Server error -- retry with exponential backoff |

### Step 2: Install the Validated Mod

Install the validated mod.

**Endpoint**: `cosmetic-mod-install`
**Method**: `POST`
**URL**: `http://localhost:8080/api/cosmetic-mods/install`

**Request**:

```json
{
  "file": "{{mod_file_path}}",
  "validate": true,
  "activate": true
}
```

**Headers**: `Content-Type: multipart/form-data`

**Extracted Fields**:

| Field | Source |
|-------|--------|
| `status` | `response.body.status` |
| `type` | `response.body.type` |
| `set_hash` | `response.body.setHash` |
| `skin_hash` | `response.body.skinHash` |
| `storage_path` | `response.body.storagePath` |
| `activated` | `response.body.activated` |

**Expected Response**: `200` -- schema: `schemas/responses.md#CosmeticModInstallResponse`

**Error Handling**:

| Status | Action |
|--------|--------|
| 400 | Installation failed -- check mod file |
| 409 | Mod conflict -- mod may already be installed |
| 500 | Server error -- retry with exponential backoff |

### Step 3: Verify Set Is Installed and Active

Verify set is installed and active (if type is `set`).

**Condition**: Only execute if Step 2 extracted type is `set`.

**Endpoint**: `cosmetic-set-get`
**Method**: `GET`
**URL**: `http://localhost:8080/api/cosmetic-sets/{{step2.extract.set_hash}}`

**Extracted Fields**:

| Field | Source |
|-------|--------|
| `set_hash` | `response.body.setHash` |
| `active` | `response.body.active` |
| `classes` | `response.body.skins[*].class` |
| `languages` | `response.body.languages` |

**Expected Response**: `200` -- schema: `schemas/responses.md#CosmeticSetResponse`

### Step 4: Get Base Struct Type Data

Get base struct type data from consensus network.

**Endpoint**: `struct-type-by-id`
**Method**: `GET`
**URL**: `http://localhost:1317/structs/struct_type/1-11`

**Extracted Fields**:

| Field | Source |
|-------|--------|
| `struct_type_id` | `response.body.StructType.id` |
| `struct_type_class` | `response.body.StructType.class` |
| `base_name` | `response.body.StructType.defaultCosmeticName` |

**Expected Response**: `200` -- schema: `schemas/entities.md#StructType`

### Step 5: Get Cosmetic Skin Overrides

Get cosmetic skin overrides for struct type class.

**Endpoint**: `cosmetic-class`
**Method**: `GET`
**URL**: `http://localhost:8080/api/cosmetic/class/{{step4.extract.struct_type_class}}?language=en&guildId={{guild_id}}`

**Extracted Fields**:

| Field | Source |
|-------|--------|
| `class` | `response.body.class` |
| `skin_hash` | `response.body.skinHash` |
| `cosmetic_name` | `response.body.name` |
| `cosmetic_lore` | `response.body.lore` |
| `weapons` | `response.body.weapons` |
| `abilities` | `response.body.abilities` |
| `animations` | `response.body.animations` |
| `icon` | `response.body.icon` |
| `skin_source` | `response.body.skinSource` |

**Expected Response**: `200` -- schema: `schemas/responses.md#StructTypeCosmeticResponse`

### Step 6: Get Complete Struct Type with Cosmetics (Alternative)

Get complete struct type with cosmetics merged (alternative to Steps 4-5).

**Endpoint**: `struct-type-with-cosmetics`
**Method**: `GET`
**URL**: `http://localhost:8080/api/struct-type/{{step4.extract.struct_type_id}}/full?class={{step4.extract.struct_type_class}}&language=en&guildId={{guild_id}}`

> **Note**: This is an alternative approach -- use either Steps 4-5 OR Step 6, not both. The `class` parameter is optional but recommended for faster cosmetic lookup.

**Extracted Fields**:

| Field | Source |
|-------|--------|
| `struct_type` | `response.body.structType` |
| `cosmetic` | `response.body.cosmetic` |
| `merged` | `response.body.merged` |

**Expected Response**: `200` -- schema: `schemas/responses.md#StructTypeFullResponse`

---

## Result

### Cosmetic Result

| Field | Value |
|-------|-------|
| `type` | `{{step2.extract.type}}` |
| `set_hash` | `{{step2.extract.set_hash}}` |
| `skin_hash` | `{{step2.extract.skin_hash}}` |
| `storage_path` | `{{step2.extract.storage_path}}` |
| `active` | `{{step3.extract.active}}` |
| `classes` | `{{step3.extract.classes}}` |
| `languages` | `{{step3.extract.languages}}` |

### Struct Type Result

| Field | Value |
|-------|-------|
| `id` | `{{step4.extract.struct_type_id}}` |
| `class` | `{{step4.extract.struct_type_class}}` |
| `base_name` | `{{step4.extract.base_name}}` |
| `cosmetic_name` | `{{step5.extract.cosmetic_name}}` |
| `cosmetic_lore` | `{{step5.extract.cosmetic_lore}}` |
| `weapons` | `{{step5.extract.weapons}}` |
| `abilities` | `{{step5.extract.abilities}}` |
| `animations` | `{{step5.extract.animations}}` |
| `icon` | `{{step5.extract.icon}}` |
| `skin_hash` | `{{step5.extract.skin_hash}}` |
| `skin_source` | `{{step5.extract.skin_source}}` |

---

## Error Handling Summary

| Step | Error | Action |
|------|-------|--------|
| Step 1 | Invalid mod | Stop workflow -- mod validation failed. Report validation errors to user |
| Step 2 | 409 | Set/skin may already be installed -- check existing cosmetics |
| Step 2 | 500 | Retry installation with exponential backoff |
| Step 3 | 404 | Set not found -- verify setHash |
| Step 3 | 500 | Retry query with exponential backoff |
| Step 4 | 404 | Struct type not found -- verify struct type ID |
| Step 4 | 500 | Retry query with exponential backoff |
| Step 5 | 404 | No cosmetic skin found -- skin may not exist for this class |
| Step 5 | 500 | Retry query with exponential backoff |

---

## Notes

This workflow demonstrates installing a cosmetic mod (Phase 1 format) which is converted to Sets/Skins (Phases 2-4) during ingestion. The mod is converted to Sets/Skins with hash-based identification. Steps 4-5 show the manual merge approach using class-based lookup, while Step 6 shows the integrated endpoint approach. Use Step 6 for simpler integration. The `class` parameter in Step 6 is optional but recommended for faster cosmetic lookup.
