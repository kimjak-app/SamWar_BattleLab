class_name BattleDebugFormatHelper
extends RefCounted


static func format_cell(cell: Vector2i) -> String:
	return "(%d,%d)" % [cell.x, cell.y]
