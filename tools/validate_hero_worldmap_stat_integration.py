#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE_PATH = ROOT / "data/heroes/generated/hero_base_stats.json"
LOYALTY_PATH = ROOT / "data/heroes/generated/hero_initial_loyalty.json"
SCRIPT_PATH = ROOT / "scripts/worldmap/hero_worldmap_stat_integration.gd"
PROJECT_PATH = ROOT / "project.godot"

EXPECTED_COUNT = 39
EXPECTED_SAMPLE = {
    "yi_sun_sin": (99, 88, 96, 78, 100),
    "cheok_jun_gyeong": (82, 100, 52, 35, 82),
    "gwanggaeto": (99, 92, 81, 85, 100),
    "eulji_mundeok": (96, 85, 95, 80, 99),
    "lu_bu": (90, 100, 35, 33, 45),
    "genghis_khan": (100, 99, 75, 78, 100),
}


def load_json(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as handle:
        payload = json.load(handle)
    if payload.get("schema_version") != 1:
        raise AssertionError(f"{path.name}: schema_version must be 1")
    return payload


def main() -> None:
    base_payload = load_json(BASE_PATH)
    loyalty_payload = load_json(LOYALTY_PATH)
    base = {row["hero_id"]: row for row in base_payload.get("heroes", [])}
    loyalty = {row["hero_id"]: row for row in loyalty_payload.get("heroes", [])}

    assert len(base) == EXPECTED_COUNT, f"base count={len(base)}"
    assert len(loyalty) == EXPECTED_COUNT, f"loyalty count={len(loyalty)}"
    assert set(base) == set(loyalty), "base/loyalty hero IDs differ"

    for hero_id, row in base.items():
        stats = row.get("stats", {})
        assert set(stats) == {"leadership", "martial", "intelligence", "politics"}, hero_id
        for key, value in stats.items():
            assert 0 <= int(value) <= 100, f"{hero_id}.{key}={value}"
        value = int(loyalty[hero_id].get("initial_loyalty", -1))
        assert 0 <= value <= 100, f"{hero_id}.initial_loyalty={value}"

    for hero_id, expected in EXPECTED_SAMPLE.items():
        stats = base[hero_id]["stats"]
        actual = (
            int(stats["leadership"]),
            int(stats["martial"]),
            int(stats["intelligence"]),
            int(stats["politics"]),
            int(loyalty[hero_id]["initial_loyalty"]),
        )
        assert actual == expected, f"{hero_id}: {actual} != {expected}"

    script = SCRIPT_PATH.read_text(encoding="utf-8")
    project = PROJECT_PATH.read_text(encoding="utf-8")
    required_script_tokens = [
        "_seed_definition_registry",
        "_apply_runtime_stat_migration",
        "initial_loyalty",
        "loyalty_schema_version",
        "지휘 %d / 무 %d / 지 %d / 정 %d / 충 %d",
    ]
    for token in required_script_tokens:
        assert token in script, f"integration script missing: {token}"
    assert 'HeroWorldMapStatIntegration="*res://scripts/worldmap/hero_worldmap_stat_integration.gd"' in project

    print(
        "WORLDMAP HERO STAT INTEGRATION PASS: "
        "39 final stat records, 39 initial loyalty records, runtime migration and 5-stat UI formatter present"
    )


if __name__ == "__main__":
    main()
