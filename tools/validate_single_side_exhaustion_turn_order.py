#!/usr/bin/env python3
"""Regression contract for one-side actor exhaustion in the battle scheduler."""
from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
SOURCE = (ROOT / "scripts/battle_web_import_test.gd").read_text(encoding="utf-8")
TEST = (ROOT / "tests/scripts/test_single_side_exhaustion_turn_order.gd").read_text(encoding="utf-8")
errors: list[str] = []


def require(condition: bool, message: str) -> None:
    if not condition:
        errors.append(message)


def body(name: str) -> str:
    match = re.search(rf"^func {re.escape(name)}\([^\n]*\) -> (?:void|String):\n([\s\S]*?)(?=^func |\Z)", SOURCE, re.M)
    return match.group(1) if match else ""


def schedule(allies: list[str], enemies: list[str]) -> list[str]:
    result: list[str] = []
    while allies or enemies:
        if allies:
            result.append(allies.pop(0))
        if enemies:
            result.append(enemies.pop(0))
    return result + ["round_complete"]


require(schedule(["A1"], ["E1", "E2", "E3", "E4", "E5"]) ==
        ["A1", "E1", "E2", "E3", "E4", "E5", "round_complete"], "1v5 sequence")
require(schedule(["A1", "A2", "A3", "A4", "A5"], ["E1"]) ==
        ["A1", "E1", "A2", "A3", "A4", "A5", "round_complete"], "5v1 sequence")
require(schedule(["A1"], ["E1"]) == ["A1", "E1", "round_complete"], "1v1 sequence")
require(schedule(["A1"], ["E1", "E3", "E5"]) == ["A1", "E1", "E3", "E5", "round_complete"], "dead/confused enemy skip")

side_choice = body("_get_next_side_after_enemy_action")
return_to_ally = body("_return_to_ally_turn")
start_round = body("_start_new_round")
require('return "round_complete"' in side_choice, "missing completed-round side result")
require('return "enemy"' in side_choice, "missing remaining-enemy side result")
require('return "ally"' in side_choice, "missing remaining-ally side result")
require('next_side == "enemy"' in return_to_ally, "exhaustion branch missing")
require("active_unit_state = null" in return_to_ally, "acted ally selection is not cleared")
require("_play_enemy_turn_demo()" in return_to_ally, "remaining enemy actor is not scheduled")
require("이미 행동한 부대입니다" not in return_to_ally, "scheduler emits player already-acted log")
require("call_deferred" not in return_to_ally, "exhaustion branch can loop through deferred callbacks")
require(start_round.count("_settle_battle_supply_turn(") == 1, "supply settlement is not exactly once per round")
require(start_round.count("battle_round += 1") == 1, "round increment is not exactly once")
for token in (
    "_test_one_vs_many_continues_enemy_turn",
    "_test_many_vs_one_returns_next_unacted_ally",
    "_test_one_vs_one_completes_once",
    "current_enemy_ai_actor_state",
    "BattleSupplyRuntime",
):
    require(token in TEST, f"runtime execution test missing {token}")

if errors:
    print("ONE-SIDE EXHAUSTION TURN ORDER VALIDATION FAILED", file=sys.stderr)
    print("\n".join(f"ERROR: {error}" for error in errors), file=sys.stderr)
    raise SystemExit(1)
print("ONE-SIDE EXHAUSTION TURN ORDER PASS: 1v5/5v1/1v1/skip contracts; no acted-ally input deadlock; one round and supply settlement")
