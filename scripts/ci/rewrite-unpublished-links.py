#!/usr/bin/env python3
"""Rewrite markdown links that Jekyll cannot publish to GitHub blob or a live page.

github-pages rewrites repo-relative .md hrefs to site URLs. Files in `exclude`
(config, memory, generated, scripts, …) then 404. Run from repo root; writes in place.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BLOB = "https://github.com/playstructs/structs-ai/blob/main/"
LINK_RE = re.compile(r"\[([^\]]+)\]\(([^)]+)\)")
DELETED_SKILLS = {
    "structs-mining": "structs-production",
    "structs-exploration": "structs-planets-fleet",
    "structs-power": "structs-energy",
    "structs-economy": "structs-commerce",
    "structs-diplomacy": "structs-guild",
    "structs-reconnaissance": "structs-intel",
}
SKIP_DIRS = {
    ".git",
    ".references",
    "vendor",
    "node_modules",
    "_site",
    "structs-webapp",
    "structs-desktop",
    ".review",
}


def repo_rel(from_file: Path, href: str) -> str | None:
    path = href.split("#", 1)[0].split("?", 1)[0]
    if not path or path.startswith(("#", "mailto:", "structs://")):
        return None
    if path.startswith(("http://", "https://")):
        return None
    if path.startswith("/"):
        return path.lstrip("/")
    resolved = (from_file.parent / path).resolve()
    try:
        return str(resolved.relative_to(ROOT)).replace("\\", "/")
    except ValueError:
        return None


def unpublished(rel: str) -> bool:
    rel = rel.lstrip("./")
    if rel in {"README.md", "_config.yml", ".structs-webapp-version", "LICENSE"}:
        return True
    prefixes = (
        "config/",
        "memory/",
        "generated/",
        "scripts/",
        ".references/",
    )
    if any(rel == p.rstrip("/") or rel.startswith(p) for p in prefixes):
        return True
    if rel.endswith(".sh") or rel.endswith(".mjs"):
        return True
    if rel.endswith("event-types.yaml"):
        return True
    return False


def rewrite_href(from_file: Path, href: str) -> str | None:
    path, _, frag = href.partition("#")
    fragment = f"#{frag}" if frag else ""
    rel = repo_rel(from_file, path)
    if rel is None:
        return None
    rel = rel.rstrip("/")

    if rel.endswith("event-types.yaml") or rel == "api/streaming/event-types.yaml":
        return "event-types.md" + fragment if from_file.name.startswith("event-") else "/api/streaming/event-types.html" + fragment

    m = re.search(r"(?:\.cursor/)?skills/([^/]+)/SKILL(?:\.md)?$", rel)
    if m:
        name = m.group(1)
        if name in DELETED_SKILLS:
            return f"/skills/{DELETED_SKILLS[name]}/SKILL.html{fragment}"
        return None

    if rel in {".cursor/skills", "skills"} or rel.endswith(".cursor/skills"):
        return "/skills/"

    if rel == "memory" or rel.startswith("memory"):
        return "/awareness/continuity.html" + fragment

    if rel in {"config/operator.md", "config/operator"}:
        return None  # caller unwraps to code

    if unpublished(rel):
        return BLOB + rel + fragment

    return None


def transform(from_file: Path, text: str) -> str:
    def sub(m: re.Match[str]) -> str:
        label, href = m.group(1), m.group(2)
        stripped = href.strip()
        new = rewrite_href(from_file, stripped)
        rel = repo_rel(from_file, stripped.split("#", 1)[0])
        if rel in {"config/operator.md", "config/operator"}:
            example = "https://github.com/playstructs/structs-ai/blob/main/config/operator.example.md"
            if "operator.example" in label:
                return f"[{label}]({example})"
            return f"`config/operator.md`"
        if new is None or new == stripped:
            return m.group(0)
        return f"[{label}]({new})"

    return LINK_RE.sub(sub, text)


def main() -> int:
    changed = 0
    for path in ROOT.rglob("*.md"):
        if any(p in SKIP_DIRS for p in path.parts):
            continue
        original = path.read_text(encoding="utf-8")
        updated = transform(path, original)
        # Historical structs-mcp repo is gone; Desktop MCP is the agent path.
        updated = updated.replace(
            "https://github.com/playstructs/structs-mcp",
            "https://github.com/playstructs/structs-desktop",
        )
        if updated != original:
            path.write_text(updated, encoding="utf-8")
            changed += 1
            print(path.relative_to(ROOT))
    print(f"updated {changed} files", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
