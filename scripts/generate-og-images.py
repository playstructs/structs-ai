#!/usr/bin/env python3
"""Build the 1200x630 OG template and per-page title cards.

Native GitHub Pages cannot run this. Commit the PNGs under assets/og/ and
assets/og-image.png so the Jekyll build can copy them.

Usage:
  python3 scripts/generate-og-images.py           # write assets/
  python3 scripts/generate-og-images.py --check   # generate to a temp dir and diff
"""
from __future__ import annotations

import argparse
import hashlib
import io
import re
import shutil
import sys
import tempfile
from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFont, ImageFilter
except ImportError:
    sys.stderr.write("Pillow is required: python3 -m pip install pillow\n")
    sys.exit(2)

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets"
FONT_PATH = ASSETS / "fonts" / "NotoSans-Bold.ttf"
OG_IMAGE = ASSETS / "og-image.png"
OG_SOURCE = ASSETS / "og-source.png"
OG_DIR = ASSETS / "og"
SITE_TITLE = "Structs AI"
W, H = 1200, 630
BAND_H = 168

SKIP_DIRS = {
    ".git",
    "_site",
    "vendor",
    "node_modules",
    "memory",
    "config",
    "generated",
    ".references",
    "structs-desktop",
    "structs-webapp",
    "scripts",
    "_layouts",
    "_includes",
    "_data",
    "_plugins",
    ".cursor",
    ".jekyll-cache",
    ".sass-cache",
    "gemfiles",
}

FM_RE = re.compile(r"^---\s*\n(.*?)\n---\s*\n?", re.S)


def parse_front_matter(text: str) -> dict[str, str]:
    m = FM_RE.match(text)
    if not m:
        return {}
    data: dict[str, str] = {}
    for line in m.group(1).splitlines():
        if not line.strip() or line.strip().startswith("#") or line.strip().startswith("-"):
            continue
        if ":" not in line:
            continue
        key, val = line.split(":", 1)
        key = key.strip()
        val = val.strip().strip('"').strip("'")
        if key:
            data[key] = val
    return data


def first_h1(text: str) -> str:
    m = re.search(r"^#\s+(.+)$", text, re.M)
    return m.group(1).strip() if m else ""


def og_key(canonical_path: str) -> str:
    p = canonical_path.replace(".html", "").replace("/", " ").strip().replace(" ", "-")
    return p or "index"


def canonical_from_source(rel: Path, fm: dict[str, str]) -> str | None:
    if fm.get("sitemap", "").lower() in {"false", "no"}:
        return None
    permalink = fm.get("permalink", "").strip()
    if permalink:
        return permalink if permalink.startswith("/") else "/" + permalink
    posix = rel.as_posix()
    if posix.endswith("/index.md"):
        parent = posix[: -len("index.md")]
        return "/" + parent if parent.startswith("/") else "/" + parent
    if posix.endswith(".md"):
        return "/" + posix[:-3] + ".html"
    if posix.endswith(".html"):
        return "/" + posix
    return None


def page_title(fm: dict[str, str], body: str) -> str:
    title = fm.get("title") or first_h1(body) or SITE_TITLE
    title = title.strip()
    if title == SITE_TITLE or SITE_TITLE in title:
        return title
    return f"{title} | {SITE_TITLE}"


def overlay_title(title: str) -> str:
    """Text drawn on the card — drop the site suffix; the wordmark is already on the art."""
    suffix = f" | {SITE_TITLE}"
    if title.endswith(suffix):
        return title[: -len(suffix)]
    return title


def iter_pages() -> list[tuple[str, str]]:
    pages: list[tuple[str, str]] = []
    seen: set[str] = set()
    for path in ROOT.rglob("*"):
        if not path.is_file():
            continue
        if path.suffix.lower() not in {".md", ".html"}:
            continue
        rel_parts = path.relative_to(ROOT).parts
        if rel_parts[0] in SKIP_DIRS or rel_parts[0] == "assets":
            continue
        if any(p in SKIP_DIRS for p in rel_parts):
            continue
        if path.name in {"sitemap.xml", "sitemap-txt.xml", "LICENSE"}:
            continue
        if path.relative_to(ROOT).as_posix() == "README.md":
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        fm = parse_front_matter(text)
        body = FM_RE.sub("", text, count=1)
        canon = canonical_from_source(path.relative_to(ROOT), fm)
        if canon is None:
            continue
        # Strip index.html last segment the same way the layout does.
        parts = canon.split("/")
        if parts and parts[-1] == "index.html":
            canon = canon[: -len("index.html")]
        key = og_key(canon)
        if key in seen:
            continue
        seen.add(key)
        pages.append((key, overlay_title(page_title(fm, body))))
    pages.sort()
    return pages


def load_font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    if FONT_PATH.exists():
        return ImageFont.truetype(str(FONT_PATH), size=size)
    return ImageFont.load_default()


def wrap_text(text: str, font: ImageFont.ImageFont, max_width: int) -> list[str]:
    words = text.split()
    lines: list[str] = []
    cur = ""
    for word in words:
        trial = f"{cur} {word}".strip()
        bbox = font.getbbox(trial)
        width = bbox[2] - bbox[0]
        if width <= max_width:
            cur = trial
        else:
            if cur:
                lines.append(cur)
            cur = word
    if cur:
        lines.append(cur)
    return lines[:3]


