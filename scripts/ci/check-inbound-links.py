#!/usr/bin/env python3
"""Every sitemap.xml <loc> must have an inbound <a> from another sitemap page.

SITEMAP.md is noindex and must not be the only hub. Run after jekyll build.
"""
from __future__ import annotations

import re
import sys
from collections import defaultdict
from pathlib import Path
from urllib.parse import urljoin, urlparse

ROOT = Path("_site")
SITE_ORIGIN = "https://structs.ai"
LOC_RE = re.compile(r"<loc>([^<]+)</loc>")
HREF_RE = re.compile(r"""href=["']([^"'#]+)""", re.I)


def path_from_loc(url: str) -> str:
    parsed = urlparse(url.strip())
    path = parsed.path or "/"
    if not path.startswith("/"):
        path = "/" + path
    return path


def variants(path: str) -> set[str]:
    p = path.split("#", 1)[0].split("?", 1)[0]
    if not p.startswith("/"):
        p = "/" + p
    out = {p}
    if p.endswith(".md"):
        out.add(p[:-3] + ".html")
        out.add(p[:-3])
    if p.endswith(".html"):
        out.add(p[:-5])
        stem = p[:-5]
        out.add(stem + ".md")
        if stem.endswith("/index"):
            out.add(stem[:-5] or "/")
            out.add((stem[:-6] or "") + "/" if stem[:-5] else "/")
    if p.endswith("/index.html"):
        out.add(p[: -len("index.html")])
        out.add((p[: -len("/index.html")] or "") or "/")
    if p.endswith("/") and p != "/":
        out.add(p + "index.html")
        out.add(p.rstrip("/") + ".html")
    elif not p.endswith(("/", ".html", ".txt", ".xml", ".ico")):
        out.add(p + "/")
        out.add(p + ".html")
        out.add(p + "/index.html")
    return {v if v.startswith("/") else "/" + v for v in out if v}


def resolve_href(page_url: str, href: str) -> str | None:
    href = href.strip()
    if not href or href.startswith(("mailto:", "javascript:", "data:", "{")):
        return None
    if href.startswith(("http://", "https://")):
        if not href.startswith(SITE_ORIGIN):
            return None
        return path_from_loc(href)
    if href.startswith("//"):
        return None
    return urlparse(urljoin(SITE_ORIGIN + page_url, href)).path or "/"


def site_file_for_path(path: str) -> Path | None:
    rel = path.lstrip("/")
    candidates = []
    if rel == "" or path.endswith("/"):
        candidates.append(ROOT / rel / "index.html")
    else:
        candidates.append(ROOT / rel)
        candidates.append(ROOT / f"{rel}.html")
        candidates.append(ROOT / rel / "index.html")
    for c in candidates:
        if c.is_file():
            return c
    return None


def main() -> int:
    if not ROOT.is_dir():
        print("ERROR: _site/ missing — run jekyll build first", file=sys.stderr)
        return 2
    sitemap = ROOT / "sitemap.xml"
    if not sitemap.is_file():
        print("ERROR: _site/sitemap.xml missing", file=sys.stderr)
        return 2

    locs = LOC_RE.findall(sitemap.read_text(encoding="utf-8", errors="replace"))
    loc_paths = [path_from_loc(u) for u in locs]
    loc_set: dict[str, str] = {}
    for p in loc_paths:
        for v in variants(p):
            loc_set[v] = p

    inbound: dict[str, set[str]] = defaultdict(set)
    html_sources = []
    for src_path in loc_paths:
        src_file = site_file_for_path(src_path)
        if src_file is None or src_file.suffix.lower() not in {".html", ".htm"}:
            continue
        html_sources.append(src_path)
        text = src_file.read_text(encoding="utf-8", errors="replace")
        for raw in HREF_RE.findall(text):
            target = resolve_href(src_path if src_path.endswith(("/", ".html")) else src_path + "/", raw)
            if target is None:
                continue
            dest = loc_set.get(target)
            if dest is None:
                dest = loc_set.get(target.rstrip("/") + "/") or loc_set.get(target + ".html")
            if dest is None:
                continue
            if dest == src_path or dest in variants(src_path):
                continue
            inbound[dest].add(src_path)

    missing = [p for p in loc_paths if not inbound.get(p)]
    if missing:
        print("FAIL: sitemap URLs with no inbound <a> from another sitemap HTML page:")
        for p in missing[:40]:
            print(f"  {SITE_ORIGIN}{p}")
        if len(missing) > 40:
            print(f"  … {len(missing) - 40} more")
        return 1
    print(f"OK: {len(loc_paths)} sitemap URLs have inbound links ({len(html_sources)} HTML sources)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
