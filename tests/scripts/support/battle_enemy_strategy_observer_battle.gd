extends "res://tests/scripts/support/battle_enemy_turn_oracle_harness.gd".SeamBattle
# Transparent observer for the S4-2 behavior tests: each override calls super
# exactly once and only records its inputs/outputs.
var strategy_choices: Array = [] # [actor_id, plan_target_id, chosen_id]
var strategy_momentum: Array = [] # [caster_id, momentum before, momentum when the caster is closed]
var _momentum_at_close := {}

func _momentum() -> Dictionary:
	return {"ally":battle_momentum.get_value("ally"), "enemy":battle_momentum.get_value("enemy")}

func _get_enemy_strategy_target_for_actor(enemy_actor_state: BattleUnitState, plan_target_state: BattleUnitState) -> BattleUnitState:
	var chosen := super._get_enemy_strategy_target_for_actor(enemy_actor_state, plan_target_state)
	strategy_choices.append([enemy_actor_state.unit_id, plan_target_state.unit_id if plan_target_state != null else "", chosen.unit_id if chosen != null else ""])
	return chosen

func _resolve_enemy_strategy(caster_state: BattleUnitState, target_state: BattleUnitState) -> void:
	var before := _momentum()
	super._resolve_enemy_strategy(caster_state, target_state)
	strategy_momentum.append([caster_state.unit_id, before, _momentum_at_close])

func _mark_enemy_unit_acted(unit_state: BattleUnitState) -> void:
	# Sampled when a caster is closed, before the turn (and any round gain) advances.
	_momentum_at_close = _momentum()
	super._mark_enemy_unit_acted(unit_state)
