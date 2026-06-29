#!/usr/bin/env bash
# check-drift.sh — detect documentation drift against the live chain.
#
# The docs hard-code game constants (build difficulties, charge costs, HP, build
# limits). When the chain ships a balance patch, those constants silently go
# stale. This script queries the live struct-type definitions and compares a
# curated set of values against what the docs claim for the CURRENT release.
#
# It is READ-ONLY. A "DRIFT" line means: either the chain changed (update the
# docs) or the expected value below is wrong (fix this table). Keep the CHECKS
# table in sync with the catalog in knowledge/entities/struct-types.md.
#
# Usage:   scripts/check-drift.sh
# Env:     STRUCTSD, STRUCTS_NODE (see lib.sh)

set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
# shellcheck source=lib.sh
source "$HERE/lib.sh"

# --- Glossary link/anchor validation (filesystem-only; no chain needed) ------
# The glossary is a curated finder that links into canonical pages. If a page is
# renamed or a heading reworded, those links rot silently. This pass verifies
# every relative link target file exists and every #anchor resolves to a heading.
slugify() {
  # GitHub-style heading slug: lowercase, drop punctuation (keep space/_/-),
  # spaces -> hyphens. No multi-hyphen collapsing (matches GitHub).
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9 _-]//g' \
    | sed -E 's/ /-/g'
}

heading_slugs() {
  # Print the slug of every ATX heading (# .. ######) in a markdown file.
  local file="$1" line text
  while IFS= read -r line; do
    [[ "$line" =~ ^#{1,6}[[:space:]] ]] || continue
    text="$(printf '%s' "$line" | sed -E 's/^#{1,6}[[:space:]]+//')"
    printf '%s\n' "$(slugify "$text")"
  done < "$file"
}

GLOSSARY_BROKEN=0
check_glossary_links() {
  local glossary="$ROOT/reference/glossary.md"
  if [[ ! -f "$glossary" ]]; then
    echo "${C_YEL}== Glossary link check: SKIP (reference/glossary.md not found) ==${C_RST}"
    return 0
  fi
  echo "${C_CYN}== Glossary link/anchor check ==${C_RST}"
  local gdir checked=0 ok=0 broken=0 tgt path anchor file dir slugs
  gdir="$(dirname "$glossary")"
  while IFS= read -r tgt; do
    [[ -z "$tgt" ]] && continue
    [[ "$tgt" =~ ^https?:// ]] && continue
    [[ "$tgt" =~ ^mailto: ]] && continue
    checked=$((checked+1))
    path="${tgt%%#*}"
    anchor=""
    [[ "$tgt" == *#* ]] && anchor="${tgt#*#}"
    if [[ -z "$path" ]]; then
      file="$glossary"
    else
      dir="$(cd "$gdir/$(dirname "$path")" 2>/dev/null && pwd || true)"
      if [[ -z "$dir" || ! -f "$dir/$(basename "$path")" ]]; then
        printf '  %s %s\n' "${C_RED}MISSING FILE${C_RST}" "$tgt"
        broken=$((broken+1)); continue
      fi
      file="$dir/$(basename "$path")"
    fi
    if [[ -n "$anchor" ]]; then
      slugs="|$(heading_slugs "$file" | tr '\n' '|')|"
      if [[ "$slugs" != *"|$anchor|"* ]]; then
        printf '  %s %s\n' "${C_RED}BAD ANCHOR${C_RST} " "$tgt"
        broken=$((broken+1)); continue
      fi
    fi
    ok=$((ok+1))
  done < <(grep -oE '\]\([^)]+\)' "$glossary" 2>/dev/null | sed -E 's/^\]\(//; s/\)$//' || true)
  if (( broken > 0 )); then
    echo "  ${C_GRN}$ok ok${C_RST}, ${C_RED}$broken broken${C_RST} (of $checked links)"
    GLOSSARY_BROKEN=$broken
  else
    echo "  ${C_GRN}$ok ok${C_RST}, 0 broken (of $checked links)"
  fi
  echo
}

check_glossary_links

preflight

# Expected values for the current documented release (structsd v0.19.1).
# Format: "<struct-type-id>|<jq-field-alternation>|<expected>|<label>"
# The jq alternation tolerates snake_case vs camelCase field naming.
CHECKS=(
  "1|.buildDifficulty,.build_difficulty|200|Command Ship build difficulty"
  "14|.buildDifficulty,.build_difficulty|700|Ore Extractor build difficulty"
  "15|.buildDifficulty,.build_difficulty|700|Ore Refinery build difficulty"
  "18|.buildDifficulty,.build_difficulty|3600|Ore Bunker build difficulty"
  "1|.activateCharge,.activate_charge|2|Command Ship activateCharge"
  "14|.activateCharge,.activate_charge|2|Ore Extractor activateCharge"
  "18|.buildLimit,.build_limit|0|Ore Bunker build limit (0 = unlimited)"
)

extract() {
  # extract <json> <comma-separated-jq-paths>
  local json="$1" paths="$2" p out
  IFS=',' read -ra parts <<< "$paths"
  for p in "${parts[@]}"; do
    out="$(printf '%s' "$json" | jq -r "(.StructType // .structType // .struct_type // .) | $p // empty" 2>/dev/null || true)"
    [[ -n "$out" && "$out" != "null" ]] && { printf '%s' "$out"; return; }
  done
  printf ''
}

pass=0; drift=0; skip=0
echo "${C_CYN}== Doc drift check (expected = structsd v0.19.1 docs) ==${C_RST}"

declare -A CACHE
for row in "${CHECKS[@]}"; do
  IFS='|' read -r tid paths expected label <<< "$row"
  json="${CACHE[$tid]:-}"
  if [[ -z "$json" ]]; then
    json="$(q struct-type "$tid" || true)"
    CACHE[$tid]="$json"
  fi
  if [[ -z "$json" ]]; then
    printf '  %-44s %s\n' "$label" "${C_YEL}SKIP (no chain data)${C_RST}"
    skip=$((skip+1)); continue
  fi
  actual="$(extract "$json" "$paths")"
  if [[ -z "$actual" ]]; then
    printf '  %-44s %s\n' "$label" "${C_YEL}SKIP (field not found)${C_RST}"
    skip=$((skip+1))
  elif [[ "$actual" == "$expected" ]]; then
    printf '  %-44s %s\n' "$label" "${C_GRN}OK${C_RST} ($actual)"
    pass=$((pass+1))
  else
    printf '  %-44s %s\n' "$label" "${C_RED}DRIFT${C_RST} expected=$expected actual=$actual"
    drift=$((drift+1))
  fi
done

echo
echo "  ${C_GRN}$pass ok${C_RST}, ${C_RED}$drift drift${C_RST}, ${C_YEL}$skip skipped${C_RST}"
if (( drift > 0 )); then
  echo "${C_DIM}  Reconcile each DRIFT: update the docs (and CHANGELOG) or correct the CHECKS table.${C_RST}"
  exit 1
fi
if (( GLOSSARY_BROKEN > 0 )); then
  echo "${C_DIM}  Fix each broken glossary link/anchor in reference/glossary.md (the target page moved or a heading was reworded).${C_RST}"
  exit 1
fi
