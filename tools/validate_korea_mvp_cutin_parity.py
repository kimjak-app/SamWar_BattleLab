#!/usr/bin/env python3
"""Validate the exact Korea MVP hero/skill contract used by battle cutin routing."""

from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SKILLS_PATH = ROOT / "data/heroes/generated/hero_unique_skills.json"
CUTINS_PATH = ROOT / "data/cutin/korea_mvp_hero_cutins.json"
BATTLE_SCRIPT_PATH = ROOT / "scripts/battle_web_import_test.gd"

KOREA_MVP_HERO_IDS = (
    "yi_sun_sin",
    "uija_wang",
    "kim_yu_sin",
    "kim_chun_chu",
    "jeong_do_jeon",
    "jang_bo_go",
    "heukchi_sangji",
    "gyebaek",
    "kwon_yul",
    "gwanggaeto",
    "eulji_mundeok",
    "dorim",
    "cheok_jun_gyeong",
)


def resource_path_to_file(resource_path: str) -> Path:
    if not resource_path.startswith("res://"):
        raise ValueError("non-res resource path: %s" % resource_path)
    return ROOT / resource_path.removeprefix("res://")


def main() -> int:
    skills = json.loads(SKILLS_PATH.read_text(encoding="utf-8"))["skills"]
    cutin_entries = json.loads(CUTINS_PATH.read_text(encoding="utf-8"))["entries"]
    skills_by_hero = {item["hero_id"]: item for item in skills}
    entries_by_hero: dict[str, list[dict]] = {}
    for entry in cutin_entries:
        entries_by_hero.setdefault(entry.get("hero_id", ""), []).append(entry)

    failures: list[str] = []
    for hero_id in KOREA_MVP_HERO_IDS:
        skill = skills_by_hero.get(hero_id)
        entries = entries_by_hero.get(hero_id, [])
        if skill is None:
            failures.append("%s missing authoritative skill" % hero_id)
            continue
        if len(entries) != 1:
            failures.append("%s expected one cutin entry, got %d" % (hero_id, len(entries)))
            continue
        entry = entries[0]
        if entry.get("skill_id") != skill.get("skill_id"):
            failures.append("%s skill mismatch: registry=%s authoritative=%s" % (
                hero_id, entry.get("skill_id"), skill.get("skill_id")
            ))
            continue
        for key in ("video_path", "skill_title_texture_path"):
            path = str(entry.get(key, ""))
            if not resource_path_to_file(path).is_file():
                failures.append("%s missing %s: %s" % (hero_id, key, path))
        print("[CUTIN_PARITY] %s / %s PASS" % (hero_id, skill["skill_id"]))

    battle_script = BATTLE_SCRIPT_PATH.read_text(encoding="utf-8")
    if "WORLDMAP_CONTEXT_HERO_ID_COMPATIBILITY" in battle_script:
        failures.append("battle runtime still contains source-to-legacy compatibility table")

    if failures:
        for failure in failures:
            print("[CUTIN_PARITY] FAIL: %s" % failure)
        return 1
    print("[CUTIN_PARITY] 13/13 PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
