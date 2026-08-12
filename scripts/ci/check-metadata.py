#!/usr/bin/env python3
"""Metadata gate for structs.ai. Run against built output before deploy."""
from __future__ import annotations

import html
import re
import sys
from pathlib import Path

ROOT = Path("_site")
REPO = Path(".")
MAX_DESC = 155
MAX_TITLE = 60
SITE_ORIGIN = "https://structs.ai"

DIRECTORY_INDEXES = (
    "api/queries",
    "api/streaming",
    "api/transactions",
    "api/webapp",
    "develop/ui/examples",
    "examples/workflows",
    "patterns",
    "schemas/entities",
    "schemas/minimal",
    "troubleshooting",
    "visuals",
)

TXT_SITEMAP_LOCS = (
    "https://structs.ai/llms.txt",
    "https://structs.ai/llms-start.txt",
    "https://structs.ai/llms-core.txt",
    "https://structs.ai/llms-full.txt",
)

LLMS_ABS_URL = re.compile(r"https://structs\.ai(/[^\s)\]>\"']*)")

errors: list[str] = []
warnings: list[str] = []

FRONT_MATTER_PREFIX = re.compile(
    r"^(Version|Category|Type|Status|Entity|Purpose|Audience|Base URL|Base Path|Schema|Last Updated)\s*:",
    re.I,
)
BAD_TOKENS = ("localhost", "127.0.0.1", "-XX", "TODO", "TBD")


def attr(html_text: str, pattern: str) -> str | None:
    m = re.search(pattern, html_text, re.S | re.I)
    if not m:
        return None
    return html.unescape(m.group(1)).strip()


def resolve_canonical_target(canon: str) -> Path | None:
    path = canon.replace(SITE_ORIGIN, "").split("#", 1)[0].split("?", 1)[0]
    if not path.startswith("/"):
        return None
    rel = path.lstrip("/")
    candidates = []
    if rel == "" or rel.endswith("/"):
        candidates.append(ROOT / rel / "index.html")
        candidates.append(ROOT / "index.html" if rel == "" else ROOT / rel.rstrip("/") / "index.html")
    else:
        candidates.append(ROOT / rel)
        candidates.append(ROOT / f"{rel}.html")
        candidates.append(ROOT / rel / "index.html")
    for c in candidates:
        if c.exists():
            return c
    return None


def is_redirect_stub(html_text: str) -> bool:
    return "redirect_to" in html_text or 'http-equiv="refresh"' in html_text.lower()


def check_url_gate() -> None:
    for rel_dir in DIRECTORY_INDEXES:
        index = ROOT / rel_dir / "index.html"
        if not index.exists():
            errors.append(f"directory index missing: _site/{rel_dir}/index.html")

    changelog_ok = (ROOT / "CHANGELOG.html").exists() or (
        ROOT / "CHANGELOG" / "index.html"
    ).exists()
    if not changelog_ok:
        errors.append("CHANGELOG missing from _site (expected CHANGELOG.html or CHANGELOG/index.html)")
    if (ROOT / "README.html").exists():
        errors.append("_site/README.html must not be published")

    sitemap = ROOT / "sitemap-txt.xml"
    if not sitemap.exists():
        errors.append("_site/sitemap-txt.xml missing")
    else:
        body = sitemap.read_text(encoding="utf-8", errors="replace")
        for loc in TXT_SITEMAP_LOCS:
            if loc not in body:
                errors.append(f"sitemap-txt.xml missing loc {loc}")

    llms = REPO / "llms.txt"
    if not llms.exists():
        errors.append("llms.txt missing from repo root")
        return
    cited = []
    for m in LLMS_ABS_URL.finditer(llms.read_text(encoding="utf-8", errors="replace")):
        cited.append(SITE_ORIGIN + m.group(1).rstrip(".,;:"))
    if not cited:
        errors.append("llms.txt contains no https://structs.ai/... URLs")
    for url in cited:
        if resolve_canonical_target(url) is None:
            errors.append(f"llms.txt cites missing _site target {url}")


