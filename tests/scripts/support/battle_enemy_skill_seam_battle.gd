extends "res://tests/scripts/support/battle_enemy_turn_oracle_harness.gd".SeamBattle
# S4-2b test seam (works on BASE too): `skill_block_unit_id` cannot use its
# unique skill on its own turn (as if its target had died or left range in the
# meantime). Other actors still see it as a candidate. Empty = no seam.
var skill_block_unit_id := ""

func _can_actor_use_unique_skill(unit_state: BattleUnitState) -> bool:
	if not skill_block_unit_id.is_empty() and unit_state != null and unit_state.unit_id == skill_block_unit_id and current_enemy_ai_actor_state == unit_state:
		return false
	return super._can_actor_use_unique_skill(unit_state)
