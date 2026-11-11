extends SceneTree
# Queue 35: the Hansando naval scenario (scenes/battle3d/Battle3D_NavalHansando.tscn) on the 3D battle shell.
# 1 scene loads: ten ships (5 + 5), the scenario's heroes, types, troops, cells; every hero id is in the hero data.
# 2 each ship type moves as far as the naval rules file says (reachable cells against an own flood).
# 3 island cells are blocked for the engine; both fleets can reach each other.
# 4 each type's attack goes to its weapons' effects (cannon / arrow / gun), in the rule's order.
# 5 a ship without troops sinks; the battle gets a result.
# 6 the delivered ship models (reply 3): each type's GLB by the rule's model_path, fitted by its Hull to the ship
#   length, its WaterLine on the sea, sails furled at rest and open with the oars rowing while it moves, each ship's
#   own sail colour. With the model_path taken out (a restart at the end): stand-in models, no error.
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
const RIVER_SHADER := "res://scripts/battle3d/eastwar_terrain_20x20_water.gdshader"
const RIVER_SHADER_SHA256 := "f255d007614e13c4be1cef3e76c610ada1b660f0aa719b4e1755a213e938fa2e" # main 8cc0640 (LF)
const TYPE_NAMES := {"turtle_ship":"거북선", "panokseon":"판옥선", "atakebune":"안택선", "sekibune":"관선"}
const WEAPON_KINDS := {"cannon":"cannon", "arrow":"arrow", "gun":"shot"}
const MODEL_DIR := "res://assets/battle3d/naval/"
# Reply 3 section 0: the delivered files (sha256, first 12 hex digits). The two Chinese ships have no type yet.
const MODEL_SHA256 := {"panokseon_game_v2.glb":"4144db4aedf5", "geobukseon_game_v2.glb":"ae40107222d5", "jp_atakebune_game_v1.glb":"0a5ea4b13fa2",
	"jp_sekibune_game_v1.glb":"47c30e6417cf", "cn_mengchong_game_v1.glb":"63edba268e13", "cn_doujian_game_v1.glb":"7aff0405278f"}
const TYPE_MODELS := {"turtle_ship":"geobukseon_game_v2.glb", "panokseon":"panokseon_game_v2.glb", "atakebune":"jp_atakebune_game_v1.glb", "sekibune":"jp_sekibune_game_v1.glb"}
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