def main() -> int:
    if not ROOT.is_dir():
        print(f"ERROR: built site not found at {ROOT}/ — run jekyll build first", file=sys.stderr)
        return 2

    if not (ROOT / "favicon.ico").exists():
        errors.append("favicon.ico missing from _site")
    if not (ROOT / ".well-known" / "security.txt").exists():
        errors.append(".well-known/security.txt missing from _site")
    if not (ROOT / "schemas" / "responses.html").exists():
        errors.append("schemas/responses.html missing from _site (sitemap target)")

    check_url_gate()

    pages = sorted(ROOT.rglob("*.html"))
    # Skip theme/plugin junk if any; redirect stubs are skipped below
    seen_titles: dict[str, list[str]] = {}
    canonicals: list[tuple[str, str]] = []

    for f in pages:
        # Ignore nested vendor copies if any sneak in
        rel = "/" + str(f.relative_to(ROOT)).replace("\\", "/")
        if "/node_modules/" in rel or "/vendor/" in rel:
            continue
        # `.cursor/skills/` is a byte-identical mirror of `/skills/` (sitemap: false).
        # Skip it so duplicate-title checks and metadata rules apply once to the public path.
        if rel.startswith("/.cursor/"):
            continue

        text = f.read_text(encoding="utf-8", errors="replace")
        if is_redirect_stub(text):
            warnings.append(f"{rel}: redirect stub skipped for meta gate")
            continue
        # Standalone example assets (not Jekyll layout pages) — detect by missing site chrome
        if rel.startswith("/develop/ui/examples/") and "G-8NB71VRFSQ" not in text:
            warnings.append(f"{rel}: standalone example HTML skipped for meta gate")
            continue
        title = attr(text, r"<title>(.*?)</title>")
        desc = attr(text, r'<meta\s+[^>]*name=["\']description["\'][^>]*content=["\']([^"\']*)["\']')
        if desc is None:
            desc = attr(text, r'<meta\s+[^>]*content=["\']([^"\']*)["\'][^>]*name=["\']description["\']')
        canon = attr(text, r'<link\s+[^>]*rel=["\']canonical["\'][^>]*href=["\']([^"\']*)["\']')
        if canon is None:
            canon = attr(text, r'<link\s+[^>]*href=["\']([^"\']*)["\'][^>]*rel=["\']canonical["\']')
        h1s = re.findall(r"<h1\b", text, re.I)
        has_favicon_link = bool(re.search(r'rel=["\']icon["\']', text, re.I))

        # descriptions
        if not desc:
            errors.append(f"{rel}: missing meta description")
        else:
            if len(desc) > MAX_DESC:
                errors.append(f"{rel}: description {len(desc)} chars (max {MAX_DESC})")
            if desc[-1] not in ".!?":
                errors.append(f"{rel}: description does not end in terminal punctuation -> …{desc[-40:]!r}")
            if FRONT_MATTER_PREFIX.match(desc):
                errors.append(f"{rel}: description starts with front-matter key")
            for bad in BAD_TOKENS:
                if bad in desc:
                    errors.append(f"{rel}: description contains placeholder/internal value {bad!r}")

        # titles
        if not title:
            errors.append(f"{rel}: missing <title>")
        else:
            if len(title) > MAX_TITLE:
                warnings.append(f"{rel}: title {len(title)} chars (>{MAX_TITLE}, will truncate)")
            seen_titles.setdefault(title, []).append(rel)

        # double-encoding
        for field, val in (("title", title), ("description", desc)):
            if val and re.search(r"&(amp|lt|gt|quot|#39|apos);", val):
                errors.append(f"{rel}: {field} is double-encoded -> {val[:60]!r}")

        if len(h1s) != 1:
            # jekyll-redirect-from stubs may lack an h1
            if "redirect_to" in text or 'http-equiv="refresh"' in text.lower():
                warnings.append(f"{rel}: redirect stub without single h1 (ok)")
            else:
                errors.append(f"{rel}: expected exactly 1 <h1>, found {len(h1s)}")

        if not has_favicon_link and "redirect" not in text.lower():
            warnings.append(f"{rel}: no rel=icon link")

        if not canon:
            if "redirect_to" in text or 'http-equiv="refresh"' in text.lower():
                warnings.append(f"{rel}: redirect stub missing canonical (ok)")
            else:
                errors.append(f"{rel}: missing canonical")
        else:
            canonicals.append((rel, canon))

    for t, ps in seen_titles.items():
        if len(ps) > 1:
            errors.append(f"duplicate title {t!r} on {len(ps)} pages: {', '.join(ps[:4])}")

    for rel, canon in canonicals:
        if resolve_canonical_target(canon) is None:
            errors.append(f"{rel}: canonical points to non-existent target {canon}")

    print(f"checked {len(pages)} pages | {len(errors)} errors | {len(warnings)} warnings")
    for w in warnings[:50]:
        print("  WARN ", w)
    for e in errors:
        print("  ERROR", e)
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
