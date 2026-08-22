#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GENERATED = ROOT / "data" / "heroes" / "generated"
EXPECTED_COUNT = 44
NEW_HEROES = {
    "gwak_jae_u": ("goryeo_joseon", "hanseong", "res://assets/heroes/portraits/korea/korea_gwak_jae_u.png"),
    "go_gyeong_myeong": ("goryeo_joseon", "hanseong", "res://assets/heroes/portraits/korea/korea_go_gyeong_myeong.png"),
    "kim_deok_ryeong": ("goryeo_joseon", "hanseong", "res://assets/heroes/portraits/korea/korea_kim_deok_ryeong.png"),
    "kato_kiyomasa": ("toyotomi", "osaka", "res://assets/heroes/portraits/japan/japan_kato_kiyomasa.png"),
    "kuroda_nagamasa": ("toyotomi", "osaka", "res://assets/heroes/portraits/japan/japan_kuroda_nagamasa.png"),
}


def load_json(name: str) -> dict:
    return json.loads((GENERATED / name).read_text(encoding="utf-8"))


def ids(records: list[dict], key: str) -> list[str]:
    values = [str(record.get(key, "")) for record in records]
    if any(not value for value in values):
        raise AssertionError(f"{key}: empty id")
    if len(values) != len(set(values)):
        raise AssertionError(f"{key}: duplicate id")
    return values


def main() -> int:
    base = load_json("hero_base_stats.json")["heroes"]
    loyalty = load_json("hero_initial_loyalty.json")["heroes"]
    profiles = load_json("hero_battle_profiles.json")["profiles"]
    skills = load_json("hero_unique_skills.json")["skills"]

    groups = {
        "base": ids(base, "hero_id"),
        "loyalty": ids(loyalty, "hero_id"),
        "profiles": ids(profiles, "hero_id"),
        "skills": ids(skills, "hero_id"),
    }
    for name, values in groups.items():
        assert len(values) == EXPECTED_COUNT, f"{name}: expected {EXPECTED_COUNT}, found {len(values)}"

    authoritative = set(groups["base"])
    for name, values in groups.items():
        assert set(values) == authoritative, f"{name}: hero id set differs from base stats"

    skill_by_hero = {str(record["hero_id"]): record for record in skills}
    profile_by_hero = {str(record["hero_id"]): record for record in profiles}
    for hero_id in authoritative:
        assert str(profile_by_hero[hero_id].get("unique_skill_id", "")) == str(skill_by_hero[hero_id].get("skill_id", "")), (
            f"{hero_id}: profile/skill id mismatch"
        )

    design_registry = (ROOT / "scripts" / "worldmap" / "hero_design_data_registry.gd").read_text(encoding="utf-8")
    assert "const EXPECTED_HERO_COUNT := 44" in design_registry, "HeroDesignDataRegistry still expects a non-44 count"

    identity_path = ROOT / "scripts" / "worldmap" / "hero_definition_registry.gd"
    identity_text = identity_path.read_text(encoding="utf-8")
    identity_ids = set(re.findall(r'^\t"([a-z0-9_]+)": \{', identity_text, flags=re.MULTILINE))
    assert identity_ids == authoritative, (
        f"HeroDefinitionRegistry identity set mismatch: missing={sorted(authoritative - identity_ids)} extra={sorted(identity_ids - authoritative)}"
    )

    for hero_id, (faction_id, city_id, portrait_path) in NEW_HEROES.items():
        line_match = re.search(rf'^\t"{re.escape(hero_id)}": \{{.*$', identity_text, flags=re.MULTILINE)
        assert line_match, f"missing WorldMap identity: {hero_id}"
        line = line_match.group(0)
        assert f'"faction_id": "{faction_id}"' in line, f"{hero_id}: wrong faction"
        assert f'"assigned_city_id": "{city_id}"' in line, f"{hero_id}: wrong city"
        assert f'"portrait_path": "{portrait_path}"' in line, f"{hero_id}: wrong portrait path"

    loyalty_by_hero = {str(record["hero_id"]): int(record["initial_loyalty"]) for record in loyalty}
    for hero_id in NEW_HEROES:
        assert loyalty_by_hero[hero_id] == 80, f"{hero_id}: bootstrap loyalty must match runtime fallback 80"

    print("VALIDATION PASS: 44 hero design parity + 44 WorldMap identities + five Imjin placements")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
