#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAIN_PATH = ROOT / "scripts/worldmap/worldmap_main.gd"

DEAD_PRIVATE_FUNCTIONS = [
    "_register_hud_panel_drag",
    "_on_hud_drag_handle_gui_input",
    "_format_internal_route_summary",
    "_format_external_trade_target",
    "_format_external_trade_recent_summary",
    "_format_city_supply_adjustment_display",
    "_format_city_loyalty_drift_display",
    "_format_city_public_support_display",
    "_format_city_seasonal_loyalty_display",
    "_format_city_revolt_risk_display",
    "_format_trade_result_summary",
    "_set_turn_phase",
    "_get_enemy_turn_mvp_timer",
    "_get_or_restore_turn_resolution_state_mvp",
    "_get_enemy_goal_label_display_part",
    "_format_enemy_strategic_action_summary",
    "_payment_resource_ids_mvp",
    "_get_empty_domestic_tech_city_economy_bonus_mvp",
    "_get_empty_domestic_defense_modifier_mvp",
    "_get_empty_domestic_tech_national_policy_bonus_mvp",
    "_get_empty_domestic_tech_city_naval_siege_bonus_mvp",
    "_get_empty_domestic_tech_diplomacy_spy_bonus_mvp",
    "_get_empty_domestic_tech_city_spy_intel_bonus_mvp",
    "_has_domestic_tech_city_economy_bonus_mvp",
    "_has_domestic_tech_national_policy_bonus_mvp",
    "_has_domestic_tech_diplomacy_spy_bonus_mvp",
    "_has_domestic_tech_city_spy_intel_bonus_mvp",
    "_are_required_national_techs_completed_mvp",
    "_get_available_city_domestic_tech_ids_mvp",
    "_get_available_national_domestic_tech_ids_mvp",
    "_get_domestic_tech_cost_summary_mvp",
    "_get_completed_national_tech_effect_ids",
    "_get_completed_city_tech_effect_ids",
    "_calculate_city_gold_tax_income",
    "_apply_chancellor_type_effect",
    "_round_discounted_amount",
    "_format_city_list",
    "_format_hero_list",
    "_ensure_city_storage_keys",
    "_get_city_storage_group_total",
    "_format_city_storage_group_details",
    "_refresh_warehouse_card",
    "_format_policy_preview_summary",
    "_format_hero_upkeep_preview",
    "_format_soldier_upkeep_preview",
    "_format_salt_preservation_preview",
    "_format_tax_preview",
    "_get_city_detail_status",
    "_on_wild_army_edit_placeholder_pressed",
    "_on_save_placeholder_pressed",
    "_on_load_placeholder_pressed",
    "_on_reset_placeholder_pressed",
]

DEAD_CONSTANTS = [
    "DOMESTIC_TECH_RESEARCH_ACTIVE_KEY",
    "ENEMY_STRATEGIC_SPY_PRESSURE_WEIGHT",
    "INVASION_RESULT_DEFAULT_OCCUPATION_TROOPS",
    "COMMAND_RANK_GENERAL",
    "TRADE_EFFICIENCY_MIN",
    "TRADE_EFFICIENCY_MAX",
    "SPY_COOLDOWN_TURNS",
    "SPY_PUBLIC_SUPPORT_DISRUPT_COST",
    "SPY_PUBLIC_SUPPORT_DISRUPT_COOLDOWN_TURNS",
    "SPY_DETECTED_RELATION_PENALTY_GATHER_INFO",
    "SPY_DETECTED_RELATION_PENALTY_PUBLIC_SUPPORT",
    "SPY_LOYALTY_DISRUPT_COST",
    "SPY_LOYALTY_DISRUPT_COOLDOWN_TURNS",
    "SPY_DETECTED_RELATION_PENALTY_LOYALTY",
    "SPY_REVOLT_INSTIGATION_COST",
    "SPY_REVOLT_INSTIGATION_COOLDOWN_TURNS",
    "SPY_REVOLT_INSTIGATION_DURATION_TURNS",
    "SPY_DETECTED_RELATION_PENALTY_REVOLT",
    "SPY_WEDGE_COST",
    "SPY_WEDGE_COOLDOWN_TURNS",
    "SPY_DETECTED_RELATION_PENALTY_WEDGE",
    "TRADE_SUSPENSION_TURNS",
    "RELATION_TRADE_MULTIPLIER",
]

