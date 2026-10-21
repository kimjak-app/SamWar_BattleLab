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

func _unit_view() -> Dictionary:
	var view := {}
	for u in all_battle_unit_states:
		view[u.unit_id] = {"hp":u.current_hp, "troops":u.current_troops, "cell":[u.grid_cell.x, u.grid_cell.y], "alive":u.is_alive(), "turns":_status_turns(u)}
	return view

func _momentum_view() -> Dictionary:
	return {"ally":battle_momentum.get_value("ally"), "enemy":battle_momentum.get_value("enemy")}

func _begin_unique_skill_sequence(caster_state: BattleUnitState, skill_data: Dictionary) -> void:
	var before := _tactic_events().size()
	var momentum_before := _momentum_view()
	super._begin_unique_skill_sequence(caster_state, skill_data)
	samples.append({"kind":"skill_begin", "caster_id":caster_state.unit_id if caster_state != null else "", "side":caster_state.side if caster_state != null else "",
		"committed":not pending_unique_skill_plan.is_empty(), "momentum_before":momentum_before, "momentum_after":_momentum_view(),
		"plan_skill_id":String(pending_unique_skill_plan.get("skill_id", "")), "new_events":_tactic_events().slice(before)})

func _apply_resolver_skill_plan(caster_state: BattleUnitState, plan: Dictionary) -> void:
	var before := _tactic_events().size()
	var units_before := _unit_view()
	var momentum_before := _momentum_view()
	super._apply_resolver_skill_plan(caster_state, plan)
	var command_types: Array = []
	for command in plan.get("commands", []): command_types.append(String(command.get("type", "")))
	samples.append({"kind":"skill_apply", "caster_id":caster_state.unit_id, "command_types":command_types, "before":units_before, "after":_unit_view(),
		"momentum_before":momentum_before, "momentum_after":_momentum_view(), "new_events":_tactic_events().slice(before)})

func _finalize_unique_skill_action(caster_state: BattleUnitState, skill_data: Dictionary) -> void:
	var before := _tactic_events().size()
	var cooldown := int(skill_data.get("cooldown_turns", 0))
	super._finalize_unique_skill_action(caster_state, skill_data)
	samples.append({"kind":"skill_finalize", "caster_id":caster_state.unit_id if caster_state != null else "", "cooldown":cooldown, "new_events":_tactic_events().slice(before)})

func _reinforcement_sample(source: String, before: int, round_started_before: Array) -> void:
	var arrived := []
	for event in _tactic_events().slice(before):
		var unit: BattleUnitState = null
		for u in all_battle_unit_states:
			if u.unit_id == event.get("unit_id", ""): unit = u
		arrived.append({"event":event, "cell":[unit.grid_cell.x, unit.grid_cell.y] if unit else [], "deployed":_is_unit_state_available_for_battle_slot(unit) if unit else false,
			"has_acted":unit.has_acted if unit else true})
	samples.append({"kind":"reinforcement", "source":source, "round":battle_round, "arrived":arrived, "round_started_before":round_started_before})

func _round_started_rounds() -> Array:
	return enemy_action_event_log.export().filter(func(e): return e.kind == "round_started").map(func(e): return e.round)

func _try_deploy_reinforce_01_pair() -> void:
	var before := _tactic_events().size()
	super._try_deploy_reinforce_01_pair()
	_reinforcement_sample("reinforce_01", before, _round_started_rounds())

func _try_deploy_city_reinforce_02_pair() -> void:
	var before := _tactic_events().size()
	super._try_deploy_city_reinforce_02_pair()
	_reinforcement_sample("city_reinforce_02", before, _round_started_rounds())
