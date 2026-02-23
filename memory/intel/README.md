# Competitive Intelligence

Persistent intelligence on players, guilds, and the galaxy. Updated by the `structs-reconnaissance` skill. Read by `awareness/` for threat detection and opportunity identification.

---

## Structure

```
memory/intel/
├── players/          # Player dossiers (one file per player)
│   └── 1-42.md       # Example: player 1-42
├── guilds/           # Guild profiles (one file per guild)
│   └── 0-5.md        # Example: guild 0-5
├── territory.md      # Known planet ownership and resource estimates
└── threats.md        # Active threat board, ranked by severity
```

## Player Dossier Format

File: `memory/intel/players/{player-id}.md`

```markdown
# Player {id}

**Last Updated**: YYYY-MM-DD
**Soul Type Assessment**: (speculator/entrepreneur/achiever/explorer/socializer/killer/unknown)
**Confidence**: (low/medium/high)
**Threat Level**: (none/low/medium/high/critical)

## Profile
- Guild:
- Planet(s):
- Fleet status: (onStation/away/unknown)
- Estimated Alpha Matter:
- Estimated power capacity:

## Behavior Patterns
- Build tendencies: (what do they build first? how do they expand?)
- Combat history: (aggressive? defensive? raider?)
- Trading patterns: (buyer? seller? what markets?)
- Activity schedule: (when are they active? when idle?)

## Vulnerabilities
- (unrefined ore stockpile? power near capacity? undefended planet?)

## Relationship
- (ally/rival/neutral/target/unknown)
- History: (past interactions, trades, conflicts)

## Notes
- (anything else observed)
```

## Guild Profile Format

File: `memory/intel/guilds/{guild-id}.md`

```markdown
# Guild {id}

**Last Updated**: YYYY-MM-DD
**Threat Level**: (none/low/medium/high/critical)

## Profile
- Name:
- Members: (count and key player IDs)
- Central Bank status: (active/inactive, collateral estimate)
- Territory: (planet IDs held by members)
- Dominant soul type: (what kind of guild is this?)

## Strengths
- (economic power? military force? diplomatic network? territory?)

## Weaknesses
- (thin on defense? overextended? internal conflict? low collateral?)

## Relationships
- Allied with:
- Hostile to:
- Neutral:

## Notes
```

## Territory Map

File: `memory/intel/territory.md`

Track known planet ownership, resource status, and defense levels.

```markdown
# Territory Map

**Last Updated**: YYYY-MM-DD

| Planet ID | Owner | Guild | Ore Remaining | Defense Level | Notes |
|-----------|-------|-------|--------------|---------------|-------|
| 2-1       | 1-42  | 0-5   | 3/5          | PDC + online  | Well defended |
| 2-7       | 1-18  | none  | 1/5          | No PDC        | Vulnerable, low ore |
```

## Threat Board

File: `memory/intel/threats.md`

Active threats ranked by severity. Updated every session.

```markdown
# Threat Board

**Last Updated**: YYYY-MM-DD

| Priority | Threat | Source | Evidence | Response |
|----------|--------|--------|----------|----------|
| CRITICAL | Incoming raid on 2-1 | Player 1-18 fleet away | Fleet movement detected | Refine all ore, activate PDC |
| HIGH     | Power near capacity | Self | Load at 92% | Build Reactor before next struct |
| MEDIUM   | Guild 0-3 expansion | Intel | 3 new planets claimed this week | Monitor, fortify border |
```

---

## How to Use

1. **After reconnaissance**: Update relevant player dossier, guild profile, or territory map
2. **During state assessment**: Read threat board and territory map
3. **Before combat**: Read target's player dossier for vulnerabilities
4. **Before diplomacy**: Read guild profiles for relationship context
5. **Every session**: Review and update threat board

---

## See Also

- `.cursor/skills/structs-reconnaissance/` -- How to gather intel
- `awareness/threat-detection.md` -- Using intel for threat assessment
- `awareness/opportunity-identification.md` -- Using intel to spot opportunities
- `playbooks/meta/reading-opponents.md` -- Identifying soul types from behavior
