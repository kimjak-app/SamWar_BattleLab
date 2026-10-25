extends CanvasLayer
# HUD block 4-1: the 2D ally roster (AllyRosterHud, five cards) copied as a 2D
# overlay above the 3D battlefield, like the block 3 enemy roster. It shows the
# cards handed to it by the scenario shell and reads nothing from the engine.
# The card rules follow the 2D roster bridge (battle_roster_hud_controller.gd
# _sync_slot): portrait, name, "병력 %d / %d", troop icon, troop type name,
# status text (hidden when empty) and the unique-skill ready icon (only the
# active ally, engine _can_use_unique_skill); the other card parts stay hidden.
# The ally actor gets the 2D gold frame (_apply_production_roster_actor_highlight).
# Every node ignores the mouse: the roster lies over the lab's info box and
# action/facing buttons, which stay in use until block 4-2.
const SLOT_NAMES := ["Slot01", "Slot02", "Slot03", "Reinforce01", "Reinforce02"]
const HIDDEN_PARTS := ["TroopBar", "ActionStateLabel", "UniqueSkillReadyLabel", "UnitTypeLabel", "TroopsLabel"]
const ACTOR_FILL := Color(0.26, 0.2, 0.08, 0.96)
const ACTOR_BORDER := Color(1.0, 0.86, 0.46, 0.98)
var shown: Array = [] # last applied cards; the nodes change only when these change
var apply_count := 0

func _ready() -> void:
	_ignore_mouse(get_node("ProductionHudRoot"))
	for index in SLOT_NAMES.size():
		for part in HIDDEN_PARTS:
			var node := slot(index).get_node_or_null(part) as Control
			if node != null: node.visible = false
		(slot(index).get_node("UniqueSkillReadyIcon") as Control).visible = false

func _ignore_mouse(node: Node) -> void:
	if node is Control: (node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children(): _ignore_mouse(child)

func slot(index: int) -> Control:
	return get_node("ProductionHudRoot/AllyRosterHud/%s" % SLOT_NAMES[index])

func roster_rect() -> Rect2:
	return get_node("ProductionHudRoot/AllyRosterHud").get_global_rect()

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
		(node.get_node("UniqueSkillReadyIcon") as Control).visible = bool(card.get("ready", false))
		_highlight(node, bool(card.get("actor", false)))

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
