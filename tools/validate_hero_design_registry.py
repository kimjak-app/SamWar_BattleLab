#!/usr/bin/env python3
"""Validate generated hero design JSON against the protected legacy registry."""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter
from pathlib import Path

EXPECTED_HERO_COUNT = 39
EXPECTED_UNIT_TYPE_COUNT = 5
EXPECTED_UNIT_DISTRIBUTION = {
    "infantry": 11,
    "cavalry": 10,
    "archer": 11,
    "gunner": 4,
    "mounted_archer": 3,
}
EXPECTED_MOMENTUM_DISTRIBUTION = {1: 1, 2: 9, 3: 18, 4: 11}
HERO_ENTRY_RE = re.compile(r'^\s*"([a-z0-9_]+)"\s*:\s*\{', re.MULTILINE)


def load_json(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as handle:
        value = json.load(handle)
    if not isinstance(value, dict):
        raise ValueError(f"{path}: root must be an object")
    return value


def fail(errors: list[str], message: str) -> None:
    errors.append(message)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--registry", type=Path, default=Path("scripts/worldmap/hero_definition_registry.gd"))
    parser.add_argument("--data-dir", type=Path, default=Path("data/heroes/generated"))
    args = parser.parse_args()

    errors: list[str] = []
    registry_text = args.registry.read_text(encoding="utf-8")
    legacy_ids = HERO_ENTRY_RE.findall(registry_text)

    base = load_json(args.data_dir / "hero_base_stats.json")
    profiles = load_json(args.data_dir / "hero_battle_profiles.json")
    skills = load_json(args.data_dir / "hero_unique_skills.json")
    unit_types = load_json(args.data_dir / "unit_type_rules.json")
    roles = load_json(args.data_dir / "battle_role_rules.json")

    base_rows = base.get("heroes", [])
    profile_rows = profiles.get("profiles", [])
    skill_rows = skills.get("skills", [])
    unit_rows = unit_types.get("unit_types", [])
    role_rows = roles.get("roles", [])

    for label, rows, expected in (
        ("legacy registry", legacy_ids, EXPECTED_HERO_COUNT),
        ("base stats", base_rows, EXPECTED_HERO_COUNT),
        ("battle profiles", profile_rows, EXPECTED_HERO_COUNT),
        ("unique skills", skill_rows, EXPECTED_HERO_COUNT),
        ("unit types", unit_rows, EXPECTED_UNIT_TYPE_COUNT),
        ("battle roles", role_rows, 8),
    ):
        if len(rows) != expected:
            fail(errors, f"{label}: expected {expected}, found {len(rows)}")

    base_ids = [str(row.get("hero_id", "")) for row in base_rows]
    profile_ids = [str(row.get("hero_id", "")) for row in profile_rows]
    skill_hero_ids = [str(row.get("hero_id", "")) for row in skill_rows]

    if legacy_ids != base_ids:
        fail(errors, "legacy registry and base JSON hero ID order differ")
    if base_ids != profile_ids:
        fail(errors, "base JSON and profile JSON hero ID order differ")
    if base_ids != skill_hero_ids:
        fail(errors, "base JSON and skill JSON hero ID order differ")

    allowed_units = set(EXPECTED_UNIT_DISTRIBUTION)
    allowed_roles = {"assault", "vanguard", "defender", "commander", "mobile", "ranged", "tactician", "support"}
    unit_distribution: Counter[str] = Counter()

    for row in profile_rows:
        hero_id = str(row.get("hero_id", ""))
        expected_skill_id = f"{hero_id}_unique"
        unit_type = str(row.get("unit_type", ""))
        primary_role = str(row.get("primary_role", ""))
        secondary_role = str(row.get("secondary_role", ""))

        if row.get("unique_skill_id") != expected_skill_id:
            fail(errors, f"{hero_id}: profile skill ID must be {expected_skill_id}")
        if unit_type not in allowed_units:
            fail(errors, f"{hero_id}: unsupported unit_type {unit_type}")
        if unit_type == "support":
            fail(errors, f"{hero_id}: support is a role, never a unit_type")
        if primary_role not in allowed_roles or secondary_role not in allowed_roles:
            fail(errors, f"{hero_id}: unsupported role pair {primary_role}/{secondary_role}")
        unit_distribution[unit_type] += 1

    if dict(unit_distribution) != EXPECTED_UNIT_DISTRIBUTION:
        fail(errors, f"unit distribution mismatch: expected {EXPECTED_UNIT_DISTRIBUTION}, found {dict(unit_distribution)}")

    skill_ids: set[str] = set()
    momentum_distribution: Counter[int] = Counter()
    for row in skill_rows:
        hero_id = str(row.get("hero_id", ""))
        skill_id = str(row.get("skill_id", ""))
        expected_skill_id = f"{hero_id}_unique"
        momentum_cost = row.get("momentum_cost")

        if skill_id != expected_skill_id:
            fail(errors, f"{hero_id}: skill ID must be {expected_skill_id}")
        if skill_id in skill_ids:
            fail(errors, f"duplicate skill ID: {skill_id}")
        skill_ids.add(skill_id)

        if not isinstance(momentum_cost, int) or isinstance(momentum_cost, bool) or not 1 <= momentum_cost <= 4:
            fail(errors, f"{hero_id}: momentum_cost must be integer 1..4, found {momentum_cost!r}")
        else:
            momentum_distribution[momentum_cost] += 1

        if row.get("action_cost") != 1:
            fail(errors, f"{hero_id}: action_cost must remain 1")
        if row.get("hp_condition") is not None:
            fail(errors, f"{hero_id}: hp_condition must remain null")

    for hero_id in profile_ids:
        if f"{hero_id}_unique" not in skill_ids:
            fail(errors, f"{hero_id}: missing linked unique skill")

    if dict(momentum_distribution) != EXPECTED_MOMENTUM_DISTRIBUTION:
        fail(errors, f"momentum distribution mismatch: expected {EXPECTED_MOMENTUM_DISTRIBUTION}, found {dict(momentum_distribution)}")

    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1

    print("PARITY PASS: 39 heroes; unit distribution 11/10/11/4/3; support role-only contract; momentum costs 1..4")
    print("MOMENTUM DISTRIBUTION PASS: 1=1, 2=9, 3=18, 4=11")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
