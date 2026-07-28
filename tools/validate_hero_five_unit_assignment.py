#!/usr/bin/env python3
from __future__ import annotations

import json
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROFILE_PATH = ROOT / "data/heroes/generated/hero_battle_profiles.json"
UNIT_RULE_PATH = ROOT / "data/heroes/generated/unit_type_rules.json"

ALLOWED_UNITS = {"infantry", "cavalry", "archer", "gunner", "mounted_archer"}
EXPECTED_DISTRIBUTION = {"infantry": 11, "cavalry": 10, "archer": 11, "gunner": 4, "mounted_archer": 3}
EXPECTED_FINAL = {
    "kim_chun_chu": "infantry",
    "uija_wang": "infantry",
    "toyotomi_hideyoshi": "infantry",
    "konishi_yukinaga": "gunner",
    "honda_masanobu": "gunner",
}


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def main() -> None:
    profiles = load_json(PROFILE_PATH).get("profiles", [])
    rules = load_json(UNIT_RULE_PATH).get("unit_types", [])
    by_hero = {str(row.get("hero_id", "")): str(row.get("unit_type", "")) for row in profiles}
    rule_ids = {str(row.get("unit_type", "")) for row in rules}
    distribution = Counter(by_hero.values())

    assert len(profiles) == 39, f"profile count={len(profiles)}"
    assert rule_ids == ALLOWED_UNITS, f"unit rules={sorted(rule_ids)}"
    assert "support" not in by_hero.values(), "support remains in hero profiles"
    assert dict(distribution) == EXPECTED_DISTRIBUTION, f"distribution={dict(distribution)}"
    for hero_id, expected_unit in EXPECTED_FINAL.items():
        actual = by_hero.get(hero_id)
        assert actual == expected_unit, f"{hero_id}: {actual} != {expected_unit}"

    print("FIVE UNIT ASSIGNMENT PASS: 11/10/11/4/3; final infantry corrections locked; support role-only")


if __name__ == "__main__":
    main()
