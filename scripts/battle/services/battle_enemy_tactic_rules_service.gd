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


# S4-2c enemy unique skill rotation (replaces the S4-2b recent-use penalty).
const NO_USE_ROUND := -1
## Same threshold as the controller's high-value skill check (unchanged).
const HIGH_VALUE_SKILL_SCORE := 130


## Entries: {unit_id, raw, last_use_round, order, cost}. True when a ranks ahead
## of b in the rotation: the older last use first (never used is oldest), then
## the higher raw score, then the existing actor order.
static func ranks_ahead(a: Dictionary, b: Dictionary) -> bool:
	if a.last_use_round != b.last_use_round:
		return a.last_use_round < b.last_use_round
	if a.raw != b.raw:
		return a.raw > b.raw
	return a.order < b.order


## The deciding actor plus every other candidate with a high-value raw score.
## When there are two or more and the shared momentum cannot pay all of them,
## only the first in the rotation uses its skill: the actor yields when any
## candidate ranks ahead of it. Momentum for all of them means no yield.
static func should_yield_unique_skill(actor: Dictionary, others: Array, momentum: int) -> bool:
	var candidates: Array = [actor]
	for other in others:
		if other.raw >= HIGH_VALUE_SKILL_SCORE:
			candidates.append(other)
	if candidates.size() < 2:
		return false
	var total_cost := 0
	for candidate in candidates:
		total_cost += candidate.cost
	if total_cost <= momentum:
		return false
	for candidate in candidates:
		if candidate != actor and ranks_ahead(candidate, actor):
			return true
	return false


# S4-2c addendum: enemy unique skill use cap (every AI level).
const SKILL_CAP_USE_GAP := 2
const SKILL_CAP_RELEASE_IDLE_ROUNDS := 2


## A deciding enemy is capped when its use count is at least SKILL_CAP_USE_GAP
## above the lowest count among the other live, deployed enemies that have a
## unique skill (none -> never capped). Safety release: when the whole enemy
## side has used no unique skill for SKILL_CAP_RELEASE_IDLE_ROUNDS rounds
## (current round - last any use >= 3), the cap is lifted. No last use at all
## means no release (the gap cannot be reached without a use anyway).
static func is_skill_capped(own_count: int, other_counts: Array, battle_round: int, last_any_use_round: int) -> bool:
	if other_counts.is_empty():
		return false
	var lowest: int = other_counts.min()
	if own_count - lowest < SKILL_CAP_USE_GAP:
		return false
	if last_any_use_round != NO_USE_ROUND and battle_round - last_any_use_round > SKILL_CAP_RELEASE_IDLE_ROUNDS:
		return false
	return true
