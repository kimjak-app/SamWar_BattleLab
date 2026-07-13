class_name BattleFormationFacingHelper
extends RefCounted


const FACING_LEFT := "left"
const FACING_RIGHT := "right"
const FACING_UP := "up"
const FACING_DOWN := "down"


static func normalize_facing(facing: String) -> String:
	if facing == FACING_LEFT:
		return FACING_LEFT
	if facing == FACING_RIGHT:
		return FACING_RIGHT
	if facing == FACING_UP:
		return FACING_UP
	if facing == FACING_DOWN:
		return FACING_DOWN
	return FACING_RIGHT


static func is_vertical_facing(facing: String) -> bool:
	var normalized_facing := normalize_facing(facing)
	return normalized_facing == FACING_UP or normalized_facing == FACING_DOWN


static func is_horizontal_facing(facing: String) -> bool:
	var normalized_facing := normalize_facing(facing)
	return normalized_facing == FACING_LEFT or normalized_facing == FACING_RIGHT


static func get_facing_arrow_text(facing: String) -> String:
	match normalize_facing(facing):
		FACING_LEFT:
			return "←"
		FACING_RIGHT:
			return "→"
		FACING_UP:
			return "↑"
		FACING_DOWN:
			return "↓"
		_:
			return "→"
