extends "res://scripts/battle/presentation/iso/battle_iso_production_controller.gd"
# T3 measurement spy: the product battle controller, observed only. It counts
# calls of the presentation functions that draw from the global random number
# generator (`randf_range`/`randi`), then runs them unchanged through `super`.
var fx_calls := {}

func _count(name: String) -> void:
	fx_calls[name] = int(fx_calls.get(name, 0)) + 1

func _fade_out_move_dust_for_unit(unit_state: BattleUnitState) -> void:
	_count("_fade_out_move_dust_for_unit")
	super._fade_out_move_dust_for_unit(unit_state)

func _spawn_battle_dust_fx(world_pos: Vector2, alpha_min: float, alpha_max: float, scale_min: float, scale_max: float) -> void:
	_count("_spawn_battle_dust_fx")
	super._spawn_battle_dust_fx(world_pos, alpha_min, alpha_max, scale_min, scale_max)

func _play_arrow_projectile_effect(source_pos: Vector2, target_pos: Vector2) -> void:
	_count("_play_arrow_projectile_effect")
	super._play_arrow_projectile_effect(source_pos, target_pos)

func _get_arrow_curve_midpoint(source_pos: Vector2, target_impact_pos: Vector2) -> Vector2:
	_count("_get_arrow_curve_midpoint")
	return super._get_arrow_curve_midpoint(source_pos, target_impact_pos)

func _spawn_arrow_projectile(source_pos: Vector2, target_impact_pos: Vector2, launch_delay: float, travel_duration: float) -> void:
	_count("_spawn_arrow_projectile")
	super._spawn_arrow_projectile(source_pos, target_impact_pos, launch_delay, travel_duration)

func _spawn_arrow_impact_pin(target_impact_pos: Vector2, arrow_angle: float) -> void:
	_count("_spawn_arrow_impact_pin")
	super._spawn_arrow_impact_pin(target_impact_pos, arrow_angle)

func _play_gunner_shot_effect(source_pos: Vector2, target_pos: Vector2) -> void:
	_count("_play_gunner_shot_effect")
	super._play_gunner_shot_effect(source_pos, target_pos)

func _spawn_gunner_impact_pop(target_pos: Vector2, shot_direction: Vector2) -> void:
	_count("_spawn_gunner_impact_pop")
	super._spawn_gunner_impact_pop(target_pos, shot_direction)

func _spawn_hit_spark_fx(target_pos: Vector2) -> void:
	_count("_spawn_hit_spark_fx")
	super._spawn_hit_spark_fx(target_pos)

func _start_unique_skill_camera_shake(effect_type: String) -> void:
	_count("_start_unique_skill_camera_shake")
	super._start_unique_skill_camera_shake(effect_type)

func _load_random_fx_texture(paths: Array[String]) -> Texture2D:
	_count("_load_random_fx_texture")
	return super._load_random_fx_texture(paths)
