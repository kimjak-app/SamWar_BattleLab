#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RULES_PATH = ROOT / "data/heroes/generated/unit_type_rules.json"
EXPECTED = {
    "infantry": (3, 1, 1),
    "cavalry": (4, 1, 1),
    "archer": (3, 1, 3),
    "gunner": (2, 1, 3),
    "mounted_archer": (4, 1, 2),
}
REQUIRED_FIELDS = {
    "unit_type",
    "display_name",
    "move_range",
    "minimum_attack_range",
    "maximum_attack_range",
    "counterattack_min_range",
    "counterattack_max_range",
    "can_attack_after_move",
    "can_move_after_attack",
    "post_attack_move_limit",
    "base_damage_modifier",
    "received_damage_modifier",
    "armor_ignore_ratio",
    "ai_behavior_profile",
    "visual_key",
    "icon_key",
    "animation_profile",
}


def main() -> int:
    payload = json.loads(RULES_PATH.read_text(encoding="utf-8"))
    errors: list[str] = []
    if payload.get("schema_version") != 2:
        errors.append("unit type rules schema_version must be 2")
    rows = payload.get("unit_types", [])
    if len(rows) != 5:
        errors.append(f"unit type count must be 5, got {len(rows)}")
    by_id = {str(row.get("unit_type", "")): row for row in rows}
    if set(by_id) != set(EXPECTED):
        errors.append(f"unit type IDs mismatch: {sorted(by_id)}")

    for unit_type, expected_values in EXPECTED.items():
        row = by_id.get(unit_type, {})
        missing = sorted(REQUIRED_FIELDS - set(row))
        if missing:
            errors.append(f"{unit_type}: missing fields {missing}")
            continue
        actual = (
            int(row["move_range"]),
            int(row["minimum_attack_range"]),
            int(row["maximum_attack_range"]),
        )
        if actual != expected_values:
            errors.append(f"{unit_type}: move/min/max {actual} != {expected_values}")
        if int(row["minimum_attack_range"]) > int(row["maximum_attack_range"]):
            errors.append(f"{unit_type}: invalid attack range interval")
        if str(row["visual_key"]) != unit_type:
            errors.append(f"{unit_type}: visual_key must match canonical ID")

    gunner = by_id.get("gunner", {})
    if gunner.get("can_attack_after_move") is not False:
        errors.append("gunner: can_attack_after_move must be false")
    if float(gunner.get("armor_ignore_ratio", 0.0)) != 0.20:
        errors.append("gunner: armor_ignore_ratio must be 0.20")
    if float(gunner.get("post_fire_penalty", 0.0)) != -0.40:
        errors.append("gunner: post_fire_penalty must be -0.40")

    mounted = by_id.get("mounted_archer", {})
    if mounted.get("can_move_after_attack") is not True:
        errors.append("mounted_archer: can_move_after_attack must be true")
    if int(mounted.get("post_attack_move_limit", 0)) != 2:
        errors.append("mounted_archer: post_attack_move_limit must be 2")
    if mounted.get("mobile_ranged") is not True:
        errors.append("mounted_archer: mobile_ranged must be true")

    if errors:
        print("FIVE UNIT TYPE STRUCTURED CONTRACT FAILED")
        for error in errors:
            print(f"- {error}")
        return 1
    print("FIVE UNIT TYPE STRUCTURED CONTRACT PASS: schema=2 types=5")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
