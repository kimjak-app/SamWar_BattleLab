extends SceneTree
# HUD block 5: the 2D hero cut-in, battle toasts, still skill toast and ending
# video on the scenario shell. Checks:
#   - all 21 registry heroes: video and title files exist, the shell's cut-in
#     loads that video into the shared 2D cut-in scene, starts it and ends on the
#     scene's 4.01 s schedule (cutin_finished); a hero outside the registry gets no
#     entry (the still toast route); the registry reads leave the engine
#     fingerprint unchanged;
#   - win practice played with [자동]: every engine skill_cast gets one cut-in or
#     still toast, in the engine's order; while a cut-in plays no skill event of
#     that cast is presented, input is locked and the auto play waits; after it,
#     the held events are presented in order; frames and real seconds from
#     skill_cast to the first skill_effect (engine) and of the 3D cut-in are
#     measured (at speed x4);
#   - toasts: BATTLE n for every round the lab showed, one "지원군 도착!" per
#     arriving round, no non-result toast after the result; the ending video plays
#     before the result panel, then the result toast; the panel shows after it;
#   - what headless playback could and could not show (video is_playing,
#     finished signal or fallback timer) is printed, not judged.
var h
var hud

func _initialize() -> void:
	run.call_deferred()

func engine_print(b: Node) -> Dictionary:
	var p: Dictionary = h.start_print(b)
	p["writes"] = b.writes.duplicate()
	p["phase"] = b.current_phase
	return p

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080)
	hud = h.shell.cutin_hud
	var Registry = load("res://scripts/ui/cutin/korea_mvp_hero_cutin_registry.gd")
	var Reader = load("res://scripts/battle3d/battle3d_cutin_reader.gd")
	h.expect(hud.get_node("HeroCutinOverlay").layer == 9 and hud.get_node("ToastLayer").layer == 8 and not hud.cutin_overlay.visible, "cut-in layer 9, toasts layer 8 (under the shell's 10), hidden at start")
	await h.press_scenario(self, "default")
	for i in range(5): await process_frame
	var lab = h.lab
	var b: Node = lab.engine
	h.expect(lab.hud_cutin_enabled and hud.toasts_played.size() >= 1 and hud.toasts_played[0] == {"tag":"round_start", "text":"BATTLE 1"}, "start: lab cut-in hold on, toast BATTLE 1 %s" % str(hud.toasts_played))
	# All 21 registry heroes through the shell's cut-in (time scale 8 so each 4.01 s schedule ends in about 0.5 s).
	var entries: Array = Registry.load_all_entries().filter(func(e): return bool(e.get("enabled", false)))
	h.expect(entries.size() == 21, "21 enabled registry heroes (%d)" % entries.size())
	var bad := []
	var playing_after_start := 0
	var ends := []
	Engine.time_scale = 8.0
	for e in entries:
		var entry: Dictionary = Reader.entry_for(str(e.hero_id), str(e.skill_id))
		if entry.is_empty() or not ResourceLoader.exists(str(entry.video_path)) or not ResourceLoader.exists(str(entry.skill_title_texture_path)):
			bad.append([e.hero_id, "entry/files"])
			continue
		if not hud.play_cutin(entry, 1.0):
			bad.append([e.hero_id, "load"])
			continue
		var video: VideoStreamPlayer = hud.presentation.video
		if not hud.cutin_overlay.visible or video.stream == null or video.stream.resource_path != str(entry.video_path) or hud.presentation.skill_title_png.texture.resource_path != str(entry.skill_title_texture_path) or hud.presentation.hero_name_label.text != str(entry.hero_name):
			bad.append([e.hero_id, "configure"])
		if video.is_playing(): playing_after_start += 1
		var started := Time.get_ticks_msec()
		var frames := 0
		while not hud.cutin_tween_done and frames < 2000:
			await process_frame
			frames += 1
		ends.append((Time.get_ticks_msec() - started) * Engine.time_scale / 1000.0)
		if not hud.cutin_tween_done: bad.append([e.hero_id, "no cutin_finished"])
		hud.end_cutin()
	Engine.time_scale = 1.0
	h.expect(bad.is_empty(), "21 heroes: entry and files, the video loaded into the shared cut-in scene, cutin_finished at the end of its schedule %s" % str(bad))
	ends.sort()
	print("[CUTIN] 21 heroes: video.is_playing() right after play_cutin = ", playing_after_start, "/21; schedule length (scaled s) min ", ends[0] if ends.size() else -1, " max ", ends[-1] if ends.size() else -1)
	h.expect(Reader.entry_for("guan_yu", "anything").is_empty() and Reader.fallback_image("guan_yu", "x") != "", "a hero outside the registry: no entry (still toast route) and a still picture")
	var before := engine_print(b)
	for k in range(20):
		for e in entries: Reader.entry_for(str(e.hero_id), str(e.skill_id))
		for u in b.all_battle_unit_states: Reader.entry_for(lab.hud_hero_id(u.unit_id), str(lab.hud_unique_skill(u.unit_id).get("skill_id", "")))
	h.expect(engine_print(b) == before, "registry reads x20: engine fingerprint unchanged")
	# Win practice with [자동] at speed x4: every cast, the hold, the order, the timing; toasts; ending.
	h.shell.choose_button.pressed.emit()
	await process_frame
	await h.press_scenario(self, "win_practice")
	lab = h.lab
	b = lab.engine
	for i in range(2): lab.speed_button.pressed.emit()
	lab._sync_views()
	seed(1)
	h.press_auto()
	var frames := 0
	var casts_engine := [] # [frame, msec, caster, skill_id]
	var first_effect := {} # engine log index of the cast -> [frame, msec]
	var cutin_spans := [] # [caster, start frame, end frame, real s]
	var hold_violations := [] # skill events presented while a cut-in held
	var lock_bad := 0
	var auto_wait_bad := 0
	var was_playing := false
	var cut_start := 0
	var cut_msec := 0
	var presented_before := 0
	var rounds_seen := {}
	var arrival_rounds := {}
	var result_frame := -1
	var ending_frame := -1
	var panel_frame := -1
	var ending_seen := false
	var log_seen := 0
	var ending_during_cutin := 0
	for i in range(200000):
		await process_frame
		frames += 1
		var log: Array = b.tactic_event_log.export()
		while log_seen < log.size():
			var ev: Dictionary = log[log_seen]
			if ev.kind == "skill_cast": casts_engine.append([frames, Time.get_ticks_msec(), ev.caster_id, ev.skill_id, log_seen])
			elif ev.kind in ["skill_effect", "skill_finished"]:
				for c in casts_engine:
					if c[2] == ev.caster_id and not first_effect.has(c[4]) and c[4] < log_seen: first_effect[c[4]] = [frames, Time.get_ticks_msec()]
			log_seen += 1
		if lab.ready_for_input:
			rounds_seen[lab.current_round] = true
			for a in lab.arrival_presentations: arrival_rounds[a.round] = true
		var playing: bool = hud.cutin_playing
		if playing and not was_playing:
			cut_start = frames
			cut_msec = Time.get_ticks_msec()
			presented_before = lab.skill_presentations.size() + lab.enemy_skill_presentations.size()
		if playing:
			# The cast itself is presented when the hold starts; nothing after it until the release.
			if lab.skill_presentations.size() + lab.enemy_skill_presentations.size() != presented_before: hold_violations.append([frames, h.shell.cutin_log[-1].caster if h.shell.cutin_log.size() else "?"])
			if not lab.hud_cutin_hold: lock_bad += 1
			if not lab._presentation_busy(): auto_wait_bad += 1
		if was_playing and not playing: cutin_spans.append([h.shell.cutin_log[-1].caster, cut_start, frames, (Time.get_ticks_msec() - cut_msec) / 1000.0])
		was_playing = playing
		if result_frame < 0 and not lab.battle_result.is_empty(): result_frame = frames
		if hud.ending_playing and (lab.hud_cutin_hold or hud.cutin_playing): ending_during_cutin += 1
		if hud.ending_playing and ending_frame < 0: ending_frame = frames
		if hud.ending_playing: ending_seen = true
		if h.shell.result_panel.visible and panel_frame < 0:
			panel_frame = frames
			break
	for i in range(30): await process_frame
	h.expect(h.shell.result_panel.visible and lab.battle_result == "victory", "win practice ends in victory with the result panel")
	var log_casts: Array = b.tactic_event_log.export().filter(func(e): return e.kind == "skill_cast").map(func(e): return [e.caster_id, e.skill_id])
	var shell_casts: Array = h.shell.cutin_log.map(func(c): return [c.caster, c.skill_id])
	h.expect(log_casts.size() >= 1 and shell_casts == log_casts, "every engine skill_cast got one cut-in or still toast, in the engine's order (%d) %s / %s" % [log_casts.size(), shell_casts, log_casts])
	h.expect(hold_violations.is_empty() and lock_bad == 0 and auto_wait_bad == 0, "while a cut-in played: no skill event presented (%s), lab held and busy every frame (%d / %d)" % [hold_violations.slice(0, 5), lock_bad, auto_wait_bad])
	h.expect(lab.hud_held_skill_events.is_empty() and not lab.hud_cutin_hold, "after the battle: nothing left held")
	h.expect(cutin_spans.size() >= 1 and cutin_spans.all(func(c): return c[3] >= 4.0), "at speed x%s every 3D cut-in lasts at least 4.01 real seconds (decision 3) %s" % [lab.SPEED_STEPS[lab.speed_index], cutin_spans.map(func(c): return c[3])])
	h.expect(ending_during_cutin == 0 and cutin_spans.size() == h.shell.cutin_log.filter(func(c): return c.route == "video").size(), "the ending waits for the last cut-in: every video cut-in ended before it (%d frames overlapped)" % ending_during_cutin)
	h.expect(ending_seen and ending_frame >= result_frame and panel_frame > ending_frame and hud.endings_played.size() == 1 and hud.endings_played[0].state == "victory",
		"ending video after the result (frame %d >= %d), result panel after it (%d) %s" % [ending_frame, result_frame, panel_frame, hud.endings_played])
	var tags: Array = hud.toasts_played.map(func(t): return t.tag)
	var round_toasts: Array = hud.toasts_played.filter(func(t): return t.tag == "round_start").map(func(t): return t.text)
	var want_rounds: Array = rounds_seen.keys()
	want_rounds.sort()
	h.expect(round_toasts == want_rounds.map(func(r): return "BATTLE %d" % r), "a BATTLE n toast for every round the lab showed %s / %s" % [round_toasts, want_rounds])
	h.expect(tags.count("reinforcement_arrival") == arrival_rounds.size(), "one 지원군 도착! toast per arriving round (%d / %d)" % [tags.count("reinforcement_arrival"), arrival_rounds.size()])
	var result_index: int = tags.find("result_victory")
	h.expect(result_index >= 0 and tags.slice(result_index + 1).is_empty() and hud.toasts_played[result_index].text == "승리!", "the result toast 승리! last, nothing after it %s" % str(tags))
	# Timing (measured): engine skill_cast -> first skill_effect, and the 3D cut-in, at speed x4.
	var timing := []
	for c in casts_engine:
		var fe = first_effect.get(c[4])
		timing.append([c[2], c[3], (fe[0] - c[0]) if fe else -1, ((fe[1] - c[1]) / 1000.0) if fe else -1.0])
	print("[CUTIN] speed x", lab.SPEED_STEPS[lab.speed_index], " Engine.time_scale=", Engine.time_scale, " casts (caster, skill, frames to first effect, real s)=", timing)
	print("[CUTIN] 3D cut-ins (caster, start frame, end frame, real s)=", cutin_spans, " routes=", h.shell.cutin_log.map(func(c): return [c.caster, c.route]))
	print("[CUTIN] toasts=", hud.toasts_played, " still toasts=", hud.still_toasts_played, " ending=", hud.endings_played, " frames: result ", result_frame, " ending ", ending_frame, " panel ", panel_frame)
	await h.close_shell(self)
	print("[CUTIN] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	hud = null
	await process_frame
	quit(code)
