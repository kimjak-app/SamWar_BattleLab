class_name WorldMapCityInteriorController
extends Node

## CITY-HUD CH-2: the city interior window frame. Attached outside worldmap_main.gd as a root child of WorldMap.tscn
## (like WorldMap3DHost). Listens to every city marker's `city_selected` (2D click and the 3D adapter's forwarded
## pick emit the same signal) with CONNECT_DEFERRED, so main's own handler has already run. Opens only for the
## player's own city when no target / turn / modal state is active; otherwise records why in last_reject_reason.
## Reads main state only (get()/call()), never writes it. Main is held as a plain Node; no WorldMap3D* classes are named.
## The window is built in code and is not modal (CH-2b): it docks to the right of main's left world status panel, top
## edges aligned, and everything outside it (map drag, wheel, other city clicks, camera keys) still reaches the map.
## HUDFIX: the window is the castle picture only (no title bar, close button or panel style). It closes on Esc or on a
## left click on the empty map: a left press that no HUD control took (it reaches _unhandled_input), released within
## CLICK_MOVE_LIMIT px of the press, that did not select a city by the time OUTSIDE_CLICK_SETTLE_FRAMES frames after the
## release have passed. A click that selects a city keeps the CH-2b city rules; a drag of CLICK_MOVE_LIMIT px or more
## (camera move) never closes.
## CH-3: a city with a castle layout (WorldMapCityInteriorLayouts) is drawn from it on a 1280x768 canvas scaled into
## the window's body; other cities keep the CH-2 placeholder.
## CH-4: which items are drawn follows the open city's completed city techs (main's completed snapshot, read only).
## Houses (decoration), life buildings (tech_id "") and the background always; a slot with slot_candidates draws the
## first completed candidate only (highest stage first), on the same foot point at that candidate's own image size;
## any other building only when its tech_id is completed. While open, _process compares the open city's snapshot with
## the one last drawn and redraws only when it changed. debug_show_all (debug builds: Ctrl+Shift+K while open) draws
## the whole layout as in CH-3.

const MAIN_META := "wm_city_interior_controller"
const WINDOW_LAYER := 50   # free between TopNav (40) and the tech tree overlay (60)
const TURN_PHASE_PLAYER := "player"
## CH-2b dock rule: width = viewport width x WINDOW_WIDTH_RATIO (at least MIN_WINDOW_WIDTH); the body keeps the 1280:768
## canvas ratio. Placed DOCK_GAP right of the left status panel; shrinks (not below the minimum) to clear the right panel.
const WINDOW_WIDTH_RATIO := 0.307
const DOCK_GAP := 12.0
const MIN_WINDOW_WIDTH := 400.0
const BODY_ASPECT := 768.0 / 1280.0
const FALLBACK_POSITION := Vector2(12, 12)   # the left panel is missing or hidden
const LEFT_PANEL_MEMBER := "left_world_status_panel"    # main, read only
const RIGHT_PANEL_MEMBER := "city_info_panel_control"   # main, read only
const PLACEHOLDER_TEXT := "건물 그림은 다음 단계에서 연결됩니다"
const BUILDING_ASSETS_PATH := "res://scripts/worldmap/ui/worldmap_city_building_assets.gd"
const LAYOUTS_PATH := "res://scripts/worldmap/ui/worldmap_city_interior_layouts.gd"
const COASTAL_CHECK := "_is_city_coastal_for_city_tech"   # main, read only
const CLICK_MOVE_LIMIT := 6.0               # px; the same limit as the 3D map's click-to-select (worldmap_camera.gd)
const OUTSIDE_CLICK_SETTLE_FRAMES := 2      # frames after the release for a city pick of the same click to arrive
const COMPLETED_SNAPSHOT := "_get_completed_city_domestic_tech_snapshot_mvp"   # main, read only: {tech_id: bool} copy
const DEBUG_SHOW_ALL_KEY := KEY_K           # with Ctrl+Shift, debug builds only, while open (no other use of K in the game)

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
	"_city_markers_by_id", "_is_city_owned_by_player_mvp", "_ensure_camera_controller",
	"_normalize_turn_phase", COASTAL_CHECK, LEFT_PANEL_MEMBER, RIGHT_PANEL_MEMBER, COMPLETED_SNAPSHOT,
]

@export var main_path: NodePath = NodePath("..")
## CH-4 developer switch: true draws every layout item (CH-3), ignoring the tech link. Redraws the open city when set.
var debug_show_all := false:
	set(value):
		if debug_show_all == value:
			return
		debug_show_all = value
		if is_open():
			_draw_city(_open_city_id)

