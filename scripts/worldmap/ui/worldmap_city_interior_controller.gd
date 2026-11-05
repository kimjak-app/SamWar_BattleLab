class_name WorldMapCityInteriorController
extends Node

## CITY-HUD CH-2: the city interior window frame. Attached outside worldmap_main.gd as a root child of WorldMap.tscn
## (like WorldMap3DHost). Listens to every city marker's `city_selected` (2D click and the 3D adapter's forwarded
## pick emit the same signal) with CONNECT_DEFERRED, so main's own handler has already run. Opens only for the
## player's own city when no target / turn / modal state is active; otherwise records why in last_reject_reason.
## Reads main state only (get()/call()), never writes it. Main is held as a plain Node; no WorldMap3D* classes are named.
## The window is built in code; building art goes in later steps (CH-3/CH-4).

const MAIN_META := "wm_city_interior_controller"
const WINDOW_LAYER := 50   # free between TopNav (40) and the tech tree overlay (60)
const TURN_PHASE_PLAYER := "player"
const WINDOW_SIZE := Vector2(960, 600)
const PLACEHOLDER_TEXT := "건물 그림은 다음 단계에서 연결됩니다"
const BUILDING_ASSETS_PATH := "res://scripts/worldmap/ui/worldmap_city_building_assets.gd"

## Checked in this order after "own city". [kind, main member name]. Kinds: flag = bool true blocks,
## text = non-empty String blocks, visible = node visible blocks, method_true = call() true blocks,
## method_nonempty = call() non-empty Dictionary blocks, turn_phase = _player_state.turn_phase is not the player phase.
const BUSY_GUARDS := [
	["flag", "_contextual_worldmap_action_pending"],
	["text", "_pending_diplomacy_action_id"],
	["text", "_pending_spy_action_id"],
	["text", "_pending_trade_action_id"],
	["visible", "_player_attack_deployment_panel"],
	["method_true", "_has_pending_invasion_event_mvp"],
	["method_nonempty", "_get_pending_battle_context_mvp"],
	["flag", "_enemy_turn_mvp_pending"],
	["flag", "_domestic_turn_apply_pending"],
	["turn_phase", "_player_state"],
]
const MODAL_GUARDS := [
	["method_true", "_is_domestic_tech_tree_overlay_open_mvp"],
	["method_true", "_is_domestic_tech_completion_card_visible"],
	["method_true", "_has_terminal_korea_outcome_mvp"],
	["visible", "_manual_trade_order_panel"],
	["visible", "_internal_trade_transfer_panel"],
	["visible", "_t05_outcome_presentation_root"],
	["help_modal", "_ensure_shared_ui_controller"],
]
## Other main members this controller relies on (the test checks they still exist).
const MAIN_MEMBERS := [
	"_city_markers_by_id", "_camera_controller", "_is_city_owned_by_player_mvp", "_ensure_camera_controller",
	"_normalize_turn_phase",
]

@export var main_path: NodePath = NodePath("..")

var main: Node = null
var last_reject_reason := ""
var _open_city_id := ""
var _connected_markers: Array = []
var _blocked_camera_controller: Object = null   # the one controller whose input_blocked we set (one boolean, no count)
var _layer: CanvasLayer = null
var _title_label: Label = null
var _close_button: Button = null
var _building_assets: Script = null


func _ready() -> void:
	var m := get_node_or_null(main_path)
	if m == null or not m.has_method("_is_city_owned_by_player_mvp"):
		return
	var owner_node = m.get_meta(MAIN_META) if m.has_meta(MAIN_META) else null
	if owner_node != null and is_instance_valid(owner_node) and owner_node != self:
		return   # another controller already serves this main
	m.set_meta(MAIN_META, self)
	main = m
	if ResourceLoader.exists(BUILDING_ASSETS_PATH):
		_building_assets = load(BUILDING_ASSETS_PATH)
	if not main.is_node_ready():   # root child: main._ready builds the markers after us
		await main.ready
	_connect_markers()


func _exit_tree() -> void:
	_unblock_camera_input()
	if main != null and is_instance_valid(main) and main.has_meta(MAIN_META) and main.get_meta(MAIN_META) == self:
		main.remove_meta(MAIN_META)


func is_open() -> bool:
	return not _open_city_id.is_empty()


func get_open_city_id() -> String:
	return _open_city_id


func get_title_text() -> String:
	return _title_label.text if _title_label != null else ""


func get_close_button() -> Button:
	return _close_button


func get_connected_marker_count() -> int:
	return _connected_markers.size()


## Tries to open (or retarget) the window for city_id. Returns true when the window shows that city afterwards.
func try_open(city_id: String) -> bool:
	var reason := get_reject_reason(city_id)
	last_reject_reason = reason
	if not reason.is_empty():
		return false
	_open_city_id = city_id
	_ensure_window()
	_title_label.text = "%s — 성 안" % _city_display_name(city_id)
	_layer.visible = true
	_block_camera_input()
	return true


## "" = may open. Checks in order: own city, busy/target state, building art, battle-entry handoff, modals.
func get_reject_reason(city_id: String) -> String:
	if main == null or not is_instance_valid(main):
		return "no_main"
	if city_id.is_empty() or not bool(main.call("_is_city_owned_by_player_mvp", city_id)):
		return "not_own_city"
	if is_open() and city_id == _open_city_id:
		return "already_open"
	for guard in BUSY_GUARDS:
		if _guard_active(guard):
			return "busy:%s" % guard[1]
	if _region_style(city_id).is_empty():
		return "no_art"
	var camera_controller = main.call("_ensure_camera_controller")
	if camera_controller != null and camera_controller.is_battle_entry_handoff_in_progress():
		return "battle_entry_handoff"
	for guard in MODAL_GUARDS:
		if _guard_active(guard):
			return "modal:%s" % guard[1]
	return ""


