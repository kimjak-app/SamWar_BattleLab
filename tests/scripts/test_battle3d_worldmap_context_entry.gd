extends SceneTree
# M7-1: the 3D shell starts straight from a worldmap battle context. The context comes from the real WorldMap builder
# for a player attack (_build_player_attack_battle_context) plus the fields _confirm_player_attack_deployment adds; no
# departure, snapshot or handoff runs, so no camera handoff or scene change can happen (locally or in CI).
# 출정 확인 전체 흐름(비용 차감·스냅샷·핸드오프)은 `test_worldmap_battle_main_roundtrip_settlement`가 다룬다. 여기서는 셸이 받는 문맥 모양만 실제 빌더로 만든다.
# The shell
# must skip the start panel, never set a scenario setup, leave the context meta to the engine (consumed) and show the
# context's units in the 3D lab. Without the meta the start panel comes first; a broken context goes back to it.
const CONTEXT_KEY := "samwar_worldmap_battle_context"
const SETUP_KEY := "samwar_battle_setup"
const WORLDMAP_SCENE := "res://WorldMap.tscn" # the scene the context comes from and returns to
const SOURCE_CITY := "hanseong"
const TARGET_CITY := "pyeongyang"
var h
var checks := 0
var failures: Array = []


func _initialize() -> void:
	run.call_deferred()


func expect(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)
		push_error("[BATTLE3D_CONTEXT_ENTRY_FAIL] " + label)


func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	var context: Dictionary = await real_worldmap_context()
	expect(not context.is_empty(), "the real WorldMap built a player attack context")
	expect(not Engine.has_meta(CONTEXT_KEY) and current_scene == null, "no handoff happened while getting it (no meta, no scene change)")
	if context.is_empty():
		await finish()
		return

	# 1. Context mode. A stale setup meta is left on purpose: context mode must drop it, never hand it to the engine.
	Engine.set_meta(SETUP_KEY, {"unit_overrides": {"yi_sun_sin_battle_unit": {"troops_ratio": 0.25}}})
	Engine.set_meta(CONTEXT_KEY, context.duplicate(true))
	await open_shell()
	var shell: Node = h.shell
	expect(shell.lab != null and shell.worldmap_context_mode, "context present: the shell starts the lab in context mode")
	expect(not shell.start_panel.visible and not shell.result_panel.visible, "context mode: no start panel")
	expect(not Engine.has_meta(CONTEXT_KEY), "the context meta was consumed (by the engine)")
	expect(not Engine.has_meta(SETUP_KEY), "context mode leaves no setup meta")
	expect(not shell.restart_button.visible and not shell.choose_button.visible, "context mode hides the new battle / scenario buttons")
	if shell.lab == null:
		await h.close_shell(self)
		await finish()
		return
	await h.wait_lab(self)
	var lab: Node = h.lab
	var engine: Node = lab.engine
	expect(str(engine.worldmap_battle_context.get("transaction_id", "")) == str(context.transaction_id), "the engine inside the 3D lab holds the context (same transaction id)")
	compare_side(lab, context, "attacker", "ally")
	compare_side(lab, context, "defender", "enemy")
	var count_before: int = shell.lab_count
	shell.restart()
	expect(shell.lab_count == count_before and shell.lab == lab, "restart does nothing in context mode (the context is consumed)")
	await h.close_shell(self)

	# 2. No context: the start panel, exactly as before.
	await open_shell()
	expect(h.shell.lab == null and h.shell.start_panel.visible and not h.shell.worldmap_context_mode, "no context: start panel first, no lab")
	expect(h.shell.restart_button.visible and h.shell.choose_button.visible, "no context: result buttons stay")
	await h.press_scenario(self, "default")
	expect(not h.shell.worldmap_context_mode and h.lab.engine.worldmap_battle_context.is_empty(), "scenario start is not context mode")
	await h.close_shell(self)

	# 3. Broken contexts: back to the start panel, no crash, nothing left behind.
	var missing_heroes := context.duplicate(true)
	for side in ["attacker", "defender"]:
		for key in ["_hero_ids", "_heroes", "_governor_id"]: missing_heroes.erase(side + key)
	for broken in [{"name": "empty dictionary", "value": {}}, {"name": "hero keys missing", "value": missing_heroes}]:
		Engine.set_meta(CONTEXT_KEY, broken.value)
		await open_shell()
		expect(h.shell.lab == null and h.shell.start_panel.visible and not h.shell.worldmap_context_mode, "%s: back to the start panel" % broken.name)
		expect(not Engine.has_meta(CONTEXT_KEY) and not Engine.has_meta(SETUP_KEY), "%s: no meta left" % broken.name)
		expect(h.shell.restart_button.visible and h.shell.choose_button.visible, "%s: start panel buttons usable again" % broken.name)
		await h.close_shell(self)
	await finish()


