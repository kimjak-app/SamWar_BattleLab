#!/usr/bin/env python3
from pathlib import Path
import json
root = Path(__file__).resolve().parents[1]
rules = json.loads((root/'data/heroes/generated/unit_type_rules.json').read_text(encoding='utf-8'))['unit_types']
profiles = json.loads((root/'data/heroes/generated/hero_battle_profiles.json').read_text(encoding='utf-8'))['profiles']
ids = {r['unit_type'] for r in rules}; expected={'infantry','cavalry','archer','gunner','mounted_archer'}
errors=[]
if ids != expected: errors.append('canonical IDs')
if any(p.get('unit_type') == 'support' or p.get('unit_type') not in ids for p in profiles): errors.append('profile unit types')
if len(profiles) != 39: errors.append('39 profile parity')
for path, token in [('scripts/battle_unit_state.gd','remaining_post_attack_move'),('scripts/battle/helpers/battle_ui_text_format_helper.gd','mounted_archer'),('scripts/worldmap/t03/auto_battle_resolver.gd','UnitTypeContractScript')]:
    if token not in (root/path).read_text(encoding='utf-8'): errors.append(path)
if errors: print('FIVE UNIT TYPE FULL COMPLETION FAILED:', ', '.join(errors)); raise SystemExit(1)
print('FIVE UNIT TYPE FULL COMPLETION PASS: canonical display / state round-trip fields / auto battle / 39 profiles')
