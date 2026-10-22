extends RefCounted

## S4-3 battle start setup and enemy AI level rules. Pure functions only: plain
## values in, a decision out. No state, no random numbers, no battle-state reads
## or writes; the controller reads the setup and applies the result.

const AI_LEVELS := ["low", "mid", "high"]
const TROOP_FIELDS := ["current_troops", "max_troops", "allocated_troops", "initial_allocated_troops", "current_hp", "max_hp"]


## A troops ratio is a number (not a bool or a string) with 0 < ratio <= 1.
static func is_valid_troops_ratio(value: Variant) -> bool:
	if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
		return false
	return float(value) > 0.0 and float(value) <= 1.0


## Each troop field is scaled on its own: round down, at least 1 when it was
## positive; a field at 0 stays 0.
static func scale_troop_value(value: int, ratio: float) -> int:
	if value <= 0:
		return value
	return maxi(1, int(floor(float(value) * ratio)))


static func is_valid_ai_level(level: Variant) -> bool:
	return typeof(level) == TYPE_STRING and AI_LEVELS.has(level)


## Design S4 §1: low = only the use cap; mid and high (high plays as mid until
## S4-4) = strategy, rotation and the use cap.
static func flags_for_ai_level(level: String) -> Dictionary:
	var smart := level == "mid" or level == "high"
	return {"enemy_strategy_enabled":smart, "enemy_skill_spread_enabled":smart, "enemy_skill_cap_enabled":true}
