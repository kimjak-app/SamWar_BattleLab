extends SceneTree

## Queue 46 (addendum 7): records old (pre-placement-A) saves and what they load to. Run ONCE on main 60fd2a5 with
## tests/scripts/support/placement_a_world_capture.gd copied in:
##   godot --headless --path <60fd2a5 checkout> --script res://tools/make_placement_a_old_save_baseline.gd -- <out folder>
## Writes into <out folder>:
##   old_manual_save.json, old_checkpoint_save.json - a new game's manual slot and turn checkpoint on 60fd2a5
##   old_save_baseline.json - the world after loading each of them through each load path, in a fresh WorldMap scene,
##     after the deferred registered-hero seeding has run:
##       title:  GameSession.request_load() then a new WorldMap scene (reads the checkpoint slot)
##       system: a new game's WorldMap, then the system menu load (_load_worldmap_manual_slot_mvp: manual slot first)

const Capture := preload("res://tests/scripts/support/placement_a_world_capture.gd")
const WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"
const MANUAL_SAVE := "user://worldmap_manual_save.json"
const CHECKPOINT_SAVE := "user://worldmap_left_panel_state.json"
const SETTLE_FRAMES := 20


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var out := args[0] if not args.is_empty() else ProjectSettings.globalize_path("user://placement_a_old_save_baseline")
	DirAccess.make_dir_recursive_absolute(out)
	var session := root.get_node("/root/GameSession")
	var backup := {MANUAL_SAVE: _read(MANUAL_SAVE), CHECKPOINT_SAVE: _read(CHECKPOINT_SAVE)}
	session.call("request_new_game", "player")
	change_scene_to_file(WORLDMAP_SCENE_PATH)
	await _frames(SETTLE_FRAMES)
	var main := current_scene
	main.call("_save_worldmap_manual_slot_mvp")
	main.call("_checkpoint_worldmap_state_mvp")
	var saves := {"manual": _read(MANUAL_SAVE), "checkpoint": _read(CHECKPOINT_SAVE)}
	_write(out.path_join("old_manual_save.json"), saves.manual)
	_write(out.path_join("old_checkpoint_save.json"), saves.checkpoint)
	var baseline := {"base_commit": _commit()}
	for save_kind in saves:
		baseline["title_" + save_kind] = await load_through_title(self, saves[save_kind])
		baseline["system_" + save_kind] = await load_through_system_menu(self, saves[save_kind])
	_write(out.path_join("old_save_baseline.json"), JSON.stringify(baseline, "\t", true) + "\n")
	for path in backup:
		if backup[path] == null:
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
		else:
			_write(path, backup[path])
	print("[PLACEMENT_A_OLD_SAVE_BASELINE] %s -> %s" % [baseline.base_commit, out])
	quit(0)


## Title "불러오기": the save in the checkpoint slot, read by a new WorldMap scene's _ready.
static func load_through_title(tree: SceneTree, save_text: String) -> Dictionary:
	_write(CHECKPOINT_SAVE, save_text)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(MANUAL_SAVE))
	tree.root.get_node("/root/GameSession").call("request_load")
	tree.change_scene_to_file(WORLDMAP_SCENE_PATH)
	for i in SETTLE_FRAMES:
		await tree.process_frame
	return Capture.world(tree.current_scene)


## System menu "불러오기" in a fresh new-game WorldMap: the manual slot (the checkpoint is not read when it exists).
static func load_through_system_menu(tree: SceneTree, save_text: String) -> Dictionary:
	tree.root.get_node("/root/GameSession").call("request_new_game", "player")
	tree.change_scene_to_file(WORLDMAP_SCENE_PATH)
	for i in SETTLE_FRAMES:
		await tree.process_frame
	_write(MANUAL_SAVE, save_text)
	tree.current_scene.call("_load_worldmap_manual_slot_mvp")
	for i in SETTLE_FRAMES:
		await tree.process_frame
	return Capture.world(tree.current_scene)


func _frames(count: int) -> void:
	for i in count:
		await process_frame


static func _read(path: String) -> Variant:
	return FileAccess.get_file_as_string(path) if FileAccess.file_exists(path) else null


static func _write(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _commit() -> String:
	var output: Array = []
	if OS.execute("git", ["-C", ProjectSettings.globalize_path("res://"), "rev-parse", "--short", "HEAD"], output, true) == 0 and not output.is_empty():
		return str(output[0]).strip_edges()
	return "unknown"
