extends Node

## ISO test-only guard for battlefield READY panels.
##
## The production setup styles AllyReadyFrame and AllySupportReadyFrame, but
## AllyMain03ReadyFrame and the two reinforcement READY panels are left with
## Godot's default Panel theme. Those unstyled 116x116 panels still participate
## in the READY pulse, which makes a dark square flash behind the unit visuals.
## Apply the same intended gold translucent style to all five ally READY panels.

const READY_FRAME_PATHS := [
	"BattleUI/AllyReadyFrame",
	"BattleUI/AllySupportReadyFrame",
	"BattleUI/AllyMain03ReadyFrame",
	"BattleUI/AllyReinforce01ReadyFrame",
	"BattleUI/AllyReinforce02ReadyFrame",
]


func _ready() -> void:
	var battle_root := get_parent()
	if battle_root == null:
		return
	for frame_path in READY_FRAME_PATHS:
		var frame := battle_root.get_node_or_null(frame_path) as Panel
		if frame == null:
			continue
		_apply_ready_frame_style(frame)


func _apply_ready_frame_style(frame: Panel) -> void:
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.88, 0.42, 0.035)
	style.border_color = Color(1.0, 0.88, 0.48, 0.58)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	frame.add_theme_stylebox_override("panel", style)
	frame.pivot_offset = frame.size * 0.5
