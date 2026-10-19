extends BattleGridController
const Heightfield=preload("res://scripts/battle3d/lab_heightfield.gd")
var heightfield=Heightfield.new()
var world_3d: World3D

func _init() -> void:
	grid_width=heightfield.SIZE.x
	grid_height=heightfield.SIZE.y

func grid_to_world_3d(cell: Vector2i) -> Vector3:
	return heightfield.world(cell)

func world_to_grid_from_ray(origin: Vector3,direction: Vector3) -> Vector2i:
	if world_3d==null or direction.length_squared()<.000001: return Vector2i(-1,-1)
	# Mask 1 contains only the actual terrain + ford, never units or trees.
	var query := PhysicsRayQueryParameters3D.create(origin,origin+direction.normalized()*1000,1)
	var hit := world_3d.direct_space_state.intersect_ray(query)
	if hit.is_empty(): return _heightfield_fallback(origin,direction.normalized())
	var cell: Vector2i=heightfield.cell_at(hit.position)
	return cell if is_in_bounds(cell) else Vector2i(-1,-1)

func _heightfield_fallback(origin: Vector3,direction: Vector3) -> Vector2i:
	# Jolt may miss a ray exactly on a GLB triangle vertex. Intersect the same
	# piecewise-linear heightfield on the SAME ray, never a flat plane or jittered ray.
	var previous_t := 0.0
	var previous_above := false
	for sample in range(20001):
		var t := sample*.05
		var p := origin+direction*t
		var cell: Vector2i=heightfield.cell_at(p)
		if not is_in_bounds(cell):
			previous_above=false
			continue
		var above: bool=p.y>heightfield.height(p.x,p.z)
		if not above and previous_above:
			var lo := previous_t
			var hi := t
			for iteration in range(24):
				var mid := (lo+hi)*.5
				var point := origin+direction*mid
				if point.y>heightfield.height(point.x,point.z): lo=mid
				else: hi=mid
			return heightfield.cell_at(origin+direction*((lo+hi)*.5))
		previous_above=above
		previous_t=t
	return Vector2i(-1,-1)

static func attach_surface_collisions(node: Node) -> void:
	if node is MeshInstance3D and node.name in ["Terrain","Ford"]:
		node.create_trimesh_collision()
	for child in node.get_children(): attach_surface_collisions(child)
