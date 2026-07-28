#!/usr/bin/env python3
"""Validate T06-7 original shared-momentum and unique-skill runtime contract."""
from __future__ import annotations

import json
import re
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SKILLS_PATH = ROOT / "data/heroes/generated/hero_unique_skills.json"
RESOLVER_PATH = ROOT / "scripts/battle/battle_skill_resolver.gd"
MOMENTUM_PATH = ROOT / "scripts/battle/battle_momentum_state.gd"
SNAPSHOT_PATH = ROOT / "scripts/battle/battle_runtime_snapshot.gd"
BATTLE_PATH = ROOT / "scripts/battle_web_import_test.gd"
UNIT_PATH = ROOT / "scripts/battle_unit_state.gd"
FACTORY_PATH = ROOT / "scripts/worldmap/hero_runtime_factory.gd"
SESSION_PATH = ROOT / "scripts/game_session.gd"
SUPPLY_PATH = ROOT / "scripts/t02/battle_supply_runtime.gd"
SMOKE_PATH = ROOT / "scripts/t06_t07/t06_t07_playable_transaction_smoke.gd"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def require(errors: list[str], condition: bool, message: str) -> None:
    if not condition:
        errors.append(message)


def extract_mapping_keys(source: str) -> set[str]:
    match = re.search(r"const ARCHETYPE_BY_EFFECT_TYPE := \{(?P<body>.*?)\n\}", source, re.DOTALL)
    if not match:
        return set()
    return set(re.findall(r'^\s*"([^"]+)"\s*:', match.group("body"), re.MULTILINE))


def extract_function(source: str, function_name: str) -> str:
    match = re.search(
        rf"^(?:static )?func {re.escape(function_name)}\(.*?(?=^(?:static )?func |\Z)",
        source,
        re.MULTILINE | re.DOTALL,
    )
    return match.group(0) if match else ""


