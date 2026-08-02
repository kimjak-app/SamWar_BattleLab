#!/usr/bin/env python3
"""Validate registered Korea MVP videos win over unrelated visual fallbacks."""
from pathlib import Path
import json
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
REGISTRY_JSON = ROOT / "data/cutin/korea_mvp_hero_cutins.json"
REGISTRY_GD = ROOT / "scripts/ui/cutin/korea_mvp_hero_cutin_registry.gd"
BATTLE = ROOT / "scripts/battle_web_import_test.gd"
errors: list[str] = []


def require(condition: bool, message: str) -> None:
    if not condition:
        errors.append(message)


def resource_path(path: str) -> Path:
    require(path.startswith("res://"), f"non-res path: {path}")
    return ROOT / path.removeprefix("res://")


entries = json.loads(REGISTRY_JSON.read_text(encoding="utf-8")).get("entries", [])
registry_source = REGISTRY_GD.read_text(encoding="utf-8")
battle_source = BATTLE.read_text(encoding="utf-8")
runtime_pairs = {
    "yi_sunsin": "hakikjin_barrage",
    "jeong_dojeon": "reform_order",
    "kwon_yul": "gwon_yul_haengju_defense",
    "gim_yusin": "kim_yu_sin_unification_charge",
    "eulji_mundeok": "eulji_mundeok_salsu_ambush",
}
for hero_id, skill_id in runtime_pairs.items():
    require(f'"{skill_id}"' in registry_source, f"missing runtime skill alias: {hero_id}/{skill_id}")
for entry in entries:
    if not entry.get("enabled", False):
        continue
    hero_id = str(entry.get("hero_id", ""))
    require(hero_id != "", "enabled entry missing hero_id")
    for field in ("video_path", "skill_title_texture_path"):
        path = str(entry.get(field, ""))
        file = resource_path(path)
        require(file.exists(), f"missing {field}: {hero_id} -> {path}")
        require((file.with_suffix(file.suffix + ".uid")).exists() or field != "video_path", f"missing OGV UID: {path}")
    require(str(entry.get("video_path", "")).endswith(".ogv"), f"registered video is not OGV: {hero_id}")
for forbidden in ("reinforcement_arrival_toast", "unique_skill_ready_icon"):
    require(forbidden not in registry_source and forbidden not in REGISTRY_JSON.read_text(encoding="utf-8"),
            f"unrelated flag/icon leaked into cutin registry: {forbidden}")
require("if _play_committed_hero_cutin(caster_state, skill_data):" in battle_source, "registry video is not first cutin route")
require("KoreaMvpHeroCutinRegistryScript.find_entry(canonical_skill_owner_hero_id, skill_id)" in battle_source, "battle does not query video registry with canonical ID")
require("route=registry_video" in battle_source, "registry video route logging missing")

if errors:
    print("KOREA MVP VIDEO CUTIN ROUTING VALIDATION FAILED", file=sys.stderr)
    print("\n".join(f"ERROR: {error}" for error in errors), file=sys.stderr)
    raise SystemExit(1)
print("KOREA MVP VIDEO CUTIN ROUTING PASS: runtime aliases, registered OGV/title resources, video-first route, no flag fallback")
