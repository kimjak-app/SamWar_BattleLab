extends CanvasLayer
# HUD block 2: the 2D battle log panel (BattleLogHud, "전투 기록", the latest
# four engine log lines) copied as a 2D overlay above the 3D battlefield. It
# shows the lines handed to it by the scenario shell, joined like the 2D
# (battle_web_import_test.gd `_refresh_production_battle_hud`:
# "\n".join(recent_log)); it reads nothing from the engine and writes nothing.
var shown: Array = [] # last applied lines; the label changes only when these change
var apply_count := 0

func show_lines(lines: Array) -> void:
	if lines == shown: return
	shown = lines.duplicate()
	apply_count += 1
	log_label().text = "\n".join(lines)

func log_label() -> Label:
	return get_node("ProductionHudRoot/BattleLogHud/RecentLogLabel")

func panel_rect() -> Rect2:
	return get_node("ProductionHudRoot/BattleLogHud").get_global_rect()
