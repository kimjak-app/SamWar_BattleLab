extends SceneTree
# Queue 35: the Hansando naval scenario (scenes/battle3d/Battle3D_NavalHansando.tscn) on the 3D battle shell.
# 1 scene loads: ten ships (5 + 5), the scenario's heroes, types, troops, cells; every hero id is in the hero data.
# 2 each ship type moves as far as the naval rules file says (reachable cells against an own flood).
# 3 island cells are blocked for the engine; both fleets can reach each other.
# 4 each type's attack goes to its weapons' effects (cannon / arrow / gun), in the rule's order.
# 5 a ship without troops sinks; the battle gets a result.
# 6 no GLB delivered: stand-in models, no error. A delivered model would be fitted to the ship length.
# 7 the battle plays to its end on auto (Hakikjin cast at least once, reaching 3 cells: battle_type naval).
# 8 without the naval setting nothing changes: the shell's default, the land board, the land unit models.
const SCENE := "res://scenes/battle3d/Battle3D_NavalHansando.tscn"
const SCENARIO := "res://data/battle3d/naval_hansando_scenario.json"
const RULES := "res://data/battle3d/naval_unit_type_rules.json"
const Board := preload("res://scripts/battle3d/lab_heightfield.gd")
const Naval := preload("res://scripts/battle/services/battle_setup_naval_service.gd")
const NavalScenario := preload("res://scripts/battle3d/naval/battle3d_naval_scenario.gd")
const ShipVisuals := preload("res://scripts/battle3d/naval/battle3d_ship_visuals.gd")
const Overlay := preload("res://scripts/battle3d/naval/battle3d_naval_overlay.gd")
const HeroData := preload("res://scripts/worldmap/hero_definition_registry.gd")
const TYPE_NAMES := {"turtle_ship":"거북선", "panokseon":"판옥선", "atakebune":"안택선", "sekibune":"관선"}
const WEAPON_KINDS := {"cannon":"cannon", "arrow":"arrow", "gun":"shot"}
var checks := 0
var failures: Array[String] = []

func _initialize() -> void:
	run.call_deferred()

func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)
		printerr("[NAVAL_HANSANDO] FAIL ", label)

func cell_of(value) -> Vector2i:
	return Vector2i(int(value[0]), int(value[1]))

func flood(start: Vector2i, steps: int, blocked: Dictionary) -> Dictionary:
	var seen := {start: 0}
	var queue := [start]
	while not queue.is_empty():
		var cell: Vector2i = queue.pop_front()
		if steps >= 0 and seen[cell] >= steps: continue
		for step in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var next: Vector2i = cell + step
			if next.x < 0 or next.y < 0 or next.x >= 18 or next.y >= 10 or blocked.has(next) or seen.has(next): continue
			seen[next] = seen[cell] + 1
			queue.append(next)
	return seen

func frames(count: int) -> void:
	for i in range(count): await process_frame

