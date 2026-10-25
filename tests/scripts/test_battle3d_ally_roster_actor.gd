extends SceneTree
# HUD block 4-1: the 2D ally roster and current-actor panel on the scenario
# shell (game window 1920x1080). Expected values are built here from the engine
# units, the engine's own functions and the hero data registry; the engine's own
# 2D HUDs (AllyRosterHud and CurrentActorInfoHud of the Battle_Main inside the
# lab's engine) are compared too. Checks:
#   - both HUDs at the 2D rects; ally cards in the engine's ally slot order with
#     the engine's name, "병력 %d / %d", type, status text, portrait, troop icon;
#     the ready icon only on the active ally (= _can_use_unique_skill); the gold
#     frame on exactly the active ally's card; the same as the engine's 2D cards;
#   - the current-actor panel for each selectable ally: name, type, troops, three
#     stats, unique skill name/description, portrait, troop icon, ready badge,
#     status rows, legend and terrain = the engine/registry values ("-" stats when
#     the registry has none); every difference from the engine's 2D panel is
#     classified (registry type name / hp vs troops / stats fallback, other = 0);
#   - the new reads (N5, N6, registry) and the wrapper reads leave the engine
#     fingerprint unchanged and return copies; N2 and the engine texture cache are
#     reported separately; N3 is read again when the unit's facing changes;
#   - a real mouse click where the roster lies over the lab's [대기] button still
#     presses the button (the HUD ignores the mouse); every HUD node ignores it;
#   - the status rows and card status text do not change while an enemy replay is
#     pending and equal the engine once it is not;
#   - win practice played with [자동]: every frame the cards and the panel equal the
#     engine (allowed lags counted by reason, other = 0); the frames where the 2D
#     actor rule (active ally in an ally input phase) differs from the lab's
#     `selected`, and what the 2D and 3D panels show during the enemy turn, are
#     measured; both HUDs are hidden after the result.
const SLOT_NAMES := ["Slot01", "Slot02", "Slot03", "Reinforce01", "Reinforce02"]
const HeroData = preload("res://scripts/battle3d/battle3d_hero_data_reader.gd")
const TYPES := {"infantry":"보병", "cavalry":"기병", "archer":"궁병", "gunner":"총병", "mounted_archer":"기마궁병"}
const ALIASES := {"yi_sunsin":"yi_sun_sin", "jeong_dojeon":"jeong_do_jeon", "gim_yusin":"kim_yu_sin", "gwon_yul":"kwon_yul"} # the 2D bridge's table
const COUNTRIES := ["korea", "china", "japan", "mongol"]
const EMPTY_ACTOR := {"name":"대기", "type":"-", "troops":"병력 - / -", "stats":["지휘 -", "무력 -", "지력 -"], "skill":"고유특기 -", "skill_desc":"",
	"portrait":null, "troop_icon":null, "ready":false, "rows":[], "legend":true, "terrain":["평지", "방어 0%\n이동 0%"]}
var h
var roster
var actor_hud

func _initialize() -> void:
	run.call_deferred()

func allies(b: Node) -> Array:
	return b.all_battle_unit_states.filter(func(u): return u.side == "ally")

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

func twod_card(b: Node, index: int) -> Control:
	return b.get_node("BattleUI/ProductionHudRoot/AllyRosterHud/%s" % SLOT_NAMES[index])

func twod_panel(b: Node) -> Control:
	return b.get_node("BattleUI/ProductionHudRoot/CurrentActorInfoHud")

func tex(hud: Control, path: String) -> Texture2D:
	var rect := hud.get_node_or_null(path) as TextureRect
	return null if rect == null or not rect.visible else rect.texture

func label(hud: Control, path: String) -> String:
	return (hud.get_node(path) as Label).text

func panel_values(hud: Control) -> Dictionary:
	# What a current-actor panel (2D or 3D: the same node tree) shows.
	var rows := []
	for index in range(1, 6):
		var row := hud.get_node("StatusArea/StatusRow%02d" % index) as Control
		if row.visible: rows.append(label(row, "Label"))
	var badge := hud.get_node_or_null("BoundUniqueSkillReadyBadge") as Control
	var legend := hud.get_node_or_null("StatusArea/ProductionEmptyStatusLegend") as Control
	return {"name":label(hud, "InfoArea/NameLabel"), "type":label(hud, "InfoArea/TroopClassLabel"), "troops":label(hud, "InfoArea/TroopRow/TroopsLabel"),
		"stats":[label(hud, "InfoArea/StatsRow/CommandStat/Value"), label(hud, "InfoArea/StatsRow/MightStat/Value"), label(hud, "InfoArea/StatsRow/IntellectStat/Value")],
		"skill":label(hud, "InfoArea/UniqueTraitArea/UniqueTraitLabel"), "skill_desc":label(hud, "InfoArea/UniqueTraitArea/UniqueTraitSummaryLabel"),
		"portrait":tex(hud, "PortraitSlot/BoundPortrait"), "troop_icon":tex(hud, "InfoArea/TroopRow/TroopTypeIconSlot/BoundTroopTypeIcon"),
		"ready":badge != null and badge.visible, "rows":rows, "legend":legend != null and legend.visible,
		"terrain":[label(hud, "TerrainArea/TerrainNameLabel"), label(hud, "TerrainArea/TerrainEffectLabel")]}

