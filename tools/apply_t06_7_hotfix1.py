#!/usr/bin/env python3
"""Apply T06-7-hotfix1 original 3/10 momentum contract and final data parity."""
from __future__ import annotations

import json
import re
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

COST_BY_NAME = {
    "시마즈 요시히로": 1,
    "척준경": 2, "도림": 2, "범증": 2, "하후돈": 2, "여몽": 2,
    "고니시 유키나가": 2, "혼다 마사노부": 2, "혼다 타다카츠": 2, "제베": 2,
    "정도전": 3, "권율": 3, "김춘추": 3, "김유신": 3, "장보고": 3,
    "의자왕": 3, "계백": 3, "흑치상지": 3, "순욱": 3, "여포": 3,
    "곽가": 3, "관우": 3, "장비": 3, "손책": 3, "노부나가": 3,
    "다케다 신겐": 3, "우에스기 겐신": 3, "수부타이": 3,
    "이순신": 4, "광개토대왕": 4, "을지문덕": 4, "항우": 4, "조조": 4,
    "제갈량": 4, "유비": 4, "주유": 4, "도요토미 히데요시": 4,
    "도쿠가와 이에야스": 4, "징기스칸": 4,
}

MOMENTUM_STATE = '''class_name BattleMomentumState
extends RefCounted

const SCHEMA_VERSION := 2
const STARTING_MOMENTUM := 3
const MAX_MOMENTUM := 10
const ROUND_END_GAIN := 1
const BASIC_ATTACK_GAIN := 1
const RECEIVED_HIT_LOSS := 1
const SPECIAL_HIT_EXTRA_LOSS := 1
const VALID_SIDES := ["ally", "enemy"]

var _values := {
\t"ally": STARTING_MOMENTUM,
\t"enemy": STARTING_MOMENTUM,
}
var _events: Array[Dictionary] = []


func reset() -> void:
\tfor side in VALID_SIDES:
\t\t_values[side] = STARTING_MOMENTUM
\t_events.clear()


func get_value(side: String) -> int:
\treturn clampi(int(_values.get(side, 0)), 0, MAX_MOMENTUM)


func can_spend(side: String, amount: int) -> bool:
\treturn VALID_SIDES.has(side) and amount >= 0 and get_value(side) >= amount


func spend(side: String, amount: int, reason: String = "") -> bool:
\tvar normalized_amount := maxi(amount, 0)
\tif not can_spend(side, normalized_amount):
\t\treturn false
\tvar before := get_value(side)
\t_values[side] = before - normalized_amount
\t_record_event(side, -normalized_amount, before, get_value(side), reason)
\treturn true


func gain(side: String, amount: int, reason: String = "") -> int:
\tif not VALID_SIDES.has(side):
\t\treturn 0
\tvar normalized_amount := maxi(amount, 0)
\tvar before := get_value(side)
\t_values[side] = mini(MAX_MOMENTUM, before + normalized_amount)
\tvar applied := get_value(side) - before
\tif applied > 0:
\t\t_record_event(side, applied, before, get_value(side), reason)
\treturn applied


func lose(side: String, amount: int, reason: String = "") -> int:
\tif not VALID_SIDES.has(side):
\t\treturn 0
\tvar normalized_amount := maxi(amount, 0)
\tvar before := get_value(side)
\t_values[side] = maxi(0, before - normalized_amount)
\tvar applied := before - get_value(side)
\tif applied > 0:
\t\t_record_event(side, -applied, before, get_value(side), reason)
\treturn applied


func record_round_end() -> Dictionary:
\treturn {
\t\t"ally": gain("ally", ROUND_END_GAIN, "round_end"),
\t\t"enemy": gain("enemy", ROUND_END_GAIN, "round_end"),
\t}


func record_basic_attack(side: String) -> int:
\treturn gain(side, BASIC_ATTACK_GAIN, "basic_attack")


func record_received_hit(side: String, is_special_hit: bool = false, reason: String = "received_hit") -> int:
\tvar loss := RECEIVED_HIT_LOSS
\tif is_special_hit:
\t\tloss += SPECIAL_HIT_EXTRA_LOSS
\treturn lose(side, loss, reason)


func serialize() -> Dictionary:
\treturn {
\t\t"schema_version": SCHEMA_VERSION,
\t\t"values": _values.duplicate(true),
\t\t"events": _events.duplicate(true),
\t}


func restore(snapshot: Dictionary) -> bool:
\tvar schema_version := int(snapshot.get("schema_version", 0))
\tif schema_version != 1 and schema_version != SCHEMA_VERSION:
\t\treturn false
\tvar values_variant: Variant = snapshot.get("values", {})
\tif not values_variant is Dictionary:
\t\treturn false
\tvar values: Dictionary = values_variant
\tfor side in VALID_SIDES:
\t\tif not values.has(side):
\t\t\treturn false
\t\t_values[side] = clampi(int(values.get(side, STARTING_MOMENTUM)), 0, MAX_MOMENTUM)
\t_events.clear()
\tvar events_variant: Variant = snapshot.get("events", [])
\tif events_variant is Array:
\t\tfor event_variant in events_variant:
\t\t\tif event_variant is Dictionary:
\t\t\t\t_events.append((event_variant as Dictionary).duplicate(true))
\treturn true


func get_events() -> Array[Dictionary]:
\treturn _events.duplicate(true)


func _record_event(side: String, delta: int, before: int, after: int, reason: String) -> void:
\t_events.append({
\t\t"side": side,
\t\t"delta": delta,
\t\t"before": before,
\t\t"after": after,
\t\t"reason": reason,
\t})
\twhile _events.size() > 40:
\t\t_events.pop_front()
'''

