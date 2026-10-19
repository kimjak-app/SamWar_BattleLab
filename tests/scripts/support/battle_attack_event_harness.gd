extends "res://tests/scripts/support/battle_attack_oracle_harness.gd"
var events_at: Dictionary = {}

func snapshot(battle: Node, label: String) -> Dictionary:
	var captured := super.snapshot(battle,label)
	events_at[label]=battle.get("battle_action_event_log").export()
	return captured
