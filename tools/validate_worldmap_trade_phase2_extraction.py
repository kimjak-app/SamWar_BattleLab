from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
MAIN = (ROOT / "scripts/worldmap/worldmap_main.gd").read_text(encoding="utf-8")
CONTROLLER = (ROOT / "scripts/worldmap/actions/trade_controller.gd").read_text(encoding="utf-8")
AUTO = (ROOT / "scripts/worldmap/actions/trade_automation_service.gd").read_text(encoding="utf-8")
INTERNAL = (ROOT / "scripts/worldmap/actions/internal_trade_transfer_service.gd").read_text(encoding="utf-8")
COORDINATOR = (ROOT / "scripts/worldmap/actions/worldmap_action_coordinator.gd").read_text(encoding="utf-8")

errors: list[str] = []

for needle in [
    'TradeActionServiceScript.new()',
    'TradeAutomationServiceScript.new()',
    'InternalTradeTransferServiceScript.new()',
    'func run_chancellor_auto_trade(',
    'func execute_internal_transfer(',
]:
    if needle not in CONTROLLER:
        errors.append(f"TradeController missing ownership/facade: {needle}")

for forbidden in [
    'func _apply_chancellor_internal_auto_trade(',
    'func _apply_chancellor_external_auto_trade(',
    'func _get_chancellor_auto_trade_resource_priority(',
    'CHANCELLOR_AUTO_TRADE_STORAGE_TARGETS',
]:
    if forbidden in MAIN:
        errors.append(f"auto-trade rule remains in main: {forbidden}")

for service_name, source in [("automation", AUTO), ("internal", INTERNAL)]:
    for forbidden in ['worldmap_main', 'adapter.get("_player_state")', 'adapter.get("_city_runtime_states")', '_host']:
        if forbidden in source:
            errors.append(f"{service_name} Service directly depends on giant main: {forbidden}")

if 'return _ensure_trade_controller().run_chancellor_auto_trade(turn_number)' not in MAIN:
    errors.append("turn auto-trade thin bridge missing")
if 'return _ensure_trade_controller().validate_internal_transfer(source_city_id, target_city_id, amounts)' not in MAIN:
    errors.append("internal validation thin bridge missing")
if 'return _ensure_trade_controller().execute_internal_transfer(source_city_id, target_city_id, amounts)' not in MAIN:
    errors.append("internal execution thin bridge missing")
if '_trade_controller.execute_order(order)' not in COORDINATOR:
    errors.append("manual Coordinator -> TradeController routing changed")
if '_action_service.execute_order(self, order,' not in CONTROLLER:
    errors.append("manual TradeController -> TradeActionService routing changed")

for frozen in [
    ROOT / "scripts/worldmap/actions/diplomacy_controller.gd",
    ROOT / "scripts/worldmap/actions/spy_controller.gd",
]:
    if not frozen.exists():
        errors.append(f"frozen controller missing: {frozen.name}")

changed = set(
    subprocess.run(
        ["git", "diff", "HEAD", "--name-only"], cwd=ROOT, check=True, capture_output=True, text=True
    ).stdout.splitlines()
)
for forbidden_path in [
    "scripts/worldmap/actions/diplomacy_controller.gd",
    "scripts/worldmap/actions/spy_controller.gd",
    "scripts/worldmap/actions/worldmap_action_coordinator.gd",
]:
    if forbidden_path in changed:
        errors.append(f"frozen routing changed: {forbidden_path}")
if any(path.endswith(".tscn") or "/ui/" in path for path in changed):
    errors.append("UI/scene restoration or modification detected")

if errors:
    for error in errors:
        print(f"FAIL: {error}")
    raise SystemExit(1)

print("PASS: WorldMap Trade Phase 2 extraction boundaries")
