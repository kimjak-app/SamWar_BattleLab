## EASTWAR WorldMap3D v3 — ribbon meshes draped on the terrain (roads, rivers).
## Replaces v2's 2K road distance texture (stair-stepping when zoomed). Geometry stores the centre line;
## the ribbon shader widens it in the vertex stage (world width, but never thinner than N screen pixels),
## so lines stay crisp at every zoom. Heights use the exact terrain-mesh surface (WorldMapGeo.mesh_height_at).
class_name WorldMapRibbons
extends RefCounted

## polylines: Array of PackedVector2Array (map km). widths: Array of float (0..1, per polyline) or
## Array of PackedFloat32Array (per point). step_km: resample spacing.
static func build(geo: WorldMapGeo, polylines: Array, widths: Array, step_km: float, lift_km := 0.0) -> ArrayMesh:
	var verts := PackedVector3Array()
	var norms := PackedVector3Array()
	var uvs := PackedVector2Array()
	var cols := PackedColorArray()
	var idx := PackedInt32Array()
	for pi in polylines.size():
		var src: PackedVector2Array = polylines[pi]
		if src.size() < 2:
			continue
		var wsrc = widths[pi] if pi < widths.size() else 1.0
		# resample at ~step_km
		var pts := PackedVector2Array()
		var ws := PackedFloat32Array()
		var along := PackedFloat32Array()
		var acc := 0.0
		for k in src.size() - 1:
			var a := src[k]
			var b := src[k + 1]
			var l := a.distance_to(b)
			var n := maxi(1, int(ceil(l / step_km)))
			var wa := _w(wsrc, k)
			var wb := _w(wsrc, k + 1)
			for s in n:
				var t := float(s) / n
				pts.append(a.lerp(b, t))
				ws.append(lerpf(wa, wb, t))
				along.append(acc + l * t)
			acc += l
		pts.append(src[src.size() - 1])
		ws.append(_w(wsrc, src.size() - 1))
		along.append(acc)
		var base := verts.size()
		var m := pts.size()
		for k in m:
			var p := pts[k]
			var t: Vector2
			if k == 0:
				t = pts[1] - pts[0]
			elif k == m - 1:
				t = pts[k] - pts[k - 1]
			else:
				t = pts[k + 1] - pts[k - 1]
			t = t.normalized()
			var side := Vector3(-t.y, 0.0, t.x)
			var y := geo.mesh_height_at(p) + lift_km
			# taper the two ends
			var taper := clampf(minf(along[k], acc - along[k]) / 1.5, 0.15, 1.0)
			for sgn in [-1.0, 1.0]:
				verts.append(Vector3(p.x, y, p.y))
				norms.append(side)
				uvs.append(Vector2(sgn, along[k]))
				cols.append(Color(ws[k] * taper, taper, 0.0, 1.0))
			if k > 0:
				var v := base + k * 2
				idx.append_array([v - 2, v - 1, v, v - 1, v + 1, v])
	var mesh := ArrayMesh.new()
	if verts.is_empty():
		return mesh
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_NORMAL] = norms
	arr[Mesh.ARRAY_TEX_UV] = uvs
	arr[Mesh.ARRAY_COLOR] = cols
	arr[Mesh.ARRAY_INDEX] = idx
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	# ribbons are widened in the vertex shader -> enlarge culling box
	mesh.custom_aabb = mesh.get_aabb().grow(5.0)
	return mesh

static func _w(w, k: int) -> float:
	if w is PackedFloat32Array or w is Array:
		return float(w[clampi(k, 0, w.size() - 1)])
	return float(w)
