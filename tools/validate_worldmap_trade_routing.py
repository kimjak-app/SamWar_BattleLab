"""Phase-three guard for the production trade routing extraction."""

import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = "244706d9849c4ec5dfc413b27ec79ac4690140a6"
MAIN = "scripts/worldmap/worldmap_main.gd"


def original(path):
    return subprocess.check_output(
        ["git", "show", f"{BASE}:{path}"], cwd=ROOT
    ).decode("utf-8").replace("\r\n", "\n")


def current(path):
    return (ROOT / path).read_text(encoding="utf-8")


def functions(source):
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
        "_execute_external_manual_trade_order",
        "_on_manual_trade_execution_button_pressed",
    }
    for name, body in before.items():
        assert name in after, f"removed function: {name}"
        if name not in bridges:
            assert after[name] == body, f"out-of-scope function changed: {name}"
    assert after["_execute_external_manual_trade_order_legacy"] == before["_execute_external_manual_trade_order"], "legacy trade implementation changed"
    assert len(current(MAIN).splitlines()) >= len(original(MAIN).splitlines()), "host shortened"

    for file in ["diplomacy_action_service.gd", "spy_action_service.gd", "worldmap_action_coordinator.gd"]:
        path = "scripts/worldmap/actions/" + file
        assert current(path) == original(path), f"existing domain/coordinator changed: {file}"
    presentation = "scripts/worldmap/ui/worldmap_action_presentation_controller.gd"
    assert current(presentation) == original(presentation), "presentation contract changed"

    ui = "scripts/worldmap/ui/worldmap_city_action_test_controller.gd"
    old_ui, new_ui = functions(original(ui)), functions(current(ui))
    for name in old_ui:
        if name != "_on_contextual_action_pressed":
            assert old_ui[name] == new_ui[name], f"unrelated UI changed: {name}"
    ui_entry = new_ui["_on_contextual_action_pressed"]
    assert all(action in ui_entry for action in ['"diplomacy"', '"spy"', '"trade"'])
    assert '\telse:\n\t\taction_video_test_requested.emit(action_type, target_city_id)' in ui_entry

    assert '.begin("trade", target_city_id, _contextual_worldmap_action_source_city_id)' in after["open_contextual_worldmap_action"]
    assert '_pending_trade_action_id' in after["complete_contextual_worldmap_action"]
    assert '.execute_trade_order(order)' in after["_execute_external_manual_trade_order"]

    coordinator = current("scripts/worldmap/actions/worldmap_action_coordinator.gd")
    assert '"trade":\n\t\t\treturn _trade_service.execute(host, action_id, target_city_id, source_city_id)' in coordinator
    service = current("scripts/worldmap/actions/trade_action_service.gd")
    for helper in ["_validate_external_manual_trade_execution", "_build_external_manual_trade_execution_preview", "_get_city_storage", "_set_city_storage"]:
        assert f'"{helper}"' in service, f"service helper missing: {helper}"
    for field in ['"efficiency"', '"market_turn"', '"market_prices"']:
        assert field in service, f"legacy result field missing: {field}"
    assert 'if bool(result.get("ok", false)):' in service and 'orders.erase(source_city_id)' in service

    print(f"PASS: trade routing static guard; {len(before)} prior functions retained, legacy body identical, diplomacy/spy/coordinator unchanged")


if __name__ == "__main__":
    main()
