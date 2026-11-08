## EASTWAR WorldMap3D v3 (EA v2: + chunked/LOD terrain) — map geometry from the config: map-km <-> uv, terrain height (bilinear and
## mesh-exact), terrain mesh. v3: NO lat/lon at runtime (that conversion only exists in the bake tools).
class_name WorldMapGeo
extends RefCounted

var cfg: WorldMapConfig
var grid: PackedFloat32Array
var gw: int
var gh: int
var width_km: float
var height_km: float
var height_scale: float

func load_data(config: WorldMapConfig) -> bool:
	cfg = config
	gw = cfg.grid_size.x
	gh = cfg.grid_size.y
	width_km = cfg.size_km.x
	height_km = cfg.size_km.y
	height_scale = cfg.height_scale
	var bytes := FileAccess.get_file_as_bytes(cfg.height_grid_path)
	grid = bytes.to_float32_array()
	if grid.size() != gw * gh:
		push_error("WorldMapGeo: grid size mismatch %d vs %d (%s)" % [grid.size(), gw * gh, cfg.height_grid_path])
		return false
	return true

func xz_to_uv(xz: Vector2) -> Vector2:
	return Vector2(xz.x / width_km + 0.5, xz.y / height_km + 0.5)

func uv_to_xz(uv: Vector2) -> Vector2:
	return Vector2((uv.x - 0.5) * width_km, (uv.y - 0.5) * height_km)

func grid_height_m(i: int, j: int) -> float:
	i = clampi(i, 0, gw - 1)
	j = clampi(j, 0, gh - 1)
	var h := grid[j * gw + i]
	return -8.0 if h < -9000.0 else h

## Ground height for gameplay/camera (bilinear, sea clamped to 0).
func height_at(xz: Vector2) -> float:
	var uv := xz_to_uv(xz)
	var fx := clampf(uv.x, 0.0, 1.0) * (gw - 1)
	var fz := clampf(uv.y, 0.0, 1.0) * (gh - 1)
	var i := int(floor(fx))
	var j := int(floor(fz))
	var tx := fx - i
	var tz := fz - j
	var h := lerpf(lerpf(grid_height_m(i, j), grid_height_m(i + 1, j), tx),
			lerpf(grid_height_m(i, j + 1), grid_height_m(i + 1, j + 1), tx), tz)
	return maxf(h, 0.0) * height_scale / 1000.0

## Exactly the rendered mesh surface (same triangle split as build_terrain_mesh) — used to drape ribbons.
func mesh_height_at(xz: Vector2) -> float:
	var uv := xz_to_uv(xz)
	var fx := clampf(uv.x, 0.0, 1.0) * (gw - 1)
	var fz := clampf(uv.y, 0.0, 1.0) * (gh - 1)
	var i := mini(int(floor(fx)), gw - 2)
	var j := mini(int(floor(fz)), gh - 2)
	var tx := fx - i
	var tz := fz - j
	var ha := grid_height_m(i, j)
	var hb := grid_height_m(i + 1, j)
	var hc := grid_height_m(i, j + 1)
	var hd := grid_height_m(i + 1, j + 1)
	var h: float
	if tx + tz <= 1.0:      # triangle a,b,c
		h = ha + (hb - ha) * tx + (hc - ha) * tz
	else:                   # triangle b,d,c
		h = hd + (hc - hd) * (1.0 - tx) + (hb - hd) * (1.0 - tz)
	return h * height_scale / 1000.0

func grid_to_xz(i: int, j: int) -> Vector2:
	return Vector2(-0.5 * width_km + float(i) / (gw - 1) * width_km, -0.5 * height_km + float(j) / (gh - 1) * height_km)

func xz_to_grid(xz: Vector2) -> Vector2i:
	var uv := xz_to_uv(xz)
	return Vector2i(clampi(roundi(uv.x * (gw - 1)), 0, gw - 1), clampi(roundi(uv.y * (gh - 1)), 0, gh - 1))

func is_inside(xz: Vector2) -> bool:
	return absf(xz.x) <= width_km * 0.5 and absf(xz.y) <= height_km * 0.5

