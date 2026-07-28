#!/usr/bin/env python3
from pathlib import Path
path=Path('scripts/worldmap/worldmap_main.gd')
text=path.read_text(encoding='utf-8')
old='''\tif attacker_general_ids.is_empty():\n\t\tattacker_general_ids = attacker_hero_outcomes.keys()\n'''
new='''\tif attacker_general_ids.is_empty():\n\t\tfor hero_id_variant in attacker_hero_outcomes.keys():\n\t\t\tvar fallback_hero_id := str(hero_id_variant)\n\t\t\tif not fallback_hero_id.is_empty() and not attacker_general_ids.has(fallback_hero_id):\n\t\t\t\tattacker_general_ids.append(fallback_hero_id)\n'''
if old not in text:
    raise SystemExit('typed outcome fallback anchor missing')
path.write_text(text.replace(old,new,1),encoding='utf-8')
print('T06-9-hotfix1 typed outcome IDs applied')
