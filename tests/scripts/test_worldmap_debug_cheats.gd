extends SceneTree

# Queue 30 DEBUG-CHEATS (reply 1, option A): scripts/worldmap/ui/worldmap_debug_cheats_controller.gd, a root child of
# WorldMap.tscn (worldmap_main.gd unchanged). Runs on the real WorldMap.tscn; cheats are called directly, and through
# real key events pushed into the viewport where the order asks for input checks.
# 1. ① fills every owned city's resource_stock and storage to WAREHOUSE_CAPACITY, the national stock is their sum,
#    and a city tech and a national tech no longer fail validate_start with insufficient_cost
# 2. ① leaves enemy cities alone
# 3. ② completes the selected tech with no resource change, keeps the active research slot, does not spread to other
#    cities; already completed / no selection / overlay closed change nothing; Ctrl+Shift+T reaches the controller
#    while the tech tree overlay is open
# 4. ③ shows every field with real values for an enemy city, city_intel unchanged; off restores; own city untouched;
#    the spy service _adapter is only filled when empty and the normal spy validation is unchanged
# 5. a non-debug simulation frees the controller in _ready; cheats and key input do nothing afterwards
# 6. the three keys collide with no other key use under scripts/worldmap/
# +  _player_state key set unchanged by all cheats (save format)

const WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"
const CONTROLLER_NODE := "WorldMapDebugCheatsController"
const CONTROLLER_SCRIPT := "res://scripts/worldmap/ui/worldmap_debug_cheats_controller.gd"
const OWN_CITY := "hanseong"
const INTEL_FIELDS := ["troops", "resources", "publicSupport", "loyalty", "governor", "tech"]
const CHEAT_KEYS := [KEY_G, KEY_T, KEY_I]
const CHEAT_KEY_NAMES := ["KEY_G", "KEY_T", "KEY_I"]
const VIEWPORT_SIZE := Vector2i(1920, 1080)

var _checks := 0
var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = VIEWPORT_SIZE
	# The F6 checklist starts from a new game (start city selected, national stock aggregated).
	_expect(bool(root.get_node("/root/GameSession").call("request_new_game", "player")), "new game requested (player / hanseong)")
	_expect(change_scene_to_file(WORLDMAP_SCENE_PATH) == OK, "WorldMap scene transition starts")
	for i in 6:
		await process_frame
	var main := current_scene
	_expect(main != null and main.scene_file_path == WORLDMAP_SCENE_PATH, "WorldMap scene loaded")
	if main == null:
		_finish()
		return
	var ctl := main.get_node_or_null(CONTROLLER_NODE)
	_expect(ctl != null and ctl.get("main") == main and bool(ctl.call("is_active")), "controller is a root child, found main, active in this debug build")
	_expect(OS.is_debug_build(), "test runs on a debug build")
	if ctl == null:
		_finish()
		return
	var state_keys_before := _player_state_keys(main)

	_check_keys()
	await _check_resources(main, ctl)
	await _check_tech(main, ctl)
	await _check_intel(main, ctl)
	_expect(_player_state_keys(main) == state_keys_before, "save format: _player_state key set unchanged by the cheats (%s)" % str(_diff_keys(state_keys_before, _player_state_keys(main))))
	await _check_disabled(main, ctl)
	_finish()


# ---- 6. keys ----

func _check_keys() -> void:
	var hits := []
	_scan_key_uses("res://scripts/worldmap", hits)
	_expect(hits.is_empty(), "6. KEY_G / KEY_T / KEY_I are used nowhere else under scripts/worldmap (%s)" % str(hits))
	_expect(CHEAT_KEYS == [int(load(CONTROLLER_SCRIPT).get_script_constant_map()["KEY_FILL_RESOURCES"]),
		int(load(CONTROLLER_SCRIPT).get_script_constant_map()["KEY_COMPLETE_TECH"]),
		int(load(CONTROLLER_SCRIPT).get_script_constant_map()["KEY_REVEAL_INTEL"])], "6. controller keys are G / T / I (with Ctrl+Shift)")