## Terrain ArrayMesh (far-sea cells dropped; the open-sea plane covers them).
func build_terrain_mesh() -> ArrayMesh:
	var n := gw * gh
	var verts := PackedVector3Array()
	var norms := PackedVector3Array()
	var uvs := PackedVector2Array()
	verts.resize(n)
	norms.resize(n)
	uvs.resize(n)
	var k := height_scale / 1000.0
	var dx := width_km / (gw - 1)
	var dz := height_km / (gh - 1)
	for j in gh:
		for i in gw:
			var h := grid_height_m(i, j)
			var xz := grid_to_xz(i, j)
			verts[j * gw + i] = Vector3(xz.x, h * k, xz.y)
			uvs[j * gw + i] = Vector2(float(i) / (gw - 1), float(j) / (gh - 1))
			var hl := grid_height_m(i - 1, j) * k
			var hr := grid_height_m(i + 1, j) * k
			var hu := grid_height_m(i, j - 1) * k
			var hd := grid_height_m(i, j + 1) * k
			norms[j * gw + i] = Vector3((hl - hr) / (2.0 * dx), 1.0, (hu - hd) / (2.0 * dz)).normalized()
	var idx := PackedInt32Array()
	for j in gh - 1:
		for i in gw - 1:
			var a := j * gw + i
			var b := a + 1
			var c := a + gw
			var d := c + 1
			if grid[a] < -9000.0 or grid[b] < -9000.0 or grid[c] < -9000.0 or grid[d] < -9000.0:
				continue
			idx.append_array([a, b, c, b, d, c])
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_NORMAL] = norms
	arr[Mesh.ARRAY_TEX_UV] = uvs
	arr[Mesh.ARRAY_INDEX] = idx
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	return mesh

# ------------------------------------------------------------------ EA v2: chunked terrain with LODs
## Tiles of `tile_cells` grid cells (129x129 verts -> 16-bit indices). Each tile is its own mesh (frustum culling)
## with Godot mesh LODs (strides 2/4/8; key = the tile's max height error in km, baked in terrain/tile_lod.json
## or estimated here). Skirts (both windings) hide LOD cracks between neighbouring tiles. All-sea tiles skipped.
## Returns [{mesh, tris_lod0, rect}], and fills `tile_stats`.
var tile_stats := {}
var _idx_cache := {}

func _cell_ok(i: int, j: int) -> bool:
	return grid[j * gw + i] > -9000.0 and grid[j * gw + i + 1] > -9000.0 \
		and grid[(j + 1) * gw + i] > -9000.0 and grid[(j + 1) * gw + i + 1] > -9000.0

func build_terrain_tiles(tile_cells := 128, strides := [2, 4, 8], skirt_km := 6.0, lod_errors := {}) -> Array:
	var out := []
	var k := height_scale / 1000.0
	var nti := int(ceil(float(gw - 1) / tile_cells))
	var ntj := int(ceil(float(gh - 1) / tile_cells))
	var tris0 := 0
	var skipped := 0
	for tj in ntj:
		for ti in nti:
			var i0 := ti * tile_cells
			var j0 := tj * tile_cells
			var ncx := mini(tile_cells, gw - 1 - i0)
			var ncz := mini(tile_cells, gh - 1 - j0)
			var nx := ncx + 1
			var nz := ncz + 1
			# which cells are kept (v3 rule: drop cells touching far-sea -9999 samples)
			var keep := PackedByteArray()
			keep.resize(ncx * ncz)
			var nkeep := 0
			for b in ncz:
				for a in ncx:
					if _cell_ok(i0 + a, j0 + b):
						keep[b * ncx + a] = 1
						nkeep += 1
			if nkeep == 0:
				skipped += 1
				continue
			var full := nkeep == ncx * ncz
			# vertices: grid verts + 4 skirt rings (one copy per edge, dropped by skirt_km)
			var nv := nx * nz
			var verts := PackedVector3Array()
			var uvs := PackedVector2Array()
			verts.resize(nv + 2 * nx + 2 * nz)
			uvs.resize(nv + 2 * nx + 2 * nz)
			for b in nz:
				var j := j0 + b
				var z := -0.5 * height_km + float(j) / (gh - 1) * height_km
				var vv := float(j) / (gh - 1)
				var row := j * gw
				for a in nx:
					var i := i0 + a
					var h := grid[row + i]
					if h < -9000.0:
						h = -8.0
					verts[b * nx + a] = Vector3(-0.5 * width_km + float(i) / (gw - 1) * width_km, h * k, z)
					uvs[b * nx + a] = Vector2(float(i) / (gw - 1), vv)
			# skirts: top edge (b=0), bottom (b=nz-1), left (a=0), right (a=nx-1)
			var sb := [nv, nv + nx, nv + 2 * nx, nv + 2 * nx + nz]
			for a in nx:
				verts[sb[0] + a] = verts[a] - Vector3(0, skirt_km, 0); uvs[sb[0] + a] = uvs[a]
				verts[sb[1] + a] = verts[(nz - 1) * nx + a] - Vector3(0, skirt_km, 0); uvs[sb[1] + a] = uvs[(nz - 1) * nx + a]
			for b in nz:
				verts[sb[2] + b] = verts[b * nx] - Vector3(0, skirt_km, 0); uvs[sb[2] + b] = uvs[b * nx]
				verts[sb[3] + b] = verts[b * nx + nx - 1] - Vector3(0, skirt_km, 0); uvs[sb[3] + b] = uvs[b * nx + nx - 1]
			var norms := PackedVector3Array()
			norms.resize(verts.size())
			norms.fill(Vector3.UP)      # lighting uses the baked normal texture; vertex normals only feed shadow bias
			var idx0 := _tile_indices(nx, nz, 1, keep, full)
			# 의도된 버림: 삼각형 수 = 인덱스 수 / 3(항상 나누어떨어짐)
			@warning_ignore("integer_division")
			tris0 += idx0.size() / 3
			var lods := {}
			var errs: Array = lod_errors.get("%d,%d" % [ti, tj], [])
			var last := 0.0
			for si in strides.size():
				var s: int = strides[si]
				if s >= ncx or s >= ncz:
					break
				var e := float(errs[si]) if si < errs.size() else float(s) * width_km / (gw - 1) * 0.25
				e = maxf(e, last * 1.05 + 1e-4)
				last = e
				var li := _tile_indices(nx, nz, s, keep, full)
				if li.size() == 0 or li.size() >= idx0.size():
					break    # sparse coastal tile: a coarser LOD would not be smaller (Godot requires LOD < LOD0)
				lods[e] = li
			var arr := []
			arr.resize(Mesh.ARRAY_MAX)
			arr[Mesh.ARRAY_VERTEX] = verts
			arr[Mesh.ARRAY_NORMAL] = norms
			arr[Mesh.ARRAY_TEX_UV] = uvs
			arr[Mesh.ARRAY_INDEX] = idx0
			var mesh := ArrayMesh.new()
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr, [], lods)
			# 의도된 버림: 삼각형 수 = 인덱스 수 / 3(항상 나누어떨어짐)
			@warning_ignore("integer_division")
			out.append({"mesh": mesh, "tile": Vector2i(ti, tj), "tris": idx0.size() / 3})
	tile_stats = {"tiles": out.size(), "tiles_skipped_sea": skipped, "tris_lod0": tris0, "tile_cells": tile_cells}
	return out

