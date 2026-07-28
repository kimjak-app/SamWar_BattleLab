#!/usr/bin/env python3
from pathlib import Path

path = Path('scripts/battle/battle_skill_resolver.gd')
text = path.read_text(encoding='utf-8')
text = text.replace('\tvar hero_id := String(skill.get("hero_id", ""))\n', '', 1)
text = text.replace('\t\t\t\tif hero_id == "cheok_jun_gyeong": damage_flag = "advance_on_kill"', '\t\t\t\tif effect_type == "line_damage" and int(skill.get("range", 0)) == 1: damage_flag = "advance_on_kill"', 1)
text = text.replace('\tif effect_type == "guard_aura" and target == caster and String(caster.hero_id) == "gyebaek": scaled = int(round(float(amount) * 1.5))', '\tif effect_type == "guard_aura" and target == caster: scaled = int(round(float(amount) * 1.25))', 1)
path.write_text(text, encoding='utf-8')
print('T06-8 hero hardcodes removed')