func _scan_key_uses(dir_path: String, hits: Array) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return
	for sub in dir.get_directories():
		_scan_key_uses(dir_path.path_join(sub), hits)
	for file_name in dir.get_files():
		if not file_name.ends_with(".gd") or file_name == "worldmap_debug_cheats_controller.gd":
			continue
		var text := FileAccess.get_file_as_string(dir_path.path_join(file_name))
		var regex := RegEx.new()
		regex.compile("\\b(KEY_G|KEY_T|KEY_I)\\b")
		for m in regex.search_all(text):
			hits.append("%s:%s" % [file_name, m.get_string()])


# ---- 1, 2. resources ----

func _check_resources(main: Node, ctl: Node) -> void:
	var capacity: Dictionary = main.get_script().get_script_constant_map()["WAREHOUSE_CAPACITY"]
	var owned: Array = ctl.call("get_owned_city_ids")
	_expect(owned.has(OWN_CITY), "player owns %s (%s)" % [OWN_CITY, str(owned)])
	var enemy := _find_enemy_city(main)
	_expect(not enemy.is_empty(), "an enemy city exists (%s)" % enemy)
	# Empty the player's stock first so that the tech start checks fail on cost before the cheat.
	for city_id in owned:
		var zero_storage := {}
		for resource_id in capacity.keys():
			main.call("_wounded_recovery_mutation", "set_city_resource_amount", [city_id, resource_id, 0])
			zero_storage[resource_id] = 0
		main.call("_set_city_storage", city_id, zero_storage)
	main.call("_rebuild_occupation_runtime_indexes_mvp")
	var city_tech := _find_cost_tech(main, "city", OWN_CITY)
	var national_tech := _find_cost_tech(main, "national", "")
	_expect(not city_tech.is_empty(), "1. a city tech fails on cost with an empty stock (%s)" % city_tech)
	_expect(not national_tech.is_empty(), "1. a national tech fails on cost with an empty stock (%s)" % national_tech)
	var enemy_stock_before: Dictionary = (_city(main, enemy).get("resource_stock", {}) as Dictionary).duplicate(true)
	var enemy_storage_before: Variant = _city(main, enemy).get("storage", null)
	enemy_storage_before = (enemy_storage_before as Dictionary).duplicate(true) if enemy_storage_before is Dictionary else null

	# Through a real key event (overlay closed).
	_push_key(KEY_G)
	await process_frame
	for city_id in owned:
		var stock: Dictionary = _city(main, city_id).get("resource_stock", {})
		var storage: Dictionary = _city(main, city_id).get("storage", {})
		var bad := []
		for resource_id in capacity.keys():
			if int(stock.get(resource_id, -1)) != int(capacity[resource_id]) or int(storage.get(resource_id, -1)) != int(capacity[resource_id]):
				bad.append("%s %s/%s" % [resource_id, str(stock.get(resource_id)), str(storage.get(resource_id))])
		_expect(bad.is_empty(), "1. Ctrl+Shift+G: %s resource_stock and storage = capacity (%s)" % [city_id, str(bad)])
	var national: Dictionary = (main.get("_player_state") as Dictionary).get("resource_stock", {})
	var bad_national := []
	for resource_id in capacity.keys():
		if int(national.get(resource_id, -1)) != int(capacity[resource_id]) * owned.size():
			bad_national.append("%s %s" % [resource_id, str(national.get(resource_id))])
	_expect(bad_national.is_empty(), "1. national resource_stock = sum of the owned cities (%s)" % str(bad_national))
	var service = main.call("_ensure_domestic_tech_research_service")
	var city_check: Dictionary = service.validate_start(city_tech, OWN_CITY) if not city_tech.is_empty() else {}
	var national_check: Dictionary = service.validate_start(national_tech, "") if not national_tech.is_empty() else {}
	_expect(str(city_check.get("reason", "")) != "insufficient_cost" and bool(city_check.get("ok", false)), "1. city tech %s can start after ① (%s)" % [city_tech, str(city_check.get("reason", ""))])
	_expect(str(national_check.get("reason", "")) != "insufficient_cost" and bool(national_check.get("ok", false)), "1. national tech %s can start after ① (%s)" % [national_tech, str(national_check.get("reason", ""))])
	_expect(str(main.get("_save_management_status")).begins_with("[디버그] 자원 채움"), "1. status line message (%s)" % str(main.get("_save_management_status")))
	# 2. enemy untouched
	_expect(_city(main, enemy).get("resource_stock", {}) == enemy_stock_before, "2. enemy %s resource_stock unchanged" % enemy)
	var enemy_storage_after: Variant = _city(main, enemy).get("storage", null)
	_expect(enemy_storage_after == enemy_storage_before or enemy_storage_before == null and not enemy_storage_after is Dictionary, "2. enemy %s storage unchanged" % enemy)
	# Pressing again keeps the values (fill, not toggle).
	ctl.call("fill_resources")
	_expect(int((_city(main, OWN_CITY).get("resource_stock", {}) as Dictionary).get("gold", 0)) == int(capacity["gold"]), "1. pressing again keeps the capacity values")


