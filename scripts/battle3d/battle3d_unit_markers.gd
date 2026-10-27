extends CanvasLayer
# HUD block 4-6: one marker per unit, a screen overlay that follows the unit (the 2D battle's unit marker carried over):
# the general's face chip (the roster's portrait, ally blue / enemy red frame, gold when selected), the troop bar with
# "current / max" always shown, darkened once the unit has acted, and up to three status badges (block 4-6 C). Every
# Control ignores the mouse, so clicks, the edge scroll and the camera pass through. Drawn on layer 0, under the lab's UI
# (1) and the shell's HUD (5 and up). Values only, handed over by the lab each sync (its display values and its approved
# portrait / status reads); no engine access here.
# HUD block 4-6b: placed and sized like the 2D marker. The face chip sits over the unit's upper right; the bar and the
# number sit under the unit's ground disc, about as wide as the unit. Sizes follow the unit's on-screen cell width
# (cell_px, measured by the lab from the camera projection), so they grow when the camera zooms in, within these limits.
const LAYER := 0
const CHIP_FRAC := 0.55 # face chip side = clamp(0.55 x cell_px, 34, 80) px
const CHIP_MIN := 34.0
const CHIP_MAX := 80.0
const CHIP_RIGHT := 0.38 # chip centre = body point + (0.38, -0.55) x cell_px (body: 1 m above the unit's ground point)
const CHIP_UP := 0.55
const BAR_FRAC := 0.90 # bar width = clamp(0.90 x cell_px, 60, 150) px, height 0.09 x width (at least 7 px)
const BAR_MIN := 60.0
const BAR_MAX := 150.0
const BAR_HEIGHT_FRAC := 0.09
const BAR_HEIGHT_MIN := 7.0
const BAR_GAP := 2.0 # px from the ground disc's lower screen edge to the bar's top
const FONT_FRAC := 0.17 # number and badge font = clamp(round(0.17 x cell_px), 13, 22) pt
const FONT_MIN := 13
const FONT_MAX := 22
const BODY_HEIGHT := 1.0 # m above the unit's ground point: the body point the chip is placed from
const DISC_RADIUS := 1.27 # m (the selection ring): the disc's lower screen edge is measured this far toward the camera
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
const MAX_BADGES := 3
const BADGE_COLORS := {"◎":Color(0.48, 0.92, 1.0), "⚠":Color(1.0, 0.76, 0.28), "◆":Color(0.52, 0.70, 0.90), "▲":Color(1.0, 0.70, 0.28), "▼":Color(0.92, 0.36, 0.26)}
const BADGE_DEFAULT := Color(0.62, 0.82, 0.96)
const Z_BAR := 0 # drawing order: bars and numbers < chips and badges < the selected unit's marker
const Z_CHIP := 1
const Z_SELECTED := 2
var markers := {} # unit_id -> Control

func _init() -> void:
	layer = LAYER
	name = "UnitMarkers"

static func layout(foot: Vector2, body: Vector2, disc_bottom: Vector2, cell_px: float) -> Dictionary:
	# Screen layout from the lab's projected points: foot (the unit's ground point), body (BODY_HEIGHT up), disc_bottom
	# (the ground disc's lower screen edge) and cell_px (one cell's on-screen width).
	var chip := clampf(CHIP_FRAC * cell_px, CHIP_MIN, CHIP_MAX)
	var chip_centre := body + Vector2(CHIP_RIGHT * cell_px, -CHIP_UP * cell_px)
	var bar_w := clampf(BAR_FRAC * cell_px, BAR_MIN, BAR_MAX)
	var bar_h := maxf(BAR_HEIGHT_MIN, roundf(BAR_HEIGHT_FRAC * bar_w))
	var font := clampi(roundi(FONT_FRAC * cell_px), FONT_MIN, FONT_MAX)
	var bar := Rect2(Vector2(foot.x - bar_w * 0.5, disc_bottom.y + BAR_GAP), Vector2(bar_w, bar_h))
	return {"chip":Rect2(chip_centre - Vector2(chip, chip) * 0.5, Vector2(chip, chip)), "chip_centre":chip_centre, "bar":bar, "font":font,
		"number":Rect2(Vector2(bar.position.x, bar.end.y), Vector2(bar_w, font + 6))}

