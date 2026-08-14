class_name BattleMomentumState
extends RefCounted

const SCHEMA_VERSION := 2
const STARTING_MOMENTUM := 3
const MAX_MOMENTUM := 10
const ROUND_END_GAIN := 2
const BASIC_ATTACK_GAIN := 1
const RECEIVED_HIT_LOSS := 1
const SPECIAL_HIT_EXTRA_LOSS := 1
const VALID_SIDES := ["ally", "enemy"]

var _values := {
	"ally": STARTING_MOMENTUM,
	"enemy": STARTING_MOMENTUM,
}
var _events: Array[Dictionary] = []


func reset() -> void:
	for side in VALID_SIDES:
		_values[side] = STARTING_MOMENTUM
	_events.clear()


func get_value(side: String) -> int:
	return clampi(int(_values.get(side, 0)), 0, MAX_MOMENTUM)


func can_spend(side: String, amount: int) -> bool:
	return VALID_SIDES.has(side) and amount >= 0 and get_value(side) >= amount


func spend(side: String, amount: int, reason: String = "") -> bool:
	var normalized_amount := maxi(amount, 0)
	if not can_spend(side, normalized_amount):
		return false
	var before := get_value(side)
	_values[side] = before - normalized_amount
	_record_event(side, -normalized_amount, before, get_value(side), reason)
	return true


func gain(side: String, amount: int, reason: String = "") -> int:
	if not VALID_SIDES.has(side):
		return 0
	var normalized_amount := maxi(amount, 0)
	var before := get_value(side)
	_values[side] = mini(MAX_MOMENTUM, before + normalized_amount)
	var applied := get_value(side) - before
	if applied > 0:
		_record_event(side, applied, before, get_value(side), reason)
	return applied


func lose(side: String, amount: int, reason: String = "") -> int:
	if not VALID_SIDES.has(side):
		return 0
	var normalized_amount := maxi(amount, 0)
	var before := get_value(side)
	_values[side] = maxi(0, before - normalized_amount)
	var applied := before - get_value(side)
	if applied > 0:
		_record_event(side, -applied, before, get_value(side), reason)
	return applied


func record_round_end() -> Dictionary:
	return {
		"ally": gain("ally", ROUND_END_GAIN, "round_end"),
		"enemy": gain("enemy", ROUND_END_GAIN, "round_end"),
	}


func record_basic_attack(side: String) -> int:
	return gain(side, BASIC_ATTACK_GAIN, "basic_attack")


func record_received_hit(side: String, is_special_hit: bool = false, reason: String = "received_hit") -> int:
	var loss := RECEIVED_HIT_LOSS
	if is_special_hit:
		loss += SPECIAL_HIT_EXTRA_LOSS
	return lose(side, loss, reason)


func serialize() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"values": _values.duplicate(true),
		"events": _events.duplicate(true),
	}


func restore(snapshot: Dictionary) -> bool:
	var schema_version := int(snapshot.get("schema_version", 0))
	if schema_version != 1 and schema_version != SCHEMA_VERSION:
		return false
	var values_variant: Variant = snapshot.get("values", {})
	if not values_variant is Dictionary:
		return false
	var values: Dictionary = values_variant
	for side in VALID_SIDES:
		if not values.has(side):
			return false
		_values[side] = clampi(int(values.get(side, STARTING_MOMENTUM)), 0, MAX_MOMENTUM)
	_events.clear()
	var events_variant: Variant = snapshot.get("events", [])
	if events_variant is Array:
		for event_variant in events_variant:
			if event_variant is Dictionary:
				_events.append((event_variant as Dictionary).duplicate(true))
	return true


func get_events() -> Array[Dictionary]:
	return _events.duplicate(true)


func _record_event(side: String, delta: int, before: int, after: int, reason: String) -> void:
	_events.append({
		"side": side,
		"delta": delta,
		"before": before,
		"after": after,
		"reason": reason,
	})
	while _events.size() > 40:
		_events.pop_front()