var main: Node = null
var last_reject_reason := ""
var _open_city_id := ""
var _connected_markers: Array = []
var _layer: CanvasLayer = null
var _window: PanelContainer = null
var _dock_rect := Rect2()             # the last applied window rect (position, size)
var _outside_press := false            # a left press reached the map while open; waiting for its release
var _outside_press_at := Vector2.ZERO
var _city_picked_since_press := false
var _outside_settle_frames := -1       # >= 0: counting down to the close decision of a released map click
var _building_assets: Script = null
var _layouts: Script = null
var _placeholder: Label = null
var _interior_area: Control = null   # the window body; the canvas is scaled and centred in it
var _canvas: Control = null          # "InteriorCanvas", 1280x768 layout pixels
var _drawn_items: Array = []         # the layout item of each drawn node, in draw order (tests)
var _drawn_completed: Dictionary = {}   # the open city's completed snapshot the canvas was last drawn from
var _draw_count := 0                 # canvas draws so far (tests: no redraw while the snapshot is unchanged)


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
	if main != null and is_instance_valid(main) and main.has_meta(MAIN_META) and main.get_meta(MAIN_META) == self:
		main.remove_meta(MAIN_META)


func is_open() -> bool:
	return not _open_city_id.is_empty()


func get_open_city_id() -> String:
	return _open_city_id


func get_connected_marker_count() -> int:
	return _connected_markers.size()


func get_canvas() -> Control:
	return _canvas


func get_interior_area() -> Control:
	return _interior_area


func get_placeholder() -> Label:
	return _placeholder


func get_window_panel() -> PanelContainer:
	return _window


## The window rect the dock rule gives now: {position, width, body_width}. Width is the window's outer width.
func compute_dock() -> Dictionary:
	var viewport_size := get_viewport().get_visible_rect().size
	var width := maxf(viewport_size.x * WINDOW_WIDTH_RATIO, MIN_WINDOW_WIDTH)
	var position := FALLBACK_POSITION
	var left_panel := _main_control(LEFT_PANEL_MEMBER)
	if left_panel != null:
		var left_rect := left_panel.get_global_rect()
		position = Vector2(left_rect.end.x + DOCK_GAP, left_rect.position.y)
	var right_panel := _main_control(RIGHT_PANEL_MEMBER)
	if right_panel != null:
		var limit := right_panel.get_global_rect().position.x - DOCK_GAP
		if position.x + width > limit:
			width = maxf(limit - position.x, MIN_WINDOW_WIDTH)   # still overlapping at the minimum: left as is (M6)
	return {"position": position, "width": width, "body_width": width - _window_padding().x}


## The layout item of each drawn canvas node (background excluded), in draw order.
func get_drawn_items() -> Array:
	return _drawn_items.duplicate()


func get_draw_count() -> int:
	return _draw_count


## CH-4: the building key to draw for a layout item of city_id given that city's completed snapshot, "" = not drawn.
## compare_only and (inland) coastal_only items are already left out by WorldMapCityInteriorLayouts.items_for_city.
static func building_key_to_draw(item: Dictionary, completed: Dictionary, show_all: bool) -> String:
	var key := str(item.get("building_key", ""))
	if show_all or str(item.get("kind", "")) != "building" or str(item.get("tech_id", "")).is_empty():
		return key   # houses and life buildings always; everything with the debug switch
	var candidates: Variant = item.get("slot_candidates", null)
	if candidates is Array and not (candidates as Array).is_empty():
		for candidate in candidates:   # highest stage first
			if bool(completed.get(str(candidate), false)):
				return str(candidate)
		return ""   # no stage completed: the slot stays empty
	return key if bool(completed.get(str(item.get("tech_id", "")), false)) else ""


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
	_draw_city(city_id)
	_layer.visible = true
	_update_dock()
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
	_reset_outside_click()
	if _layer != null:
		_layer.visible = false
	_clear_canvas()   # lets the textures go


## Follows the left panel (dragged) and the viewport size while open; applies only when the rect changed.
func _process(_delta: float) -> void:
	if is_open():
		_update_dock()
		if not debug_show_all and _completed_snapshot(_open_city_id) != _drawn_completed:
			_draw_city(_open_city_id)   # a tech of the open city was completed (or lost) while open
		if _outside_settle_frames >= 0:
			_outside_settle_frames -= 1
			if _outside_settle_frames < 0:
				var picked := _city_picked_since_press
				_reset_outside_click()
				if not picked:
					close()


func _input(event: InputEvent) -> void:
	if not is_open():
		return
	var key := event as InputEventKey
	if event.is_action_pressed("ui_cancel") or (key != null and key.pressed and not key.echo and key.keycode == KEY_ESCAPE):
		close()
		get_viewport().set_input_as_handled()
		return
	if key != null and key.pressed and not key.echo and key.keycode == DEBUG_SHOW_ALL_KEY and key.ctrl_pressed and key.shift_pressed \
			and OS.is_debug_build():
		debug_show_all = not debug_show_all
		get_viewport().set_input_as_handled()
		return
	# The release of a map press: seen here (never consumed) wherever the pointer is now.
	var button := event as InputEventMouseButton
	if _outside_press and button != null and button.button_index == MOUSE_BUTTON_LEFT and not button.pressed:
		_outside_press = false
		if button.position.distance_to(_outside_press_at) < CLICK_MOVE_LIMIT:
			_outside_settle_frames = OUTSIDE_CLICK_SETTLE_FRAMES
		# a drag (camera move) of CLICK_MOVE_LIMIT px or more: not a click, the window stays


