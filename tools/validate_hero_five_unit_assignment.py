#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROFILE_PATH = ROOT / "data/heroes/generated/hero_battle_profiles.json"
UNIT_RULE_PATH = ROOT / "data/heroes/generated/unit_type_rules.json"
WORLDMAP_SCRIPT_PATH = ROOT / "scripts/worldmap/hero_worldmap_stat_integration.gd"

EXPECTED_REASSIGNMENTS = {
    "jeong_do_jeon": "archer",
    "dorim": "archer",
    "kim_chun_chu": "archer",
    "uija_wang": "archer",
    "fan_zeng": "archer",
    "xun_yu": "archer",
    "guo_jia": "archer",
    "zhuge_liang": "archer",
    "toyotomi_hideyoshi": "archer",
    "konishi_yukinaga": "gunner",
    "honda_masanobu": "gunner",
}
ALLOWED_UNITS = {"infantry", "cavalry", "archer", "gunner", "mounted_archer"}


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def main() -> None:
    profiles = load_json(PROFILE_PATH).get("profiles", [])
    rules = load_json(UNIT_RULE_PATH).get("unit_types", [])
    by_hero = {str(row.get("hero_id", "")): str(row.get("unit_type", "")) for row in profiles}
    rule_ids = {str(row.get("unit_type", "")) for row in rules}

    assert len(profiles) == 39, f"profile count={len(profiles)}"
    assert rule_ids == ALLOWED_UNITS, f"unit rules={sorted(rule_ids)}"
    assert "support" not in by_hero.values(), "support remains in hero profiles"

    for hero_id, expected_unit in EXPECTED_REASSIGNMENTS.items():
        actual = by_hero.get(hero_id)
        assert actual == expected_unit, f"{hero_id}: {actual} != {expected_unit}"

    script = WORLDMAP_SCRIPT_PATH.read_text(encoding="utf-8")
    assert '"support": "지원"' not in script, "WorldMap still maps support as a unit type"
    assert 'hero["unit_type"] = unit_type' in script, "runtime hero unit_type migration missing"
    assert "_apply_unit_type_label" in script, "WorldMap unit label refresh missing"

    print(
        "FIVE UNIT ASSIGNMENT PASS: support unit removed; 9 former support heroes use archer, "
        "Konishi and Honda Masanobu use gunner; WorldMap/runtime/battle profile linkage present"
    )


if __name__ == "__main__":
    main()
