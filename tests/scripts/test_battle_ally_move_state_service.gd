extends SceneTree
const Service = preload("res://scripts/battle/services/battle_ally_move_state_service.gd")
const Log = preload("res://scripts/battle/services/battle_event_log_service.gd")
var checks := 0
var failures := 0
func expect(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: ",label)
func _initialize() -> void:
	var service := Service.new()
	var unit := BattleUnitState.create({"unit_id":"move_test","grid_cell":Vector2i(2,2),"facing":"left"})
	unit.last_action = {"sentinel":73}
	var snapshot := service.capture_snapshot(unit,false)
	expect(snapshot == {"unit_id":"move_test","grid_cell":[2,2],"facing":"left","has_moved":false,"ally_has_moved":false},"snapshot exact logical fields")
	var vertical := service.apply_step_facing(unit,Vector2i(2,2),Vector2i(2,3))
	expect(not vertical.applied and unit.facing=="left" and vertical.events.is_empty(),"vertical retains facing")
	var horizontal := service.apply_step_facing(unit,Vector2i(2,3),Vector2i(3,3))
	expect(horizontal.changed and unit.facing=="right","horizontal changes facing")
	var repeated := service.apply_step_facing(unit,Vector2i(3,3),Vector2i(4,3))
	expect(repeated.applied and not repeated.changed and repeated.events.is_empty(),"same facing still applies visuals without duplicate event")
	var path := [Vector2i(2,2),Vector2i(2,3),Vector2i(3,3),Vector2i(4,3),Vector2i(4,2)]
	service.apply_destination(unit,Vector2i(4,2))
	expect(unit.grid_cell==Vector2i(4,2) and not unit.has_moved and unit.last_action=={"sentinel":73},"destination writes only cell")
	var result := service.commit_move_metadata(unit,Vector2i(2,2),Vector2i(4,2),2,path,"left")
	expect(unit.has_moved and not unit.has_acted,"move does not act")
	expect(unit.last_action=={"type":"move","origin_cell":[2,2],"destination_cell":[4,2],"moved_distance":2},"grid distance not path length")
	var log_service := Log.new()
	for event in horizontal.events + result.events:
		expect(not log_service.emit(event.kind,event.fields).is_empty(),"schema accepted "+event.kind)
	path[0] = Vector2i(9,9)
	expect(result.events[0].fields.path[0]==[2,2],"path copied")
	result.events[0].fields.last_action_after.origin_cell[0] = 99
	expect(unit.last_action.origin_cell==[2,2],"event detached from state")
	var action := unit.last_action.duplicate(true)
	var reverted := service.rollback(unit,snapshot)
	expect(unit.grid_cell==Vector2i(2,2) and unit.facing=="left" and not unit.has_moved,"rollback cell facing moved")
	expect(unit.last_action==action and not unit.has_acted,"rollback deliberately does not restore last_action or act")
	expect(snapshot.grid_cell==[2,2],"snapshot detached")
	var confirmation := service.confirm_facing(unit,"down")
	expect(unit.facing=="down" and not unit.has_acted,"confirm facing without action consumption")
	for event in reverted.events + confirmation.events:
		expect(not log_service.emit(event.kind,event.fields).is_empty(),"schema accepted "+event.kind)
	service.confirm_facing(unit,"invalid")
	expect(unit.facing=="right","existing normalization fallback")
	var before_cell := unit.grid_cell
	service.commit_move_metadata(unit,Vector2i(2,2),Vector2i(8,8),12,[],"right")
	expect(unit.grid_cell==before_cell,"metadata never rewrites cell; legacy empty path allowed")
	expect(service.capture_snapshot(null,false).is_empty(),"null snapshot")
	service.apply_destination(null,Vector2i.ZERO)
	expect(not service.apply_step_facing(null,Vector2i.ZERO,Vector2i.RIGHT).applied,"null step")
	expect(service.commit_move_metadata(null,Vector2i.ZERO,Vector2i.RIGHT,1,[],"left").events.is_empty(),"null commit")
	expect(service.confirm_facing(null,"left").events.is_empty(),"null confirm")
	expect(service.rollback(null,snapshot).events.is_empty(),"null rollback")
	print("[BATTLE_ALLY_MOVE_STATE] %s: %d checks, %d failures" % ["PASS" if failures==0 else "FAIL",checks,failures])
	quit(0 if failures==0 else 1)
