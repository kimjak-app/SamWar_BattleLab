extends Node

const TURN_END_BUTTON_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/WildArmyEditButtonPlaceholder"
const GUARD_DURATION_MSEC := 4000
const MAX_BIND_ATTEMPTS := 10

@onready var production_world_map: Node = get_node_or_null("../ProductionWorldMap")

var _turn_end_button: Button = null
var _bind_attempts := 0
var _guard_generation := 0
var _guard_until_msec := 0


func _ready() -> void:
	call_deferred("_bind_turn_end_button")


func _bind_turn_end_button() -> void:
	if production_world_map == null:
		return
	_turn_end_button = production_world_map.get_node_or_null(TURN_END_BUTTON_PATH) as Button
	if _turn_end_button == null:
		if _bind_attempts < MAX_BIND_ATTEMPTS:
			_bind_attempts += 1
			call_deferred("_bind_turn_end_button")
		return

	var callback := Callable(self, "_on_turn_end_button_down")
	if not _turn_end_button.button_down.is_connected(callback):
		_turn_end_button.button_down.connect(callback)


func _on_turn_end_button_down() -> void:
	_guard_generation += 1
	_guard_until_msec = Time.get_ticks_msec() + GUARD_DURATION_MSEC
	_refresh_compact_presentation_now()
	call_deferred("_late_refresh_tick", _guard_generation)


func _late_refresh_tick(generation: int) -> void:
	if generation != _guard_generation:
		return
	if Time.get_ticks_msec() > _guard_until_msec:
		return

	# Production can update labels/cards from an awaited turn callback after the
	# normal _process pass. Re-apply the compact presentation in deferred idle so
	# those temporary legacy values never reach the rendered frame.
	_refresh_compact_presentation_now()
	await get_tree().process_frame

	if generation == _guard_generation and Time.get_ticks_msec() <= _guard_until_msec:
		call_deferred("_late_refresh_tick", generation)


func _refresh_compact_presentation_now() -> void:
	var readability := get_node_or_null("../ReadabilityController")
	if readability != null:
		_call_if_present(readability, "_compact_calendar_text")
		_call_if_present(readability, "_refine_chancellor_card")
		_call_if_present(readability, "_refine_governor_card")

	var refinement := get_node_or_null("../PanelRefinementController")
	if refinement != null:
		_call_if_present(refinement, "_hide_legacy_help_ui")
		_call_if_present(refinement, "_apply_city_stability_presentation")
		_call_if_present(refinement, "_apply_national_gauge_presentation")
		_call_if_present(refinement, "_refresh_domestic_metrics")
		_call_if_present(refinement, "_place_domestic_metrics_row")


func _call_if_present(target: Node, method_name: String) -> void:
	if target != null and is_instance_valid(target) and target.has_method(method_name):
		target.call(method_name)
