extends SceneTree

const HeroDefinitionRegistryScript := preload("res://scripts/worldmap/hero_definition_registry.gd")
const HeroRuntimeFactoryScript := preload("res://scripts/worldmap/hero_runtime_factory.gd")
const HeroDesignDataRegistryScript := preload("res://scripts/worldmap/hero_design_data_registry.gd")
const BattleUnitStateScript := preload("res://scripts/battle_unit_state.gd")
const BattleMomentumStateScript := preload("res://scripts/battle/battle_momentum_state.gd")
const BattleSkillResolverScript := preload("res://scripts/battle/battle_skill_resolver.gd")
const BattleRuntimeSnapshotScript := preload("res://scripts/battle/battle_runtime_snapshot.gd")

var failures: Array[String] = []


func _initialize() -> void:
	_test_momentum_transaction()
	_test_all_39_skill_resolutions()
	_test_snapshot_roundtrip()
	_finish()


func _test_momentum_transaction() -> void:
	var momentum := BattleMomentumStateScript.new()
	_expect(momentum.get_value("ally") == 3, "momentum: ally starts at 3")
	_expect(momentum.get_value("enemy") == 3, "momentum: enemy starts at 3")
	_expect(momentum.record_basic_attack("ally") == 1, "momentum: successful basic attack gains 1")
	_expect(momentum.get_value("ally") == 4, "momentum: ally shared pool receives gain")
	_expect(not momentum.spend("ally", 5, "rejected"), "momentum: insufficient spend rejected")
	_expect(momentum.get_value("ally") == 4, "momentum: rejected spend is not charged")
	_expect(momentum.spend("ally", 4, "committed_skill"), "momentum: committed skill spends")
	_expect(momentum.get_value("ally") == 0, "momentum: committed cost applied exactly once")
	momentum.reset()
	var round_gain := momentum.record_round_end()
	_expect(momentum.get_value("ally") == 5 and momentum.get_value("enemy") == 5, "momentum: round end gives both sides 2")
	_expect(int(round_gain.get("ally", 0)) == 2 and int(round_gain.get("enemy", 0)) == 2, "momentum: round gain event is exact")
	_expect(momentum.record_received_hit("enemy") == 1, "momentum: normal hit loses 1")
	_expect(momentum.get_value("enemy") == 4, "momentum: normal hit loss applied once")
	_expect(momentum.record_received_hit("enemy", true, "cooperative_hit") == 2, "momentum: cooperative hit loses total 2")
	_expect(momentum.get_value("enemy") == 2, "momentum: cooperative hit transaction is capped once")
	_expect(momentum.record_received_hit("enemy", true, "unique_skill_hit") == 2, "momentum: special hit loses total 2")
	_expect(momentum.get_value("enemy") == 0, "momentum: floor is zero")
	for _index in range(10):
		momentum.record_basic_attack("ally")
	_expect(momentum.get_value("ally") == 10, "momentum: shared pool clamps at 10")
	var restored := BattleMomentumStateScript.new()
	_expect(restored.restore(momentum.serialize()), "momentum: serialized state restores")
	_expect(restored.get_value("ally") == 10, "momentum: restored value matches")


func _test_all_39_skill_resolutions() -> void:
	_expect(HeroDesignDataRegistryScript.ensure_loaded(), "registry: generated design data loads")
	var hero_ids := HeroDesignDataRegistryScript.get_all_hero_ids()
	_expect(hero_ids.size() == 39, "resolver: exactly 39 heroes discovered")
	for hero_id in hero_ids:
		var identity_variant: Variant = HeroDefinitionRegistryScript.HERO_DATA.get(hero_id, {})
		if not identity_variant is Dictionary:
			_expect(false, "resolver: identity exists for %s" % hero_id)
			continue
		var caster := _build_unit(identity_variant as Dictionary, "ally", Vector2i(3, 3))
		var ally := _build_unit(
			HeroDefinitionRegistryScript.HERO_DATA.get("yi_sun_sin", {}) as Dictionary,
			"ally",
			Vector2i(4, 3)
		)
		var enemy := _build_unit(
			HeroDefinitionRegistryScript.HERO_DATA.get("guan_yu", {}) as Dictionary,
			"enemy",
			Vector2i(4, 3)
		)
		var skill := BattleSkillResolverScript.normalize_skill(caster.unique_skill_definition)
		var target_mode := String(skill.get("target_mode", ""))
		var primary: BattleUnitState = enemy
		if BattleSkillResolverScript.SELF_TARGET_MODES.has(target_mode):
			primary = caster
		elif BattleSkillResolverScript.ALLY_TARGET_MODES.has(target_mode):
			primary = ally
		var units: Array[BattleUnitState] = [caster, ally, enemy]
		var plan := BattleSkillResolverScript.build_plan(caster, skill, units, primary, 10, "land")
		_expect(bool(plan.get("ok", false)), "resolver: %s builds executable plan" % hero_id)
		_expect(not (plan.get("commands", []) as Array).is_empty(), "resolver: %s emits effect commands" % hero_id)


func _test_snapshot_roundtrip() -> void:
	var caster := _build_unit(
		HeroDefinitionRegistryScript.HERO_DATA.get("yi_sun_sin", {}) as Dictionary,
		"ally",
		Vector2i(2, 2)
	)
	caster.apply_damage(17)
	caster.apply_status_effect("defense_up", 2, 12)
	var momentum := BattleMomentumStateScript.new()
	momentum.record_basic_attack("ally")
	var units: Array[BattleUnitState] = [caster]
	var snapshot := BattleRuntimeSnapshotScript.capture(
		"t06-7-smoke",
		3,
		"ally_turn",
		units,
		momentum,
		{"active_unit_id": caster.unit_id}
	)
	caster.apply_damage(30)
	momentum.spend("ally", 3, "mutation")
	var restored := BattleRuntimeSnapshotScript.restore(snapshot, "t06-7-smoke", units, momentum)
	_expect(bool(restored.get("ok", false)), "snapshot: battle runtime restores")
	_expect(caster.current_hp == caster.max_hp - 17, "snapshot: unit HP restores")
	_expect(caster.has_status_effect("defense_up"), "snapshot: status effect restores")
	_expect(momentum.get_value("ally") == 4, "snapshot: side momentum restores")


func _build_unit(identity: Dictionary, side: String, cell: Vector2i) -> BattleUnitState:
	var runtime := HeroRuntimeFactoryScript.build_runtime_hero(identity, identity)
	var payload := HeroRuntimeFactoryScript.build_battle_unit_payload(runtime, {
		"unit_id": "%s_%s_smoke" % [String(runtime.get("hero_id", "")), side],
		"side": side,
		"slot_id": "%s_smoke" % side,
		"current_hp": 100,
		"max_hp": 100,
		"current_troops": 100,
		"max_troops": 100,
		"grid_cell": cell,
	})
	return BattleUnitStateScript.create(payload)


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("[T06_T07_SMOKE_PASS] %s" % label)
	else:
		failures.append(label)
		push_error("[T06_T07_SMOKE_FAIL] %s" % label)


func _finish() -> void:
	if failures.is_empty():
		print("[T06_T07_SMOKE] PASS")
		quit(0)
	else:
		print("[T06_T07_SMOKE] FAIL %s" % str(failures))
		quit(1)
