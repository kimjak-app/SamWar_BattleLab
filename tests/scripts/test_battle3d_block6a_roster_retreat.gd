extends SceneTree
# HUD block 6a test 2: retreated cards. On the scenario shell at 1920 x 1080 this test sets one ally and one enemy (not
# the active unit) to 0 troops on the engine's own unit states and lets the lab sync its display values:
#   - each roster keeps its card count (the slots stay);
#   - those two cards: shown, drawn dimmed (alpha under 1, colour under 1) and a "퇴각" text shown over the card's
#     middle; every other shown card: opaque, no "퇴각";
#   - control: before the retreat both cards are opaque and without the text.
var h

func _initialize() -> void:
	run.call_deferred()

func shown_cards(roster) -> Array:
	return range(roster.SLOT_NAMES.size()).map(func(i): return roster.slot(i)).filter(func(c): return c.visible)

func card_state(roster, id: String, ids: Array) -> Dictionary:
	var index := ids.find(id)
	var card: Control = roster.slot(index)
	var label: Label = card.get_parent().get_node_or_null("RetreatLabel%02d" % (index + 1))
	var text := label != null and label.is_visible_in_tree() and label.text == "퇴각" and card.get_global_rect().has_point(label.get_global_rect().get_center())
	return {"visible":card.is_visible_in_tree(), "modulate":card.modulate, "text":text}

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080)
	await h.press_scenario(self, "default")
	var lab = h.lab
	var b: Node = lab.engine
	for i in range(120): await process_frame
	var shell = h.shell
	var ally_ids: Array = lab.hud_ally_unit_ids()
	var enemy_ids: Array = lab.hud_enemy_unit_ids()
	var active: String = b.active_unit_state.unit_id
	var ally := ""
	var enemy := ""
	for unit in b.all_battle_unit_states:
		if unit.unit_id == active or not lab.views[unit.unit_id].visible: continue
		if unit.side == "ally" and ally.is_empty(): ally = unit.unit_id
		if unit.side == "enemy" and enemy.is_empty(): enemy = unit.unit_id
	var counts_before := [shown_cards(shell.ally_roster).size(), shown_cards(shell.enemy_roster).size()]
	var before := [card_state(shell.ally_roster, ally, ally_ids), card_state(shell.enemy_roster, enemy, enemy_ids)]
	h.expect(before.all(func(s): return s.visible and s.modulate == Color.WHITE and not s.text), "control: before the retreat both cards opaque, no text %s" % str(before))
	for unit in b.all_battle_unit_states:
		if unit.unit_id in [ally, enemy]: unit.current_troops = 0
	lab._sync_views()
	for i in range(4): await process_frame
	var counts_after := [shown_cards(shell.ally_roster).size(), shown_cards(shell.enemy_roster).size()]
	h.expect(counts_after == counts_before and counts_before[0] >= 3 and counts_before[1] >= 3, "card counts kept %s -> %s" % [counts_before, counts_after])
	var after := [card_state(shell.ally_roster, ally, ally_ids), card_state(shell.enemy_roster, enemy, enemy_ids)]
	h.expect(after.all(func(s): return s.visible and s.modulate.a < 1.0 and s.modulate.r < 1.0 and s.text), "%s / %s retreated: card kept, dimmed, \"퇴각\" over it %s" % [ally, enemy, str(after)])
	var others := []
	for pair in [[shell.ally_roster, ally_ids, ally], [shell.enemy_roster, enemy_ids, enemy]]:
		for id in pair[1]:
			if id == pair[2]: continue
			var s := card_state(pair[0], id, pair[1])
			if s.visible and (s.modulate != Color.WHITE or s.text): others.append([id, s])
	h.expect(others.is_empty(), "the other shown cards opaque, no text (wrong %s)" % str(others))
	await h.close_shell(self)
	print("[BLOCK6A_RETREAT] checks=", h.checks, " failures=", h.failures, " retreated ", [ally, enemy], " cards ", counts_before, " -> ", counts_after, " ", after)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