def main() -> int:
    errors: list[str] = []
    skills = json.loads(read(SKILLS_PATH)).get("skills", [])
    resolver = read(RESOLVER_PATH)
    momentum = read(MOMENTUM_PATH)
    snapshot = read(SNAPSHOT_PATH)
    battle = read(BATTLE_PATH)
    unit = read(UNIT_PATH)
    factory = read(FACTORY_PATH)
    session = read(SESSION_PATH)
    supply = read(SUPPLY_PATH)
    smoke = read(SMOKE_PATH)

    effect_types = {str(skill.get("effect_type", "")) for skill in skills}
    mapping_keys = extract_mapping_keys(resolver)
    cost_distribution = Counter(int(skill.get("momentum_cost", 0)) for skill in skills)
    require(errors, len(skills) == 39, f"expected 39 unique skills, found {len(skills)}")
    require(errors, cost_distribution == Counter({1: 1, 2: 9, 3: 18, 4: 11}),
            f"momentum distribution mismatch: {dict(cost_distribution)}")
    require(errors, effect_types <= mapping_keys,
            f"resolver mapping missing effect types: {sorted(effect_types - mapping_keys)}")
    require(errors, '"damage_single"' in resolver, "damage_single archetype missing")
    require(errors, '"restore_dispel"' in resolver, "restore_dispel archetype missing")
    require(errors, '"movement_charge"' in resolver, "movement_charge archetype missing")
    for skill in skills:
        hero_id = str(skill.get("hero_id", ""))
        skill_id = str(skill.get("skill_id", ""))
        require(errors, f'"{hero_id}"' not in resolver, f"resolver hardcodes hero ID: {hero_id}")
        require(errors, f'"{skill_id}"' not in resolver, f"resolver hardcodes skill ID: {skill_id}")

    require(errors, "STARTING_MOMENTUM := 3" in momentum, "starting momentum must be 3")
    require(errors, "MAX_MOMENTUM := 10" in momentum, "momentum cap must be 10")
    require(errors, "ROUND_END_GAIN := 1" in momentum, "round end gain must be 1")
    require(errors, "BASIC_ATTACK_GAIN := 1" in momentum, "basic attack gain must be 1")
    require(errors, "RECEIVED_HIT_LOSS := 1" in momentum, "normal hit loss must be 1")
    require(errors, "SPECIAL_HIT_EXTRA_LOSS := 1" in momentum, "special hit extra loss must be 1")
    require(errors, "func spend(" in momentum, "momentum commit spend API missing")
    require(errors, "func record_round_end(" in momentum, "round end momentum API missing")
    require(errors, "func record_received_hit(" in momentum, "received-hit momentum API missing")
    require(errors, "func restore(" in momentum, "momentum restore API missing")

    factory_build = extract_function(factory, "build_runtime_hero")
    factory_payload = extract_function(factory, "build_battle_unit_payload")
    require(errors, 'result["design_unique_skill"] = unique_skill' in factory_build,
            "factory does not attach validated skill definition")
    require(errors, '"design_unique_skill"' in factory_payload or '"design_unique_skill"' in factory,
            "battle payload does not protect skill authority")
    require(errors, "unique_skill_definition" in unit, "BattleUnitState lacks skill definition")

    get_skill = extract_function(battle, "_get_unique_skill_for_unit")
    require(errors, "unique_skill_definition" in get_skill,
            "battle skill lookup does not consume BattleUnitState authority")
    require(errors, "UNIQUE_SKILL_REGISTRY" not in get_skill,
            "battle skill lookup still falls back to legacy registry")
    require(errors, "BattleSkillResolverScript.build_plan" in battle,
            "player/AI runtime does not call BattleSkillResolver")
    require(errors, battle.count('"enemy_adjacent"') >= 3,
            "adjacent self-anchored skill target flow is incomplete")
    require(errors, "battle_momentum.spend" in battle,
            "skill execution does not commit shared momentum")
    require(errors, "_gain_momentum_for_basic_attack(active_unit_state)" in battle,
            "player basic attack does not gain momentum")
    require(errors, "_gain_momentum_for_basic_attack(current_enemy_ai_actor_state)" in battle,
            "AI basic attack does not gain momentum")
    require(errors, "battle_momentum.record_round_end()" in battle,
            "round completion does not grant both sides momentum")
    require(errors, "record_received_hit(defending_side" in battle,
            "successful basic attack does not reduce defending side momentum")
    require(errors, '"unique_skill_hit"' in resolver and "-2" in resolver,
            "damaging unique skill does not apply one total -2 side loss")
    require(errors, "_score_unique_skill_plan_for_actor" in battle,
            "AI does not score resolver plans")
    require(errors, "AllyMomentumLabel" in battle and "EnemyMomentumLabel" in battle and "MomentumFeedbackLabel" in battle and "MomentumHudRefreshTimer" in battle,
            "persistent momentum HUD or spend feedback missing")
    require(errors, "기세 미소비" in battle,
            "cancel/failure no-charge log evidence missing")

    require(errors, "func capture(" in snapshot and "func restore(" in snapshot,
            "battle runtime snapshot roundtrip missing")
    require(errors, "save_battle_resume_snapshot" in session,
            "GameSession battle snapshot save missing")
    require(errors, "load_battle_resume_snapshot" in session,
            "GameSession battle snapshot load missing")
    require(errors, "_try_restore_battle_resume_snapshot" in battle,
            "battle scene resume hook missing")
    require(errors, "serialize_runtime" in supply and "restore_runtime" in supply,
            "battle supply runtime roundtrip missing")
    require(errors, "GameSession.clear_battle_resume_snapshot()" in battle,
            "completed battle does not clear resume snapshot")

    require(errors, "_test_all_39_skill_resolutions" in smoke,
            "39-skill resolver smoke coverage missing")
    require(errors, "_test_momentum_transaction" in smoke,
            "momentum transaction smoke coverage missing")
    require(errors, "round end gives both sides" in smoke,
            "round-end momentum smoke missing")
    require(errors, "cooperative hit loses total 2" in smoke,
            "cooperative-hit momentum smoke missing")
    require(errors, "_test_snapshot_roundtrip" in smoke,
            "snapshot roundtrip smoke coverage missing")

    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1

    print("T06-7 HOTFIX1 RUNTIME VALIDATION PASS")
    print("39 skills; cost 1/9/18/11; shared momentum 3/10; round/basic/special contracts locked")
    print("player/AI resolver, UI/log evidence, and battle snapshot save/resume locked")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
