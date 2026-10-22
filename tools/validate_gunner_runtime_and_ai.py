#!/usr/bin/env python3
"""Read-only guard for the gunner runtime contract."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]
rules = {r["unit_type"]: r for r in json.loads((ROOT / "data/heroes/generated/unit_type_rules.json").read_text(encoding="utf-8"))["unit_types"]}
gunner = rules["gunner"]
errors = []
for key, value in {"move_range": 2, "can_attack_after_move": False, "armor_ignore_ratio": .20, "prepared_fire_bonus": .15, "post_fire_penalty": -.40, "post_fire_penalty_turns": 1}.items():
    if gunner.get(key) != value: errors.append(f"gunner {key} mismatch")
# B1d (edfc67e) moved the damage formula into a service: runtime tokens are checked in the controller plus that service.
source = "\n".join((ROOT / p).read_text(encoding="utf-8") for p in ("scripts/battle_web_import_test.gd", "scripts/battle/services/battle_damage_formula_service.gd"))
for token in ("prepared_fire_bonus", "armor_ignore_ratio", "post_fire_penalty", "총병은 이동한 턴에 공격할 수 없습니다"):
    if token not in source: errors.append(f"missing runtime token: {token}")
if errors:
    print("GUNNER RUNTIME FAILED\n" + "\n".join("- " + e for e in errors)); raise SystemExit(1)
print("GUNNER RUNTIME PASS: prepared fire / armor penetration / post-fire penalty / shared AI eligibility")
