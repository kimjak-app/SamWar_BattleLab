extends CanvasLayer
# HUD spike: the 2D top HUD (momentum diamonds and turn) copied as a 2D overlay
# above the 3D battlefield. It only shows values handed to it by the scenario
# shell (the lab's momentum_display and current_round); it reads nothing from
# the engine and writes nothing. The fill mirrors the 2D controller's
# `_refresh_production_momentum_slots` and its "%d / %d" turn text.
const MAX_TURN := BattleHudStateAdapter.MAX_TURN
const SIDES := ["Ally", "Enemy"]
var shown := {} # last applied values; slots and label change only when these change
var apply_count := 0
var refresh := Callable() # set by the shell; called after the lab's own _process (process_priority)

func _ready() -> void:
	process_priority = 100 # after the lab, so a value the lab changes this frame shows this frame

func _process(_delta: float) -> void:
	if refresh.is_valid(): refresh.call()

func show_values(ally: int, enemy: int, round_value: int) -> void:
	var values := {"Ally":ally, "Enemy":enemy, "round":round_value}
	if values == shown: return
	shown = values
	apply_count += 1
	for side in SIDES: _fill_slots(side, values[side])
	turn_label().text = "%d / %d" % [round_value, MAX_TURN]

func frame_rect() -> Rect2:
	return get_node("ProductionHudRoot/TopHudRoot").get_global_rect()

func slot_row(side: String) -> Container:
	return get_node("ProductionHudRoot/TopHudRoot/%sMomentumHud/SlotRow" % side)

func turn_label() -> Label:
	return get_node("ProductionHudRoot/TopHudRoot/TurnHud/TurnLabel")

func slot(side: String, index: int) -> Panel:
	return slot_row(side).get_child(index).get_node("Slot%02d" % (index + 1))

func filled_count(side: String) -> int:
	var count := 0
	for index in slot_row(side).get_child_count():
		if slot(side, index).theme_type_variation == StringName("MomentumSlot%sFilled" % side): count += 1
	return count

func _fill_slots(side: String, value: int) -> void:
	for index in slot_row(side).get_child_count():
		var panel := slot(side, index)
		var active := index < value
		panel.theme_type_variation = "MomentumSlot%s%s" % [side, "Filled" if active else "Empty"]
		var style_key := "_diamond_filled_style" if active else "_diamond_empty_style"
		if panel.has_meta(style_key): panel.add_theme_stylebox_override(&"panel", panel.get_meta(style_key))
		panel.modulate = Color.WHITE
