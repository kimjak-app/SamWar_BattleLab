# Battle3D art pilot (not engine data)

Blender pilot squads exported as one soldier per GLB (`unit_<type>.glb`, rotation 0, vertex-color material, 260-462 tris).
`formations.json` holds per-soldier offsets/yaw/scale (infantry 9, archer 6, gunner 6, cavalry 6, mounted_archer 5).
`pilot_compare.tscn` renders the 5 pilot squads next to the old 2x3 Lab models using the Lab camera numbers
(ortho, yaw 0.32, offset 43/40/43). Run: `godot --path . res://assets/battle3d/pilot/pilot_compare.tscn -- --out=out.png --zoom=24`.
Notes: colors are placeholder; the glb needs `Col` set as the active color attribute in Blender or Godot sees white COLOR_0.
