#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE_SCENE = ROOT / "tests" / "scenes" / "Battle_UI_Production_Test.tscn"
IMJIN_SCENE = ROOT / "tests" / "scenes" / "Battle_UI_Production_Imjin_Test.tscn"
BASE_CONTROLLER = ROOT / "scripts" / "battle_web_import_test.gd"
IMJIN_SCRIPT = ROOT / "tests" / "scripts" / "battle_ui_production_imjin_test.gd"
PROJECT_FILE = ROOT / "project.godot"
WORLD_MAP_SEEDER = ROOT / "scripts" / "worldmap" / "worldmap_registered_hero_seeder.gd"

EXPECTED_SLOTS = [
    "ally_main_01",
    "ally_main_02",
    "ally_main_03",
    "ally_reinforce_01",
    "ally_reinforce_02",
    "enemy_main_01",
    "enemy_main_02",
    "enemy_main_03",
    "enemy_reinforce_01",
    "enemy_reinforce_02",
]
EXPECTED_ALLY = [
    "yi_sun_sin",
    "gwak_jae_u",
    "kim_deok_ryeong",
    "kwon_yul",
    "go_gyeong_myeong",
]
EXPECTED_ENEMY = [
    "toyotomi_hideyoshi",
    "shimazu_yoshihiro",
    "kato_kiyomasa",
    "konishi_yukinaga",
    "kuroda_nagamasa",
]
EXPECTED_UNIT_TYPES = {
    "yi_sun_sin": "archer",
    "gwak_jae_u": "infantry",
    "kim_deok_ryeong": "cavalry",
    "kwon_yul": "infantry",
    "go_gyeong_myeong": "infantry",
    "toyotomi_hideyoshi": "infantry",
    "shimazu_yoshihiro": "gunner",
    "kato_kiyomasa": "infantry",
    "konishi_yukinaga": "gunner",
    "kuroda_nagamasa": "cavalry",
}
EXPECTED_SKILL_NAMES = {
    "yi_sun_sin": "학익진",
    "gwak_jae_u": "홍의장군",
    "kim_deok_ryeong": "충용장",
    "kwon_yul": "행주대첩",
    "go_gyeong_myeong": "호남의병",
    "toyotomi_hideyoshi": "태합호령",
    "shimazu_yoshihiro": "귀석만자",
    "kato_kiyomasa": "칠본창",
    "konishi_yukinaga": "선봉교섭",
    "kuroda_nagamasa": "세키가하라 조략",
}
NEW_IMJIN_IDS = {
    "gwak_jae_u",
    "go_gyeong_myeong",
    "kim_deok_ryeong",
    "kato_kiyomasa",
    "kuroda_nagamasa",
}
PORTRAIT_STEM_OVERRIDES = {"kwon_yul": "gwon_yul"}
# Preserve the existing Test1 source roster exactly. These legacy aliases are
# intentionally snapshot-tested here so D3 cannot silently rewrite Test1.
EXPECTED_TEST1 = {
    "ally_main_01": "yi_sunsin",
    "ally_main_02": "jeong_dojeon",
    "ally_main_03": "kwon_yul",
    "ally_reinforce_01": "gim_yusin",
    "ally_reinforce_02": "eulji_mundeok",
    "enemy_main_01": "guan_yu",
    "enemy_main_02": "zhang_fei",
    "enemy_main_03": "xiahou_dun",
    "enemy_reinforce_01": "liu_bei",
    "enemy_reinforce_02": "zhuge_liang",
}
FORBIDDEN_TEST2_LEGACY_IDS = {
    "yi_sunsin",
    "jeong_dojeon",
    "gim_yusin",
}


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def parse_roster_block(text: str, const_name: str) -> dict[str, str]:
    match = re.search(rf"const {re.escape(const_name)} := \{{(.*?)\n\}}", text, flags=re.DOTALL)
    if not match:
        raise AssertionError(f"missing roster constant: {const_name}")
    pairs = re.findall(r'"([a-z0-9_]+)"\s*:\s*"([a-z0-9_]+)"', match.group(1))
    return dict(pairs)