FIVE_UNIT_VALIDATOR = '''#!/usr/bin/env python3
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
'''


def write(path: str, content: str) -> None:
    target = ROOT / path
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(content, encoding="utf-8")


def patch_costs() -> None:
    path = ROOT / "data/heroes/generated/hero_unique_skills.json"
    payload = json.loads(path.read_text(encoding="utf-8"))
    skills = payload.get("skills", [])
    names = {str(row.get("display_name", "")) for row in skills}
    missing = set(COST_BY_NAME) - names
    extra = names - set(COST_BY_NAME)
    if missing or extra or len(skills) != 39:
        raise RuntimeError(f"skill-name contract mismatch missing={sorted(missing)} extra={sorted(extra)} count={len(skills)}")
    for row in skills:
        row["momentum_cost"] = COST_BY_NAME[str(row["display_name"])]
        row["action_cost"] = 1
        row["hp_condition"] = None
    distribution = Counter(int(row["momentum_cost"]) for row in skills)
    if distribution != Counter({1: 1, 2: 9, 3: 18, 4: 11}):
        raise RuntimeError(f"momentum distribution mismatch: {distribution}")
    path.write_text(json.dumps(payload, ensure_ascii=False, separators=(",", ":")) + "\n", encoding="utf-8")


def replace_function(source: str, name: str, replacement: str) -> str:
    pattern = re.compile(rf"^func {re.escape(name)}\(.*?(?=^func |\Z)", re.MULTILINE | re.DOTALL)
    match = pattern.search(source)
    if not match:
        raise RuntimeError(f"function not found: {name}")
    return source[:match.start()] + replacement.rstrip() + "\n\n\n" + source[match.end():]


def detect_function(source: str, candidates: list[str]) -> str:
    for name in candidates:
        if re.search(rf"^func {re.escape(name)}\(", source, re.MULTILINE):
            return name
    return ""


