#!/usr/bin/env python3
"""Protect legacy runtime hero lookups while keeping canonical IDs at the cutin boundary."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
BATTLE = (ROOT / "scripts/battle_web_import_test.gd").read_text(encoding="utf-8")
TEST = (ROOT / "tests/scripts/test_runtime_hero_id_and_cutin_boundary.gd").read_text(encoding="utf-8")
errors: list[str] = []

def require(condition: bool, message: str) -> None:
    if not condition:
        errors.append(message)

getter = re.search(r"func _get_hero_id_for_unit_state\(unit_state: BattleUnitState\) -> String:\n(.*?)(?=\n\nfunc )", BATTLE, re.S)
require(getter is not None, "missing runtime hero ID getter")
if getter:
    getter_source = getter.group(1)
    require("canonicalize_hero_id" not in getter_source, "runtime hero getter globally canonicalizes IDs")
    require("return assigned_hero_id" in getter_source, "assigned runtime ID contract missing")
    require("return _get_test_battle_roster_hero_id(capacity_slot_id)" in getter_source, "test runtime ID contract missing")

committed = re.search(r"func _get_committed_skill_hero_id\(caster_state: BattleUnitState, skill_data: Dictionary\) -> String:\n(.*?)(?=\n\nfunc )", BATTLE, re.S)
require(committed is not None and "canonicalize_hero_id" not in committed.group(1), "skill owner getter must return raw runtime ID")

cutin = re.search(r"func _play_committed_hero_cutin\(caster_state: BattleUnitState, skill_data: Dictionary\) -> bool:\n(.*?)(?=\n\nfunc _get_committed_skill_hero_id)", BATTLE, re.S)
require(cutin is not None, "missing cutin boundary")
if cutin:
    source = cutin.group(1)
    for token in ("runtime_caster_hero_id", "raw_skill_owner_hero_id", "canonical_caster_hero_id", "canonical_skill_owner_hero_id"):
        require(token in source, f"cutin boundary missing explicit ID variable: {token}")
    require("find_entry(canonical_skill_owner_hero_id, skill_id)" in source, "cutin registry lookup is not canonical")
    require("canonical_skill_owner_hero_id != canonical_caster_hero_id" in source, "cutin parity is not canonical")

for hero_id, expected_name in {"yi_sunsin": "이순신", "jeong_dojeon": "정도전", "gim_yusin": "김유신"}.items():
    require(f'"{hero_id}": {{' in BATTLE, f"HERO_REGISTRY missing runtime key {hero_id}")
    require(f'"display_name": "{expected_name}"' in BATTLE, f"HERO_REGISTRY missing display name {expected_name}")
for token in ("gim_yusin", "jeong_dojeon", "yi_sunsin", "kwon_yul", "지원군 선봉"):
    require(token in TEST, f"runtime boundary test missing {token}")

if errors:
    print("RUNTIME HERO ID CONTRACT VALIDATION FAILED", file=sys.stderr)
    print("\n".join(f"ERROR: {error}" for error in errors), file=sys.stderr)
    raise SystemExit(1)
print("RUNTIME HERO ID CONTRACT PASS: legacy HERO_REGISTRY lookups preserved; canonicalization isolated to cutin boundary")
