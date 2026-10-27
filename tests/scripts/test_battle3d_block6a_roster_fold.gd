extends SceneTree
# HUD block 6a test 3: the roster side banners fold the rosters as the 2D does, on the scenario shell at 1920 x 1080.
# Expected values come from the 2D battle the lab runs (its own nodes and its roster presentation controller,
# ProductionRosterCollapseExperiment: _collapsed_banner_position / _collapsed_portrait_position, PORTRAIT_SIZE,
# TRANSITION_DURATION), not from the 3D code:
#   - before: each banner on the 2D banner's rect, with the 2D banner's texture; the roster at its rect;
#   - a real click on each banner, then the 2D transition time: the roster (and so every card) hidden, the banner at the
#     2D folded place, one portrait per shown card at the 2D place and size, the card count unchanged, the actor's frame
#     on the ally column; roster_rect() = the portrait column (frames) and the folded banner;
#   - folded: the mouse over the banner hovers the banner (the edge scroll is off there), over the old roster area it
#     hovers nothing; the shell's HUD list and the command panel's take the folded rect, and with the selected ally
#     pushed into the old roster area the panel is clear of the folded rect and the marker;
#   - folded, an ally loses 10 troops and an enemy retreats: the enemy portrait takes the 2D retreat tint at once;
#     clicked open again: the card shows the new troops, the retreated card is dimmed with "퇴각";
#   - opened: the roster rect, banner rect and card count as before, the portraits hidden.
const CameraCenter = preload("res://scripts/battle3d/battle3d_camera_center.gd")
var h

func _initialize() -> void:
	run.call_deferred()

func click_at(at: Vector2) -> void:
	for pressed in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT
		e.pressed = pressed
		e.position = at
		e.global_position = at
		root.push_input(e)
		for i in range(2): await process_frame

func hover(at: Vector2) -> Control:
	var e := InputEventMouseMotion.new()
	e.position = at
	e.global_position = at
	root.push_input(e)
	for i in range(3): await process_frame
	return root.gui_get_hovered_control()

func same(a: Rect2, c: Rect2) -> bool:
	# Equal within 0.01 px (a tween ends on float steps).
	return a.position.distance_to(c.position) < 0.01 and a.size.distance_to(c.size) < 0.01

func shown(roster) -> Array:
	return range(roster.SLOT_NAMES.size()).filter(func(i): return roster.slot(i).visible)

