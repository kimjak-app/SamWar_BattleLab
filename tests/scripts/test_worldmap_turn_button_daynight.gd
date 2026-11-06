extends SceneTree
# TURNBTN reskin: the day/night turn button is the same WorldMapTurnCompass node ("TurnEndCompass", turn_end_requested,
# the serialized turn flow); only its layers and click shape change. On a fake world scene (the old turn end button
# "턴 종료" with a counting callback, a turn label and a calendar label) bound with bind_world_scene:
# a. the node name and the signal   b. the layers for the flag on / off
# c. the click circle (real mouse events through the viewport): window centre, just inside the edge, the gold frame
#    just outside, the control's corner, the centre icon
# d. one click = one turn_end_requested and one old callback; a second click during the turn presentation does nothing
# e. after the turn label changes and the old button is "턴 종료" again the cycle finishes on day (SkyA day, SkyB clear)
# f. an old button reading "편집" or disabled hides the click area: a click sends nothing
# The flag off (the old compass) runs a, d and e as well. The 10 s timeout path is not run (constant unchanged).
const COMPASS_SCRIPT := "res://scripts/worldmap/worldmap_turn_compass.gd"
const DAY_SKY := "res://assets/ui/turn_button/sky_1_day.png"
const BUTTON_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/WildArmyEditButtonPlaceholder"
const TURN_LABEL_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/TurnLabel"
const CALENDAR_LABEL_PATH := "WorldMapUI/LeftWorldStatusPanel/MarginContainer/Content/CalendarLabel"

var checks := 0
var failures: Array = []
var callback_calls := 0
var signal_calls := 0


func _initialize() -> void:
	run.call_deferred()


func expect(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)
		push_error("[TURN_BUTTON_DAYNIGHT_FAIL] " + label)


func run() -> void:
	root.size = Vector2i(1920, 1080)
	await run_flag(true)
	await run_flag(false)
	print("[TURN_BUTTON_DAYNIGHT] checks=%d failures=%s" % [checks, str(failures)])
	quit(0 if failures.is_empty() and checks > 0 else 1)


