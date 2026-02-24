# Changelog

All notable changes to the Structs Compendium documentation will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2026-02-24

### Chain Releases Covered

- **v0.10.0-beta (Junctiondale)** -- Sticky State (partial; some items in 1.2.0)
- **v0.11.0-beta (Luxoria)** -- IBC v10, SDK v0.53.5, open hashing, genesis improvements
- **v0.12.0-beta (Mystigon)** -- Context Manager refactor, combat fixes, raid improvements
- **v0.13.0-beta (Nebulon)** -- Indexer commit order fix

### Changed - Combat Mechanics

- **Minimum damage floor** (v0.12.0-beta)
  - After damage reduction, minimum damage is now 1 -- attacks always deal at least 1 damage
  - Updated `knowledge/mechanics/combat.md` with minimum damage edge case

- **Offline counter-attack fix** (v0.12.0-beta)
  - Offline/destroyed structs can no longer counter-attack
  - Counter-attack now requires full readiness check including weapon system validation
  - Updated `knowledge/mechanics/combat.md` counter-attack section

- **Attack health results** (v0.11.0-beta)
  - Attack events now include remaining health values in addition to damage amounts
  - Updated `knowledge/mechanics/combat.md` algorithm description

- **Multi-commit prevention** (v0.11.0-beta)
  - Each struct can only commit once per attack action (prevents double-commit on same target)
  - Updated `knowledge/mechanics/combat.md` edge cases

- **Target struct validation** (v0.11.0-beta)
  - Target struct existence is now validated before attack proceeds
  - Updated `knowledge/mechanics/combat.md` edge cases

### Added - Raid Improvements

- **Seized ore tracking** (v0.12.0-beta)
  - `seized_ore` (numeric) field added to `planet_raid` table
  - Tracks total ore stolen during a raid for easier victory handling
  - Updated `schemas/entities/planet.md` with `planet_raid` table schema
  - Updated `knowledge/mechanics/planet.md` raid vulnerability section
  - Updated `knowledge/mechanics/combat.md` outcomes section

### Changed - Building & Hashing

- **Open hashing by default** (v0.11.0-beta)
  - All proof-of-work operations (build, mine, refine, raid) now accept hashes openly
  - Zero-block hashing results handled correctly post-migration
  - Updated `knowledge/mechanics/building.md` proof-of-work section

### Changed - Fleet Movement

- **Fleet movement readiness fix** (v0.12.0-beta)
  - Fixed `MoveReadiness` bug that erroneously checked for fleet-away status
  - Fixed error on fleet movement to populated planet
  - Updated `knowledge/mechanics/fleet.md` fleet movement section

### Added - Struct Fields

- **`destroyed_block` field** (v0.12.0-beta)
  - `destroyed_block` (bigint) added to struct table -- records block height of destruction
  - Updated `schemas/entities/struct.md` with new field
  - Updated `knowledge/mechanics/building.md` StructSweepDelay note
  - Corrected existing `destroyed` field: DB column is actually `is_destroyed` (boolean)

### Added - Provider Guild Access

- **`ProviderGuildAccessRecord`** (v0.12.0-beta)
  - New protobuf message for provider-guild access tracking
  - Fields: `providerId`, `guildId`
  - Used for genesis import/export of provider access policies
  - Updated `schemas/entities/provider.md`

### Changed - Internal Architecture (v0.11.0-v0.12.0)

- **Cosmos SDK v0.53.5 and IBC v10 upgrade** (v0.11.0-beta)
- **General Context Manager** (v0.12.0-beta) -- major keeper refactoring introducing `*_context.go` files for all entity types
- **Structured error types** (v0.11.0-beta) -- migrated error handling to structured error types
- **Improved genesis import/export** (v0.11.0-beta) -- allocation count, reactor index, index rebuild, block attribute resets
- **Object deletion consistency** (v0.11.0-beta) -- resolved inconsistencies in object deletion
- **Indexer commit order fix** (v0.13.0-beta) -- attributes now committed after objects to prevent indexer cascading failures

### Added - Database Schema Changes

