extends "res://tests/scripts/support/battle_enemy_skill_spread_observer_battle.gd"
# Transparent observer for the S4-2c addendum behavior test: each override calls
# super exactly once. Records every cap decision and proves it draws no random
# number; records the counts right before each confirmed enemy skill use (the
# invariant: a use with a gap of 2+ needs the safety release).
var cap_decisions: Array = [] # [unit_id, capped, rng_untouched]
var use_records: Array = [] # [unit_id, round, own_before, lowest_other_before, last_any_before]

func _is_enemy_skill_capped(caster_state: BattleUnitState) -> bool:
	var probe_seed := 54321 + cap_decisions.size()
	seed(probe_seed)
	var expected := randf()
	seed(probe_seed)
	var capped := super._is_enemy_skill_capped(caster_state)
	cap_decisions.append([caster_state.unit_id if caster_state != null else "", capped, randf() == expected])
	return capped

func _record_enemy_unique_skill_use(caster_state: BattleUnitState) -> void:
	if caster_state != null and caster_state.side == "enemy":
		var others: Array = []
		for unit_state in _get_enemy_unique_skill_holders():
			if unit_state != caster_state: others.append(int(enemy_skill_use_count.get(unit_state.unit_id, 0)))
		use_records.append([caster_state.unit_id, battle_round, int(enemy_skill_use_count.get(caster_state.unit_id, 0)), others.min() if not others.is_empty() else -1, enemy_skill_last_any_use_round])
	super._record_enemy_unique_skill_use(caster_state)