func run_flag(daynight: bool) -> void:
	var tag := "daynight" if daynight else "old compass"
	callback_calls = 0
	signal_calls = 0
	var world := build_fake_world()
	root.add_child(world)
	var button: Button = world.get_node(BUTTON_PATH)
	var compass: Control = load(COMPASS_SCRIPT).new()
	compass.name = "TurnEndCompass"
	compass.set("use_daynight_turn_button", daynight)
	world.get_node("WorldMapUI").add_child(compass)
	compass.call("bind_world_scene", world)
	compass.connect("turn_end_requested", func(): signal_calls += 1)
	for i in 10: await process_frame

	# a. name and signal
	expect(compass.name == "TurnEndCompass" and compass.has_signal("turn_end_requested") and compass.get_parent().name == "WorldMapUI", "%s: TurnEndCompass with turn_end_requested" % tag)
	# b. layers
	var new_layers := ["SkyA", "SkyB", "Frame", "Center", "TurnEndHitArea"]
	var old_layers := ["Base", "Needle", "Cap", "TurnEndPlaque", "TurnEndPlaqueButton"]
	if daynight:
		expect(new_layers.all(func(n): return compass.get_node_or_null(n) != null) and old_layers.all(func(n): return compass.get_node_or_null(n) == null), "daynight: SkyA/SkyB/Frame/Center/TurnEndHitArea, no Base/Needle/Cap/plaque")
		for n in ["SkyA", "SkyB", "Frame", "Center"]:
			expect((compass.get_node(n) as Control).mouse_filter == Control.MOUSE_FILTER_IGNORE, "daynight: %s ignores the mouse" % n)
		var hit: TextureButton = compass.get_node("TurnEndHitArea")
		expect(hit.tooltip_text == "턴 종료" and hit.mouse_default_cursor_shape == Control.CURSOR_POINTING_HAND, "daynight: tooltip 턴 종료, pointing hand")
		var circle: Dictionary = compass.call("get_window_circle")
		expect((circle.center as Vector2).distance_to(Vector2(119.63, 120.82)) < 0.05 and absf(float(circle.radius) - 67.5) < 0.01, "daynight: window circle %s r %.2f" % [str(circle.center), float(circle.radius)])
		var sky: Control = compass.get_node("SkyA")
		var sky_circle: Dictionary = compass.call("get_sky_circle"); var hole: Dictionary = compass.call("get_frame_hole"); expect(bool(hole.measured) and (hole.center as Vector2).distance_to(Vector2(120.0, 119.0625)) < 0.05 and (sky_circle.center as Vector2).distance_to(hole.center) < 0.05 and absf(float(sky_circle.radius) - 71.4375) < 0.01 and float(sky_circle.radius) >= maxf((hole.radius as Vector2).x, (hole.radius as Vector2).y) + 3.0 - 0.001 and sky.position.distance_to((sky_circle.center as Vector2) - Vector2.ONE * float(sky_circle.radius)) < 0.05 and sky.size.is_equal_approx(Vector2.ONE * float(sky_circle.radius) * 2.0), "daynight: sky on the measured frame hole + 3 px (%s %s, hole %s %s)" % [str(sky.position), str(sky.size), str(hole.center), str(hole.radius)])
		expect((compass.get_node("Frame") as Control).size.is_equal_approx(Vector2(240, 240)), "daynight: frame on the 240 canvas")
		expect((compass.get_node("SkyA") as TextureRect).texture.resource_path == DAY_SKY and is_zero_approx((compass.get_node("SkyB") as Control).modulate.a), "daynight: rests on day")
		# c. click circle, by the GUI's own hover pick
		var origin := compass.get_global_rect().position
		var c: Vector2 = origin + circle.center
		var r: float = circle.radius
		for probe in [["window centre", c, true], ["inside the edge (r - 2)", c + Vector2(r - 2.0, 0.0), true], ["frame just outside (r + 3)", c + Vector2(r + 3.0, 0.0), false],
				["control corner", origin + Vector2(2, 2), false], ["centre icon", origin + Vector2(120, 120), true], ["frame below (r + 3)", c + Vector2(0.0, r + 3.0), false]]:
			await move_mouse(probe[1])
			var over: bool = root.gui_get_hovered_control() == hit
			expect(over == probe[2], "daynight: %s -> %s (got %s)" % [probe[0], str(probe[2]), str(over)])
		await move_mouse(c)
		expect((compass.get_node("Center") as TextureRect).texture.resource_path.ends_with("turn_btn_center_hover.png"), "daynight: hover texture")
	else:
		expect(old_layers.all(func(n): return compass.get_node_or_null(n) != null) and new_layers.all(func(n): return compass.get_node_or_null(n) == null), "old compass: Base/Needle/Cap/plaque, no new layers")

	# f. not an actual turn end: "편집" or disabled
	var click_point := compass.get_global_rect().position + (Vector2(120, 120) if daynight else Vector2(120, 126))
	for state in [["편집", false], ["턴 종료", true]]:
		button.text = state[0]
		button.disabled = state[1]
		for i in 3: await process_frame
		var area: Control = compass.get_node("TurnEndHitArea" if daynight else "TurnEndPlaqueButton")
		expect(not area.visible, "%s: '%s' disabled=%s hides the click area" % [tag, state[0], str(state[1])])
		await click(click_point)
		expect(signal_calls == 0 and callback_calls == 0, "%s: a click then sends nothing" % tag)
	button.text = "턴 종료"
	button.disabled = false
	for i in 3: await process_frame

	# d. one click, one turn
	await click(click_point)
	expect(signal_calls == 1, "%s: one click -> one turn_end_requested (%d)" % [tag, signal_calls])
	await click(click_point)   # during the presentation
	expect(signal_calls == 1, "%s: a second click during the presentation is ignored" % tag)
	var cycled := false
	var deadline := Time.get_ticks_msec() + 2500
	while callback_calls == 0 and Time.get_ticks_msec() < deadline:
		await process_frame
		if daynight and (compass.get_node("SkyA") as TextureRect).texture.resource_path != DAY_SKY: cycled = true
	expect(callback_calls == 1, "%s: the old callback ran once after the pre-roll (%d)" % [tag, callback_calls])
	if daynight: expect(cycled, "daynight: the sky cycled during the pre-roll")
	await click(click_point)
	expect(signal_calls == 1 and callback_calls == 1, "%s: still one turn while waiting for it to finish" % tag)

	# e. the turn completes: label changes, the old button is a turn end again -> the cycle rests on day
	(world.get_node(TURN_LABEL_PATH) as Label).text = "2턴"
	deadline = Time.get_ticks_msec() + 3000
	while bool(compass.get("_serializing_turn_end")) and Time.get_ticks_msec() < deadline:
		await process_frame
	expect(not bool(compass.get("_serializing_turn_end")), "%s: the presentation finished after the turn" % tag)
	if daynight:
		expect((compass.get_node("SkyA") as TextureRect).texture.resource_path == DAY_SKY and is_zero_approx((compass.get_node("SkyB") as Control).modulate.a), "daynight: stops on day (SkyA day, SkyB alpha 0)")
	else:
		expect(is_zero_approx((compass.get_node("Needle") as Control).rotation), "old compass: needle back at 0")
	for i in 3: await process_frame
	expect((compass.get_node("TurnEndHitArea" if daynight else "TurnEndPlaqueButton") as Control).visible, "%s: the click area is back" % tag)
	world.queue_free()
	await process_frame


func build_fake_world() -> Node:
	var world := Node.new()
	world.name = "FakeWorld"
	var ui := CanvasLayer.new()
	ui.name = "WorldMapUI"
	world.add_child(ui)
	var parent: Node = ui
	for part in ["LeftWorldStatusPanel", "MarginContainer", "Content"]:
		var node := Control.new()
		node.name = part
		parent.add_child(node)
		parent = node
	var button := Button.new()
	button.name = "WildArmyEditButtonPlaceholder"
	button.text = "턴 종료"
	button.pressed.connect(func(): callback_calls += 1)
	parent.add_child(button)
	for pair in [["TurnLabel", "1턴"], ["CalendarLabel", "1592년 1월"]]:
		var label := Label.new()
		label.name = pair[0]
		label.text = pair[1]
		parent.add_child(label)
	return world


func move_mouse(at: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = at
	motion.global_position = at
	root.push_input(motion)
	await process_frame


func click(at: Vector2) -> void:
	await move_mouse(at)
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = at
		event.global_position = at
		root.push_input(event)
		await process_frame
