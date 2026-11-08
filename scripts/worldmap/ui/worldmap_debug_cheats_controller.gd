class_name WorldMapDebugCheatsController
extends Node

## Queue 30 DEBUG-CHEATS (reply 1, option A): three developer cheats for world-map testing, debug builds only.
##   Ctrl+Shift+G      fill every owned city's stock (city resource_stock and city storage) to WAREHOUSE_CAPACITY
##   Ctrl+Shift+T      complete the tech selected in the open tech tree (no cost, no prerequisites, active research kept)
##   Ctrl+Shift+Alt+T  complete every tech of the selected tech's scope (city scope: the selected city only)
##   Ctrl+Shift+I      toggle: show every field of enemy city intel without spying (read-time only, never saved)
## Attached as a root child of WorldMap.tscn, outside worldmap_main.gd (main is byte-pinned by tools/p1_exact_delta.py).
## In a non-debug build the node frees itself in _ready and does nothing. Main is reached only through call()/get() on
## its existing methods and members. No new save keys: cheat ① writes ordinary stock values, ② ordinary completion
## flags, ③ nothing (the spy presenter asks this controller at read time while the toggle is on).

const KEY_FILL_RESOURCES := KEY_G
const KEY_COMPLETE_TECH := KEY_T
const KEY_REVEAL_INTEL := KEY_I
const INTEL_FIELDS: Array[String] = ["troops", "resources", "publicSupport", "loyalty", "governor", "tech"]
const SCOPE_CITY := "city"
const SCOPE_NATIONAL := "national"
const STATUS_PREFIX := "[디버그] "

@export var main_path: NodePath = NodePath("..")

## -1 = follow OS.is_debug_build(); 0 = force off; 1 = force on. Tests set this before adding the node.
var enabled_override := -1
var main: Node = null
var _active := false
var _intel_reveal := false


func _ready() -> void:
	if not is_cheats_enabled():
		queue_free()
		return
	main = get_node_or_null(main_path)
	if main == null or not main.has_method("_ensure_spy_presenter"):
		main = null
		return
	_active = true


func _exit_tree() -> void:
	if _intel_reveal:
		set_intel_reveal(false)


func is_cheats_enabled() -> bool:
	if enabled_override >= 0:
		return enabled_override == 1
	return OS.is_debug_build()


func is_active() -> bool:
	return _active and main != null and is_instance_valid(main)


func is_intel_reveal_on() -> bool:
	return _intel_reveal


func _unhandled_key_input(event: InputEvent) -> void:
	if not is_active():
		return
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo or not key.ctrl_pressed or not key.shift_pressed:
		return
	match key.keycode:
		KEY_FILL_RESOURCES:
			fill_resources()
		KEY_COMPLETE_TECH:
			if key.alt_pressed:
				complete_all_techs_in_selected_scope()
			else:
				complete_selected_tech()
		KEY_REVEAL_INTEL:
			set_intel_reveal(not _intel_reveal)
		_:
			return
	get_viewport().set_input_as_handled()


# ---- ① resources -------------------------------------------------------------------------------------------------

func fill_resources() -> Dictionary:
	if not is_active():
		return {"ok": false, "reason": "inactive"}
	var capacity: Dictionary = _get_main_constant("WAREHOUSE_CAPACITY", {})
	var city_ids := get_owned_city_ids()
	for city_id_variant in city_ids:
		var city_id := str(city_id_variant)
		main.call("_ensure_city_supply_resource_defaults", city_id)
		var storage: Dictionary = (main.call("_get_city_storage", city_id) as Dictionary).duplicate(true)
		for resource_id_variant in capacity.keys():
			var resource_id := str(resource_id_variant)
			var amount := int(capacity[resource_id_variant])
			main.call("_wounded_recovery_mutation", "set_city_resource_amount", [city_id, resource_id, amount])
			storage[resource_id] = amount
		main.call("_set_city_storage", city_id, storage)
	main.call("_rebuild_occupation_runtime_indexes_mvp")
	_refresh_after_resource_change()
	_status("자원 채움: 내 도시 %d곳, 창고 용량 값(금 %d)" % [city_ids.size(), int(capacity.get("gold", 0))])
	return {"ok": true, "city_ids": city_ids.duplicate()}


