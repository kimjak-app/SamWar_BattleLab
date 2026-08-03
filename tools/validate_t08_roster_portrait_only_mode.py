from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCENE = ROOT / "tests/scenes/Battle_UI_Production_Test.tscn"
SCRIPT = ROOT / "tests/scripts/battle_ui_production_roster_collapse.gd"
PROTECTED = [
    ROOT / "Battle_Land.tscn",
    ROOT / "assets/ui/battle_ui_theme.tres",
    ROOT / "scripts/battle_web_import_test.gd",
]


def require(condition: bool, message: str, errors: list[str]) -> None:
    if not condition:
        errors.append(message)


def main() -> int:
    errors: list[str] = []
    scene = SCENE.read_text(encoding="utf-8")
    script = SCRIPT.read_text(encoding="utf-8")

    require('script = ExtResource("46_production_roster_collapse")' in scene,
            "collapse experiment node is not attached to the production test scene", errors)
    for side in ("Ally", "Enemy"):
        require(f'[node name="{side}RosterSideBanner" type="TextureRect" parent="BattleUI/ProductionHudRoot"' in scene,
                f"{side} banner is not a ProductionHudRoot child", errors)
    require('get_node_or_null("%sRosterSideBanner" % side_name)' in script,
            "banners are not connected to the collapse controller", errors)
    require("const TRANSITION_DURATION := 0.30" in script,
            "transition duration must be 0.30 seconds", errors)
    require("const PORTRAIT_SIZE := Vector2(72.0, 72.0)" in script,
            "portrait-only size must be 72x72", errors)
    require("create_tween()" in script and "Tween.TRANS_CUBIC" in script,
            "collapse controller must use a cubic Tween", errors)
    require("_apply_existing_actor_border" in script,
            "portrait-only mode must mirror the existing actor border", errors)
    require("_portrait_status_modulate" in script and "has_moved" not in script.split("func _portrait_status_modulate", 1)[1].split("func ", 1)[0],
            "portrait dimming must be based on death/deployment, not action completion", errors)
    require('"_select_ally_unit"' in script,
            "ally portrait clicks must use the existing selection function", errors)
    require("func _apply_roster_display_mode" in script,
            "display mode must be reapplied from one idempotent function", errors)
    require("roster.visible = false" in script and "roster.visible = true" in script,
            "the common expanded roster root must be explicitly hidden/restored", errors)
    require("banner.visible = true" in script,
            "persistent banner must remain visible in both display modes", errors)
    require("and not bool(_transitioning.get(side_name, false))" in script,
            "mode reapplication must not interrupt an active transition", errors)
    require("source_slot != null and unit != null" in script,
            "portrait visibility must not depend on the hidden source card", errors)
    require("_controller.call(\"_select_ally_unit\"" in script,
            "portrait selection must remain separate from roster mode changes", errors)
    require("_transitioning" in script and "if bool(_transitioning.get(side_name, false))" in script,
            "rapid banner clicks must be guarded during transitions", errors)

    # This test only asserts the declared transaction scope; git protects are checked by CI callers.
    for path in PROTECTED:
        require(path.exists(), f"protected file missing: {path.relative_to(ROOT)}", errors)

    if errors:
        print("T08 ROSTER PORTRAIT-ONLY VALIDATION FAILED")
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print("T08 ROSTER PORTRAIT-ONLY VALIDATION PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
