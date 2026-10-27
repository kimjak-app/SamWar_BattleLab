extends Node
# HUD block 6a: the 2D roster side banner (깃발) and its fold, carried over from the 2D production roster
# (battle_roster_presentation_controller.gd, ProductionRosterCollapseExperiment; Battle_Production.tscn
# AllyRosterSideBanner / EnemyRosterSideBanner). One per roster; values only, no engine access.
#   - the banner: the 2D texture and place (ProductionHudRoot offsets 350,121 / 1507,124, 60 x 126), takes the mouse;
#   - a left press folds the roster: one 0.30 s cubic in-out tween fades the roster out, fades a portrait-only column
#     in and moves the banner to its folded place (4,115 / 1856,115); then the roster is hidden. Pressed again: the
#     reverse. Presses during a tween are ignored. Expanded by default; this run only (no option is saved yet);
#   - the column: per card a 72 x 72 portrait at x 8 / 1840, y 250 + 78 x slot, with the card's gold frame (76 x 76)
#     behind it for the actor; a retreated unit's portrait is tinted (0.62, 0.62, 0.62, 0.72), no text (as in the 2D);
#   - the banner pulses on each turn change (scale 1.5 in 0.18 s, back in 0.26 s), as the 2D banner does.
# Differences kept from the 3D roster [block 6a report]: a portrait is shown only for a card the 3D roster shows (the
# 2D also shows reinforcements not arrived yet, dimmed: N9, unchanged here); the ally portraits do not take clicks
# (the 2D selects that ally, an engine command the 3D roster does not have).
const TRANSITION_DURATION := 0.30
const PORTRAIT_SIZE := Vector2(72.0, 72.0)
const PORTRAIT_STEP := 78.0
const PORTRAIT_TOP := 250.0
const PORTRAIT_X := {"ally":8.0, "enemy":1840.0}
const BANNER_SIZE := Vector2(60.0, 126.0)
const BANNER_EXPANDED := {"ally":Vector2(350.0, 121.0), "enemy":Vector2(1507.0, 124.0)}
const BANNER_FOLDED := {"ally":Vector2(4.0, 115.0), "enemy":Vector2(1856.0, 115.0)}
const BANNER_TEXTURE := {"ally":"res://assets/ui/battle/production_hud/roster/roster_side_banner_ally.png",
	"enemy":"res://assets/ui/battle/production_hud/roster/roster_side_banner_enemy.png"}
const RETREAT_TINT := Color(0.62, 0.62, 0.62, 0.72) # _portrait_status_modulate
const PULSE_SCALE := Vector2(1.5, 1.5)
var side := ""
var root: Control # ProductionHudRoot
var roster: Control
var banner: TextureRect
var overlay: Control
var items := [] # [{border, portrait}] per slot
var collapsed := false
var transitioning := false
var tween: Tween
var pulse_tween: Tween

func setup(roster_side: String, hud_root: Control, roster_panel: Control, slot_count: int) -> void:
	side = roster_side
	root = hud_root
	roster = roster_panel
	banner = TextureRect.new()
	banner.name = "%sRosterSideBanner" % side.capitalize()
	banner.texture = load(BANNER_TEXTURE[side])
	banner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	banner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	banner.position = BANNER_EXPANDED[side]
	banner.size = BANNER_SIZE
	banner.mouse_filter = Control.MOUSE_FILTER_STOP
	banner.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	banner.gui_input.connect(_on_banner_input)
	root.add_child(banner)
	overlay = Control.new()
	overlay.name = "%sRosterPortraitOnlyLayer" % side.capitalize()
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.visible = false
	root.add_child(overlay)
	for index in range(slot_count):
		var border := Panel.new()
		border.name = "%sPortraitBorder%02d" % [side.capitalize(), index + 1]
		border.position = portrait_position(index) - Vector2(2, 2)
		border.size = PORTRAIT_SIZE + Vector2(4, 4)
		border.mouse_filter = Control.MOUSE_FILTER_IGNORE
		border.visible = false
		overlay.add_child(border)
		var portrait := TextureRect.new()
		portrait.name = "%sPortraitOnly%02d" % [side.capitalize(), index + 1]
		portrait.position = portrait_position(index)
		portrait.size = PORTRAIT_SIZE
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
		portrait.visible = false
		overlay.add_child(portrait)
		items.append({"border":border, "portrait":portrait})

func portrait_position(index: int) -> Vector2:
	return Vector2(PORTRAIT_X[side], PORTRAIT_TOP + PORTRAIT_STEP * index)

func banner_rect() -> Rect2:
	return banner.get_global_rect()

func folded_rect() -> Rect2:
	# The folded roster's screen area: the portrait column (frames included) and the banner at its folded place.
	var area := Rect2(root.global_position + portrait_position(0) - Vector2(2, 2), Vector2(PORTRAIT_SIZE.x + 4, PORTRAIT_STEP * (items.size() - 1) + PORTRAIT_SIZE.y + 4))
	return area.merge(Rect2(root.global_position + BANNER_FOLDED[side], BANNER_SIZE))

func show_cards(cards: Array, slots: Array) -> void:
	# The column follows the roster's cards (refreshed while folded too): portrait, retreat tint, the actor's frame.
	for index in range(items.size()):
		var card: Dictionary = cards[index] if index < cards.size() else {}
		var portrait: TextureRect = items[index].portrait
		var border: Panel = items[index].border
		portrait.visible = bool(card.get("visible", false))
		portrait.texture = card.get("portrait")
		portrait.modulate = RETREAT_TINT if bool(card.get("retreated", false)) else Color.WHITE
		border.visible = portrait.visible and bool(card.get("actor", false))
		if border.visible: border.add_theme_stylebox_override(&"panel", (slots[index] as Control).get_theme_stylebox(&"panel"))

func _on_banner_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		toggle()
		banner.accept_event()

func toggle() -> void:
	if transitioning: return
	transitioning = true
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	if not collapsed:
		overlay.visible = true
		overlay.modulate = Color(1, 1, 1, 0)
		tween.parallel().tween_property(roster, "modulate:a", 0.0, TRANSITION_DURATION)
		tween.parallel().tween_property(overlay, "modulate:a", 1.0, TRANSITION_DURATION)
		tween.parallel().tween_property(banner, "position", BANNER_FOLDED[side], TRANSITION_DURATION)
	else:
		roster.visible = true
		roster.modulate.a = 0.0
		tween.parallel().tween_property(roster, "modulate:a", 1.0, TRANSITION_DURATION)
		tween.parallel().tween_property(overlay, "modulate:a", 0.0, TRANSITION_DURATION)
		tween.parallel().tween_property(banner, "position", BANNER_EXPANDED[side], TRANSITION_DURATION)
	tween.tween_callback(_finish)

func _finish() -> void:
	collapsed = not collapsed
	transitioning = false
	roster.visible = not collapsed
	roster.modulate.a = 1.0
	overlay.visible = collapsed
	overlay.modulate = Color.WHITE

func pulse() -> void:
	# The 2D turn-change pulse (_pulse_roster_side_banner).
	if pulse_tween != null and pulse_tween.is_valid(): pulse_tween.kill()
	banner.scale = Vector2.ONE
	banner.pivot_offset = banner.size * 0.5
	pulse_tween = create_tween()
	pulse_tween.tween_property(banner, "scale", PULSE_SCALE, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	pulse_tween.tween_property(banner, "scale", Vector2.ONE, 0.26).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	pulse_tween.tween_callback(func(): banner.scale = Vector2.ONE)