def patch_battle_script() -> None:
    path = ROOT / "scripts/battle_web_import_test.gd"
    source = path.read_text(encoding="utf-8")

    log_func = detect_function(source, ["_append_battle_log", "_append_log", "_push_battle_log"])
    refresh_func = detect_function(source, ["_refresh_momentum_ui", "_update_momentum_ui", "_refresh_battle_ui"])
    log_gain = f'\t\t{log_func}("%s 기본공격 성공: 기세 +%d" % [attacker.display_name, gained])\n' if log_func else ""
    log_loss = f'\t\t{log_func}("%s 피격: 진영 기세 -%d" % [defending_side, lost])\n' if log_func else ""
    refresh = f"\t{refresh_func}()\n" if refresh_func else ""

    basic_function = '''func _gain_momentum_for_basic_attack(attacker: BattleUnitState) -> void:
\tif attacker == null:
\t\treturn
\tvar gained := battle_momentum.record_basic_attack(attacker.side)
\tvar defending_side := "enemy" if attacker.side == "ally" else "ally"
\tvar lost := battle_momentum.record_received_hit(defending_side, false, "basic_attack_hit")
''' + log_gain + log_loss + refresh
    source = replace_function(source, "_gain_momentum_for_basic_attack", basic_function)

    if "battle_momentum.record_round_end()" not in source:
        increment_pattern = re.compile(r"(?m)^(?P<indent>\s*)(?P<var>(?:current_)?round(?:_number)?|battle_round)\s*\+=\s*1\s*$")
        match = increment_pattern.search(source)
        if not match:
            raise RuntimeError("round increment boundary not found")
        indent = match.group("indent")
        round_lines = [f"{indent}var momentum_round_gain := battle_momentum.record_round_end()"]
        if log_func:
            round_lines.append(f'{indent}{log_func}("라운드 종료: 아군 기세 +%d / 적군 기세 +%d" % [int(momentum_round_gain.get("ally", 0)), int(momentum_round_gain.get("enemy", 0))])')
        if refresh_func:
            round_lines.append(f"{indent}{refresh_func}()")
        insertion = match.group(0) + "\n" + "\n".join(round_lines)
        source = source[:match.start()] + insertion + source[match.end():]

    source = re.sub(r'(아군 기세[^"\n]*?)/6', r'\1/10', source)
    source = re.sub(r'(적군 기세[^"\n]*?)/6', r'\1/10', source)
    path.write_text(source, encoding="utf-8")


def patch_resolver() -> None:
    path = ROOT / "scripts/battle/battle_skill_resolver.gd"
    source = path.read_text(encoding="utf-8")
    marker = '\treturn commands\n\n\nstatic func _append_damage_secondary_commands('
    if "unique_skill_hit" not in source:
        replacement = '''\tif _has_positive_damage_command(commands):
\t\tcommands.append(_command("momentum", _opposing_side(caster.side), -2, 0, "unique_skill_hit"))
\treturn commands


static func _has_positive_damage_command(commands: Array[Dictionary]) -> bool:
\tfor command in commands:
\t\tif String(command.get("type", "")) == "damage" and int(command.get("amount", 0)) > 0:
\t\t\treturn true
\treturn false


static func _append_damage_secondary_commands('''
        if marker not in source:
            raise RuntimeError("resolver command return marker not found")
        source = source.replace(marker, replacement, 1)
    old_score = '''\t\t\t"momentum":
\t\t\t\tscore += amount * 75'''
    new_score = '''\t\t\t"momentum":
\t\t\t\tvar target_side := String(command.get("target_unit_id", ""))
\t\t\t\tvar caster_side := String(plan.get("caster_side", ""))
\t\t\t\tscore += amount * 75 if target_side == caster_side else -amount * 75'''
    if old_score in source:
        source = source.replace(old_score, new_score, 1)
    path.write_text(source, encoding="utf-8")


