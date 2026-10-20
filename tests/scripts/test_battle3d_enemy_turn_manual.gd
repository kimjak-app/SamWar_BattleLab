extends SceneTree
## Manual entry for M3. `--layout=default` opens the untouched 18x10 battle;
## `--layout=<M3 case>` (default case M10_round_two_slots) applies the
## approved near-layout fixture before any player input. All later actions
## are real engine actions driven by the window's input.
##   --check          compare the lab start with the golden and quit
##   --update-golden  rewrite the start golden from an engine without 3D
const GOLDEN := "res://tests/golden/battle3d_m3_start_v0.json"
const BASE_COMMIT := "cbc1e43abfcc59aa40883883b5dcc4182ecf21e1"
const LAYOUTS := ["default", "M10_round_two_slots"]

func _initialize() -> void:
	run.call_deferred()

func start_snapshot(h, battle: Node) -> Dictionary:
	return {"units":h.fingerprint.fingerprint_units(battle.get("all_battle_unit_states")), "controller":h.oracle.controller_state(battle)}

func run() -> void:
	root.size = Vector2i(1280,800)
	var args := OS.get_cmdline_user_args()
	var layout := "M10_round_two_slots"
	for arg in args:
		if arg.begins_with("--layout="): layout = arg.trim_prefix("--layout=")
	var h = load("res://tests/scripts/support/battle3d_enemy_turn_harness.gd").new()
	if args.has("--update-golden"):
		var data := {"schema_version":0, "base_commit":BASE_COMMIT, "layouts":{}}
		for name in LAYOUTS:
			var host = await h.open_bare(self, false)
			if name != "default": h.setup(host.battle, name)
			await process_frame
			data.layouts[name] = start_snapshot(h, host.battle)
			await h.close_bare(self, host)
		var file := FileAccess.open(GOLDEN, FileAccess.WRITE)
		file.store_string(JSON.stringify(data, "\t", true) + "\n")
		file.close()
		print("M3_MANUAL golden written layouts=", LAYOUTS)
		quit(0)
		return
	if layout != "default" and not h.CASES.has(layout):
		printerr("M3_MANUAL unknown layout: ", layout)
		quit(1)
		return
	var lab = load("res://scenes/battle3d/Battle3D_EnginePlayLab.tscn").instantiate()
	root.add_child(lab)
	while not lab.ready_for_input: await process_frame
	h.lab = lab
	if layout != "default": h.setup(lab.engine, layout)
	await process_frame
	lab._sync_views()
	var golden = JSON.parse_string(FileAccess.get_file_as_string(GOLDEN))
	if golden.layouts.has(layout):
		var differences: Array = h.fingerprint.diff(golden.layouts[layout], start_snapshot(h, lab.engine))
		h.expect(differences.is_empty(), "manual start equals golden " + layout + " " + str(differences))
	elif args.has("--check"):
		h.expect(false, "no golden for layout " + layout)
	if not h.failures.is_empty():
		quit(1)
		return
	root.title = "EASTWAR | M3 3D ENEMY TURN · " + layout
	if layout != "default": lab.status.text = "검증 배치 " + layout + " / 초기 배치만 테스트용 · 이후 모든 행동은 실제 엔진"
	print("M3_MANUAL READY layout=", layout, " golden_start=", golden.layouts.has(layout), " (no scripted player actions)")
	if args.has("--check"):
		var iso = lab.engine.get("_iso_grid_controller")
		lab.free()
		if is_instance_valid(iso) and iso.get_parent() == null: iso.free()
		await process_frame
		quit(0)
