extends SceneTree

const BattleSkillResolverScript := preload("res://scripts/battle/battle_skill_resolver.gd")
const BattleUITextFormatHelper := preload("res://scripts/battle/helpers/battle_ui_text_format_helper.gd")

const SKILL_DATA_PATH := "res://data/heroes/generated/hero_unique_skills.json"


func _init() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SKILL_DATA_PATH))
	if not parsed is Dictionary:
		push_error("[UNIQUE_SKILL_KO] FAIL reason=skill_data_parse")
		quit(1)
		return
	var skills: Variant = (parsed as Dictionary).get("skills", [])
	if not skills is Array:
		push_error("[UNIQUE_SKILL_KO] FAIL reason=skills_missing")
		quit(1)
		return
	var passed := 0
	for raw_skill in skills:
		if raw_skill is Dictionary and _validate_skill(raw_skill as Dictionary):
			passed += 1
	if passed == (skills as Array).size():
		print("[UNIQUE_SKILL_KO] %d/%d PASS" % [passed, (skills as Array).size()])
		quit(0)
		return
	push_error("[UNIQUE_SKILL_KO] %d/%d FAIL" % [passed, (skills as Array).size()])
	quit(1)


func _validate_skill(raw_skill: Dictionary) -> bool:
	var hero_id := String(raw_skill.get("hero_id", ""))
	var skill_name := String(raw_skill.get("display_name", ""))
	var effect_id := String(raw_skill.get("effect_type", ""))
	if hero_id.is_empty() or not _contains_hangul(skill_name):
		push_error("[UNIQUE_SKILL_KO] %s FAIL reason=skill_display_name" % hero_id)
		return false
	if not BattleUITextFormatHelper.UNIQUE_SKILL_EFFECT_DISPLAY_NAMES.has(effect_id):
		push_error("[UNIQUE_SKILL_KO] %s FAIL reason=effect_display_missing effect=%s" % [hero_id, effect_id])
		return false
	var effect_display := BattleUITextFormatHelper.format_unique_skill_effect_display_name(effect_id)
	if not _contains_hangul(effect_display):
		push_error("[UNIQUE_SKILL_KO] %s FAIL reason=effect_display_non_korean effect=%s" % [hero_id, effect_id])
		return false
	var plan := _build_plan_for_skill(raw_skill)
	if not bool(plan.get("ok", false)):
		push_error("[UNIQUE_SKILL_KO] %s FAIL reason=resolver_plan %s" % [hero_id, String(plan.get("reason", ""))])
		return false
	for command_variant in plan.get("commands", []):
		if not command_variant is Dictionary:
			continue
		var command := command_variant as Dictionary
		if String(command.get("type", "")) != "status":
			continue
		var status_id := String(command.get("status_id", ""))
		if not BattleUITextFormatHelper.UNIQUE_SKILL_STATUS_DISPLAY_NAMES.has(status_id):
			push_error("[UNIQUE_SKILL_KO] %s FAIL reason=status_display_missing status=%s" % [hero_id, status_id])
			return false
		var status_display := BattleUITextFormatHelper.format_unique_skill_status_display_name(status_id)
		if not _contains_hangul(status_display):
			push_error("[UNIQUE_SKILL_KO] %s FAIL reason=status_display_non_korean status=%s" % [hero_id, status_id])
			return false
	print("[UNIQUE_SKILL_KO] %s PASS effect=%s display=%s" % [hero_id, effect_id, effect_display])
	return true


func _build_plan_for_skill(skill: Dictionary) -> Dictionary:
	var hero_id := String(skill.get("hero_id", ""))
	var caster := BattleUnitState.create({
		"hero_id": hero_id,
		"unit_id": "%s_caster" % hero_id,
		"side": "ally",
		"grid_cell": Vector2i(2, 2),
		"current_hp": 120,
		"max_hp": 120,
		"current_troops": 120,
		"max_troops": 120,
	})
	var ally := BattleUnitState.create({
		"hero_id": "yi_sun_sin",
		"unit_id": "%s_ally" % hero_id,
		"side": "ally",
		"grid_cell": Vector2i(3, 2),
		"current_hp": 120,
		"max_hp": 120,
		"current_troops": 120,
		"max_troops": 120,
	})
	var enemy := BattleUnitState.create({
		"hero_id": "xiang_yu",
		"unit_id": "%s_enemy" % hero_id,
		"side": "enemy",
		"grid_cell": Vector2i(3, 2),
		"current_hp": 120,
		"max_hp": 120,
		"current_troops": 120,
		"max_troops": 120,
	})
	var target_mode := String(skill.get("target_mode", ""))
	var selected_target := enemy
	if ["self", "self_area", "self_area_enemy", "enemy_adjacent"].has(target_mode):
		selected_target = caster
	elif target_mode == "ally_area":
		selected_target = ally
	return BattleSkillResolverScript.build_plan(caster, skill, [caster, ally, enemy], selected_target, 10, "land")


func _contains_hangul(value: String) -> bool:
	var matcher := RegEx.new()
	matcher.compile("[가-힣]")
	return matcher.search(value) != null
