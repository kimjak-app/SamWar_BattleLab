class_name BattleUniqueSkillCooldownStateService
extends RefCounted

var _cooldowns_by_hero_id: Dictionary = {}


func clear() -> void:
	_cooldowns_by_hero_id.clear()


func set_remaining(cooldown_key: String, turns: int) -> void:
	if cooldown_key.is_empty():
		return
	_cooldowns_by_hero_id[cooldown_key] = maxi(turns, 0)


func get_remaining(cooldown_key: String) -> int:
	if cooldown_key.is_empty():
		return 0
	return maxi(int(_cooldowns_by_hero_id.get(cooldown_key, 0)), 0)


func tick_keys(cooldown_keys: Array[String]) -> void:
	var seen_keys: Dictionary = {}
	for cooldown_key in cooldown_keys:
		if cooldown_key.is_empty() or seen_keys.has(cooldown_key):
			continue
		seen_keys[cooldown_key] = true
		var remaining := int(_cooldowns_by_hero_id.get(cooldown_key, 0))
		if remaining > 0:
			_cooldowns_by_hero_id[cooldown_key] = remaining - 1


func export_state() -> Dictionary:
	return _cooldowns_by_hero_id.duplicate(true)


func restore_state(value: Variant) -> void:
	_cooldowns_by_hero_id = (value as Dictionary).duplicate(true) if value is Dictionary else {}
