from pathlib import Path
import json, re
ROOT=Path(__file__).resolve().parents[1]
S=ROOT/'scripts/battle3d'
# Independent literal from B3D-F1 contract; never derive expectations from source.
EXPECTED_VIEW_FIELDS = ["unit_id","side","unit_type","grid_cell","facing","current_troops","max_troops","allocated_troops","footprint","has_moved","has_acted","status_effects","move_range","attack_range"]
adapter=(S/'battle3d_unit_adapter.gd').read_text(encoding='utf8')
match=re.search(r'^const\s+VIEW_FIELDS\s*(?::=|=)\s*(\[[^\]]*\])',adapter,re.M)
assert match is not None, 'VIEW_FIELDS declaration missing'
assert json.loads(match.group(1)) == EXPECTED_VIEW_FIELDS, 'VIEW_FIELDS exact size/order/elements mismatch'
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
    assert 'WorldMap.tscn' not in text
    if file != S/'battle3d_engine_host.gd':
        assert 'Battle_Main.tscn' not in text
    for path in re.findall(r'(?:load|preload)\("res://([^"%]+)"\)',text):
        assert (ROOT/path).exists(), path
data=json.loads((ROOT/'assets/battle3d/heightfield.json').read_text(encoding='utf8'))
# Block 7: the one 18x10 assertion is split by meaning (none dropped): the play area (the engine's battle grid) stays
# 18x10 in its one definition; the board (ground, heights, terrain types) is 20x20 of 3 m cells; the height grid
# covers the board at 0.5 m (20 x 3 / 0.5 + 1 = 121 per axis).
heightfield=(S/'lab_heightfield.gd').read_text(encoding='utf8')
play=re.findall(r'^const\s+PLAY_SIZE\s*:=\s*Vector2i\((\d+),\s*(\d+)\)',heightfield,re.M)
assert play==[('18','10')], ('play area 18x10, defined once', play)
assert 'grid_width=heightfield.PLAY_SIZE.x' in projection and 'grid_height=heightfield.PLAY_SIZE.y' in projection, 'the projection grid is the play area'
assert (data['board']['width'],data['board']['height'])==(20,20), 'board 20x20'
assert data['board']['cell_size']==3.0 and data['step']==0.5, 'cell 3 m, height step 0.5 m'
assert (data['nx'],data['nz'])==(121,121) and len(data['heights'])==121 and all(len(r)==121 for r in data['heights']), 'height grid 121x121'
print('BATTLE3D_CONTRACT PASS: 14-field ordered view contract, projection inheritance, engine query ownership, resources, play 18x10 / board 20x20 / heights 121x121 metadata')
