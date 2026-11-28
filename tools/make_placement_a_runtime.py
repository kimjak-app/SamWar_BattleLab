#!/usr/bin/env python3
"""Queue 46 (addendum 9): build the runtime placement file the game reads from the working sources.

    python tools/make_placement_a_runtime.py          # write data/worldmap/placement_a_runtime.json
    python tools/make_placement_a_runtime.py --check  # exit 1 unless the committed file is byte-identical

Sources (working data, kept in data/heroes/source/, which has a .gdignore and is NOT exported):
  placement_A_revised_20261128.json   - Drive 67 section 3 (39 cities, Korean names)
  placement_A_city_ids_20261128.csv   - city name -> city id
  placement_A_hero_ids_20261128.csv   - hero name -> hero id
Output (exported with the game): data/worldmap/placement_a_runtime.json - ids only, one record per city in source
order, with the source files' SHA-256. A hero in two cities, an unknown name, or a governor outside the garrison is
an error: nothing is written.
Queue 47: each of the 26 new cities carries city_values (gold, food, population / commerce rating, resource_seed rice /
barley / seafood / wood / iron / salt / gold, values_status "proposal"); a new city without it, a legacy city with it,
or a missing / non-integer key is an error.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "data/heroes/source"
SOURCE = SOURCE_DIR / "placement_A_revised_20261128.json"
CITY_IDS = SOURCE_DIR / "placement_A_city_ids_20261128.csv"
HERO_IDS = SOURCE_DIR / "placement_A_hero_ids_20261128.csv"
OUTPUT = ROOT / "data/worldmap/placement_a_runtime.json"
PLACEMENT_ID = "placement_A_revised_20261128"
LEGACY_GROUP_PREFIX = "기존 13성"
GOVERNOR_UNDECIDED_PREFIX = "미정"
CITY_VALUE_KEYS = ("gold", "food", "population_rating", "commerce_rating")
RESOURCE_SEED_KEYS = ("rice", "barley", "seafood", "wood", "iron", "salt", "gold")


def _city_values(entry: dict, city_id: str, legacy: bool, errors: list[str]) -> dict | None:
    values = entry.get("city_values")
    if legacy:
        if values is not None:
            errors.append(f"legacy city {city_id} must not carry city_values (its values stay as in main)")
        return None
    if not isinstance(values, dict):
        errors.append(f"no city_values for new city {city_id}")
        return None
    out: dict = {"values_status": str(values.get("values_status", ""))}
    if out["values_status"] != "proposal":
        errors.append(f"city_values of {city_id}: values_status must be proposal")
    for key in CITY_VALUE_KEYS:
        if not isinstance(values.get(key), int) or values[key] < 0:
            errors.append(f"city_values of {city_id}: {key} must be an integer >= 0")
        out[key] = values.get(key)
    seed = values.get("resource_seed")
    out["resource_seed"] = {}
    for key in RESOURCE_SEED_KEYS:
        if not isinstance(seed, dict) or not isinstance(seed.get(key), int) or seed[key] < 0:
            errors.append(f"city_values of {city_id}: resource_seed.{key} must be an integer >= 0")
            continue
        out["resource_seed"][key] = seed[key]
    return out


def _csv_map(path: Path, key: str, value: str) -> dict[str, str]:
    with path.open(encoding="utf-8", newline="") as handle:
        return {row[key]: row[value] for row in csv.DictReader(handle)}


def build() -> tuple[str, list[str]]:
    errors: list[str] = []
    source = json.loads(SOURCE.read_text(encoding="utf-8"))
    city_ids = _csv_map(CITY_IDS, "city_name", "city_id")
    hero_ids = _csv_map(HERO_IDS, "hero_name", "hero_id")
    cities = []
    seen_city: set[str] = set()
    hero_city: dict[str, str] = {}
    for entry in source["cities"]:
        city_id = city_ids.get(entry["city"], "")
        if not city_id:
            errors.append(f"unknown city {entry['city']}")
            continue
        if city_id in seen_city:
            errors.append(f"city listed twice {city_id}")
        seen_city.add(city_id)
        stationed = []
        for hero in entry["stationed"]:
            hero_id = hero_ids.get(hero["name"], "")
            if not hero_id:
                errors.append(f"unknown hero {hero['name']} ({city_id})")
                continue
            if hero_id in hero_city:
                errors.append(f"hero {hero_id} in two cities: {hero_city[hero_id]}, {city_id}")
                continue
            hero_city[hero_id] = city_id
            stationed.append(hero_id)
        governor = str(entry.get("governor", ""))
        governor_id = ""
        if not governor.startswith(GOVERNOR_UNDECIDED_PREFIX):
            governor_id = hero_ids.get(governor, "")
            if not governor_id or governor_id not in stationed:
                errors.append(f"governor {governor} not in the garrison of {city_id}")
        if not entry.get("faction_id"):
            errors.append(f"no faction for {city_id}")
        cities.append({
            "city_id": city_id,
            "name": entry["city"],
            "legacy": str(entry.get("group", "")).startswith(LEGACY_GROUP_PREFIX),
            "faction_id": entry["faction_id"],
            "governor_id": governor_id,
            "governor_source": governor,
            "stationed": stationed,
            "troops": int(str(entry.get("troops", "0"))),
            "population": int(str(entry.get("population", "0"))),
            "grade": int(str(entry.get("grade", "0"))),
            "capital": str(entry.get("capital", "false")) == "true",   # a string in the source: only "true" is true
            "home_city": str(entry.get("home_city", "")),
        })
        values = _city_values(entry, city_id, cities[-1]["legacy"], errors)
        if values is not None:
            cities[-1]["city_values"] = values
    doc = {
        "schema": "eastwar_placement_runtime_v1",
        "placement_id": PLACEMENT_ID,
        "note": "Generated by tools/make_placement_a_runtime.py from data/heroes/source/ - do not edit by hand.",
        "sources": {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in (SOURCE, CITY_IDS, HERO_IDS)},
        "cities": cities,
    }
    return json.dumps(doc, ensure_ascii=False, indent="\t") + "\n", errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="fail unless the committed runtime file is up to date")
    args = parser.parse_args()
    text, errors = build()
    if errors:
        print("PLACEMENT RUNTIME FAILED", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1
    if args.check:
        if not OUTPUT.is_file() or OUTPUT.read_bytes() != text.encode("utf-8"):
            print(f"PLACEMENT RUNTIME STALE: {OUTPUT.relative_to(ROOT)} differs from the sources; run tools/make_placement_a_runtime.py", file=sys.stderr)
            return 1
        print(f"PLACEMENT RUNTIME PASS: {OUTPUT.relative_to(ROOT)} is byte-identical to the build from data/heroes/source/")
        return 0
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_bytes(text.encode("utf-8"))
    print(f"PLACEMENT RUNTIME WRITTEN: {OUTPUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