func _find_cost_tech(main: Node, scope: String, city_id: String) -> String:
	var catalog = main.call("_ensure_domestic_tech_catalog")
	var service = main.call("_ensure_domestic_tech_research_service")
	var definitions: Dictionary = catalog.get_city_definitions() if scope == "city" else catalog.get_national_definitions()
	var ids := definitions.keys()
	ids.sort()
	for tech_id_variant in ids:
		var result: Dictionary = service.validate_start(str(tech_id_variant), city_id)
		if str(result.get("reason", "")) == "insufficient_cost":
			return str(tech_id_variant)
	return ""


# ---- 3. tech ----

func _check_tech(main: Node, ctl: Node) -> void:
	var service = main.call("_ensure_domestic_tech_research_service")
	var catalog = main.call("_ensure_domestic_tech_catalog")
	var tree = main.call("_ensure_domestic_tech_tree_presentation_controller")
	# Overlay closed -> nothing.
	main.call("_close_domestic_tech_tree_overlay_mvp")
	var closed: Dictionary = ctl.call("complete_selected_tech")
	_expect(str(closed.get("reason", "")) == "overlay_closed", "3. overlay closed -> no change (%s)" % str(closed))

	# An active city research on one tech, then cheat-complete a different city tech.
	var ids: Array = catalog.get_city_definitions().keys()
	ids.sort()
	var active_tech := ""
	for tech_id_variant in ids:
		if bool(service.validate_start(str(tech_id_variant), OWN_CITY).get("ok", false)):
			active_tech = str(tech_id_variant)
			break
	_expect(not active_tech.is_empty(), "3. a city tech can start (%s)" % active_tech)
	var started: Dictionary = service.start_research(active_tech, OWN_CITY) if not active_tech.is_empty() else {}
	_expect(bool(started.get("ok", false)), "3. city research started on %s" % active_tech)
	var active_before: Dictionary = (service.get_city_active_research(OWN_CITY) as Dictionary).duplicate(true)
	var target := ""
	for tech_id_variant in ids:
		var tech_id := str(tech_id_variant)
		if tech_id != active_tech and not bool(service.get_city_completed_snapshot(OWN_CITY).get(tech_id, false)):
			target = tech_id
			break
	_expect(not target.is_empty(), "3. an uncompleted city tech to cheat (%s)" % target)

	main.call("_open_domestic_tech_tree_overlay_mvp")
	await process_frame
	_expect(bool(main.call("_is_domestic_tech_tree_overlay_open_mvp")), "3. tech tree overlay open")
	tree.call("_set_selected_domestic_tech_for_inspector_mvp", "", "")
	var none: Dictionary = ctl.call("complete_selected_tech")
	_expect(str(none.get("reason", "")) == "no_selection", "3. no selection -> no change (%s)" % str(none))

	tree.call("_set_selected_domestic_tech_for_inspector_mvp", target, OWN_CITY)
	var other_cities := []
	for city_id in (main.get_script().get_script_constant_map()["CITY_HUD_DATA"] as Dictionary).keys():
		if str(city_id) != OWN_CITY:
			other_cities.append(str(city_id))
	var others_before := {}
	for city_id in other_cities:
		others_before[city_id] = (service.get_city_completed_snapshot(city_id) as Dictionary).duplicate(true)
	var stock_before := _stock_snapshot(main)
	# Through a real key event while the overlay is open (order 2 [미확인] ②).
	_push_key(KEY_T)
	await process_frame
	_expect(bool(service.get_city_completed_snapshot(OWN_CITY).get(target, false)), "3. Ctrl+Shift+T with the overlay open completes %s (key reached the controller)" % target)
	_expect(_stock_snapshot(main) == stock_before, "3. no resource change")
	_expect(service.get_city_active_research(OWN_CITY) == active_before, "3. active research slot kept (%s)" % str(service.get_city_active_research(OWN_CITY)))
	var city_mirror: Dictionary = ((_city(main, OWN_CITY).get("city_tech", {}) as Dictionary).get("completed", {}) as Dictionary)
	_expect(bool(city_mirror.get(target, false)), "3. city_tech.completed mirror has %s" % target)
	var spread := []
	for city_id in other_cities:
		if service.get_city_completed_snapshot(city_id) != others_before[city_id]:
			spread.append(city_id)
	_expect(spread.is_empty(), "3. city tech did not spread to other cities (%s)" % str(spread))
	var again: Dictionary = ctl.call("complete_selected_tech")
	_expect(str(again.get("reason", "")) == "already_completed", "3. already completed -> no change (%s)" % str(again))

	# National scope: one national tech, no national research slot change.
	var national_ids: Array = catalog.get_national_definitions().keys()
	national_ids.sort()
	var national_target := ""
	for tech_id_variant in national_ids:
		if not bool(service.get_national_completed_snapshot().get(str(tech_id_variant), false)):
			national_target = str(tech_id_variant)
			break
	var national_active_before: Dictionary = (service.get_national_active_research() as Dictionary).duplicate(true)
	tree.call("_set_selected_domestic_tech_for_inspector_mvp", national_target, "")
	var national_result: Dictionary = ctl.call("complete_selected_tech")
	_expect(bool(national_result.get("ok", false)) and bool(service.get_national_completed_snapshot().get(national_target, false)), "3. national tech %s completed (%s)" % [national_target, str(national_result)])
	_expect(service.get_national_active_research() == national_active_before, "3. national active research slot kept")

	# Ctrl+Shift+Alt+T: every city tech of the selected city.
	tree.call("_set_selected_domestic_tech_for_inspector_mvp", target, OWN_CITY)
	var all_result: Dictionary = ctl.call("complete_all_techs_in_selected_scope")
	var missing := []
	for tech_id_variant in ids:
		if str(tech_id_variant) != active_tech and not bool(service.get_city_completed_snapshot(OWN_CITY).get(str(tech_id_variant), false)):
			missing.append(str(tech_id_variant))
	_expect(not bool(service.get_city_completed_snapshot(OWN_CITY).get(active_tech, false)), "3. complete-all skips the tech under active research (%s)" % active_tech)
	_expect(bool(all_result.get("ok", false)) and missing.is_empty(), "3. all city techs of %s completed (missing %s)" % [OWN_CITY, str(missing)])
	_expect(service.get_city_active_research(OWN_CITY) == active_before, "3. active research slot still kept after complete-all")
	main.call("_close_domestic_tech_tree_overlay_mvp")
	await process_frame


