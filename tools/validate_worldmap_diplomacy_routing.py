#!/usr/bin/env python3
"""Diplomacy 2D guard with exact C-1~C-3, M-5, and M-FINAL-A bridges.

The C-track refactor intentionally rewired city-administration/resource/detail
functions in worldmap_main.gd after the verified T-4 diplomacy guard.  M-5 then
moved turn orchestration, and M-FINAL-A intentionally changed domain-constant
ownership plus the duplicated trade relation-multiplier implementation.

Do not weaken the historical diplomacy guard with broad function/file skips.
Instead:

1. require the current worldmap_main.gd to be byte-for-byte identical to the
   immutable approved M-FINAL-A domain-ownership checkpoint;
2. require the M-FINAL-A main to contain the reviewed canonical aliases and
   TradeController delegation introduced by that checkpoint;
3. require the complete T-4 -> C-3 changed-file set to match the audited city
   refactor scope exactly;
4. require diplomacy/spy/trade and other protected main functions to have the
   same bodies at T-4 and C-3; and
5. execute the immutable T-4 diplomacy validator unchanged, projecting only
   worldmap_main.gd back to its approved T-4 snapshot while every other current
   production file is still validated normally.

Any future main change therefore still fails until another explicit immutable
checkpoint is reviewed.  This is an exact-delta bridge, not a moving baseline
or a broad whitelist.
"""

from __future__ import annotations

import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
VALIDATOR_PATH = "tools/validate_worldmap_diplomacy_routing.py"
MAIN = "scripts/worldmap/worldmap_main.gd"

T4_VALIDATOR_CHECKPOINT = "af0af137177cec3cc3d8e8ac8e0267a60e70bf9e"
T4_MAIN_CHECKPOINT = "d3decdc9b89a3a3a3989b568a625c58bab245e0f"
C1_CITY_ADMIN_CHECKPOINT = "dfa9f179dc026800e694e9442131edaf10cf0ef9"
C2_CITY_RESOURCE_CHECKPOINT = "6a3e73e5133ab6a24209d41f99e309a53166cf97"
C3_CITY_DETAIL_CHECKPOINT = "6cfea9a1651999a9b97b96eb3a56ece213f2b04f"
M5_TURN_CONTROLLER_CHECKPOINT = "a9b00b5"
M_FINAL_A_DOMAIN_OWNERSHIP_CHECKPOINT = "751b6a07d3e66449f8b2cd27f9685d3e9ed1b98e"

EXPECTED_C_TRACK_CHANGED_FILES = {
    "docs/worldmap_city_administration_c1_audit.md",
    "docs/worldmap_city_resources_c2_audit.md",
    "scripts/worldmap/economy_city/city_administration_service.gd",
    "scripts/worldmap/economy_city/city_detail_presentation_controller.gd",
    "scripts/worldmap/economy_city/city_resource_service.gd",
    "scripts/worldmap/worldmap_main.gd",
    "tests/scripts/test_worldmap_city_administration_service_extraction.gd",
    "tests/scripts/test_worldmap_city_detail_presentation_extraction.gd",
    "tests/scripts/test_worldmap_city_resource_service_extraction.gd",
}

PROTECTED_CURRENT_MAIN_FUNCTIONS = {
    "_apply_generic_resource_cost",
    "_adjust_faction_relation_score",
    "_request_military_support",
    "_calculate_military_support_acceptance_chance",
    "_ensure_faction_relation_entry",
}
PROTECTED_NAME_TOKENS = (
    "diplomacy",
    "spy",
    "trade",
    "alliance",
    "faction_relation",
    "tribute",
)

M_FINAL_A_REQUIRED_MAIN_SNIPPETS = (
    "const TURN_PHASE_PLAYER := WorldMapTurnControllerScript.PHASE_PLAYER",
    "const TURN_PHASE_ENEMY := WorldMapTurnControllerScript.PHASE_ENEMY",
    "const FACTION_RELATION_STATUS := DiplomacyControllerScript.FACTION_RELATION_STATUS",
    "const DIPLOMACY_ACTION_ENVOY := DiplomacyControllerScript.DIPLOMACY_ACTION_ENVOY",
    "const SPY_ACTION_GATHER_INFO := SpyControllerScript.SPY_ACTION_GATHER_INFO",
    "const TRADE_CONTROL_MODE_CHANCELLOR := TradeControllerScript.TRADE_CONTROL_MODE_CHANCELLOR",
    "const RELATION_TRADE_MULTIPLIER := TradeControllerScript.RELATION_TRADE_MULTIPLIER",
    "const INVASION_RESULT_DEFENDER_WIN := BattleResultServiceScript.RESULT_DEFENDER_WIN",
    "return _ensure_trade_controller().get_relation_multiplier_for_factions(",
    "var relation_multiplier := _ensure_trade_controller().get_relation_multiplier_for_factions(",
)