func marker(unit_id: String) -> Control:
	if not markers.has(unit_id):
		var root := Control.new()
		root.name = "Marker_" + unit_id
		var frame := Panel.new()
		frame.name = "Chip"
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.05, 0.06, 0.08, 0.9)
		style.set_border_width_all(2)
		style.set_corner_radius_all(4)
		frame.add_theme_stylebox_override("panel", style)
		root.add_child(frame)
		var face := TextureRect.new()
		face.name = "Face"
		face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		face.clip_contents = true
		frame.add_child(face)
		var back := ColorRect.new()
		back.name = "BarBack"
		back.color = BAR_BACK
		root.add_child(back)
		var fill := ColorRect.new()
		fill.name = "BarFill"
		root.add_child(fill)
		var number := Label.new()
		number.name = "Troops"
		number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		number.add_theme_color_override("font_color", NUMBER_COLOR)
		number.add_theme_color_override("font_outline_color", NUMBER_OUTLINE)
		number.add_theme_constant_override("outline_size", 3)
		root.add_child(number)
		var badges := HBoxContainer.new()
		badges.name = "Badges"
		badges.add_theme_constant_override("separation", 2)
		root.add_child(badges)
		for node in [root, frame, face, back, fill, number, badges]: (node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(root)
		markers[unit_id] = root
	return markers[unit_id]

func rect_of(unit_id: String) -> Rect2:
	# HUD block 4-6b: the marker's screen area (chip + badges + bar + number), for the command panel to keep clear of;
	# an empty rect when the marker is hidden.
	if not markers.has(unit_id) or not markers[unit_id].visible: return Rect2()
	var root: Control = markers[unit_id]
	var area: Rect2 = root.get_node("Chip").get_global_rect().merge(root.get_node("BarBack").get_global_rect()).merge(root.get_node("Troops").get_global_rect())
	for badge in root.get_node("Badges").get_children():
		if badge.visible: area = area.merge(badge.get_global_rect())
	return area

func show_unit(unit_id: String, value: Dictionary, portrait: Texture2D, selected: bool, status_badges: Array, geometry: Dictionary, on_screen: bool) -> void:
	# value: the lab's 14-field display value; geometry: {foot, body, disc_bottom, cell_px} (see layout()); on_screen: the
	# unit is in front of the camera and its chip centre is inside the window.
	var root := marker(unit_id)
	root.visible = on_screen and not value.is_empty() and int(value.get("current_troops", 0)) > 0
	if not root.visible: return
	var place := layout(geometry.foot, geometry.body, geometry.disc_bottom, geometry.cell_px)
	var ally: bool = value.get("side", "") == "ally"
	var frame: Panel = root.get_node("Chip")
	var chip: Rect2 = place.chip
	frame.position = chip.position.round()
	frame.size = chip.size.round()
	var face: TextureRect = frame.get_node("Face")
	face.position = Vector2(2, 2)
	face.size = frame.size - Vector2(4, 4)
	face.texture = portrait
	var style: StyleBoxFlat = frame.get_theme_stylebox("panel")
	style.border_color = SELECTED if selected else (ALLY if ally else ENEMY)
	style.set_border_width_all(3 if selected else 2)
	var bar: Rect2 = place.bar
	var back: ColorRect = root.get_node("BarBack")
	back.position = bar.position.round()
	back.size = bar.size.round()
	var current := int(value.get("current_troops", 0))
	var most := maxi(1, int(value.get("max_troops", 0)))
	var fill: ColorRect = root.get_node("BarFill")
	fill.position = back.position
	fill.size = Vector2(back.size.x * clampf(float(current) / float(most), 0.0, 1.0), back.size.y)
	fill.color = BAR_ALLY if ally else BAR_ENEMY
	back.modulate.a = BAR_ALPHA
	fill.modulate.a = BAR_ALPHA
	var number: Label = root.get_node("Troops")
	number.text = "%d / %d" % [current, int(value.get("max_troops", 0))]
	number.add_theme_font_size_override("font_size", place.font)
	number.position = (place.number as Rect2).position.round()
	number.size = (place.number as Rect2).size.round()
	var badges: HBoxContainer = root.get_node("Badges")
	badges.position = Vector2(frame.position.x + frame.size.x + 3, frame.position.y)
	_show_badges(badges, status_badges, place.font)
	var lift := Z_SELECTED if selected else 0
	for node in [back, fill, number]: node.z_index = Z_BAR + lift
	for node in [frame, badges]: node.z_index = Z_CHIP + lift
	root.modulate = ACTED if bool(value.get("has_acted", false)) else READY

func _show_badges(row: HBoxContainer, status_badges: Array, font: int) -> void:
	# Block 4-6 C: the engine's own badge glyphs (◎2, ⚠1, ◆, ▲, ▼3 ...), at most three, then "+n"; block 4-6b: in the
	# number's font size.
	var texts: Array = status_badges.slice(0, MAX_BADGES)
	if status_badges.size() > MAX_BADGES: texts.append("+%d" % (status_badges.size() - MAX_BADGES))
	while row.get_child_count() < texts.size():
		var label := Label.new()
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_theme_color_override("font_outline_color", NUMBER_OUTLINE)
		label.add_theme_constant_override("outline_size", 4)
		row.add_child(label)
	for i in range(row.get_child_count()):
		var label: Label = row.get_child(i)
		label.visible = i < texts.size()
		if not label.visible: continue
		label.text = str(texts[i])
		label.add_theme_font_size_override("font_size", font)
		label.add_theme_color_override("font_color", BADGE_COLORS.get(label.text.left(1), BADGE_DEFAULT))