func run() -> void:
	h = load("res://tests/scripts/support/battle3d_scenario_harness.gd").new()
	await h.open_shell(self)
	root.size = Vector2i(1920, 1080)
	await h.press_scenario(self, "default")
	var lab = h.lab
	var b: Node = lab.engine
	for i in range(120): await process_frame
	lab.edge_scroll_enabled = false
	var shell = h.shell
	var twod = b.get_node("ProductionRosterCollapseExperiment")
	var root_at: Vector2 = (b.get_node("BattleUI/ProductionHudRoot") as Control).global_position
	var wait_sec: float = twod.TRANSITION_DURATION + 0.15
	var portrait_size: Vector2 = twod.PORTRAIT_SIZE
	var sides := {"Ally":shell.ally_roster, "Enemy":shell.enemy_roster}
	var before := {}
	for side in sides:
		var roster = sides[side]
		var twod_banner: TextureRect = b.get_node("BattleUI/ProductionHudRoot/%sRosterSideBanner" % side)
		before[side] = {"roster":roster.roster_rect(), "banner":roster.fold.banner_rect(), "cards":shown(roster)}
		h.expect(roster.fold.banner_rect() == twod_banner.get_global_rect() and roster.fold.banner.texture.resource_path == twod_banner.texture.resource_path,
			"%s banner on the 2D banner %s with its texture (%s vs %s)" % [side, twod_banner.get_global_rect(), roster.fold.banner_rect(), roster.fold.banner.texture.resource_path])
		await click_at(roster.fold.banner_rect().get_center())
	await create_timer(wait_sec).timeout
	for i in range(3): await process_frame
	for side in sides:
		var roster = sides[side]
		var origin: Vector2 = roster.get_node("ProductionHudRoot").global_position
		var want_banner := Rect2(origin + twod._collapsed_banner_position(side), roster.fold.banner.size)
		var cards: Array = before[side].cards
		var wrong := []
		var column := Rect2()
		for i in range(roster.SLOT_NAMES.size()):
			var portrait: TextureRect = roster.fold.items[i].portrait
			var want := Rect2(origin + twod._collapsed_portrait_position(side, i), portrait_size)
			var frame := Rect2(want.position - Vector2(2, 2), want.size + Vector2(4, 4))
			column = frame if i == 0 else column.merge(frame)
			if portrait.is_visible_in_tree() != cards.has(i) or (cards.has(i) and not same(portrait.get_global_rect(), want)): wrong.append([i, portrait.is_visible_in_tree(), portrait.get_global_rect(), want])
		h.expect(not roster.get_node("ProductionHudRoot/%sRosterHud" % side).is_visible_in_tree() and shown(roster) == cards and wrong.is_empty() and same(roster.fold.banner_rect(), want_banner),
			"%s folded: roster hidden, %d cards kept, portraits at the 2D places, banner at %s (got %s; wrong %s)" % [side, cards.size(), want_banner, roster.fold.banner_rect(), str(wrong)])
		h.expect(same(roster.roster_rect(), column.merge(want_banner)), "%s folded rect = portrait column + banner %s (got %s)" % [side, column.merge(want_banner), roster.roster_rect()])
	var actor_index: int = lab.hud_ally_unit_ids().find(lab.hud_ally_actor_id())
	h.expect(actor_index >= 0 and shell.ally_roster.fold.items[actor_index].border.is_visible_in_tree(), "ally column: the actor's frame shown (slot %d)" % actor_index)
	# Gates on the folded rects.
	var ally_fold: Rect2 = shell.ally_roster.roster_rect()
	var over_banner := await hover(shell.ally_roster.fold.banner_rect().get_center())
	var over_old := await hover(Vector2(200, 450))
	h.expect(over_banner == shell.ally_roster.fold.banner and over_old == null, "folded: the banner takes the mouse (%s), the old roster area does not (%s)" % [over_banner, over_old])
	h.expect(shell.hud_rects().has(ally_fold) and shell.hud_rects().has(shell.enemy_roster.roster_rect()), "the shell's HUD list holds the folded rects")
	var id: String = lab.hud_ally_actor_id()
	if is_instance_valid(shell.camera_tween): shell.camera_tween.kill()
	lab.zoom = 30.0
	for i in range(2): await process_frame
	var board_size := Vector2(lab.board.PLAY_SIZE.x * lab.board.CELL, lab.board.PLAY_SIZE.y * lab.board.CELL)
	lab.focus = CameraCenter.focus_for(lab.camera, lab.focus, lab.views[id].position, Vector2(200, 480), board_size)
	for i in range(6): await process_frame
	var panel = shell.command_panel
	var marker: Array = lab.unit_markers.rects_of(id)
	h.expect(panel.panel.visible and panel.hud_rects.has(ally_fold) and not panel.panel_rect().intersects(ally_fold) and not panel.covers(panel.panel_rect(), marker),
		"folded: %s pushed into the old roster area, the panel %s clear of the folded rect %s and the marker" % [id, panel.panel_rect(), ally_fold])
	# Values change while folded.
	var ally_ids: Array = lab.hud_ally_unit_ids()
	var hurt := ""
	for u in b.all_battle_unit_states:
		if u.side == "ally" and u.unit_id != id and lab.views[u.unit_id].visible and hurt.is_empty():
			hurt = u.unit_id
			u.current_troops -= 10
	var gone := ""
	for u in b.all_battle_unit_states:
		if u.side == "enemy" and lab.views[u.unit_id].visible and gone.is_empty():
			gone = u.unit_id
			u.current_troops = 0
	lab._sync_views()
	for i in range(3): await process_frame
	var gone_index: int = lab.hud_enemy_unit_ids().find(gone)
	h.expect(shell.enemy_roster.fold.items[gone_index].portrait.modulate == Color(0.62, 0.62, 0.62, 0.72) and shell.enemy_roster.fold.items[gone_index].portrait.is_visible_in_tree(),
		"folded: %s retreats, its portrait takes the 2D tint %s" % [gone, shell.enemy_roster.fold.items[gone_index].portrait.modulate])
	for side in sides: await click_at(sides[side].fold.banner_rect().get_center())
	await create_timer(wait_sec).timeout
	for i in range(3): await process_frame
	var hurt_card: Control = shell.ally_roster.slot(ally_ids.find(hurt))
	var hurt_value: Dictionary = lab.display_values[hurt]
	var gone_card: Control = shell.enemy_roster.slot(gone_index)
	h.expect((hurt_card.get_node("HpLabel") as Label).text == "병력 %d / %d" % [hurt_value.current_troops, hurt_value.max_troops] and gone_card.is_visible_in_tree() and gone_card.modulate.a < 1.0
		and shell.enemy_roster.retreat_label(gone_index).is_visible_in_tree(), "opened: %s shows %s, %s dimmed with \"퇴각\"" % [hurt, (hurt_card.get_node("HpLabel") as Label).text, gone])
	for side in sides:
		var roster = sides[side]
		h.expect(same(roster.roster_rect(), before[side].roster) and same(roster.fold.banner_rect(), before[side].banner) and shown(roster) == before[side].cards
			and not roster.fold.overlay.visible and roster.get_node("ProductionHudRoot/%sRosterHud" % side).is_visible_in_tree(),
			"%s opened again: roster %s, banner %s, cards %s as before" % [side, roster.roster_rect(), roster.fold.banner_rect(), str(shown(roster))])
	lab.edge_scroll_enabled = true
	await h.close_shell(self)
	print("[BLOCK6A_FOLD] checks=", h.checks, " failures=", h.failures, " folded ally ", ally_fold, " 2D root ", root_at)
	var code := 0 if h.failures.is_empty() else 1
	h = null
	await process_frame
	quit(code)