func _stock_snapshot(main: Node) -> Dictionary:
	var snap := {"national": ((main.get("_player_state") as Dictionary).get("resource_stock", {}) as Dictionary).duplicate(true)}
	for city_id in _owned(main):
		snap[city_id] = [(_city(main, city_id).get("resource_stock", {}) as Dictionary).duplicate(true), (_city(main, city_id).get("storage", {}) as Dictionary).duplicate(true)]
	return snap


# ---- 4. intel ----

func _check_intel(main: Node, ctl: Node) -> void:
	var enemy := _find_enemy_city(main)
	var presenter = main.call("_ensure_spy_presenter")
	var spy_controller = main.call("_ensure_spy_controller")
	var service = spy_controller.get("_service")
	var intel_before: Variant = ((main.get("_player_state") as Dictionary).get("city_intel", {}) as Dictionary).duplicate(true)
	var enemy_entry_before: Dictionary = presenter.get_city_intel_entry(enemy)
	var own_entry_before: Dictionary = presenter.get_city_intel_entry(OWN_CITY)
	var marker = (main.get("_city_markers_by_id") as Dictionary).get(enemy)
	var visibility_before := str(presenter.format_visibility_summary(marker)) if marker != null else ""
	var check_before: Dictionary = spy_controller.validate_spy_action("gather_info", enemy)
	# reply 1 §3: empty _adapter is filled with the spy controller; an existing one is kept.
	service.set("_adapter", null)

	_push_key(KEY_I)
	await process_frame
	_expect(bool(ctl.call("is_intel_reveal_on")), "4. Ctrl+Shift+I turns the reveal on")
	var entry: Dictionary = presenter.get_city_intel_entry(enemy)
	var fields: Array = entry.get("fields", [])
	var payload: Dictionary = entry.get("payload", {})
	_expect(fields == INTEL_FIELDS and not bool(entry.get("estimated", true)), "4. enemy %s entry has the six fields, not estimated (%s)" % [enemy, str(fields)])
	_expect(service.get("_adapter") == spy_controller, "4. empty spy service _adapter filled with the spy controller")
	_expect(int(payload.get("troops", -1)) == int(main.call("_get_city_troops_for_battle_context", enemy)) and not payload.has("troops_estimated"), "4. troops is the real value (%s)" % str(payload.get("troops")))
	var revealed: Array = presenter.get_revealed_field_ids(presenter.get_city_intel_fields(entry), presenter.get_city_intel_payload(entry))
	var expected_revealed := INTEL_FIELDS.duplicate()
	if str(payload.get("governor", "")) == "not_available":
		expected_revealed.erase("governor")
	_expect(revealed == expected_revealed, "4. presenter reveals %s (%s)" % [str(expected_revealed), str(revealed)])
	if marker != null:
		var visibility_on := str(presenter.format_visibility_summary(marker))
		_expect(visibility_on != visibility_before and not visibility_on.contains("미확인"), "4. visibility summary changes from 미확인")
	_expect(((main.get("_player_state") as Dictionary).get("city_intel", {}) as Dictionary) == intel_before, "4. city_intel unchanged (not written)")
	_expect(presenter.get_city_intel_entry(OWN_CITY) == own_entry_before, "4. own city entry unaffected")
	var check_on: Dictionary = spy_controller.validate_spy_action("gather_info", enemy)
	_expect(check_on == check_before, "4. normal spy validation unchanged with the reveal on")
	_expect(service.get("_adapter") == spy_controller, "4. normal spy call keeps the same _adapter")
	# An existing _adapter is not overwritten.
	var sentinel: Variant = spy_controller
	service.set("_adapter", sentinel)
	presenter.get_city_intel_entry(enemy)
	_expect(service.get("_adapter") == sentinel, "4. existing _adapter kept")

	_push_key(KEY_I)
	await process_frame
	_expect(not bool(ctl.call("is_intel_reveal_on")), "4. Ctrl+Shift+I again turns it off")
	_expect(presenter.get_city_intel_entry(enemy) == enemy_entry_before, "4. off -> enemy entry back to the original (%s)" % str(presenter.get_city_intel_entry(enemy)))
	if marker != null:
		_expect(str(presenter.format_visibility_summary(marker)) == visibility_before, "4. off -> visibility summary back to the original")
	_expect(((main.get("_player_state") as Dictionary).get("city_intel", {}) as Dictionary) == intel_before, "4. city_intel still unchanged")


