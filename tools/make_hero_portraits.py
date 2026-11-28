#!/usr/bin/env python3
"""Queue 45: make the in-repo hero portraits from the 2K originals kept OUTSIDE the repository.

    python tools/make_hero_portraits.py --src <2K folder> --map data/heroes/source/hero_portrait_candidates_74_20261128.csv \
        --roster data/heroes/source/roster_245_20261128.json --out assets/heroes/portraits

* --src is searched recursively for each mapped source file name (Drive file names as they are). A name found in more
  than one place is an error unless the map's `source_folder` column says which folder to use.
* Output: the existing portrait format - 512x512, PNG, RGB 8-bit (no alpha), at <out>/<region>/<region>_<hero_id>.png.
  A non-square original is centre-cropped to a square first (never stretched).
* Region folder: the existing china / korea / japan / mongol, chosen from the roster's faction for the steppe /
  Tibet / Manchu groups and from its region otherwise (REGION_FOLDERS below).
* Writes data/heroes/source/portrait_map_119_20261128.csv (name, hero_id, source file, Drive ID, output, source size).
The 2K originals are never copied into the repository (public repository).
"""

from __future__ import annotations

import argparse
import csv
import json
import sys
from pathlib import Path

from PIL import Image

PORTRAIT_SIZE = 512
MAX_BYTES = 1_000_000
FACTION_FOLDERS = {"돌궐": "steppe", "토번": "tibet", "청": "manchuria", "몽골": "mongol"}
REGION_FOLDERS = {"중국": "china", "한반도": "korea", "일본": "japan"}
DEFAULT_RESULT = Path("data/heroes/source/portrait_map_119_20261128.csv")


def region_folder(hero: dict) -> str:
    faction = str(hero.get("faction", ""))
    if faction in FACTION_FOLDERS:
        return FACTION_FOLDERS[faction]
    region = str(hero.get("region", ""))
    if region not in REGION_FOLDERS:
        raise SystemExit(f"no portrait folder for {hero.get('hero_id')}: region {region!r}, faction {faction!r}")
    return REGION_FOLDERS[region]


def find_source(src: Path, file_name: str, folder_hint: str) -> Path:
    if folder_hint:
        candidate = src / folder_hint / file_name
        if not candidate.is_file():
            raise SystemExit(f"missing source: {candidate}")
        return candidate
    hits = [p for p in src.rglob(file_name) if p.is_file()]
    if len(hits) != 1:
        raise SystemExit(f"{file_name}: expected exactly one file under {src}, found {len(hits)}: {[str(h) for h in hits]}")
    return hits[0]


def make_portrait(source: Path, target: Path) -> tuple[int, int]:
    with Image.open(source) as image:
        width, height = image.size
        side = min(width, height)
        left = (width - side) // 2
        top = (height - side) // 2
        square = image.convert("RGB").crop((left, top, left + side, top + side))
        portrait = square.resize((PORTRAIT_SIZE, PORTRAIT_SIZE), Image.LANCZOS)
    target.parent.mkdir(parents=True, exist_ok=True)
    portrait.save(target, format="PNG", optimize=True)
    if target.stat().st_size > MAX_BYTES:
        raise SystemExit(f"{target}: {target.stat().st_size} bytes is over the 1 MB limit")
    return width, height


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--src", type=Path, required=True, help="folder with the 2K originals (outside the repository)")
    parser.add_argument("--map", type=Path, required=True, help="name / hero_id / source file / Drive ID csv (table 74)")
    parser.add_argument("--roster", type=Path, default=Path("data/heroes/source/roster_245_20261128.json"))
    parser.add_argument("--out", type=Path, default=Path("assets/heroes/portraits"))
    parser.add_argument("--result", type=Path, default=DEFAULT_RESULT)
    args = parser.parse_args()

    roster = {hero["hero_id"]: hero for hero in json.loads(args.roster.read_text(encoding="utf-8"))["heroes"]}
    with args.map.open(encoding="utf-8", newline="") as handle:
        rows = list(csv.DictReader(handle))
    results = []
    for row in rows:
        hero_id = row["hero_id"]
        if hero_id not in roster:
            raise SystemExit(f"{hero_id}: not in the roster")
        folder = region_folder(roster[hero_id])
        source = find_source(args.src, row["source_file"], row.get("source_folder", ""))
        target = args.out / folder / f"{folder}_{hero_id}.png"
        width, height = make_portrait(source, target)
        results.append({
            "name": row["name"], "hero_id": hero_id, "source_file": row["source_file"], "drive_id": row["drive_id"],
            "output_path": target.as_posix(), "source_size": f"{width}x{height}",
        })
    args.result.parent.mkdir(parents=True, exist_ok=True)
    with args.result.open("w", encoding="utf-8", newline="\n") as handle:
        writer = csv.DictWriter(handle, fieldnames=["name", "hero_id", "source_file", "drive_id", "output_path", "source_size"], lineterminator="\n")
        writer.writeheader()
        writer.writerows(results)
    print(f"PORTRAITS: {len(results)} written under {args.out} -> {args.result}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
