#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FULL_OUTPUT="$REPO_ROOT/llms-full.txt"
CORE_OUTPUT="$REPO_ROOT/llms-core.txt"

# CORE: a tight starter set — identity, conventions, the core-loop skills, the
# highest-leverage knowledge, and the awareness an agent needs to act safely.
# Designed to fit comfortably in context when the full bundle is too large.
CORE_FILES=(
  SOUL.md
  SAFETY.md
  AGENTS.md
  QUICKSTART.md
  identity/manifesto.md

  .cursor/skills/conventions.md
  .cursor/skills/play-structs/SKILL.md
  .cursor/skills/structs-onboarding/SKILL.md
  .cursor/skills/structs-production/SKILL.md
  .cursor/skills/structs-building/SKILL.md
  .cursor/skills/structs-planets-fleet/SKILL.md
  .cursor/skills/structs-energy/SKILL.md
  .cursor/skills/structs-combat/SKILL.md

  knowledge/mechanics/building.md
  knowledge/mechanics/hashing.md
  knowledge/mechanics/combat.md
  knowledge/mechanics/resources.md
  knowledge/mechanics/energy.md
  knowledge/mechanics/power.md
  knowledge/entities/struct-types.md

  awareness/priority-framework.md
  awareness/game-loop.md
  awareness/async-operations.md
)

# FULL: the complete canonical corpus.
FULL_FILES=(
  # Identity
  SOUL.md
  QUICKSTART.md
  AGENTS.md
  SAFETY.md
  OPENCLAW.md
  IDENTITY.md
  COMMANDER.md
  USER.md
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
  .cursor/skills/index.md
  .cursor/skills/conventions.md
  .cursor/skills/play-structs/SKILL.md
  .cursor/skills/structsd-install/SKILL.md
  .cursor/skills/structs-onboarding/SKILL.md
  .cursor/skills/structs-production/SKILL.md
  .cursor/skills/structs-building/SKILL.md
  .cursor/skills/structs-planets-fleet/SKILL.md
  .cursor/skills/structs-energy/SKILL.md
  .cursor/skills/structs-combat/SKILL.md
  .cursor/skills/structs-commerce/SKILL.md
  .cursor/skills/structs-guild/SKILL.md
  .cursor/skills/structs-permissions/SKILL.md
  .cursor/skills/structs-intel/SKILL.md
  .cursor/skills/structs-streaming/SKILL.md
  .cursor/skills/structs-guild-stack/SKILL.md

  # Knowledge - Lore
  knowledge/lore/universe.md
  knowledge/lore/structs-origin.md
  knowledge/lore/factions.md
  knowledge/lore/alpha-matter.md
  knowledge/lore/timeline.md

  # Knowledge - Mechanics
  knowledge/mechanics/combat.md
  knowledge/mechanics/permissions.md
  knowledge/mechanics/transactions.md
  knowledge/mechanics/ugc-moderation.md
  knowledge/mechanics/resources.md
  knowledge/mechanics/energy.md
  knowledge/mechanics/power.md
  knowledge/mechanics/building.md
  knowledge/mechanics/hashing.md
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

  # Knowledge - Infrastructure
  knowledge/infrastructure/guild-stack.md
  knowledge/infrastructure/structs-desktop.md
  knowledge/infrastructure/database-schema.md

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
  playbooks/meta/team-operations.md

  # Awareness
  awareness/state-assessment.md
  awareness/threat-detection.md
  awareness/agent-security.md
  awareness/opportunity-identification.md
  awareness/priority-framework.md
  awareness/game-loop.md
  awareness/async-operations.md
  awareness/context-handoff.md
  awareness/continuity.md
  awareness/scorecard.md

  # Examples - Golden Transcripts
  examples/transcripts/README.md
  examples/transcripts/01-zero-to-mining.md
  examples/transcripts/02-raid-go-no-go.md
  examples/transcripts/03-combat-and-raid.md

  # API
  api/integration-notes.md
  api/streaming/event-types.md
  api/streaming/event-schemas.md

  # Troubleshooting
  troubleshooting/common-issues.md

  # Reference
  reference/glossary.md
  reference/local-devnet.md
)

# emit_bundle <output-path> <file...>
emit_bundle() {
  local output="$1"; shift
  : > "$output"
  local file filepath
  for file in "$@"; do
    filepath="$REPO_ROOT/$file"
    if [[ -f "$filepath" ]]; then
      {
        echo "<document>"
        echo "<source>$file</source>"
        cat "$filepath"
        echo ""
        echo "</document>"
        echo ""
      } >> "$output"
    else
      echo "WARNING: $file not found, skipping" >&2
    fi
  done
  local size lines
  size=$(wc -c < "$output" | tr -d ' ')
  lines=$(wc -l < "$output" | tr -d ' ')
  echo "Generated $output ($lines lines, $size bytes)"
}

emit_bundle "$FULL_OUTPUT" "${FULL_FILES[@]}"
emit_bundle "$CORE_OUTPUT" "${CORE_FILES[@]}"