PRESERVED_SYMBOLS = [
    "SPY_ACTION_GATHER_INFO",
    "SPY_ACTION_PUBLIC_SUPPORT_DISRUPT",
    "SPY_ACTION_LOYALTY_DISRUPT",
    "SPY_ACTION_REVOLT_INSTIGATE",
    "SPY_ACTION_WEDGE",
    "TRADE_ROUTE_CAP",
    "TRADE_GLOBAL_DAMPENER",
    "TRADE_FOOD_FACTOR",
    "_get_trade_relation_multiplier_for_ui",
    "_ensure_trade_controller",
    "_ensure_spy_controller",
    "_ensure_diplomacy_controller",
    "_ensure_turn_controller",
]


def _function_ranges(text: str) -> dict[str, tuple[int, int]]:
    matches = list(re.finditer(r"^func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(", text, re.M))
    ranges: dict[str, tuple[int, int]] = {}
    for i, match in enumerate(matches):
        name = match.group(1)
        start = match.start()
        end = matches[i + 1].start() if i + 1 < len(matches) else len(text)
        ranges[name] = (start, end)
    return ranges


def audit(text: str) -> None:
    ranges = _function_ranges(text)
    for name in DEAD_PRIVATE_FUNCTIONS:
        if name not in ranges:
            raise SystemExit(f"missing audited dead function: {name}")
        occurrences = text.count(name)
        if occurrences != 1:
            raise SystemExit(f"dead function is referenced in main: {name} occurrences={occurrences}")
    for name in DEAD_CONSTANTS:
        if not re.search(rf"^const\s+{re.escape(name)}\b", text, re.M):
            raise SystemExit(f"missing audited dead constant: {name}")
        occurrences = text.count(name)
        if occurrences != 1:
            raise SystemExit(f"dead constant is referenced in main: {name} occurrences={occurrences}")
    for name in PRESERVED_SYMBOLS:
        if name not in text:
            raise SystemExit(f"required hub symbol missing before cleanup: {name}")


def apply_cleanup(text: str) -> str:
    result = text
    ranges = _function_ranges(result)
    spans = sorted((ranges[name] for name in DEAD_PRIVATE_FUNCTIONS), reverse=True)
    for start, end in spans:
        result = result[:start] + result[end:]

    lines = result.splitlines(keepends=True)
    dead_set = set(DEAD_CONSTANTS)
    kept: list[str] = []
    removed: set[str] = set()
    for line in lines:
        match = re.match(r"^const\s+([A-Z][A-Z0-9_]*)\b", line)
        if match and match.group(1) in dead_set:
            removed.add(match.group(1))
            continue
        kept.append(line)
    if removed != dead_set:
        missing = sorted(dead_set - removed)
        raise SystemExit(f"failed to remove all audited constants: {missing}")
    result = "".join(kept)
    result = re.sub(r"\n{4,}", "\n\n\n", result)
    return result


def verify_after(text: str) -> None:
    for name in DEAD_PRIVATE_FUNCTIONS + DEAD_CONSTANTS:
        if name in text:
            raise SystemExit(f"dead symbol survived cleanup: {name}")
    for name in PRESERVED_SYMBOLS:
        if name not in text:
            raise SystemExit(f"required hub symbol removed: {name}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    original = MAIN_PATH.read_text(encoding="utf-8")
    audit(original)
    print(f"PASS preflight: {len(DEAD_PRIVATE_FUNCTIONS)} dead functions + {len(DEAD_CONSTANTS)} dead constants are exact/unreferenced in main")
    if not args.apply:
        return
    updated = apply_cleanup(original)
    verify_after(updated)
    MAIN_PATH.write_text(updated, encoding="utf-8")
    print(f"APPLIED M-FINAL-B cleanup: lines {len(original.splitlines())} -> {len(updated.splitlines())}")


if __name__ == "__main__":
    main()