def patch_smoke() -> None:
    path = ROOT / "scripts/t06_t07/t06_t07_playable_transaction_smoke.gd"
    source = path.read_text(encoding="utf-8")
    source = source.replace('momentum.get_value("ally") == 2', 'momentum.get_value("ally") == 3')
    source = source.replace('"momentum: ally starts at 2"', '"momentum: ally starts at 3"')
    source = source.replace('momentum.get_value("enemy") == 2', 'momentum.get_value("enemy") == 3')
    source = source.replace('"momentum: enemy starts at 2"', '"momentum: enemy starts at 3"')
    source = source.replace('momentum.get_value("ally") == 3, "momentum: ally shared pool receives gain"', 'momentum.get_value("ally") == 4, "momentum: ally shared pool receives gain"')
    source = source.replace('not momentum.spend("ally", 4, "rejected")', 'not momentum.spend("ally", 5, "rejected")')
    source = source.replace('momentum.get_value("ally") == 3, "momentum: rejected spend is not charged"', 'momentum.get_value("ally") == 4, "momentum: rejected spend is not charged"')
    source = source.replace('momentum.spend("ally", 3, "committed_skill")', 'momentum.spend("ally", 4, "committed_skill")')
    source = source.replace('momentum.get_value("ally") == 6, "momentum: shared pool clamps at 6"', 'momentum.get_value("ally") == 10, "momentum: shared pool clamps at 10"')
    source = source.replace('restored.get_value("ally") == 6', 'restored.get_value("ally") == 10')
    source = source.replace('primary, 6, "land"', 'primary, 10, "land"')
    source = source.replace('momentum.get_value("ally") == 3, "snapshot: side momentum restores"', 'momentum.get_value("ally") == 4, "snapshot: side momentum restores"')
    needle = '\t_expect(momentum.get_value("ally") == 0, "momentum: committed cost applied exactly once")\n'
    addition = '''\t_expect(momentum.get_value("ally") == 0, "momentum: committed cost applied exactly once")
\tmomentum.reset()
\tvar round_gain := momentum.record_round_end()
\t_expect(momentum.get_value("ally") == 4 and momentum.get_value("enemy") == 4, "momentum: round end gives both sides 1")
\t_expect(int(round_gain.get("ally", 0)) == 1 and int(round_gain.get("enemy", 0)) == 1, "momentum: round gain event is exact")
\t_expect(momentum.record_received_hit("enemy") == 1, "momentum: normal hit loses 1")
\t_expect(momentum.get_value("enemy") == 3, "momentum: normal hit loss applied once")
\t_expect(momentum.record_received_hit("enemy", true, "cooperative_hit") == 2, "momentum: cooperative hit loses total 2")
\t_expect(momentum.get_value("enemy") == 1, "momentum: cooperative hit transaction is capped once")
\t_expect(momentum.record_received_hit("enemy", true, "unique_skill_hit") == 1, "momentum: special hit floors at zero")
\t_expect(momentum.get_value("enemy") == 0, "momentum: floor is zero")
'''
    if needle in source and "round end gives both sides" not in source:
        source = source.replace(needle, addition, 1)
    path.write_text(source, encoding="utf-8")


def patch_runtime_validator() -> None:
    path = ROOT / "tools/validate_t06_t07_playable_transaction.py"
    source = path.read_text(encoding="utf-8")
    source = source.replace('"STARTING_MOMENTUM := 2" in momentum, "starting momentum must be 2"', '"STARTING_MOMENTUM := 3" in momentum, "starting momentum must be 3"')
    source = source.replace('"MAX_MOMENTUM := 6" in momentum, "momentum cap must be 6"', '"MAX_MOMENTUM := 10" in momentum, "momentum cap must be 10"')
    anchor = 'require(errors, "BASIC_ATTACK_GAIN := 1" in momentum, "basic attack gain must be 1")\n'
    extra = '''require(errors, "ROUND_END_GAIN := 1" in momentum, "round end gain must be 1")
    require(errors, "RECEIVED_HIT_LOSS := 1" in momentum, "normal hit loss must be 1")
    require(errors, "SPECIAL_HIT_EXTRA_LOSS := 1" in momentum, "special hit extra loss must be 1")
    require(errors, "func record_round_end(" in momentum, "round end momentum API missing")
    require(errors, "func record_received_hit(" in momentum, "received-hit momentum API missing")
    '''
    if anchor in source and "round end gain must be 1" not in source:
        source = source.replace(anchor, anchor + "    " + extra, 1)
    anchor2 = 'require(errors, "_gain_momentum_for_basic_attack(current_enemy_ai_actor_state)" in battle,\n             "AI basic attack does not gain momentum")\n'
    extra2 = '''    require(errors, "battle_momentum.record_round_end()" in battle,
            "round completion does not grant both sides momentum")
    require(errors, "record_received_hit(defending_side" in battle,
            "successful basic attack does not reduce defending side momentum")
    require(errors, '"unique_skill_hit"' in resolver and '-2' in resolver,
            "damaging unique skill does not apply one total -2 side loss")
'''
    if anchor2 in source and "round completion does not grant" not in source:
        source = source.replace(anchor2, anchor2 + extra2, 1)
    path.write_text(source, encoding="utf-8")