def _git_show(commit: str, path: str) -> str:
    return subprocess.check_output(
        ["git", "show", f"{commit}:{path}"], cwd=ROOT
    ).decode("utf-8").replace("\r\n", "\n")


def _git_changed_files(base: str, head: str) -> set[str]:
    output = subprocess.check_output(
        ["git", "diff", "--name-only", f"{base}..{head}"], cwd=ROOT
    ).decode("utf-8")
    return {line.strip() for line in output.splitlines() if line.strip()}


def _current(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8").replace("\r\n", "\n")


def main() -> None:
    # Historical checkpoints must resolve; this protects the intended C-track
    # and M-5 ancestry from typoed or moving identifiers.
    _git_show(C1_CITY_ADMIN_CHECKPOINT, MAIN)
    _git_show(C2_CITY_RESOURCE_CHECKPOINT, MAIN)
    c3_main = _git_show(C3_CITY_DETAIL_CHECKPOINT, MAIN)
    _git_show(M5_TURN_CONTROLLER_CHECKPOINT, MAIN)
    m_final_a_main = _git_show(M_FINAL_A_DOMAIN_OWNERSHIP_CHECKPOINT, MAIN)
    current_main = _current(MAIN)

    assert current_main == m_final_a_main, (
        "worldmap_main.gd changed after the approved M-FINAL-A domain-ownership "
        "checkpoint; review a new exact delta instead of relaxing diplomacy routing"
    )
    for snippet in M_FINAL_A_REQUIRED_MAIN_SNIPPETS:
        assert snippet in current_main, (
            "approved M-FINAL-A main no longer contains required canonical "
            f"ownership/delegation: {snippet}"
        )

    changed_files = _git_changed_files(T4_VALIDATOR_CHECKPOINT, C3_CITY_DETAIL_CHECKPOINT)
    assert changed_files == EXPECTED_C_TRACK_CHANGED_FILES, (
        "T-4 -> C-3 audited file scope changed: "
        f"expected={sorted(EXPECTED_C_TRACK_CHANGED_FILES)} actual={sorted(changed_files)}"
    )

    # Load the complete, previously-green T-4 guard from its immutable commit.
    # Execute it as a module so its __main__ block does not auto-run.
    t4_validator_source = _git_show(T4_VALIDATOR_CHECKPOINT, VALIDATOR_PATH)
    namespace = {
        "__name__": "_immutable_t4_diplomacy_routing_guard",
        "__file__": str(ROOT / VALIDATOR_PATH),
    }
    exec(compile(t4_validator_source, VALIDATOR_PATH, "exec"), namespace)

    functions = namespace["functions"]
    t4_main = _git_show(T4_MAIN_CHECKPOINT, MAIN)
    t4_functions = functions(t4_main)
    c3_functions = functions(c3_main)

    # C-track work must not have altered the previously protected diplomacy,
    # spy, trade, alliance, tribute, or shared diplomacy-mutation functions.
    protected_names = set(PROTECTED_CURRENT_MAIN_FUNCTIONS)
    for name in t4_functions:
        if any(token in name for token in PROTECTED_NAME_TOKENS):
            protected_names.add(name)
    for name in sorted(protected_names):
        assert name in c3_functions, f"C-track removed protected main function: {name}"
        assert c3_functions[name] == t4_functions[name], (
            f"C-track changed protected diplomacy/spy/trade main function: {name}"
        )

    # Keep every historical T-4 assertion.  Only MAIN is projected to the
    # exact T-4 snapshot while current controller/service/UI files remain live.
    original_current = namespace["current"]

    def bridged_current(path: str) -> str:
        if path == MAIN:
            return t4_main
        return original_current(path)

    namespace["current"] = bridged_current
    namespace["main"]()

    print(
        "PASS: diplomacy routing guard + exact C-1/C-2/C-3/M-5/M-FINAL-A main "
        "checkpoint bridge; historical T-4 guard preserved"
    )


if __name__ == "__main__":
    main()
