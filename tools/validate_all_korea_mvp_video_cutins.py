#!/usr/bin/env python3
"""Audit every enabled Korea MVP video cutin before its scene-tree playback test."""
from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data/cutin/korea_mvp_hero_cutins.json"
TEST = ROOT / "tests/scripts/test_all_korea_mvp_video_cutins.gd"

errors: list[str] = []
entries = json.loads(DATA.read_text(encoding="utf-8")).get("entries", [])
expected_heroes = {
    "yi_sun_sin", "uija_wang", "kim_yu_sin", "kim_chun_chu", "jeong_do_jeon",
    "jang_bo_go", "heukchi_sangji", "gyebaek", "kwon_yul", "gwanggaeto",
    "eulji_mundeok", "dorim", "cheok_jun_gyeong",
}
seen: set[str] = set()
for entry in entries:
    hero_id = str(entry.get("hero_id", ""))
    if not entry.get("enabled", False):
        errors.append(f"disabled MVP cutin entry: {hero_id}")
        continue
    seen.add(hero_id)
    korea_portrait = ROOT / "assets/heroes/portraits/korea" / f"korea_{hero_id}.png"
    legacy_portrait = ROOT / "assets/web_battle/portraits" / f"{hero_id}_portrait.png"
    portrait = korea_portrait if korea_portrait.exists() else legacy_portrait
    title = ROOT / str(entry.get("skill_title_texture_path", "")).removeprefix("res://")
    video = ROOT / str(entry.get("video_path", "")).removeprefix("res://")
    result = all((portrait.exists(), title.exists(), video.exists(), video.suffix == ".ogv"))
    print(f"MVP AUDIT hero={hero_id} registry={bool(entry.get('skill_id'))} portrait={portrait.exists()} title={title.exists()} ogv={video.exists()} playback_test=scheduled result={'PASS' if result else 'FAIL'}")
    if not result:
        errors.append(f"resource contract failed: {hero_id} portrait={portrait} title={title} video={video}")
if seen != expected_heroes:
    errors.append(f"MVP roster mismatch missing={sorted(expected_heroes - seen)} unexpected={sorted(seen - expected_heroes)}")
if len(entries) != 13:
    errors.append(f"expected 13 MVP entries, found {len(entries)}")
test = TEST.read_text(encoding="utf-8")
for token in ("PresentationScene.instantiate()", "presentation.is_video_playing()", "Registry.get_portrait_path(hero_id)", "guan_yu"):
    if token not in test:
        errors.append(f"actual playback test missing: {token}")
if errors:
    print("ALL KOREA MVP VIDEO CUTINS VALIDATION FAILED", file=sys.stderr)
    print("\n".join(f"ERROR: {error}" for error in errors), file=sys.stderr)
    raise SystemExit(1)
print("ALL KOREA MVP VIDEO CUTINS VALIDATION PASS: 13 registry/resource contracts and scene-tree playback test coverage")
