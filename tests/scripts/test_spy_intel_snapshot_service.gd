extends SceneTree

const Snapshot = preload("res://scripts/worldmap/actions/spy_intel_snapshot_service.gd")

var _checks := 0
var _failures: Array[String] = []


func _initialize() -> void:
	var stock := {
		"gold": 0, "rice": 40, "barley": -4, "seafood": 0,
		"wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, "unapproved": 700,
	}
	var heroes := [
		{"hero_id": "yi", "display_name": "이순신", "faction_id": "player", "status": "normal", "role": "governor", "stats": {"hidden": 99}},
		{"hero_id": "foreign", "faction_id": "enemy", "status": "normal"},
		{"hero_id": "own_captive", "faction_id": "player", "status": "captured"},
		{"hero_id": "foreign_captive", "faction_id": "enemy", "status": "captured"},
		{"hero_id": "dead", "faction_id": "player", "status": "dead"},
		{"hero_id": "an", "display_name": "안", "faction_id": "player", "status": "wounded"},
		{"hero_id": "yi", "faction_id": "player", "status": "normal"},
	]
	var input := {
		"city_id": "hanseong", "owner_faction_id": "player", "observed_turn": 7,
		"precision": "exact", "fields": ["resources", "heroes", "troops", "troops"],
		"stock": stock, "heroes": heroes,
	}
	var report := Snapshot.build_snapshot(input)
	_expect(report["city_id"] == "hanseong" and report["observed_turn"] == 7, "preserve city and observation turn")
	_expect(report["precision"] == "exact" and not report.has("error"), "recognize exact report")
	_expect(report["resources"]["rice"] == 40 and report["resources"]["gold"] == 0, "preserve real stock and confirmed zero")
	_expect(report["resources"]["barley"] == 0, "clamp negative inventory")
	_expect(report["resources"].size() == 9 and not report["resources"].has("unapproved"), "only approved stock keys")
	_expect(report["unknown_fields"] == ["troops"] and not report.has("troops"), "unavailable requests reported once")
	_expect(report["heroes"] == [
		{"hero_id": "yi", "display_name": "이순신", "status": "normal", "role": "governor"},
		{"hero_id": "an", "display_name": "안", "status": "wounded", "role": "none"},
	], "filter roster and preserve the first eligible row in input order")
	_expect(not report.has("captives"), "no separate captive roster in phase one")
	_expect(JSON.stringify(report, "", false) == JSON.stringify(Snapshot.build_snapshot(input), "", false), "deterministic values and order")
	report["resources"]["rice"] = 5
	report["heroes"][0]["display_name"] = "changed"
	_expect(stock["rice"] == 40 and heroes[0]["display_name"] == "이순신", "output cannot mutate observation data")

	var partial := Snapshot.build_snapshot({
		"precision": "exact", "fields": ["resources"], "stock": {"gold": 0, "rice": "bad"}, "heroes": heroes,
	})
	_expect(partial["resources"] == {"gold": 0} and partial["unknown_fields"].has("resources.rice"), "missing or invalid amounts are not zero")
	_expect(not partial.has("heroes"), "unrequested fields are omitted")
	var absent := Snapshot.build_snapshot({"precision": "exact", "fields": ["resources", "heroes"]})
	_expect(not absent.has("resources") and absent["unknown_fields"] == ["resources"], "absent stock is unknown")
	_expect(absent["heroes"].is_empty(), "absent roster yields an empty array")
	var estimated_input := input.duplicate()
	estimated_input["precision"] = "estimated"
	var estimated := Snapshot.build_snapshot(estimated_input)
	_expect(estimated.get("error") == "unsupported_precision" and estimated["unknown_fields"] == ["resources", "heroes", "troops"], "unsupported precision is explicit")
	_expect(not estimated.has("resources") and not estimated.has("heroes"), "estimated path never exposes exact observations")
	print("[SPY_INTEL_SNAPSHOT] checks=%d failures=%s" % [_checks, str(_failures)])
	quit(0 if _failures.is_empty() else 1)


func _expect(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(description)
