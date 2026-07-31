#!/usr/bin/env python3
"""Read-only gunner/mounted-archer visual-resource contract guard."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EXPECTED = {
    "gunner": "assets/web_battle/unit_tokens/japan/gunner/japan_gunner_01.png",
    "mounted_archer": "assets/web_battle/unit_tokens/mongol/horse_archer/mongol_horse_archer.png",
}
errors = []
for unit_type, relative in EXPECTED.items():
    asset = ROOT / relative
    if not asset.is_file(): errors.append(f"{unit_type}: missing asset {relative}")
    if not Path(str(asset) + '.import').is_file(): errors.append(f"{unit_type}: missing Godot import")
contract = (ROOT / 'scripts/battle/unit_type_contract.gd').read_text(encoding='utf-8')
battle = (ROOT / 'scripts/battle_web_import_test.gd').read_text(encoding='utf-8')
factory = (ROOT / 'scripts/worldmap/hero_runtime_factory.gd').read_text(encoding='utf-8')
for token in ('get_visual_metadata', 'japan_gunner', 'mongol_mounted_archer', 'icon_path', 'attack_fx_profile', 'move_fx_profile'):
    if token not in contract and token not in factory: errors.append(f"missing canonical metadata: {token}")
for token in ('japan_gunner', 'mongol_mounted_archer', 'japan_gunner_01.png', 'mongol_horse_archer.png'):
    if token not in battle: errors.append(f"missing battle lookup: {token}")
if errors:
    print('T07 VISUAL METADATA FAILED\n' + '\n'.join('- ' + e for e in errors)); raise SystemExit(1)
print('T07 VISUAL METADATA PASS: Japanese gunner and Mongol mounted-archer assets/imports/lookups')
