extends Node

## D5-4-hotfix1
## Test2 safety guard for the registry-video cutin overlay.
##
## The inherited battle scene owns a fullscreen HeroCutinInputBlocker. Keep it
## input-blocking only while the CanvasLayer is actually visible, and release
## mouse input immediately when the cutin closes. This does not alter battle,
## skill, initiative, or presentation timing logic.

@onready var cutin_overlay: CanvasLayer = get_node_or_null("../HeroCutinOverlay") as CanvasLayer
@onready var input_blocker: Control = get_node_or_null("../HeroCutinOverlay/HeroCutinInputBlocker") as Control

var _last_should_block := false
var _has_synced_once := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_sync_input_blocker(true)


func _process(_delta: float) -> void:
	_sync_input_blocker(false)


func _sync_input_blocker(force_log: bool) -> void:
	if cutin_overlay == null or input_blocker == null:
		return
	var should_block := bool(cutin_overlay.visible)
	input_blocker.mouse_filter = Control.MOUSE_FILTER_STOP if should_block else Control.MOUSE_FILTER_IGNORE
	if force_log or not _has_synced_once or should_block != _last_should_block:
		print("[D5_CUTIN_INPUT_GUARD] overlay_visible=%s blocker=%s" % [
			str(should_block),
			"STOP" if should_block else "IGNORE",
		])
	_last_should_block = should_block
	_has_synced_once = true