# ---- 5. disabled ----

func _check_disabled(main: Node, ctl: Node) -> void:
	# Remove the scene's controller, then add one that simulates a non-debug build.
	main.remove_child(ctl)
	ctl.free()
	var disabled: Node = load(CONTROLLER_SCRIPT).new()
	disabled.set("enabled_override", 0)
	main.add_child(disabled)
	_expect(disabled.is_queued_for_deletion(), "5. non-debug simulation: _ready queues the controller for deletion")
	_expect(not bool(disabled.call("is_active")) and disabled.get("main") == null, "5. non-debug simulation: inactive, no main")
	var before := _stock_snapshot(main)
	var r1: Dictionary = disabled.call("fill_resources")
	var r2: Dictionary = disabled.call("complete_selected_tech")
	var r3: Dictionary = disabled.call("set_intel_reveal", true)
	_expect(str(r1.get("reason", "")) == "inactive" and str(r2.get("reason", "")) == "inactive" and not bool(r3.get("ok", true)), "5. ①②③ do nothing (%s %s %s)" % [str(r1), str(r2), str(r3)])
	await process_frame
	_expect(not is_instance_valid(disabled), "5. the controller is gone after one frame")
	_expect(main.get_node_or_null(CONTROLLER_NODE) == null, "5. no cheat controller left under main")
	# Zero one stock value, then press the keys: nothing may happen.
	main.call("_wounded_recovery_mutation", "set_city_resource_amount", [OWN_CITY, "gold", 7])
	main.call("_rebuild_occupation_runtime_indexes_mvp")
	var intel_before: Variant = ((main.get("_player_state") as Dictionary).get("city_intel", {}) as Dictionary).duplicate(true)
	for key in CHEAT_KEYS:
		_push_key(key)
		await process_frame
	_expect(int((_city(main, OWN_CITY).get("resource_stock", {}) as Dictionary).get("gold", -1)) == 7, "5. Ctrl+Shift+G without a controller changes nothing")
	_expect(((main.get("_player_state") as Dictionary).get("city_intel", {}) as Dictionary) == intel_before, "5. intel unchanged")
	var presenter = main.call("_ensure_spy_presenter")
	_expect(not (presenter.get("debug_intel_provider") as Callable).is_valid(), "5. presenter has no debug provider")
	_expect(before.size() > 0, "5. snapshot taken")