def recompose_template(src: Image.Image) -> Image.Image:
    src = src.convert("RGB")
    if src.size == (W, H):
        return src
    scaled = src.resize((W, int(src.height * W / src.width)), Image.Resampling.LANCZOS)
    # scaled is 1200 x ~400 from 1500x500
    canvas = Image.new("RGB", (W, H))
    pad = H - scaled.height
    top_h = pad // 2
    bot_h = pad - top_h
    top_row = scaled.crop((0, 0, W, min(8, scaled.height))).resize((W, top_h), Image.Resampling.LANCZOS)
    bot_row = scaled.crop((0, max(0, scaled.height - 8), W, scaled.height)).resize(
        (W, bot_h), Image.Resampling.LANCZOS
    )
    top_row = top_row.filter(ImageFilter.GaussianBlur(radius=6))
    bot_row = bot_row.filter(ImageFilter.GaussianBlur(radius=6))
    canvas.paste(top_row, (0, 0))
    canvas.paste(scaled, (0, top_h))
    canvas.paste(bot_row, (0, top_h + scaled.height))
    return canvas


def render_card(template: Image.Image, title: str | None) -> Image.Image:
    img = template.copy().convert("RGBA")
    if not title:
        return img.convert("RGB")
    draw = ImageDraw.Draw(img, "RGBA")
    band_top = H - BAND_H
    draw.rectangle((0, band_top, W, H), fill=(8, 18, 24, 210))
    font = load_font(42)
    lines = wrap_text(title, font, W - 96)
    # Shrink if still overflowing vertically
    line_h = 52
    size = 42
    while len(lines) * line_h > BAND_H - 36 and size > 28:
        size -= 2
        font = load_font(size)
        lines = wrap_text(title, font, W - 96)
        line_h = max(36, size + 10)
    total_h = len(lines) * line_h
    y = band_top + (BAND_H - total_h) // 2
    for line in lines:
        bbox = font.getbbox(line)
        tw = bbox[2] - bbox[0]
        draw.text(((W - tw) / 2, y), line, font=font, fill=(197, 215, 217, 255))
        y += line_h
    return img.convert("RGB")


def save_png(img: Image.Image, dest: Path) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    quantized = img.convert("RGB").convert("P", palette=Image.ADAPTIVE, colors=64)
    buf = io.BytesIO()
    quantized.save(buf, format="PNG", optimize=True, compress_level=9)
    dest.write_bytes(buf.getvalue())


def file_digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def build_all(out_image: Path, out_dir: Path, source: Image.Image) -> None:
    template = recompose_template(source)
    save_png(template, out_image)
    out_dir.mkdir(parents=True, exist_ok=True)
    # Homepage / fallback: no extra title (wordmark is already on the art)
    save_png(template, out_dir / "index.png")
    for key, title in iter_pages():
        if key == "index":
            continue
        card = render_card(template, title)
        save_png(card, out_dir / f"{key}.png")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="diff generated output against committed files")
    args = parser.parse_args()

    if not FONT_PATH.exists():
        sys.stderr.write(f"missing font {FONT_PATH}\n")
        return 2

    if OG_SOURCE.exists():
        source = Image.open(OG_SOURCE)
    elif OG_IMAGE.exists():
        source = Image.open(OG_IMAGE)
        if source.size != (W, H):
            OG_SOURCE.write_bytes(OG_IMAGE.read_bytes())
    else:
        sys.stderr.write(f"missing {OG_IMAGE}\n")
        return 2

    if args.check:
        tmp = Path(tempfile.mkdtemp(prefix="og-check-"))
        try:
            build_all(tmp / "og-image.png", tmp / "og", source)
            mismatches = []
            if not OG_IMAGE.exists() or file_digest(tmp / "og-image.png") != file_digest(OG_IMAGE):
                mismatches.append("assets/og-image.png")
            gen_files = {p.name: p for p in (tmp / "og").glob("*.png")}
            committed = {p.name: p for p in OG_DIR.glob("*.png")} if OG_DIR.exists() else {}
            extra = sorted(set(committed) - set(gen_files))
            missing = sorted(set(gen_files) - set(committed))
            changed = sorted(
                name
                for name in set(gen_files) & set(committed)
                if file_digest(gen_files[name]) != file_digest(committed[name])
            )
            if extra:
                mismatches.append("extra: " + ", ".join(extra[:8]))
            if missing:
                mismatches.append("missing: " + ", ".join(missing[:8]))
            if changed:
                mismatches.append("changed: " + ", ".join(changed[:8]))
            if mismatches:
                print("FAIL: OG images are stale — run python3 scripts/generate-og-images.py and commit")
                for m in mismatches:
                    print(" ", m)
                return 1
            print(f"OK: {len(gen_files)} OG images in sync")
            return 0
        finally:
            shutil.rmtree(tmp, ignore_errors=True)

    # Preserve the original wide art so later runs can recompose.
    if not OG_SOURCE.exists() and source.size != (W, H):
        OG_SOURCE.write_bytes(OG_IMAGE.read_bytes())
        source = Image.open(OG_SOURCE)

    build_all(OG_IMAGE, OG_DIR, source)
    n = len(list(OG_DIR.glob("*.png")))
    size = OG_IMAGE.stat().st_size
    print(f"Wrote {OG_IMAGE} ({size} bytes) and {n} per-page cards in {OG_DIR}")
    if size > 300_000:
        print(f"warn: og-image.png is {size} bytes (target < 300 KB)", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
