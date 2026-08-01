#!/usr/bin/env python3
"""Focused structural validation for the T08-2 production battle HUD."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
SCENE = (ROOT / "Battle_Land.tscn").read_text(encoding="utf-8")
BATTLE = (ROOT / "scripts/battle_web_import_test.gd").read_text(encoding="utf-8")
ADAPTER = (ROOT / "scripts/battle/ui/battle_hud_state_adapter.gd").read_text(encoding="utf-8")

errors = []
def require(condition, message):
    if not condition:
        errors.append(message)

for name in ("ProductionHudRoot", "TopHudRoot", "AllyRosterHud", "EnemyRosterHud",
             "InteractionGuideHud", "ActorComparisonHud", "GlobalCommandHud", "BattleLogHud",
             "TooltipHud", "FacingSelectionHud"):
    require(f'name="{name}"' in SCENE, f"missing scene-authored {name}")
for side in ("Ally", "Enemy"):
    slots = re.findall(rf'parent="BattleUI/ProductionHudRoot/TopHudRoot/{side}MomentumHud/SlotRow"', SCENE)
    require(len(slots) == 10, f"{side} momentum slot count is {len(slots)}, expected 10")
    require(f'parent="BattleUI/ProductionHudRoot/TopHudRoot/{side}MomentumHud"]' in SCENE, f"missing {side} momentum root")
for side in ("Ally", "Enemy"):
    for slot in ("Slot01", "Slot02", "Slot03", "Reinforce01", "Reinforce02"):
        require(f'parent="BattleUI/ProductionHudRoot/{side}RosterHud/{slot}"]' in SCENE, f"missing {side} {slot}")
for name in ("TurnLabel", "ValueLabel", "LeftActorPanel", "CenterContextPanel", "RightSubjectPanel",
             "InstructionLabel", "DisabledReasonLabel"):
    require(f'name="{name}"' in SCENE, f"missing {name}")
require("func _refresh_production_battle_hud" in BATTLE, "production refresh entry missing")
require("BattleHudStateAdapterScript.build(self)" in BATTLE, "refresh does not consume normalized adapter state")
for field in ("turn", "max_turn", "active_side", "phase", "battle_title", "ally_momentum",
              "enemy_momentum", "ally_roster", "enemy_roster", "left_actor", "right_subject",
              "right_subject_role", "center_context", "instruction", "disabled_reason",
              "command_states", "recent_log", "battle_complete"):
    require(f'"{field}"' in ADAPTER, f"adapter field missing: {field}")
floating = re.search(r'\[node name="FloatingMoveButton".*?(?=\n\[node |\Z)', SCENE, re.S)
require(floating is not None and 'text = "방어"' in floating.group(0), "visible 이동->defend mismatch remains")
require('text = "이동"' not in (floating.group(0) if floating else ""), "floating defend handler remains labeled 이동")
require('"unit_type_name"' in ADAPTER, "adapter lacks Korean unit-type presentation mapping")
if errors:
    print("T08-2 HUD VALIDATION FAILED", file=sys.stderr)
    for error in errors:
        print(f"ERROR: {error}", file=sys.stderr)
    raise SystemExit(1)
print("T08-2 HUD VALIDATION PASS: scene hierarchy, 20 momentum slots, rosters, adapter, refresh, command mapping")
