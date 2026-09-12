"""Phase-one guard: preserve recovery functions and route only diplomacy.

Compare with the verified recovery HEAD, not a moving branch name. Runtime
behavior is covered separately by test_worldmap_diplomacy_routing.gd.
"""

import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = "e066b59a28226de1e5f4680ae11b651926903361"
MAIN = "scripts/worldmap/worldmap_main.gd"


def original(path):
    return subprocess.check_output(
        ["git", "show", f"{BASE}:{path}"], cwd=ROOT
    ).decode("utf-8").replace("\r\n", "\n")


def current(path):
    return (ROOT / path).read_text(encoding="utf-8")


def functions(source):
    # Ignore comments/blank lines when comparing function bodies. Keep every
    # executable line, including indentation and signal connections.
    result = {}
    for match in re.finditer(r"(?ms)^func (\w+)(\(.*?)(?=^func |\Z)", source):
        result[match[1]] = "\n".join(
            line for line in match[2].splitlines()
            if line.strip() and not line.lstrip().startswith("#")
        )
    return result


def main():
    before, after = functions(original(MAIN)), functions(current(MAIN))
    bridges = {
        "open_contextual_worldmap_action", "cancel_contextual_worldmap_action",
        "complete_contextual_worldmap_action",
        "_request_contextual_worldmap_action_presentation",
        "_apply_diplomacy_action", "_on_diplomacy_action_pressed",
        # Later domain phases may extend the shared bridge without changing
        # the phase-one diplomacy implementation checked below.
        "_apply_spy_action", "_on_spy_action_pressed",
        "_execute_external_manual_trade_order",
        "_on_manual_trade_execution_button_pressed",
    }
    for name, body in before.items():
        assert name in after, f"removed function: {name}"
        if name not in bridges:
            assert after[name] == body, f"out-of-scope function changed: {name}"
    assert after["_apply_diplomacy_action_legacy"] == before["_apply_diplomacy_action_legacy"], "legacy implementation changed"
    assert len(current(MAIN).splitlines()) >= len(original(MAIN).splitlines()), "host shortened"
    for file in ["spy_action_service.gd", "worldmap_action_coordinator.gd"]:
        path = "scripts/worldmap/actions/" + file
        assert current(path) == original(path), f"shared routing/service changed: {file}"
    presentation = "scripts/worldmap/ui/worldmap_action_presentation_controller.gd"
    assert current(presentation) == original(presentation), "presentation contract changed"
    ui = "scripts/worldmap/ui/worldmap_city_action_test_controller.gd"
    old_ui, new_ui = functions(original(ui)), functions(current(ui))
    for name in old_ui:
        if name != "_on_contextual_action_pressed":
            assert old_ui[name] == new_ui[name], f"unrelated UI changed: {name}"
    assert '\telse:\n\t\taction_video_test_requested.emit(action_type, target_city_id)' in new_ui["_on_contextual_action_pressed"]
    assert '.execute_now("diplomacy", action_id, target_city_id)' in after["_apply_diplomacy_action"]
    assert '.complete(action_type, action_id, target_city_id)' in after["complete_contextual_worldmap_action"]
    assert '.begin("diplomacy", target_city_id)' in after["open_contextual_worldmap_action"]
    service = current("scripts/worldmap/actions/diplomacy_action_service.gd")
    assert 'host.call("_get_current_player_faction_id")' in service
    assert "PLAYER_FACTION_ID" not in service
    print(f"PASS: diplomacy routing static guard; {len(before)} original functions retained, legacy body identical, unrelated functions/services unchanged")


if __name__ == "__main__":
    main()
