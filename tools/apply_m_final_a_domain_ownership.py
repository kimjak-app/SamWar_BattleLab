#!/usr/bin/env python3
"""Apply the audited M-FINAL-A domain-ownership cleanup.

Default mode is read-only validation. Pass --apply to write the changes.
The replacements are deliberately exact and fail if the audited source shape
has drifted, so this script must never silently patch a newer architecture.
"""

from __future__ import annotations

import argparse
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class PatchDrift(RuntimeError):
    pass


class ExactPatch:
    def __init__(self, relative_path: str, old: str, new: str, label: str) -> None:
        self.path = ROOT / relative_path
        self.old = old
        self.new = new
        self.label = label

    def inspect(self, text: str) -> str:
        old_count = text.count(self.old)
        new_count = text.count(self.new)
        if old_count == 1 and new_count == 0:
            return "pending"
        if old_count == 0 and new_count == 1:
            return "applied"
        raise PatchDrift(
            f"{self.label}: expected exactly one audited old block or one applied block "
            f"in {self.path.relative_to(ROOT)} (old={old_count}, new={new_count})"
        )

    def apply(self, text: str) -> str:
        state = self.inspect(text)
        if state == "applied":
            return text
        return text.replace(self.old, self.new, 1)


def patches() -> list[ExactPatch]:
    return [
        ExactPatch(
            "scripts/worldmap/actions/diplomacy_controller.gd",
            '''const FACTION_RELATION_STATUS := {\n\t"ALLIED": "allied",\n\t"NEUTRAL": "neutral",\n\t"HOSTILE": "hostile",\n\t"SUSPENDED": "suspended",\n}\nconst DIPLOMACY_SCORE_MIN := 0\nconst DIPLOMACY_SCORE_MAX := 100\nconst DIPLOMACY_DEFAULT_SCORE := 50\nconst DIPLOMACY_ACTION_ENVOY := "envoy"\nconst DIPLOMACY_ACTION_TRIBUTE := "tribute"\nconst DIPLOMACY_ACTION_TRADE_AGREEMENT := "trade_agreement"\nconst DIPLOMACY_ACTION_RESTORE_RELATIONS := "restore_relations"\nconst DIPLOMACY_ACTION_ALLIANCE_PROPOSAL := "alliance_proposal"''',
            '''const FACTION_RELATION_STATUS := {\n\t"ALLIED": DiplomacyActionServiceScript.RELATION_STATUS_ALLIED,\n\t"NEUTRAL": DiplomacyActionServiceScript.RELATION_STATUS_NEUTRAL,\n\t"HOSTILE": DiplomacyActionServiceScript.RELATION_STATUS_HOSTILE,\n\t"SUSPENDED": DiplomacyActionServiceScript.RELATION_STATUS_SUSPENDED,\n}\nconst DIPLOMACY_SCORE_MIN := DiplomacyActionServiceScript.RELATION_SCORE_MIN\nconst DIPLOMACY_SCORE_MAX := DiplomacyActionServiceScript.RELATION_SCORE_MAX\nconst DIPLOMACY_DEFAULT_SCORE := DiplomacyActionServiceScript.DEFAULT_RELATION_SCORE\nconst DIPLOMACY_ACTION_ENVOY := DiplomacyActionServiceScript.ACTION_ENVOY\nconst DIPLOMACY_ACTION_TRIBUTE := DiplomacyActionServiceScript.ACTION_TRIBUTE\nconst DIPLOMACY_ACTION_TRADE_AGREEMENT := DiplomacyActionServiceScript.ACTION_TRADE_AGREEMENT\nconst DIPLOMACY_ACTION_RESTORE_RELATIONS := DiplomacyActionServiceScript.ACTION_RESTORE_RELATIONS\nconst DIPLOMACY_ACTION_ALLIANCE_PROPOSAL := DiplomacyActionServiceScript.ACTION_ALLIANCE_PROPOSAL''',
            "DiplomacyController service-owned constants",
        ),
        ExactPatch(
            "scripts/worldmap/actions/spy_controller.gd",
            '''const SpyActionServiceScript := preload("res://scripts/worldmap/actions/spy_action_service.gd")''',
            '''const SpyActionServiceScript := preload("res://scripts/worldmap/actions/spy_action_service.gd")\nconst SPY_ACTION_GATHER_INFO := SpyActionServiceScript.SPY_ACTION_GATHER_INFO\nconst SPY_ACTION_PUBLIC_SUPPORT_DISRUPT := SpyActionServiceScript.SPY_ACTION_PUBLIC_SUPPORT_DISRUPT\nconst SPY_ACTION_LOYALTY_DISRUPT := SpyActionServiceScript.SPY_ACTION_LOYALTY_DISRUPT\nconst SPY_ACTION_REVOLT_INSTIGATE := SpyActionServiceScript.SPY_ACTION_REVOLT_INSTIGATE\nconst SPY_ACTION_WEDGE := SpyActionServiceScript.SPY_ACTION_WEDGE\nconst SPY_COOLDOWN_TURNS := SpyActionServiceScript.SPY_COOLDOWN_TURNS\nconst SPY_PUBLIC_SUPPORT_DISRUPT_COST := SpyActionServiceScript.SPY_PUBLIC_SUPPORT_DISRUPT_COST\nconst SPY_PUBLIC_SUPPORT_DISRUPT_COOLDOWN_TURNS := SpyActionServiceScript.SPY_PUBLIC_SUPPORT_DISRUPT_COOLDOWN_TURNS\nconst SPY_DETECTED_RELATION_PENALTY_GATHER_INFO := SpyActionServiceScript.SPY_DETECTED_RELATION_PENALTY_GATHER_INFO\nconst SPY_DETECTED_RELATION_PENALTY_PUBLIC_SUPPORT := SpyActionServiceScript.SPY_DETECTED_RELATION_PENALTY_PUBLIC_SUPPORT\nconst SPY_LOYALTY_DISRUPT_COST := SpyActionServiceScript.SPY_LOYALTY_DISRUPT_COST\nconst SPY_LOYALTY_DISRUPT_COOLDOWN_TURNS := SpyActionServiceScript.SPY_LOYALTY_DISRUPT_COOLDOWN_TURNS\nconst SPY_DETECTED_RELATION_PENALTY_LOYALTY := SpyActionServiceScript.SPY_DETECTED_RELATION_PENALTY_LOYALTY\nconst SPY_REVOLT_INSTIGATION_COST := SpyActionServiceScript.SPY_REVOLT_INSTIGATION_COST\nconst SPY_REVOLT_INSTIGATION_COOLDOWN_TURNS := SpyActionServiceScript.SPY_REVOLT_INSTIGATION_COOLDOWN_TURNS\nconst SPY_REVOLT_INSTIGATION_DURATION_TURNS := SpyActionServiceScript.SPY_REVOLT_INSTIGATION_DURATION_TURNS\nconst SPY_DETECTED_RELATION_PENALTY_REVOLT := SpyActionServiceScript.SPY_DETECTED_RELATION_PENALTY_REVOLT\nconst SPY_WEDGE_COST := SpyActionServiceScript.SPY_WEDGE_COST\nconst SPY_WEDGE_COOLDOWN_TURNS := SpyActionServiceScript.SPY_WEDGE_COOLDOWN_TURNS\nconst SPY_DETECTED_RELATION_PENALTY_WEDGE := SpyActionServiceScript.SPY_DETECTED_RELATION_PENALTY_WEDGE''',
            "SpyController public service aliases",
        ),
        ExactPatch(
            "scripts/worldmap/actions/trade_controller.gd",
            '''const TRADE_CONTROL_MODE_CHANCELLOR := "chancellor"\nconst TRADE_CONTROL_MODE_MANUAL := "manual"''',
            '''const TRADE_CONTROL_MODE_CHANCELLOR := "chancellor"\nconst TRADE_CONTROL_MODE_MANUAL := "manual"\nconst RELATION_TRADE_MULTIPLIER := {\n\t"allied": 1.25,\n\t"neutral": 1.0,\n\t"hostile": 0.0,\n\t"suspended": 0.0,\n}\nconst TRADE_ROUTE_CAP := {\n\t"gold": 90,\n\t"rice": 20,\n\t"barley": 20,\n\t"seafood": 22,\n\t"salt": 16,\n}\n# v0.68b-13-2B Trade balance tuning (web parity restore)\nconst TRADE_GLOBAL_DAMPENER := 0.5\nconst TRADE_FOOD_FACTOR := 1.5''',
            "TradeController canonical trade constants",
        ),
        ExactPatch(
            "scripts/worldmap/actions/trade_controller.gd",
            '''func _get_trade_relation_multiplier(source_faction_id: String, target_faction_id: String) -> float:\n\treturn float(_host.call("_get_trade_relation_multiplier_for_ui", source_faction_id, target_faction_id))''',
            '''func get_relation_multiplier_for_factions(source_faction_id: String, target_faction_id: String) -> float:\n\tvar relation_status := str(_host.call("_get_faction_relation_status", source_faction_id, target_faction_id))\n\tvar raw_multiplier: Variant = RELATION_TRADE_MULTIPLIER.get(relation_status, 1.0)\n\treturn float(raw_multiplier) + float(\n\t\t_host.call("_get_trade_agreement_bonus_multiplier", source_faction_id, target_faction_id)\n\t)\n\n\nfunc _get_trade_relation_multiplier(source_faction_id: String, target_faction_id: String) -> float:\n\treturn get_relation_multiplier_for_factions(source_faction_id, target_faction_id)''',
            "TradeController canonical relation multiplier",
        ),
        ExactPatch(
            "scripts/worldmap/worldmap_main.gd",
            '''const TRADE_CONTROL_MODE_CHANCELLOR := "chancellor"\nconst TRADE_CONTROL_MODE_MANUAL := "manual"''',
            '''const TRADE_CONTROL_MODE_CHANCELLOR := TradeControllerScript.TRADE_CONTROL_MODE_CHANCELLOR\nconst TRADE_CONTROL_MODE_MANUAL := TradeControllerScript.TRADE_CONTROL_MODE_MANUAL''',
            "main trade mode aliases",
        ),
        ExactPatch(
            "scripts/worldmap/worldmap_main.gd",
            '''const TURN_PHASE_PLAYER := "player"\nconst TURN_PHASE_ENEMY := "enemy"''',
            '''const TURN_PHASE_PLAYER := WorldMapTurnControllerScript.PHASE_PLAYER\nconst TURN_PHASE_ENEMY := WorldMapTurnControllerScript.PHASE_ENEMY''',
            "main turn phase aliases",
        ),
        ExactPatch(
            "scripts/worldmap/worldmap_main.gd",
            '''const FACTION_RELATION_STATUS := {\n\t"ALLIED": "allied",\n\t"NEUTRAL": "neutral",\n\t"HOSTILE": "hostile",\n\t"SUSPENDED": "suspended",\n}\nconst DIPLOMACY_SCORE_MIN := 0\nconst DIPLOMACY_SCORE_MAX := 100\nconst DIPLOMACY_DEFAULT_SCORE := 50''',
            '''const FACTION_RELATION_STATUS := DiplomacyControllerScript.FACTION_RELATION_STATUS\nconst DIPLOMACY_SCORE_MIN := DiplomacyControllerScript.DIPLOMACY_SCORE_MIN\nconst DIPLOMACY_SCORE_MAX := DiplomacyControllerScript.DIPLOMACY_SCORE_MAX\nconst DIPLOMACY_DEFAULT_SCORE := DiplomacyControllerScript.DIPLOMACY_DEFAULT_SCORE''',
            "main diplomacy relation aliases",
        ),
        ExactPatch(
            "scripts/worldmap/worldmap_main.gd",
            '''const DIPLOMACY_ACTION_ENVOY := "envoy"\nconst DIPLOMACY_ACTION_TRIBUTE := "tribute"\nconst DIPLOMACY_ACTION_TRADE_AGREEMENT := "trade_agreement"\nconst DIPLOMACY_ACTION_RESTORE_RELATIONS := "restore_relations"\nconst DIPLOMACY_ACTION_ALLIANCE_PROPOSAL := "alliance_proposal"''',
            '''const DIPLOMACY_ACTION_ENVOY := DiplomacyControllerScript.DIPLOMACY_ACTION_ENVOY\nconst DIPLOMACY_ACTION_TRIBUTE := DiplomacyControllerScript.DIPLOMACY_ACTION_TRIBUTE\nconst DIPLOMACY_ACTION_TRADE_AGREEMENT := DiplomacyControllerScript.DIPLOMACY_ACTION_TRADE_AGREEMENT\nconst DIPLOMACY_ACTION_RESTORE_RELATIONS := DiplomacyControllerScript.DIPLOMACY_ACTION_RESTORE_RELATIONS\nconst DIPLOMACY_ACTION_ALLIANCE_PROPOSAL := DiplomacyControllerScript.DIPLOMACY_ACTION_ALLIANCE_PROPOSAL''',
            "main diplomacy action aliases",
        ),
        ExactPatch(
            "scripts/worldmap/worldmap_main.gd",
            '''const SPY_ACTION_GATHER_INFO := "gather_info"\nconst SPY_ACTION_PUBLIC_SUPPORT_DISRUPT := "public_support_disrupt"\nconst SPY_ACTION_LOYALTY_DISRUPT := "loyalty_disrupt"\nconst SPY_ACTION_REVOLT_INSTIGATE := "revolt_instigate"\nconst SPY_ACTION_WEDGE := "wedge"\nconst SPY_COOLDOWN_TURNS := 1\nconst SPY_PUBLIC_SUPPORT_DISRUPT_COST := {"gold": 300}\nconst SPY_PUBLIC_SUPPORT_DISRUPT_COOLDOWN_TURNS := 2\nconst SPY_DETECTED_RELATION_PENALTY_GATHER_INFO := -6\nconst SPY_DETECTED_RELATION_PENALTY_PUBLIC_SUPPORT := -10\nconst SPY_LOYALTY_DISRUPT_COST := {\n\t"gold": 500,\n\t"silk": 50,\n}\nconst SPY_LOYALTY_DISRUPT_COOLDOWN_TURNS := 2\nconst SPY_DETECTED_RELATION_PENALTY_LOYALTY := -10\nconst SPY_REVOLT_INSTIGATION_COST := {\n\t"gold": 800,\n\t"silk": 100,\n}\nconst SPY_REVOLT_INSTIGATION_COOLDOWN_TURNS := 2\nconst SPY_REVOLT_INSTIGATION_DURATION_TURNS := 3\nconst SPY_DETECTED_RELATION_PENALTY_REVOLT := -10\nconst SPY_WEDGE_COST := {\n\t"gold": 600,\n\t"silk": 150,\n}\nconst SPY_WEDGE_COOLDOWN_TURNS := 12\nconst SPY_DETECTED_RELATION_PENALTY_WEDGE := -20''',
            '''const SPY_ACTION_GATHER_INFO := SpyControllerScript.SPY_ACTION_GATHER_INFO\nconst SPY_ACTION_PUBLIC_SUPPORT_DISRUPT := SpyControllerScript.SPY_ACTION_PUBLIC_SUPPORT_DISRUPT\nconst SPY_ACTION_LOYALTY_DISRUPT := SpyControllerScript.SPY_ACTION_LOYALTY_DISRUPT\nconst SPY_ACTION_REVOLT_INSTIGATE := SpyControllerScript.SPY_ACTION_REVOLT_INSTIGATE\nconst SPY_ACTION_WEDGE := SpyControllerScript.SPY_ACTION_WEDGE\nconst SPY_COOLDOWN_TURNS := SpyControllerScript.SPY_COOLDOWN_TURNS\nconst SPY_PUBLIC_SUPPORT_DISRUPT_COST := SpyControllerScript.SPY_PUBLIC_SUPPORT_DISRUPT_COST\nconst SPY_PUBLIC_SUPPORT_DISRUPT_COOLDOWN_TURNS := SpyControllerScript.SPY_PUBLIC_SUPPORT_DISRUPT_COOLDOWN_TURNS\nconst SPY_DETECTED_RELATION_PENALTY_GATHER_INFO := SpyControllerScript.SPY_DETECTED_RELATION_PENALTY_GATHER_INFO\nconst SPY_DETECTED_RELATION_PENALTY_PUBLIC_SUPPORT := SpyControllerScript.SPY_DETECTED_RELATION_PENALTY_PUBLIC_SUPPORT\nconst SPY_LOYALTY_DISRUPT_COST := SpyControllerScript.SPY_LOYALTY_DISRUPT_COST\nconst SPY_LOYALTY_DISRUPT_COOLDOWN_TURNS := SpyControllerScript.SPY_LOYALTY_DISRUPT_COOLDOWN_TURNS\nconst SPY_DETECTED_RELATION_PENALTY_LOYALTY := SpyControllerScript.SPY_DETECTED_RELATION_PENALTY_LOYALTY\nconst SPY_REVOLT_INSTIGATION_COST := SpyControllerScript.SPY_REVOLT_INSTIGATION_COST\nconst SPY_REVOLT_INSTIGATION_COOLDOWN_TURNS := SpyControllerScript.SPY_REVOLT_INSTIGATION_COOLDOWN_TURNS\nconst SPY_REVOLT_INSTIGATION_DURATION_TURNS := SpyControllerScript.SPY_REVOLT_INSTIGATION_DURATION_TURNS\nconst SPY_DETECTED_RELATION_PENALTY_REVOLT := SpyControllerScript.SPY_DETECTED_RELATION_PENALTY_REVOLT\nconst SPY_WEDGE_COST := SpyControllerScript.SPY_WEDGE_COST\nconst SPY_WEDGE_COOLDOWN_TURNS := SpyControllerScript.SPY_WEDGE_COOLDOWN_TURNS\nconst SPY_DETECTED_RELATION_PENALTY_WEDGE := SpyControllerScript.SPY_DETECTED_RELATION_PENALTY_WEDGE''',
            "main spy aliases",
        ),
        ExactPatch(
            "scripts/worldmap/worldmap_main.gd",
            '''const RELATION_TRADE_MULTIPLIER := {\n\t"allied": 1.25,\n\t"neutral": 1.0,\n\t"hostile": 0.0,\n\t"suspended": 0.0,\n}\nconst TRADE_ROUTE_CAP := {\n\t"gold": 90,\n\t"rice": 20,\n\t"barley": 20,\n\t"seafood": 22,\n\t"salt": 16,\n}\n# v0.68b-13-2B Trade balance tuning (web parity restore)\nconst TRADE_GLOBAL_DAMPENER := 0.5\nconst TRADE_FOOD_FACTOR := 1.5''',
            '''const RELATION_TRADE_MULTIPLIER := TradeControllerScript.RELATION_TRADE_MULTIPLIER\nconst TRADE_ROUTE_CAP := TradeControllerScript.TRADE_ROUTE_CAP\nconst TRADE_GLOBAL_DAMPENER := TradeControllerScript.TRADE_GLOBAL_DAMPENER\nconst TRADE_FOOD_FACTOR := TradeControllerScript.TRADE_FOOD_FACTOR''',
            "main trade domain aliases",
        ),
        ExactPatch(
            "scripts/worldmap/worldmap_main.gd",
            '''const INVASION_RESULT_DEFENDER_WIN := "defender_win"\nconst INVASION_RESULT_ATTACKER_WIN := "attacker_win"\nconst INVASION_RESULT_RETREAT := "retreat"\nconst INVASION_RESULT_UNKNOWN := "unknown"''',
            '''const INVASION_RESULT_DEFENDER_WIN := BattleResultServiceScript.RESULT_DEFENDER_WIN\nconst INVASION_RESULT_ATTACKER_WIN := BattleResultServiceScript.RESULT_ATTACKER_WIN\nconst INVASION_RESULT_RETREAT := BattleResultServiceScript.RESULT_RETREAT\nconst INVASION_RESULT_UNKNOWN := BattleResultServiceScript.RESULT_UNKNOWN''',
            "main battle result aliases",
        ),
        ExactPatch(
            "scripts/worldmap/worldmap_main.gd",
            '''func _get_trade_relation_multiplier_for_ui(source_faction_id: String, target_faction_id: String) -> float:\n\tif source_faction_id.is_empty() or target_faction_id.is_empty() or source_faction_id == target_faction_id:\n\t\treturn 0.0\n\tvar relation_status := _get_faction_relation_status(source_faction_id, target_faction_id)\n\tvar raw_multiplier: Variant = RELATION_TRADE_MULTIPLIER.get(relation_status, 1.0)\n\treturn float(raw_multiplier) + _get_trade_agreement_bonus_multiplier(source_faction_id, target_faction_id)''',
            '''func _get_trade_relation_multiplier_for_ui(source_faction_id: String, target_faction_id: String) -> float:\n\tif source_faction_id.is_empty() or target_faction_id.is_empty() or source_faction_id == target_faction_id:\n\t\treturn 0.0\n\treturn _ensure_trade_controller().get_relation_multiplier_for_factions(\n\t\tsource_faction_id, target_faction_id\n\t)''',
            "main trade UI multiplier delegation",
        ),
        ExactPatch(
            "scripts/worldmap/worldmap_main.gd",
            '''\tvar trade_agreement_bonus := _get_trade_agreement_bonus_multiplier(faction_a, faction_b)\n\tvar relation_multiplier := float(RELATION_TRADE_MULTIPLIER.get(relation_status, 1.0)) + trade_agreement_bonus''',
            '''\tvar trade_agreement_bonus := _get_trade_agreement_bonus_multiplier(faction_a, faction_b)\n\tvar relation_multiplier := _ensure_trade_controller().get_relation_multiplier_for_factions(\n\t\tfaction_a, faction_b\n\t)''',
            "main trade route multiplier delegation",
        ),
    ]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true", help="write audited changes; default is validation only")
    args = parser.parse_args()

    by_path: dict[Path, list[ExactPatch]] = {}
    for patch in patches():
        by_path.setdefault(patch.path, []).append(patch)

    pending_total = 0
    changed_paths: list[Path] = []
    for path, file_patches in by_path.items():
        if not path.is_file():
            raise PatchDrift(f"missing audited file: {path.relative_to(ROOT)}")
        text = path.read_text(encoding="utf-8")
        states = [(patch, patch.inspect(text)) for patch in file_patches]
        pending_total += sum(1 for _, state in states if state == "pending")
        for patch, state in states:
            print(f"[{state.upper():7}] {path.relative_to(ROOT)} :: {patch.label}")
        if args.apply:
            updated = text
            for patch, _ in states:
                updated = patch.apply(updated)
            if updated != text:
                path.write_text(updated, encoding="utf-8")
                changed_paths.append(path)

    if args.apply:
        print(f"Applied M-FINAL-A changes to {len(changed_paths)} file(s).")
        for path in changed_paths:
            print(f"  - {path.relative_to(ROOT)}")
    else:
        print(f"Validation complete: {pending_total} audited replacement(s) pending. Use --apply to write them.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
