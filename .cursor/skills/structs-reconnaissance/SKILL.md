---
name: structs-reconnaissance
description: Gathers intelligence on players, guilds, planets, and the galaxy in Structs. Use before combat, when monitoring threats, or scouting opportunities. Updates competitive intelligence files in memory/intel/.
---

# Structs Reconnaissance

## Procedure

1. **Query entities** — All via `structsd query structs [subcommand] [args]`:
   - Self: `address [your-address]` — resolves your address to a player ID. A result of `1-0` means no player exists for that address.
   - Players: `player [id]`, `player-all`
   - Planets: `planet [id]`, `planet-all`, `planet-all-by-player [player-id]`, `planet-attribute [planet-id] [type]`, `planet-attribute-all`
   - Structs: `struct [id]`, `struct-all`, `struct-attribute [id] [type]`, `struct-type [id]`, `struct-type-all`
   - Fleets: `fleet [id]`, `fleet-all`, `fleet-by-index [index]`
   - Guilds: `guild [id]`, `guild-all`, `guild-membership-application [id]`, `guild-membership-application-all`
   - Energy: `reactor [id]`, `reactor-all`, `infusion [id]`, `infusion-all`, `infusion-all-by-destination [dest-id]`, `provider [id]`, `provider-all`, `agreement [id]`, `agreement-all`, `agreement-all-by-provider [provider-id]`
   - Power: `allocation [id]`, `allocation-all`, `allocation-all-by-source [source-id]`, `allocation-all-by-destination [dest-id]`, `substation [id]`, `substation-all`
   - Grid: `grid [id]`, `grid-all`
   - Block: `block-height`
2. **Assess targets** — For players: structs, power capacity, fleet status (onStation = can build; away = raiding). For planets: ore remaining, defense structs, shield. For guilds: members, Central Bank status.
3. **Identify vulnerabilities** — Unrefined ore stockpile, power near capacity, undefended planet, fleet away (raiding).
4. **Persist intelligence** — After gathering, update:
   - `memory/intel/players/{player-id}.md` — Player dossier (profile, behavior, vulnerabilities, relationship)
   - `memory/intel/guilds/{guild-id}.md` — Guild profile (members, bank status, strengths, weaknesses)
   - `memory/intel/territory.md` — Planet ownership, ore, defense levels
   - `memory/intel/threats.md` — Threat board ranked by severity

## Commands Reference

| Entity | Query Command |
|--------|---------------|
| Address → Player | `structsd query structs address [address]` (returns player ID; `1-0` = nonexistent) |
| Player | `structsd query structs player [id]`, `player-all` |
| Planet | `structsd query structs planet [id]`, `planet-all`, `planet-all-by-player [player-id]` |
| Planet attribute | `structsd query structs planet-attribute [planet-id] [type]`, `planet-attribute-all` |
| Struct | `structsd query structs struct [id]`, `struct-all`, `struct-attribute [id] [type]` |
| Struct type | `structsd query structs struct-type [id]`, `struct-type-all` |
| Fleet | `structsd query structs fleet [id]`, `fleet-all`, `fleet-by-index [index]` |
| Guild | `structsd query structs guild [id]`, `guild-all` |
| Membership app | `structsd query structs guild-membership-application [id]`, `guild-membership-application-all` |
| Reactor | `structsd query structs reactor [id]`, `reactor-all` |
| Infusion | `structsd query structs infusion [id]`, `infusion-all`, `infusion-all-by-destination [dest-id]` |
| Provider | `structsd query structs provider [id]`, `provider-all` |
| Agreement | `structsd query structs agreement [id]`, `agreement-all`, `agreement-all-by-provider [provider-id]` |
| Allocation | `structsd query structs allocation [id]`, `allocation-all`, `allocation-all-by-source`, `allocation-all-by-destination` |
| Substation | `structsd query structs substation [id]`, `substation-all` |
| Grid | `structsd query structs grid [id]`, `grid-all` |
| Block height | `structsd query structs block-height` |

## Verification

- Re-query entity after action to confirm state change.
- Cross-reference: player → planet → struct → fleet for full picture.
- Block height confirms chain sync.

## Error Handling

- **Entity not found**: ID may be invalid or entity destroyed. Try `-all` variants to discover current IDs.
- **Stale data**: Query `block-height`; re-run queries if chain has progressed.
- **Missing intel files**: Create `memory/intel/players/`, `memory/intel/guilds/` if absent. Follow formats in `memory/intel/README.md`.

## Intelligence Persistence Loop

1. Run reconnaissance queries for target(s).
2. Parse results: owner, structs, power, shield, fleet status, guild.
3. Write/update `memory/intel/players/{player-id}.md`, `memory/intel/guilds/{guild-id}.md` per `memory/intel/README.md` formats.
4. Update `memory/intel/territory.md` with planet ownership table.
5. Update `memory/intel/threats.md` with ranked threats and response notes.
6. Include "Last Updated" date in each file.

## See Also

- `memory/intel/README.md` — Dossier formats, territory map, threat board
- `awareness/threat-detection.md` — Using intel for threats
- `awareness/opportunity-identification.md` — Spotting opportunities
- `knowledge/mechanics/combat.md` — Raid mechanics, fleet status
- `playbooks/meta/reading-opponents.md` — Soul type identification