func run() -> void:
	root.size = Vector2i(1280, 800)
	var scenario: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(SCENARIO))
	var rules := {}
	for entry in JSON.parse_string(FileAccess.get_file_as_string(RULES)).unit_types: rules[entry.unit_type] = entry
	var islands := {}
	for cell in NavalScenario.island_cells(scenario): islands[cell_of(cell)] = true
	expect(islands.size() >= 10 and islands.size() <= 18, "the play area has 10-18 island cells (%d)" % islands.size())
	for ship in scenario.ships:
		expect(HeroData.HERO_DATA.has(ship.hero_id) and not HeroDesignDataRegistry.get_battle_profile(ship.hero_id).is_empty(), "hero %s is in the hero data" % ship.hero_id)
		expect(rules.has(ship.unit_type) and not islands.has(cell_of(ship.grid_cell)), "%s: a ship type, on a sea cell" % ship.hero_id)
		expect(not ResourceLoader.exists(ShipVisuals.MODEL_PATH % ship.unit_type), "no delivered model for %s yet (this run checks the stand-ins)" % ship.unit_type)

	# 1: the scene.
	var shell: Node = (load(SCENE) as PackedScene).instantiate()
	root.add_child(shell)
	await process_frame
	var lab: Node = shell.lab
	expect(lab != null and shell.scenario == "naval" and not shell.start_panel.visible and not Engine.has_meta("samwar_battle_setup"), "the naval scene opens its lab at once (no start panel, setup meta consumed)")
	while not lab.ready_for_input: await process_frame
	await physics_frame
	await frames(3)
	var engine: Node = lab.engine
	var visuals = lab.unit_visuals
	expect(visuals is ShipVisuals and lab.get_node_or_null("NavalOverlay") != null, "ship models and the naval overlay are in the lab")
	expect(lab.find_child("Sea", true, false) != null and lab.find_child("Terrain", true, false) != null and lab.find_child("RiverWaterPlane", true, false) == null, "the sea board is built (no land ground)")
	expect(lab.board.terrain(Vector2i(0, 0)) == "sea" and lab.board.terrain(Vector2i(5, 1)) == "island" and is_zero_approx(lab.board.world(Vector2i(0, 0)).y) and lab.board.world(Vector2i(5, 1)).y > 0.5, "board: sea at height 0, islands above it")
	expect(Naval.battle_type(engine, engine.worldmap_battle_context) == "naval" and engine.worldmap_battle_context.is_empty(), "engine battle_type naval, no worldmap context")
	var by_hero := {}
	var sides := {"ally":0, "enemy":0}
	var occupied := {}
	for unit in engine.all_battle_unit_states:
		if not engine.call("_is_unit_state_available_for_battle_slot", unit): continue
		by_hero[String(engine.call("_get_hero_id_for_unit_state", unit))] = unit
		sides[unit.side] += 1
		occupied[unit.grid_cell] = unit.unit_id
	expect(sides == {"ally":5, "enemy":5} and occupied.size() == 10 and lab.current_round == 1, "ten ships on the board in round 1: %s" % str(sides))
	for ship in scenario.ships:
		var unit: BattleUnitState = by_hero.get(ship.hero_id)
		if unit == null:
			expect(false, "%s is on the board" % ship.hero_id)
			continue
		var id: String = unit.unit_id
		expect(unit.side == ship.side and unit.unit_type == ship.unit_type and unit.grid_cell == cell_of(ship.grid_cell) and unit.facing == ship.facing and unit.current_troops == int(ship.troops) and unit.max_troops == int(ship.troops),
			"%s: %s %s at %s facing %s, troops %d" % [ship.hero_id, unit.side, unit.unit_type, str(unit.grid_cell), unit.facing, unit.current_troops])
		expect(lab.views.has(id) and lab.views[id].visible and lab.views[id].has_meta("unit3d") and lab.soldiers[id].size() == 1 and visuals.model_sources.get(id) == "placeholder",
			"%s: one stand-in ship model, shown" % ship.hero_id)
		expect(lab.views[id].position.distance_to(lab.board.world(unit.grid_cell)) < 0.01 and absf(lab.soldiers[id][0].global_position.y - 0.035) < 0.01, "%s: the ship floats on its cell" % ship.hero_id)
		expect(lab.hud_unit_type_name(unit.unit_type) == TYPE_NAMES[unit.unit_type] and lab.hud_troop_icon(id) == null and lab.hud_portrait(id) != null and lab.hud_display_name(id) == HeroData.HERO_DATA[ship.hero_id].display_name,
			"%s: HUD name %s, type %s, portrait, no troop icon" % [ship.hero_id, lab.hud_display_name(id), lab.hud_unit_type_name(unit.unit_type)])
		var box := AABB()
		for mesh in lab.soldiers[id][0].find_children("*", "MeshInstance3D", true, false): box = box.merge(lab.soldiers[id][0].global_transform.affine_inverse() * mesh.global_transform * mesh.get_aabb())
		expect(box.size.x <= box.size.z and absf(box.size.z - float(rules[unit.unit_type].ship_length)) <= 0.05, "%s: the ship is its type's length, inside one 3 m cell (%.2f x %.2f m)" % [ship.hero_id, box.size.x, box.size.z])
	var cards: Array = shell.ally_cards() + shell.enemy_cards()
	expect(cards.size() == 10 and cards.all(func(card): return card.visible and TYPE_NAMES.values().has(card.type_name) and card.troop_icon == null and card.portrait != null), "roster cards: ten, ship type names, portraits, no troop icons")
	var actor: Dictionary = shell.current_actor()
	expect(actor.is_empty() or TYPE_NAMES.values().has(actor.type_name), "current actor panel shows a ship type")
	await frames(2)
	var overlay: Node = lab.get_node("NavalOverlay")
	expect(overlay.title_label.text == "한산도 대첩" and overlay.title_label.visible, "title under the top HUD: %s" % overlay.title_label.text)

	# 2 + 3: movement and islands.
	expect(lab.forest_cells().size() == islands.size() and lab.forest_cells().all(func(cell): return islands.has(cell) and engine.battle_grid_controller.is_blocked(cell)), "the engine's blocked cells are the island cells")
	var seen_types := {}
	for ship in scenario.ships:
		var unit: BattleUnitState = by_hero.get(ship.hero_id)
		if unit == null: continue
		var block := islands.duplicate()
		for cell in occupied:
			if occupied[cell] != unit.unit_id: block[cell] = true
		var result: Dictionary = lab.queries.query(unit.unit_id, unit.grid_cell)
		var want := flood(unit.grid_cell, int(rules[unit.unit_type].move_range), block)
		expect(int(result.budget) == int(rules[unit.unit_type].move_range) and result.reachable.size() == want.size() and result.reachable.keys().all(func(cell): return not islands.has(cell)),
			"%s (%s): move %d, %d reachable cells (own flood %d), none on an island" % [ship.hero_id, unit.unit_type, int(result.budget), result.reachable.size(), want.size()])
		seen_types[unit.unit_type] = true
		var open := flood(unit.grid_cell, -1, islands)
		var foes := 0
		for other in by_hero.values():
			if other.side != unit.side and open.has(other.grid_cell): foes += 1
		expect(foes == 5, "%s can sail to all five enemy ships" % ship.hero_id)
	expect(seen_types.size() == 4, "all four ship types are in the scenario")
	for cell in islands:
		var to_island: Dictionary = lab.queries.query(by_hero["yi_sun_sin"].unit_id, cell)
		expect(not to_island.can_preview and to_island.path.is_empty() and not to_island.reachable.has(cell), "island %s: no path, no move preview" % str(cell))

	# 4: each type's weapons, by the lab's own attack call.
	var target_id: String = by_hero["kato_kiyomasa"].unit_id
	for hero in ["yi_sun_sin", "kim_deok_ryeong", "kato_kiyomasa", "konishi_yukinaga"]:
		var unit: BattleUnitState = by_hero[hero]
		var foe: String = target_id if unit.side == "ally" else String(by_hero["yi_sun_sin"].unit_id)
		visuals.records.clear()
		visuals.cannon.stop_all()
		visuals.fx.stop_all()
		visuals.attack(lab, unit.unit_id, foe)
		visuals.hit(lab, unit.unit_id, foe)
		await create_timer(2.2).timeout
		var weapons: Array = rules[unit.unit_type].weapons
		expect(visuals.records.map(func(r): return r.weapon) == weapons and visuals.records.all(func(r): return r.attacker_id == unit.unit_id and r.target_id == foe and r.unit_type == unit.unit_type),
			"%s attack: weapons %s in order" % [unit.unit_type, str(weapons)])
		var kinds := {}
		for record in visuals.cannon.records + visuals.fx.records: kinds[record.kind] = int(kinds.get(record.kind, 0)) + 1
		var want_kinds := {}
		for weapon in weapons: want_kinds[WEAPON_KINDS[weapon]] = true
		expect(kinds.keys().all(func(kind): return want_kinds.has(kind)) and want_kinds.keys().all(func(kind): return int(kinds.get(kind, 0)) >= 3),
			"%s attack: effects %s (wanted %s)" % [unit.unit_type, str(kinds), str(want_kinds.keys())])
	await create_timer(1.5).timeout
	expect(visuals.cannon.effect_count() == 0 and visuals.fx.effect_count() == 0, "the effects clean themselves up (%d + %d left)" % [visuals.cannon.effect_count(), visuals.fx.effect_count()])

	# 6: a delivered model is fitted to the ship length whatever its size and direction.
	var model := Node3D.new()
	var hull := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(40, 6, 10) # sideways and far too big
	hull.mesh = mesh
	hull.position = Vector3(3, 3, -2)
	model.add_child(hull)
	var fitted: Vector2 = ShipVisuals.fit_model(model, 2.6)
	var fitted_box: AABB = ShipVisuals.model_box(model, Transform3D())
	expect(absf(fitted_box.size.z - 2.6) < 0.001 and absf(fitted_box.size.x - 0.65) < 0.001 and absf(fitted_box.get_center().x) < 0.001 and absf(fitted_box.get_center().z) < 0.001 and absf(fitted.x - 0.65) < 0.001,
		"a delivered model: 2.6 m long along Z, centred (%s)" % str(fitted_box))
	model.free()

	# Capture: the file name, and a call that never fails (a headless run has no picture: "").
	expect(Overlay.capture_path("C:/x", false, {"year":2026, "month":11, "day":10, "hour":9, "minute":5, "second":7}, 12345) == "C:/x/hansando_20261110_090507_345.png"
		and Overlay.capture_path("C:/x", true, {"year":2026, "month":11, "day":10, "hour":9, "minute":5, "second":7}, 1).ends_with("_001_nohud.png"), "capture file names")
	var before: int = overlay.captures.size()
	var saved: String = await overlay.capture(true)
	expect(not overlay.capturing and ((saved.is_empty() and overlay.captures.size() == before) or FileAccess.file_exists(saved)), "capture call returns (%s)" % ("no picture" if saved.is_empty() else saved))
	if not saved.is_empty(): DirAccess.remove_absolute(saved)

	# 7: Hakikjin through the lab's own skill command. Test arrangement only (direct state writes): momentum for the
	# cost, one enemy 3 cells from Yi Sun-sin (the target) and one 3 cells from that target (inside the sea radius 3,
	# outside the land radius 2).
	var yi: BattleUnitState = by_hero["yi_sun_sin"]
	var yi_id: String = yi.unit_id
	var near: BattleUnitState = by_hero["kuroda_nagamasa"]
	var far: BattleUnitState = by_hero["honda_tadakatsu"]
	for placed in [[near, Vector2i(8, 4)], [far, Vector2i(11, 4)]]:
		placed[0].set_grid_cell(placed[1])
		engine.call("_sync_resumed_unit_markers_to_grid", placed[0])
	engine.battle_momentum.gain("ally", 5, "test arrangement")
	engine.call("_select_ally_unit", yi, false, false, false)
	await frames(3)
	var skill: Dictionary = lab.hud_unique_skill(yi_id)
	expect(String(skill.get("skill_id", "")) == "yi_sun_sin_unique" and lab.hud_skill_ready(yi_id) and lab._skill_block_reason() == "", "Hakikjin is ready for Yi Sun-sin (%s)" % lab._skill_block_reason())
	var troops_before := {near.unit_id: near.current_troops, far.unit_id: far.current_troops}
	lab.request_skill()
	await frames(2)
	if engine.current_phase == "unique_skill_target_select": lab._click_skill_cell(Vector2i(8, 4))
	var skill_started := Time.get_ticks_msec()
	while Time.get_ticks_msec() - skill_started < 60000 and (lab.hud_skill_casts.is_empty() or lab._presentation_busy() or lab.hud_cutin_hold or engine.current_phase != "ally_turn" or engine.is_demo_animating):
		await process_frame
	var yi_casts: Array = engine.tactic_event_log.export().filter(func(e): return e.kind == "skill_cast" and String(e.get("caster_id", e.get("unit_id", ""))) == yi_id)
	expect(yi_casts.size() == 1 and lab.hud_skill_casts.size() >= 1, "Yi Sun-sin cast Hakikjin once (%d cast event, %d shown)" % [yi_casts.size(), lab.hud_skill_casts.size()])
	expect(near.current_troops < troops_before[near.unit_id] and far.current_troops < troops_before[far.unit_id], "Hakikjin hit the target and the ship 3 cells from it (sea radius 3): %d->%d, %d->%d" % [
		troops_before[near.unit_id], near.current_troops, troops_before[far.unit_id], far.current_troops])

	# 5 + 7: the rest of the battle on auto.
	lab.cycle_speed()
	lab.cycle_speed()
	visuals.records.clear()
	lab.request_auto()
	expect(engine.is_full_auto_battle_enabled, "auto accepted")
	var started := Time.get_ticks_msec()
	while lab.battle_result.is_empty() and Time.get_ticks_msec() - started < 240000:
		await process_frame
	var ended := Time.get_ticks_msec() # the result panel comes after the shell's ending toast, however long a frame takes
	while not shell.result_panel.visible and Time.get_ticks_msec() - ended < 60000: await process_frame
	await frames(30)
	expect(not lab.battle_result.is_empty() and ["victory", "defeat"].has(lab.battle_result), "the battle ends on auto: %s in round %d (%.0f s)" % [lab.battle_result, lab.current_round, (Time.get_ticks_msec() - started) / 1000.0])
	expect(shell.result_panel.visible and not shell.choose_button.visible and shell.restart_button.visible, "result panel: restart only (%s)" % shell.result_text)
	expect(visuals.records.size() >= 10 and visuals.records.all(func(r): return (rules[r.unit_type].weapons as Array).has(r.weapon)), "%d weapon effects during the battle, each from its ship type's weapons" % visuals.records.size())
	var dead := []
	for unit in engine.all_battle_unit_states:
		if unit.current_troops <= 0: dead.append(unit.unit_id)
	expect(dead.size() >= 1 and dead.all(func(id): return visuals.sink_records.has(id) and not lab.soldiers[id][0].visible), "%d ship(s) lost, each sank and is hidden (%s)" % [dead.size(), str(visuals.sink_records)])
	expect(visuals.cannon.records.any(func(r): return r.kind == "sink_smoke"), "sinking smoke was shown")

	# Restart: a fresh naval battle; then closing: the land board is back.
	shell.restart_button.pressed.emit()
	await process_frame
	lab = shell.lab
	while not lab.ready_for_input: await process_frame
	expect(shell.lab_count == 2 and lab.unit_visuals is ShipVisuals and lab.battle_result.is_empty() and Board.source_paths.get("heightfield", "") == scenario.heightfield, "restart: a new naval lab")
	shell._close_lab()
	shell.free()
	await process_frame

	# 8: without the naval setting.
	expect(Board.source_paths.is_empty() and Board.new().terrain(Vector2i(0, 0)) != "sea" and Board.new().data.board.river_center == 28.0, "closed: heightfields read the land board again")
	var land_shell: Node = load("res://scenes/battle3d/Battle3D_ScenarioShell.tscn").instantiate()
	root.add_child(land_shell)
	await process_frame
	expect(land_shell.naval_scenario_path == "" and land_shell.lab == null and land_shell.start_panel.visible, "land shell: start panel, no lab, no naval scenario")
	land_shell.scenario_buttons["default"].pressed.emit()
	await process_frame
	lab = land_shell.lab
	while not lab.ready_for_input: await process_frame
	expect(lab.field_script == "" and lab.unit_visuals_script == "res://scripts/battle3d/battle3d_unit_visuals.gd" and not (lab.unit_visuals is ShipVisuals) and lab.get_node_or_null("NavalOverlay") == null
		and lab.find_child("Sea", true, false) == null, "land lab: land ground, land unit models, no naval node")
	expect(not lab.engine.has_meta(Naval.META_BATTLE_TYPE) and Naval.battle_type(lab.engine, lab.engine.worldmap_battle_context) == "land" and lab.forest_cells().size() > 0
		and lab.engine.all_battle_unit_states.all(func(unit): return UnitTypeContract.CANONICAL_UNIT_TYPES.has(unit.unit_type)), "land lab: battle_type land, forest cells, land unit types")
	expect(land_shell.choose_button != null and lab.hud_unit_type_name("archer") == "궁병" and lab.hud_unit_type_name("nothing") == "부대", "land lab: unit type names as before")
	land_shell._close_lab()
	land_shell.free()
	await process_frame

	print("[NAVAL_HANSANDO] checks=", checks, " failures=", failures)
	quit(0 if failures.is_empty() else 1)