func hero_id_of(b: Node, u: BattleUnitState) -> String:
	var hero_id := String(b.call("_get_hero_id_for_unit_state", u))
	if hero_id.is_empty(): hero_id = u.unit_id.trim_suffix("_battle_unit")
	return ALIASES.get(hero_id, hero_id)

func country_of(hero_id: String) -> String:
	for country in COUNTRIES:
		if ResourceLoader.exists("res://assets/heroes/portraits/current_actor/%s/%s_%s.png" % [country, country, hero_id]): return country
	return ""

func status_rows(b: Node, u: BattleUnitState) -> Array:
	var rows := []
	for entry in b.call("_get_unit_status_display_entries", u):
		var summary := String(entry.get("summary", entry.get("label", "")))
		if not summary.contains("부상") and rows.size() < 5: rows.append(summary)
	return rows

func expected_panel(b: Node) -> Dictionary:
	# The engine's active unit with the 2D priorities: registry first, then the engine.
	var u: BattleUnitState = b.active_unit_state
	if u == null: return EMPTY_ACTOR.duplicate(true)
	var hero_id := hero_id_of(b, u)
	var stats: Dictionary = HeroData.Registry.get_base_stats(hero_id).get("stats", {})
	var unit_type := String(HeroData.Registry.get_battle_profile(hero_id).get("unit_type", u.unit_type))
	var skill: Dictionary = HeroData.Registry.get_unique_skill_for_hero(hero_id)
	if skill.is_empty(): skill = b.call("_get_unique_skill_for_unit", u)
	var country := country_of(hero_id)
	var portrait: Texture2D = null if country.is_empty() else load("res://assets/heroes/portraits/current_actor/%s/%s_%s.png" % [country, country, hero_id])
	if portrait == null: portrait = b.call("_get_closeup_portrait_texture_for_unit", u)
	var icon: Texture2D = null if country.is_empty() else b.call("_get_troop_icon_texture_for_visual_key", "%s_%s" % [country, unit_type], null)
	if icon == null: icon = b.call("_get_troop_icon_texture_for_visual_key", "", u)
	var stat := func(key: String, word: String) -> String: return "%s %s" % [word, str(int(stats[key])) if stats.has(key) else "-"]
	var rows := status_rows(b, u)
	return {"name":u.display_name, "type":TYPES.get(unit_type, "부대"), "troops":troops_text(u), "stats":[stat.call("leadership", "지휘"), stat.call("martial", "무력"), stat.call("intelligence", "지력")],
		"skill":String(skill.get("display_name", skill.get("name", "고유특기"))), "skill_desc":String(skill.get("description", skill.get("concept", ""))),
		"portrait":portrait, "troop_icon":icon, "ready":bool(b.call("_can_use_unique_skill", u)), "rows":rows, "legend":rows.is_empty(), "terrain":EMPTY_ACTOR.terrain}

func twod_reason(b: Node, key: String) -> String:
	# Why the engine's 2D panel may show another value than the 3D one for the active unit.
	var u: BattleUnitState = b.active_unit_state
	if u == null: return "other"
	var hero_id := hero_id_of(b, u)
	var unit_type := String(HeroData.Registry.get_battle_profile(hero_id).get("unit_type", u.unit_type))
	if key == "type" and HeroData.Registry.get_unit_type_display_name(unit_type, TYPES.get(unit_type, "부대")) != TYPES.get(unit_type, "부대"): return "registry_type_name"
	if key == "troops" and (u.current_hp != u.current_troops or u.max_hp != u.max_troops): return "hp_vs_troops"
	if key == "stats" and not HeroData.Registry.get_base_stats(hero_id).has("stats"): return "stats_fallback"
	if (key == "rows" or key == "legend") and roster_busy(): return "status_held_replay"
	return "other"

func roster_busy() -> bool:
	return h.lab._enemy_presentation_busy()

func diff_keys(a: Dictionary, c: Dictionary) -> Array:
	return a.keys().filter(func(k): return a[k] != c[k])

