extends "res://tests/scripts/support/battle_enemy_turn_oracle_harness.gd".SeamBattle
# Transparent observer for the S4-1 semantics test: each override calls super
# exactly once and only reads state around it.
var samples: Array = []

func _tactic_events() -> Array:
	return tactic_event_log.export()

func _status_turns(unit: BattleUnitState) -> Dictionary:
	var turns := {}
	for key in unit.status_effects.keys(): turns[String(key)] = unit.get_status_turns(String(key))
	return turns

func _mark_ally_unit_acted(unit_state: BattleUnitState) -> void:
	# Right after a strategy_cast the caster is marked acted: sample the target then.
	var events := _tactic_events()
	if unit_state != null and not events.is_empty() and events[-1].kind == "strategy_cast" and events[-1].caster_id == unit_state.unit_id \
			and not samples.any(func(s): return s.kind == "strategy" and s.sequence == events[-1].sequence):
		var target: BattleUnitState = null
		for u in all_battle_unit_states:
			if u.unit_id == events[-1].target_id: target = u
		samples.append({"kind":"strategy", "sequence":events[-1].sequence, "event":events[-1], "target_turns":_status_turns(target)})
	super._mark_ally_unit_acted(unit_state)

func _consume_strategy_status_after_unit_action(unit_state: BattleUnitState) -> void:
	var before := _tactic_events().size()
	var state_before := {"hp":unit_state.current_hp, "troops":unit_state.current_troops, "turns":_status_turns(unit_state)} if unit_state != null else {}
	super._consume_strategy_status_after_unit_action(unit_state)
	if unit_state == null: return
	samples.append({"kind":"tick", "unit_id":unit_state.unit_id, "acted":unit_state.has_acted, "before":state_before,
		"after":{"hp":unit_state.current_hp, "troops":unit_state.current_troops, "turns":_status_turns(unit_state)},
		"new_events":_tactic_events().slice(before)})
