#!/usr/bin/env bash
# gen-sui-inventory.sh — extract the SUI ground-truth inventory from structs-webapp.
#
# structs-webapp is the canonical source for the Structs UI design system. The
# develop/ui/ pages are written FROM this inventory, and scripts/check-webapp-drift.sh
# later diffs a fresh extract against the committed copy to catch upstream churn.
# One artifact, two jobs: writing source and drift baseline.
#
# READ-ONLY with respect to the webapp checkout. Writes generated/sui-inventory.md.
#
# Usage:   scripts/gen-sui-inventory.sh [--stdout]
# Env:     STRUCTS_WEBAPP  path to a structs-webapp checkout
#                          (default: .references/structs-webapp; falls back to a
#                           shallow clone in a temp dir so CI runners work)

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/generated/sui-inventory.md"
WEBAPP_REPO="https://github.com/playstructs/structs-webapp.git"
TO_STDOUT=0
[ "${1:-}" = "--stdout" ] && TO_STDOUT=1

CLONE_TMP=""
cleanup() { [ -n "$CLONE_TMP" ] && rm -rf "$CLONE_TMP"; return 0; }
trap cleanup EXIT

WEBAPP="${STRUCTS_WEBAPP:-$ROOT/.references/structs-webapp}"
if [ ! -f "$WEBAPP/src/public/css/sui/sui.css" ]; then
  echo "structs-webapp not found at $WEBAPP; shallow-cloning..." >&2
  CLONE_TMP="$(mktemp -d)"
  git clone --depth 1 --quiet "$WEBAPP_REPO" "$CLONE_TMP/structs-webapp" >&2
  WEBAPP="$CLONE_TMP/structs-webapp"
fi

SUI_CSS="$WEBAPP/src/public/css/sui/sui.css"
ICONS_CSS="$WEBAPP/src/public/css/structicons.css"
MAIN_CSS="$WEBAPP/src/public/css/main.css"
SUI_JS_DIR="$WEBAPP/src/js/sui"

for f in "$SUI_CSS" "$ICONS_CSS" "$MAIN_CSS"; do
  [ -f "$f" ] || { echo "error: missing $f" >&2; exit 1; }
done

SHA="$(git -C "$WEBAPP" rev-parse HEAD 2>/dev/null || echo unknown)"
SHA_DATE="$(git -C "$WEBAPP" log -1 --format=%cd --date=short 2>/dev/null || echo unknown)"
TODAY="$(date -u +%Y-%m-%d)"

# --- extractors -------------------------------------------------------------

# Every custom property declared in the :root block, as "name<TAB>value".
tokens() {
  awk '
    /^:root[[:space:]]*\{/ { inroot=1; next }
    inroot && /^\}/        { inroot=0 }
    inroot && /^[[:space:]]*--/ {
      line=$0
      sub(/^[[:space:]]+/, "", line)
      sub(/;.*$/, "", line)
      idx = index(line, ":")
      if (idx > 0) {
        name = substr(line, 1, idx-1)
        val  = substr(line, idx+1)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", val)
        printf "%s\t%s\n", name, val
      }
    }
  ' "$SUI_CSS"
}

# Glyph icons: icon-font classes declared in structicons.css.
glyph_icons() { grep -oE '^\.icon-[a-z0-9-]+' "$ICONS_CSS" | sed 's/^\.//' | sort -u; }
glyph_dupes() { grep -oE '^\.icon-[a-z0-9-]+' "$ICONS_CSS" | sed 's/^\.//' | sort | uniq -d; }

