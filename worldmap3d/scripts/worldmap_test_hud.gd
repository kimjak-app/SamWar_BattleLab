## EASTWAR WorldMap3D v2.3 — test scene HUD (worldmap3d/scenes/worldmap3d_eastasia_v2_3_test.tscn).
##  F2 = toggle camera input scheme A/B (start value: map_config camera.input_scheme)
##  F3 = toggle CAPTURED state (hanseong=player captures pyeongyang, wei captures luoyang) -> same-faction inner borders
##  F4 = new-game owners (13 different factions)
##  The text field (top right) tests external_input_block: while it has focus WASD/QE are ignored.
##  Left click = select (shows the region/city under the cursor).
extends Node

@export var start_captured := false
const CAPTURE := {"pyeongyang": "player", "luoyang": "wei"}

var root: WorldMap3DRoot
var label: Label
var field: LineEdit
var captured := false
var orig := {}
var sel_text := "-"

func _ready() -> void:
	root = $WorldMap3DEastAsia
	if not root.stats.has("map_id"):
		await root.map_built
	for cid in CAPTURE:
		orig[cid] = root.regions.owner_of_city(cid)
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	label = Label.new()
	label.position = Vector2(16, 12)
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	label.add_theme_constant_override("outline_size", 6)
	var f := load("res://worldmap3d/fonts/NotoSerifKR-Bold-subset.otf")
	if f:
		label.add_theme_font_override("font", f)
	layer.add_child(label)
	field = LineEdit.new()
	field.placeholder_text = "UI 입력 테스트 (포커스 중 WASD/QE 무시)"
	field.size = Vector2(380, 34)
	field.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	field.position = Vector2(get_viewport().get_visible_rect().size.x - 396, 12)
	field.focus_entered.connect(func(): root.camera.external_input_block = true)
	field.focus_exited.connect(func(): root.camera.external_input_block = false)
	field.text_submitted.connect(func(_t): field.release_focus())
	layer.add_child(field)
	root.city_selected.connect(func(cid, r): sel_text = "%s (region %d, owner %s)" % [cid if cid != "" else "중립", r, root.regions.owner_of_city(cid) if cid != "" else "-"])
	if start_captured:
		set_captured(true)
	_refresh()

func set_captured(on: bool) -> void:
	captured = on
	for cid in CAPTURE:
		root.set_city_owner(cid, CAPTURE[cid] if on else orig[cid])

func _unhandled_key_input(e: InputEvent) -> void:
	if not (e is InputEventKey and e.pressed and not e.echo):
		return
	match e.keycode:
		KEY_F2:
			root.camera.toggle_input_scheme()
		KEY_F3:
			set_captured(not captured)
		KEY_F4:
			set_captured(false)
		KEY_ESCAPE:
			field.release_focus()

func _process(_dt: float) -> void:
	_refresh()

func _refresh() -> void:
	if label == null:
		return
	label.text = "%s   [F2 전환]\n상태: %s   [F3 점령 전환 / F4 새 게임]\n키보드 차단(external_input_block): %s\n선택: %s" % [
		root.camera.input_scheme_text(),
		"점령 (한성=평양 점령, 위=낙양 점령 -> 같은 세력 내부 경계)" if captured else "새 게임 (13개 도시 모두 다른 세력 -> 굵은 국경)",
		"켜짐" if root.camera.keys_blocked() else "꺼짐", sel_text]
