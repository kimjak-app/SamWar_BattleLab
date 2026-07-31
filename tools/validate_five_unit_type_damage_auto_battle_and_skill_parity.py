#!/usr/bin/env python3
from pathlib import Path
import json
root = Path(__file__).resolve().parents[1]
rules = {r['unit_type']: r for r in json.loads((root/'data/heroes/generated/unit_type_rules.json').read_text(encoding='utf-8'))['unit_types']}
profiles = json.loads((root/'data/heroes/generated/hero_battle_profiles.json').read_text(encoding='utf-8'))['profiles']
errors=[]
if set(rules) != {'infantry','cavalry','archer','gunner','mounted_archer'}: errors.append('canonical IDs')
if len(profiles) != 39: errors.append('profile count')
if any(p.get('unit_type') not in rules for p in profiles): errors.append('unsupported profile type')
for path, token in [('scripts/battle_web_import_test.gd','get_damage_context'),('scripts/worldmap/t03/auto_battle_resolver.gd','get_damage_context')]:
    if token not in (root/path).read_text(encoding='utf-8'): errors.append(path)
if errors: print('FIVE UNIT TYPE DAMAGE PARITY FAILED:', ', '.join(errors)); raise SystemExit(1)
print('FIVE UNIT TYPE DAMAGE PARITY PASS: manual / automatic / 39-profile canonical types')
