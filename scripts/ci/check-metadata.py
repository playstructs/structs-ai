#!/usr/bin/env python3
"""Metadata gate for structs.ai. Run against built output before deploy."""
from __future__ import annotations

import html
import json
import re
import sys
from pathlib import Path

ROOT = Path("_site")
REPO = Path(".")
MAX_DESC = 155
MAX_TITLE = 60
MIN_TITLE = 30
SITE_ORIGIN = "https://structs.ai"
OG_FALLBACK = f"{SITE_ORIGIN}/assets/og-image.png"
OG_PAGE_PREFIX = f"{SITE_ORIGIN}/assets/og/"
PREV_SITEMAP = REPO / "scripts" / "ci" / "prev-sitemap.txt"
LASTMOD_VALUE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
LOC_RE = re.compile(r"<loc>([^<]+)</loc>")
LASTMOD_RE = re.compile(r"<lastmod>([^<]+)</lastmod>")

DIRECTORY_INDEXES = (
    "api",
    "api/queries",
    "api/streaming",
    "api/transactions",
    "api/webapp",
    "develop/ui/examples",
    "examples",
    "examples/auth",
    "examples/database",
    "examples/errors",
    "examples/transcripts",
    "examples/workflows",
    "knowledge/infrastructure",
    "patterns",
    "protocols",
    "schemas",
    "schemas/entities",
    "schemas/minimal",
    "strategy/presets",
    "troubleshooting",
    "visuals",
    "visuals/graphs",
    "visuals/reference",
    "visuals/schemas",
    "visuals/spatial",
)

TXT_SITEMAP_LOCS = (
    "https://structs.ai/llms.txt",
    "https://structs.ai/llms-start.txt",
)

TXT_SITEMAP_FORBIDDEN = (
    "https://structs.ai/llms-core.txt",
    "https://structs.ai/llms-full.txt",
)