func close() -> void:
	if not is_open():
		return
	_open_city_id = ""
	if _layer != null:
		_layer.visible = false
	_unblock_camera_input()


func _input(event: InputEvent) -> void:
	if not is_open():
		return
	var key := event as InputEventKey
	if event.is_action_pressed("ui_cancel") or (key != null and key.pressed and not key.echo and key.keycode == KEY_ESCAPE):
		close()
		get_viewport().set_input_as_handled()


func _connect_markers() -> void:
	var markers = main.get("_city_markers_by_id")
	if not markers is Dictionary:
		return
	for marker in (markers as Dictionary).values():
		if marker == null or not is_instance_valid(marker) or not marker.has_signal("city_selected"):
			continue
		var callable := Callable(self, "_on_city_selected")
		if not marker.is_connected("city_selected", callable):
			marker.connect("city_selected", callable, CONNECT_DEFERRED)
			_connected_markers.append(marker)


func _on_city_selected(marker: Node) -> void:
	if marker == null or not is_instance_valid(marker):
		return
	try_open(str(marker.get("city_id")))


func _guard_active(guard: Array) -> bool:
	var kind: String = guard[0]
	var member: String = guard[1]
	match kind:
		"flag":
			return bool(main.get(member))
		"text":
			return not str(main.get(member)).is_empty()
		"visible":
			var node = main.get(member)
			return node != null and is_instance_valid(node) and node is CanvasItem and (node as CanvasItem).visible
		"method_true":
			return bool(main.call(member))
		"method_nonempty":
			var value = main.call(member)
			return value is Dictionary and not (value as Dictionary).is_empty()
		"turn_phase":
			var state = main.get(member)
			var phase := str((state as Dictionary).get("turn_phase", TURN_PHASE_PLAYER)) if state is Dictionary else TURN_PHASE_PLAYER
			return str(main.call("_normalize_turn_phase", phase)) != TURN_PHASE_PLAYER
		"help_modal":
			var shared_ui = main.call(member)
			return shared_ui != null and shared_ui.has_method("is_help_modal_visible") and bool(shared_ui.is_help_modal_visible())
	return false


func _region_style(city_id: String) -> String:
	if _building_assets == null:
		return ""
	var marker = _marker_for(city_id)
	var region_key := str(marker.get("region_id")) if marker != null else ""
	return str(_building_assets.region_style_for_region_key(region_key))


func _city_display_name(city_id: String) -> String:
	var marker = _marker_for(city_id)
	var display_name := str(marker.get("display_name")) if marker != null else ""
	return display_name if not display_name.is_empty() else city_id


func _marker_for(city_id: String) -> Node:
	var markers = main.get("_city_markers_by_id")
	if markers is Dictionary:
		var marker = (markers as Dictionary).get(city_id, null)
		if marker is Node and is_instance_valid(marker):
			return marker
	return null


## Existing mechanism only: the 3D camera controller's input_blocked flag (keyboard axes). Mouse wheel / drag / picks
## never reach the map because the full-screen blocker below eats them in the GUI stage. The 2D camera controller has
## no such flag, so 2D keyboard panning is not blocked here (see the CH-2 report).
func _block_camera_input() -> void:
	var camera_controller = main.get("_camera_controller")
	if camera_controller == _blocked_camera_controller:
		return
	_unblock_camera_input()
	if camera_controller != null and is_instance_valid(camera_controller) and "input_blocked" in camera_controller:
		camera_controller.set("input_blocked", true)
		_blocked_camera_controller = camera_controller


func _unblock_camera_input() -> void:
	if _blocked_camera_controller != null and is_instance_valid(_blocked_camera_controller):
		_blocked_camera_controller.set("input_blocked", false)
	_blocked_camera_controller = null


func _ensure_window() -> void:
	if _layer != null:
		return
	_layer = CanvasLayer.new()
	_layer.name = "CityInteriorCanvas"
	_layer.layer = WINDOW_LAYER
	_layer.visible = false
	add_child(_layer)
	var blocker := Control.new()
	blocker.name = "InputBlocker"
	blocker.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	blocker.mouse_filter = Control.MOUSE_FILTER_STOP   # clicks outside the window do nothing (and never reach the map)
	_layer.add_child(blocker)
	var panel := PanelContainer.new()
	panel.name = "Window"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -WINDOW_SIZE.x * 0.5
	panel.offset_top = -WINDOW_SIZE.y * 0.5
	panel.offset_right = WINDOW_SIZE.x * 0.5
	panel.offset_bottom = WINDOW_SIZE.y * 0.5
	blocker.add_child(panel)
	var column := VBoxContainer.new()
	panel.add_child(column)
	var header := HBoxContainer.new()
	column.add_child(header)
	_title_label = Label.new()
	_title_label.name = "TitleLabel"
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_title_label)
	_close_button = Button.new()
	_close_button.name = "CloseButton"
	_close_button.text = "닫기"
	_close_button.pressed.connect(close)
	header.add_child(_close_button)
	var body := Label.new()
	body.name = "PlaceholderLabel"
	body.text = PLACEHOLDER_TEXT
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	column.add_child(body)
