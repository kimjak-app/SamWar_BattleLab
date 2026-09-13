"""Static guard for production Spy routing through the extracted Controller."""

from validate_worldmap_spy_controller_extraction import main as validate_controller_extraction
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def current(path):
    return (ROOT / path).read_text(encoding="utf-8")


def main():
    validate_controller_extraction()
    host = current("scripts/worldmap/worldmap_main.gd")
    coordinator = current("scripts/worldmap/actions/worldmap_action_coordinator.gd")
    assert '.begin("spy", target_city_id)' in host
    assert '.execute_now("spy", action_id, target_city_id)' in host
    assert 'if action_type == "spy":' in host
    assert "_pending_spy_action_id" in host
    assert "func begin(" in coordinator
    assert "func cancel(" in coordinator
    assert "func request_presentation(" in coordinator
    assert "func complete(" in coordinator
    assert "func execute_now(" in coordinator
    assert "signal action_resolved" in coordinator
    assert "signal presentation_requested" in coordinator
    assert '"spy":\n\t\t\tif _spy_controller == null:' in coordinator
    assert "return _spy_controller.execute(action_id, target_city_id, source_city_id)" in coordinator
    print("PASS: Spy production routing uses WorldMapMain thin bridge -> Coordinator -> SpyController -> SpyActionService")


if __name__ == "__main__":
    main()
