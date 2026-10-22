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

func entry(id: String, raw: int, adjusted: int, last_use: int, order: int, cost: int) -> Dictionary:
	return {"unit_id":id, "raw":raw, "adjusted":adjusted, "last_use_round":last_use, "order":order, "cost":cost}

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
	# Recent-use penalty.
	expect(Rules.recent_use_penalty(5, Rules.NO_USE_ROUND) == 0, "never used -> 0")
	expect(Rules.recent_use_penalty(5, 4) == 40 and Rules.recent_use_penalty(5, 3) == 20 and Rules.recent_use_penalty(5, 2) == 0 and Rules.recent_use_penalty(5, 5) == 0, "d=1 -> 40, d=2 -> 20, otherwise 0")
	expect(Rules.adjusted_skill_score(268, 3, 2) == 228 and Rules.adjusted_skill_score(268, 3, 1) == 248 and Rules.adjusted_skill_score(268, 3, Rules.NO_USE_ROUND) == 268, "adjusted = raw - penalty")
	# Ranking: adjusted, then older last use (never used is oldest), then actor order.
	expect(Rules.ranks_ahead(entry("y", 200, 200, -1, 1, 3), entry("x", 300, 190, 2, 0, 3)), "higher adjusted ranks ahead")
	expect(Rules.ranks_ahead(entry("y", 200, 200, -1, 1, 3), entry("x", 200, 200, 2, 0, 3)), "tie: never used ranks ahead of a recent user")
	expect(Rules.ranks_ahead(entry("y", 200, 200, 1, 1, 3), entry("x", 200, 200, 2, 0, 3)), "tie: older last use ranks ahead")
	expect(Rules.ranks_ahead(entry("x", 200, 200, 2, 0, 3), entry("y", 200, 200, 2, 1, 3)) and not Rules.ranks_ahead(entry("y", 200, 200, 2, 1, 3), entry("x", 200, 200, 2, 0, 3)), "full tie: actor order")
	# Yield: a higher-ranked high-value candidate and momentum for only one.
	var x := entry("x", 268, 268, -1, 0, 3)
	var y := entry("y", 341, 341, -1, 2, 2)
	expect(Rules.should_yield_unique_skill(x, [y], 4), "momentum 4: 4-3 < 2 -> yield")
	expect(not Rules.should_yield_unique_skill(x, [y], 5), "momentum 5: both affordable -> use")
	expect(not Rules.should_yield_unique_skill(y, [x], 3), "the higher-ranked actor never yields to a lower one")
	expect(not Rules.should_yield_unique_skill(x, [entry("y", 129, 129, -1, 2, 2)], 3), "other below the high-value threshold -> no yield (threshold kept)")
	expect(not Rules.should_yield_unique_skill(x, [entry("y", 300, 260, 2, 2, 2)], 3), "other ranks lower after its own penalty -> no yield")
	expect(Rules.should_yield_unique_skill(entry("x", 268, 228, 2, 0, 3), [entry("z", 240, 240, -1, 1, 3)], 5), "own recent use (-40) makes the actor yield")
	expect(not Rules.should_yield_unique_skill(x, [], 0), "no other candidate -> no yield")
	# Determinism.
	var first := [Rules.should_yield_unique_skill(x, [y], 4), Rules.adjusted_skill_score(268, 3, 2)]
	for i in range(5): expect([Rules.should_yield_unique_skill(x, [y], 4), Rules.adjusted_skill_score(268, 3, 2)] == first, "same inputs -> same outputs")
	print("[ENEMY_TACTIC_RULES] checks=", checks, " failures=", failures)
	quit(0 if failures.is_empty() else 1)
