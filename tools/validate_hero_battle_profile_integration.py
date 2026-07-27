#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def require(condition: bool, message: str, errors: list[str]) -> None:
    if not condition:
        errors.append(message)


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def main() -> int:
    errors: list[str] = []
    project = (ROOT / "project.godot").read_text(encoding="utf-8")
    integration = (ROOT / "scripts/battle/hero_battle_profile_integration.gd").read_text(encoding="utf-8")
    adapter = (ROOT / "scripts/battle/hero_battle_design_adapter.gd").read_text(encoding="utf-8")

    require('HeroBattleProfileIntegration="*res://scripts/battle/hero_battle_profile_integration.gd"' in project,
            "project.godot autoload is missing", errors)
    require("HeroBattleDesignAdapter.build_battle_contract" in integration,
            "integration does not invoke the battle design adapter", errors)
    require('battle_root.set("worldmap_context_hero_registry", enriched_registry)' in integration,
            "enriched roster registry is not written back", errors)
    require("unit_state.move_range" in integration and "unit_state.attack_range" in integration,
            "unit movement/range are not applied", errors)
    require("design_primary_role" in integration and "design_secondary_role" in integration,
            "role metadata is not attached", errors)
    require('status_effects["design_primary_role"]' not in integration,
            "role metadata must not use status_effects", errors)
    require("result[\"design_stats\"]" in adapter and "result[\"design_profile\"]" in adapter,
            "adapter namespaces are incomplete", errors)

    base = load_json(ROOT / "data/heroes/generated/hero_base_stats.json")
    profiles = load_json(ROOT / "data/heroes/generated/hero_battle_profiles.json")
    skills = load_json(ROOT / "data/heroes/generated/hero_unique_skills.json")
    units = load_json(ROOT / "data/heroes/generated/unit_type_rules.json")
    roles = load_json(ROOT / "data/heroes/generated/battle_role_rules.json")

    require(len(base.get("heroes", [])) == 39, "base hero count must be 39", errors)
    require(len(profiles.get("profiles", [])) == 39, "profile count must be 39", errors)
    require(len(skills.get("skills", [])) == 39, "skill count must be 39", errors)
    require(len(units.get("unit_types", [])) == 5, "unit type count must be 5", errors)
    require(len(roles.get("roles", [])) == 8, "role count must be 8", errors)

    allowed_units = {"infantry", "cavalry", "archer", "gunner", "mounted_archer"}
    profile_units = {str(item.get("unit_type", "")) for item in profiles.get("profiles", [])}
    require(profile_units.issubset(allowed_units), f"unknown unit types: {sorted(profile_units - allowed_units)}", errors)
    require("support" not in profile_units, "support must remain a role only, not a unit type", errors)

    if errors:
        print("INTEGRATION VALIDATION FAILED")
        for error in errors:
            print(f"- {error}")
        return 1

    print("INTEGRATION VALIDATION PASS: 39 heroes, 5 unit types, 8 roles, Battle autoload and profile application present")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
