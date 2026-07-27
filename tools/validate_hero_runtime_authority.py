#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def require(condition: bool, message: str, errors: list[str]) -> None:
    if not condition:
        errors.append(message)


def main() -> int:
    errors: list[str] = []

    project = (ROOT / "project.godot").read_text(encoding="utf-8")
    registry = (ROOT / "scripts/worldmap/hero_definition_registry.gd").read_text(encoding="utf-8")
    factory = (ROOT / "scripts/worldmap/hero_runtime_factory.gd").read_text(encoding="utf-8")
    adapter = (ROOT / "scripts/battle/hero_battle_design_adapter.gd").read_text(encoding="utf-8")

    require("HeroWorldMapStatIntegration" not in project,
            "worldmap postprocess autoload must be removed", errors)
    require("HeroBattleProfileIntegration" not in project,
            "battle postprocess autoload must be removed", errors)
    require("HeroRuntimeFactory.build_runtime_registry" in registry,
            "hero registry must expose factory-built runtime data", errors)
    require("static var HERO_DATA" in registry,
            "hero registry runtime data must not be a read-only legacy const", errors)
    require("HeroRuntimeFactory.build_runtime_hero" in adapter,
            "battle adapter must use HeroRuntimeFactory", errors)

    require("static func migrate_saved_payload" in factory,
            "recursive saved payload migration API is missing", errors)
    require("static func migrate_saved_hero" in factory,
            "saved hero migration API is missing", errors)
    require("MUTABLE_SAVE_KEYS" in factory and '"loyalty"' in factory,
            "current loyalty must be preserved as mutable save state", errors)
    require('result["unit_type"] = unit_type' in factory,
            "unit type must be restored from authoritative profile", errors)
    require('result["war"] = martial' in factory and 'result["politics"]' in factory,
            "fixed stats must be restored from authoritative design data", errors)
    require('identity_registry.has(hero_id)' in factory,
            "recursive migration must only rebuild known heroes", errors)
    require("depth > 12" in factory,
            "recursive save migration must have a depth guard", errors)

    profiles = json.loads(
        (ROOT / "data/heroes/generated/hero_battle_profiles.json").read_text(encoding="utf-8")
    )
    profile_by_id = {item["hero_id"]: item for item in profiles.get("profiles", [])}
    expected = {
        "jeong_do_jeon": "archer",
        "dorim": "archer",
        "cheok_jun_gyeong": "infantry",
        "konishi_yukinaga": "gunner",
        "honda_masanobu": "gunner",
    }
    for hero_id, unit_type in expected.items():
        require(profile_by_id.get(hero_id, {}).get("unit_type") == unit_type,
                f"{hero_id} must use {unit_type}", errors)

    all_units = {item.get("unit_type") for item in profiles.get("profiles", [])}
    require("support" not in all_units, "support unit type must not exist", errors)

    if errors:
        print("HERO RUNTIME AUTHORITY VALIDATION FAILED")
        for error in errors:
            print(f"- {error}")
        return 1

    print(
        "HERO RUNTIME AUTHORITY PASS: factory-built registry, no postprocess autoloads, "
        "recursive save migration contract, five-unit authority locked"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
