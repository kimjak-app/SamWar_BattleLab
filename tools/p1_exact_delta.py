"""Exact, reviewable deltas approved after the WorldMap warning-cleanup checkpoint.

The checkpoint-style guards (diplomacy routing, AF-1 settlement) deliberately compare
files byte-for-byte against an approved commit. P-1C/P-1D then changed two files on
purpose. Instead of relaxing those guards, the new state is pinned to a commit AND the
exact line delta between the old approved state and the new one is spelled out here,
so any further drift still fails.

Regenerate only with a reviewed, intentional change:
    delta = line_delta(git_show(OLD, path), git_show(NEW, path))
"""

import difflib
import subprocess

WARNING_CLEANUP_CHECKPOINT = "c098fb7e92006103c630aefb20b99067e2822caf"

# Last commit that touched worldmap_main.gd on the P-1 line (P-1D retreat label hotfix).
P1_MAIN_CHECKPOINT = "9b2cd8ee6d5ab2aac1071af8e43ed5f7360bde2d"
# Last commit that touched battle_settlement_applier.gd on the P-1 line (P-1D hotfix).
P1D_SETTLEMENT_CHECKPOINT = "f1f3fde1e0698a94e1de29fdeb942ab96e4c2226"

EXPECTED_P1_MAIN_DELTA = ['-const WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Land.tscn"',
 '+const WORLDMAP_BATTLE_SCENE_PATH := "res://scenes/battle/Battle_Main.tscn"',
 '-\tvar attacker_won := str(plan.get("result_kind", "")) == INVASION_RESULT_ATTACKER_WIN',
 '-\tvar outcome_label := "점령 성공" if attacker_won else ("30턴 제한 패배" if '
 'str(result.get("result_reason", "")) == "turn_limit" else "공격 패배")',
 '+\tvar result_kind := str(plan.get("result_kind", ""))',
 '+\tvar attacker_won := result_kind == INVASION_RESULT_ATTACKER_WIN',
 '+\tvar outcome_label := "점령 성공" if attacker_won else ("후퇴" if result_kind == '
 'INVASION_RESULT_RETREAT or str(result.get("result_reason", "")) == "retreat" else ("30턴 제한 패배" '
 'if str(result.get("result_reason", "")) == "turn_limit" else "공격 패배"))',
 '+\t_refresh_territory_overlay_if_present()',
 '+',
 '+',
 '+func _refresh_territory_overlay_if_present() -> void:',
 '+\tvar territory := get_node_or_null("WorldMapTerritoryController")',
 '+\tif territory != null and territory.has_method("refresh_territory_data"):',
 '+\t\tterritory.call_deferred("refresh_territory_data")',
 '+\t_refresh_worldmap_tech_badge_summary_if_present()',
 '+',
 '+',
 '+func _refresh_worldmap_tech_badge_summary_if_present() -> void:',
 '+\tvar badges := get_node_or_null("WorldMapTechBadgeSummaryController")',
 '+\tif badges != null and badges.has_method("refresh_from_runtime"):',
 '+\t\tbadges.call_deferred("refresh_from_runtime")',
 '+\t_refresh_worldmap_tech_badge_summary_if_present()',
 '+\t_refresh_territory_overlay_if_present()']

EXPECTED_P1D_SETTLEMENT_DELTA = ['-\tif result_kind == RESULT_RETREAT:',
 '+\tif result_kind == RESULT_RETREAT and str(plan.get("settlement_profile", "standard")) != '
 '"t02_return":',
 '+\telif not attacker_won:',
 '+\t\tvar defending_wounded := maxi(0, int(troop_plan.get("defender_wounded", 0)))',
 '+\t\tif defending_wounded > 0:',
 '+\t\t\t_m("add_wounded", [target_city_id, defending_wounded, '
 'int(_config.get("normal_wounded_turns", 3)), "normal", str(plan.get("transaction_id", ""))], '
 'null)',
 '+\t\t\treport["troop_changes"].append({"city_id": target_city_id, "wounded_added": '
 'defending_wounded})',
 '-\tif str(plan.get("result_kind", "")) == RESULT_ATTACKER_WIN:',
 '+\tif str(plan.get("result_kind", "")) == RESULT_ATTACKER_WIN or '
 'str(plan.get("settlement_profile", "standard")) == "t02_return":']


