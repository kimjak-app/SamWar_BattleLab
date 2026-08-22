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
NEW_IMJIN_IDS = {
    "gwak_jae_u",
    "go_gyeong_myeong",
    "kim_deok_ryeong",
    "kato_kiyomasa",
    "kuroda_nagamasa",
}
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

    assert 'path="res://tests/scenes/Battle_UI_Production_Test.tscn"' in imjin_scene_text, "Test2 must inherit Test1"
    assert 'path="res://tests/scripts/battle_ui_production_imjin_test.gd"' in imjin_scene_text, "Test2 script missing"
    assert 'extends "res://scripts/battle_web_import_test.gd"' in imjin_script_text, "Test2 must reuse production battle controller"
    assert imjin_scene_text.count("[node ") == 1, "Test2 must not duplicate Test1 UI node tree"
    assert len(imjin_scene_text) < 2000, "Test2 scene unexpectedly copied production UI"
    assert len(base_scene_text) > 100000, "Production Test1 scene unexpectedly missing/changed shape"

    test1 = parse_roster_block(base_controller_text, "TEST_BATTLE_ROSTER")
    assert test1 == EXPECTED_TEST1, f"Test1 Korea-vs-China roster changed: {test1}"

    test2 = parse_roster_block(imjin_script_text, "IMJIN_TEST_BATTLE_ROSTER")
    ally = [test2[key] for key in ["ally_main_01", "ally_main_02", "ally_main_03", "ally_reinforce_01", "ally_reinforce_02"]]
    enemy = [test2[key] for key in ["enemy_main_01", "enemy_main_02", "enemy_main_03", "enemy_reinforce_01", "enemy_reinforce_02"]]
    assert ally == EXPECTED_ALLY, f"wrong Test2 ally roster: {ally}"
    assert enemy == EXPECTED_ENEMY, f"wrong Test2 enemy roster: {enemy}"

    test2_ids = set(test2.values())
    leaked_legacy_ids = sorted(test2_ids & FORBIDDEN_TEST2_LEGACY_IDS)
    assert not leaked_legacy_ids, f"Test2 must use canonical hero IDs, legacy IDs found: {leaked_legacy_ids}"

    base_stats = load_json(ROOT / "data" / "heroes" / "generated" / "hero_base_stats.json")["heroes"]
    profiles = load_json(ROOT / "data" / "heroes" / "generated" / "hero_battle_profiles.json")["profiles"]
    skills = load_json(ROOT / "data" / "heroes" / "generated" / "hero_unique_skills.json")["skills"]
    base_ids = {str(item["hero_id"]) for item in base_stats}
    profile_ids = {str(item["hero_id"]) for item in profiles}
    skill_ids = {str(item["hero_id"]) for item in skills}
    for hero_id in EXPECTED_ALLY + EXPECTED_ENEMY:
        assert hero_id in base_ids, f"Test2 hero missing base stats: {hero_id}"
        assert hero_id in profile_ids, f"Test2 hero missing battle profile: {hero_id}"
        assert hero_id in skill_ids, f"Test2 hero missing unique skill: {hero_id}"

    for hero_id in NEW_IMJIN_IDS:
        country = "korea" if hero_id in EXPECTED_ALLY else "japan"
        path = ROOT / "assets" / "heroes" / "portraits" / "current_actor" / country / f"{country}_{hero_id}.png"
        assert path.exists(), f"missing prepared current-actor portrait: {path.relative_to(ROOT)}"

    for hero_id in ["toyotomi_hideyoshi", "shimazu_yoshihiro", "konishi_yukinaga"]:
        path = ROOT / "assets" / "heroes" / "portraits" / "current_actor" / "japan" / f"japan_{hero_id}.png"
        assert path.exists(), f"missing prepared Japan current-actor portrait: {path.relative_to(ROOT)}"

    assert "naval" not in imjin_script_text.lower(), "Test2 must not implement naval battle yet"
    assert "sea_route" not in imjin_script_text.lower(), "Test2 must not add a temporary sea route"

    print("VALIDATION PASS: Test1 preserved + inherited Test2 Korea 5 vs Japan 5 scenario isolated + canonical Test2 hero IDs")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
