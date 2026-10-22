extends "res://tests/scripts/support/battle_enemy_turn_oracle_harness.gd".SeamBattle
# S4-2: the production controller with both new enemy flags turned on (tests
# only; the committed default is off). Used to prove the ally paths are
# unchanged when the enemy rules are active.

func _ready() -> void:
	set("enemy_strategy_enabled", true)
	set("enemy_skill_spread_enabled", true)
	super._ready()
