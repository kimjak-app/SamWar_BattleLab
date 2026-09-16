#!/usr/bin/env python3
"""Fail fast if the production WorldMap god script is accidentally truncated.

This guard exists because worldmap_main.gd was catastrophically shortened twice
(2026-09-06 and 2026-09-12) by updates that were intended to touch only a small
part of the file.  It deliberately checks broad structural invariants rather
than feature-specific behavior.
"""

from __future__ import annotations

import re
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MAIN = ROOT / "scripts/worldmap/worldmap_main.gd"
MIN_LINE_COUNT = 18_000
MIN_FUNCTION_COUNT = 900
T3_EFFECT_PROVIDER_CHECKPOINT = "850b37095146688ed80c52c330cfbf069216024e"
T4_PRESENTATION_CHECKPOINT = "d3decdc9b89a3a3a3989b568a625c58bab245e0f"
C1_CITY_ADMIN_CHECKPOINT = "dfa9f179dc026800e694e9442131edaf10cf0ef9"
C2_CITY_RESOURCE_CHECKPOINT = "6a3e73e5133ab6a24209d41f99e309a53166cf97"
C3_CITY_DETAIL_CHECKPOINT = "6cfea9a1651999a9b97b96eb3a56ece213f2b04f"

REQUIRED_TOKENS = {
    "camera": "func _configure_camera",
    "city storage": "func _get_city_storage",
    "save serialization": "func _serialize_worldmap_state",
    "save load": "func _load_worldmap_state",
    "battle handoff": "_worldmap_battle_entry_handoff_in_progress",
    "turn runtime": "func _ensure_worldmap_runtime_state_defaults",
    "city marker selection": "func _on_city_marker_selected",
    "diplomacy validation": "func _validate_diplomacy_action",
    "spy validation": "func _validate_spy_action",
    "trade controller bridge": "func _ensure_trade_controller",
}


def main() -> None:
    source = MAIN.read_text(encoding="utf-8")
    line_count = len(source.splitlines())
    function_count = len(re.findall(r"^(?:static\s+)?func\s+", source, flags=re.MULTILINE))

    failures: list[str] = []
    if line_count < MIN_LINE_COUNT:
        approved_checkpoints = {
            "T-3 effect-provider": T3_EFFECT_PROVIDER_CHECKPOINT,
            "T-4 presentation": T4_PRESENTATION_CHECKPOINT,
            "C-1 city-administration": C1_CITY_ADMIN_CHECKPOINT,
            "C-2 city-resource": C2_CITY_RESOURCE_CHECKPOINT,
            "C-3 city-detail": C3_CITY_DETAIL_CHECKPOINT,
        }
        approved_sources = {
            label: subprocess.check_output(
                ["git", "show", f"{checkpoint}:scripts/worldmap/worldmap_main.gd"],
                cwd=ROOT,
            ).decode("utf-8").replace("\r\n", "\n")
            for label, checkpoint in approved_checkpoints.items()
        }
        if source not in approved_sources.values():
            failures.append(
                f"worldmap_main.gd has only {line_count} lines; expected at least {MIN_LINE_COUNT}, "
                "and does not exactly match an approved T-3/T-4/C-1/C-2/C-3 refactor checkpoint."
            )
    if function_count < MIN_FUNCTION_COUNT:
        failures.append(
            f"worldmap_main.gd has only {function_count} functions; expected at least "
            f"{MIN_FUNCTION_COUNT}. Possible whole-file truncation."
        )

    for label, token in REQUIRED_TOKENS.items():
        if token not in source:
            failures.append(f"missing structural sentinel [{label}]: {token}")

    if failures:
        raise SystemExit("FAIL: WorldMap main integrity guard\n- " + "\n- ".join(failures))

    print(
        "PASS: WorldMap main integrity guard "
        f"({line_count} lines, {function_count} functions, all sentinels present)."
    )


if __name__ == "__main__":
    main()