func all_ignore(node: Node) -> Array:
	# Controls that would take the mouse (must be none).
	var out := []
	if node is Control and (node as Control).mouse_filter != Control.MOUSE_FILTER_IGNORE: out.append(str(node.get_path()))
	for child in node.get_children(): out.append_array(all_ignore(child))
	return out

func mouse(tree_root: Window, at: Vector2, pressed := false, motion := false) -> void:
	var event: InputEvent
	if motion:
		event = InputEventMouseMotion.new()
	else:
		event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	event.position = at
	event.global_position = at
	tree_root.push_input(event)

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080)
	roster = h.shell.ally_roster
	actor_hud = h.shell.actor_hud
	h.expect(not roster.visible and not actor_hud.visible, "start screen: ally roster and current-actor panel hidden")
	await h.press_scenario(self, "default")
	for i in range(5): await process_frame
	var lab = h.lab
	var b: Node = lab.engine
	var twod_roster_rect: Rect2 = b.get_node("BattleUI/ProductionHudRoot/AllyRosterHud").get_global_rect()
	h.expect(roster.visible and roster.roster_rect() == twod_roster_rect and roster.roster_rect() == Rect2(54, 150, 270, 524), "roster at the 2D rect 54..324 x 150..674: %s (2D %s)" % [roster.roster_rect(), twod_roster_rect])
	h.expect(actor_hud.visible and actor_hud.panel_rect() == twod_panel(b).get_global_rect() and actor_hud.panel_rect() == Rect2(451, 825, 1012, 220), "panel at the 2D rect 451..1463 x 825..1045: %s (2D %s)" % [actor_hud.panel_rect(), twod_panel(b).get_global_rect()])
	h.expect(all_ignore(roster).is_empty() and all_ignore(actor_hud).is_empty(), "every HUD node ignores the mouse %s" % str(all_ignore(roster) + all_ignore(actor_hud)))
	var badge_3d: Control = actor_hud.hud.get_node("BoundUniqueSkillReadyBadge")
	var badge_2d: Control = twod_panel(b).get_node("BoundUniqueSkillReadyBadge")
	h.expect(badge_3d.get_global_rect() == badge_2d.get_global_rect() and badge_3d.get_global_rect() == Rect2(573, 807, 84, 84), "ready badge at the 2D rect 573..657 x 807..891: %s" % badge_3d.get_global_rect())
	var units := allies(b)
	h.expect(units.size() == 5, "five ally units (%d)" % units.size())
	var portraits := {}
	var check_cards := func(label_text: String) -> void:
		var golden := []
		var ready := []
		for i in range(units.size()):
			var u: BattleUnitState = units[i]
			var avail: bool = b.call("_is_unit_state_available_for_battle_slot", u)
			h.expect(card(i).visible == avail and card(i).visible == lab.views[u.unit_id].visible, "%s: %s card %d shown = engine slot availability (%s)" % [label_text, u.unit_id, i, avail])
			if not card(i).visible: continue
			h.expect(card_text(i, "NameLabel") == u.display_name and card_text(i, "HpLabel") == troops_text(u) and card_text(i, "TroopTypeLabel") == TYPES.get(u.unit_type, "부대"),
				"%s: %s name '%s', '%s', type '%s'" % [label_text, u.unit_id, card_text(i, "NameLabel"), card_text(i, "HpLabel"), card_text(i, "TroopTypeLabel")])
			var want_status := String(b.call("_get_formation_status_summary_text", u))
			h.expect(card_text(i, "StatusLabel") == want_status and card(i).get_node("StatusLabel").visible == (want_status != ""), "%s: %s status '%s'" % [label_text, u.unit_id, want_status])
			var portrait: Texture2D = (card(i).get_node("Portrait") as TextureRect).texture
			var icon: Texture2D = (card(i).get_node("TroopIconRect") as TextureRect).texture
			h.expect(portrait != null and portrait == b.call("_get_closeup_portrait_texture_for_unit", u) and icon != null and icon == b.call("_get_troop_icon_texture_for_visual_key", "", u),
				"%s: %s portrait and troop icon = the engine's" % [label_text, u.unit_id])
			portraits[u.unit_id] = portrait
			var want_ready: bool = b.call("_can_use_unique_skill", u)
			h.expect(card(i).get_node("UniqueSkillReadyIcon").visible == want_ready and want_ready == bool(b.call("_is_unique_skill_ready_for_formation_guide", u)),
				"%s: %s ready icon = _can_use_unique_skill (%s) = the 2D formation-guide rule" % [label_text, u.unit_id, want_ready])
			if want_ready: ready.append(u.unit_id)
			if card(i).has_theme_stylebox_override(&"panel"): golden.append(u.unit_id)
			var twod := twod_card(b, i)
			h.expect([twod.get_node("NameLabel").text, twod.get_node("HpLabel").text, twod.get_node("TroopTypeLabel").text, twod.get_node("StatusLabel").text, twod.get_node("Portrait").texture,
				twod.get_node("TroopIconRect").texture, twod.get_node("UniqueSkillReadyIcon").visible, twod.has_theme_stylebox_override(&"panel")] \
				== [card_text(i, "NameLabel"), card_text(i, "HpLabel"), card_text(i, "TroopTypeLabel"), card_text(i, "StatusLabel"), portrait, icon,
				card(i).get_node("UniqueSkillReadyIcon").visible, card(i).has_theme_stylebox_override(&"panel")], "%s: %s same as the engine's own 2D card (texts, portrait, icon, ready, gold frame)" % [label_text, u.unit_id])
			h.expect(not card(i).get_node("TroopBar").visible and not card(i).get_node("UniqueSkillReadyLabel").visible, "%s: %s troop bar and ready label hidden (2D)" % [label_text, u.unit_id])
		var active: BattleUnitState = b.active_unit_state
		h.expect(golden == [active.unit_id] and ready.size() <= 1 and (ready.is_empty() or ready == [active.unit_id]), "%s: gold frame on exactly the active ally %s %s, ready icon only on it %s" % [label_text, active.unit_id, golden, ready])
	var twod_diffs := {}
	var check_panel := func(label_text: String) -> void:
		var shown: Dictionary = panel_values(actor_hud.hud)
		var want := expected_panel(b)
		h.expect(shown == want, "%s: panel = engine/registry values (differs in %s: %s vs %s)" % [label_text, diff_keys(shown, want), str(shown.get(diff_keys(shown, want)[0])) if not diff_keys(shown, want).is_empty() else "", str(want.get(diff_keys(shown, want)[0])) if not diff_keys(shown, want).is_empty() else ""])
		var twod: Dictionary = panel_values(twod_panel(b))
		for key in diff_keys(shown, twod):
			var reason := twod_reason(b, key)
			twod_diffs["%s:%s" % [key, reason]] = twod_diffs.get("%s:%s" % [key, reason], 0) + 1
			h.expect(reason != "other", "%s: panel %s '%s' vs the engine's 2D panel '%s' (%s)" % [label_text, key, shown[key], twod[key], reason])
		print("[ALLY_ACTOR] ", label_text, " panel: ", shown.name, " / ", shown.type, " / ", shown.troops, " / ", shown.stats, " / ", shown.skill, " / rows ", shown.rows, " / ready ", shown.ready,
			" / portrait ", shown.portrait.resource_path if shown.portrait != null else "none", " / 2D differs in ", diff_keys(shown, twod))
	check_cards.call("start")
	check_panel.call("start")
	var shown_ids: Array = portraits.keys()
	h.expect(shown_ids.size() >= 3 and portraits.values().filter(func(t): return t == portraits[shown_ids[0]]).size() == 1, "different generals, different portraits %s" % str(shown_ids))
	# Each selectable ally as the active unit (a click on its cell selects it, as in the 2D).
	var checked_heroes := []
	for u in units:
		if not lab.views[u.unit_id].visible or u == b.active_unit_state: continue
		h.click(u.grid_cell)
		lab._sync_views()
		for k in range(3): await process_frame
		if b.active_unit_state != u:
			print("[ALLY_ACTOR] ", u.unit_id, " not selected by a click (active ", b.active_unit_state.unit_id, ")")
			continue
		check_cards.call("selected " + u.unit_id)
		check_panel.call("selected " + u.unit_id)
		checked_heroes.append(hero_id_of(b, u))
	h.expect(checked_heroes.size() >= 1, "other allies selected and checked %s" % str(checked_heroes))
	h.expect(h.shell._stat({}, "leadership") == "-" and h.shell._stat({"leadership":81.0}, "leadership") == 81 and HeroData.base_stats("no_such_hero_4_1").is_empty(),
		"registry without stats -> '-' (the 2D unit-field fallback is not approved)")
	var registry_less := units.filter(func(u): return not HeroData.Registry.get_base_stats(hero_id_of(b, u)).has("stats")).map(func(u): return u.unit_id)
	print("[ALLY_ACTOR] allies without registry stats (shown '-'): ", registry_less, " ; 2D panel differences by reason: ", twod_diffs)
	# Read only: the new reads N5/N6, the registry and the wrapper reads change nothing in the engine fingerprint.
	var cache_before: int = b.hero_identity_texture_cache.size()
	var before := engine_print(b)
	lab.hud_status_entry_lists.clear()
	lab.hud_troop_icons_by_key.clear()
	HeroData.countries.clear()
	HeroData.portraits.clear()
	for k in range(20):
		for u in units:
			var hid: String = lab.hud_hero_id(u.unit_id)
			lab.hud_status_entries(u.unit_id)
			lab.hud_skill_ready(u.unit_id)
			lab.hud_unique_skill(u.unit_id)
			HeroData.base_stats(HeroData.resolve_hero_id(hid, u.unit_id))
			HeroData.battle_profile(HeroData.resolve_hero_id(hid, u.unit_id))
			HeroData.unique_skill_for_hero(HeroData.resolve_hero_id(hid, u.unit_id))
			var country := HeroData.portrait_country(HeroData.resolve_hero_id(hid, u.unit_id))
			if country != "": lab.hud_troop_icon_for_key("%s_%s" % [country, u.unit_type])
		h.shell.ally_cards()
		h.shell.current_actor()
	h.expect(engine_print(b) == before, "new reads x20 for five allies (+ shell cards and actor): engine fingerprint unchanged (units, controller, four logs, momentum, writes, phase)")
	print("[ALLY_ACTOR] engine hero_identity_texture_cache size before=", cache_before, " after=", b.hero_identity_texture_cache.size())
	var first: BattleUnitState = units[0]
	var first_hero := hero_id_of(b, first)
	h.expect(lab.hud_hero_id(first.unit_id) == String(b.call("_get_hero_id_for_unit_state", first)), "N6 = engine _get_hero_id_for_unit_state ('%s' for unit '%s', registry id '%s')" % [lab.hud_hero_id(first.unit_id), first.unit_id, first_hero])
	var entries: Array = lab.hud_status_entries(first.unit_id)
	entries.append({"summary":"test"})
	h.expect(lab.hud_status_entries(first.unit_id) == (b.call("_get_unit_status_display_entries", first) as Array) and lab.hud_status_entries(first.unit_id).size() == entries.size() - 1, "N5 = engine entries, a copy")
	var stats_copy: Dictionary = HeroData.base_stats(first_hero)
	var profile_copy: Dictionary = HeroData.battle_profile(first_hero)
	var skill_copy: Dictionary = HeroData.unique_skill_for_hero(first_hero)
	h.expect(stats_copy == HeroData.Registry.get_base_stats(first_hero) and profile_copy == HeroData.Registry.get_battle_profile(first_hero) and skill_copy == HeroData.Registry.get_unique_skill_for_hero(first_hero), "registry reads = the registry values")
	stats_copy["changed_by_test"] = true
	profile_copy["changed_by_test"] = true
	skill_copy["changed_by_test"] = true
	h.expect(not HeroData.Registry.get_base_stats(first_hero).has("changed_by_test") and not HeroData.Registry.get_battle_profile(first_hero).has("changed_by_test") \
		and not HeroData.Registry.get_unique_skill_for_hero(first_hero).has("changed_by_test"), "registry reads are copies")
	# N3 again when the facing changes (test-only fixture write, restored).
	var old_facing := first.facing
	var new_facing := "left" if old_facing != "left" else "right"
	var old_icon: Texture2D = lab.hud_troop_icon(first.unit_id)
	first.facing = new_facing
	var new_icon: Texture2D = lab.hud_troop_icon(first.unit_id)
	h.expect(lab.hud_troop_icons[first.unit_id][0] == new_facing and new_icon == b.call("_get_troop_icon_texture_for_visual_key", "", first), "N3: facing %s -> %s re-read, icon = the engine's for the new facing" % [old_facing, new_facing])
	print("[ALLY_ACTOR] N3 facing ", old_facing, " -> ", new_facing, ": icon ", "changed" if new_icon != old_icon else "same texture", " (", old_icon.resource_path if old_icon else "none", " -> ", new_icon.resource_path if new_icon else "none", ")")
	first.facing = old_facing
	h.expect(lab.hud_troop_icon(first.unit_id) == old_icon and lab.hud_troop_icons[first.unit_id][0] == old_facing, "N3: back to %s" % old_facing)
	# Overlap with the lab controls (kept until block 4-2), and a real click on [대기] through the roster.
	for pair in [["공격", lab.attack_button], ["대기", lab.wait_button], ["방어", lab.defend_button], ["책략", lab.strategy_button], ["특기", lab.skill_button], ["방향 줄", lab.facing_ui], ["정보", lab.info]]:
		var r: Rect2 = (pair[1] as Control).get_global_rect()
		var o := r.intersection(roster.roster_rect())
		var o2 := r.intersection(actor_hud.panel_rect())
		print("[ALLY_ACTOR] overlap ", pair[0], " ", r, " visible=", (pair[1] as Control).is_visible_in_tree(), " with roster ", o.size if o.has_area() else Vector2.ZERO, " with panel ", o2.size if o2.has_area() else Vector2.ZERO)
	# Block 4-2 moved the lab's buttons off screen (the command panel replaces them); the same roster
	# point (once over the lab's [대기]) now lies over the 3D field, and a real click there must still
	# pass through the roster to what is under it: the lab's world click (an off-board cell is rejected).
	var point := Vector2(249, 273)
	h.expect(roster.roster_rect().has_point(point) and not lab.wait_button.get_global_rect().intersects(root.get_visible_rect()), "click point %s is on the roster; the lab's [대기] is off screen %s" % [point, lab.wait_button.get_global_rect()])
	var rejected_before: int = lab.rejected
	mouse(root, point, false, true)
	await process_frame
	var hovered: Control = root.gui_get_hovered_control() if root.has_method("gui_get_hovered_control") else null
	mouse(root, point, true)
	await process_frame
	mouse(root, point, false)
	await process_frame
	h.expect(hovered == null and lab.rejected == rejected_before + 1, "a real mouse click on the roster passes through to the lab's world click (hovered %s, lab rejections +%d)" % [hovered.name if hovered else "none", lab.rejected - rejected_before])
	h.press_wait() # the wait that starts the enemy slot (the lab's own button path)
	# Status rows and card status held during an enemy replay (the engine has finished its enemy turn first).
	var waited := 0
	while not (lab._enemy_presentation_busy() and b.current_phase != "enemy_turn") and waited < 2000:
		await process_frame
		waited += 1
	var target_id: String = lab.hud_active_unit_id()
	var target: BattleUnitState = b.active_unit_state
	var card_index := -1
	for i in range(units.size()):
		if card(i).visible and card_index < 0: card_index = i
	var old_rows: Array = panel_values(actor_hud.hud).rows
	var old_card := card_text(card_index, "StatusLabel")
	if target != null: target.apply_status_effect("burn", 2, 12)
	if units[card_index] != target: units[card_index].apply_status_effect("burn", 2, 12)
	h.expect(lab._enemy_presentation_busy() and target != null and status_rows(b, target) != old_rows and String(b.call("_get_formation_status_summary_text", units[card_index])) != old_card,
		"during the enemy replay the engine status changes (panel %s: %s -> %s; card %s: '%s' -> '%s')" % [target_id, old_rows, status_rows(b, target) if target else [], units[card_index].unit_id, old_card, b.call("_get_formation_status_summary_text", units[card_index])])
	var held := 0
	var early := false
	while lab._enemy_presentation_busy():
		await process_frame
		if lab._enemy_presentation_busy():
			held += 1
			if panel_values(actor_hud.hud).rows != old_rows or card_text(card_index, "StatusLabel") != old_card: early = true
	for i in range(3): await process_frame
	var settled_rows: Array = panel_values(actor_hud.hud).rows
	h.expect(not early and held > 0 and (b.active_unit_state == null or settled_rows == status_rows(b, b.active_unit_state)) and card_text(card_index, "StatusLabel") == String(b.call("_get_formation_status_summary_text", units[card_index])),
		"status rows and card status held for %d replay frames, then = engine (rows %s, card '%s')" % [held, settled_rows, card_text(card_index, "StatusLabel")])
	print("[ALLY_ACTOR] status hold: replay frames held=", held, " panel target=", target_id, " rows ", old_rows, " -> ", settled_rows, " card ", units[card_index].unit_id, " '", old_card, "' -> '", card_text(card_index, "StatusLabel"), "'")
	# Win practice with [자동]: every frame.
	h.shell.choose_button.pressed.emit()
	await process_frame
	h.expect(not roster.visible and not actor_hud.visible, "[시나리오 선택]: both hidden")
	await h.press_scenario(self, "win_practice")
	lab = h.lab
	b = lab.engine
	units = allies(b)
	for i in range(2): lab.speed_button.pressed.emit()
	lab._sync_views()
	seed(1)
	h.press_auto()
	var prev_troops := {}
	for u in units: prev_troops[u.unit_id] = troops_text(u)
	var prev_panel := expected_panel(b)
	var prev_gold := []
	var start_actor: String = lab.hud_ally_actor_id()
	prev_gold = [] if start_actor == "" or not lab.views[start_actor].visible else [start_actor]
	var frames := 0
	var bad := []
	var lagged := 0
	var status_frozen_changes := 0
	var status_settled_mismatch := 0
	var busy_status := {}
	var ready_bad := 0
	var ready_lag := 0
	var gold_bad := 0
	var prev_ready := {} # the engine's ready value the frame before
	var prev_status := {} # the engine's status text the frame before
	var status_lag := 0
	var status_examples := []
	var gold_lag := 0
	var gold_examples := []
	var reinforce_frames := 0
	var panel_diff := {"one_frame_lag":0, "status_held_replay":0, "rows_refreshed_to_engine_during_replay":0, "other":0}
	var panel_other := []
	var refresh_examples := []
	var held_rows := {} # unit_id -> the rows shown for it when the replay began (N5 is cached per unit)
	var twod_frame_diff := {}
	var actor_vs_selected := {"same":0, "not_ally_input_phase":0, "selected_not_synced_yet":0, "other":0}
	var enemy_turn := {"frames":0, "active_null":0, "active_ally":0, "active_enemy":0, "panel_name_same_as_2d":0}
	var vis_diff := {"other":0}
	for i in range(80000):
		await process_frame
		if not roster.visible:
			if h.shell.result_panel.visible: break
			continue
		frames += 1
		var busy: bool = lab._enemy_presentation_busy()
		var golden := []
		for k in range(units.size()):
			var u: BattleUnitState = units[k]
			if card(k).visible != lab.views[u.unit_id].visible: bad.append([frames, u.unit_id, "visible"])
			if card(k).visible != twod_card(b, k).visible:
				var avail: bool = b.call("_is_unit_state_available_for_battle_slot", u)
				var twod_visible: bool = twod_card(b, k).visible
				var reason := "dead" if not u.is_alive() else ("not_arrived" if not avail and twod_visible else ("held_until_arrival_replay" if avail and twod_visible and not lab._unit_shown(u.unit_id) else ("lab_view_not_synced_yet" if avail and twod_visible and not lab.views[u.unit_id].visible else "other")))
				vis_diff[reason] = vis_diff.get(reason, 0) + 1
			if not card(k).visible: continue
			if k >= 3: reinforce_frames += 1
			if card_text(k, "NameLabel") != u.display_name or card_text(k, "TroopTypeLabel") != TYPES.get(u.unit_type, "부대"): bad.append([frames, u.unit_id, "name/type"])
			var shown_troops := card_text(k, "HpLabel")
			if shown_troops != troops_text(u):
				if shown_troops == prev_troops[u.unit_id]: lagged += 1
				else: bad.append([frames, u.unit_id, "troops %s vs %s" % [shown_troops, troops_text(u)]])
			var st := card_text(k, "StatusLabel")
			if busy:
				if busy_status.has(u.unit_id) and busy_status[u.unit_id] != st: status_frozen_changes += 1
				busy_status[u.unit_id] = st
			else:
				busy_status.erase(u.unit_id)
				var want_st := String(b.call("_get_formation_status_summary_text", u))
				if st != want_st:
					if st == prev_status.get(u.unit_id, st): status_lag += 1
					else: status_settled_mismatch += 1
					if status_examples.size() < 6: status_examples.append([frames, u.unit_id, st, want_st, b.current_phase])
			var want_ready: bool = b.call("_can_use_unique_skill", u)
			var shown_ready: bool = card(k).get_node("UniqueSkillReadyIcon").visible
			if shown_ready != want_ready:
				if shown_ready == prev_ready.get(u.unit_id, want_ready): ready_lag += 1
				else: ready_bad += 1
			if card(k).has_theme_stylebox_override(&"panel"): golden.append(u.unit_id)
		var actor: String = lab.hud_ally_actor_id()
		var want_gold := [] if actor == "" or not lab.views[actor].visible else [actor]
		if golden != want_gold:
			if golden == prev_gold: gold_lag += 1
			else: gold_bad += 1
			if gold_examples.size() < 6: gold_examples.append([frames, b.current_phase, golden, want_gold, prev_gold, lab.selected])
		prev_gold = want_gold
		if actor == lab.selected: actor_vs_selected.same += 1
		elif actor == "": actor_vs_selected.not_ally_input_phase += 1
		elif lab.selected != actor: actor_vs_selected.selected_not_synced_yet += 1
		else: actor_vs_selected.other += 1
		# The current-actor panel against the engine (now, or the frame before; rows held during a replay).
		var shown_panel: Dictionary = panel_values(actor_hud.hud)
		var want_panel := expected_panel(b)
		var active_id: String = lab.hud_active_unit_id()
		if not busy: held_rows.clear()
		elif active_id != "" and not held_rows.has(active_id): held_rows[active_id] = shown_panel.rows
		for key in diff_keys(shown_panel, want_panel):
			if busy and (key == "rows" or key == "legend") and shown_panel.rows == held_rows.get(active_id): panel_diff.status_held_replay += 1
			elif shown_panel[key] == prev_panel[key]: panel_diff.one_frame_lag += 1
			else:
				panel_diff.other += 1
				if panel_other.size() < 5: panel_other.append([frames, key, shown_panel[key], want_panel[key]])
		if busy and held_rows.has(active_id) and shown_panel.rows != held_rows[active_id]:
			# The lab re-reads N5 only when it sees no pending replay at the HUD refresh; a change is
			# allowed only to the engine's current rows (a fresh read), never to anything else.
			if shown_panel.rows == want_panel.rows:
				panel_diff.rows_refreshed_to_engine_during_replay += 1
				if refresh_examples.size() < 5: refresh_examples.append([frames, active_id, held_rows[active_id], shown_panel.rows])
				held_rows[active_id] = shown_panel.rows
			else:
				panel_diff.other += 1
				if panel_other.size() < 5: panel_other.append([frames, "rows changed during replay", active_id, held_rows[active_id], shown_panel.rows])
		var twod_panel_values: Dictionary = panel_values(twod_panel(b))
		for key in diff_keys(shown_panel, twod_panel_values):
			var reason := "%s:%s" % [key, twod_reason(b, key)]
			twod_frame_diff[reason] = twod_frame_diff.get(reason, 0) + 1
		if b.current_phase == "enemy_turn":
			enemy_turn.frames += 1
			var active: BattleUnitState = b.active_unit_state
			if active == null: enemy_turn.active_null += 1
			elif active.side == "ally": enemy_turn.active_ally += 1
			else: enemy_turn.active_enemy += 1
			if shown_panel.name == twod_panel_values.name: enemy_turn.panel_name_same_as_2d += 1
		prev_panel = want_panel
		for u in units:
			prev_troops[u.unit_id] = troops_text(u)
			prev_ready[u.unit_id] = bool(b.call("_can_use_unique_skill", u))
			prev_status[u.unit_id] = String(b.call("_get_formation_status_summary_text", u))
		if h.shell.result_panel.visible: break
	h.expect(h.shell.result_panel.visible and b.call("_get_battle_result_state") == "victory", "win practice ends in victory")
	h.expect(bad.is_empty(), "every frame: shown ally cards follow the lab views, name/type = engine, troops = engine now or one frame before (wrong %s)" % str(bad.slice(0, 5)))
	h.expect(status_frozen_changes == 0 and status_settled_mismatch == 0, "card status: unchanged while an enemy replay is pending (%d changes), = engine now or one frame before otherwise (%d wrong, %d one-frame lag) %s" % [status_frozen_changes, status_settled_mismatch, status_lag, status_examples])
	h.expect(ready_bad == 0, "ready icon = _can_use_unique_skill now or one frame before (%d wrong, %d one-frame lag)" % [ready_bad, ready_lag])
	h.expect(gold_bad == 0, "gold frame on exactly the 2D actor rule card, now or one frame before (%d wrong, %d one-frame lag) %s" % [gold_bad, gold_lag, gold_examples])
	h.expect(panel_diff.other == 0, "every frame: the panel = engine/registry now or one frame before, status rows held during a replay %s %s" % [panel_diff, panel_other])
	h.expect(vis_diff.other == 0, "card shown state vs the engine's own 2D card: only known reasons %s" % vis_diff)
	h.expect(not roster.visible and not actor_hud.visible, "after the result: ally roster and panel hidden with the HUD (like 2D)")
	print("[ALLY_ACTOR] auto frames=", frames, " troops one-frame lag=", lagged, " ready one-frame lag=", ready_lag, " ally reinforcement card-frames=", reinforce_frames, " card shown != 2D card=", vis_diff)
	print("[ALLY_ACTOR] panel vs engine (key-frames)=", panel_diff, " panel vs the engine's 2D panel (key:reason -> frames)=", twod_frame_diff)
	print("[ALLY_ACTOR] rows refreshed during a replay (frame, unit, held, shown)=", refresh_examples, " gold one-frame lag=", gold_lag, " examples=", gold_examples, " status one-frame lag=", status_lag)
	print("[ALLY_ACTOR] 2D actor rule vs lab.selected (frames)=", actor_vs_selected, " enemy turn=", enemy_turn)
	await h.close_shell(self)
	print("[ALLY_ACTOR] checks=", h.checks, " failures=", h.failures)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	roster = null
	actor_hud = null
	await process_frame
	quit(code)
