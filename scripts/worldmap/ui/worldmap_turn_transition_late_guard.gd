extends Node

# W2-A15 Stable HUD Presentation Coordinator
#
# Production remains the gameplay/source-of-truth owner. Dynamic labels/bars that
# used to flash are now permanently hidden and represented by StableHudMirror.
# This coordinator performs only lightweight final-value synchronization before draw.

const LEFT_CONTENT_PATH := "ProductionWorldMap/WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content"
const TURN_END_BUTTON_NAME := "WildArmyEditButtonPlaceholder"

var _connected := false
var _hidden_items: Array[CanvasItem] = []


func _ready() -> void:
	set_process(false)
	call_deferred("_install_pre_draw_pass")


func _exit_tree() -> void:
	var callback := Callable(self, "_on_frame_pre_draw")
	if _connected and RenderingServer.frame_pre_draw.is_connected(callback):
		RenderingServer.frame_pre_draw.disconnect(callback)
	_connected = false


func _install_pre_draw_pass() -> void:
	var summary := get_node_or_null("../TurnSummaryBridge")
	if summary != null:
		summary.set_process(false)
		_call_if_present(summary, "_hide_post_turn_log_nodes")

	_install_post_turn_visibility_guards()

	var callback := Callable(self, "_on_frame_pre_draw")
	if not RenderingServer.frame_pre_draw.is_connected(callback):
		RenderingServer.frame_pre_draw.connect(callback)
	_connected = true
	_apply_final_presentation()


func _install_post_turn_visibility_guards() -> void:
	_hidden_items.clear()
	var content := get_node_or_null("../" + LEFT_CONTENT_PATH) as VBoxContainer
	if content == null:
		return
	var turn_button := content.get_node_or_null(TURN_END_BUTTON_NAME)
	if turn_button == null:
		return
	var turn_index := turn_button.get_index()
	for child in content.get_children():
		if child.get_index() <= turn_index or not child is CanvasItem:
			continue
		var item := child as CanvasItem
		item.visible = false
		_hidden_items.append(item)
		var callback := Callable(self, "_on_hidden_item_visibility_changed").bind(item)
		if not item.visibility_changed.is_connected(callback):
			item.visibility_changed.connect(callback)


func _on_hidden_item_visibility_changed(item: CanvasItem) -> void:
	if item != null and is_instance_valid(item) and item.visible:
		item.visible = false


func _on_frame_pre_draw() -> void:
	_apply_final_presentation()


func _apply_final_presentation() -> void:
	var warehouse := get_node_or_null("../WarehouseTabsController")
	if warehouse != null:
		_call_if_present(warehouse, "_hide_legacy_source")
		_call_if_present(warehouse, "_refresh_if_needed")

	var tech := get_node_or_null("../TechBadgeController")
	_call_if_present(tech, "_ensure_visible")

	# Tax color and compact domestic metrics still use the existing refinement
	# controller. Loyalty/stability source nodes are hidden by StableHudMirror.
	var refinement := get_node_or_null("../PanelRefinementController")
	if refinement != null:
		_call_if_present(refinement, "_apply_city_stability_presentation")
		_call_if_present(refinement, "_apply_national_gauge_presentation")
		_call_if_present(refinement, "_refresh_domestic_metrics")

	# Visible turn/stability/role information comes only from stable mirrors.
	# Production may republish any temporary legacy text; those sources stay hidden.
	var mirror := get_node_or_null("../StableHudMirrorController")
	_call_if_present(mirror, "_sync_from_sources")


func _call_if_present(target: Node, method_name: String) -> void:
	if target != null and is_instance_valid(target) and target.has_method(method_name):
		target.call(method_name)