## The national payment cities plus every CITY_HUD_DATA city the player owns: the same owner test as the national
## re-aggregation (_rebuild_occupation_runtime_indexes_mvp), so a city without a runtime state yet is not skipped.
func get_owned_city_ids() -> Array[String]:
	var city_ids: Array[String] = []
	if not is_active():
		return city_ids
	for city_id_variant in main.call("_get_national_payment_city_ids_mvp"):
		city_ids.append(str(city_id_variant))
	var player := str(main.call("_get_current_player_faction_id"))
	var registry: Dictionary = _get_main_constant("CITY_HUD_DATA", {})
	var extra: Array[String] = []
	for city_id_variant in registry.keys():
		var city_id := str(city_id_variant)
		if not city_ids.has(city_id) and str(main.call("_get_city_owner_id_for_battle_context", city_id)) == player:
			extra.append(city_id)
	extra.sort()
	city_ids.append_array(extra)
	return city_ids


func _refresh_after_resource_change() -> void:
	main.call("_refresh_left_world_status_panel")
	_refresh_selected_city_panels(true)
	if bool(main.call("_is_domestic_tech_tree_overlay_open_mvp")):
		main.call("_refresh_domestic_tech_tree_overlay_mvp")


# ---- ② tech ------------------------------------------------------------------------------------------------------

func complete_selected_tech() -> Dictionary:
	var selection := _get_tech_selection()
	if not bool(selection.get("ok", false)):
		_status(str(selection.get("message", "")))
		return selection
	var tech_id := str(selection.tech_id)
	var scope := str(selection.scope)
	var city_id := str(selection.city_id)
	if _is_tech_completed(scope, city_id, tech_id):
		_status("이미 완료된 테크: %s" % _tech_name(tech_id))
		return {"ok": false, "reason": "already_completed", "tech_id": tech_id}
	_mark_completed(scope, city_id, tech_id)
	_refresh_after_tech_change(scope, city_id, [tech_id])
	_status("테크 즉시 완료: %s" % _tech_name(tech_id))
	return {"ok": true, "tech_id": tech_id, "scope": scope, "city_id": city_id}


func complete_all_techs_in_selected_scope() -> Dictionary:
	var selection := _get_tech_selection()
	if not bool(selection.get("ok", false)):
		_status(str(selection.get("message", "")))
		return selection
	var scope := str(selection.scope)
	var city_id := str(selection.city_id)
	var catalog = main.call("_ensure_domestic_tech_catalog")
	var definitions: Dictionary = catalog.get_city_definitions() if scope == SCOPE_CITY else catalog.get_national_definitions()
	# The tech under active research is skipped: the research service's normalizer empties a slot whose tech is
	# completed, and the active research must stay as it is.
	var service = main.call("_ensure_domestic_tech_research_service")
	var active: Dictionary = service.get_city_active_research(city_id) if scope == SCOPE_CITY else service.get_national_active_research()
	var active_tech_id := str(active.get("tech_id", ""))
	var tech_ids: Array[String] = []
	for tech_id_variant in definitions.keys():
		var tech_id := str(tech_id_variant)
		if tech_id != active_tech_id and not _is_tech_completed(scope, city_id, tech_id):
			_mark_completed(scope, city_id, tech_id)
			tech_ids.append(tech_id)
	if tech_ids.is_empty():
		_status("이 범위의 테크는 모두 완료됨")
		return {"ok": false, "reason": "already_completed"}
	_refresh_after_tech_change(scope, city_id, tech_ids)
	_status("%s 테크 %d개 즉시 완료" % ["도시" if scope == SCOPE_CITY else "나라", tech_ids.size()])
	return {"ok": true, "tech_ids": tech_ids, "scope": scope, "city_id": city_id}


func _get_tech_selection() -> Dictionary:
	if not is_active():
		return {"ok": false, "reason": "inactive", "message": ""}
	if not bool(main.call("_is_domestic_tech_tree_overlay_open_mvp")):
		return {"ok": false, "reason": "overlay_closed", "message": "테크트리가 닫혀 있음"}
	var selection: Dictionary = main.call("_ensure_domestic_tech_tree_presentation_controller").get_selection()
	var tech_id := str(selection.get("tech_id", ""))
	if tech_id.is_empty():
		return {"ok": false, "reason": "no_selection", "message": "선택된 테크 없음"}
	var definition: Dictionary = main.call("_ensure_domestic_tech_catalog").get_definition(tech_id)
	var scope := str(definition.get("tree_scope", ""))
	var city_id := str(selection.get("city_id", "")) if scope == SCOPE_CITY else ""
	if scope != SCOPE_CITY and scope != SCOPE_NATIONAL:
		return {"ok": false, "reason": "invalid_scope", "message": "테크 범위를 알 수 없음"}
	if scope == SCOPE_CITY and city_id.is_empty():
		return {"ok": false, "reason": "no_city", "message": "도시 테크의 도시가 선택되지 않음"}
	return {"ok": true, "tech_id": tech_id, "scope": scope, "city_id": city_id}