func open_shell() -> void:
	# The harness's open_shell without its setup clean-up (the stale-setup check needs the meta to reach the shell).
	root.size = Vector2i(1280, 800)
	h.shell = h.SpyShell.new()
	h.shell.test_world = h.test_world
	root.add_child(h.shell)
	await process_frame


func compare_side(lab: Node, context: Dictionary, context_side: String, lab_side: String) -> void:
	# Units the 3D lab shows on one side == the context's heroes on that side, each with its troop_composition value.
	var composition: Dictionary = context.get(context_side + "_troop_composition", {})
	var expected := {}
	for hero_id in context.get(context_side + "_hero_ids", []): expected["%s_battle_unit" % hero_id] = int(composition.get(hero_id, -1))
	# Reinforcement slots (the engine's "_reinforce_" slots) are not deployed at the start: their units exist with the
	# context troops and stay hidden in 3D until they arrive, as the engine decides (the lab's own visibility rule).
	var units := {}
	var shown := []
	lab._sync_views()
	for unit in lab.engine.all_battle_unit_states:
		if unit.side != lab_side: continue
		units[unit.unit_id] = unit
		if lab.views.has(unit.unit_id) and lab.views[unit.unit_id].visible: shown.append(unit.unit_id)
	expect(not shown.is_empty() and shown.all(func(id): return expected.has(id)), "%s: the 3D lab shows only context units %s (context %s)" % [lab_side, str(shown), str(expected)])
	for unit_id in expected:
		var unit = units.get(unit_id)
		expect(unit != null, "%s: %s is in the engine" % [lab_side, unit_id])
		if unit == null: continue
		expect(int(unit.current_troops) == expected[unit_id], "%s: %s troops %d == context %d" % [lab_side, unit_id, int(unit.current_troops), expected[unit_id]])
		var deployed: bool = lab.engine._is_unit_state_available_for_battle_slot(unit)
		expect(shown.has(unit_id) == deployed, "%s: %s shown in 3D == deployed by the engine (%s)" % [lab_side, unit_id, str(deployed)])


func real_worldmap_context() -> Dictionary:
	var worldmap: Node = load(WORLDMAP_SCENE).instantiate()
	root.add_child(worldmap)
	await process_frame
	await process_frame
	var hero_ids: Array = worldmap.call("_get_available_player_attack_main_hero_ids", SOURCE_CITY)
	if hero_ids.is_empty():
		worldmap.free()
		return {}
	var hero_id := str(hero_ids[0])
	var supply: Dictionary = worldmap.call("_calculate_player_attack_supply_cost", 1)
	var food := maxi(0, int(supply.get("food", 0)))
	var food_type := ""
	for candidate in ["rice", "barley", "seafood"]:
		if food_type.is_empty() and int(worldmap.call("_get_city_supply_resource_amount", SOURCE_CITY, candidate)) >= food: food_type = candidate
	var gold := maxi(0, int(supply.get("gold", 0)))
	var salt := maxi(0, int(supply.get("salt", 0)))
	var selected: Array[String] = [hero_id]
	var supply_cost := {"food_type": food_type, "food": food, "gold": gold, "salt": salt, food_type: food}
	var context: Dictionary = (worldmap.call("_build_player_attack_battle_context", SOURCE_CITY, TARGET_CITY, "manual", selected, {hero_id: 1}, supply_cost) as Dictionary).duplicate(true)
	if not context.is_empty():
		# The fields _confirm_player_attack_deployment adds after the builder (same names).
		context["attacker_total_allocated_troops"] = 1
		context["attacker_source_city_id"] = SOURCE_CITY
		context["transaction_id"] = "t-test-1"
		context["scenario_id"] = str(worldmap.get("_player_state").get("active_scenario_id", "korea_mvp"))
		context["player_faction_id"] = str(worldmap.call("_get_current_player_faction_id"))
		context["result_return_destination"] = WORLDMAP_SCENE
	worldmap.free()
	await process_frame
	return context


func finish() -> void:
	if Engine.has_meta(CONTEXT_KEY): Engine.remove_meta(CONTEXT_KEY)
	if Engine.has_meta(SETUP_KEY): Engine.remove_meta(SETUP_KEY)
	print("[BATTLE3D_CONTEXT_ENTRY] checks=%d failures=%s" % [checks, str(failures)])
	var code := 0 if failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
