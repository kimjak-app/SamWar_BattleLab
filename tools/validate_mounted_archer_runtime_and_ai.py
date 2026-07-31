#!/usr/bin/env python3
from pathlib import Path
import json
root = Path(__file__).resolve().parents[1]
rules = {r['unit_type']: r for r in json.loads((root / 'data/heroes/generated/unit_type_rules.json').read_text(encoding='utf-8'))['unit_types']}
r = rules['mounted_archer']; errors = []
for k, v in {'move_range':4, 'minimum_attack_range':1, 'maximum_attack_range':2, 'can_attack_after_move':True, 'can_move_after_attack':True, 'post_attack_move_limit':2, 'base_damage_modifier':.92, 'received_damage_modifier':1.08, 'side_attack_modifier':.06}.items():
    if r.get(k) != v: errors.append(k)
s = (root/'scripts/battle_unit_state.gd').read_text(encoding='utf-8')
for token in ('post_attack_move_available', 'remaining_post_attack_move', 'attacked_this_turn'):
    if token not in s: errors.append(token)
if errors: print('MOUNTED ARCHER RUNTIME FAILED:', ', '.join(errors)); raise SystemExit(1)
print('MOUNTED ARCHER RUNTIME PASS: mobile range / post-attack state / snapshot fields')
