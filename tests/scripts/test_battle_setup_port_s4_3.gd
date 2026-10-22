extends SceneTree
# S4-3 battle start setup port (`Engine` meta `samwar_battle_setup`, read once
# in `_ready` and removed). No key / an empty or malformed setup = the untouched
# start. `unit_overrides[id].troops_ratio` (0 < r <= 1) scales the six troop
# fields together (round down, at least 1); anything else is ignored with one
# log line. Other units and every other field are unchanged. The setup never
# turns the WorldMap / resume / save path on. The level in the setup applies
# before the first ally turn.
var h
const WIN_PRACTICE := 0.25

func _initialize() -> void:
	run.call_deferred()

func expected_scaled(value: int, ratio: float) -> int:
	# Written independently of the service: floor, at least 1 for a positive value.
	if value <= 0: return value
	var scaled := int(floor(value * ratio))
	return scaled if scaled >= 1 else 1

func without_troops(units: Array, ids: Array) -> Array:
	var copy: Array = units.duplicate(true)
	for values in copy:
		if ids.has(values.get("unit_id", "")):
			for f in h.TROOP_FIELDS: values.erase(f)
	return copy

func run() -> void:
	h = load("res://tests/scripts/support/battle_setup_s43_harness.gd").new()
	# Baseline: no key.
	var host = await h.open_s43(self, null)
	var b: Node = host.battle
	var base: Dictionary = h.start_state(b)
	var base_troops := {}
	for u in b.all_battle_unit_states: base_troops[u.unit_id] = h.troop_fields(u)
	h.expect(b.ignored_logs.is_empty() and h.flags(b) == [false, false, false] and b.get_enemy_ai_level() == "low" and b.get_pending_enemy_ai_level() == "", "no key: no log, flags untouched, level low")
	await h.close_bare(self, host)

	# Empty / malformed setups behave like no key.
	for setup in [{}, "x", 3, {"unit_overrides":"x"}, {"unit_overrides":{}}]:
		host = await h.open_s43(self, setup)
		b = host.battle
		var s: Dictionary = h.start_state(b)
		h.expect(h.fingerprint.diff(base.units, s.units).is_empty() and h.fingerprint.diff(base.controller, s.controller).is_empty() and s.logs == base.logs and s.flags == base.flags and s.momentum == base.momentum,
			"setup %s: start equals no key" % str(setup))
		h.expect(not Engine.has_meta(h.SETUP_KEY), "setup %s: meta removed" % str(setup))
		var want_logs := 1 if (typeof(setup) != TYPE_DICTIONARY or setup.get("unit_overrides") is String) else 0
		h.expect(b.ignored_logs.size() == want_logs, "setup %s: %d ignore line(s) %s" % [str(setup), want_logs, str(b.ignored_logs)])
		await h.close_bare(self, host)

	# Win practice: the five enemies at 0.25.
	var overrides := {}
	for id in h.ENEMY_IDS: overrides[id] = {"troops_ratio":WIN_PRACTICE}
	host = await h.open_s43(self, {"unit_overrides":overrides})
	b = host.battle
	var s: Dictionary = h.start_state(b)
	h.expect(not Engine.has_meta(h.SETUP_KEY) and b.ignored_logs.is_empty(), "win practice: meta removed, nothing ignored")
	for u in b.all_battle_unit_states:
		var want: Dictionary = base_troops[u.unit_id].duplicate()
		if h.ENEMY_IDS.has(u.unit_id):
			for f in h.TROOP_FIELDS: want[f] = expected_scaled(base_troops[u.unit_id][f], WIN_PRACTICE)
		h.expect(h.troop_fields(u) == want, "win practice %s troop fields %s" % [u.unit_id, str(h.troop_fields(u))])
		h.expect(b._calculate_unit_surviving_allocated_troops(u) == want.initial_allocated_troops, "win practice %s surviving troops = initial allocation" % u.unit_id)
	h.expect(without_troops(s.units, h.ENEMY_IDS) == without_troops(base.units, h.ENEMY_IDS), "win practice: every other unit field (cells, heroes, skills, flags) unchanged")
	h.expect(h.fingerprint.diff(base.controller, s.controller).is_empty() and s.logs == base.logs and s.momentum == base.momentum and s.flags == base.flags, "win practice: controller, logs, momentum, flags unchanged")
	var hud: Dictionary = BattleHudStateAdapter.build(b)
	for row in hud.enemy_roster:
		var u: BattleUnitState = h.unit_by_id(b, row.unit_id)
		h.expect(row.current_troops == u.current_hp and row.max_troops == u.max_hp and row.current_troops == expected_scaled(base_troops[row.unit_id].current_hp, WIN_PRACTICE), "HUD row %s shows %d / %d" % [row.unit_id, row.current_troops, row.max_troops])
	# Reinforcements keep the scaled values when they arrive (round 2).
	b.battle_round = 2
	b._try_deploy_reinforce_01_pair()
	var r01: BattleUnitState = h.unit_by_id(b, "enemy_reinforce_01_demo")
	h.expect(b._is_unit_state_available_for_battle_slot(r01) and r01.current_troops == expected_scaled(base_troops["enemy_reinforce_01_demo"].current_troops, WIN_PRACTICE), "reinforcement arrives with the scaled troops %d" % r01.current_troops)
	# Not a WorldMap battle.
	h.expect(b._get_current_battle_resume_id() == "" and b.worldmap_battle_context.is_empty(), "no resume id, no WorldMap context")
	await h.close_bare(self, host)

	# Ratio 1.0 changes nothing; an ally may be scaled too.
	host = await h.open_s43(self, {"unit_overrides":{"guan_yu":{"troops_ratio":1.0}, "yi_sunsin":{"troops_ratio":0.5}}})
	b = host.battle
	h.expect(h.troop_fields(h.unit_by_id(b, "guan_yu")) == base_troops["guan_yu"], "ratio 1.0: unchanged")
	var yi: Dictionary = h.troop_fields(h.unit_by_id(b, "yi_sunsin"))
	h.expect(h.TROOP_FIELDS.all(func(f): return yi[f] == expected_scaled(base_troops["yi_sunsin"][f], 0.5)), "ally ratio 0.5 applied " + str(yi))
	await h.close_bare(self, host)

	# Out of range / wrong types / unknown ids: ignored, one line each, start unchanged.
	var bad := {"guan_yu":{"troops_ratio":0}, "zhang_fei":{"troops_ratio":-0.25}, "xiahou_dun":{"troops_ratio":1.5}, "enemy_reinforce_01_demo":{"troops_ratio":"0.25"},
		"enemy_reinforce_02_test_unit":{"troops_ratio":true}, "yi_sunsin":{"ratio":0.5}, "jeong_dojeon":0.5, "nobody":{"troops_ratio":0.5}}
	host = await h.open_s43(self, {"unit_overrides":bad})
	b = host.battle
	s = h.start_state(b)
	h.expect(b.ignored_logs.size() == bad.size(), "every bad entry ignored with one line " + str(b.ignored_logs))
	h.expect(h.fingerprint.diff(base.units, s.units).is_empty() and h.fingerprint.diff(base.controller, s.controller).is_empty(), "bad entries: start equals no key")
	await h.close_bare(self, host)

	# The level in the setup applies before the first ally turn; an invalid one is ignored.
	host = await h.open_s43(self, {"enemy_ai_level":"mid"})
	b = host.battle
	h.expect(b.get_enemy_ai_level() == "mid" and b.get_pending_enemy_ai_level() == "" and h.flags(b) == [true, true, true] and b.current_phase == "ally_turn" and b.battle_round == 1, "setup level mid applied at once")
	await h.close_bare(self, host)
	host = await h.open_s43(self, {"enemy_ai_level":"low"})
	b = host.battle
	h.expect(b.get_enemy_ai_level() == "low" and h.flags(b) == [false, false, true], "setup level low: only the use cap")
	await h.close_bare(self, host)
	for level in ["hard", "", 2, null]:
		host = await h.open_s43(self, {"enemy_ai_level":level})
		b = host.battle
		h.expect(b.get_enemy_ai_level() == "low" and b.get_pending_enemy_ai_level() == "" and h.flags(b) == [false, false, false] and b.ignored_logs.size() == 1, "setup level %s ignored with one line" % str(level))
		await h.close_bare(self, host)

	# Read once: a second battle without a new setup starts untouched; no resume persist goes out.
	host = await h.open_s43(self, {"unit_overrides":overrides, "enemy_ai_level":"mid"})
	await h.close_bare(self, host)
	host = await h.open_bare(self)
	b = host.battle
	s = h.start_state(b)
	h.expect(h.fingerprint.diff(base.units, s.units).is_empty() and s.flags == [false, false, false] and b.get_enemy_ai_level() == "low", "second battle: nothing left from the first setup")
	await h.close_bare(self, host)
	host = await h.open_s43(self, {"unit_overrides":overrides, "enemy_ai_level":"mid"})
	b = host.battle
	await h.ally_wait(self, b)
	h.expect(b._get_current_battle_resume_id() == "" and b.persist_calls > 0, "persist attempts (%d) all return early: no resume id" % b.persist_calls)
	await h.close_bare(self, host)

	print("[BATTLE_SETUP_PORT] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