GAME_URL = "https://beta.playstructs.com/"
GAME_SAME_AS = (
    "https://www.playstructs.com/",
    "https://github.com/playstructs",
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


def png_dimensions(path: Path) -> tuple[int, int] | None:
    data = path.read_bytes()[:24]
    if len(data) < 24 or data[:8] != b"\x89PNG\r\n\x1a\n":
        return None
    width = int.from_bytes(data[16:20], "big")
    height = int.from_bytes(data[20:24], "big")
    return width, height


def check_sitemap_file(path: Path, label: str) -> str:
    if not path.exists():
        errors.append(f"{label} missing from build")
        return ""
    body = path.read_text(encoding="utf-8", errors="replace")
    locs = LOC_RE.findall(body)
    lastmods = LASTMOD_RE.findall(body)
    if len(locs) != len(lastmods):
        errors.append(f"{label}: {len(locs)} <loc> but {len(lastmods)} <lastmod>")
    for value in lastmods:
        if not LASTMOD_VALUE.match(value):
            errors.append(f"{label}: lastmod not YYYY-MM-DD -> {value!r}")
    return body


def is_redirect_stub(html_text: str) -> bool:
    return "redirect_to" in html_text or 'http-equiv="refresh"' in html_text.lower()


def extract_jsonld(html_text: str) -> dict | None:
    m = re.search(
        r'<script\s+type=["\']application/ld\+json["\']\s*>(.*?)</script>',
        html_text,
        re.S | re.I,
    )
    if not m:
        return None
    try:
        data = json.loads(m.group(1))
    except json.JSONDecodeError:
        return None
    return data if isinstance(data, dict) else None


def graph_nodes(data: dict) -> list:
    graph = data.get("@graph")
    if isinstance(graph, list):
        return graph
    return [data]


def find_typed_node(data: dict, type_name: str) -> dict | None:
    for node in graph_nodes(data):
        if not isinstance(node, dict):
            continue
        raw = node.get("@type")
        types = [str(t) for t in raw] if isinstance(raw, list) else [str(raw)]
        if type_name in types:
            return node
    return None


def graph_types(data: dict) -> set[str]:
    types: set[str] = set()
    graph = data.get("@graph")
    nodes = graph if isinstance(graph, list) else [data]
    for node in nodes:
        if not isinstance(node, dict):
            continue
        raw = node.get("@type")
        if isinstance(raw, list):
            types.update(str(t) for t in raw)
        elif raw:
            types.add(str(raw))
    return types


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
    body = check_sitemap_file(sitemap, "sitemap-txt.xml")
    if body:
        for loc in TXT_SITEMAP_LOCS:
            if loc not in body:
                errors.append(f"sitemap-txt.xml missing loc {loc}")
        for loc in TXT_SITEMAP_FORBIDDEN:
            if loc in body:
                errors.append(f"sitemap-txt.xml must not list dump {loc}")

    sitemap_xml = ROOT / "sitemap.xml"
    sm = check_sitemap_file(sitemap_xml, "sitemap.xml")
    if sm:
        if "develop/ui/examples/starter" in sm:
            errors.append("sitemap.xml must not include /develop/ui/examples/starter.html")
        txt_locs = [u for u in LOC_RE.findall(sm) if u.endswith(".txt")]
        expected_txt = list(TXT_SITEMAP_LOCS)
        if sorted(txt_locs) != sorted(expected_txt):
            errors.append(f"sitemap.xml txt locs {txt_locs!r} != {expected_txt!r}")
        for loc in TXT_SITEMAP_FORBIDDEN:
            if loc in sm:
                errors.append(f"sitemap.xml must not list dump {loc}")

    if PREV_SITEMAP.exists():
        for raw in PREV_SITEMAP.read_text(encoding="utf-8", errors="replace").splitlines():
            url = raw.strip()
            if not url or url.startswith("#"):
                continue
            if resolve_canonical_target(url) is None:
                errors.append(f"prev-sitemap.txt URL missing from _site: {url}")
    else:
        errors.append("scripts/ci/prev-sitemap.txt missing")

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
            continue
        path = url.replace(SITE_ORIGIN, "").split("#", 1)[0].split("?", 1)[0]
        rel = path.lstrip("/")
        if (
            rel
            and not path.endswith("/")
            and (ROOT / rel / "index.html").exists()
            and not (ROOT / f"{rel}.html").exists()
        ):
            errors.append(f"llms.txt must use trailing slash for directory permalink {url}/")


def main() -> int:
    if not ROOT.is_dir():
        print(f"ERROR: built site not found at {ROOT}/ — run jekyll build first", file=sys.stderr)
        return 2

    if not (ROOT / "favicon.ico").exists():
        errors.append("favicon.ico missing from _site")
    if not (ROOT / "assets" / "og-image.png").exists():
        errors.append("assets/og-image.png missing from _site")
    else:
        dims = png_dimensions(ROOT / "assets" / "og-image.png")
        if dims != (1200, 630):
            errors.append(f"assets/og-image.png must be 1200x630, got {dims}")
    if not (ROOT / ".well-known" / "security.txt").exists():
        errors.append(".well-known/security.txt missing from _site")
    if not (ROOT / "schemas" / "responses.html").exists():
        errors.append("schemas/responses.html missing from _site (sitemap target)")

    check_url_gate()

    pages = sorted(ROOT.rglob("*.html"))
    # Skip theme/plugin junk if any; redirect stubs are skipped below
    seen_titles: dict[str, list[str]] = {}
    seen_descs: dict[str, list[str]] = {}
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
            seen_descs.setdefault(desc, []).append(rel)

        # titles
        if not title:
            errors.append(f"{rel}: missing <title>")
        else:
            if len(title) > MAX_TITLE:
                errors.append(f"{rel}: title {len(title)} chars (max {MAX_TITLE})")
            if len(title) < MIN_TITLE:
                warnings.append(f"{rel}: title only {len(title)} chars")
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

        og_image = attr(text, r'<meta\s+[^>]*property=["\']og:image["\'][^>]*content=["\']([^"\']*)["\']')
        if og_image is None:
            og_image = attr(text, r'<meta\s+[^>]*content=["\']([^"\']*)["\'][^>]*property=["\']og:image["\']')
        twitter_card = attr(text, r'<meta\s+[^>]*name=["\']twitter:card["\'][^>]*content=["\']([^"\']*)["\']')
        if twitter_card is None:
            twitter_card = attr(text, r'<meta\s+[^>]*content=["\']([^"\']*)["\'][^>]*name=["\']twitter:card["\']')
        twitter_image = attr(text, r'<meta\s+[^>]*name=["\']twitter:image["\'][^>]*content=["\']([^"\']*)["\']')
        if twitter_image is None:
            twitter_image = attr(text, r'<meta\s+[^>]*content=["\']([^"\']*)["\'][^>]*name=["\']twitter:image["\']')

        if not og_image:
            errors.append(f"{rel}: no og:image")
        elif og_image != OG_FALLBACK and not og_image.startswith(OG_PAGE_PREFIX):
            errors.append(f"{rel}: og:image must be fallback or /assets/og/*.png, got {og_image!r}")
        elif og_image:
            og_path = resolve_canonical_target(og_image)
            if og_path is None:
                errors.append(f"{rel}: og:image 404 {og_image}")
            else:
                dims = png_dimensions(og_path)
                if dims != (1200, 630):
                    errors.append(f"{rel}: og:image {og_image} must be 1200x630, got {dims}")
        if twitter_card != "summary_large_image":
            errors.append(f"{rel}: twitter:card must be summary_large_image, got {twitter_card!r}")
        if twitter_image != og_image:
            errors.append(f"{rel}: twitter:image must match og:image, got {twitter_image!r}")

        jsonld = extract_jsonld(text)
        if jsonld is None:
            errors.append(f"{rel}: missing or invalid application/ld+json")
        else:
            types = graph_types(jsonld)
            if "BreadcrumbList" not in types:
                errors.append(f"{rel}: JSON-LD missing BreadcrumbList")
            else:
                for node in graph_nodes(jsonld):
                    if not isinstance(node, dict) or node.get("@type") != "BreadcrumbList":
                        continue
                    for i, item in enumerate(node.get("itemListElement") or [], start=1):
                        if not isinstance(item, dict):
                            continue
                        if item.get("position") != i:
                            errors.append(
                                f"{rel}: breadcrumb position {item.get('position')} != {i}"
                            )
                        name = item.get("name")
                        url = item.get("item")
                        if not name:
                            errors.append(f"{rel}: BreadcrumbList item missing name")
                        if url is None:
                            continue
                        if not isinstance(url, str):
                            errors.append(f"{rel}: BreadcrumbList item is not a URL")
                            continue
                        if "://" in url and "///" in url.replace("://", ":"):
                            errors.append(f"{rel}: BreadcrumbList item has doubled slash {url}")
                        if resolve_canonical_target(url) is None:
                            errors.append(f"{rel}: BreadcrumbList item 404 {url}")
            is_home = rel in ("/index.html", "/") or (canon == f"{SITE_ORIGIN}/")
            is_api = rel.startswith("/api/") or (canon or "").startswith(f"{SITE_ORIGIN}/api/")
            if is_home:
                if "WebSite" not in types:
                    errors.append(f"{rel}: homepage JSON-LD missing WebSite")
                if "VideoGame" not in types:
                    errors.append(f"{rel}: homepage JSON-LD missing VideoGame")
                game = find_typed_node(jsonld, "VideoGame")
                if game is not None:
                    if game.get("url") != GAME_URL:
                        errors.append(
                            f"{rel}: VideoGame.url must be {GAME_URL}, got {game.get('url')!r}"
                        )
                    same_as = game.get("sameAs")
                    if not isinstance(same_as, list):
                        errors.append(f"{rel}: VideoGame.sameAs missing")
                    else:
                        for expected in GAME_SAME_AS:
                            if expected not in same_as:
                                errors.append(f"{rel}: VideoGame.sameAs missing {expected}")
            elif is_api:
                if "APIReference" not in types:
                    errors.append(f"{rel}: /api/ JSON-LD missing APIReference")
            elif "TechArticle" not in types:
                errors.append(f"{rel}: JSON-LD missing TechArticle")
            article = find_typed_node(jsonld, "APIReference") or find_typed_node(
                jsonld, "TechArticle"
            )
            if article is not None:
                if not article.get("dateModified"):
                    errors.append(f"{rel}: JSON-LD article missing dateModified")
                if not article.get("datePublished"):
                    errors.append(f"{rel}: JSON-LD article missing datePublished")
                if article.get("inLanguage") != "en":
                    errors.append(f"{rel}: JSON-LD article inLanguage must be 'en'")
                if not article.get("author"):
                    errors.append(f"{rel}: JSON-LD article missing author")

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

    for d, ps in seen_descs.items():
        if len(ps) > 1:
            errors.append(f"duplicate description on {len(ps)} pages: {', '.join(ps[:4])}")

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
