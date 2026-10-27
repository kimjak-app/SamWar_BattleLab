extends CanvasLayer
# HUD block 3: the 2D enemy roster (EnemyRosterHud, five cards) copied as a 2D
# overlay above the 3D battlefield. It shows the cards handed to it by the
# scenario shell and reads nothing from the engine. The card rules follow the
# 2D: the roster bridge (battle_roster_hud_controller.gd _sync_slot) fills the
# portrait, name, "병력 %d / %d", troop icon, troop type name and status text
# (hidden when empty) and keeps the other card parts hidden; the enemy ready
# icon is always hidden (the engine only readies the active ally); the current
# actor gets the 2D gold frame (_apply_production_roster_actor_highlight).
const SLOT_NAMES := ["Slot01", "Slot02", "Slot03", "Reinforce01", "Reinforce02"]
const HIDDEN_PARTS := ["TroopBar", "ActionStateLabel", "UniqueSkillReadyLabel", "UnitTypeLabel", "TroopsLabel", "UniqueSkillReadyIcon"]
const ACTOR_FILL := Color(0.26, 0.2, 0.08, 0.96)
const ACTOR_BORDER := Color(1.0, 0.86, 0.46, 0.98)
# HUD block 6a: a retreated unit (troops 0; the 2D has no other retreat state) keeps its card, dimmed by the 2D tint
# (the 2D portrait-only roster's 0.62 / alpha 0.72; the expanded 2D card is not dimmed) with "퇴각" over its middle (the 2D
# card has no text; 김작's decision), bright: the text is a sibling over the card, not its child.
const RETREAT_TINT := Color(0.62, 0.62, 0.62, 0.72)
const RETREAT_TEXT := "퇴각"
const RETREAT_FONT := 30
var shown: Array = [] # last applied cards; the nodes change only when these change
var fold # block 6a: the side banner and the fold (battle3d_roster_fold.gd)
var apply_count := 0

func _ready() -> void:
	fold = preload("res://scripts/battle3d/battle3d_roster_fold.gd").new()
	add_child(fold)
	for index in SLOT_NAMES.size():
		for part in HIDDEN_PARTS:
			var node := slot(index).get_node_or_null(part) as Control
			if node != null: node.visible = false
	fold.setup("enemy", get_node("ProductionHudRoot"), get_node("ProductionHudRoot/EnemyRosterHud"), SLOT_NAMES.size())

func slot(index: int) -> Control:
	return get_node("ProductionHudRoot/EnemyRosterHud/%s" % SLOT_NAMES[index])

func roster_rect() -> Rect2:
	# Block 6a: folded, the portrait column and the banner.
	if fold.collapsed: return fold.folded_rect()
	return get_node("ProductionHudRoot/EnemyRosterHud").get_global_rect()

func show_cards(cards: Array) -> void:
	if cards == shown: return
	shown = cards.duplicate(true)
	apply_count += 1
	for index in SLOT_NAMES.size():
		var card: Dictionary = cards[index] if index < cards.size() else {}
		var node := slot(index)
		node.visible = bool(card.get("visible", false))
		if not node.visible: continue
		(node.get_node("Portrait") as TextureRect).texture = card.get("portrait")
		(node.get_node("NameLabel") as Label).text = str(card.get("name", ""))
		(node.get_node("HpLabel") as Label).text = str(card.get("troops_text", ""))
		var icon := node.get_node("TroopIconRect") as TextureRect
		icon.texture = card.get("troop_icon")
		icon.visible = icon.texture != null
		(node.get_node("TroopTypeLabel") as Label).text = str(card.get("type_name", ""))
		var status := node.get_node("StatusLabel") as Label
		status.text = str(card.get("status", ""))
		status.visible = status.text != ""
		_highlight(node, bool(card.get("actor", false)))
		if bool(card.get("retreated", false)): node.modulate = RETREAT_TINT
	for index in SLOT_NAMES.size():
		var card: Dictionary = cards[index] if index < cards.size() else {}
		retreat_label(index).visible = slot(index).visible and bool(card.get("retreated", false))
	fold.show_cards(cards, range(SLOT_NAMES.size()).map(func(i): return slot(i)))

func retreat_label(index: int) -> Label:
	# Block 6a: the "퇴각" text over card index (made once, mouse ignored).
	var roster := get_node("ProductionHudRoot/EnemyRosterHud")
	var label := roster.get_node_or_null("RetreatLabel%02d" % (index + 1)) as Label
	if label == null:
		label = Label.new()
		label.name = "RetreatLabel%02d" % (index + 1)
		label.text = RETREAT_TEXT
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", RETREAT_FONT)
		label.add_theme_color_override("font_color", Color(0.96, 0.92, 0.84))
		label.add_theme_color_override("font_outline_color", Color(0.05, 0.03, 0.02))
		label.add_theme_constant_override("outline_size", 6)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.visible = false
		roster.add_child(label)
	label.position = slot(index).position
	label.size = slot(index).size
	return label

func _highlight(node: Control, on: bool) -> void:
	node.remove_theme_stylebox_override(&"panel")
	node.modulate = Color.WHITE
	if not on: return
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(6)
	style.bg_color = ACTOR_FILL
	style.border_color = ACTOR_BORDER
	style.set_border_width_all(2)
	node.add_theme_stylebox_override(&"panel", style)
