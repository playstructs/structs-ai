# Validation Rules and Patterns

**Version**: 1.0.0
**Category**: validation
**Schema**: JSON Schema Draft-07
**Description**: Validation rules, patterns, and validators for AI agents to validate API requests and responses. See `schemas/formats.md` for format specifications.

---

## Definitions

### ValidationRule

A validation rule definition.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Yes | Unique rule identifier |
| name | string | Yes | Rule name |
| field | string | No | Field to validate (dot notation) |
| type | string | Yes | Validation type: `required`, `type`, `format`, `range`, `pattern`, or `custom` |
| value | any | No | Validation value (depends on type) |
| message | string | No | Error message if validation fails |

### ValidationPattern

A validation pattern composed of multiple rules.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Yes | Pattern identifier |
| name | string | Yes | Pattern name |
| description | string | No | Pattern description |
| rules | array of ValidationRule | Yes | Validation rules for this pattern |

---

## Input Validation

### playerId

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| required | boolean | true | Whether field is required |
| type | string | `string` | Allowed types: `string`, `number` |
| pattern | string | | Regex pattern for player ID format |

### planetId

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| required | boolean | true | Whether field is required |
| type | string | `string` | Allowed type: `string` |
| pattern | string | | Regex pattern for planet ID format (e.g., `\d+-\d+`) |

### blockchainAddress

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| required | boolean | true | Whether field is required |
| type | string | `string` | Allowed type: `string` |
| pattern | string | | Regex pattern for blockchain address (e.g., `^structs1[a-z0-9]{38}$`) |

---

## Response Validation

### statusCode

| Property | Type | Description |
|----------|------|-------------|
| expected | array of integer | Expected status codes |
| retryable | array of integer | Retryable status codes (5xx) |

### requiredFields

Required fields by endpoint, defined as key-value pairs where the key is the endpoint path and the value is an array of required field names.

### schemaValidation

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| enabled | boolean | true | Whether schema validation is enabled |
| strict | boolean | false | Strict schema validation (reject unknown fields) |

---

## Transaction Validation

### messageType

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| required | boolean | true | Whether message type is required |
| pattern | string | | Message type pattern (e.g., `/structs.structs.Msg.*`) |

### creator

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| required | boolean | true | Whether creator address is required |
| format | string | `blockchain-address` | Expected format |

### gasLimit

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| min | integer | 200000 | Minimum gas limit |
| max | integer | 10000000 | Maximum gas limit |

---

## Validation Patterns

### Player Query Validation

**ID**: `player-query`

Validation for player query endpoints.

| Rule ID | Rule Name | Field | Type | Value | Message |
|---------|-----------|-------|------|-------|---------|
| player-id-required | Player ID Required | id | required | | Player ID is required |
| player-id-format | Player ID Format | id | pattern | `^1-[0-9]+$` | Player ID must be in format `1-X` where X is the player index (e.g., `1-11`) |

### Planet Query Validation

**ID**: `planet-query`

Validation for planet query endpoints.

| Rule ID | Rule Name | Field | Type | Value | Message |
|---------|-----------|-------|------|-------|---------|
| planet-id-required | Planet ID Required | id | required | | Planet ID is required |
| planet-id-format | Planet ID Format | id | pattern | `^2-[0-9]+$` | Planet ID must be in format `2-X` where X is the planet index (e.g., `2-1`) |

### Transaction Validation

**ID**: `transaction`

Validation for transaction submission.

| Rule ID | Rule Name | Field | Type | Value | Message |
|---------|-----------|-------|------|-------|---------|
| message-type-required | Message Type Required | body.messages[].@type | required | | Message type is required |
| creator-required | Creator Required | body.messages[].creator | required | | Creator address is required |
| creator-format | Creator Format | body.messages[].creator | format | `blockchain-address` | Creator must be a valid blockchain address |
| gas-limit-range | Gas Limit Range | auth_info.fee.gas_limit | range | min: 200000, max: 10000000 | Gas limit must be between 200000 and 10000000 |

---

## Validators

Standalone validators for common field types.

| Validator | Type | Pattern | Description |
|-----------|------|---------|-------------|
| playerId | string | `^1-[0-9]+$` | Player ID must be in format `1-X` where X is the player index (e.g., `1-11`). Type 1 = Player. |
| planetId | string | `^2-[0-9]+$` | Planet ID must be in format `2-X` where X is the planet index (e.g., `2-1`). Type 2 = Planet. |
| blockchainAddress | string | `^structs1[a-z0-9]{38}$` | Blockchain address must start with `structs1` and be 45 characters |
| structId | string | `^5-[0-9]+$` | Struct ID must be in format `5-X` where X is the struct index (e.g., `5-42`). Type 5 = Struct. |
| fleetId | string | `^9-[0-9]+$` | Fleet ID must be in format `9-X` where X is the fleet index (e.g., `9-11`). Type 9 = Fleet. |
| guildId | string | `^0-[0-9]+$` | Guild ID must be in format `0-X` where X is the guild index (e.g., `0-1`). Type 0 = Guild. |

---

## Response Validation Rules

### Required Fields by Endpoint

| Endpoint | Required Fields |
|----------|----------------|
| `/structs/player/{id}` | Player, gridAttributes, playerInventory, halted |
| `/structs/planet/{id}` | Planet, gridAttributes, planetAttributes |
| `/structs/guild/{id}` | Guild |
| `/api/player/{player_id}` | player |
| `/api/planet/{planet_id}` | planet |

### Status Codes