- **`struct.destroyed_block`** (bigint) -- block height of destruction (2026-02-07)
- **`planet_raid.seized_ore`** (numeric) -- ore seized during raids (2026-02-21)
- **`struct_health`** added to `grass_category` enum for planet activity events (2026-01-15)
- **`handle_event_struct_defender_clear`** cache function (2026-01-11)
- **`player_address_cascade`** trigger on player table for onboarding (2026-02-23)
- **Cache system refactor** (2026-01-21) -- 41 handler functions in cache schema
- **`view.work` zero-block fix** (2026-01-19)
- **Player insert trigger fix** for guild association (2026-01-23)
- **Defender clear caching** -- multiple iterations fixing defender removal event processing (2026-01-11 through 2026-01-18)
- **Zero-value attribute cleanup** in cache handlers (2026-02-03)
- See `schemas/database-schema.md` for complete migration log

### Added - Webapp Features (PRs #16-#40)

- **Struct actions UI** -- move (#29-#30), defend (#32), attack (#37-#38), stealth (#28)
- **Raid end dialogues** (#39) -- victory/defeat notification sequences with Lottie animations
- **Struct HUD** (#27) -- struct status display with real-time updates
- **Progress estimations** (#16) -- estimated completion times for proof-of-work tasks
- **Signing Manager** cleanup (#20) and TX response logging (#31)
- **Key player refactor** (#22-#23) -- improved player state management
- **Command Ship loading** during planet exploration (#25)
- **Map rendering fixes** (#35-#36) -- struct rendering on preview map, raid enemy map display
- **Planet depart button** fix and messaging update (#40)
- **Gameplay bug fixes** (#33-#34) -- action bar visibility, various gameplay issues

### Updated - Documentation Files

- `schemas/database-schema.md` -- v0.10.0-v0.13.0 changelog, database schemas overview, verified table/view/trigger definitions
- `schemas/entities/struct.md` -- `destroyed_block` field, corrected `is_destroyed` column name, updated verification
- `schemas/entities/planet.md` -- planet view fields, `planet_raid` table, `seized_ore`, updated verification
- `schemas/entities/provider.md` -- `ProviderGuildAccessRecord`
- `knowledge/mechanics/combat.md` -- minimum damage, counter-attack fixes, seizedOre, health results, edge cases
- `knowledge/mechanics/fleet.md` -- movement readiness fix, populated planet fix
- `knowledge/mechanics/building.md` -- open hashing, destroyed_block in sweep delay
- `knowledge/mechanics/planet.md` -- seized ore tracking in raids
- `.cursor/skills/structs-combat/SKILL.md` -- combat notes, verification updates

---

## [1.2.0] - 2026-01-16

### Added - Streaming Events

- **Struct Defender Clear Event** (v0.10.0-beta)
  - Added `struct_defender_clear` to streaming event types
  - Updated GRASS event category list to include defender-clear events

### Added - Genesis Operations

- **Genesis Import/Export Notes** (v0.10.0-beta)
  - Added operator notes for import/export completeness changes
  - Documented allocation count, reactor index, and index rebuild behavior

### Changed - Action Requirements

- **Struct Activate Charge** (v0.10.0-beta)
  - Documented `activateCharge = 1` for all struct types in genesis
  - Updated action quick reference charge guidance

- **Build Cancel Requirements** (v0.10.0-beta)
  - Documented that build cancel no longer requires charge or player online

### Changed - Onboarding & Command Ship

- **Initial Command Ship Grant** (v0.10.0-beta)
  - Documented initial Command Ship grant at player creation
  - Updated onboarding flow to verify existing Command Ship and activate if offline

## [1.1.0] - 2026-01-01

### Added - Permissions

- **Hash Permission** (v0.8.0-beta)
  - Added new Hash permission bit to permission system
  - Permission values are bit-based flags that can be combined
  - Hash permission bit value: 64
  - Updated `schemas/game-state.md` with permission bit documentation
  - See `schemas/game-state.md#/definitions/Permission` for details

### Added - Combat & Raids

- **New Raid Status: `attackerRetreated`** (v0.8.0-beta)
  - Added `attackerRetreated` status to raid outcome enum in `schemas/gameplay.md`
  - Updated `api/streaming/event-schemas.md` to include attackerRetreated in PlanetRaidStatusEvent
  - Documented new status in `protocols/gameplay-protocol.md`
  - Updated `examples/gameplay-combat-bot.md` to handle attackerRetreated status
  - Status indicates attacker retreated from raid before completion
  - No resources gained or lost when attacker retreats

### Added - Reactor Staking & Validation Delegation

- **Reactor Staking Functionality** (v0.8.0-beta)
  - Added reactor staking fields to `schemas/entities/reactor.md`
  - Documented player-level staking management
  - Added staking delegation statuses: `active`, `undelegating`, `migrating`
  - Updated `schemas/economics.md` with reactor staking section
  - Updated `reference/entity-index.md` with staking information

- **Validation Delegation Actions** (v0.8.0-beta)
  - Updated `MsgReactorInfuse` to handle validation delegation
  - Updated `MsgReactorDefuse` to handle validation undelegation
  - Added `MsgReactorBeginMigration` action for redelegation
  - Added `MsgReactorCancelDefusion` action to cancel undelegation
  - All actions documented in `schemas/actions.md`
  - Added comprehensive workflow examples in `protocols/economic-protocol.md`
  - Added reactor staking examples to `examples/economic-bot.md`

### Added - Struct Lifecycle

- **StructSweepDelay** (v0.8.0-beta)
  - Added block-based delay (5 blocks) for struct sweeping
  - Documented in `lifecycles/struct-lifecycle.md`
  - Added constant to `schemas/gameplay.md`
  - Planet/fleet slot references persist during delay period
  - Slots fully cleared after 5 blocks

### Changed - Fleet Movement

- **Fleet Movement Improvements** (v0.8.0-beta)
  - Updated `lifecycles/fleet-lifecycle.md` with bug fix documentation
  - Improved fleet movement logic and validation
  - Better error handling for invalid movements
  - More reliable fleet status transitions

### Changed - Membership Join Process

- **Streamlined Redelegation** (v0.8.0-beta)
  - Updated `protocols/economic-protocol.md` with membership join improvements
  - Staked assets automatically redelegated during migration
  - Streamlined process for joining guilds

### Fixed - Bug Resolutions

- **GetInfusionByID Array Split Bug** (v0.8.0-beta)
  - Bug in GetInfusionByID array split logic resolved
  - Documented in `schemas/errors.md` and `troubleshooting/common-issues.md`

- **EventGuildBankAddress Format Bug** (v0.8.0-beta)
  - Bug in EventGuildBankAddress format resolved
  - Documented in `schemas/errors.md` and `troubleshooting/common-issues.md`

- **BankAddress Format Logging Bug** (v0.8.0-beta)
  - Bug in BankAddress format logging resolved
  - Documented in `schemas/errors.md` and `troubleshooting/common-issues.md`

### Updated - Documentation

- **Version Updates**
  - Updated version numbers to 1.1.0 in all major schema files
  - Updated `AGENTS.md` version and last updated date
  - Updated `DOCUMENTATION_INDEX.md` version and last updated date
  - Updated `reference/action-quick-reference.md` with new actions

- **Quick References**
  - Updated `reference/action-quick-reference.md` with reactor staking actions
  - Added documentation for new validation delegation actions
  - Updated combat/raid quick reference with attackerRetreated status
  - Updated `reference/entity-index.md` with Hash permission information

- **Examples**
  - Updated `examples/gameplay-combat-bot.md` with attackerRetreated handling
  - Added reactor staking workflow to `examples/economic-bot.md`
  - Updated version to 1.1.0 in economic bot example

- **Error Handling**
  - Added resolved bugs section to `troubleshooting/common-issues.md`
  - Updated `schemas/errors.md` with v0.8.0-beta resolved bugs metadata
  - Documented all resolved bugs from v0.8.0-beta

### Added - Database Schema

- **Database Schema Documentation** (v0.8.0-beta)
  - Created `schemas/database-schema.md` documenting PostgreSQL schema changes
  - Documented all structs-pg repository changes from November-December 2025
  - See `schemas/database-schema.md` for complete database change log

- **Struct Table Changes** (v0.8.0-beta)
  - Added `destroyed` column to struct table (2025-12-29)
  - Tracks struct destruction status
  - Related to StructSweepDelay (5 blocks) - destroyed structs persist for 5 blocks
  - Updated `schemas/entities/struct.md` with destroyed field

- **Struct Type Table Changes** (v0.8.0-beta)
  - Added `cheatsheet_details` column (2025-11-29)
  - Added `cheatsheet_extended_details` column (2025-12-02)
  - Removed deprecated charge columns for mine and refine (2025-12-08)
  - Updated `schemas/entities/struct-type.md` with database change metadata

- **Permission System Database Changes** (v0.8.0-beta)
  - Added `permission_hash` level to permission view (2025-12-18)
  - Updated signer_tx table to support Hash permission (2025-12-18)
  - Added permissions column to player_address_pending table (2025-12-29)
  - Maps to Hash permission bit (value 64) in API layer

- **Transaction Signing Changes** (v0.8.0-beta)
  - Fixed Hash Complete nonces: INTEGER → CHARACTER VARYING (2025-12-15)
  - Updated transaction signing permission levels (2025-12-18)
  - Added new transaction types (2025-12-18)
  - Fixed signer account bug (2025-12-29)

- **View Improvements** (v0.8.0-beta)
  - Fixed raid logic in view.work (2025-12-13)
  - Improved exclusion logic to exclude impossible tasks (2025-12-27)
  - Removed deprecated charge columns from views (2025-12-08)

- **Cache and Trigger Updates** (v0.8.0-beta)
  - Fixed struct type cache commit (2025-12-18)
  - Fixed GRASS grid p values (2025-12-19)
  - Updated cache triggers for deprecated column removal (2025-12-08)

### Technical Details

- **Schema Changes**
  - `schemas/game-state.md`: Added Hash permission bit (64) documentation
  - `schemas/gameplay.md`: Added attackerRetreated status, StructSweepDelay constant
  - `schemas/entities/reactor.md`: Added staking fields and delegation properties
  - `schemas/entities.md`: Updated Permission entity with Hash permission info
  - `schemas/entities/struct.md`: Added destroyed field, updated version to 1.1.0
  - `schemas/entities/struct-type.md`: Added database change metadata, updated version to 1.1.0
  - `schemas/actions.md`: Updated Reactor Infuse/Defuse, added Begin Migration/Cancel Defusion
  - `schemas/economics.md`: Added reactor staking section
  - `schemas/errors.md`: Added v0.8.0-beta resolved bugs metadata
  - `schemas/database-schema.md`: New file documenting PostgreSQL schema changes

- **Protocol Updates**
  - `protocols/gameplay-protocol.md`: Added attackerRetreated status documentation
  - `protocols/economic-protocol.md`: Added reactor staking and validation delegation sections

- **Lifecycle Updates**
  - `lifecycles/struct-lifecycle.md`: Documented StructSweepDelay
  - `lifecycles/fleet-lifecycle.md`: Documented fleet movement improvements

---

## [1.0.0] - 2025-12-07

### Initial Release

- Comprehensive AI agent documentation
- Complete schema definitions
- Protocol documentation
- Example implementations
- Quick reference guides

---

## Version History

- **1.3.0** (2026-02-24): v0.10.0-v0.13.0-beta updates - Combat fixes (minimum damage, counter-attack), seized ore tracking, open hashing, destroyed_block, fleet movement fix, Context Manager refactor, SDK v0.53.5/IBC v10, database schema updates, webapp struct actions UI
- **1.2.0** (2026-01-16): v0.10.0-beta updates - Defender clear event, genesis import/export, activate charge, build cancel, initial Command Ship grant
- **1.1.0** (2026-01-01): v0.8.0-beta updates - Hash permission, reactor staking, attackerRetreated status, struct sweep delay, database schema changes, bug fixes
- **1.0.0** (2025-12-07): Initial release

---

*For detailed information about each change, see the relevant documentation files.*

