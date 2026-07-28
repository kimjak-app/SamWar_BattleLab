#!/usr/bin/env python3
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
PATH = ROOT / 'scripts/battle_web_import_test.gd'
text = PATH.read_text(encoding='utf-8')

if 'var momentum_feedback_label: Label = null' not in text:
    text = text.replace(
        'var momentum_enemy_label: Label = null\n',
        'var momentum_enemy_label: Label = null\nvar momentum_feedback_label: Label = null\n'
    )

replacement = r'''func _update_momentum_ui() -> void:
	_ensure_momentum_hud()
	var ally_value := battle_momentum.get_value("ally")
	var enemy_value := battle_momentum.get_value("enemy")
	if momentum_ally_label != null:
		momentum_ally_label.text = "아군 기세 ◆ %d/%d" % [ally_value, BattleMomentumStateScript.MAX_MOMENTUM]
	if momentum_enemy_label != null:
		momentum_enemy_label.text = "적군 기세 ◆ %d/%d" % [enemy_value, BattleMomentumStateScript.MAX_MOMENTUM]
	_show_momentum_delta_if_changed(ally_value, enemy_value)


func _ensure_momentum_hud() -> void:
	if momentum_ally_label != null and is_instance_valid(momentum_ally_label) \
			and momentum_enemy_label != null and is_instance_valid(momentum_enemy_label):
		return
	var layer := CanvasLayer.new()
	layer.name = "RuntimeMomentumHudLayer"
	layer.layer = 90
	add_child(layer)
	var panel := PanelContainer.new()
	panel.name = "RuntimeMomentumHud"
	panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	panel.position = Vector2(-250.0, 14.0)
	panel.size = Vector2(500.0, 82.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(panel)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(box)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 42)
	box.add_child(row)
	momentum_ally_label = Label.new()
	momentum_ally_label.name = "AllyMomentumLabel"
	momentum_ally_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	momentum_ally_label.add_theme_font_size_override("font_size", 22)
	momentum_ally_label.add_theme_color_override("font_color", Color(0.55, 0.78, 1.0, 1.0))
	row.add_child(momentum_ally_label)
	momentum_enemy_label = Label.new()
	momentum_enemy_label.name = "EnemyMomentumLabel"
	momentum_enemy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	momentum_enemy_label.add_theme_font_size_override("font_size", 22)
	momentum_enemy_label.add_theme_color_override("font_color", Color(1.0, 0.52, 0.44, 1.0))
	row.add_child(momentum_enemy_label)
	momentum_feedback_label = Label.new()
	momentum_feedback_label.name = "MomentumFeedbackLabel"
	momentum_feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	momentum_feedback_label.add_theme_font_size_override("font_size", 18)
	momentum_feedback_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.34, 1.0))
	momentum_feedback_label.modulate.a = 0.0
	box.add_child(momentum_feedback_label)


func _show_momentum_delta_if_changed(ally_value: int, enemy_value: int) -> void:
	var previous_ally := int(get_meta("momentum_hud_prev_ally", ally_value))
	var previous_enemy := int(get_meta("momentum_hud_prev_enemy", enemy_value))
	set_meta("momentum_hud_prev_ally", ally_value)
	set_meta("momentum_hud_prev_enemy", enemy_value)
	if momentum_feedback_label == null:
		return
	var parts: Array[String] = []
	if previous_ally != ally_value:
		parts.append("아군 %d → %d (%+d)" % [previous_ally, ally_value, ally_value - previous_ally])
	if previous_enemy != enemy_value:
		parts.append("적군 %d → %d (%+d)" % [previous_enemy, enemy_value, enemy_value - previous_enemy])
	if parts.is_empty():
		return
	momentum_feedback_label.text = "기세  " + "   |   ".join(parts)
	momentum_feedback_label.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_interval(1.35)
	tween.tween_property(momentum_feedback_label, "modulate:a", 0.0, 0.35)
'''

pattern = re.compile(r'^func _update_momentum_ui\(\) -> void:\n.*?(?=^func |\Z)', re.M | re.S)
match = pattern.search(text)
if not match:
    raise SystemExit('missing _update_momentum_ui')
text = text[:match.start()] + replacement + '\n\n' + text[match.end():]
PATH.write_text(text, encoding='utf-8')

validator = ROOT / 'tools/validate_t06_t07_playable_transaction.py'
v = validator.read_text(encoding='utf-8')
needle = 'require(errors, "기세 %d" in battle and "AllyMomentumLabel" in battle,\n            "player momentum/cost UI evidence missing")'
replacement_v = 'require(errors, "AllyMomentumLabel" in battle and "EnemyMomentumLabel" in battle and "MomentumFeedbackLabel" in battle,\n            "persistent momentum HUD or spend feedback missing")'
if needle in v:
    v = v.replace(needle, replacement_v)
elif 'persistent momentum HUD or spend feedback missing' not in v:
    raise SystemExit('momentum UI validator anchor missing')
validator.write_text(v, encoding='utf-8')

print('T06-7-hotfix2 momentum HUD applied')