def main() -> int:
    base_scene_text = BASE_SCENE.read_text(encoding="utf-8")
    imjin_scene_text = IMJIN_SCENE.read_text(encoding="utf-8")
    base_controller_text = BASE_CONTROLLER.read_text(encoding="utf-8")
    imjin_script_text = IMJIN_SCRIPT.read_text(encoding="utf-8")
    project_text = PROJECT_FILE.read_text(encoding="utf-8")
    seeder_text = WORLD_MAP_SEEDER.read_text(encoding="utf-8")

    assert 'path="res://tests/scenes/Battle_UI_Production_Test.tscn"' in imjin_scene_text, "Test2 must inherit Test1"
    assert 'path="res://tests/scripts/battle_ui_production_imjin_test.gd"' in imjin_scene_text, "Test2 script missing"
    assert 'extends "res://scripts/battle_web_import_test.gd"' in imjin_script_text, "Test2 must reuse production battle controller"
    assert imjin_scene_text.count("[node ") == 1, "Test2 must not duplicate Test1 UI node tree"
    assert len(imjin_scene_text) < 2000, "Test2 scene unexpectedly copied production UI"
    assert len(base_scene_text) > 100000, "Production Test1 scene unexpectedly missing/changed shape"

    test1 = parse_roster_block(base_controller_text, "TEST_BATTLE_ROSTER")
    assert test1 == EXPECTED_TEST1, f"Test1 Korea-vs-China roster changed: {test1}"

    test2 = parse_roster_block(imjin_script_text, "IMJIN_TEST_BATTLE_ROSTER")
    ally = [test2[key] for key in EXPECTED_SLOTS[:5]]
    enemy = [test2[key] for key in EXPECTED_SLOTS[5:]]
    assert ally == EXPECTED_ALLY, f"wrong Test2 ally roster: {ally}"
    assert enemy == EXPECTED_ENEMY, f"wrong Test2 enemy roster: {enemy}"

    test2_ids = set(test2.values())
    leaked_legacy_ids = sorted(test2_ids & FORBIDDEN_TEST2_LEGACY_IDS)
    assert not leaked_legacy_ids, f"Test2 must use canonical hero IDs, legacy IDs found: {leaked_legacy_ids}"

    # Regression for the bug found in manual F6 QA: changing only slot metadata
    # is insufficient because the inherited Test1 BattleUnitState objects retain
    # old hero authority. Test2 must explicitly rebind all ten states after the
    # inherited builder runs.
    assert "func _create_demo_unit_states()" in imjin_script_text, "Test2 must override demo state construction"
    assert "super._create_demo_unit_states()" in imjin_script_text, "Test2 must preserve inherited battle wiring"
    assert "unit_state.unit_id = hero_id" in imjin_script_text, "Test2 must trigger BattleUnitState authority rebuild"
    for slot_id in EXPECTED_SLOTS:
        assert f'"{slot_id}"' in imjin_script_text, f"Test2 state rebind missing slot: {slot_id}"

    base_stats = load_json(ROOT / "data" / "heroes" / "generated" / "hero_base_stats.json")["heroes"]
    profiles = load_json(ROOT / "data" / "heroes" / "generated" / "hero_battle_profiles.json")["profiles"]
    skills = load_json(ROOT / "data" / "heroes" / "generated" / "hero_unique_skills.json")["skills"]
    base_by_id = {str(item["hero_id"]): item for item in base_stats}
    profile_by_id = {str(item["hero_id"]): item for item in profiles}
    skill_by_hero_id = {str(item["hero_id"]): item for item in skills}
    for hero_id in EXPECTED_ALLY + EXPECTED_ENEMY:
        assert hero_id in base_by_id, f"Test2 hero missing base stats: {hero_id}"
        assert hero_id in profile_by_id, f"Test2 hero missing battle profile: {hero_id}"
        assert hero_id in skill_by_hero_id, f"Test2 hero missing unique skill: {hero_id}"
        actual_unit_type = str(profile_by_id[hero_id]["unit_type"])
        assert actual_unit_type == EXPECTED_UNIT_TYPES[hero_id], (
            f"Test2 unit type drift: {hero_id} expected={EXPECTED_UNIT_TYPES[hero_id]} actual={actual_unit_type}"
        )
        profile_skill_id = str(profile_by_id[hero_id]["unique_skill_id"])
        skill = skill_by_hero_id[hero_id]
        assert str(skill["skill_id"]) == profile_skill_id, (
            f"Test2 profile/skill id mismatch: {hero_id} profile={profile_skill_id} skill={skill['skill_id']}"
        )
        actual_skill_name = str(skill["display_name"])
        assert actual_skill_name == EXPECTED_SKILL_NAMES[hero_id], (
            f"Test2 skill name drift: {hero_id} expected={EXPECTED_SKILL_NAMES[hero_id]} actual={actual_skill_name}"
        )

    # Roster portraits and current-actor portraits are separate contracts.
    assert "_get_imjin_regular_portrait_path" in imjin_script_text, "Test2 normal portrait resolver missing"
    assert "current_actor" not in re.search(
        r"func _get_hero_registry_entry\(.*?\n\nfunc ", imjin_script_text, flags=re.DOTALL
    ).group(0), "Roster registry must not bind current_actor cinematic portraits"
    for hero_id in EXPECTED_ALLY + EXPECTED_ENEMY:
        country = "korea" if hero_id in EXPECTED_ALLY else "japan"
        stem = PORTRAIT_STEM_OVERRIDES.get(hero_id, hero_id)
        regular_path = ROOT / "assets" / "heroes" / "portraits" / country / f"{country}_{stem}.png"
        assert regular_path.exists(), f"missing normal roster portrait: {regular_path.relative_to(ROOT)}"

    for hero_id in NEW_IMJIN_IDS:
        country = "korea" if hero_id in EXPECTED_ALLY else "japan"
        path = ROOT / "assets" / "heroes" / "portraits" / "current_actor" / country / f"{country}_{hero_id}.png"
        assert path.exists(), f"missing prepared current-actor portrait: {path.relative_to(ROOT)}"

    for hero_id in ["toyotomi_hideyoshi", "shimazu_yoshihiro", "konishi_yukinaga"]:
        path = ROOT / "assets" / "heroes" / "portraits" / "current_actor" / "japan" / f"japan_{hero_id}.png"
        assert path.exists(), f"missing prepared Japan current-actor portrait: {path.relative_to(ROOT)}"

    # Production WorldMap integration must bridge registry assigned_city_id into
    # mutable city/runtime rosters without teleporting already-known heroes.
    assert 'RegisteredHeroCitySeeder="*res://scripts/worldmap/worldmap_registered_hero_seeder.gd"' in project_text, (
        "registered hero WorldMap seeder autoload missing"
    )
    for required_token in [
        "assigned_city_id",
        "stationed_hero_ids",
        "hero_states.has(hero_id)",
        "owned_hero_ids",
        "_refresh_city_hud_data_bindings",
    ]:
        assert required_token in seeder_text, f"WorldMap registered-hero seeder contract missing: {required_token}"

    assert "naval" not in imjin_script_text.lower(), "Test2 must not implement naval battle yet"
    assert "sea_route" not in imjin_script_text.lower(), "Test2 must not add a temporary sea route"

    print(
        "VALIDATION PASS: Test1 preserved + Test2 canonical authority/unit/skill/portrait binding + "
        "registered WorldMap hero seeding contract"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
