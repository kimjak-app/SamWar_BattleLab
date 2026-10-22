extends "res://tests/scripts/support/battle_enemy_skill_seam_battle.gd"
# Transparent observer for the S4-2b behavior test: each override calls super
# exactly once. Records every enemy yield decision and proves it draws no
# random number (the global RNG is checked around the decision).
var spread_decisions: Array = [] # [actor_id, yielded, rng_untouched, momentum]

func _should_enemy_yield_unique_skill(caster_state: BattleUnitState, skill_data: Dictionary, target_state: BattleUnitState) -> bool:
	var probe_seed := 98765 + spread_decisions.size()
	seed(probe_seed)
	var expected := randf()
	seed(probe_seed)
	var yielded := super._should_enemy_yield_unique_skill(caster_state, skill_data, target_state)
	spread_decisions.append([caster_state.unit_id if caster_state != null else "", yielded, randf() == expected, battle_momentum.get_value("enemy")])
	return yielded