# Sprite icons: `i.sui-icon-*` rules that actually carry a background-image.
# `span.sui-icon-value` is deliberately excluded — it is a margin utility, not art.
sprite_icons() {
  awk '
    /^i\.sui-icon-[a-z0-9-]+[[:space:]]*\{/ {
      sel=$0; sub(/^i\./, "", sel); sub(/[[:space:]]*\{.*$/, "", sel)
      cur=sel; next
    }
    cur && /background-image/ { print cur; cur="" }
    /^\}/ { cur="" }
  ' "$SUI_CSS" | sed 's/^sui-icon-//' | sort -u
}

# Component classes: every .sui-* class, minus modifiers, themes and icon names.
component_classes() {
  grep -oE '\.sui-[a-z0-9-]+' "$SUI_CSS" \
    | sed 's/^\.//' \
    | grep -vE '^sui-(mod|theme|icon)-' \
    | sort -u
}

modifiers()  { grep -oE '\.sui-mod-[a-z0-9-]+'   "$SUI_CSS" | sed 's/^\.//' | sort -u; }
themes()     { grep -oE '\.sui-theme-[a-z0-9-]+' "$SUI_CSS" | sed 's/^\.//' | sort -u; }
icon_sizes() { grep -oE '\.sui-icon-(xs|sm|md|lg|xl|xxl)\b' "$SUI_CSS" | sed 's/^\.//' | sort -u; }

# Breakpoint -> transform scale pairs from main.css (the game's UI scaling model).
scale_rules() {
  awk '
    /@media[^{]*min-width:[[:space:]]*[0-9]+px/ {
      match($0, /min-width:[[:space:]]*[0-9]+px/)
      bp = substr($0, RSTART, RLENGTH); sub(/min-width:[[:space:]]*/, "", bp)
      pending = bp; next
    }
    /transform:[[:space:]]*scale\(/ {
      if (pending != "") {
        match($0, /scale\([0-9.]+\)/)
        printf "%s\t%s\n", pending, substr($0, RSTART, RLENGTH)
        pending = ""
      }
    }
  ' "$MAIN_CSS" | sort -u
}

fmt_list() { sed 's/^/`/; s/$/`/' | paste -sd' ' - | fold -s -w 78; }

# --- render -----------------------------------------------------------------

render() {
  local n_tokens n_glyph n_sprite n_comp n_mod
  n_tokens=$(tokens | wc -l | tr -d ' ')
  n_glyph=$(glyph_icons | wc -l | tr -d ' ')
  n_sprite=$(sprite_icons | wc -l | tr -d ' ')
  n_comp=$(component_classes | wc -l | tr -d ' ')
  n_mod=$(modifiers | wc -l | tr -d ' ')

  cat <<EOF
---
kind: ui
authority: source
verified_against: structs-webapp @ ${SHA:0:12} (${SHA_DATE})
verified_at: ${TODAY}
volatility: high
generated_by: scripts/gen-sui-inventory.sh
---

# SUI inventory

> Generated from \`structs-webapp\` — the canonical source for the Structs UI
> design system. Do not hand-edit. Regenerate with \`scripts/gen-sui-inventory.sh\`;
> diff against upstream with \`scripts/check-webapp-drift.sh\`.

Source commit: \`${SHA}\` (${SHA_DATE})

| Inventory | Count |
|---|---|
| \`:root\` tokens | ${n_tokens} |
| Glyph icons (icon font) | ${n_glyph} |
| Sprite icons (background art) | ${n_sprite} |
| Component classes | ${n_comp} |
| Modifiers | ${n_mod} |

## Tokens

| Token | Value |
|---|---|
EOF
  tokens | while IFS=$'\t' read -r name value; do
    printf '| `%s` | `%s` |\n' "$name" "$value"
  done

  cat <<EOF

## Glyph icons

Icon-font classes from \`src/public/css/structicons.css\`. These inherit \`color\`.

EOF
  glyph_icons | fmt_list
  local dupes
  dupes="$(glyph_dupes)"
  if [ -n "$dupes" ]; then
    printf '\nDeclared more than once in the stylesheet: '
    printf '%s' "$dupes" | fmt_list
    printf '\n'
  fi

  cat <<EOF

## Sprite icons

\`i.sui-icon-*\` rules carrying a \`background-image\` in \`sui.css\`. These are pixel
art and do **not** inherit \`color\`.

EOF
  sprite_icons | fmt_list

  cat <<EOF

## Icon sizes

EOF
  icon_sizes | fmt_list

  cat <<EOF

## Themes

EOF
  themes | fmt_list

  cat <<EOF

## Modifiers

EOF
  modifiers | fmt_list

  cat <<EOF

## Component classes

EOF
  component_classes | fmt_list

  cat <<EOF

## UI scaling (main.css)

The game scales its whole UI at these breakpoints. A companion app that does not
scale renders SUI at half size or less — see \`develop/ui/index.md\`.

| Breakpoint | Transform |
|---|---|
EOF
  scale_rules | while IFS=$'\t' read -r bp scale; do
    printf '| `min-width: %s` | `%s` |\n' "$bp" "$scale"
  done

  cat <<EOF

## SUI JavaScript modules

EOF
  if [ -d "$SUI_JS_DIR" ]; then
    (cd "$SUI_JS_DIR" && ls *.js 2>/dev/null | sort) | fmt_list
  else
    echo "_(not present in this checkout)_"
  fi
  echo
}

if [ "$TO_STDOUT" -eq 1 ]; then
  render
else
  mkdir -p "$ROOT/generated"
  render > "$OUT"
  echo "wrote $OUT (structs-webapp @ ${SHA:0:12})"
fi
