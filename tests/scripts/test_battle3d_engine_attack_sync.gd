extends SceneTree
var h
func _initialize() -> void:
	run.call_deferred()
func run() -> void:
	h=load("res://tests/scripts/support/battle3d_engine_attack_harness.gd").new()
	await h.open_lab(self)
	h.sync_check("standard deployment")
	var hidden := 0
	for unit in h.lab.engine.all_battle_unit_states:
		if not h.lab.views[unit.unit_id].visible: hidden+=1
	h.expect(hidden==4,"four standard reinforcements initially hidden")
	await h.close_lab(self)
	# Each layout is prepared before observation. Runtime receives only UI commands.
	for label in ["wait","deployed_fixture","small_formation","enemy_kills_ally"]:
		await h.open_lab(self)
		await h.setup_case(self,"A1")
		var lab=h.lab
		var battle=lab.engine
		var actor=battle.all_battle_unit_states[0]
		var target=battle.all_battle_unit_states[5]
		if label=="wait": target.apply_status_effect("confusion",2)
		if label=="deployed_fixture": battle._set_unit_deployed(battle.all_battle_unit_states[3],true)
		if label=="small_formation": target.current_troops=100
		if label=="enemy_kills_ally":
			actor.current_hp=1
			actor.current_troops=1
		lab._sync_views()
		h.sync_check(label+" initial")
		if label=="deployed_fixture": h.expect(lab.views[battle.all_battle_unit_states[3].unit_id].visible,"deployed reinforcement follows engine flag")
		if label=="small_formation": h.expect(lab.visual_soldier_count(lab.display_values[target.unit_id])==2,"troops and model count are separate")
		if label in ["wait","enemy_kills_ally"]:
			h.click(actor.grid_cell)
			h.press_attack()
			h.click(target.grid_cell)
			await h.wait_for(self,"ally_turn")
			h.sync_check(label+" result")
			h.expect(lab.enemy_summaries.size()==1,label+" enemy summary exists even if no enemy frame observed")
			if label=="wait": h.expect(lab.enemy_summaries[0].text.contains("변화 없음"),"no-action summary")
			if label=="enemy_kills_ally":
				h.expect(not lab.views[actor.unit_id].visible,"enemy-killed ally hidden")
				h.expect(lab.combat_lines.has("격파 · "+actor.unit_id),"shared death event displayed for ally")
		await h.close_lab(self)
		if not h.failures.is_empty(): break
	await h.open_lab(self)
	h.expect(h.lab.action_cursor==0 and h.lab.damage_presentations.is_empty() and not h.lab.awaiting_enemy_result,"restart has no action residue")
	h.expect(h.lab.event_cursor==0 and h.lab.playback.is_empty(),"restart has no movement residue")
	await h.close_lab(self)
	print("M2_SYNC checks=",h.checks," failures=",h.failures)
	quit(0 if h.failures.is_empty() else 1)
