extends SceneTree
# HUD block 4-4 test 2: the edge scroll on the scenario shell (a real mouse motion into the edge band, then frames).
#   - each frame's focus step is the WASD step, checked as direction and length separately, with that same frame's delta:
#     a probe node processed after the lab (process_priority) records the focus and the delta of every frame, so a step
#     and the delta it was made with come from one frame (frame times may vary). Direction: screen right = world
#     (cos yaw, 0, -sin yaw), screen down = (sin yaw, 0, cos yaw); length: zoom x 0.45 x delta (x sqrt 2 in a corner);
#     at two yaws;
#   - held at each corner long enough to cross the board, the focus stops at the play area's limits (0..54 m, 0..30 m,
#     the 18x10 play area of 3 m cells written here) and never leaves them;
#   - the mouse back in the middle: the focus stays.
const PLAY_W := 18 * 3.0
const PLAY_H := 10 * 3.0
var h

class FrameProbe extends Node:
	# Processed after the lab in the same frame: the focus the lab's _process left and the delta it was given.
	var lab
	var frames := []
	func _ready() -> void:
		process_priority = 1000
	func _process(delta: float) -> void:
		frames.append([lab.focus, delta])

func _initialize() -> void:
	run.call_deferred()

func move(p: Vector2) -> void:
	var e := InputEventMouseMotion.new()
	e.position = p
	e.global_position = p
	root.push_input(e)
	await process_frame

func settle(lab, b) -> void:
	for i in range(8000):
		await process_frame
		if b.is_demo_animating or lab._enemy_presentation_busy() or lab._presentation_busy(): continue
		if b.current_phase in ["ally_turn", "facing_select", "attack_select"] or not lab.battle_result.is_empty(): break
	for i in range(60): await process_frame # the turn's camera centring ends

func inside(f: Vector3) -> bool:
	return f.x >= -0.0001 and f.x <= PLAY_W + 0.0001 and f.z >= -0.0001 and f.z <= PLAY_H + 0.0001

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080) # the game's window (project.godot), no stretch
	await h.press_scenario(self, "default")
	var lab = h.lab
	await settle(lab, lab.engine)
	var size := Vector2(root.size)
	# Per-frame steps at two yaws, each with its own frame's delta.
	var probe := FrameProbe.new()
	probe.lab = lab
	root.add_child(probe)
	var bad_direction := []
	var bad_length := []
	var deltas := []
	var steps := 0
	for yaw in [0.32, 1.9]:
		lab.yaw = yaw
		for case in [[Vector2(size.x - 4, size.y * 0.5), Vector2(1, 0)], [Vector2(size.x * 0.5, size.y - 4), Vector2(0, 1)], [Vector2(4, 4), Vector2(-1, -1)]]:
			lab.focus = Vector3(PLAY_W * 0.5, 0, PLAY_H * 0.5)
			await move(case[0])
			probe.frames.clear()
			for i in range(5): await process_frame
			var d: Vector2 = case[1]
			var unit: Vector3 = Vector3(d.x * cos(yaw) + d.y * sin(yaw), 0, -d.x * sin(yaw) + d.y * cos(yaw))
			for i in range(1, probe.frames.size()):
				var step: Vector3 = probe.frames[i][0] - probe.frames[i - 1][0]
				var delta: float = probe.frames[i][1]
				var length: float = unit.length() * lab.zoom * 0.45 * delta
				steps += 1
				deltas.append(delta)
				if step.length() < 0.000001 or step.normalized().angle_to(unit.normalized()) > 0.001: bad_direction.append([yaw, d, step])
				if absf(step.length() - length) > 0.0001 * maxf(1.0, length): bad_length.append([yaw, d, step.length(), length, delta])
	probe.queue_free()
	h.expect(steps == 24 and bad_direction.is_empty(), "%d frame steps point the WASD way for the edge direction (wrong %s)" % [steps, str(bad_direction.slice(0, 4))])
	h.expect(steps == 24 and bad_length.is_empty(), "%d frame steps are zoom x 0.45 x that frame's delta (x sqrt 2 in a corner) (wrong %s; deltas %s..%s)" % [steps, str(bad_length.slice(0, 4)), deltas.min(), deltas.max()])
	# Corners held: the focus ends at the limits and never leaves them.
	var ends := []
	var left := []
	lab.yaw = 0.0 # screen axes = world axes: each corner pushes toward one corner of the play area
	for case in [[Vector2(2, 2), Vector3(0, 0, 0)], [Vector2(size.x - 2, 2), Vector3(PLAY_W, 0, 0)], [Vector2(2, size.y - 2), Vector3(0, 0, PLAY_H)], [Vector2(size.x - 2, size.y - 2), Vector3(PLAY_W, 0, PLAY_H)]]:
		lab.focus = Vector3(PLAY_W * 0.5, 0, PLAY_H * 0.5)
		await move(case[0])
		for i in range(240):
			await process_frame
			if not inside(lab.focus): left.append(lab.focus)
		ends.append([case[0], lab.focus, case[1]])
	h.expect(left.is_empty(), "held at the corners for 240 frames each, the focus never leaves 0..%.0f x 0..%.0f m (%s)" % [PLAY_W, PLAY_H, str(left.slice(0, 4))])
	h.expect(ends.all(func(e): return (e[1] as Vector3).distance_to(e[2]) < 0.0001), "each corner ends exactly at the play area's corner %s" % str(ends))
	await move(size * 0.5)
	var rest: Vector3 = lab.focus
	for i in range(30): await process_frame
	h.expect(lab.focus == rest, "mouse in the middle: the focus stays (%s -> %s)" % [rest, lab.focus])
	await h.close_shell(self)
	print("[EDGE_LIMITS] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
