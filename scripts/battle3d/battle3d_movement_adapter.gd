extends RefCounted
const Units=preload("res://scripts/battle3d/battle3d_unit_adapter.gd")
const Service=preload("res://scripts/battle/services/battle_movement_query_service.gd")
var service=Service.new()
var grid: BattleGridController
var alive_units: Array[BattleUnitState] = []

func find_unit(id: String) -> BattleUnitState:
	for unit in alive_units:
		if unit.unit_id==id: return unit
	return null

func query(id: String,target: Vector2i,allow_breakthrough := false) -> Dictionary:
	var mover := find_unit(id)
	if mover==null or grid==null: return {}
	var view := Units.to_view(mover)
	var budget: int=service.get_effective_move_range(mover)
	var reachable: Dictionary=service.get_reachable_paths(view.grid_cell,mover,budget,grid,alive_units,allow_breakthrough)
	var path: Array[Vector2i]=service.find_move_path(view.grid_cell,target,mover,budget,grid,alive_units,allow_breakthrough)
	var destination: bool=service.is_valid_destination_for_unit(target,mover,grid,alive_units,allow_breakthrough)
	return {"unit":view,"budget":budget,"reachable":reachable,"path":path,"destination_valid":destination,"can_preview":destination and reachable.has(target) and not path.is_empty()}
