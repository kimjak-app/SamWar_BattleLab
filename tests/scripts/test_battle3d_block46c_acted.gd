extends SceneTree
# HUD block 4-6c test 3: an acted unit's marker on the scenario shell. After an ally waits for real (the lab's wait
# command), for that ally: the face chip and the bar are darkened (each colour channel under 0.7), the number and the
# whole marker are not (white); the units that have not acted: chip, bar and number all bright. Badges on an acted marker
# (a probe marker with five statuses): bright.
# Block 4-6d: every part is read as drawn: its own self_modulate x modulate times the modulate of each parent up to and
# including the marker root (a darkened container or root darkens what is inside it).
const PROBE_AT := {"foot":Vector2(400, 400), "body":Vector2(400, 370), "disc_bottom":Vector2(400, 420), "cell_px":77.0}
var h

func _initialize() -> void:
	run.call_deferred()

func dark(c: Color) -> bool:
	return c.r < 0.7 and c.g < 0.7 and c.b < 0.7

func bright(c: Color) -> bool:
	return c.r == 1.0 and c.g == 1.0 and c.b == 1.0

func drawn(node: CanvasItem, m: Control) -> Color:
	var c := node.self_modulate * node.modulate
	var up := node
	while up != m:
		up = up.get_parent()
		c *= (up as CanvasItem).modulate
	return c

func parts(m: Control) -> Dictionary:
	return {"chip":drawn(m.get_node("Chip/Face"), m), "bar":drawn(m.get_node("BarBack"), m), "fill":drawn(m.get_node("BarFill"), m),
		"number":drawn(m.get_node("Troops"), m), "root":m.self_modulate * m.modulate}

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080)
	await h.press_scenario(self, "default")
	var lab = h.lab
	var b: Node = lab.engine
	for i in range(60): await process_frame
	var actor: String = b.active_unit_state.unit_id
	lab.request_wait()
	for i in range(8): await process_frame
	var markers = lab.unit_markers
	var acted_wrong := []
	var ready_wrong := []
	var acted_seen := 0
	for unit in b.all_battle_unit_states:
		var m: Control = markers.markers.get(unit.unit_id)
		if m == null or not m.visible: continue
		var p := parts(m)
		if unit.has_acted:
			acted_seen += 1
			if not (dark(p.chip) and dark(p.bar) and dark(p.fill) and bright(p.number) and bright(p.root)): acted_wrong.append([unit.unit_id, p])
		elif not (bright(p.chip) and bright(p.bar) and bright(p.fill) and bright(p.number) and bright(p.root)): ready_wrong.append([unit.unit_id, p])
	h.expect(acted_seen >= 1 and acted_wrong.is_empty(), "%s waited: acted markers have a dark chip and bar, a bright number (wrong %s)" % [actor, str(acted_wrong)])
	h.expect(ready_wrong.is_empty(), "control: markers of units that have not acted are bright (wrong %s)" % str(ready_wrong))
	var probe := "zz_probe"
	markers.show_unit(probe, {"side":"ally", "current_troops":5, "max_troops":10, "has_acted":true}, null, false, ["◎2", "⚠1", "▼3", "▲2"], PROBE_AT, true)
	var pm: Control = markers.markers[probe]
	var badge_mods: Array = pm.get_node("Badges").get_children().filter(func(l): return l.visible).map(func(l): return drawn(l, pm))
	var pp := parts(pm)
	h.expect(badge_mods.size() == 4 and badge_mods.all(func(c): return bright(c)) and bright(pp.number) and bright(pp.root) and dark(pp.chip) and dark(pp.bar), "an acted marker's badges and number stay bright as drawn (%s, %s), its chip and bar dark" % [str(badge_mods), pp])
	pm.queue_free()
	markers.markers.erase(probe)
	await h.close_shell(self)
	print("[BLOCK46C_ACTED] checks=", h.checks, " failures=", h.failures, " acted ", acted_seen)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
