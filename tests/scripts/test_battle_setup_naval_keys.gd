extends SceneTree
# Queue 35 reply 1 (S1-S5): the optional naval keys of the battle start setup, on the bare engine.
# S1 a setup without the new keys starts exactly like no setup (and the land types keep their rule values).
# S2 the battle_type handed to the skill resolver: worldmap context first, then the setup, then "land";
#    Hakikjin reaches 3 cells only when it is "naval".
# S3 a unit_type override recomputes the derived ranges: reachable cells match the naval rules file.
# S4 wrong values are ignored with a log line and the battle still starts.
# S5 arrival_round_overrides 0 puts all ten units on the board from round 1.
var h
const Naval := preload("res://scripts/battle/services/battle_setup_naval_service.gd")
const Contract := preload("res://scripts/battle/unit_type_contract.gd")
const Resolver := preload("res://scripts/battle/battle_skill_resolver.gd")
const Movement := preload("res://scripts/battle/services/battle_movement_query_service.gd")
const RULES_PATH := "res://data/battle3d/naval_unit_type_rules.json"
const ALLY_IDS := ["yi_sunsin", "jeong_dojeon", "gwon_yul"]

func _initialize() -> void:
	run.call_deferred()

func unit_in_slot(battle: Node, slot_id: String) -> BattleUnitState:
	return battle.call("_get_unit_state_for_capacity_slot_id", slot_id)

func own_reach(start: Vector2i, steps: int, blocked: Dictionary) -> int:
	# Written independently of the service: 4-neighbour flood on the 18x10 board.
	var seen := {start: 0}
	var queue := [start]
	while not queue.is_empty():
		var cell: Vector2i = queue.pop_front()
		if seen[cell] >= steps: continue
		for step in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var next: Vector2i = cell + step
			if next.x < 0 or next.y < 0 or next.x >= 18 or next.y >= 10 or blocked.has(next) or seen.has(next): continue
			seen[next] = seen[cell] + 1
			queue.append(next)
	return seen.size()

func affected_ids(battle: Node, caster: BattleUnitState) -> Array:
	var skill: Dictionary = battle.call("_get_unique_skill_for_unit", caster)
	var units: Array[BattleUnitState] = []
	for unit in battle.get("all_battle_unit_states"):
		if battle.call("_is_unit_state_available_for_battle_slot", unit): units.append(unit)
	var ids := []
	for unit in Resolver._resolve_affected_targets(caster, skill, units, caster, Naval.battle_type(battle, battle.get("worldmap_battle_context"))):
		ids.append(unit.unit_id)
	return ids

