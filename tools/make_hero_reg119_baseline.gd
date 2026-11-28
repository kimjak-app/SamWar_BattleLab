extends SceneTree

## Queue 45: records the baseline that test_hero_register_119.gd compares against. Run it ONCE on the base commit
## (main 6b6bc2f, before the 119 heroes) with the capture helper copied in:
##   godot --headless --path <base checkout> --script res://tools/make_hero_reg119_baseline.gd -- <out folder>
## Writes into <out folder>:
##   baseline.json         - the 44 definitions, the new-game world, and the world after loading each save below
##   manual_save.json      - the manual slot (user://worldmap_manual_save.json) written by a new game on the base
##   checkpoint_save.json  - the turn checkpoint (user://worldmap_left_panel_state.json) written the same way

const Capture := preload("res://tests/scripts/support/hero_reg119_capture.gd")
const WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var out := args[0] if not args.is_empty() else ProjectSettings.globalize_path("user://hero_reg119_baseline")
	DirAccess.make_dir_recursive_absolute(out)
	var ids := HeroDefinitionRegistry.LEGACY_IDENTITY_DATA.keys()
	var baseline := {"base_commit": _commit(), "hero_ids": ids, "definitions": Capture.definitions(ids)}
	var main := await _new_game()
	baseline["new_game"] = Capture.world(main)
	main.call("_save_worldmap_manual_slot_mvp")
	main.call("_checkpoint_worldmap_state_mvp")
	_copy("user://worldmap_manual_save.json", out.path_join("manual_save.json"))
	_copy("user://worldmap_left_panel_state.json", out.path_join("checkpoint_save.json"))
	main.call("_load_worldmap_state", "user://worldmap_manual_save.json")
	await _frames(4)
	baseline["after_manual_load"] = Capture.world(main)
	main.call("_load_worldmap_state", "user://worldmap_left_panel_state.json")
	await _frames(4)
	baseline["after_checkpoint_load"] = Capture.world(main)
	var file := FileAccess.open(out.path_join("baseline.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(baseline, "\t", true) + "\n")
	file.close()
	print("[HERO_REG119_BASELINE] %d definitions, %d cities -> %s" % [ids.size(), (baseline.new_game.stationed as Dictionary).size(), out])
	quit(0)


func _new_game() -> Node:
	root.get_node("/root/GameSession").call("request_new_game", "player")
	change_scene_to_file(WORLDMAP_SCENE_PATH)
	await _frames(8)
	return current_scene


func _frames(count: int) -> void:
	for i in count:
		await process_frame


func _copy(from: String, to: String) -> void:
	var text := FileAccess.get_file_as_string(from)
	var file := FileAccess.open(to, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _commit() -> String:
	var output: Array = []
	if OS.execute("git", ["-C", ProjectSettings.globalize_path("res://"), "rev-parse", "--short", "HEAD"], output, true) == 0 and not output.is_empty():
		return str(output[0]).strip_edges()
	return "unknown"
