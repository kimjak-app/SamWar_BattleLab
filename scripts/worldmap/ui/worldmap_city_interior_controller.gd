class_name WorldMapCityInteriorController
extends Node

## CITY-HUD CH-2: the city interior window frame. Attached outside worldmap_main.gd as a root child of WorldMap.tscn
## (like WorldMap3DHost). Listens to every city marker's `city_selected` (2D click and the 3D adapter's forwarded
## pick emit the same signal) with CONNECT_DEFERRED, so main's own handler has already run. Opens only for the
## player's own city when no target / turn / modal state is active; otherwise records why in last_reject_reason.
## Reads main state only (get()/call()), never writes it. Main is held as a plain Node; no WorldMap3D* classes are named.
## The window is built in code. CH-3: a city with a castle layout (WorldMapCityInteriorLayouts) is drawn from it on a
## 1280x768 canvas scaled into the window's body; other cities keep the CH-2 placeholder. Tech-driven visibility is CH-4.

const MAIN_META := "wm_city_interior_controller"
const WINDOW_LAYER := 50   # free between TopNav (40) and the tech tree overlay (60)
const TURN_PHASE_PLAYER := "player"
const WINDOW_SIZE := Vector2(960, 600)
const PLACEHOLDER_TEXT := "건물 그림은 다음 단계에서 연결됩니다"
const BUILDING_ASSETS_PATH := "res://scripts/worldmap/ui/worldmap_city_building_assets.gd"
const LAYOUTS_PATH := "res://scripts/worldmap/ui/worldmap_city_interior_layouts.gd"
const COASTAL_CHECK := "_is_city_coastal_for_city_tech"   # main, read only

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
	"_normalize_turn_phase", COASTAL_CHECK,
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
var _layouts: Script = null
var _placeholder: Label = null
var _interior_area: Control = null   # the window body; the canvas is scaled and centred in it
var _canvas: Control = null          # "InteriorCanvas", 1280x768 layout pixels
var _drawn_items: Array = []         # the layout item of each drawn node, in draw order (tests)


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
	if ResourceLoader.exists(LAYOUTS_PATH):
		_layouts = load(LAYOUTS_PATH)
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


func get_canvas() -> Control:
	return _canvas


func get_interior_area() -> Control:
	return _interior_area


func get_placeholder() -> Label:
	return _placeholder


## The layout item of each drawn canvas node (background excluded), in draw order.
func get_drawn_items() -> Array:
	return _drawn_items.duplicate()


## Scales and centres the 1280x768 canvas in an area of this size (k = min(W/1280, H/768)).
func apply_canvas_transform(area_size: Vector2) -> void:
	if _canvas == null or _layouts == null:
		return
	var transform: Dictionary = _layouts.canvas_transform(area_size)
	_canvas.scale = Vector2.ONE * float(transform.k)
	_canvas.position = transform.off


## Tries to open (or retarget) the window for city_id. Returns true when the window shows that city afterwards.
func try_open(city_id: String) -> bool:
	var reason := get_reject_reason(city_id)
	last_reject_reason = reason
	if not reason.is_empty():
		return false
	_open_city_id = city_id
	_ensure_window()
	_title_label.text = "%s — 성 안" % _city_display_name(city_id)
	_draw_city(city_id)
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
	_clear_canvas()   # lets the textures go
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
	_interior_area = Control.new()
	_interior_area.name = "InteriorArea"
	_interior_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_interior_area.clip_contents = true
	_interior_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_interior_area.resized.connect(func(): apply_canvas_transform(_interior_area.size))
	column.add_child(_interior_area)
	_placeholder = Label.new()
	_placeholder.name = "PlaceholderLabel"
	_placeholder.text = PLACEHOLDER_TEXT
	_placeholder.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_interior_area.add_child(_placeholder)
	_canvas = Control.new()
	_canvas.name = "InteriorCanvas"
	_canvas.size = Vector2(1280, 768)
	_canvas.clip_contents = true   # D7: items past the canvas edge are cut, as in the reference
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.visible = false
	_interior_area.add_child(_canvas)


## The castle layout when the city has one (background, then items in layout order), else the CH-2 placeholder.
func _draw_city(city_id: String) -> void:
	_clear_canvas()
	var has_layout := _layouts != null and bool(_layouts.has_layout(city_id))
	_placeholder.visible = not has_layout
	_canvas.visible = has_layout
	if not has_layout:
		return
	var layout: Dictionary = _layouts.get_layout(city_id)
	var background := str(layout.get("background", ""))
	if ResourceLoader.exists(background):
		_add_canvas_texture("Background", load(background), Vector2.ZERO, Vector2(1280, 768), false)
	var coastal := bool(main.call(COASTAL_CHECK, city_id))
	var region_style := str(layout.get("region_style", ""))
	for item in _layouts.items_for_city(city_id, coastal):
		var texture: Texture2D = null
		if str(item.get("kind", "")) == "building":
			if _building_assets != null:
				texture = _building_assets.load_texture(str(item.get("building_key", "")), region_style)
		else:
			var path := str(item.get("texture", ""))
			if ResourceLoader.exists(path):
				texture = load(path)
		if texture == null:
			continue   # missing art: skip the slot quietly
		var node := _add_canvas_texture("Item_%d_%s" % [int(item.get("z", 0)), str(item.get("building_key", ""))], texture,
			_layouts.item_top_left(item), Vector2(float(item.get("w", 0)), float(item.get("h", 0))), bool(item.get("flip_h", false)))
		node.set_meta("layout_item", item)
		_drawn_items.append(item)
	apply_canvas_transform(_interior_area.size)


func _add_canvas_texture(node_name: String, texture: Texture2D, top_left: Vector2, size: Vector2, flip: bool) -> TextureRect:
	var rect := TextureRect.new()
	rect.name = node_name
	rect.texture = texture
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.flip_h = flip
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.position = top_left
	rect.size = size
	_canvas.add_child(rect)
	return rect


func _clear_canvas() -> void:
	_drawn_items.clear()
	if _canvas == null:
		return
	for child in _canvas.get_children():
		_canvas.remove_child(child)
		child.free()