| Category | Codes |
|----------|-------|
| Expected | 200 |
| Retryable | 500, 502, 503, 504 |
| Client Errors | 400, 401, 403, 404 |
| Server Errors | 500, 502, 503, 504 |

---

## Action Validation

### Struct Build Validation

**ID**: `struct-build-validation`

Validation requirements for `MsgStructBuild`.

#### Pre-Action Checks

| Check ID | Name | Query | Field | Expected | Condition | Message |
|----------|------|-------|-------|----------|-----------|---------|
| player-online | Player Online | `GET /structs/player/{playerId}` | halted | false | | Player must be online (not halted) |
| command-ship-online | Command Ship Online | `GET /structs/fleet/{fleetId}` | | | locationType = planet | Command Ship must be built and online in fleet |
| fleet-on-station | Fleet On Station | `GET /structs/fleet/{fleetId}` | status | onStation | locationType = planet | Fleet must be on station (not away) |
| sufficient-power | Sufficient Power | `GET /structs/player/{playerId}` | gridAttributes.power | | | Must have sufficient power capacity |

#### Post-Action Verification

- **Query**: `GET /structs/struct`
- **Filter**: By locationId
- **Expected**: Struct exists at location
- **On Failure**: Check requirements and retry

### Planet Exploration Validation

**ID**: `planet-explore-validation`

Validation requirements for `MsgPlanetExplore`.

#### Pre-Action Checks

| Check ID | Name | Query | Field | Expected | Message |
|----------|------|-------|-------|----------|---------|
| current-planet-empty | Current Planet Empty | `GET /structs/planet/{currentPlanetId}` | gridAttributes.ore | 0 | Current planet must have 0 ore before exploring new planet |
| player-online | Player Online | `GET /structs/player/{playerId}` | halted | false | Player must be online |

#### Post-Action Verification

- **Query**: `GET /structs/planet_by_player/{playerId}`
- **Expected**: New planet owned by player
- **On Failure**: Current planet still has ore

---

## Common Failures

### Transaction Broadcasts But Action Doesn't Occur

**ID**: `broadcast-no-result`

Transaction shows `broadcast` status but action didn't happen.

- **Symptom**: Transaction status = `broadcast` but game state unchanged
- **Cause**: On-chain validation failed (requirements not met)

**Diagnosis**:
1. Query game state to verify action occurred
2. Compare expected vs actual game state
3. Check action requirements in `schemas/actions.md`
4. Identify missing requirement

**Solution**:
1. Fix missing requirement
2. Retry action
3. Verify success

**Prevention**:
1. Always check requirements before acting
2. Query game state before action
3. Verify all requirements met
4. Then perform action

### Building on Planet Without Command Ship

**ID**: `command-ship-not-online`

Attempting to build on planet without Command Ship online.

- **Symptom**: `MsgStructBuild` broadcasts but struct not created on planet
- **Cause**: Command Ship not built or not online in fleet

**Diagnosis**:
1. Query fleet: `GET /structs/fleet/{fleetId}`
2. Check for Command Ship struct
3. Verify Command Ship status is `online` (not just materialized)
4. Verify fleet status is `onStation`

**Solution**:
1. Build Command Ship in fleet (`MsgStructBuild`)
2. Complete Command Ship build (`MsgStructBuildComplete`)
3. Activate Command Ship (bring online)
4. Then build on planets

**Reference**: See `schemas/actions.md` MsgStructBuild for complete requirements.

### Building Without Sufficient Power

**ID**: `insufficient-power`

Attempting to build struct without sufficient power capacity.

- **Symptom**: `MsgStructBuild` broadcasts but struct not created
- **Cause**: Insufficient power capacity for struct passive draw

**Diagnosis**:
1. Query player: `GET /structs/player/{playerId}`
2. Check `gridAttributes.power` (current power)
3. Check struct requirements for passive draw
4. Verify capacity > current load + struct load

**Solution**:
1. Increase power capacity (build reactors/generators)
2. Reduce current power load
3. Then retry build

### Exploration With Ore Remaining

**ID**: `planet-not-empty`

Attempting to explore new planet while current planet has ore.

- **Symptom**: `MsgPlanetExplore` broadcasts but planet ownership unchanged
- **Cause**: Current planet still has ore remaining

**Diagnosis**:
1. Query current planet: `GET /structs/planet/{planetId}`
2. Check `gridAttributes.ore`
3. Verify ore amount is 0

**Solution**:
1. Mine all ore from current planet
2. Verify ore = 0
3. Then explore new planet

---

## Validation Flow

### Transaction Flow

1. Create transaction (pending)
2. Sign transaction
3. Submit to `POST /cosmos/tx/v1beta1/txs`
4. Transaction moves to `broadcast` status
5. On-chain validation occurs
6. Action succeeds OR fails based on validation
7. Query game state to verify action actually occurred
8. If action didn't occur, check requirements and retry

### Verification Pattern

1. Submit transaction
2. Wait for transaction to reach `broadcast` status
3. Query game state to verify action actually occurred
4. If action didn't occur, check requirements
5. Fix requirements and retry if needed

### Pre-Action Check Pattern

1. Query current game state
2. Verify all requirements met (see Action Validation above)
3. If not met, fix requirements first
4. Then perform action

---

**IMPORTANT**: Transaction status `broadcast` does NOT mean action succeeded. Validation happens on-chain after broadcast. Always verify game state to confirm action occurred.

---

## References

- `schemas/actions.md` - Complete action requirements
- `patterns/validation-patterns.md` - Detailed validation patterns
- `protocols/error-handling.md` - Error handling patterns
