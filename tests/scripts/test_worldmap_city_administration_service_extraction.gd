extends SceneTree

const ServiceScript := preload("res://scripts/worldmap/economy_city/city_administration_service.gd")

var _checks := 0
var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var service := ServiceScript.new()
	var city := {"id": "hanseong", "governor_id": "old", "stationed_hero_ids": ["hero_a"]}
	var hero := {"id": "hero_a", "side": "player", "location_city_id": "hanseong"}
	var valid := service.validate_governor_assignment("hanseong", " hero_a ", city, hero)
	_expect(bool(valid.ok) and str(valid.governor_id) == "hero_a" and str(valid.previous_governor_id) == "old", "valid governor assignment")
	var cleared := service.validate_governor_assignment("hanseong", "", city)
	_expect(bool(cleared.ok) and str(cleared.governor_id).is_empty(), "clear governor")
	_expect(str(service.validate_governor_assignment("", "hero_a", {}, hero).error_code) == "invalid_city", "invalid city rejected")
	_expect(str(service.validate_governor_assignment("hanseong", "hero_b", city, {"id": "hero_b"}).error_code) == "hero_not_stationed", "governor not stationed rejected")
	var same := service.validate_governor_assignment("hanseong", "old", {"id": "hanseong", "governor_id": "old", "stationed_hero_ids": ["old"]}, {"id": "old"})
	_expect(bool(same.ok) and str(same.previous_governor_id) == str(same.governor_id), "duplicate governor assignment is safe")
	_expect(str(service.get_governor_policy_entry("commerce").name) == "상업 중심", "governor policy lookup")
	_expect(str(service.get_governor_policy_entry("unknown").name) == "균형 운영", "unknown policy fallback")

	var admin := _effects(service, "administrative", 4.0, "follow_chancellor", "balanced")
	_expect(float(admin.rice_multiplier) > 1.0 and float(admin.seafood_multiplier) > 1.0, "administrative aptitude effect")
	var economic := _effects(service, "economic", 4.0, "follow_chancellor", "balanced")
	_expect(float(economic.gold_multiplier) > 1.0, "economic aptitude effect")
	var political := _effects(service, "political", 4.0, "follow_chancellor", "balanced")
	_expect(float(political.city_loyalty_loss_multiplier) < 1.0, "political aptitude effect")
	var diplomatic := _effects(service, "diplomatic", 4.0, "follow_chancellor", "balanced")
	_expect(float(diplomatic.gold_multiplier) > 1.0, "diplomatic aptitude effect")
	var military_admin := _effects(service, "militaryAdmin", 4.0, "follow_chancellor", "balanced")
	_expect(int(military_admin.recruitable_troops_bonus) == 48, "militaryAdmin aptitude effect")

	var agriculture := _effects(service, "", 0.0, "agriculture", "balanced")
	_expect(float(agriculture.rice_multiplier) > 1.0 and float(agriculture.gold_multiplier) < 1.0, "agriculture policy")
	var commerce := _effects(service, "", 0.0, "commerce", "balanced")
	_expect(float(commerce.gold_multiplier) > 1.0 and float(commerce.rice_multiplier) < 1.0, "commerce policy")
	var military := _effects(service, "", 0.0, "military", "balanced")
	_expect(int(military.recruitable_troops_bonus) == 40, "military policy")
	var follows := _effects(service, "", 0.0, "follow_chancellor", "commerce")
	_expect(is_equal_approx(float(follows.gold_multiplier), 1.03), "follow-chancellor policy")

	var fallback := service.calculate_city_domestic_effects(
		{"id": "hanseong"}, {},
		{"side": "player", "chancellor_primary_type": "political", "chancellor_primary_aptitude": 4.0},
		"player", "follow_chancellor", "balanced", 0.03, 0.015
	)
	_expect(float(fallback.city_loyalty_loss_multiplier) < 1.0, "no valid governor uses chancellor fallback")
	var city_before := city.duplicate(true)
	var hero_before := hero.duplicate(true)
	service.validate_governor_assignment("hanseong", "hero_a", city, hero)
	service.calculate_city_domestic_effects(city, hero, {}, "player", "follow_chancellor", "balanced", 0.03, 0.015)
	_expect(city == city_before and hero == hero_before, "input snapshots are not mutated")
	_expect(not service.has_method("get_node") and not service.has_method("show"), "no UI dependency")
	_expect(not service.has_method("save") and not service.has_method("save_game"), "no save dependency")
	_expect(str(service.validate_governor_assignment("hanseong", "hero_a", city).error_code) == "invalid_hero", "invalid hero rejected")
	_expect(str(service.get_city_policy_id("hanseong", city, {"hanseong": "military"})) == "military", "city policy snapshot overrides seed")
	_finish()


func _effects(service: RefCounted, type_id: String, aptitude: float, governor_policy_id: String, chancellor_policy_id: String) -> Dictionary:
	return service.calculate_city_domestic_effects(
		{"id": "hanseong", "governor_id": "hero_a"},
		{"id": "hero_a", "side": "player", "location_city_id": "hanseong", "chancellor_primary_type": type_id, "chancellor_primary_aptitude": aptitude},
		{}, "player", governor_policy_id, chancellor_policy_id, 0.03, 0.015
	)


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("[CITY_ADMINISTRATION_SERVICE_FAIL] %s" % label)


func _finish() -> void:
	print("[CITY_ADMINISTRATION_SERVICE] %s: %d checks, %d failures" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	quit(0 if _failures == 0 else 1)
