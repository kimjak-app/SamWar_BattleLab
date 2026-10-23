extends SceneTree
# Roster card unique-skill ready icon (2D production HUD). Structure: every ally
# and enemy roster card has exactly one child named `UniqueSkillReadyIcon` (the
# name the roster bridge looks up) and no other ready-icon node. Behaviour: the
# engine calls a unit "ready" only when it is the active ally with momentum and a
# skill target. For each deployed ally card in turn: ally momentum 10, an enemy
# moved next to that ally (fixture write), the ally selected through the
# engine's `_select_ally_unit`; then every card's icon is visible exactly when
# the engine's `_is_unique_skill_ready_for_formation_guide` says so, and the
# selected card is ready (so its icon is exercised). With momentum 0 every icon
# is hidden. The expected values come from the engine, not from the icons.
const HOST := "res://scripts/battle3d/battle3d_engine_host.gd"
const SLOT_NAMES := ["Slot01", "Slot02", "Slot03", "Reinforce01", "Reinforce02"]
var checks := 0
var failures: Array = []

func _initialize() -> void:
	run.call_deferred()

func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)
		print("[ROSTER_ICON] FAIL ", label)

func roster(b: Node, side: String) -> Array:
	return b.call("_get_all_unit_states_in_slot_order").filter(func(u): return str(u.side) == side)

func icon_nodes(node: Node) -> Array:
	var out := []
	for c in node.get_children():
		if str(c.name).begins_with("UniqueSkillReadyIcon"): out.append(c)
		out.append_array(icon_nodes(c))
	return out

func check_icons(b: Node, tag: String, ready_card: int) -> void:
	for side in ["Ally", "Enemy"]:
		var units := roster(b, side.to_lower())
		var expected := []
		var shown := []
		for index in SLOT_NAMES.size():
			var unit = units[index] if index < units.size() else null
			expected.append(unit != null and bool(b.call("_is_unique_skill_ready_for_formation_guide", unit)))
			var icon := b.get_node_or_null("BattleUI/ProductionHudRoot/%sRosterHud/%s/UniqueSkillReadyIcon" % [side, SLOT_NAMES[index]]) as TextureRect
			shown.append(icon != null and icon.visible)
		expect(shown == expected, "%s %s: icons shown %s == engine ready %s" % [tag, side, str(shown), str(expected)])
		if ready_card >= 0 and side == "Ally": expect(expected[ready_card], "%s: ally card %d (%s) is ready, so its icon is exercised" % [tag, ready_card + 1, units[ready_card].unit_id])
		print("[ROSTER_ICON] ", tag, " ", side, " ids=", units.map(func(u): return u.unit_id), " ready=", expected, " shown=", shown)

func run() -> void:
	var host = load(HOST).new()
	root.add_child(host)
	await host.initialized
	for i in range(5): await process_frame
	var b: Node = host.battle
	for side in ["Ally", "Enemy"]:
		var hud := b.get_node("BattleUI/ProductionHudRoot/%sRosterHud" % side)
		var all_icons := icon_nodes(hud)
		expect(all_icons.size() == SLOT_NAMES.size(), "%s roster: %d ready-icon nodes in total (one per card) %s" % [side, all_icons.size(), all_icons.map(func(n): return str(hud.get_path_to(n)))])
		for slot_name in SLOT_NAMES:
			var slot := hud.get_node(slot_name)
			var mine := slot.get_children().filter(func(c): return str(c.name).begins_with("UniqueSkillReadyIcon"))
			expect(mine.size() == 1 and str(mine[0].name) == "UniqueSkillReadyIcon" and mine[0] is TextureRect, "%s %s: exactly one TextureRect named UniqueSkillReadyIcon %s" % [side, slot_name, mine.map(func(n): return str(n.name))])
	# Ready, card by card: momentum 10, an enemy next to the card's ally, that ally selected.
	b.battle_momentum.gain("ally", 10, "test")
	var allies := roster(b, "ally")
	var enemy: BattleUnitState = roster(b, "enemy")[0]
	var exercised := []
	for index in allies.size():
		var ally: BattleUnitState = allies[index]
		if not b.call("_is_unit_state_available_for_battle_slot", ally): continue
		var placed := false
		for d in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
			var cell: Vector2i = ally.grid_cell + d
			if b.battle_grid_controller.is_in_bounds(cell) and b.all_battle_unit_states.filter(func(u): return u.is_alive() and u.grid_cell == cell).is_empty():
				enemy.set_grid_cell(cell)
				placed = true
				break
		expect(placed, "card %d: an enemy placed next to %s" % [index + 1, ally.unit_id])
		b.call("_select_ally_unit", ally, false, false, false)
		for i in range(3): await process_frame
		check_icons(b, "card %d selected" % (index + 1), index)
		exercised.append(ally.unit_id)
	expect(exercised.size() >= 3 and exercised[0] == allies[0].unit_id, "deployed ally cards exercised, card 1 included %s" % str(exercised))
	# Not ready: momentum 0.
	b.battle_momentum.lose("ally", 10, "test")
	for i in range(3): await process_frame
	check_icons(b, "momentum 0", -1)
	for side in ["Ally", "Enemy"]:
		var visible_icons := icon_nodes(b.get_node("BattleUI/ProductionHudRoot/%sRosterHud" % side)).filter(func(n): return n.visible)
		expect(visible_icons.is_empty(), "momentum 0: no %s ready icon visible" % side)
	var iso = b.get("battle_grid_controller")
	host.free()
	if is_instance_valid(iso) and iso.get_parent() == null: iso.free()
	await process_frame
	print("[ROSTER_ICON] checks=", checks, " failures=", failures)
	quit(0 if failures.is_empty() else 1)
