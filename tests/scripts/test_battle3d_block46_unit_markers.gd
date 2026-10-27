extends SceneTree
# HUD block 4-6 tests 2-4: the unit markers on the scenario shell, against values this test reads from the engine's own
# unit states (BattleUnitState) and computes itself.
#   2. markers shown = units on the battlefield (engine slot available, troops > 0), ally + enemy, with the whole play area
#      on screen; undeployed reinforcements and a unit with 0 troops: no marker;
#   3. bar fill = current_troops / max_troops of the unit (x the bar's width; block 4-6b: sized by zoom), number "current / max" ("94 / 94");
#      a 30 / 120 unit: a quarter bar, "30 / 120";
#   4. after an ally waits (the lab's wait command), that ally's marker is darkened and every unit that has not acted
#      is bright; the selected ally's chip frame is gold.
# Also: no marker for a unit off the screen; the badges row shows at most three badges then "+n".
const PROBE_AT := {"foot":Vector2(400, 400), "body":Vector2(400, 370), "disc_bottom":Vector2(400, 420), "cell_px":77.0} # block 4-6b: markers take projected points
const GOLD := Color("ffd575")
var h

func _initialize() -> void:
	run.call_deferred()

func settle(lab, b) -> void:
	for i in range(8000):
		await process_frame
		if b.is_demo_animating or lab._enemy_presentation_busy() or lab._presentation_busy(): continue
		if b.current_phase in ["ally_turn", "facing_select", "attack_select"] or not lab.battle_result.is_empty(): break
	for i in range(30): await process_frame

func whole_area(lab) -> void:
	# The play area's middle at the zoom-out limit, straight on: every play cell is on screen at 1920 x 1080.
	if is_instance_valid(h.shell.camera_tween): h.shell.camera_tween.kill()
	lab.yaw = 0.0
	lab.zoom = lab.ZOOM_MAX
	lab.focus = Vector3(27, 0, 15)
	for i in range(3): await process_frame

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080)
	await h.press_scenario(self, "default")
	var lab = h.lab
	var b: Node = lab.engine
	await settle(lab, b)
	await whole_area(lab)
	var markers = lab.unit_markers
	# 2. Count.
	var on_field := []
	var off_field := []
	for unit in b.all_battle_unit_states:
		if b._is_unit_state_available_for_battle_slot(unit) and unit.current_troops > 0: on_field.append(unit.unit_id)
		else: off_field.append(unit.unit_id)
	var shown: Array = markers.markers.keys().filter(func(id): return markers.markers[id].visible)
	on_field.sort()
	shown.sort()
	h.expect(not on_field.is_empty() and shown == on_field, "markers shown = units on the field %s (shown %s)" % [str(on_field), str(shown)])
	h.expect(on_field.any(func(id): return id in lab.views and b.all_battle_unit_states.any(func(u): return u.unit_id == id and u.side == "enemy")) and on_field.any(func(id): return b.all_battle_unit_states.any(func(u): return u.unit_id == id and u.side == "ally")), "both sides have markers")
	h.expect(off_field.all(func(id): return not markers.markers.has(id) or not markers.markers[id].visible), "no marker for units off the field %s" % str(off_field))
	# 3. Bar and number from the engine's own fields.
	var bad := []
	for unit in b.all_battle_unit_states:
		if not unit.unit_id in on_field: continue
		var m: Control = markers.markers[unit.unit_id]
		var want_w: float = m.get_node("BarBack").size.x * float(unit.current_troops) / float(unit.max_troops) # block 4-6b: the bar's own width (sized by zoom)
		var text: String = m.get_node("Troops").text
		if absf(m.get_node("BarFill").size.x - want_w) > 0.01 or text != "%d / %d" % [unit.current_troops, unit.max_troops]: bad.append([unit.unit_id, m.get_node("BarFill").size.x, want_w, text])
	h.expect(bad.is_empty(), "bars = current / max x the bar's width and numbers 'current / max' (wrong %s)" % str(bad))
	var probe := "zz_probe"
	markers.show_unit(probe, {"side":"enemy", "current_troops":30, "max_troops":120, "has_acted":false}, null, false, [], PROBE_AT, true)
	var pm: Control = markers.markers[probe]
	h.expect(is_equal_approx(pm.get_node("BarFill").size.x, pm.get_node("BarBack").size.x * 0.25) and pm.get_node("Troops").text == "30 / 120", "30 / 120: a quarter bar (%s px), '%s'" % [pm.get_node("BarFill").size.x, pm.get_node("Troops").text])
	markers.show_unit(probe, {"side":"enemy", "current_troops":0, "max_troops":120, "has_acted":false}, null, false, [], PROBE_AT, true)
	h.expect(not pm.visible, "0 troops: no marker")
	markers.show_unit(probe, {"side":"ally", "current_troops":10, "max_troops":10, "has_acted":false}, null, false, ["◎2", "⚠1", "▼3", "▲2", "◆"], PROBE_AT, true)
	var row: Array = pm.get_node("Badges").get_children().filter(func(l): return l.visible).map(func(l): return l.text)
	h.expect(row == ["◎2", "⚠1", "▼3", "+2"], "five statuses: three badges then +2 (%s)" % str(row))
	markers.show_unit(probe, {"side":"ally", "current_troops":10, "max_troops":10, "has_acted":false}, null, false, [], PROBE_AT, false)
	h.expect(not pm.visible, "off screen: no marker")
	pm.queue_free()
	markers.markers.erase(probe)
	# 4. Acted vs not acted, and the selection.
	var actor: String = b.active_unit_state.unit_id
	var chip: StyleBoxFlat = markers.markers[actor].get_node("Chip").get_theme_stylebox("panel")
	h.expect(chip.border_color == GOLD, "the selected ally %s: gold frame (%s)" % [actor, chip.border_color])
	lab.request_wait()
	for i in range(5): await process_frame
	var acted_unit = b.all_battle_unit_states.filter(func(u): return u.unit_id == actor)[0]
	h.expect(acted_unit.has_acted, "%s acted (engine has_acted)" % actor)
	var dark := []
	var bright := []
	for unit in b.all_battle_unit_states:
		if not markers.markers.has(unit.unit_id) or not markers.markers[unit.unit_id].visible: continue
		var mod: Color = markers.markers[unit.unit_id].get_node("Chip").modulate # block 4-6c: the darkening is on the chip and bar, not the whole marker
		if unit.has_acted: dark.append([unit.unit_id, mod.r < 0.7 and mod.g < 0.7 and mod.b < 0.7])
		else: bright.append([unit.unit_id, mod == Color(1, 1, 1, 1)])
	h.expect(not dark.is_empty() and dark.all(func(x): return x[1]), "acted units darkened %s" % str(dark))
	h.expect(not bright.is_empty() and bright.all(func(x): return x[1]), "units not acted bright %s" % str(bright))
	await h.close_shell(self)
	print("[BLOCK46_MARKERS] checks=", h.checks, " failures=", h.failures, " shown ", shown.size())
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
