from pathlib import Path
import json, re
ROOT=Path(__file__).resolve().parents[1]
S=ROOT/'scripts/battle3d'
projection=(S/'battle3d_grid_projection.gd').read_text(encoding='utf8')
assert projection.startswith('extends BattleGridController')
for name in ['is_in_bounds','get_distance','get_tiles_in_range','grid_to_world','world_to_grid']:
    assert not re.search(r'^func '+name+r'\(',projection,re.M), name
query=(S/'battle3d_movement_adapter.gd').read_text(encoding='utf8')
assert 'battle/services/battle_movement_query_service.gd' in query
assert 'get_effective_move_range' in query and 'get_reachable_paths' in query
assert 'terrain_rules_enabled' not in query
view=(S/'battle3d_connect_lab.gd').read_text(encoding='utf8')
assert 'var terrain_rules_enabled := false' in view
assert 'var query_mode := true' in view
for file in list(S.glob('*.gd'))+list((ROOT/'tests/scripts').glob('test_battle3d_*.gd')):
    text=file.read_text(encoding='utf8')
    assert 'WorldMap.tscn' not in text and 'Battle_Main.tscn' not in text
    for path in re.findall(r'(?:load|preload)\("res://([^"%]+)"\)',text):
        assert (ROOT/path).exists(), path
data=json.loads((ROOT/'assets/battle3d/heightfield.json').read_text(encoding='utf8'))
assert (data['board']['width'],data['board']['height'])==(18,10)
assert (data['nx'],data['nz'])==(109,61)
print('BATTLE3D_CONTRACT PASS: projection inheritance, engine query ownership, resources, 18x10 metadata')
