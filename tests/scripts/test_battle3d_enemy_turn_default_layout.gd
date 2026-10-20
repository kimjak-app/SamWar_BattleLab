extends SceneTree
# M3 default 18x10 layout: start == golden, turn/roster/action-state UI from
# engine flags, and evidence that the six M2 commands cannot end an ally action
# in this layout (no ally reaches an enemy; facing confirmation keeps has_acted
# false), so no enemy slot can start. No end-turn command is added (§6-3).
const GOLDEN := "res://tests/golden/battle3d_m3_start_v0.json"
var h

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_enemy_turn_harness.gd").new()
	var golden = JSON.parse_string(FileAccess.get_file_as_string(GOLDEN))
	h.expect(golden.base_commit == "cbc1e43abfcc59aa40883883b5dcc4182ecf21e1", "golden base")
	var bare = await h.open_bare(self, false)
	var bare_start := {"units":h.fingerprint.fingerprint_units(bare.battle.get("all_battle_unit_states")), "controller":h.oracle.controller_state(bare.battle)}
	h.expect(h.fingerprint.diff(golden.layouts.default, bare_start).is_empty(), "engine-only default start equals golden")
	await h.close_bare(self, bare)
	await h.open_lab(self)
	var lab = h.lab
	var battle: Node = lab.engine
	var start := {"units":h.fingerprint.fingerprint_units(battle.get("all_battle_unit_states")), "controller":h.oracle.controller_state(battle)}
	h.expect(h.fingerprint.diff(golden.layouts.default, start).is_empty(), "3D lab default start equals golden")
	lab._sync_views()
	h.expect(lab.turn_label.text == "라운드 1 · 아군 턴 · 행동 중: " + lab.selected, "turn label " + lab.turn_label.text)
	var visible := 0
	for badge in lab.action_badges.get_children():
		if badge.visible:
			visible += 1
			h.expect(badge.text == "미행동", "initial badge " + badge.get_meta("unit_id"))
	h.expect(visible == 6 and lab.roster_label.text.split("\n").size() == 7, "roster lists the six deployed units")
	var allies: Array = []
	var enemies: Array = []
	for unit in battle.all_battle_unit_states:
		if not battle._is_unit_state_available_for_battle_slot(unit): continue
		if unit.side == "ally": allies.append(unit)
		else: enemies.append(unit)
	var grid = battle.battle_grid_controller
	var report := []
	for ally in allies:
		h.click(ally.grid_cell)
		if battle.active_unit_state != ally:
			report.append({"unit_id":ally.unit_id, "selectable":false})
			continue
		var reach: Dictionary = lab.queries.query(ally.unit_id, ally.grid_cell).get("reachable", {})
		var best: Vector2i = ally.grid_cell
		var best_distance := 999
		for cell in reach:
			for enemy in enemies:
				var d: int = grid.get_distance(cell, enemy.grid_cell)
				h.expect(d > ally.attack_range, "%s cannot reach %s from %s" % [ally.unit_id, enemy.unit_id, cell])
				if d < best_distance:
					best_distance = d
					best = cell
		var entry := {"unit_id":ally.unit_id, "selectable":true, "attack_range":ally.attack_range, "best_cell":best, "best_distance":best_distance, "reachable":reach.size()}
		if best != ally.grid_cell:
			h.click(best)
			await h.wait_for(self, "facing_select")
			for button in lab.facing_ui.get_children():
				if button.text == "방향 right": button.pressed.emit()
			lab._sync_views()
			h.expect(ally.has_moved and not ally.has_acted and battle.current_phase == "ally_turn", ally.unit_id + " facing confirmation does not end the action")
			for badge in lab.action_badges.get_children():
				if badge.get_meta("unit_id") == ally.unit_id: h.expect(badge.text == "이동 완료", ally.unit_id + " badge shows engine has_moved")
		h.press_attack()
		var before: int = battle.writes.count("_try_attack_enemy_target_from_attack_select")
		if battle.current_phase == "attack_select":
			for enemy in enemies:
				h.click(enemy.grid_cell)
			h.expect(battle.writes.count("_try_attack_enemy_target_from_attack_select") == before, ally.unit_id + " every enemy out of range, no attack call")
			h.click(ally.grid_cell, MOUSE_BUTTON_RIGHT)
		entry["attack_select_entered"] = battle.writes.has("try_basic_attack")
		h.expect(not ally.has_acted, ally.unit_id + " still not acted")
		report.append(entry)
	await process_frame
	h.expect(battle.enemy_action_event_log.export().is_empty(), "no enemy slot started in the default layout")
	h.expect(battle.battle_round == 1 and lab.current_round == 1, "still round 1")
	print("[M3_DEFAULT_LAYOUT] ally_attempts=", JSON.stringify(report))
	print("[M3_DEFAULT_LAYOUT] writes=", battle.writes)
	await h.close_lab(self)
	print("[M3_DEFAULT_LAYOUT] checks=", h.checks, " failures=", h.failures)
	quit(0 if h.failures.is_empty() else 1)
