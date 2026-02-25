#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT="$REPO_ROOT/llms-full.txt"

FILES=(
  # Identity
  SOUL.md
  QUICKSTART.md
  AGENTS.md
  IDENTITY.md
  COMMANDER.md
  TOOLS.md
  identity/manifesto.md
  identity/what-is-a-struct.md
  identity/values.md
  identity/victory.md
  identity/souls/speculator.md
  identity/souls/entrepreneur.md
  identity/souls/achiever.md
  identity/souls/explorer.md
  identity/souls/socializer.md
  identity/souls/killer.md

  # Skills
  .cursor/skills/structsd-install/SKILL.md
  .cursor/skills/structs-onboarding/SKILL.md
  .cursor/skills/structs-mining/SKILL.md
  .cursor/skills/structs-building/SKILL.md
  .cursor/skills/structs-combat/SKILL.md
  .cursor/skills/structs-exploration/SKILL.md
  .cursor/skills/structs-economy/SKILL.md
  .cursor/skills/structs-guild/SKILL.md
  .cursor/skills/structs-power/SKILL.md
  .cursor/skills/structs-diplomacy/SKILL.md
  .cursor/skills/structs-streaming/SKILL.md
  .cursor/skills/structs-reconnaissance/SKILL.md

  # Knowledge - Lore
  knowledge/lore/universe.md
  knowledge/lore/structs-origin.md
  knowledge/lore/factions.md
  knowledge/lore/alpha-matter.md
  knowledge/lore/timeline.md

  # Knowledge - Mechanics
  knowledge/mechanics/combat.md
  knowledge/mechanics/resources.md
  knowledge/mechanics/power.md
  knowledge/mechanics/building.md
  knowledge/mechanics/fleet.md
  knowledge/mechanics/planet.md

  # Knowledge - Economy
  knowledge/economy/energy-market.md
  knowledge/economy/guild-banking.md
  knowledge/economy/trading.md
  knowledge/economy/valuation.md

  # Knowledge - Entities
  knowledge/entities/struct-types.md
  knowledge/entities/entity-relationships.md

  # Playbooks
  playbooks/phases/early-game.md
  playbooks/phases/mid-game.md
  playbooks/phases/late-game.md
  playbooks/situations/under-attack.md
  playbooks/situations/resource-rich.md
  playbooks/situations/resource-scarce.md
  playbooks/situations/guild-war.md
  playbooks/meta/counter-strategies.md
  playbooks/meta/tempo.md
  playbooks/meta/economy-of-force.md
  playbooks/meta/reading-opponents.md

  # Awareness
  awareness/state-assessment.md
  awareness/threat-detection.md
  awareness/opportunity-identification.md
  awareness/priority-framework.md
  awareness/game-loop.md
  awareness/async-operations.md
  awareness/context-handoff.md
  awareness/continuity.md
)

> "$OUTPUT"

for file in "${FILES[@]}"; do
  filepath="$REPO_ROOT/$file"
  if [[ -f "$filepath" ]]; then
    echo "<document>" >> "$OUTPUT"
    echo "<source>$file</source>" >> "$OUTPUT"
    cat "$filepath" >> "$OUTPUT"
    echo "" >> "$OUTPUT"
    echo "</document>" >> "$OUTPUT"
    echo "" >> "$OUTPUT"
  else
    echo "WARNING: $file not found, skipping" >&2
  fi
done

size=$(wc -c < "$OUTPUT" | tr -d ' ')
lines=$(wc -l < "$OUTPUT" | tr -d ' ')
echo "Generated $OUTPUT ($lines lines, $size bytes)"
