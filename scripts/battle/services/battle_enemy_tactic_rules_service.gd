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


# S4-2b enemy unique skill spread. Initial values (tunable, see the report).
const RECENT_USE_PENALTY_ONE_ROUND := 40
const RECENT_USE_PENALTY_TWO_ROUNDS := 20
const NO_USE_ROUND := -1
## Same threshold as the controller's high-value skill check (unchanged).
const HIGH_VALUE_SKILL_SCORE := 130


## Penalty by rounds since the unit's last unique skill: 1 -> 40, 2 -> 20, else 0.
static func recent_use_penalty(current_round: int, last_use_round: int) -> int:
	if last_use_round == NO_USE_ROUND:
		return 0
	match current_round - last_use_round:
		1:
			return RECENT_USE_PENALTY_ONE_ROUND
		2:
			return RECENT_USE_PENALTY_TWO_ROUNDS
	return 0


static func adjusted_skill_score(raw_score: int, current_round: int, last_use_round: int) -> int:
	return raw_score - recent_use_penalty(current_round, last_use_round)


## Entries: {unit_id, raw, adjusted, last_use_round, order, cost}. True when a
## ranks ahead of b: higher adjusted score, then the older last use (never used
## is oldest), then the existing actor order.
static func ranks_ahead(a: Dictionary, b: Dictionary) -> bool:
	if a.adjusted != b.adjusted:
		return a.adjusted > b.adjusted
	if a.last_use_round != b.last_use_round:
		return a.last_use_round < b.last_use_round
	return a.order < b.order


## The actor yields when another candidate with a high-value raw score ranks
## ahead of it and the shared momentum cannot pay both skills.
static func should_yield_unique_skill(actor: Dictionary, others: Array, momentum: int) -> bool:
	for other in others:
		if other.raw < HIGH_VALUE_SKILL_SCORE:
			continue
		if not ranks_ahead(other, actor):
			continue
		if momentum - actor.cost < other.cost:
			return true
	return false
