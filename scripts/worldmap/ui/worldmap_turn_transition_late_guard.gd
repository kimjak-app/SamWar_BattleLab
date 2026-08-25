extends Node

# W2-A14 Stable HUD Presentation Coordinator
#
# Production remains the gameplay/source-of-truth owner. The test presentation
# controllers do not race it in independent _process loops. This node performs
# one final lightweight pass immediately before RenderingServer draws the frame.

var _connected := false


func _ready() -> void:
	set_process(false)
	call_deferred("_install_pre_draw_pass")


func _exit_tree() -> void:
	var callback := Callable(self, "_on_frame_pre_draw")
	if _connected and RenderingServer.frame_pre_draw.is_connected(callback):
		RenderingServer.frame_pre_draw.disconnect(callback)
	_connected = false


func _install_pre_draw_pass() -> void:
	# TurnSummaryBridge used to recursively scan/hide the legacy log every normal
	# process frame. The coordinator now owns that final visibility pass instead.
	var summary := get_node_or_null("../TurnSummaryBridge")
	if summary != null:
		summary.set_process(false)

	var callback := Callable(self, "_on_frame_pre_draw")
	if not RenderingServer.frame_pre_draw.is_connected(callback):
		RenderingServer.frame_pre_draw.connect(callback)
	_connected = true
	_apply_final_presentation()


func _on_frame_pre_draw() -> void:
	_apply_final_presentation()


func _apply_final_presentation() -> void:
	# Presentation-only legacy nodes must never reach the renderer.
	var summary := get_node_or_null("../TurnSummaryBridge")
	_call_if_present(summary, "_hide_post_turn_log_nodes")

	# Warehouse nodes are constructed during install. Pre-draw only syncs values
	# and visibility; it never creates/destroys/reparents controls.
	var warehouse := get_node_or_null("../WarehouseTabsController")
	if warehouse != null:
		_call_if_present(warehouse, "_hide_legacy_source")
		_call_if_present(warehouse, "_refresh_if_needed")

	# Static tech sections are simply kept visible; no layout/refit work here.
	var tech := get_node_or_null("../TechBadgeController")
	_call_if_present(tech, "_ensure_visible")

	# Normalize value/status labels.
	var refinement := get_node_or_null("../PanelRefinementController")
	if refinement != null:
		_call_if_present(refinement, "_hide_legacy_help_ui")
		_call_if_present(refinement, "_apply_city_stability_presentation")
		_call_if_present(refinement, "_apply_national_gauge_presentation")
		_call_if_present(refinement, "_refresh_domestic_metrics")
		_call_if_present(refinement, "_place_domestic_metrics_row")

	# Readability is deliberately last. The renderer therefore never sees the
	# temporary production phase string or raw governor/chancellor stat line.
	var readability := get_node_or_null("../ReadabilityController")
	if readability != null:
		_call_if_present(readability, "_compact_calendar_text")
		_call_if_present(readability, "_refine_chancellor_card")
		_call_if_present(readability, "_refine_governor_card")


func _call_if_present(target: Node, method_name: String) -> void:
	if target != null and is_instance_valid(target) and target.has_method(method_name):
		target.call(method_name)
