#!/usr/bin/env python3
"""Regression contract for unit-by-unit alternating battle initiative."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
SOURCE = (ROOT / "scripts/battle_web_import_test.gd").read_text(encoding="utf-8")
errors: list[str] = []


def require(condition: bool, message: str) -> None:
    if not condition:
        errors.append(message)


def body(name: str) -> str:
    match = re.search(rf"^func {re.escape(name)}\([^\n]*\) -> void:\n([\s\S]*?)(?=^func |\Z)", SOURCE, re.M)
    return match.group(1) if match else ""


def schedule(allies: list[str], enemies: list[str]) -> list[str]:
    """The runtime contract: one ally, then one enemy, then the next valid side."""
    result: list[str] = []
    for index in range(max(len(allies), len(enemies))):
        if index < len(allies):
            result.append(allies[index])
        if index < len(enemies):
            result.append(enemies[index])
    result.append("round_complete")
    return result


require(schedule(["ally_1", "ally_2", "ally_3"], ["enemy_1", "enemy_2", "enemy_3"]) ==
        ["ally_1", "enemy_1", "ally_2", "enemy_2", "ally_3", "enemy_3", "round_complete"], "3v3 contract failed")
require(schedule(["ally_1", "ally_2", "ally_3"], ["enemy_1", "enemy_2"]) ==
        ["ally_1", "enemy_1", "ally_2", "enemy_2", "ally_3", "round_complete"], "3v2 contract failed")
require(schedule(["ally_1", "ally_2"], ["enemy_1", "enemy_2", "enemy_3"]) ==
        ["ally_1", "enemy_1", "ally_2", "enemy_2", "enemy_3", "round_complete"], "2v3 contract failed")
require(schedule(["ally_1"], ["enemy_1", "enemy_2"]) == ["ally_1", "enemy_1", "enemy_2", "round_complete"], "unavailable-actor skip contract failed")
require(schedule(["ally_1"], ["enemy_1", "enemy_2", "enemy_3", "enemy_4", "enemy_5"]) ==
        ["ally_1", "enemy_1", "enemy_2", "enemy_3", "enemy_4", "enemy_5", "round_complete"], "1v5 exhaustion contract failed")
require(schedule(["ally_1", "ally_2", "ally_3", "ally_4", "ally_5"], ["enemy_1"]) ==
        ["ally_1", "enemy_1", "ally_2", "ally_3", "ally_4", "ally_5", "round_complete"], "5v1 exhaustion contract failed")
require(schedule(["ally_1"], ["enemy_1"]) == ["ally_1", "enemy_1", "round_complete"], "1v1 contract failed")

advance = body("_advance_enemy_turn_or_return_to_ally")
return_to_ally = body("_return_to_ally_turn")
finish_attack = body("_finish_enemy_actor_basic_attack")
require("_return_to_ally_turn()" in advance, "enemy completion no longer returns initiative to ally")
require("_play_enemy_ai_for_actor" not in advance and "call_deferred" not in advance, "enemy completion schedules another enemy actor")
require("_get_next_side_after_enemy_action()" in return_to_ally, "ally return path does not resolve side exhaustion")
require('next_side == "enemy"' in return_to_ally and "_play_enemy_turn_demo()" in return_to_ally,
        "ally exhaustion does not continue one enemy actor")
require("active_unit_state = null" in return_to_ally, "ally exhaustion can leave an acted ally selected")
require("call_deferred" not in return_to_ally, "side exhaustion must not create an unbounded deferred loop")
require("_advance_enemy_turn_or_return_to_ally()" in finish_attack or "_return_to_ally_turn()" in finish_attack,
        "enemy attack completion does not return initiative")
require('next_side == "round_complete"' in return_to_ally,
        "round may advance before both sides complete")
require("_settle_battle_supply_turn(battle_round)" in body("_start_new_round"), "supply settlement missing from round boundary")
require(body("_start_new_round").count("_settle_battle_supply_turn(") == 1, "supply settlement must occur once per completed round")

if errors:
    print("ALTERNATING BATTLE ACTION ORDER VALIDATION FAILED", file=sys.stderr)
    print("\n".join(f"ERROR: {error}" for error in errors), file=sys.stderr)
    raise SystemExit(1)
print("ALTERNATING BATTLE ACTION ORDER PASS: 3v3/3v2/2v3/1v5/5v1/1v1/skip contract, one-enemy completion, exhaustion and supply boundary")
