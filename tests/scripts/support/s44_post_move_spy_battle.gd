extends "res://scripts/battle/presentation/iso/battle_iso_production_controller.gd"
# N2 measurement spy: the product battle controller, observed only. For every
# enemy actor it records the unique skill score where the engine itself judges
# it: once when the actor starts (before any move) and once after its move
# (the engine's own post-move judgement point). Reads use the engine's own
# functions; nothing is written; the super calls run unchanged.
var actor_rows: Array = []

func _skill_view(u: BattleUnitState) -> Dictionary:
	var view := {"cell":[u.grid_cell.x, u.grid_cell.y], "momentum":battle_momentum.get_value("enemy"), "can_use":_can_actor_use_unique_skill(u)}
	var skill := _get_unique_skill_for_unit(u)
	view["has_skill"] = not skill.is_empty()
	if skill.is_empty(): return view
	var target := _get_best_unique_skill_target_for_actor(u, skill)
	view["skill_id"] = String(skill.get("id", skill.get("skill_id", "")))
	view["raw"] = _score_unique_skill_plan_for_actor(u, skill, target)
	view["target"] = target.unit_id if target != null else ""
	view["cost"] = _get_effective_unique_skill_cost(u, skill)
	view["valid_targets"] = _get_unique_skill_valid_targets(u, skill).size()
	view["high_value"] = _is_unique_skill_high_value_for_actor(u, skill, target)
	view["fallback_value"] = _is_unique_skill_fallback_value_for_actor(u, skill, target)
	return view

func _play_enemy_ai_for_actor(enemy_actor_state: BattleUnitState) -> void:
	if enemy_actor_state != null and enemy_actor_state.is_alive():
		var row := {"round":battle_round, "actor_index":actor_rows.size(), "unit_id":enemy_actor_state.unit_id,
			"event_index":enemy_action_event_log.export().size(), "before":_skill_view(enemy_actor_state), "moved":false}
		actor_rows.append(row)
	super._play_enemy_ai_for_actor(enemy_actor_state)

func _play_enemy_actor_basic_attack_or_wait_after_move(enemy_actor_state: BattleUnitState) -> void:
	if enemy_actor_state != null and not actor_rows.is_empty() and actor_rows[-1].unit_id == enemy_actor_state.unit_id:
		var row: Dictionary = actor_rows[-1]
		row["moved"] = true
		row["after"] = _skill_view(enemy_actor_state)
		var attack_target := _find_best_auto_attack_target(enemy_actor_state)
		row["after"]["attack_target"] = attack_target.unit_id if attack_target != null else ""
		row["after"]["attack_kills"] = attack_target != null and _can_auto_kill_target(enemy_actor_state, attack_target)
	super._play_enemy_actor_basic_attack_or_wait_after_move(enemy_actor_state)