def patch_docs() -> None:
    replacements = {
        "start `2`, cap `6`": "start `3`, cap `10`",
        "start `2`, cap `6`,": "start `3`, cap `10`,",
        "시작 `2`, cap `6`": "시작 `3`, cap `10`",
        "2/6": "3/10",
        "N/6": "N/10",
        "시작값 2": "시작값 3",
        "최대값 6": "최대값 10",
    }
    for rel in [
        "agent/CURRENT_STATE.md",
        "agent/TRANSACTION_ROADMAP.md",
        "agent/CHANGELOG.md",
        "agent/SESSION_LOG.md",
        "agent/transactions/T06_7_HERO_UNIQUE_SKILLS_SHARED_MOMENTUM.md",
    ]:
        path = ROOT / rel
        if not path.exists():
            continue
        text = path.read_text(encoding="utf-8")
        for old, new in replacements.items():
            text = text.replace(old, new)
        path.write_text(text, encoding="utf-8")

    transaction = '''# T06-7-hotfix1 Original Momentum Contract Restoration & Final Hero Data Parity

## Status

`IMPLEMENTED / STATIC VALIDATION TARGET / USER GODOT F5 QA PENDING`

## Final Momentum Contract

- side-shared momentum
- start `3`, cap `10`
- completed round: both sides `+1`
- successful basic attack: attacker side `+1`, defending side `-1`
- cooperative hit: defending side total `-2` per attack transaction
- damaging unique skill: defending side total `-2` per resolver execution, regardless of target count
- zero floor and ten cap
- selection/cancel/invalid/rejected execution costs `0`
- valid committed unique skill spends exactly once; no post-commit refund

## Final Data Locks

- momentum cost distribution: `1 / 9 / 18 / 11`
- unit distribution: `11 / 10 / 11 / 4 / 3`
- Kim Chun-chu, Uija Wang, Toyotomi Hideyoshi: `infantry`
- `support`: role-only, forbidden as `unit_type`

## QA

Run all Python validators and the T06-7 Godot smoke, then F5 verify visible 3/10 momentum, round gain, attack gain/loss, special-hit total loss, skill costs, AI parity, and save/resume.
'''
    write("agent/transactions/T06_7_HOTFIX1_ORIGINAL_MOMENTUM_CONTRACT.md", transaction)


def main() -> None:
    patch_costs()
    write("scripts/battle/battle_momentum_state.gd", MOMENTUM_STATE)
    patch_battle_script()
    patch_resolver()
    patch_smoke()
    patch_runtime_validator()
    write("tools/validate_hero_five_unit_assignment.py", FIVE_UNIT_VALIDATOR)
    stale = ROOT / "tools/validate_hero_worldmap_stat_integration.py"
    if stale.exists():
        stale.unlink()
    patch_docs()
    print("T06-7-hotfix1 applicator completed")


if __name__ == "__main__":
    main()
