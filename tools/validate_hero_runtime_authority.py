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
    game_session = (ROOT / "scripts/game_session.gd").read_text(encoding="utf-8")
    battle_unit_state = (ROOT / "scripts/battle_unit_state.gd").read_text(encoding="utf-8")
    worldmap_panel = (ROOT / "scripts/worldmap_city_info_panel.gd").read_text(encoding="utf-8")
    worldmap_panel_base_path = ROOT / "scripts/worldmap_city_info_panel_base.gd"
    worldmap_panel_base = (
        worldmap_panel_base_path.read_text(encoding="utf-8")
        if worldmap_panel_base_path.exists()
        else ""
    )
    dead_postprocess = ROOT / "scripts/battle/hero_battle_profile_integration.gd"

    require("HeroWorldMapStatIntegration" not in project,
            "worldmap postprocess autoload must be removed", errors)
    require("HeroBattleProfileIntegration" not in project,
            "battle postprocess autoload must be removed", errors)
    require(not dead_postprocess.exists(),
            "dead battle profile postprocess integration file must be deleted", errors)
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
    require('return "지휘 %d / 무 %d / 지 %d / 정 %d / 충 %d"' in factory,
            "factory must own the final five-stat hero display contract", errors)

    require(worldmap_panel_base_path.exists(),
            "worldmap city info panel base implementation is missing", errors)
    require("class_name WorldMapCityInfoPanel" in worldmap_panel_base,
            "worldmap panel base must preserve the scene-facing class contract", errors)
    require('extends "res://scripts/worldmap_city_info_panel_base.gd"' in worldmap_panel,
            "scene-facing worldmap panel must extend the preserved implementation", errors)
    require("HeroRuntimeFactory.format_stat_line(hero_data)" in worldmap_panel,
            "worldmap hero cards must use the authoritative five-stat formatter", errors)
    require('"정 %d / 무 %d / 지 %d / 충 %d"' not in worldmap_panel,
            "scene-facing worldmap panel must not expose the legacy four-stat formatter", errors)

    require("HeroRuntimeFactoryScript.build_battle_unit_payload" in battle_unit_state,
            "BattleUnitState must enforce HeroRuntimeFactory at the creation boundary", errors)
    require("var authoritative_data := _build_authoritative_payload(data)" in battle_unit_state,
            "BattleUnitState.setup must consume the authoritative payload", errors)
    require('payload["visual_key"] = payload["unit_type"]' in battle_unit_state,
            "BattleUnitState must lock visual_key to unit_type before first render", errors)
    require("static func _resolve_hero_id" in battle_unit_state,
            "BattleUnitState must resolve runtime heroes from hero_id or display name", errors)
    require("HeroDefinitionRegistryScript.HERO_DATA" in battle_unit_state,
            "BattleUnitState must resolve heroes from the factory-built runtime registry", errors)

    require("func request_load()" in game_session,
            "GameSession load entry is missing", errors)
    require("_migrate_worldmap_save_before_load()" in game_session,
            "GameSession must migrate the save before setting the load request", errors)
    require("HeroRuntimeFactory.migrate_saved_payload" in game_session,
            "GameSession must invoke HeroRuntimeFactory at the load boundary", errors)
    require("HeroDefinitionRegistry.LEGACY_IDENTITY_DATA" in game_session,
            "save migration must receive the identity registry", errors)
    require("hero_runtime_migration_version" in game_session,
            "migrated saves must carry a migration marker", errors)
    request_load_body = game_session.split("func request_load()", 1)[1].split("func consume_load_request", 1)[0]
    require(request_load_body.find("_migrate_worldmap_save_before_load()") < request_load_body.find("_load_requested = true"),
            "save migration must run before WorldMap consumes the load request", errors)

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
        "HERO RUNTIME AUTHORITY PASS: factory-built registry, authoritative five-stat WorldMap UI, "
        "pre-load save migration, BattleUnitState creation authority, no postprocess integration, "
        "five-unit authority locked"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
