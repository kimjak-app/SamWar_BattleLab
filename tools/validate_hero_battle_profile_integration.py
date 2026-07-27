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
    factory = (ROOT / "scripts/worldmap/hero_runtime_factory.gd").read_text(encoding="utf-8")
    registry = (ROOT / "scripts/worldmap/hero_definition_registry.gd").read_text(encoding="utf-8")
    adapter = (ROOT / "scripts/battle/hero_battle_design_adapter.gd").read_text(encoding="utf-8")

    require("HeroBattleProfileIntegration=" not in project,
            "battle postprocess autoload must be removed", errors)
    require("HeroWorldMapStatIntegration=" not in project,
            "worldmap postprocess autoload must be removed", errors)
    require("HeroRuntimeFactory.build_runtime_registry(LEGACY_IDENTITY_DATA)" in registry,
            "hero registry does not expose factory-built runtime data", errors)
    require("HeroRuntimeFactory.build_runtime_hero" in adapter,
            "battle adapter bypasses HeroRuntimeFactory", errors)
    require("build_battle_unit_payload" in factory,
            "factory battle payload builder missing", errors)
    require('"visual_key" = unit_type' not in factory,
            "invalid visual assignment syntax detected", errors)
    require('result["visual_key"] = unit_type' in factory,
            "factory does not synchronize battle visual_key", errors)

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

    print("INTEGRATION VALIDATION PASS: factory-owned 39-hero runtime registry, five unit types, no hero postprocess autoloads")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
