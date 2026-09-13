"""Trade Controller extraction guard: ownership, routing, and frozen boundaries."""

import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = "b51f95f868aa7bda891895ac29eb0730d0b15428"
MAIN = "scripts/worldmap/worldmap_main.gd"
COORDINATOR = "scripts/worldmap/actions/worldmap_action_coordinator.gd"
CONTROLLER = "scripts/worldmap/actions/trade_controller.gd"
SERVICE = "scripts/worldmap/actions/trade_action_service.gd"
PRESENTER = "scripts/worldmap/actions/trade_presentation_helper.gd"


def current(path):
    return (ROOT / path).read_text(encoding="utf-8")


def at_base(path):
    return subprocess.check_output(["git", "show", f"{BASE}:{path}"], cwd=ROOT).decode("utf-8").replace("\r\n", "\n")


def functions(source):
    return {
        match[1]: "\n".join(line for line in match[2].splitlines() if line.strip() and not line.lstrip().startswith("#"))
        for match in re.finditer(r"(?ms)^func (\w+)(\(.*?)(?=^func |\Z)", source)
    }


def main():
    source = current(MAIN)
    coordinator = current(COORDINATOR)
    controller = current(CONTROLLER)
    service = current(SERVICE)
    presenter = current(PRESENTER)

    assert "TradeActionServiceScript" not in coordinator
    assert "var _trade_controller: RefCounted" in coordinator
    assert "configure_trade(controller: RefCounted)" in coordinator
    assert "return _trade_controller.execute(action_id, target_city_id, source_city_id)" in coordinator
    assert "return _trade_controller.execute_order(order)" in coordinator
    assert "configure_trade(_ensure_trade_controller())" in source
    assert controller.count("TradeActionServiceScript.new()") == 1
    assert "TradeActionServiceScript.new()" not in source + coordinator
    assert "_service.execute_order(self, order, _build_external_manual_trade_execution_context(order))" in controller

    for removed in [
        "_execute_external_manual_trade_order_legacy",
        "_validate_external_manual_trade_execution",
        "_build_external_manual_trade_execution_preview",
        "_calculate_external_trade_delta",
        "_build_empty_external_trade_delta",
        "_normalize_manual_trade_order_payload",
        "_normalize_manual_trade_order_items",
        "_normalize_trade_delta_payload",
        "_format_manual_trade_preview_summary",
        "_format_external_trade_manual_order_summary",
        "_format_external_manual_trade_execution_result_summary",
        "_format_manual_trade_nonzero_preview_summary",
        "_format_trade_market_prices_for_external_trade_ui",
    ]:
        assert f"func {removed}(" not in source, f"Trade implementation remains in main: {removed}"

    assert "_host.call" not in service and '_player_state' not in service and '_manual_trade_orders' not in service
    for method in ["validate_order", "build_preview", "calculate_import_cost", "calculate_export_gain", "execute_order"]:
        assert f"func {method}(" in service, f"Service rule missing: {method}"
    for method in ["sync_persistence_to_player_state", "restore_persistence_from_player_state", "get_manual_trade_order", "store_manual_trade_order"]:
        assert f"func {method}(" in controller, f"Controller lifecycle missing: {method}"
    for method in ["format_manual_trade_preview_summary", "format_external_trade_manual_order_summary", "format_trade_market_prices_for_external_trade_ui"]:
        assert f"func {method}(" in presenter, f"Presenter formatter missing: {method}"
    assert "Button.new" not in presenter and "Label.new" not in presenter

    for frozen in [
        "scripts/worldmap/actions/diplomacy_controller.gd",
        "scripts/worldmap/actions/diplomacy_action_service.gd",
        "scripts/worldmap/actions/diplomacy_presentation_helper.gd",
        "scripts/worldmap/actions/spy_action_service.gd",
        "scripts/worldmap/ui/worldmap_action_presentation_controller.gd",
    ]:
        assert current(frozen) == at_base(frozen), f"Frozen Diplomacy/Spy/presentation boundary changed: {frozen}"

    old, new = functions(at_base(MAIN)), functions(source)
    for boundary in ["_calculate_military_support_acceptance_chance", "_request_military_support", "_break_spy_wedge_alliance_if_needed", "_apply_spy_action"]:
        assert new[boundary] == old[boundary], f"Spy/Military boundary changed: {boundary}"

    print("PASS: Trade Controller/Service/Presenter ownership; Diplomacy, Spy, Military boundaries frozen")


if __name__ == "__main__":
    main()