# ---- helpers ----

func _push_key(keycode: int, alt := false) -> void:
	for pressed in [true, false]:
		var ev := InputEventKey.new()
		ev.keycode = keycode as Key
		ev.physical_keycode = keycode as Key
		ev.ctrl_pressed = true
		ev.shift_pressed = true
		ev.alt_pressed = alt
		ev.pressed = pressed
		root.push_input(ev)


func _owned(main: Node) -> Array:
	var ctl := main.get_node_or_null(CONTROLLER_NODE)
	return ctl.call("get_owned_city_ids") if ctl != null else [OWN_CITY]


func _find_enemy_city(main: Node) -> String:
	var player := str(main.call("_get_current_player_faction_id"))
	var ids: Array = (main.get_script().get_script_constant_map()["CITY_HUD_DATA"] as Dictionary).keys()
	ids.sort()
	for city_id_variant in ids:
		var city_id := str(city_id_variant)
		var owner := str(main.call("_get_city_owner_faction_id_for_trade_display", city_id))
		if not owner.is_empty() and owner != player:
			return city_id
	return ""


func _city(main: Node, city_id: String) -> Dictionary:
	return main.call("_get_city_hud_entry", city_id)


func _player_state_keys(main: Node) -> Array:
	var keys := (main.get("_player_state") as Dictionary).keys()
	keys.sort()
	return keys


func _diff_keys(a: Array, b: Array) -> Array:
	var diff := []
	for k in a:
		if not b.has(k):
			diff.append("-%s" % str(k))
	for k in b:
		if not a.has(k):
			diff.append("+%s" % str(k))
	return diff


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)
		push_error("[DEBUG_CHEATS] FAIL: %s" % message)


func _finish() -> void:
	print("[DEBUG_CHEATS] checks=%d failures=%s" % [_checks, str(_failures)])
	quit(0 if _failures.is_empty() else 1)
