extends SceneTree
# S4-2: the pure enemy tactic rules (no battle): strategy eligibility and
# duplicate-status exclusion, the recent-use penalty, ranking ties and the
# yield condition. Same inputs always give the same output; no random numbers.
const Rules = preload("res://scripts/battle/services/battle_enemy_tactic_rules_service.gd")
var checks := 0
var failures: Array[String] = []

func _initialize() -> void:
	run.call_deferred()

func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)
		printerr("[ENEMY_TACTIC_RULES] FAIL ", label)

func entry(id: String, raw: int, last_use: int, order: int, cost: int) -> Dictionary:
	return {"unit_id":id, "raw":raw, "last_use_round":last_use, "order":order, "cost":cost}

func run() -> void:
	# Strategy eligibility: same conditions as the player's units.
	expect(Rules.can_enemy_use_strategy(true, false, false, 80, 80), "INT 80 alive, unacted, not confused -> may cast")
	expect(not Rules.can_enemy_use_strategy(true, false, false, 79, 80), "INT 79 -> no")
	expect(not Rules.can_enemy_use_strategy(true, false, true, 96, 80), "confused / action-locked / afraid -> no")
	expect(not Rules.can_enemy_use_strategy(true, true, false, 96, 80), "already acted -> no")
	expect(not Rules.can_enemy_use_strategy(false, false, false, 96, 80), "dead -> no")
	# Duplicate exclusion against the caster's pool.
	expect(Rules.is_strategy_target_blocked(["shake"], ["shake"]), "basic pool: shaken target blocked")
	expect(not Rules.is_strategy_target_blocked(["confusion"], ["shake"]), "basic pool: confused target still allowed (not in its pool)")
	expect(Rules.is_strategy_target_blocked(["confusion"], ["confusion", "shake"]), "master pool: confused target blocked")
	expect(not Rules.is_strategy_target_blocked([], ["confusion", "shake"]), "no status: allowed")
	expect(Rules.keeps_plan_target("a", ["b", "a"]) and not Rules.keeps_plan_target("a", ["b"]) and not Rules.keeps_plan_target("", ["b"]), "plan target kept only when it is a candidate")
	# S4-2c rotation order: older last use (never used first), then raw score, then actor order.
	var none: int = Rules.NO_USE_ROUND
	expect(Rules.ranks_ahead(entry("y", 150, none, 1, 3), entry("x", 400, 2, 0, 3)), "never used ranks ahead of any user, whatever the raw score")
	expect(Rules.ranks_ahead(entry("y", 150, 1, 1, 3), entry("x", 400, 2, 0, 3)), "older last use ranks ahead")
	expect(Rules.ranks_ahead(entry("x", 268, 2, 0, 3), entry("y", 240, 2, 1, 3)) and not Rules.ranks_ahead(entry("y", 240, 2, 1, 3), entry("x", 268, 2, 0, 3)), "same last use: higher raw first")
	expect(Rules.ranks_ahead(entry("x", 200, 2, 0, 3), entry("y", 200, 2, 1, 3)) and not Rules.ranks_ahead(entry("y", 200, 2, 1, 3), entry("x", 200, 2, 0, 3)), "same last use and raw: actor order")
	# Yield: two or more candidates (the actor + others with raw >= 130) that the momentum cannot all pay.
	var x := entry("x", 268, none, 0, 3)
	var y := entry("y", 341, none, 2, 2)
	expect(Rules.should_yield_unique_skill(x, [y], 4), "momentum 4 < 3+2: both never used, higher raw first -> x yields")
	expect(not Rules.should_yield_unique_skill(x, [y], 5), "momentum 5 pays all -> no yield")
	expect(not Rules.should_yield_unique_skill(y, [x], 3), "the first in the rotation never yields")
	expect(not Rules.should_yield_unique_skill(entry("x", 268, 2, 0, 3), [entry("y", 129, none, 2, 2)], 3), "below the 130 threshold (even never used) is no candidate")
	expect(Rules.should_yield_unique_skill(entry("x", 268, 2, 0, 3), [entry("y", 130, none, 2, 2)], 3), "at the threshold (130) a never-used other is a candidate")
	expect(Rules.should_yield_unique_skill(entry("x", 400, 2, 0, 3), [entry("z", 140, none, 1, 3)], 5), "a recent user yields to a never-used candidate despite a much higher raw")
	expect(not Rules.should_yield_unique_skill(x, [], 0), "no other candidate -> no yield")
	expect(not Rules.should_yield_unique_skill(entry("x", 268, 2, 0, 3), [entry("y", 300, 1, 1, 3), entry("z", 200, none, 2, 3)], 9), "three candidates paid in full (9) -> no yield")
	expect(Rules.should_yield_unique_skill(entry("x", 268, 2, 0, 3), [entry("y", 300, 1, 1, 3), entry("z", 200, none, 2, 3)], 8), "three candidates, momentum short -> x yields (z never used is first)")
	# Rotation over three rounds: three candidates, momentum for one each round -> three different users.
	var history := {"a":none, "b":none, "c":none}
	var raw := {"a":300, "b":250, "c":200}
	var users: Array = []
	for round_number in [1, 2, 3]:
		var used := ""
		for actor_id in ["a", "b", "c"]: # actor order
			var me := entry(actor_id, raw[actor_id], history[actor_id], ["a", "b", "c"].find(actor_id), 3)
			var others: Array = []
			for other_id in ["a", "b", "c"]:
				if other_id != actor_id and used.is_empty(): others.append(entry(other_id, raw[other_id], history[other_id], ["a", "b", "c"].find(other_id), 3))
			if used.is_empty() and not Rules.should_yield_unique_skill(me, others, 3):
				used = actor_id
		users.append(used)
		history[used] = round_number
	expect(users == ["a", "b", "c"], "three rounds rotate across three candidates " + str(users))
	# Determinism.
	var first := [Rules.should_yield_unique_skill(x, [y], 4), Rules.ranks_ahead(x, y)]
	for i in range(5): expect([Rules.should_yield_unique_skill(x, [y], 4), Rules.ranks_ahead(x, y)] == first, "same inputs -> same outputs")
	# S4-2c addendum use cap: own - min(others) >= 2 locks, unless the side used nothing for two rounds (round - L >= 3).
	expect(Rules.SKILL_CAP_USE_GAP == 2 and Rules.SKILL_CAP_RELEASE_IDLE_ROUNDS == 2, "cap constants")
	expect(not Rules.is_skill_capped(1, [0], 5, 4), "gap 1 -> free")
	expect(Rules.is_skill_capped(2, [0], 5, 4), "gap 2 -> capped")
	expect(Rules.is_skill_capped(3, [0], 5, 4), "gap 3 -> capped")
	expect(not Rules.is_skill_capped(5, [], 5, 4), "no other holder -> free")
	expect(Rules.is_skill_capped(2, [3, 0, 1], 5, 4) and not Rules.is_skill_capped(2, [3, 1, 1], 5, 4), "the lowest of many others counts")
	expect(Rules.is_skill_capped(2, [0], 5, 3), "round - L = 2 -> still capped")
	expect(not Rules.is_skill_capped(2, [0], 5, 2), "round - L = 3 -> safety release")
	expect(Rules.is_skill_capped(2, [0], 5, none), "no side use yet -> no release")
	var cap_first := Rules.is_skill_capped(2, [0, 1], 5, 3)
	for i in range(5): expect(Rules.is_skill_capped(2, [0, 1], 5, 3) == cap_first, "cap: same inputs -> same output")
	print("[ENEMY_TACTIC_RULES] checks=", checks, " failures=", failures)
	quit(0 if failures.is_empty() else 1)
