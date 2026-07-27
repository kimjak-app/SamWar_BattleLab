#!/usr/bin/env python3
"""Validate generated hero design JSON against the protected legacy registry.

This audit compares identity and linkage only. Legacy `war`, `command`, `attack`,
and similar fields are not treated as equivalent to the new locked stat contract.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

EXPECTED_HERO_COUNT = 39
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
    parser.add_argument(
        "--registry",
        type=Path,
        default=Path("scripts/worldmap/hero_definition_registry.gd"),
    )
    parser.add_argument(
        "--data-dir",
        type=Path,
        default=Path("data/heroes/generated"),
    )
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
        ("unit types", unit_rows, 6),
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

    skill_ids = {str(row.get("skill_id", "")) for row in skill_rows}
    for row in profile_rows:
        hero_id = str(row.get("hero_id", ""))
        expected_skill_id = f"{hero_id}_unique"
        if row.get("unique_skill_id") != expected_skill_id:
            fail(errors, f"{hero_id}: profile skill ID must be {expected_skill_id}")
        if expected_skill_id not in skill_ids:
            fail(errors, f"{hero_id}: missing linked unique skill")

    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1

    print(
        "PARITY PASS: 39 legacy hero IDs match generated base/profile/skill JSON; "
        "6 unit types and 8 roles present"
    )
    print(
        "NOTE: legacy combat/stat values were intentionally not compared because "
        "their field meanings are not equivalent to the T06-1 locked contract"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
