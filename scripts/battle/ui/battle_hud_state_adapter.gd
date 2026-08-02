class_name BattleHudStateAdapter
extends RefCounted

const MAX_TURN := 30

static func build(controller: Node) -> Dictionary:
	var phase := str(controller.get("current_phase"))
	var active_unit: Variant = controller.get("active_unit_state")
	var selected_target: Variant = controller.get("selected_attack_target_state")
	var title := "전투 준비"
	var title_label := controller.get_node_or_null("BattleUI/TopBar/TopBarLabel") as Label
	if title_label != null:
		title = title_label.text
	var momentum: Variant = controller.get("battle_momentum")
	var ally_momentum := 3
	var enemy_momentum := 3
	if momentum != null:
		ally_momentum = momentum.get_value("ally")
		enemy_momentum = momentum.get_value("enemy")
	var allies: Array[Dictionary] = []
	var enemies: Array[Dictionary] = []
	if controller.has_method("_get_all_unit_states_in_slot_order"):
		for unit in controller.call("_get_all_unit_states_in_slot_order"):
			var state := _unit_state(unit)
			if str(state.get("side", "")) == "ally":
				allies.append(state)
			else:
				enemies.append(state)
	_mark_roster_selection(allies, active_unit)
	_mark_roster_selection(enemies, selected_target)
	var right: Variant = null
	var role := "대기"
	if selected_target != null and _is_targeting(phase):
		right = selected_target
		role = "선택 대상"
	elif phase == "enemy_turn" and active_unit != null and str(active_unit.get("side")) == "enemy":
		right = active_unit
		role = "다음 행동"
	var complete := bool(controller.call("_is_battle_result_finalized")) if controller.has_method("_is_battle_result_finalized") else false
	return {
		"turn": int(controller.get("battle_round")), "max_turn": MAX_TURN,
		"active_side": _side_label(phase), "phase": phase, "battle_title": title,
		"ally_momentum": ally_momentum, "enemy_momentum": enemy_momentum,
		"ally_roster": allies, "enemy_roster": enemies,
		"left_actor": _unit_state(active_unit), "right_subject": _unit_state(right), "right_subject_role": role,
		"center_context": _context(controller, active_unit, right),
		"instruction": _instruction(phase, complete), "disabled_reason": _reason(phase, complete, active_unit),
		"command_states": {}, "recent_log": controller.get("battle_log_lines"), "battle_complete": complete,
	}

static func _mark_roster_selection(roster: Array[Dictionary], selected_unit: Variant) -> void:
	var selected_id := "" if selected_unit == null else str(selected_unit.get("unit_id"))
	for entry in roster:
		entry["selected"] = selected_id != "" and str(entry.get("unit_id", "")) == selected_id

static func _unit_state(unit: Variant) -> Dictionary:
	if unit == null:
		return {"visible": false, "display_name": "대기"}
	var current := int(unit.get("current_hp"))
	var maximum := maxi(1, int(unit.get("max_hp")))
	var alive := bool(unit.call("is_alive")) if unit.has_method("is_alive") else current > 0
	var statuses: Array[String] = []
	if bool(unit.get("is_defending")): statuses.append("방어")
	if bool(unit.get("has_moved")): statuses.append("이동")
	var action := "행동 완료" if bool(unit.get("has_acted")) else "행동 가능"
	if not alive: action = "전멸"
	var type_id := str(unit.get("unit_type"))
	return {"unit_id": str(unit.get("unit_id")), "hero_id": "", "side": str(unit.get("side")),
		"display_name": str(unit.get("display_name")), "portrait": null, "unit_type_id": type_id,
		"unit_type_name": _type_name(type_id), "current_troops": current, "max_troops": maximum,
		"hp_ratio": float(current) / float(maximum), "action_state": action, "status_entries": statuses,
		"unique_skill_ready": alive, "reinforcement_state": "증원" if str(unit.get("slot_id")).contains("reinforce") else "주력",
		"alive": alive, "visible": true}

static func _context(controller: Node, actor: Variant, subject: Variant) -> Dictionary:
	if actor == null or subject == null: return {"text": "거리 - · 반격 -"}
	var distance := int(controller.call("get_unit_grid_distance", actor, subject)) if controller.has_method("get_unit_grid_distance") else 0
	return {"text": "거리 %d · 반격 확인 중" % distance}

static func _is_targeting(phase: String) -> bool:
	return phase == "attack_select" or phase == "unique_skill_target_select" or phase == "strategy"

static func _side_label(phase: String) -> String:
	if phase == "enemy_turn": return "적군 턴"
	if phase == "resolving": return "처리 중"
	if phase == "facing_select": return "방향 선택"
	return "아군 턴"

static func _instruction(phase: String, complete: bool) -> String:
	if complete: return "전투가 종료되었습니다."
	if phase == "attack_select": return "공격 대상을 선택하세요. 우클릭하면 취소합니다."
	if phase == "unique_skill_target_select": return "고유특기 대상을 선택하세요. 우클릭하면 취소합니다."
	if phase == "strategy": return "책략 대상을 선택하세요. 우클릭하면 취소합니다."
	if phase == "facing_select": return "방향을 선택하세요."
	if phase == "enemy_turn": return "적군이 행동 중입니다."
	if phase == "resolving": return "행동 결과를 처리 중입니다."
	return "행동할 아군 부대를 선택하거나 명령을 선택하세요."

static func _reason(phase: String, complete: bool, active: Variant) -> String:
	if complete: return "전투가 종료되어 명령을 사용할 수 없습니다."
	if phase == "enemy_turn": return "적군 턴에는 아군 명령을 사용할 수 없습니다."
	if active == null: return "행동할 아군 부대를 선택하세요."
	return ""

static func _type_name(id: String) -> String:
	match id:
		"infantry": return "보병"
		"cavalry": return "기병"
		"archer": return "궁병"
		"gunner": return "총병"
		"mounted_archer": return "기마궁병"
	return "부대"