func _is_tech_completed(scope: String, city_id: String, tech_id: String) -> bool:
	var service = main.call("_ensure_domestic_tech_research_service")
	var completed: Dictionary = service.get_city_completed_snapshot(city_id) if scope == SCOPE_CITY else service.get_national_completed_snapshot()
	return bool(completed.get(tech_id, false))


## Completion flags only: the active research slot of that scope is left untouched (complete_*_research would clear it).
func _mark_completed(scope: String, city_id: String, tech_id: String) -> void:
	var service = main.call("_ensure_domestic_tech_research_service")
	service.mark_completed_from_normalize(scope, city_id, tech_id)
	if scope == SCOPE_CITY:
		service.sync_city_completed_mirror(city_id)


## The same refresh path as a normal turn completion (_advance_domestic_tech_research_for_world_turn_mvp), without the
## completion card.
func _refresh_after_tech_change(scope: String, city_id: String, tech_ids: Array[String]) -> void:
	var raw_events: Array = []
	for tech_id in tech_ids:
		raw_events.append({"type": scope, "city_id": city_id, "tech_id": tech_id, "completed": true})
	var events: Array = main.call("_decorate_domestic_tech_event_list_mvp", raw_events)
	main.call("_refresh_domestic_tech_tree_overlay_mvp")
	main.call("_refresh_domestic_tech_effect_display_surfaces_mvp", {"completed": events})
	main.call("_refresh_worldmap_tech_badge_summary_if_present")


func _tech_name(tech_id: String) -> String:
	return str(main.call("_get_domestic_tech_display_name_mvp", tech_id))


# ---- ③ intel -----------------------------------------------------------------------------------------------------

func set_intel_reveal(on: bool) -> Dictionary:
	if on and not is_active():
		return {"ok": false, "reason": "inactive"}
	if main == null or not is_instance_valid(main):
		_intel_reveal = false
		return {"ok": false, "reason": "no_main"}
	_intel_reveal = on
	var presenter = main.call("_ensure_spy_presenter")
	presenter.set("debug_intel_provider", Callable(self, "build_revealed_intel_entry") if on else Callable())
	if is_inside_tree() and not is_queued_for_deletion():
		_refresh_selected_city_panels(false)
		_status("적 성 정보 전부 보기: %s" % ("켬" if on else "끔"))
	return {"ok": true, "on": on}


## Read-time entry for an enemy (or unowned) city with every field and the real values from the spy service's own
## payload builder. Returns {} for the player's own cities (normal path). Never written to _player_state.
func build_revealed_intel_entry(city_id: String) -> Dictionary:
	if not _intel_reveal or not is_active():
		return {}
	var owner := str(main.call("_get_city_owner_faction_id_for_trade_display", city_id))
	if owner == str(main.call("_get_current_player_faction_id")):
		return {}
	var spy_controller = main.call("_ensure_spy_controller")
	var service = spy_controller.get("_service")
	if service == null:
		return {}
	if service.get("_adapter") == null:   # reply 1 §3: fill only when empty; the normal spy calls set the same value
		service.set("_adapter", spy_controller)
	var payload: Dictionary = service.call("_build_spy_info_payload", city_id, INTEL_FIELDS.duplicate(), false)
	if payload.is_empty():
		return {}
	var state: Dictionary = main.get("_player_state")
	return {
		"turn": maxi(1, int(state.get("turn_number", 1))),
		"fields": INTEL_FIELDS.duplicate(),
		"estimated": false,
		"payload": payload,
	}


# ---- shared ------------------------------------------------------------------------------------------------------

func _refresh_selected_city_panels(owned_only: bool) -> void:
	var marker = main.get("selected_city_marker")
	if marker == null or not is_instance_valid(marker):
		return
	if owned_only and not bool(main.call("_is_city_owned_by_player_mvp", str(marker.city_id))):
		return
	var info_panel = main.get("city_info_panel")
	if info_panel != null and info_panel.has_method("show_city"):
		info_panel.show_city(marker)
	main.call("_refresh_unified_panel_content")


func _status(message: String) -> void:
	if message.is_empty() or not is_active():
		return
	main.call("_set_save_management_status", STATUS_PREFIX + message)


func _get_main_constant(name: String, fallback: Variant) -> Variant:
	var script := main.get_script() as Script
	if script == null:
		return fallback
	var constants := script.get_script_constant_map()
	return constants.get(name, fallback)
