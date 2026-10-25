extends SceneTree
# HUD block 3: the 2D enemy roster on the scenario shell (game window 1920x1080).
# Expected values are built here from the engine units and the engine's own
# functions; the engine's own 2D roster (the Battle_Main HUD inside the lab's
# engine) is compared too. Checks:
#   - the roster at the 2D rect; five cards in the engine's enemy slot order;
#     name = display_name, "병력 %d / %d", troop type name, status text =
#     _get_formation_status_summary_text, portrait = the engine's portrait (not
#     empty, different generals -> different portraits), troop icon not empty;
#     shown cards = the lab's shown unit views (the engine's slot availability);
#   - the four reads leave the engine state unchanged (units, controller, four
#     logs, momentum, writes, phase); N2 fills the engine's texture cache, which
#     the fingerprint does not contain: checked and reported separately;
#   - win practice played with [자동]: every frame, each shown card's name and
#     type are the engine's, its troops text is the engine's now or one frame
#     before, the status text does not change while an enemy replay is pending
#     and equals the engine once it is not, the gold frame is on exactly the
#     card of the lab's enemy_actor_id, hidden cards follow the lab's views,
#     reinforcement cards included once they arrive; every frame where a card's
#     shown state differs from the engine's own 2D card is classified by reason
#     (not arrived yet / arrived but held until the 3D arrival replay / the
#     lab's own unit view not re-synced yet that frame / dead)
#     and no other reason may occur; whether troop
#     numbers and troop icons change while an enemy replay is still pending is
#     measured (frames until the replay ends), not judged.
const SLOT_NAMES := ["Slot01", "Slot02", "Slot03", "Reinforce01", "Reinforce02"]
var h
var roster

func _initialize() -> void:
	run.call_deferred()

func enemies(b: Node) -> Array:
	return b.all_battle_unit_states.filter(func(u): return u.side == "enemy")

func card(index: int) -> Control:
	return roster.slot(index)

func card_text(index: int, part: String) -> String:
	return (card(index).get_node(part) as Label).text

func troops_text(u: BattleUnitState) -> String:
	return "병력 %d / %d" % [u.current_troops, u.max_troops]

