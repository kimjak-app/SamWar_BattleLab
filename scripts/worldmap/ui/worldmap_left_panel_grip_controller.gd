class_name WorldMapLeftPanelGripController
extends Node

## CITY-HUD CH-2c: a visible grip strip at the top of main's left world status panel, so the panel can be dragged.
## Attached outside worldmap_main.gd as a root child of WorldMap.tscn (like the city interior controller). The strip is
## the first child of the panel's MarginContainer/Content VBox (a direct child would stretch over the whole
## PanelContainer). It is registered as one more drag handle through main's shared UI controller, so dragging, the
## on-screen clamp and the remembered user position are the existing ones (shared UI -> HudPositionOwner). Main is
## read only (get()/call()); the existing label handles are left as they are. The position is not saved.

const MAIN_META := "wm_left_panel_grip_controller"
const LEFT_PANEL_MEMBER := "left_world_status_panel"         # main, read only
const SHARED_UI_GETTER := "_ensure_shared_ui_controller"    # main, read only (returns the existing controller)
const CONTENT_PATH := "MarginContainer/Content"
const GRIP_NAME := "LeftPanelGrip"
const GRIP_HEIGHT := 14.0
const GRIP_COLOR := Color(0.86, 0.70, 0.38, 0.45)   # the panel's gold border family, low opacity
const DOT_RADIUS := 1.6
const DOT_SPACING := 7.0

@export var main_path: NodePath = NodePath("..")

var main: Node = null
var _grip: Control = null
var _panel: Control = null


func _ready() -> void:
	var m := get_node_or_null(main_path)
	if m == null or not m.has_method(SHARED_UI_GETTER):
		return
	var owner_node = m.get_meta(MAIN_META) if m.has_meta(MAIN_META) else null
	if owner_node != null and is_instance_valid(owner_node) and owner_node != self:
		return   # another controller already serves this main
	m.set_meta(MAIN_META, self)
	main = m
	if not main.is_node_ready():   # root child: main._ready builds and registers its panels after us
		await main.ready
	_install()


func _exit_tree() -> void:
	if main != null and is_instance_valid(main) and main.has_meta(MAIN_META) and main.get_meta(MAIN_META) == self:
		main.remove_meta(MAIN_META)


func get_grip() -> Control:
	return _grip


func get_panel() -> Control:
	return _panel


func _install() -> void:
	var panel = main.get(LEFT_PANEL_MEMBER)
	if not panel is Control:
		return
	var content := (panel as Control).get_node_or_null(CONTENT_PATH) as VBoxContainer
	if content == null or content.get_node_or_null(GRIP_NAME) != null:
		return
	var shared_ui = main.call(SHARED_UI_GETTER)
	if shared_ui == null or not shared_ui.has_method("register_draggable_panel"):
		return
	_panel = panel
	_grip = Control.new()
	_grip.name = GRIP_NAME
	_grip.custom_minimum_size = Vector2(0.0, GRIP_HEIGHT)
	_grip.mouse_filter = Control.MOUSE_FILTER_STOP
	_grip.mouse_default_cursor_shape = Control.CURSOR_MOVE
	_grip.tooltip_text = "끌어서 이동"
	_grip.draw.connect(_draw_grip)
	content.add_child(_grip)
	content.move_child(_grip, 0)
	shared_ui.register_draggable_panel(_panel, [_grip])


## A thin line along the bottom of the strip and three dots in the middle.
func _draw_grip() -> void:
	var size := _grip.size
	_grip.draw_line(Vector2(0.0, size.y - 1.0), Vector2(size.x, size.y - 1.0), GRIP_COLOR, 1.0)
	var centre := Vector2(size.x * 0.5, (size.y - 1.0) * 0.5)
	for i in [-1, 0, 1]:
		_grip.draw_circle(centre + Vector2(DOT_SPACING * i, 0.0), DOT_RADIUS, GRIP_COLOR)
