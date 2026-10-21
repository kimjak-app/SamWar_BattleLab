extends SceneTree
# M4-d: units that have not arrived are neither shown nor sent to the engine.
# A spy records every engine write; clicking a waiting unit's cell (selection
# or move) and clicking it while choosing an attack target add none.
var h

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_reinforce_harness.gd").new()
	await h.open_lab(self)
	var lab = h.lab
	var battle: Node = lab.engine
	lab._sync_views()
	var waiting: Array = battle.all_battle_unit_states.filter(func(u): return not battle._is_unit_state_available_for_battle_slot(u))
	h.expect(waiting.size() == 4, "four units wait for their arrival " + str(waiting.map(func(u): return u.unit_id)))
	for u in waiting:
		h.expect(not lab.views[u.unit_id].visible, u.unit_id + " not shown before arrival")
		for badge in lab.action_badges.get_children():
			if badge.get_meta("unit_id") == u.unit_id: h.expect(not badge.visible, u.unit_id + " badge hidden")
		h.expect(not lab.roster_label.text.contains(u.unit_id), u.unit_id + " not in the roster")
	# Ally turn: clicking a waiting unit's cell neither selects it nor asks the engine to move there.
	var active = battle.active_unit_state
	h.click(active.grid_cell)
	for u in waiting:
		var writes: int = battle.writes.size()
		var rejects: int = lab.rejected
		h.click(u.grid_cell)
		h.expect(battle.writes.size() == writes, u.unit_id + " cell click: no engine write " + str(battle.writes.slice(writes)))
		h.expect(lab.rejected == rejects + 1 and lab.status.text == "거절 / 행동 불가 · 도착 전 부대가 있는 칸입니다", u.unit_id + " refused: " + lab.status.text)
		h.expect(battle.active_unit_state == active, u.unit_id + " not selected")
	# Attack target select: a waiting enemy is not a target (engine candidates only).
	h.setup(battle, "M6_infantry_attack")
	lab._sync_views()
	var r: Dictionary = h.roles(battle)
	h.click(r.ally.grid_cell)
	h.press_attack()
	h.expect(battle.current_phase == "attack_select", "attack select entered")
	for u in waiting.filter(func(x): return x.side == "enemy"):
		var writes: int = battle.writes.size()
		h.click(u.grid_cell)
		h.expect(battle.writes.size() == writes and battle.target_calls == 0, u.unit_id + " not attackable before arrival")
	h.click(r.ally.grid_cell, MOUSE_BUTTON_RIGHT)
	h.expect(battle.deploy_calls.is_empty(), "no deploy entry point called from 3D")
	await h.close_lab(self)
	# Isolation: a fresh lab starts with the six deployed units and no arrival residue.
	var children := root.get_child_count()
	await h.open_lab(self)
	lab = h.lab
	lab._sync_views()
	h.expect(h.visible_ids().size() == 6 and lab.tactic_cursor == 0 and lab.arrival_presentations.is_empty() and lab.pending_arrivals.is_empty(), "fresh lab: no arrival residue")
	await h.close_lab(self)
	h.expect(root.get_child_count() == children, "no leftover lab/engine node")
	print("[M4D_REINFORCE_BLOCKING] checks=", h.checks, " failures=", h.failures)
	quit(0 if h.failures.is_empty() else 1)
