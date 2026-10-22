extends RefCounted

## S4-2 enemy tactic rules. Pure functions only: plain values in, a decision
## out. No state, no random numbers, no battle-state reads or writes; the
## controller gathers the inputs and applies the result.


## An enemy may use strategy under the same conditions as the player's units
## (alive, not yet acted, not confused / action-locked / afraid, intelligence
## at least the basic strategy threshold). Strategy costs no momentum.
static func can_enemy_use_strategy(alive: bool, acted: bool, confused: bool, intelligence: int, basic_intelligence: int) -> bool:
	return alive and not acted and not confused and intelligence >= basic_intelligence


## A target already carrying any status from the caster's strategy outcome
## pool is skipped, so an enemy does not repeat strategy on the same unit
## instead of advancing.
static func is_strategy_target_blocked(target_status_ids: Array, pool_status_ids: Array) -> bool:
	for status_id in pool_status_ids:
		if target_status_ids.has(status_id):
			return true
	return false


## The enemy plan's own target is kept when it is a strategy candidate;
## otherwise the controller falls back to its existing target selection.
static func keeps_plan_target(plan_target_id: String, candidate_ids: Array) -> bool:
	return not plan_target_id.is_empty() and candidate_ids.has(plan_target_id)
