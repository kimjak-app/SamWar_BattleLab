extends "res://tests/scripts/support/battle_enemy_turn_oracle_harness.gd".SeamBattle
# Transparent observer: each override calls super exactly once and only reads.
var hit_samples: Array = []

func _enemy_reaction_hit_on() -> void:
	super._enemy_reaction_hit_on()
	var defeated := []
	for event in battle_action_event_log.export():
		if event.kind == "unit_defeated": defeated.append(event.unit_id)
	var attacks := []
	for event in enemy_action_event_log.export():
		if event.kind == "enemy_attack_resolved": attacks.append(event.duplicate(true))
	hit_samples.append({"frame":Engine.get_process_frames(), "attacks":attacks, "unit_defeated":defeated})
