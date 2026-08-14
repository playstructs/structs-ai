#!/usr/bin/env bash
# Post-deploy smoke against live structs.ai. Retry once on non-200 (GitHub Pages 503s).
# Do not run this on pull requests — it reads production, not the PR build.
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ORIGIN="https://structs.ai"
PREV="$ROOT/scripts/ci/prev-sitemap.txt"
FAIL="$(mktemp)"
trap 'rm -f "$FAIL"' EXIT

http_code() {
  local url="$1"
  curl -sI -o /dev/null -w '%{http_code}' --max-time 25 "$url" 2>/dev/null || echo "000"
}

retry_code() {
  local url="$1"
  local c
  c="$(http_code "$url")"
  if [ "$c" != "200" ]; then
    sleep 1
    c="$(http_code "$url")"
  fi
  printf '%s' "$c"
}

fail() {
  echo "$1" | tee -a "$FAIL" >&2
}

# 1. Every sitemap URL resolves
SITEMAP="$(curl -fsS --max-time 30 "$ORIGIN/sitemap.xml" || true)"
if [ -z "$SITEMAP" ]; then
  fail "SITEMAP-FETCH-FAILED"
else
  echo "$SITEMAP" | grep -o '<loc>[^<]*</loc>' | sed 's|<loc>||; s|</loc>||' | while IFS= read -r u; do
    [ -n "$u" ] || continue
    c="$(retry_code "$u")"
    [ "$c" = "200" ] || fail "SITEMAP-404 $c $u"
  done
fi

# 2. Previous sitemap URLs still resolve or redirect
if [ ! -f "$PREV" ]; then
  fail "prev-sitemap.txt missing"
else
  while IFS= read -r u; do
    [ -n "$u" ] || continue
    case "$u" in \#*) continue ;; esac
    c="$(retry_code "$u")"
    case "$c" in 200|301|308) ;; *) fail "URL-REGRESSION $c $u" ;; esac
  done < "$PREV"
fi

# 3. Every breadcrumb item URL resolves
if [ -n "$SITEMAP" ]; then
  echo "$SITEMAP" | grep -o '<loc>[^<]*</loc>' | sed 's|<loc>||; s|</loc>||' | while IFS= read -r u; do
    [ -n "$u" ] || continue
    curl -fsS --max-time 25 "$u" 2>/dev/null | tr -d '\n' \
      | grep -o '"item"[[:space:]]*:[[:space:]]*"[^"]*"' \
      | sed -E 's/.*"item"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/'
  done | sort -u | while IFS= read -r i; do
    [ -n "$i" ] || continue
    c="$(retry_code "$i")"
    [ "$c" = "200" ] || fail "BREADCRUMB-404 $c $i"
  done
fi

# 4. Every URL cited in llms.txt resolves
LLMS="$(curl -fsS --max-time 30 "$ORIGIN/llms.txt" || true)"
if [ -z "$LLMS" ]; then
  fail "LLMS-FETCH-FAILED"
else
  echo "$LLMS" | grep -oE 'https://structs\.ai/[^)[:space:]]*' | sed 's/[.,;:]$//' | sort -u | while IFS= read -r u; do
    [ -n "$u" ] || continue
    c="$(retry_code "$u")"
    # Jekyll directory permalinks 301 when the trailing slash is omitted.
    case "$c" in 200|301|308) ;; *) fail "BROKEN-CITATION $c $u" ;; esac
  done
fi

# 5. Sitemap has lastmod on every entry
if [ -n "$SITEMAP" ]; then
  LOC="$(printf '%s' "$SITEMAP" | grep -c '<loc>' || true)"
  LM="$(printf '%s' "$SITEMAP" | grep -c '<lastmod>' || true)"
  [ "$LOC" = "$LM" ] || fail "LASTMOD-MISSING loc=$LOC lastmod=$LM"
fi

# 6. Discovery files present
for p in /robots.txt /sitemap.xml /favicon.ico /.well-known/security.txt /llms.txt; do
  c="$(retry_code "$ORIGIN$p")"
  [ "$c" = "200" ] || fail "MISSING $c $p"
done

if [ -s "$FAIL" ]; then
  echo "smoke-production FAILED" >&2
  exit 1
fi
echo "OK: production smoke passed"
exit 0
