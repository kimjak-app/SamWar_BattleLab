#!/usr/bin/env python3
"""Read-only T07-3 contract guard."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]
rules = {r["unit_type"]: r for r in json.loads((ROOT / "data/heroes/generated/unit_type_rules.json").read_text(encoding="utf-8"))["unit_types"]}
errors = []
expected = {"infantry": (3, 1, 1, True), "cavalry": (4, 1, 1, True), "archer": (3, 1, 3, True), "gunner": (2, 1, 3, False), "mounted_archer": (4, 1, 2, True)}
for unit_type, values in expected.items():
    row = rules.get(unit_type, {})
    if (row.get("move_range"), row.get("minimum_attack_range"), row.get("maximum_attack_range"), row.get("can_attack_after_move")) != values:
        errors.append(f"{unit_type}: movement/range/action contract mismatch")
if rules["gunner"].get("counterattack_max_range") != 0 or rules["mounted_archer"].get("counterattack_max_range") != 0:
    errors.append("ranged no-counterattack contract mismatch")
source = (ROOT / "scripts/battle_web_import_test.gd").read_text(encoding="utf-8")
for token in ("UnitTypeContractScript.can_unit_attack", "UnitTypeContractScript.can_attack_after_move", "moved_distance"):
    if token not in source:
        errors.append(f"battle source missing shared contract token: {token}")
if errors:
    print("FIVE UNIT TYPE ACTION ELIGIBILITY FAILED")
    print("\n".join(f"- {e}" for e in errors))
    raise SystemExit(1)
print("FIVE UNIT TYPE ACTION ELIGIBILITY PASS: 5 types / shared range / moved distance")
