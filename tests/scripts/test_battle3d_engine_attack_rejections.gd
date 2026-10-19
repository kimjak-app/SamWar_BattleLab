extends SceneTree
var h
func _initialize() -> void:
	run.call_deferred()
func stable() -> Dictionary:
	return {"state":h.snapshot(h.lab.engine,"probe"),"events":h.lab.engine.battle_action_event_log.export(),"moves":h.lab.engine.ally_move_event_log.export()}
func run() -> void:
	h=load("res://tests/scripts/support/battle3d_engine_attack_harness.gd").new()
	for label in ["ally","range","moved_gunner","acted","enemy_lock","animation_lock","dead","empty","cancel","isolation"]:
		await h.open_lab(self)
		var scenario: String={"range":"A7_range","moved_gunner":"A5","acted":"A7_acted","cancel":"A11"}.get(label,"A1")
		await h.setup_case(self,scenario)
		var lab=h.lab
		var battle=lab.engine
		var actor=battle.all_battle_unit_states[0]
		var target=battle.all_battle_unit_states[5]
		if label=="ally":
			battle.all_battle_unit_states[1].set_grid_cell(Vector2i(3,5))
			battle._sync_resumed_unit_markers_to_grid(battle.all_battle_unit_states[1])
		if label=="dead":
			target.current_hp=0
			target.current_troops=0
		if label=="enemy_lock": battle.current_phase="enemy_turn"
		if label=="animation_lock": battle.is_demo_animating=true
		lab._sync_views()
		var before=stable()
		var rejects: int=lab.rejected
		if label in ["moved_gunner","acted","enemy_lock","animation_lock"]:
			for i in range(3): h.press_attack()
			if label in ["enemy_lock","animation_lock"]:
				h.click(target.grid_cell)
				h.click(actor.grid_cell)
				h.click(actor.grid_cell,MOUSE_BUTTON_RIGHT)
				h.expect(battle.attack_calls==0,label+" no engine command during locked phase")
				h.expect(lab.status.text.contains("적 턴" if label=="enemy_lock" else "연출 중"),label+" explicit lock reason")
		else:
			h.press_attack()
			h.range_check(label)
			before=stable()
			if label=="ally":
				h.expect(battle.is_unit_in_attack_range(actor,battle.all_battle_unit_states[1]),"ally protection tested inside range")
				h.click(Vector2i(3,5))
			elif label in ["range","dead"]: h.click(target.grid_cell)
			elif label=="empty": h.click(Vector2i(2,4))
			elif label=="cancel": h.click(target.grid_cell,MOUSE_BUTTON_RIGHT)
			elif label=="isolation":
				lab.set_process_unhandled_input(false)
				for button in [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_RIGHT]:
					var event:=InputEventMouseButton.new()
					event.button_index=button
					event.pressed=true
					event.position=lab.camera.unproject_position(lab.board.world(target.grid_cell))
					root.push_input(event)
				lab.set_process_unhandled_input(true)
		var after=stable()
		if label=="cancel":
			h.check_point("A11","cancelled")
			h.expect(h.fingerprint.diff(before.state.units,after.state.units).is_empty(),"cancel consumes no unit state")
			h.expect(battle.current_phase=="ally_turn" and lab.attack_cells.is_empty(),"cancel phase and overlays")
		else:
			h.expect(h.fingerprint.diff(before,after).is_empty(),label+" all 40 fields/controller/events unchanged")
			if label!="isolation": h.expect(lab.rejected>rejects and lab.status.text.begins_with("거절"),label+" visible rejection")
			if label in ["ally","range","dead","empty","isolation"]: h.expect(battle.current_phase=="attack_select",label+" selection preserved")
		h.expect(battle.target_calls==0,label+" target function never called")
		h.expect(lab.damage_presentations.is_empty(),label+" no damage presentation")
		h.expect(battle.battle_action_event_log.export().is_empty(),label+" no action event")
		h.expect(root.get_camera_3d()==lab.camera,label+" camera isolated")
		print("[M2_REJECTION_CASE] ",label," failures=",h.failures.size())
		await h.close_lab(self)
		if not h.failures.is_empty(): break
	print("M2_REJECTIONS checks=",h.checks," failures=",h.failures)
	quit(0 if h.failures.is_empty() else 1)