# Queue 36 STOCK-AUTHORITY-P0 (Kim approved re-pin 11-27): the code commit that made each city's resource_stock the only
# stock ledger. worldmap_main.gd must equal that commit and differ from P1_MAIN_CHECKPOINT by exactly
# EXPECTED_P0_STOCK_MAIN_DELTA. Other files the same commit changed on purpose, which older guards freeze byte for byte,
# are listed in EXPECTED_P0_STOCK_FROZEN_DELTAS: path -> exact delta from the text such a guard expects.
# Empty checkpoint = no approved P0 state yet (only the P-1 state is accepted).
P0_STOCK_CHECKPOINT = ""
EXPECTED_P0_STOCK_MAIN_DELTA: list[str] = []
EXPECTED_P0_STOCK_FROZEN_DELTAS: dict[str, list[str]] = {}


def line_delta(old_text: str, new_text: str) -> list[str]:
    return [
        line
        for line in difflib.unified_diff(old_text.split("\n"), new_text.split("\n"), lineterm="", n=0)
        if not line.startswith(("---", "+++", "@@"))
    ]


def git_show_text(root, commit: str, path: str) -> str:
    return subprocess.check_output(["git", "show", f"{commit}:{path}"], cwd=root).decode("utf-8").replace("\r\n", "\n")


def assert_main_is_approved_p1_state(root, current_main: str, warning_cleanup_main: str, main_path: str) -> None:
    p1_main = git_show_text(root, P1_MAIN_CHECKPOINT, main_path)
    assert line_delta(warning_cleanup_main, p1_main) == EXPECTED_P1_MAIN_DELTA, (
        "P-1 worldmap_main.gd delta no longer matches the approved exact delta"
    )
    approved_main = git_show_text(root, P0_STOCK_CHECKPOINT, main_path) if P0_STOCK_CHECKPOINT else p1_main
    assert current_main == approved_main, (
        "worldmap_main.gd changed after the approved P-1/P0-stock checkpoint; review a new exact delta "
        "instead of relaxing the guard"
    )
    if P0_STOCK_CHECKPOINT:
        assert line_delta(p1_main, approved_main) == EXPECTED_P0_STOCK_MAIN_DELTA, (
            "P0-stock worldmap_main.gd delta no longer matches the approved exact delta"
        )


def frozen_text_matches(root, path: str, expected_text: str, current_text: str) -> bool:
    """A frozen file equals what its guard expects, or (queue 36) the P0-stock commit with exactly the approved delta."""
    current_text = current_text.replace("\r\n", "\n")
    if not P0_STOCK_CHECKPOINT or path not in EXPECTED_P0_STOCK_FROZEN_DELTAS:
        return current_text == expected_text
    p0_text = git_show_text(root, P0_STOCK_CHECKPOINT, path)
    return current_text == p0_text and line_delta(expected_text, p0_text) == EXPECTED_P0_STOCK_FROZEN_DELTAS[path]


def assert_settlement_is_approved_p1d_state(root, current_bytes: bytes, af1_expected_bytes: bytes, path: str) -> None:
    p1d_text = git_show_text(root, P1D_SETTLEMENT_CHECKPOINT, path)
    assert current_bytes.decode("utf-8").replace("\r\n", "\n") == p1d_text, (
        "battle settlement changed beyond the approved AF-1 rename + P-1D retreat/defender-wounded delta"
    )
    af1_text = af1_expected_bytes.decode("utf-8").replace("\r\n", "\n")
    assert line_delta(af1_text, p1d_text) == EXPECTED_P1D_SETTLEMENT_DELTA, (
        "P-1D settlement delta no longer matches the approved exact delta"
    )