## A left press that no HUD control (the window, panels, top menu, turn button) took: a press on the map. Not consumed,
## so the map still does what the press does (city pick, camera).
func _unhandled_input(event: InputEvent) -> void:
	if not is_open():
		return
	var button := event as InputEventMouseButton
	if button != null and button.button_index == MOUSE_BUTTON_LEFT and button.pressed:
		_outside_press = true
		_outside_press_at = button.position
		_city_picked_since_press = false
		_outside_settle_frames = -1


func _reset_outside_click() -> void:
	_outside_press = false
	_city_picked_since_press = false
	_outside_settle_frames = -1


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
	_city_picked_since_press = true   # this click picked a city: the city rules below decide, not the empty-map close
	if not try_open(str(marker.get("city_id"))) and last_reject_reason == "not_own_city":
		close()   # CH-2b: a city that is not the player's closes the open window


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


func _marker_for(city_id: String) -> Node:
	var markers = main.get("_city_markers_by_id")
	if markers is Dictionary:
		var marker = (markers as Dictionary).get(city_id, null)
		if marker is Node and is_instance_valid(marker):
			return marker
	return null


## A visible main Control (read only), else null.
func _main_control(member: String) -> Control:
	var node = main.get(member) if main != null and is_instance_valid(main) else null
	if node is Control and is_instance_valid(node) and (node as Control).is_visible_in_tree():
		return node
	return null


## The window panel's own padding (style box content margins), so the body is the window width minus this.
func _window_padding() -> Vector2:
	if _window == null:
		return Vector2.ZERO
	var style := _window.get_theme_stylebox("panel")
	return style.get_minimum_size() if style != null else Vector2.ZERO


func _update_dock() -> void:
	if _window == null:
		return
	var dock := compute_dock()
	var body_width := float(dock.body_width)
	var rect := Rect2(dock.position, Vector2(float(dock.width), 0.0))
	if rect.position == _dock_rect.position and is_equal_approx(rect.size.x, _dock_rect.size.x):
		return
	_dock_rect = rect
	_interior_area.custom_minimum_size = Vector2(body_width, body_width * BODY_ASPECT)
	_window.position = rect.position
	_window.reset_size()   # the minimum size the body gives: the dock width


func _ensure_window() -> void:
	if _layer != null:
		return
	_layer = CanvasLayer.new()
	_layer.name = "CityInteriorCanvas"
	_layer.layer = WINDOW_LAYER
	_layer.visible = false
	add_child(_layer)
	# No full-screen blocker (CH-2b): the window eats clicks on itself only (PanelContainer default STOP).
	# HUDFIX: an empty panel style (no margin, border or background), so the window is exactly the castle picture.
	_window = PanelContainer.new()
	_window.name = "Window"
	_window.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_window.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	_layer.add_child(_window)
	_interior_area = Control.new()
	_interior_area.name = "InteriorArea"
	_interior_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_interior_area.clip_contents = true
	_interior_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_interior_area.resized.connect(func(): apply_canvas_transform(_interior_area.size))
	_window.add_child(_interior_area)
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
	_draw_count += 1
	_drawn_completed = _completed_snapshot(city_id)
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
		var key := building_key_to_draw(item, _drawn_completed, debug_show_all)
		if key.is_empty():
			continue   # CH-4: tech not completed (or no slot stage yet)
		var texture: Texture2D = null
		if str(item.get("kind", "")) == "building":
			if _building_assets != null:
				texture = _building_assets.load_texture(key, region_style)
		else:
			var path := str(item.get("texture", ""))
			if ResourceLoader.exists(path):
				texture = load(path)
		if texture == null:
			continue   # missing art: skip the slot quietly
		var top_left: Vector2 = _layouts.item_top_left(item)
		var size := Vector2(float(item.get("w", 0)), float(item.get("h", 0)))
		if key != str(item.get("building_key", "")):
			# another stage of the slot: its own image size x the layout scale, on the same foot point (ax, ay)
			size = texture.get_size() * float(item.get("scale", 1.0))
			top_left = Vector2(float(item.get("ax", 0)) - size.x * 0.5, float(item.get("ay", 0)) - size.y)
		var node := _add_canvas_texture("Item_%d_%s" % [int(item.get("z", 0)), key], texture, top_left, size,
			bool(item.get("flip_h", false)))
		node.set_meta("layout_item", item)
		node.set_meta("drawn_key", key)
		_drawn_items.append(item)
	apply_canvas_transform(_interior_area.size)


## main's completed city techs of city_id (a copy), {} when main does not answer.
func _completed_snapshot(city_id: String) -> Dictionary:
	if main == null or not is_instance_valid(main) or city_id.is_empty() or not main.has_method(COMPLETED_SNAPSHOT):
		return {}
	var value = main.call(COMPLETED_SNAPSHOT, city_id)
	return value if value is Dictionary else {}


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
