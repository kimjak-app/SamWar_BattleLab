extends CanvasLayer
# HUD block 4-6: one marker per unit, a screen overlay that follows the unit (the 2D battle's unit marker carried over):
# the general's face chip (the roster's portrait, ally blue / enemy red frame, gold when selected), the troop bar with
# "current / max" always shown, darkened once the unit has acted. Fixed pixel
# size (no zoom scaling). Every Control ignores the mouse, so clicks, the edge scroll and the camera pass through. Drawn
# on layer 0, under the lab's UI (1) and the shell's HUD (5 and up). Values only, handed over by the lab each sync (its
# display values and its approved portrait / status reads); no engine access here.
const LAYER := 0
const CHIP := 34.0 # px (2D badge 41; smaller so neighbouring markers keep apart: a cell is about 77 px at zoom 42)
const BAR := Vector2(60, 7) # px (2D HPBar 96 x 9, narrowed for the same reason)
const NUMBER_FONT := 13 # (2D TroopLabel 14)
const HEAD := 2.6 # m above the unit's ground point where the marker's bottom sits
const ALLY := Color("286496") # the unit's ground disc colours
const ENEMY := Color("a3402a")
const SELECTED := Color("ffd575") # the selection ring's gold
const BAR_BACK := Color(0.0157, 0.0275, 0.0431, 0.78) # the 2D bar colours
const BAR_ALLY := Color(0.1255, 0.7804, 1.0, 0.5882)
const BAR_ENEMY := Color(1.0, 0.2471, 0.3608, 0.5882)
const BAR_ALPHA := 0.8
const NUMBER_COLOR := Color(0.953, 0.918, 0.851)
const NUMBER_OUTLINE := Color(0.031, 0.063, 0.094)
const ACTED := Color(0.5, 0.5, 0.5, 1.0) # modulate of an acted unit's marker
const READY := Color(1, 1, 1, 1)
var markers := {} # unit_id -> Control

func _init() -> void:
	layer = LAYER
	name = "UnitMarkers"

func marker(unit_id: String) -> Control:
	if not markers.has(unit_id):
		var root := Control.new()
		root.name = "Marker_" + unit_id
		root.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.size = Vector2(BAR.x, CHIP + 3 + BAR.y + 18)
		var frame := Panel.new()
		frame.name = "Chip"
		frame.position = Vector2((BAR.x - CHIP) * 0.5, 0)
		frame.size = Vector2(CHIP, CHIP)
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.05, 0.06, 0.08, 0.9)
		style.set_border_width_all(2)
		style.set_corner_radius_all(4)
		frame.add_theme_stylebox_override("panel", style)
		root.add_child(frame)
		var face := TextureRect.new()
		face.name = "Face"
		face.position = Vector2(2, 2)
		face.size = Vector2(CHIP - 4, CHIP - 4)
		face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		face.clip_contents = true
		frame.add_child(face)
		var back := ColorRect.new()
		back.name = "BarBack"
		back.color = BAR_BACK
		back.position = Vector2(0, CHIP + 3)
		back.size = BAR
		root.add_child(back)
		var fill := ColorRect.new()
		fill.name = "BarFill"
		fill.position = back.position
		fill.size = BAR
		root.add_child(fill)
		var number := Label.new()
		number.name = "Troops"
		number.position = Vector2(0, CHIP + 3 + BAR.y)
		number.size = Vector2(BAR.x, 18)
		number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		number.add_theme_font_size_override("font_size", NUMBER_FONT)
		number.add_theme_color_override("font_color", NUMBER_COLOR)
		number.add_theme_color_override("font_outline_color", NUMBER_OUTLINE)
		number.add_theme_constant_override("outline_size", 3)
		root.add_child(number)
		for node in [root, frame, face, back, fill, number]: (node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(root)
		markers[unit_id] = root
	return markers[unit_id]

func show_unit(unit_id: String, value: Dictionary, portrait: Texture2D, selected: bool, anchor: Vector2, on_screen: bool) -> void:
	# value: the lab's 14-field display value; anchor: the screen point under the marker's bottom centre.
	var root := marker(unit_id)
	root.visible = on_screen and not value.is_empty() and int(value.get("current_troops", 0)) > 0
	if not root.visible: return
	var ally: bool = value.get("side", "") == "ally"
	var frame: Panel = root.get_node("Chip")
	var style: StyleBoxFlat = frame.get_theme_stylebox("panel")
	style.border_color = SELECTED if selected else (ALLY if ally else ENEMY)
	style.set_border_width_all(3 if selected else 2)
	(frame.get_node("Face") as TextureRect).texture = portrait
	var current := int(value.get("current_troops", 0))
	var most := maxi(1, int(value.get("max_troops", 0)))
	var fill: ColorRect = root.get_node("BarFill")
	fill.size = Vector2(BAR.x * clampf(float(current) / float(most), 0.0, 1.0), BAR.y)
	fill.color = BAR_ALLY if ally else BAR_ENEMY
	(root.get_node("BarBack") as ColorRect).modulate.a = BAR_ALPHA
	fill.modulate.a = BAR_ALPHA
	(root.get_node("Troops") as Label).text = "%d / %d" % [current, int(value.get("max_troops", 0))]
	root.modulate = ACTED if bool(value.get("has_acted", false)) else READY
	root.position = (anchor - Vector2(root.size.x * 0.5, root.size.y)).round()
