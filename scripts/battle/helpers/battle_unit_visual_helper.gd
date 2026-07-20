class_name BattleUnitVisualHelper
extends RefCounted

static func get_portrait_template_offset(layout_offsets_by_facing: Dictionary, fallback_offset: Vector2, facing: String, facing_left: String, facing_right: String, _facing_up: String, _facing_down: String) -> Vector2:
	var normalized_facing := BattleFormationFacingHelper.normalize_facing(facing)
	if layout_offsets_by_facing.has(normalized_facing):
		return layout_offsets_by_facing[normalized_facing]
	return get_facing_aware_portrait_offset(fallback_offset, normalized_facing, facing_left, facing_right)


static func get_ally_portrait_offset_for_facing(layout_offsets_by_facing: Dictionary, fallback_offset: Vector2, facing: String, facing_left: String, facing_right: String, facing_up: String, facing_down: String) -> Vector2:
	var normalized_facing := BattleFormationFacingHelper.normalize_facing(facing)
	if normalized_facing == facing_up or normalized_facing == facing_down:
		return fallback_offset
	return get_portrait_template_offset(layout_offsets_by_facing, fallback_offset, normalized_facing, facing_left, facing_right, facing_up, facing_down)


static func get_enemy_portrait_offset_for_facing(layout_offsets_by_facing: Dictionary, fallback_offset: Vector2, facing: String, facing_left: String, facing_right: String, facing_up: String, facing_down: String) -> Vector2:
	var normalized_facing := BattleFormationFacingHelper.normalize_facing(facing)
	if normalized_facing == facing_up or normalized_facing == facing_down:
		return fallback_offset
	return get_portrait_template_offset(layout_offsets_by_facing, fallback_offset, normalized_facing, facing_left, facing_right, facing_up, facing_down)


static func get_facing_aware_portrait_offset(base_offset: Vector2, facing: String, facing_left: String, facing_right: String) -> Vector2:
	var result := base_offset
	var normalized_facing := BattleFormationFacingHelper.normalize_facing(facing)
	match normalized_facing:
		facing_left:
			result.x = -absf(base_offset.x)
		facing_right:
			result.x = absf(base_offset.x)
	return result