func engine_print(b: Node) -> Dictionary:
	var p: Dictionary = h.start_print(b)
	p["writes"] = b.writes.duplicate()
	p["phase"] = b.current_phase
	return p

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080)
	roster = h.shell.enemy_roster
	h.expect(not roster.visible, "start screen: enemy roster hidden")
	await h.press_scenario(self, "default")
	for i in range(5): await process_frame
	var lab = h.lab
	var b: Node = lab.engine
	var types := {"infantry":"보병", "cavalry":"기병", "archer":"궁병", "gunner":"총병", "mounted_archer":"기마궁병"}
	h.expect(roster.visible and roster.roster_rect() == Rect2(1595, 156, 270, 524), "roster at the 2D rect 1595..1865 x 156..680: %s" % roster.roster_rect())
	var units := enemies(b)
	h.expect(units.size() == 5, "five enemy units")
	var portraits := {}
	for i in range(5):
		var u: BattleUnitState = units[i]
		var avail: bool = b.call("_is_unit_state_available_for_battle_slot", u)
		h.expect(card(i).visible == avail and card(i).visible == lab.views[u.unit_id].visible, "%s card %d shown = engine slot availability (%s)" % [u.unit_id, i, avail])
		if not card(i).visible: continue
		h.expect(card_text(i, "NameLabel") == u.display_name and card_text(i, "HpLabel") == troops_text(u) and card_text(i, "TroopTypeLabel") == types.get(u.unit_type, "부대"),
			"%s: name '%s', '%s', type '%s'" % [u.unit_id, card_text(i, "NameLabel"), card_text(i, "HpLabel"), card_text(i, "TroopTypeLabel")])
		var want_status := String(b.call("_get_formation_status_summary_text", u))
		h.expect(card_text(i, "StatusLabel") == want_status and card(i).get_node("StatusLabel").visible == (want_status != ""), "%s: status '%s'" % [u.unit_id, want_status])
		var portrait: Texture2D = (card(i).get_node("Portrait") as TextureRect).texture
		h.expect(portrait != null and portrait == b.call("_get_closeup_portrait_texture_for_unit", u) and (card(i).get_node("TroopIconRect") as TextureRect).texture != null, "%s: portrait = engine portrait, troop icon present" % u.unit_id)
		portraits[u.unit_id] = portrait
		# The engine's own 2D roster card (inside the lab's Battle_Main) shows the same texts.
		var twod := b.get_node("BattleUI/ProductionHudRoot/EnemyRosterHud/%s" % SLOT_NAMES[i])
		h.expect([twod.get_node("NameLabel").text, twod.get_node("HpLabel").text, twod.get_node("TroopTypeLabel").text, twod.get_node("StatusLabel").text, twod.get_node("Portrait").texture] \
			== [card_text(i, "NameLabel"), card_text(i, "HpLabel"), card_text(i, "TroopTypeLabel"), card_text(i, "StatusLabel"), portrait], "%s: same as the engine's own 2D card" % u.unit_id)
		h.expect(not card(i).get_node("UniqueSkillReadyIcon").visible and not card(i).get_node("TroopBar").visible, "%s: ready icon and troop bar hidden (2D)" % u.unit_id)
	var shown_ids: Array = portraits.keys()
	h.expect(shown_ids.size() >= 3 and portraits.values().filter(func(t): return t == portraits[shown_ids[0]]).size() == 1, "different generals, different portraits %s" % str(shown_ids))
	# Read only: the four reads change nothing in the engine fingerprint; N2 and the engine texture cache.
	var cache_before: int = b.hero_identity_texture_cache.size()
	var before := engine_print(b)
	lab.hud_portraits.clear()
	lab.hud_troop_icons.clear()
	lab.hud_status_texts.clear()
	for k in range(20):
		for u in units:
			lab.hud_display_name(u.unit_id)
			lab.hud_portrait(u.unit_id)
			lab.hud_troop_icon(u.unit_id)
			lab.hud_status_summary(u.unit_id)
	h.expect(engine_print(b) == before, "four reads x20 for five units: engine fingerprint unchanged (units, controller, four logs, momentum, writes, phase)")
	h.expect(not before.controller.has("hero_identity_texture_cache"), "the fingerprint does not contain the engine texture cache (checked separately)")
	print("[ENEMY_ROSTER] engine hero_identity_texture_cache size before=", cache_before, " after=", b.hero_identity_texture_cache.size(), " (the engine's own 2D roster bridge reads portraits every frame)")
	h.expect(b.hero_identity_texture_cache.size() >= cache_before, "N2 only adds to the engine texture cache")
	# Status text held during an enemy replay: an ally wait starts the enemy slot; once the
	# engine has finished it and the 3D replay is pending, a status is put on guan_yu
	# (test-only fixture write).
	var g: BattleUnitState = units[0]
	var gi := 0
	h.click(b.active_unit_state.grid_cell)
	lab._sync_views()
	h.press_wait()
	var waited := 0
	# The lab queues the replay once the engine has finished its enemy turn (the engine animates first).
	while not (lab._enemy_presentation_busy() and b.current_phase != "enemy_turn") and waited < 2000:
		await process_frame
		waited += 1
	var old_status := card_text(gi, "StatusLabel")
	g.apply_status_effect("burn", 2, 12)
	var new_status := String(b.call("_get_formation_status_summary_text", g))
	h.expect(lab._enemy_presentation_busy() and new_status != old_status, "during the enemy replay the engine status text changes ('%s' -> '%s')" % [old_status, new_status])
	var held_frames := 0
	var changed_early := false
	while lab._enemy_presentation_busy():
		await process_frame
		if lab._enemy_presentation_busy():
			held_frames += 1
			if card_text(gi, "StatusLabel") != old_status: changed_early = true
	for i in range(3): await process_frame
	h.expect(not changed_early and held_frames > 0 and card_text(gi, "StatusLabel") == String(b.call("_get_formation_status_summary_text", g)),
		"card status held for %d replay frames, then = engine '%s' (card '%s')" % [held_frames, b.call("_get_formation_status_summary_text", g), card_text(gi, "StatusLabel")])
	print("[ENEMY_ROSTER] status hold: replay frames held=", held_frames, " old='", old_status, "' new='", card_text(gi, "StatusLabel"), "'")
	# Redraw only on change: while nothing changes the roster is not re-applied; one value change re-applies it exactly once.
	var settle := 0
	while (lab._enemy_presentation_busy() or b.current_phase != "ally_turn") and settle < 2000:
		await process_frame
		settle += 1
	for i in range(5): await process_frame
	var applies: int = roster.apply_count
	for i in range(20): await process_frame
	h.expect(roster.apply_count == applies, "20 still frames: the roster is not re-applied (apply_count %d -> %d)" % [applies, roster.apply_count])
	var still_status := card_text(gi, "StatusLabel")
	g.apply_status_effect("burn", 3, 12) # test-only fixture write: one card value changes
	var changed_status := String(b.call("_get_formation_status_summary_text", g))
	for i in range(5): await process_frame
	h.expect(changed_status != still_status and card_text(gi, "StatusLabel") == changed_status and roster.apply_count == applies + 1,
		"one status change ('%s' -> '%s'): the roster is re-applied exactly once (apply_count %d -> %d)" % [still_status, changed_status, applies, roster.apply_count])
	# Win practice with [자동]: every frame.
	h.shell.choose_button.pressed.emit()
	await process_frame
	h.expect(not roster.visible, "[시나리오 선택]: roster hidden")
	await h.press_scenario(self, "win_practice")
	lab = h.lab
	b = lab.engine
	units = enemies(b)
	for i in range(2): lab.speed_button.pressed.emit()
	lab._sync_views()
	seed(1)
	h.press_auto()
	var prev_troops := {}
	for u in units: prev_troops[u.unit_id] = troops_text(u)
	var frames := 0
	var bad := []
	var lagged := 0
	var status_frozen_changes := 0
	var status_settled_mismatch := 0
	var busy_status := {}
	var status_changes := 0 # card status text changes seen
	var frozen_behind := 0 # card-frames during an enemy replay where the engine's status text already differs from the card
	var last_status := {}
	var frame_bad := 0
	var reinforce_frames := 0
	var vis_diff := {"not_arrived":0, "held_until_arrival_replay":0, "lab_view_not_synced_yet":0, "dead":0, "other":0}
	var other_examples := []
	var troop_changes := [] # [frame, unit_id, busy]
	var icon_changes := [] # [frame, unit_id, busy]
	var busy_end_frames := []
	var was_busy := false
	var last_icons := {}
	var last_card_troops := {}
	for i in range(80000):
		await process_frame
		if not roster.visible:
			if h.shell.result_panel.visible: break
			continue
		frames += 1
		var busy: bool = lab._enemy_presentation_busy()
		if was_busy and not busy: busy_end_frames.append(frames)
		was_busy = busy
		var highlighted := []
		for k in range(5):
			var u: BattleUnitState = units[k]
			var shown: bool = lab.views[u.unit_id].visible
			if card(k).visible != shown: bad.append([frames, u.unit_id, "visible"])
			var twod_visible: bool = b.get_node("BattleUI/ProductionHudRoot/EnemyRosterHud/%s" % SLOT_NAMES[k]).visible
			if card(k).visible != twod_visible:
				var avail: bool = b.call("_is_unit_state_available_for_battle_slot", u)
				var reason := "dead" if not u.is_alive() else ("not_arrived" if not avail and twod_visible else ("held_until_arrival_replay" if avail and twod_visible and not lab._unit_shown(u.unit_id) else ("lab_view_not_synced_yet" if avail and twod_visible and not lab.views[u.unit_id].visible else "other")))
				vis_diff[reason] += 1
				if reason == "other" and other_examples.size() < 5: other_examples.append([frames, u.unit_id, card(k).visible, twod_visible])
			if not card(k).visible: continue
			if k >= 3: reinforce_frames += 1
			if card_text(k, "NameLabel") != u.display_name or card_text(k, "TroopTypeLabel") != types.get(u.unit_type, "부대"): bad.append([frames, u.unit_id, "name/type"])
			var now_troops := troops_text(u)
			var shown_troops := card_text(k, "HpLabel")
			if shown_troops != now_troops:
				if shown_troops == prev_troops[u.unit_id]: lagged += 1
				else: bad.append([frames, u.unit_id, "troops %s vs %s" % [shown_troops, now_troops]])
			if last_card_troops.get(u.unit_id, shown_troops) != shown_troops: troop_changes.append([frames, u.unit_id, busy])
			last_card_troops[u.unit_id] = shown_troops
			var st := card_text(k, "StatusLabel")
			if last_status.has(u.unit_id) and last_status[u.unit_id] != st: status_changes += 1
			last_status[u.unit_id] = st
			if busy and st != String(b.call("_get_formation_status_summary_text", u)): frozen_behind += 1
			if busy:
				if busy_status.has(u.unit_id) and busy_status[u.unit_id] != st: status_frozen_changes += 1
				busy_status[u.unit_id] = st
			else:
				busy_status.erase(u.unit_id)
				if st != String(b.call("_get_formation_status_summary_text", u)): status_settled_mismatch += 1
			var icon: Texture2D = (card(k).get_node("TroopIconRect") as TextureRect).texture
			if last_icons.has(u.unit_id) and last_icons[u.unit_id] != icon: icon_changes.append([frames, u.unit_id, busy])
			last_icons[u.unit_id] = icon
			if card(k).has_theme_stylebox_override(&"panel"): highlighted.append(u.unit_id)
		var want_actor := [] if lab.enemy_actor_id == "" or not lab.views.has(lab.enemy_actor_id) or not lab.views[lab.enemy_actor_id].visible else [lab.enemy_actor_id]
		if highlighted != want_actor: frame_bad += 1
		for u in units: prev_troops[u.unit_id] = troops_text(u)
		if h.shell.result_panel.visible: break
	h.expect(h.shell.result_panel.visible and b.call("_get_battle_result_state") == "victory", "win practice ends in victory")
	h.expect(bad.is_empty(), "every frame: shown cards follow the lab views, name/type = engine, troops = engine now or one frame before (wrong %s)" % str(bad.slice(0, 5)))
	h.expect(status_frozen_changes == 0 and status_settled_mismatch == 0, "status text: unchanged while an enemy replay is pending (%d changes), = engine otherwise (%d mismatches)" % [status_frozen_changes, status_settled_mismatch])
	h.expect(frame_bad == 0, "gold frame on exactly the enemy_actor_id card every frame (%d bad frames)" % frame_bad)
	h.expect(reinforce_frames > 0, "reinforcement cards shown and checked (%d card-frames)" % reinforce_frames)
	h.expect(not roster.visible, "after the result: roster hidden with the HUD (like 2D)")
	h.expect(vis_diff.other == 0, "card shown state vs the engine's own 2D card: only 'not arrived' / 'held until arrival replay' / 'dead' differences %s %s" % [vis_diff, other_examples])
	# Timing (measured): changes shown while an enemy replay was still pending, and frames until it ended.
	var ahead := func(changes: Array) -> Array:
		var out := []
		for c in changes:
			if not c[2]: continue
			var ends := busy_end_frames.filter(func(f): return f > c[0])
			out.append([c[1], (ends[0] - c[0]) if not ends.is_empty() else -1])
		return out
	print("[ENEMY_ROSTER] auto frames=", frames, " troops one-frame lag=", lagged, " troop changes=", troop_changes.size(), " during enemy replay (unit, frames until replay end)=", ahead.call(troop_changes),
		" icon changes=", icon_changes.size(), " during enemy replay=", ahead.call(icon_changes), " card shown != engine 2D card (card-frames)=", vis_diff)
	print("[ENEMY_ROSTER] troop changes (frame, unit, during replay)=", troop_changes, " icon changes=", icon_changes)
	print("[ENEMY_ROSTER] status text: card changes=", status_changes, " card-frames held behind the engine during an enemy replay=", frozen_behind)
	await h.close_shell(self)
	print("[ENEMY_ROSTER] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	roster = null
	await process_frame
	quit(code)
