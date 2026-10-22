extends SceneTree
# S4-3: with no `samwar_battle_setup` key (and auto_presentation_hold left at
# its default false) a whole engine full auto battle equals BASE (e835800, the
# stack commit before S4-3): final units, controller, four logs, round-start
# snapshots (with the next random value) and the write sequence, compared as
# digests from tests/golden/battle_setup_port_base_v0.json. Engine only, 4x
# speed, per seed. `--write=<path>` records the digests instead (BASE worktree).
const GOLDEN := "res://tests/golden/battle_setup_port_base_v0.json"
var h

func _initialize() -> void:
	run.call_deferred()

func seeds() -> Array:
	return [1, 2, 3, 4, 5, 6]

func run() -> void:
	h = load("res://tests/scripts/support/battle_setup_s43_harness.gd").new()
	var write_path := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--write="): write_path = arg.trim_prefix("--write=")
	var golden := {}
	if write_path.is_empty():
		golden = JSON.parse_string(FileAccess.get_file_as_string(GOLDEN))
	var written := {}
	for seed_value in seeds():
		var t0 := Time.get_ticks_msec()
		if Engine.has_meta(h.SETUP_KEY): Engine.remove_meta(h.SETUP_KEY)
		var result: Dictionary = await h.run_auto_direct(self, seed_value, 4.0)
		var got: Dictionary = h.battle_digest(result)
		var key := "seed_%d" % seed_value
		written[key] = got
		if write_path.is_empty():
			var want: Dictionary = golden.get(key, {})
			h.expect(not want.is_empty(), key + " golden present")
			for section in want:
				var expected: Variant = int(want[section]) if typeof(want[section]) == TYPE_FLOAT else want[section] # JSON numbers read back as float
				h.expect(str(got.get(section)) == str(expected), key + " " + section + " equals BASE " + str(got.get(section)) + " vs " + str(expected))
			h.expect(got.keys().size() == want.keys().size(), key + " same sections")
		print("[SETUP_BASE_PARITY] ", key, " result=", got.result, " round=", got.round, " ms=", Time.get_ticks_msec() - t0)
	if not write_path.is_empty():
		var f := FileAccess.open(write_path, FileAccess.WRITE)
		f.store_string(JSON.stringify(written, "  ", true) + "\n")
		f.close()
	print("[SETUP_BASE_PARITY] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
