#!/usr/bin/env python3
"""Static contract checks for service-owned WorldMap contextual actions."""

from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]


def read(relative_path: str) -> str:
    return (ROOT / relative_path).read_text(encoding="utf-8")


def require(source: str, token: str, label: str) -> None:
    if token not in source:
        raise AssertionError(f"missing {label}: {token}")


def forbid(source: str, token: str, label: str) -> None:
    if token in source:
        raise AssertionError(f"forbidden {label}: {token}")


def function_blocks(source: str, name: str) -> list[str]:
    pattern = re.compile(rf"(?ms)^func {re.escape(name)}\b.*?(?=^func |\Z)")
    return [match.group(0) for match in pattern.finditer(source)]


def function_block(source: str, name: str) -> str:
    blocks = function_blocks(source, name)
    if len(blocks) != 1:
        raise AssertionError(f"expected one {name}, found {len(blocks)}")
    return blocks[0]


def validate_optional_shim(
    source: str,
    name: str,
    route_token: str,
    forbidden_tokens: tuple[str, ...],
) -> None:
    blocks = function_blocks(source, name)
    if len(blocks) > 1:
        raise AssertionError(f"expected zero or one {name}, found {len(blocks)}")
    if not blocks:
        if re.search(rf"\b{re.escape(name)}\s*\(", source):
            raise AssertionError(f"dangling legacy call without shim: {name}")
        return
    block = blocks[0]
    require(block, route_token, f"{name} compatibility shim")
    for token in forbidden_tokens:
        forbid(block, token, f"legacy logic in {name} shim")


def main() -> None:
    coordinator = read("scripts/worldmap/actions/worldmap_action_coordinator.gd")
    diplomacy_service = read("scripts/worldmap/actions/diplomacy_action_service.gd")
    spy_service = read("scripts/worldmap/actions/spy_action_service.gd")
    trade_service = read("scripts/worldmap/actions/trade_action_service.gd")
    worldmap = read("scripts/worldmap/worldmap_main.gd")
    city_actions = read("scripts/worldmap/ui/worldmap_city_action_test_controller.gd")
    presentation = read("scripts/worldmap/ui/worldmap_action_presentation_controller.gd")

    for token in (
        'const VALID_ACTION_TYPES := ["diplomacy", "spy", "trade"]',
        "func request_presentation(",
        "func complete(",
        "func execute_now(",
        "func execute_trade_order(",
        "func _execute_domain_action(",
        "return _diplomacy_service.execute(host, action_id, target_city_id, source_city_id)",
        "return _spy_service.execute(host, action_id, target_city_id, source_city_id)",
        "return _trade_service.execute(host, action_id, target_city_id, source_city_id)",
        "return _trade_service.execute_order(get_parent(), order)",
        "action_resolved.emit(completed_type, result)",
    ):
        require(coordinator, token, "coordinator service contract")
    forbid(coordinator, "fallback_execute_action", "legacy coordinator fallback")
    forbid(coordinator, "execute_action: Callable", "legacy coordinator callable")

    complete_bridge = function_block(worldmap, "complete_contextual_worldmap_action")
    require(
        complete_bridge,
        "_contextual_action_coordinator.complete(",
        "WorldMap completion bridge",
    )
    forbid(
        complete_bridge,
        'Callable(self, "_execute_contextual_worldmap_action")',
        "legacy completion callable",
    )
    forbid(
        worldmap,
        "func _execute_contextual_worldmap_action(",
        "legacy contextual dispatcher",
    )

    validate_optional_shim(
        worldmap,
        "_apply_diplomacy_action",
        '_contextual_action_coordinator.execute_now("diplomacy", action_id, target_city_id)',
        ("_apply_generic_resource_cost", "_adjust_faction_relation_score"),
    )
    validate_optional_shim(
        worldmap,
        "_apply_spy_action",
        '_contextual_action_coordinator.execute_now("spy", action_id, target_city_id)',
        ("_validate_spy_action", "_gather_spy_info", "_apply_spy_wedge_action"),
    )
    validate_optional_shim(
        worldmap,
        "_execute_external_manual_trade_order",
        '_contextual_action_coordinator.execute_trade_order(order)',
        ("_validate_external_manual_trade_execution", "_set_city_storage"),
    )

    for token in (
        'host.call("_validate_diplomacy_action", action_id, target_city_id)',
        '"_apply_generic_resource_cost"',
        '"_adjust_faction_relation_score"',
        'relation_entry["diplomacy_action_cooldown"]',
        'relation_entry["trade_agreement_active"] = true',
    ):
        require(diplomacy_service, token, "diplomacy service orchestration")
    forbid(
        diplomacy_service,
        'host.call("_apply_diplomacy_action"',
        "diplomacy monolith bridge",
    )

    for token in (
        'host.call("_validate_spy_action", action_id, target_city_id)',
        '"_gather_spy_info"',
        '"_disrupt_city_public_support"',
        '"_disrupt_city_loyalty"',
        '"_instigate_revolt"',
        '"_apply_spy_wedge_action"',
    ):
        require(spy_service, token, "spy service orchestration")
    forbid(spy_service, 'host.call("_apply_spy_action"', "spy monolith bridge")

    for token in (
        "func execute_order(host: Object, order: Dictionary) -> Dictionary:",
        'host.call("_validate_external_manual_trade_execution", order)',
        'host.call("_build_external_manual_trade_execution_preview", order)',
        '"_set_city_storage"',
        'player_state["last_external_manual_trade_execution_result"] = result.duplicate(true)',
        "orders.erase(source_city_id)",
    ):
        require(trade_service, token, "trade service orchestration")
    forbid(trade_service, "func _execute_order(", "private legacy trade executor")
    forbid(
        trade_service,
        'host.call("_execute_external_manual_trade_order"',
        "trade monolith bridge",
    )

    for old_state in (
        "var _contextual_worldmap_action_type",
        "var _contextual_worldmap_action_target_city_id",
        "var _contextual_worldmap_action_source_city_id",
        "var _contextual_worldmap_action_pending",
    ):
        forbid(worldmap, old_state, "legacy main-owned contextual state")

    require(
        city_actions,
        'production_world_map.call(\n\t\t"open_contextual_worldmap_action",',
        "foreign-city production route",
    )
    forbid(city_actions, "action_video_test_requested", "video-only city action route")
    forbid(presentation, "_video_test_only", "video-only presentation state")
    require(
        presentation,
        'production_world_map.call("complete_contextual_worldmap_action", action_type, action_id, target_city_id)',
        "video completion route",
    )
    require(
        presentation,
        "func _on_action_resolved(action_type: String, result: Dictionary) -> void:\n\t_show_result(action_type, result)",
        "resolved result scroll route",
    )

    print(
        "PASS: WorldMap action execution is service-owned; main has no legacy execution body."
    )


if __name__ == "__main__":
    main()
