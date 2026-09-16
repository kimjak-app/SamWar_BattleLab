extends SceneTree

const CatalogScript := preload("res://scripts/worldmap/domestic_tech/domestic_tech_catalog.gd")
const ProviderScript := preload("res://scripts/worldmap/domestic_tech/domestic_tech_effect_provider.gd")
const ControllerScript := preload("res://scripts/worldmap/domestic_tech/domestic_tech_completion_presentation_controller.gd")

var _checks := 0
var _failures := 0
var _completed_calls := 0
var _queue_empty_calls := 0
var _sfx_calls := 0
var _catalog := CatalogScript.new()
var _provider := ProviderScript.new()


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_provider.configure(_catalog)
	var controller := ControllerScript.new()
	root.add_child(controller)
	controller.configure(root, _callbacks(), _provider)
	controller.presentation_completed.connect(func(_result: Dictionary): _completed_calls += 1)
	controller.presentation_queue_empty.connect(func(_result: Dictionary): _queue_empty_calls += 1)
	controller.sfx_requested.connect(func(_sfx_id: String): _sfx_calls += 1)
	controller.ensure_overlay()
	_expect(not controller.is_card_visible(), "completion overlay starts hidden")

	var first := _event("agri_tool_upgrade")
	var second := _event("agri_irrigation")
	controller.enqueue([first])
	await process_frame
	var state := controller.get_state_snapshot()
	_expect(bool(state.active) and str((state.current_item as Dictionary).tech_id) == "agri_tool_upgrade", "enqueue one starts first presentation")
	controller.enqueue([second, first])
	state = controller.get_state_snapshot()
	_expect((state.queue as Array).size() == 1 and str((state.queue as Array)[0].tech_id) == "agri_irrigation", "multiple enqueue is FIFO and duplicate is blocked")
	_expect(controller._domestic_tech_completion_video_player != null and controller._domestic_tech_completion_video_player.visible, "completion video starts")
	controller._complete_domestic_tech_completion_video_mvp("test_skip")
	_expect(controller.is_card_visible(), "skip opens completion card")
	controller._complete_domestic_tech_completion_video_mvp("finished_signal")
	_expect(controller.is_card_visible(), "skip and finished share a double guard")
	_expect(_sfx_calls == 1, "research SFX requested once when card opens")
	var first_item: Dictionary = state.current_item
	_expect(str(first_item.effect_summary).contains("군량 생산"), "effect lines are preserved through EffectProvider data")
	controller.confirm()
	controller.confirm()
	_expect(_completed_calls == 1, "confirm completes exactly once")
	await process_frame
	state = controller.get_state_snapshot()
	_expect(bool(state.active) and str((state.current_item as Dictionary).tech_id) == "agri_irrigation", "next item starts after confirmation")
	controller._complete_domestic_tech_completion_video_mvp("finished_signal")
	_expect(controller.is_card_visible(), "video finished opens card")
	controller.confirm()
	_expect(_completed_calls == 2 and _queue_empty_calls == 1, "queue completion and empty signal emit once")
	state = controller.get_state_snapshot()
	_expect(not bool(state.active) and (state.current_item as Dictionary).is_empty(), "active presentation state resets")
	controller.play_next()
	_expect(_queue_empty_calls == 1, "queue-empty signal is deduplicated")
	controller.enqueue([first])
	await process_frame
	_expect(not bool(controller.get_state_snapshot().active), "completed presentation identity cannot enqueue twice")

	var missing_video_item := controller._make_domestic_tech_completion_presentation_item_mvp(_event("agri_double_cropping"))
	missing_video_item.video_path = ""
	_expect(not controller._play_domestic_tech_completion_video_mvp(missing_video_item), "missing video falls back to card path")
	var rect := controller._get_domestic_tech_completion_video_panel_rect_mvp(Vector2(1920.0, 1080.0))
	_expect(is_equal_approx(rect.size.x / rect.size.y, 16.0 / 9.0), "video layout aspect ratio preserved")
	_expect(rect.size.y <= 648.0 and rect.position.x > 0.0, "video max-height and centering preserved")
	var item := controller._make_domestic_tech_completion_presentation_item_mvp(_event("agri_tool_upgrade"))
	_expect(_has_keys(item, ["scope", "city_id", "city_name", "tech_id", "tech_name", "category_name", "icon_path", "message", "effect_summary", "video_path"]), "completion item shape preserved")
	_expect(controller._make_domestic_tech_completion_presentation_item_mvp({}).is_empty(), "malformed completion event is ignored")
	_expect(not controller.has_method("start_research") and not controller.has_method("complete_research"), "no research mutation dependency")
	_expect(not controller.has_method("save_game") and not controller.has_method("_save_worldmap_state"), "no save dependency")
	_finish()


func _event(tech_id: String) -> Dictionary:
	return {"completed": true, "type": "city", "city_id": "hanseong", "tech_id": tech_id, "completed_turn": 12}


func _callbacks() -> Dictionary:
	return {
		"categories": func(): return _catalog.get_categories(),
		"definition": func(tech_id: String): return _catalog.get_definition(tech_id),
		"resolved_icon_path": func(_tech_id: String, definition_path: String): return definition_path,
		"format_city_name": func(_city_id: String, _fallback: String): return "한성",
		"city_owned": func(_city_id: String): return true,
		"format_percent": func(value: float): return "%+.0f%%" % (value * 100.0),
		"format_signed_int": func(value: int): return "%+d" % value,
		"play_sfx": func(_sfx_id: String): pass,
	}


func _has_keys(value: Dictionary, keys: Array) -> bool:
	for key in keys:
		if not value.has(key):
			return false
	return true


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[DOMESTIC_TECH_COMPLETION_PRESENTATION_FAIL] %s" % label)


func _finish() -> void:
	print("[DOMESTIC_TECH_COMPLETION_PRESENTATION] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
