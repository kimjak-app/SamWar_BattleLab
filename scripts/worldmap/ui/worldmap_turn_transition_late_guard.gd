extends Node

# W2-A14 Stable HUD Presentation Coordinator
#
# Production remains the gameplay/source-of-truth owner. The test presentation
# controllers no longer race it in several independent _process loops. Instead,
# this node performs one lightweight final presentation pass immediately before
# RenderingServer draws the frame. Any legacy text that production republishes
# during the frame is therefore normalized before it can become visible.

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
	var callback := Callable(self, "_on_frame_pre_draw")
	if not RenderingServer.frame_pre_draw.is_connected(callback):
		RenderingServer.frame_pre_draw.connect(callback)
	_connected = true
	_apply_final_presentation()


func _on_frame_pre_draw() -> void:
	_apply_final_presentation()


func _apply_final_presentation() -> void:
	# Legacy turn-summary nodes are presentation-only and must never reappear.
	var summary := get_node_or_null("../TurnSummaryBridge")
	_call_if_present(summary, "_hide_post_turn_log_nodes")

	# Normalize value/status labels first.
	var refinement := get_node_or_null("../PanelRefinementController")
	if refinement != null:
		_call_if_present(refinement, "_hide_legacy_help_ui")
		_call_if_present(refinement, "_apply_city_stability_presentation")
		_call_if_present(refinement, "_apply_national_gauge_presentation")
		_call_if_present(refinement, "_refresh_domestic_metrics")
		_call_if_present(refinement, "_place_domestic_metrics_row")

	# Readability is deliberately last. This guarantees that the renderer sees
	# only the compact calendar and role summaries, never production's temporary
	# phase string or raw hero-stat line.
	var readability := get_node_or_null("../ReadabilityController")
	if readability != null:
		_call_if_present(readability, "_compact_calendar_text")
		_call_if_present(readability, "_refine_chancellor_card")
		_call_if_present(readability, "_refine_governor_card")


func _call_if_present(target: Node, method_name: String) -> void:
	if target != null and is_instance_valid(target) and target.has_method(method_name):
		target.call(method_name)
