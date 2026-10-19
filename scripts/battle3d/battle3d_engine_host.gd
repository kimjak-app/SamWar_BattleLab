extends SubViewport
signal initialized
var battle: Node

func _ready() -> void:
	size = Vector2i(1280,720)
	render_target_update_mode = SubViewport.UPDATE_DISABLED
	battle = create_battle()
	add_child(battle)
	_skip_intro.call_deferred()

func create_battle() -> Node:
	# Test hosts may attach a transparent observer before the scene enters the tree.
	return load("res://scenes/battle/Battle_Main.tscn").instantiate()

func _skip_intro() -> void:
	await get_tree().process_frame
	if is_instance_valid(battle): battle.call("_skip_battle_intro_camera_zoom")
	while is_instance_valid(battle) and battle.get("current_phase") != "ally_turn":
		await get_tree().process_frame
	initialized.emit()

func _exit_tree() -> void:
	# Approved for this independent Lab only; not a WorldMap audio policy.
	var audio = get_tree().root.get_node_or_null("GameAudio")
	if audio == null: return
	for voice in audio.get_children():
		if voice is AudioStreamPlayer:
			voice.stop()
			voice.stream = null
