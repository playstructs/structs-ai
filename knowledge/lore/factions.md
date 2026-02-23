# Factions

**Category**: lore  
**Purpose**: Political and organizational entities for AI agent context

---

## Overview

The galaxy has no single government. Power is distributed among guilds, independent operators, and mercenary networks. Faction affiliation shapes access to resources, protection, and economic tools. AI agents must understand these structures when advising on alliances, raids, and resource allocation.

---

## Guilds

**Primary organizational unit**. Guilds are player-run organizations that pool resources, coordinate fleets, and operate economic infrastructure.

**Formation**: Guilds form when players choose to associate. Membership is explicit. Guilds have IDs, member lists, and shared objectives.

**Control**: Guilds control:
- **Territory**: Through member planets and struct placement
- **Economics**: Via Central Banks (see below)
- **Military**: Coordinated fleets, raid planning, defense agreements

**Tension**: Guild membership offers protection and token access. It also imposes obligations—contributions, defense duties, coordination requirements. Some players prefer independence.

---

## Central Banks

**Guild economic power**. Central Banks mint tokens backed by Alpha Matter collateral held in reserve.

**Mechanics**:
- Tokens derive value from collateral ratio
- Insufficient collateral undermines token credibility
- Guilds with strong reserves can extend credit, pay mercenaries, and fund operations in token rather than raw Alpha Matter

**Strategic importance**: Control of a Central Bank is control of a guild's economic engine. Raids that drain guild Alpha Matter reserves weaken token backing. Agents should consider collateral health when evaluating guild stability.

---

## Independent Operators

**Solo players**. No guild affiliation. Full autonomy, no shared resources.

**Advantages**: No obligations. No guild politics. Decisions are unilateral.

**Disadvantages**: No token access (unless trading for them). No coordinated defense. Easier targets for raids. Must secure own Alpha Matter for energy, trading, and expansion.

**When relevant**: Agents serving independent players must optimize for self-sufficiency—efficient mining, defensive struct placement, and careful raid target selection.

---

## Mercenary Services

**Combat-for-hire**. Players who sell services: raids, fleet support, defense contracts.

**Payment**: Typically Alpha Matter or guild tokens. Payment terms vary; escrow and reputation matter.

**Role**: Mercenaries allow guilds to project power beyond member count. They allow independents to purchase protection or offensive capability. They add liquidity to the conflict economy.

**Agent consideration**: Mercenary contracts may appear in agreement/allocation systems. Verify payment terms and counterparty reputation.

---

## Alliance Dynamics

**Informal and fluid**. Alliances form around:
- Shared enemies
- Resource access (trade routes, planet clusters)
- Economic interest (token acceptance, collateral sharing)

**No formal alliance mechanic** in core game systems. Alliances are social agreements—enforced by reputation, not code. Betrayal is possible. Agents should treat alliance intelligence as probabilistic; verify before acting on assumed cooperation.

---

## Tension: Guild vs. Independent

| Factor | Guild | Independent |
|--------|-------|-------------|
| Token access | Yes (if guild has Central Bank) | No (must trade) |
| Defense | Coordinated | Solo |
| Obligations | Yes | None |
| Autonomy | Shared | Full |
| Raid target profile | Higher value, better defended | Lower value, softer |

The choice is strategic. Guilds scale; independents specialize. Both are viable.

---

## See Also

- [The Universe](universe.md) — Political landscape overview
- [Alpha Matter](alpha-matter.md) — Token backing, collateral
- [The Structs](structs-origin.md) — Primary actors in guild operations
- [Timeline](timeline.md) — Formation of first guilds
- `schemas/entities.md` — Guild entity definition
