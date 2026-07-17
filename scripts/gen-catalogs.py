#!/usr/bin/env python3
"""Generate source-derived reference catalogs with provenance.

Pilot (two catalogs only, per the redesign plan):
  1. generated/commands.md      — CLI command registry from `structsd --help`
  2. generated/struct-types.md  — struct-type stats from the pinned chain source

Namespaces are kept separate: CLI command names here are NOT proto message names.
Re-run after bumping the pinned release. Verified against .structsd-version.
"""
import os
import re
import subprocess
import sys
from datetime import date

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GEN = os.path.join(ROOT, "generated")
os.makedirs(GEN, exist_ok=True)


def pinned_version():
    path = os.path.join(ROOT, ".structsd-version")
    try:
        for line in open(path):
            line = line.strip()
            if line and not line.startswith("#"):
                return line
    except OSError:
        pass
    return "unknown"


def gen_commands():
    """CLI command registry from structsd help (name + one-line description)."""
    if not shutil_which("structsd"):
        print("skip commands.md: structsd not on PATH", file=sys.stderr)
        return
    ver = run(["structsd", "version"]).strip()
    rows = []
    for kind in ("tx", "query"):
        out = run(["structsd", kind, "structs", "--help"])
        in_cmds = False
        for line in out.splitlines():
            if "Available Commands:" in line:
                in_cmds = True
                continue
            if re.match(r"^(Flags:|Global Flags:|Additional)", line):
                in_cmds = False
            if in_cmds:
                m = re.match(r"^\s+([a-z][a-z0-9-]*)\s{2,}(.*)$", line)
                if m:
                    rows.append((kind, m.group(1), m.group(2).strip()))
    with open(os.path.join(GEN, "commands.md"), "w") as f:
        f.write("---\nkind: mechanics\nauthority: source\n")
        f.write(f"verified_against: structsd {ver}\nverified_at: {date.today()}\n")
        f.write("volatility: medium\ngenerated_by: scripts/gen-catalogs.py\n---\n\n")
        f.write("# CLI command catalog\n\n")
        f.write("> Generated from `structsd tx/query structs --help`. These are **CLI command "
                "names**, not proto message names. Do not hand-edit.\n\n")
        for kind in ("tx", "query"):
            f.write(f"## `structsd {kind} structs`\n\n| Command | Description |\n|---|---|\n")
            for k, name, desc in rows:
                if k == kind:
                    f.write(f"| `{name}` | {desc} |\n")
            f.write("\n")
    print(f"wrote generated/commands.md ({len(rows)} commands)")


STRUCT_FIELDS = [
    "Id", "Type", "Class", "Category", "BuildLimit", "BuildDifficulty",
    "BuildDraw", "PassiveDraw", "MaxHealth", "PossibleAmbit", "Movable",
    "PrimaryWeaponDamage", "PrimaryWeaponCharge", "PrimaryWeaponTargets",
    "PrimaryWeaponAmbits", "SecondaryWeaponDamage",
]


def gen_struct_types():
    """Struct-type stats parsed from the pinned chain source."""
    src = os.path.join(ROOT, ".references", "structsd", "x", "structs",
                       "types", "genesis_struct_type.go")
    if not os.path.exists(src):
        print("skip struct-types.md: pinned source not found", file=sys.stderr)
        return
    text = open(src).read()
    blocks = re.split(r"structType\s*=\s*StructType\{", text)[1:]
    entries = []
    for b in blocks:
        e = {}
        for fld in STRUCT_FIELDS:
            m = re.search(rf"\b{fld}:\s*([^,\n]+)", b)
            if m:
                e[fld] = m.group(1).strip().strip('"').replace("ObjectType_", "").replace("Tech", "")
        if e.get("Id"):
            entries.append(e)
    entries.sort(key=lambda e: int(e.get("Id", "0")))

    ver = pinned_version()
    with open(os.path.join(GEN, "struct-types.md"), "w") as f:
        f.write("---\nkind: mechanics\nauthority: source\n")
        f.write(f"verified_against: structsd {ver}\nverified_at: {date.today()}\n")
        f.write("volatility: medium\ngenerated_by: scripts/gen-catalogs.py\n")
        f.write("source: x/structs/types/genesis_struct_type.go\n---\n\n")
        f.write("# Struct type catalog\n\n")
        f.write(f"> Generated from the pinned chain source (`{ver}`). Draw values are energy "
                "units; ambit is a bitmask. Do not hand-edit — run `scripts/gen-catalogs.py`.\n\n")
        f.write("| ID | Type | Category | Build limit | Build diff | Build draw | "
                "Passive draw | Max HP | Movable | Primary dmg (charge) |\n")
        f.write("|---|---|---|---|---|---|---|---|---|---|\n")
        for e in entries:
            f.write("| {Id} | {Type} | {Category} | {BuildLimit} | {BuildDifficulty} | "
                    "{BuildDraw} | {PassiveDraw} | {MaxHealth} | {Movable} | "
                    "{pdmg} ({pchg}) |\n".format(
                        pdmg=e.get("PrimaryWeaponDamage", "-"),
                        pchg=e.get("PrimaryWeaponCharge", "-"),
                        **{k: e.get(k, "-") for k in
                           ["Id", "Type", "Category", "BuildLimit", "BuildDifficulty",
                            "BuildDraw", "PassiveDraw", "MaxHealth", "Movable"]}))
    print(f"wrote generated/struct-types.md ({len(entries)} struct types)")


def run(cmd):
    return subprocess.run(cmd, capture_output=True, text=True).stdout


def shutil_which(name):
    from shutil import which
    return which(name)


if __name__ == "__main__":
    gen_commands()
    gen_struct_types()