func run() -> void:
	h = load("res://tests/scripts/support/battle_setup_s43_harness.gd").new()
	var rules := {}
	for entry in JSON.parse_string(FileAccess.get_file_as_string(RULES_PATH)).unit_types: rules[entry.unit_type] = entry
	h.expect(rules.keys() == ["turtle_ship", "panokseon", "atakebune", "sekibune"], "rules file: the four ship types %s" % str(rules.keys()))
	for land in Contract.CANONICAL_UNIT_TYPES:
		h.expect(Contract.get_rule(land) == HeroDesignDataRegistry.get_unit_type_rule(land) and not Contract.is_naval(land), "land type %s: rule unchanged, not naval" % land)
	h.expect(not Contract.is_supported("galley") and Contract.get_rule("galley").is_empty(), "an unknown type stays unsupported")

	# S1: no key, and setups without any new key.
	var host = await h.open_s43(self, null)
	var b: Node = host.battle
	var base: Dictionary = h.start_state(b)
	var base_ids := []
	for unit in b.all_battle_unit_states: base_ids.append(unit.unit_id)
	h.expect(not b.has_meta(Naval.META_BATTLE_TYPE) and not b.has_meta(Naval.META_PENDING_CELLS) and Naval.battle_type(b, b.worldmap_battle_context) == "land", "no key: no setup meta, battle_type land")
	var yi: BattleUnitState = h.unit_by_id(b, "yi_sunsin")
	var skill: Dictionary = b.call("_get_unique_skill_for_unit", yi)
	h.expect(String(skill.get("effect_type", "")) == "aoe_damage_debuff" and int(skill.get("radius", 0)) == 3, "Yi Sun-sin's unique skill is the radius 3 area skill %s" % str([skill.get("skill_id", ""), skill.get("effect_type", ""), skill.get("radius", 0)]))
	await h.close_bare(self, host)
	for setup in [{}, {"unit_overrides":{"guan_yu":{"troops_ratio":1.0}}}, {"enemy_ai_level":"low"}]:
		host = await h.open_s43(self, setup)
		b = host.battle
		var s: Dictionary = h.start_state(b)
		h.expect(h.fingerprint.diff(base.units, s.units).is_empty() and h.fingerprint.diff(base.controller, s.controller).is_empty() and s.logs == base.logs and s.momentum == base.momentum,
			"S1 setup %s: start equals no key" % str(setup))
		h.expect(not b.has_meta(Naval.META_BATTLE_TYPE) and not b.has_meta(Naval.META_PENDING_CELLS) and b.ignored_logs.is_empty(), "S1 setup %s: no naval meta, nothing ignored" % str(setup))
		await h.close_bare(self, host)
	host = await h.open_s43(self, {"unit_overrides":{"guan_yu":{}}})
	h.expect(host.battle.ignored_logs == ["guan_yu has no troops_ratio"], "S1 an override with no key keeps its S4-3 log line %s" % str(host.battle.ignored_logs))
	await h.close_bare(self, host)

	# S2: an enemy 3 cells from Yi Sun-sin, nobody else within 3.
	var s2_units := {"yi_sunsin":{"grid_cell":[4, 4]}, "guan_yu":{"grid_cell":[7, 4]}, "jeong_dojeon":{"grid_cell":[0, 9]}, "gwon_yul":{"grid_cell":[0, 0]},
		"zhang_fei":{"grid_cell":[17, 0]}, "xiahou_dun":{"grid_cell":[17, 9]}}
	for case in [[null, null, false, "land"], ["naval", null, true, "naval"], ["land", null, false, "land"], ["naval", "land", false, "land"], [null, "naval", true, "naval"], ["sea", null, false, "land"]]:
		var setup := {"unit_overrides":s2_units.duplicate(true)}
		if case[0] != null: setup["battle_type"] = case[0]
		host = await h.open_s43(self, setup)
		b = host.battle
		if case[1] != null: b.worldmap_battle_context = {"battle_type":case[1]}
		yi = h.unit_by_id(b, "yi_sunsin")
		var hit: bool = affected_ids(b, yi).has("guan_yu")
		h.expect(Naval.battle_type(b, b.worldmap_battle_context) == case[3] and hit == case[2], "S2 setup %s + context %s: battle_type %s, the enemy at 3 cells %s" % [str(case[0]), str(case[1]), case[3], "hit" if case[2] else "not hit"])
		h.expect(not b.worldmap_battle_context.has("battle_type") or case[1] != null, "S2 the setup value is not written into the worldmap context")
		h.expect((case[0] == "sea") == (b.ignored_logs == ["battle_type sea"]), "S2 setup %s: ignore lines %s" % [str(case[0]), str(b.ignored_logs)])
		await h.close_bare(self, host)

	# S3: one ship of each type on open water; S5: every slot on the board from round 1.
	var ships := {"yi_sunsin":["panokseon", [3, 2]], "jeong_dojeon":["turtle_ship", [8, 4]], "gwon_yul":["atakebune", [13, 2]], "guan_yu":["sekibune", [13, 7]]}
	var overrides := {"zhang_fei":{"grid_cell":[0, 9]}, "xiahou_dun":{"grid_cell":[17, 9]}, "ally_reinforce_01_demo":{"grid_cell":[0, 0]}}
	for id in ships: overrides[id] = {"unit_type":ships[id][0], "grid_cell":ships[id][1]}
	var blocked := [[5, 2], [8, 6]]
	host = await h.open_s43(self, {"unit_overrides":overrides, "blocked_cells":blocked,
		"arrival_round_overrides":{"ally_reinforce_01":0, "enemy_reinforce_01":0, "ally_reinforce_02":0, "enemy_reinforce_02":0}})
	b = host.battle
	b.battle_grid_controller.set_blocked_cells(blocked.map(func(c): return Vector2i(c[0], c[1]))) # what the lab hands the engine
	h.expect(b.ignored_logs.is_empty(), "S3/S5 nothing ignored %s" % str(b.ignored_logs))
	var alive: Array[BattleUnitState] = []
	var occupied := {}
	for unit in b.all_battle_unit_states:
		if b.call("_is_unit_state_available_for_battle_slot", unit):
			alive.append(unit)
			occupied[unit.grid_cell] = unit.unit_id
	h.expect(alive.size() == 10 and occupied.size() == 10 and b.battle_round == 1, "S5 ten units on ten cells in round %d (%d units)" % [b.battle_round, alive.size()])
	for slot in Naval.REINFORCE_SLOTS:
		var unit := unit_in_slot(b, slot)
		h.expect(b.call("_is_unit_state_deployed_by_capacity_slot", unit) and unit.grid_cell == b.battle_grid_controller.world_to_grid(b.call("_get_unit_marker_for_unit", unit).position), "S5 %s deployed, its cell is its marker's cell" % slot)
	var movement = Movement.new()
	for id in ships:
		var unit: BattleUnitState = h.unit_by_id(b, id)
		var rule: Dictionary = rules[ships[id][0]]
		h.expect(unit.unit_type == ships[id][0] and unit.grid_cell == Vector2i(ships[id][1][0], ships[id][1][1]) and unit.move_range == int(rule.move_range) and unit.attack_range == int(rule.maximum_attack_range),
			"S3 %s: %s at %s, move %d, attack %d" % [id, unit.unit_type, str(unit.grid_cell), unit.move_range, unit.attack_range])
		var block := {}
		for cell in blocked: block[Vector2i(cell[0], cell[1])] = true
		for cell in occupied:
			if occupied[cell] != unit.unit_id: block[cell] = true
		var reach: Dictionary = movement.get_reachable_paths(unit.grid_cell, unit, movement.get_effective_move_range(unit), b.battle_grid_controller, alive, false)
		var want := own_reach(unit.grid_cell, int(rule.move_range), block)
		h.expect(movement.get_effective_move_range(unit) == int(rule.move_range) and reach.size() == want and not reach.has(Vector2i(5, 2)) and not reach.has(Vector2i(8, 6)),
			"S3 %s (%s): %d reachable cells, own count %d, no blocked cell" % [id, unit.unit_type, reach.size(), want])
		h.expect(Contract.can_target_at_distance(unit.unit_type, int(rule.minimum_attack_range)) and Contract.can_target_at_distance(unit.unit_type, int(rule.maximum_attack_range))
			and not Contract.can_target_at_distance(unit.unit_type, int(rule.maximum_attack_range) + 1) and (int(rule.minimum_attack_range) < 2 or not Contract.can_target_at_distance(unit.unit_type, 1)),
			"S3 %s attack range %d-%d" % [unit.unit_type, int(rule.minimum_attack_range), int(rule.maximum_attack_range)])
	# S5: the later round checks find the slots deployed (no second arrival, no event).
	var arrivals_before: int = b.tactic_event_log.export().filter(func(e): return e.kind == "reinforcement_arrived").size()
	b.battle_round = 3
	b.call("_try_deploy_reinforce_01_pair")
	b.call("_try_deploy_city_reinforce_02_pair")
	h.expect(arrivals_before == 0 and b.tactic_event_log.export().filter(func(e): return e.kind == "reinforcement_arrived").is_empty(), "S5 no reinforcement event at the start or in round 3")
	b.battle_round = 1
	await h.close_bare(self, host)

	# Heroes: the hero's name, stats, unique skill and portrait; type, troops and facing on top of it.
	host = await h.open_s43(self, {"unit_overrides":{"guan_yu":{"hero_id":"kato_kiyomasa", "unit_type":"atakebune", "troops":3500, "facing":"down", "troops_ratio":0.5},
		"jeong_dojeon":{"hero_id":"kim_deok_ryeong"}}})
	b = host.battle
	var kato: BattleUnitState = h.unit_by_id(b, "kato_kiyomasa_battle_unit")
	h.expect(kato != null and h.unit_by_id(b, "guan_yu") == null and kato.side == "enemy" and b.call("_get_hero_id_for_unit_state", kato) == "kato_kiyomasa", "hero: guan_yu's slot now holds kato_kiyomasa")
	if kato != null:
		var design: Dictionary = HeroDesignDataRegistry.get_unique_skill_for_hero("kato_kiyomasa")
		h.expect(kato.display_name == HeroDesignDataRegistry.get_battle_profile("kato_kiyomasa").get("display_name", kato.display_name) and not kato.display_name.is_empty() and kato.display_name != "관우"
			and String(b.call("_get_unique_skill_for_unit", kato).get("skill_id", "")) == String(design.get("skill_id", "?")), "hero: name %s, unique skill %s" % [kato.display_name, kato.unique_skill_id])
		h.expect(kato.unit_type == "atakebune" and kato.move_range == 2 and kato.facing == "down", "hero + type: atakebune, move 2, facing down (%s %d %s)" % [kato.unit_type, kato.move_range, kato.facing])
		h.expect(h.troop_fields(kato).values() == [1750, 1750, 1750, 1750, 1750, 1750], "troops 3500 then troops_ratio 0.5: %s" % str(h.troop_fields(kato).values()))
		var portrait: Texture2D = b.call("_get_closeup_portrait_texture_for_unit", kato)
		h.expect(portrait != null and portrait.resource_path.contains("kato_kiyomasa"), "hero portrait %s" % ("" if portrait == null else portrait.resource_path))
	var kim: BattleUnitState = h.unit_by_id(b, "kim_deok_ryeong_battle_unit")
	h.expect(kim != null and Contract.CANONICAL_UNIT_TYPES.has(kim.unit_type) and kim.current_troops > 0, "hero only: its own land type %s, troops kept %d" % ["" if kim == null else kim.unit_type, 0 if kim == null else kim.current_troops])
	h.expect(b.ignored_logs.is_empty() and b.worldmap_battle_context.is_empty() and b.call("_get_current_battle_resume_id") == "", "hero: nothing ignored, no worldmap context, no resume id")
	await h.close_bare(self, host)

	# S4: wrong values.
	host = await h.open_s43(self, {"battle_type":7, "arrival_round_overrides":{"ally_main":0, "ally_reinforce_01":-1, "enemy_reinforce_01":4, "nobody":0},
		"blocked_cells":[[9, 9]], "unit_overrides":{
			"yi_sunsin":{"unit_type":"galley", "hero_id":"nobody", "grid_cell":[18, 3], "facing":"north", "troops":0},
			"jeong_dojeon":{"grid_cell":[9, 9]}, "gwon_yul":{"grid_cell":[2, 2]}, "guan_yu":{"grid_cell":[2, 2]}, "zhang_fei":{"grid_cell":"x"}}})
	b = host.battle
	var s4: Dictionary = h.start_state(b)
	var want_units: Array = base.units.duplicate(true)
	var got_units: Array = s4.units.duplicate(true)
	for list in [want_units, got_units]:
		for values in list:
			if values.get("unit_id", "") == "gwon_yul": values.erase("grid_cell")
	h.expect(h.fingerprint.diff(want_units, got_units).is_empty() and h.unit_by_id(b, "gwon_yul").grid_cell == Vector2i(2, 2), "S4 only the one valid cell changed (gwon_yul to (2, 2))")
	h.expect(b.ignored_logs.size() == 13, "S4 thirteen ignore lines: %s" % str(b.ignored_logs))
	h.expect(b.current_phase == "ally_turn" and b.call("_get_battle_result_state") == "" and not b.has_meta(Naval.META_BATTLE_TYPE) and not b.has_meta(Naval.META_PENDING_CELLS), "S4 the battle starts (ally turn, no result, no meta left)")
	await h.ally_wait(self, b)
	h.expect(b.call("_get_battle_result_state") == "" and b.current_phase == "ally_turn", "S4 one ally wait and the enemy slot play normally")
	await h.close_bare(self, host)

	print("[BATTLE_SETUP_NAVAL] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