func sails_are(info: Dictionary, open: bool) -> bool:
	# Every mast shows one sail at full size and keeps the other at the model's hidden size.
	return not info.sails_open.is_empty() and info.sails_open.size() == info.sails_furled.size() \
		and info.sails_open.all(func(sail): return is_equal_approx(sail.scale.x, 1.0 if open else 0.001)) \
		and info.sails_furled.all(func(sail): return is_equal_approx(sail.scale.x, 0.001 if open else 1.0))

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
	for kind in TYPE_MODELS:
		expect(String(rules[kind].get("model_path", "")) == MODEL_DIR + TYPE_MODELS[kind] and ShipVisuals.model_path(kind) == MODEL_DIR + TYPE_MODELS[kind], "%s: the rule's model is %s" % [kind, TYPE_MODELS[kind]])
		expect(Color.html_is_valid(String(rules[kind].get("sail_color", ""))), "%s: the rule has a sail colour (%s)" % [kind, String(rules[kind].get("sail_color", ""))])
	for file in MODEL_SHA256:
		expect(FileAccess.get_sha256(MODEL_DIR + file).left(12) == MODEL_SHA256[file], "%s is the delivered file (sha256 %s)" % [file, FileAccess.get_sha256(MODEL_DIR + file).left(12)])

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
	# Reply 2: the sea has its own shader, set from the scenario's `sea` block; the river shader file is main's.
	var sea_material := (lab.find_child("Sea", true, false) as MeshInstance3D).material_override as ShaderMaterial
	var builder: Node = lab.find_child("Sea", true, false).get_parent()
	expect(sea_material.shader.resource_path == "res://scripts/battle3d/naval/eastwar_sea_water.gdshader", "the sea uses its own shader (%s)" % sea_material.shader.resource_path)
	expect(FileAccess.get_file_as_string(RIVER_SHADER).replace("\r\n", "\n").sha256_text() == RIVER_SHADER_SHA256, "the river shader file is unchanged (main 8cc0640)")
	expect(builder.sea_values.get("flow_direction") == Vector2(0, 1) and is_equal_approx(builder.sea_values.get("flow_speed", 0.0), float(scenario.sea.flow_speed))
		and is_equal_approx(builder.sea_values.get("wave_size", 0.0), float(scenario.sea.wave_size)) and float(scenario.sea.wave_size) < 2.2
		and builder.sea_values.get("deep_color") == Color(scenario.sea.deep_color[0], scenario.sea.deep_color[1], scenario.sea.deep_color[2])
		and sea_material.get_shader_parameter("flow_direction") == Vector2(0, 1) and is_equal_approx(sea_material.get_shader_parameter("wave_strength"), float(scenario.sea.wave_strength)),
		"sea values come from the scenario: one flow direction (north to south), waves smaller than a ship (%s)" % str(builder.sea_values))
	var preset_overlay: Node = lab.get_node("NavalOverlay")
	var preset_names := []
	for step in range(4):
		preset_names.append(preset_overlay.show_sea_preset(preset_overlay.preset_index + 1))
		expect(builder.sea_values.get("flow_direction") == Vector2(0, 1) and preset_overlay.preset_label.visible and preset_overlay.preset_label.text.contains(preset_names[-1]), "F8 preset %s: same flow direction, name shown" % preset_names[-1])
	expect(scenario.sea.presets.size() == 3 and preset_names[2] == String(scenario.sea.presets[0].name) and preset_names[3] == preset_names[0] and is_equal_approx(builder.sea_values.wave_strength, float(scenario.sea.presets[1].wave_strength)),
		"F8 steps through the three presets and wraps (%s)" % str(preset_names))
	preset_overlay.show_sea_preset(0)
	expect(is_equal_approx(builder.sea_values.wave_strength, float(scenario.sea.wave_strength)) and is_equal_approx(builder.sea_values.flow_speed, float(scenario.sea.flow_speed)), "preset 1 is the scenario's base sea")
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
		expect(lab.views.has(id) and lab.views[id].visible and lab.views[id].has_meta("unit3d") and lab.soldiers[id].size() == 1 and visuals.model_sources.get(id) == "glb",
			"%s: one delivered ship model, shown" % ship.hero_id)
		expect(lab.views[id].position.distance_to(lab.board.world(unit.grid_cell)) < 0.01 and absf(lab.soldiers[id][0].global_position.y - 0.035) < 0.01, "%s: the ship floats on its cell" % ship.hero_id)
		expect(lab.hud_unit_type_name(unit.unit_type) == TYPE_NAMES[unit.unit_type] and lab.hud_troop_icon(id) == null and lab.hud_portrait(id) != null and lab.hud_display_name(id) == HeroData.HERO_DATA[ship.hero_id].display_name,
			"%s: HUD name %s, type %s, portrait, no troop icon" % [ship.hero_id, lab.hud_display_name(id), lab.hud_unit_type_name(unit.unit_type)])
		# Reply 3: measured in the ship's body space (the swell rolls the body, not these numbers).
		var info: Dictionary = visuals.ship_info(lab, id)
		var body: Node3D = info.body
		var hull := body.find_child("Hull", true, false) as MeshInstance3D
		var water := body.find_child("WaterLine", true, false) as Node3D
		expect(hull != null and water != null and info.oars != null and info.oars.has_animation("Oar_Row") and body.find_child("Flag", true, false) == null, "%s: the model has Hull, WaterLine and the oar animation; no stand-in flag" % ship.hero_id)
		if hull == null or water == null: continue
		var hull_box: AABB = body.global_transform.affine_inverse() * hull.global_transform * hull.get_aabb()
		var length := float(rules[unit.unit_type].ship_length)
		expect(absf(hull_box.size.z - length) <= length * 0.01 and hull_box.size.x < hull_box.size.z and absf(hull_box.get_center().x) < 0.01 and absf(hull_box.get_center().z) < 0.01,
			"%s: the hull is its type's length, bow along Z, centred (%.3f x %.3f m, wanted %.1f)" % [ship.hero_id, hull_box.size.x, hull_box.size.z, length])
		var box := AABB()
		for part in body.find_children("*", "MeshInstance3D", true, false): box = box.merge(body.global_transform.affine_inverse() * part.global_transform * part.get_aabb())
		expect(box.size.x <= 3.0 and box.size.z <= 3.0, "%s: the whole ship (oars, masts) is inside one 3 m cell (%.2f x %.2f m)" % [ship.hero_id, box.size.x, box.size.z])
		var water_y: float = water.global_position.y - body.position.y # without the swell's heave
		expect(absf(water_y) <= 0.01, "%s: the model's WaterLine is on the sea (%.3f m)" % [ship.hero_id, water_y])
		expect(not info.moving and is_zero_approx(info.sail) and sails_are(info, false) and not info.oars.is_playing(), "%s: at rest the sails are furled and the oars still" % ship.hero_id)
		var cloth := (info.sails_open[0] as MeshInstance3D).get_surface_override_material(0) as BaseMaterial3D
		var mast := (info.sails_open[0] as MeshInstance3D).get_parent().find_child("Mast_*", false, false) as MeshInstance3D
		expect(cloth != null and cloth.albedo_color.is_equal_approx(Color.html(rules[unit.unit_type].sail_color)) and (info.sails_open + info.sails_furled).all(func(sail): return sail.get_surface_override_material(0) == cloth)
			and (info.sails_open[0] as MeshInstance3D).mesh.surface_get_material(0) != cloth and not (info.sails_open[0] as MeshInstance3D).mesh.surface_get_material(0).albedo_color.is_equal_approx(cloth.albedo_color)
			and mast != null and mast.get_surface_override_material(0) == null and hull.get_surface_override_material(0) == null,
			"%s: its sails wear its own copy of the sail cloth in %s; mast and hull keep their materials" % [ship.hero_id, rules[unit.unit_type].sail_color])
	# Sail cloth is never shared between ships, even of one type.
	var cloths := {}
	for ship in scenario.ships:
		if by_hero.has(ship.hero_id): cloths[(visuals.ship_info(lab, by_hero[ship.hero_id].unit_id).sails_open[0] as MeshInstance3D).get_surface_override_material(0)] = true
	expect(cloths.size() == 10, "ten ships, ten sail cloths (%d)" % cloths.size())
	var turtle: Dictionary = visuals.ship_info(lab, by_hero["yi_sun_sin"].unit_id)
	expect(turtle.guns_l.size() == 5 and turtle.guns_r.size() == 5 and turtle.guns_f.size() == 3 and (turtle.guns_l + turtle.guns_r + turtle.guns_f).all(func(port): return String(port.name).begins_with("CannonSocket_")),
		"turtle ship: its gun ports are the model's 13 cannon sockets")
	expect(visuals.ship_info(lab, by_hero["kim_deok_ryeong"].unit_id).guns_f.is_empty() and visuals.ship_info(lab, by_hero["kim_deok_ryeong"].unit_id).guns_l.size() == 3, "panokseon: no sockets, three made ports a side")
	var cards: Array = shell.ally_cards() + shell.enemy_cards()
	expect(cards.size() == 10 and cards.all(func(card): return card.visible and TYPE_NAMES.values().has(card.type_name) and card.troop_icon == null and card.portrait != null), "roster cards: ten, ship type names, portraits, no troop icons")
	var actor: Dictionary = shell.current_actor()
	expect(actor.is_empty() or TYPE_NAMES.values().has(actor.type_name), "current actor panel shows a ship type")
	await frames(2)
	# Scenario edits (11-11): Yi Sun-sin sails the turtle ship, Kim Deok-ryeong the panokseon; reply 4: Yi Sun-sin has
	# the flagship's troops (design 3000) and the flagship mark.
	expect(by_hero["yi_sun_sin"].unit_type == "turtle_ship" and by_hero["yi_sun_sin"].grid_cell == Vector2i(10, 6) and by_hero["yi_sun_sin"].max_troops == 120, "Yi Sun-sin: the turtle ship at (10, 6), troops 120")
	expect(by_hero["kim_deok_ryeong"].unit_type == "panokseon" and by_hero["kim_deok_ryeong"].grid_cell == Vector2i(8, 7) and by_hero["kim_deok_ryeong"].max_troops == 80, "Kim Deok-ryeong: the panokseon at (8, 7), troops 80")
	var flagships: Array = scenario.ships.filter(func(s): return s.side == "ally" and String(s.get("role", "")) == "기함")
	expect(flagships.size() == 1 and flagships[0].hero_id == "yi_sun_sin" and int(flagships[0].troops_design) == 3000, "the Joseon flagship is Yi Sun-sin's ship (design troops 3000)")
	# Reply 4: the panel's terrain cell shows the terrain of the cell the current actor stands on: the sea.
	var panel = shell.actor_hud
	expect(lab.hud_actor_terrain() == lab.board.terrain(engine.active_unit_state.grid_cell) and lab.hud_actor_terrain() == "sea", "the lab reads the active unit's cell terrain: %s" % lab.hud_actor_terrain())
	expect(panel.visible and panel.terrain_shown == "sea" and panel.terrain_name == "바다" and (panel.hud.get_node("TerrainArea/TerrainNameLabel") as Label).text == "바다"
		and panel.terrain_icon_path == "res://assets/ui/battle/current_actor_icons/terrain_sea.png" and (panel.hud.get_node("TerrainArea/TerrainImageSlot/BoundTerrainIcon") as TextureRect).texture.resource_path == panel.terrain_icon_path
		and (panel.hud.get_node("TerrainArea/TerrainEffectLabel") as Label).text == "방어 0%\n이동 0%", "naval panel terrain cell: 바다, the sea picture, 0% lines (%s, %s)" % [panel.terrain_name, panel.terrain_icon_path])
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

	# Reply 3: a ship moving along a path opens its sails and rows; at rest again it furls them and stops. The path is
	# set by the test on the lab's presentation only (one cell out and back, twice); the engine is not asked to move.
	for hero in ["yi_sun_sin", "kato_kiyomasa"]:
		var mover: BattleUnitState = by_hero[hero]
		var mover_info: Dictionary = visuals.ship_info(lab, mover.unit_id)
		var aside := Vector2i(-1, -1)
		for step in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var next: Vector2i = mover.grid_cell + step
			if aside.x < 0 and next.x >= 0 and next.y >= 0 and next.x < 18 and next.y < 10 and not islands.has(next) and not occupied.has(next): aside = next
		lab.playback[mover.unit_id] = {"path":[mover.grid_cell, aside, mover.grid_cell, aside, mover.grid_cell], "index":1}
		await create_timer(0.6).timeout
		expect(lab.playback.has(mover.unit_id) and mover_info.moving and is_equal_approx(mover_info.sail, 1.0) and sails_are(mover_info, true), "%s moving: sails open" % hero)
		expect(mover_info.oars.is_playing() and mover_info.oars.current_animation == "Oar_Row" and mover_info.oars.get_animation("Oar_Row").loop_mode == Animation.LOOP_LINEAR, "%s moving: the oars row (Oar_Row, looping)" % hero)
		var move_started := Time.get_ticks_msec()
		while lab.playback.has(mover.unit_id) and Time.get_ticks_msec() - move_started < 10000: await process_frame
		await create_timer(0.5).timeout
		expect(not lab.playback.has(mover.unit_id) and not mover_info.moving and is_zero_approx(mover_info.sail) and sails_are(mover_info, false) and not mover_info.oars.is_playing(), "%s at rest again: sails furled, oars still" % hero)
		expect(lab.views[mover.unit_id].position.distance_to(lab.board.world(mover.grid_cell)) < 0.01, "%s is back on its cell" % hero)

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
		for record in visuals.cannon.records + visuals.fx.records:
			if record.kind != "splash": kinds[record.kind] = int(kinds.get(record.kind, 0)) + 1 # a splash belongs to its cannon shot
		var want_kinds := {}
		for weapon in weapons: want_kinds[WEAPON_KINDS[weapon]] = true
		expect(kinds.keys().all(func(kind): return want_kinds.has(kind)) and want_kinds.keys().all(func(kind): return int(kinds.get(kind, 0)) >= 3),
			"%s attack: effects %s (wanted %s)" % [unit.unit_type, str(kinds), str(want_kinds.keys())])
	# Reply 2: a ball in the water makes a splash of drops (a column and a crown), rings and foam, about 1.5 s.
	visuals.cannon.stop_all()
	visuals.cannon.call("_land", null, Vector3(20.0, 0.0, 15.0), true)
	await process_frame
	var splash: Array = visuals.cannon.records.filter(func(r): return r.kind == "splash")
	var bursts: Array = visuals.cannon.effects.get_children().filter(func(n): return n is CPUParticles3D)
	var flats: Array = visuals.cannon.effects.get_children().filter(func(n): return n is MeshInstance3D and n.mesh is PlaneMesh)
	expect(splash.size() == 1 and bursts.size() == 2 and flats.size() == 3 and bursts.all(func(b): return b.one_shot and b.amount <= 40 and b.gravity.y < 0.0) and bursts[0].amount + bursts[1].amount == int(splash[0].column) + int(splash[0].crown)
		and int(splash[0].column) + int(splash[0].crown) < 60 and is_equal_approx(splash[0].seconds, 1.5), "splash: a column and a crown of drops (%d particles), two rings and foam" % (bursts[0].amount + bursts[1].amount if bursts.size() == 2 else -1))
	expect(visuals.cannon.effects.get_children().all(func(n): return not (n is MeshInstance3D and n.mesh is CylinderMesh)), "no cylinder column any more")
	await create_timer(2.6).timeout
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
	var near_cell: Vector2i = yi.grid_cell + Vector2i(0, -3) # (10, 3)
	var far_cell: Vector2i = near_cell + Vector2i(3, 0) # (13, 3)
	for placed in [[near, near_cell], [far, far_cell]]:
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
	if engine.current_phase == "unique_skill_target_select": lab._click_skill_cell(near_cell)
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
	var rowing_frames := 0 # frames in which a ship on a path had its oars rowing and its sails opening (engine moves)
	while lab.battle_result.is_empty() and Time.get_ticks_msec() - started < 240000:
		await process_frame
		for id in lab.playback:
			var moving_info: Dictionary = visuals.ship_info(lab, id)
			if not moving_info.is_empty() and moving_info.moving and moving_info.sail > 0.0 and moving_info.oars.is_playing(): rowing_frames += 1
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
	expect(rowing_frames > 0, "ships moved by the engine rowed with their sails opening (%d frames)" % rowing_frames)

	# Restart: a fresh naval battle. This one runs with the rules' model_path taken out (and no <unit_type>.glb in the
	# folder): every ship is a stand-in, as before the models were delivered. Then closing: the land board is back.
	var model_paths := {}
	for kind in TYPE_MODELS:
		model_paths[kind] = UnitTypeContract.naval_rules()[kind].get("model_path", "")
		UnitTypeContract.naval_rules()[kind].erase("model_path")
		expect(ShipVisuals.model_path(kind) == "", "%s without model_path: no model file" % kind)
	shell.restart_button.pressed.emit()
	await process_frame
	lab = shell.lab
	while not lab.ready_for_input: await process_frame
	await physics_frame
	await frames(3)
	expect(shell.lab_count == 2 and lab.unit_visuals is ShipVisuals and lab.battle_result.is_empty() and Board.source_paths.get("heightfield", "") == scenario.heightfield, "restart: a new naval lab")
	visuals = lab.unit_visuals
	expect(visuals.model_sources.size() == 10 and visuals.model_sources.values().all(func(source): return source == "placeholder"), "no model_path: ten stand-in ships (%s)" % str(visuals.model_sources.values()))
	for id in visuals.model_sources:
		var stand_in: Node3D = lab.soldiers[id][0]
		var stand_in_info: Dictionary = visuals.ship_info(lab, id)
		var stand_in_box := AABB()
		for part in stand_in.find_children("*", "MeshInstance3D", true, false): stand_in_box = stand_in_box.merge(stand_in_info.body.global_transform.affine_inverse() * part.global_transform * part.get_aabb())
		expect(stand_in_box.size.x <= stand_in_box.size.z and absf(stand_in_box.size.z - float(rules[stand_in_info.kind].ship_length)) <= 0.05 and stand_in.find_child("Flag", true, false) != null
			and stand_in_info.oars == null and stand_in_info.sails_open.is_empty() and stand_in_info.guns_l.size() == 3 and stand_in_info.guns_f.is_empty(),
			"%s stand-in: its type's length, a flag, made gun ports (%.2f x %.2f m)" % [id, stand_in_box.size.x, stand_in_box.size.z])
	for kind in model_paths: UnitTypeContract.naval_rules()[kind]["model_path"] = model_paths[kind]
	expect(TYPE_MODELS.keys().all(func(kind): return ShipVisuals.model_path(kind) == MODEL_DIR + TYPE_MODELS[kind]), "the rules' model paths are back")
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
	# Reply 4, land: whatever cell the actor stands on, the terrain cell shows the plain as before (plain and hill are
	# listed as the plain, the other land terrains are not listed). A terrain that is not in the table falls to the plain.
	const PLAIN_ICON := "res://assets/ui/battle/current_actor_icons/terrain_plain.png"
	await frames(3)
	var land_panel = land_shell.actor_hud
	var land_name := land_panel.hud.get_node("TerrainArea/TerrainNameLabel") as Label
	var land_icon := land_panel.hud.get_node("TerrainArea/TerrainImageSlot/BoundTerrainIcon") as TextureRect
	var land_terrains := {}
	for y in range(10):
		for x in range(18): land_terrains[lab.board.terrain(Vector2i(x, y))] = true
	expect(land_panel.visible and not lab.hud_actor_terrain().is_empty() and lab.hud_actor_terrain() != "sea" and land_panel.terrain_shown == lab.hud_actor_terrain() and land_name.text == "평지" and land_icon.texture.resource_path == PLAIN_ICON,
		"land panel terrain cell: 평지 and the plain picture on a %s cell" % lab.hud_actor_terrain())
	expect(land_terrains.has("plain") and land_terrains.has("hill") and not land_terrains.has("sea"), "the land board has plain and hill cells, no sea (%s)" % str(land_terrains.keys()))
	for terrain in land_terrains.keys() + ["not_a_terrain"]:
		land_panel.show_terrain(terrain)
		expect(land_panel.terrain_shown == terrain and land_name.text == "평지" and land_panel.terrain_icon_path == PLAIN_ICON and land_icon.texture.resource_path == PLAIN_ICON, "land terrain %s: 평지, the plain picture" % terrain)
	land_panel.show_terrain("island")
	expect(land_name.text == "섬" and land_icon.texture.resource_path == PLAIN_ICON, "island: 섬, the plain picture")
	land_panel.show_terrain("sea")
	expect(land_name.text == "바다" and land_icon.texture.resource_path.ends_with("terrain_sea.png"), "sea by the table: 바다, the sea picture")
	land_panel.show_terrain("")
	expect(land_name.text == "바다", "no terrain asked: the cell keeps what it shows")
	await frames(2)
	expect(land_name.text == "평지" and land_icon.texture.resource_path == PLAIN_ICON, "the next frame the panel shows the actor's cell again: 평지")
	var table: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/battle3d/terrain_hud_labels.json")).terrains
	expect(table.keys().size() == 4 and table.sea.name == "바다" and table.plain.name == "평지" and table.hill.name == "평지" and table.island.name == "섬" and table.values().all(func(entry): return ResourceLoader.exists(entry.icon)),
		"the table lists sea, plain, hill and island; every picture exists")
	land_shell._close_lab()
	land_shell.free()
	await process_frame

	print("[NAVAL_HANSANDO] checks=", checks, " failures=", failures)
	quit(0 if failures.is_empty() else 1)