## Index list for one tile at stride s (+ skirts). Coarse cell kept if ANY fine cell under it is kept.
## Complete tiles share one cached array per (nx, nz, s).
func _tile_indices(nx: int, nz: int, s: int, keep: PackedByteArray, full: bool) -> PackedInt32Array:
	var key := "%d_%d_%d" % [nx, nz, s]
	if full and _idx_cache.has(key):
		return _idx_cache[key]
	var ncx := nx - 1
	var ncz := nz - 1
	var xs := []      # vertex columns used at this stride (always include the last one)
	var a := 0
	while a < ncx:
		xs.append(a)
		a += s
	xs.append(ncx)
	var zs := []
	var b := 0
	while b < ncz:
		zs.append(b)
		b += s
	zs.append(ncz)
	var idx := PackedInt32Array()
	var ckeep := {}   # coarse cell kept flags (for skirts)
	for q in zs.size() - 1:
		for p in xs.size() - 1:
			var ax: int = xs[p]
			var bx: int = xs[p + 1]
			var az: int = zs[q]
			var bz: int = zs[q + 1]
			var ok := full
			if not ok:
				for zz in range(az, bz):
					for xx in range(ax, bx):
						if keep[zz * ncx + xx] == 1:
							ok = true
							break
					if ok:
						break
			if not ok:
				continue
			ckeep[Vector2i(p, q)] = true
			var v00 := az * nx + ax
			var v10 := az * nx + bx
			var v01 := bz * nx + ax
			var v11 := bz * nx + bx
			idx.append_array([v00, v10, v01, v10, v11, v01])
	# skirts along the 4 tile edges (only next to kept coarse cells), both windings
	var nv := nx * nz
	var sb := [nv, nv + nx, nv + 2 * nx, nv + 2 * nx + nz]
	for p in xs.size() - 1:
		var ax: int = xs[p]
		var bx: int = xs[p + 1]
		if ckeep.has(Vector2i(p, 0)):
			_quad2(idx, ax, bx, sb[0] + ax, sb[0] + bx)
		if ckeep.has(Vector2i(p, zs.size() - 2)):
			_quad2(idx, ncz * nx + ax, ncz * nx + bx, sb[1] + ax, sb[1] + bx)
	for q in zs.size() - 1:
		var az: int = zs[q]
		var bz: int = zs[q + 1]
		if ckeep.has(Vector2i(0, q)):
			_quad2(idx, az * nx, bz * nx, sb[2] + az, sb[2] + bz)
		if ckeep.has(Vector2i(xs.size() - 2, q)):
			_quad2(idx, az * nx + ncx, bz * nx + ncx, sb[3] + az, sb[3] + bz)
	if full:
		_idx_cache[key] = idx
	return idx

func _quad2(idx: PackedInt32Array, t0: int, t1: int, s0: int, s1: int) -> void:
	idx.append_array([t0, t1, s0, t1, s1, s0, t0, s0, t1, t1, s0, s1])
