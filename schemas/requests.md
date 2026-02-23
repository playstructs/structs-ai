# API Request Schemas

**Version**: 1.0.0
**Category**: api
**Schema**: JSON Schema Draft-07
**Description**: Complete catalog of all API request body formats for AI agents. See `schemas/formats.md` for format specifications.

---

## Request Type Index

| Category | Request Types |
|----------|--------------|
| Authentication | AuthSignupRequest, AuthLoginRequest |
| Player | PlayerUsernameUpdateRequest, PlayerRaidSearchQuery, PlayerTransferSearchQuery |
| Player Address | PlayerAddressAddPendingRequest, PlayerAddressMetaRequest, PlayerAddressActivationCodeRequest, PlayerAddressPendingPermissionsRequest, PlayerAddressPermissionsRequest |
| Transaction | TransactionRequest |
| Query | QueryParameters, PlayerRaidSearchQuery, PlayerTransferSearchQuery, GuildNameFilterQuery, GuildDirectoryQuery |
| Cosmetic Mod | CosmeticModInstallRequest, CosmeticModValidateRequest |

---

## Authentication Requests

### AuthSignupRequest

Register a new player account.

- **Endpoint**: `POST /api/auth/signup`

| Field | Type | Format | Required | Description |
|-------|------|--------|----------|-------------|
| address | string | blockchain-address | Yes | Blockchain address (e.g., `cosmos1...`) |
| signature | string | | Yes | Signature for authentication |
| message | string | | Yes | Message to sign |

### AuthLoginRequest

Authenticate and log in a player.

- **Endpoint**: `POST /api/auth/login`

| Field | Type | Format | Required | Description |
|-------|------|--------|----------|-------------|
| address | string | blockchain-address | Yes | Blockchain address |
| signature | string | | Yes | Signature for authentication |
| message | string | | Yes | Message to sign |

---

## Player Requests

### PlayerUsernameUpdateRequest

Update player username.

- **Endpoint**: `PUT /api/player/username`

| Field | Type | Format | Required | Constraints | Description |
|-------|------|--------|----------|-------------|-------------|
| username | string | | Yes | minLength: 3, maxLength: 20, pattern: `^[a-zA-Z0-9_]+$` | New username |

### PlayerRaidSearchQuery

Query parameters for player raid search.

- **Endpoint**: `GET /api/player/raid/search`

| Field | Type | Format | Required | Description |
|-------|------|--------|----------|-------------|
| player_id | string | entity-id | No | Player identifier in format `type-index` (e.g., `1-11`). Pattern: `^1-[0-9]+$`. Type 1 = Player. |
| status | string | | No | Raid status filter. Values: `active`, `completed`, `failed` |

### PlayerTransferSearchQuery

Query parameters for player transfer search.

- **Endpoint**: `GET /api/player/transfer/search`

| Field | Type | Format | Required | Description |
|-------|------|--------|----------|-------------|
| player_id | string | entity-id | No | Player identifier in format `type-index` (e.g., `1-11`). Pattern: `^1-[0-9]+$`. Type 1 = Player. |
| from | string | date-time | No | Start date for search |
| to | string | date-time | No | End date for search |

---

## Player Address Requests

### PlayerAddressAddPendingRequest

Add player pending address.

- **Endpoint**: `POST /api/auth/player-address`

| Field | Type | Format | Required | Description |
|-------|------|--------|----------|-------------|
| address | string | blockchain-address | Yes | Blockchain address to add |
| player_id | string | entity-id | Yes | Player identifier in format `type-index` (e.g., `1-11`). Pattern: `^1-[0-9]+$`. Type 1 = Player. |

### PlayerAddressMetaRequest

Add player address metadata.

- **Endpoint**: `POST /api/player-address/meta`

| Field | Type | Format | Required | Description |
|-------|------|--------|----------|-------------|
| address | string | blockchain-address | Yes | Blockchain address |
| meta | object | | Yes | Metadata object (arbitrary key-value pairs) |

### PlayerAddressActivationCodeRequest

Create player address activation code.

- **Endpoint**: `POST /api/player-address/activation-code`

| Field | Type | Format | Required | Description |
|-------|------|--------|----------|-------------|
| address | string | blockchain-address | Yes | Blockchain address |
| player_id | string | entity-id | Yes | Player identifier in format `type-index` (e.g., `1-11`). Pattern: `^1-[0-9]+$`. Type 1 = Player. |

### PlayerAddressPendingPermissionsRequest

Set pending address permissions.

- **Endpoint**: `PUT /api/player-address/pending/permissions`

| Field | Type | Format | Required | Description |
|-------|------|--------|----------|-------------|
| address | string | blockchain-address | Yes | Blockchain address |
| permissions | array of string | | Yes | List of permissions |

### PlayerAddressPermissionsRequest

Set address permissions.

- **Endpoint**: `PUT /api/player-address/permissions`

| Field | Type | Format | Required | Description |
|-------|------|--------|----------|-------------|
| address | string | blockchain-address | Yes | Blockchain address |
| permissions | array of string | | Yes | List of permissions |

---

## Transaction Requests

### TransactionRequest

Cosmos SDK transaction request. See `schemas/actions.md` for complete message type definitions.

- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| body | object | Yes | Transaction body |
| auth_info | object | Yes | Authentication information |
| signatures | array of string | Yes | Transaction signatures (base64 encoded), minimum 1 |

#### body

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| messages | array of TransactionMessage | Yes | Array of transaction messages (minimum 1). See `schemas/actions.md` for complete message schemas. |
| memo | string | No | Transaction memo |
| timeout_height | string | No | Timeout height |

#### auth_info

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| signer_infos | array | Yes | Signer information |
| fee | object | Yes | Transaction fee |

Each entry in `signer_infos`:

| Field | Type | Description |
|-------|------|-------------|
| public_key | object | Public key information |
| mode_info | object | Signing mode information |
| sequence | string | Account sequence number |

The `fee` object:

| Field | Type | Description |
|-------|------|-------------|
| amount | array | Fee amount entries, each with `denom` (e.g., `ustructs`) and `amount` (as string) |
| gas_limit | string | Gas limit |
| payer | string (blockchain-address) | Fee payer address (optional) |
| granter | string (blockchain-address) | Fee granter address (optional) |

### TransactionMessage

Base transaction message structure. All messages must include `@type`. See `schemas/actions.md` for specific message schemas.

Each message type has specific required fields beyond what is listed here.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| @type | string | Yes | Message type URL (see below) |
| creator | string (blockchain-address) | Varies | Transaction creator address (required for most messages) |

#### Available Message Types

The `@type` field must be one of the following active (non-deprecated) message types:

| Message Type | Description |
|-------------|-------------|
| `/structs.structs.MsgStructBuild` | Build a struct |
| `/structs.structs.MsgStructBuildInitiate` | Initiate struct build |
| `/structs.structs.MsgStructBuildComplete` | Complete struct build |
| `/structs.structs.MsgStructActivate` | Activate a struct |
| `/structs.structs.MsgStructDeactivate` | Deactivate a struct |
| `/structs.structs.MsgStructStealthActivate` | Stealth activate a struct |
| `/structs.structs.MsgStructStealthDeactivate` | Stealth deactivate a struct |
| `/structs.structs.MsgStructAttack` | Attack with a struct |
| `/structs.structs.MsgStructDefenseSet` | Set struct defense |
| `/structs.structs.MsgStructDefenseClear` | Clear struct defense |
| `/structs.structs.MsgStructMove` | Move a struct |
| `/structs.structs.MsgStructOreMinerComplete` | Complete ore mining |
| `/structs.structs.MsgStructOreRefineryComplete` | Complete ore refining |
| `/structs.structs.MsgPlanetExplore` | Explore a planet |
| `/structs.structs.MsgPlanetRaidComplete` | Complete a planet raid |
| `/structs.structs.MsgFleetMove` | Move a fleet |
| `/structs.structs.MsgReactorInfuse` | Infuse a reactor |
| `/structs.structs.MsgReactorDefuse` | Defuse a reactor |
| `/structs.structs.MsgSubstationCreate` | Create a substation |
| `/structs.structs.MsgSubstationPlayerConnect` | Connect player to substation |
| `/structs.structs.MsgProviderCreate` | Create a provider |
| `/structs.structs.MsgGuildCreate` | Create a guild |
| `/structs.structs.MsgGuildMembershipJoin` | Join a guild |
| `/structs.structs.MsgGuildBankMint` | Mint from guild bank |
| `/structs.structs.MsgGuildBankRedeem` | Redeem from guild bank |

Deprecated message types (removed from enum): `MsgReactorAllocate`, `MsgSubstationConnect`, `MsgAgreementCreate`, `MsgOreMining`, `MsgOreRefining`, `MsgGeneratorAllocate`, `MsgGuildMembershipLeave`. See `reference/action-index.md` for deprecated types and their replacements.

---

## Query Parameters

### QueryParameters

Common query parameters for list endpoints.

| Field | Type | Default | Constraints | Description |
|-------|------|---------|-------------|-------------|
| pagination.key | string | | | Pagination key for next page |
| pagination.limit | integer | 50 | min: 1, max: 100 | Number of items per page |
| pagination.offset | integer | | min: 0 | Number of items to skip |

### GuildNameFilterQuery

Query parameters for guild name filter.

- **Endpoint**: `GET /api/guild/name`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| filter | string | No | Name filter string |

### GuildDirectoryQuery

Query parameters for guild directory.

- **Endpoint**: `GET /api/guild/directory`

| Field | Type | Default | Constraints | Description |
|-------|------|---------|-------------|-------------|
| page | integer | 1 | min: 1 | Page number |
| limit | integer | 20 | min: 1, max: 100 | Items per page |

---

## Cosmetic Mod Requests

### CosmeticModInstallRequest

Install cosmetic mod.

- **Endpoint**: `POST /api/cosmetic-mods/install`

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| file | string | | Yes | Path to mod file (ZIP) or directory, or file upload in multipart/form-data |
| validate | boolean | true | No | Whether to validate mod before installation |
| activate | boolean | true | No | Whether to activate mod after installation |

### CosmeticModValidateRequest

Validate cosmetic mod.

- **Endpoint**: `POST /api/cosmetic-mods/validate`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| file | string | Yes | Path to mod file (ZIP) or directory, or file upload in multipart/form-data |
