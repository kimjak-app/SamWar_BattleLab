# P-1C | ISO Battle Production Promotion

Date: 2026-09-19
Branch: `refactor/production-runtime-unification-20260919`

## Implemented

### Canonical production scene
- Added `scenes/battle/Battle_Production.tscn`.
- Promoted the accepted Production HUD tree out of `tests/scenes/Battle_UI_Production_Test.tscn`.
- Removed all `res://tests/` script dependencies from the player-facing scene.
- Removed `battle_supply_hud_mock.gd`.

### Production behavior controller
- Added `BattleProductionController`.
- Promoted generic behavior previously mixed into the Imjin QA controller:
  - post-skill manual reposition;
  - optional reposition skip during full-auto;
  - cutin input blocking;
  - overlay/status resync;
  - safe active-ally camera focus;
  - generic status-display behavior.
- Kept Imjin roster, nation and portrait fixtures under tests.

### ISO production presentation
- Added `BattleIsoProductionController`.
- Promoted:
  - ISO grid projection;
  - ISO move-range tiles/highlights;
  - ISO facing arrows/indicators;
  - enemy tactical overlay suppression;
  - legacy READY-frame retirement;
  - stable unit visual scale.

Logical combat grid/path/facing authority remains inherited and unchanged.

### Production HUD helpers
Promoted out of tests:
- roster HUD content controller;
- current-actor HUD binding controller;
- roster collapse/top-action presentation controller;
- auto-turn camera guard;
- empty-status legend;
- `CurrentActorInfoHud.tscn`.

### Real supply data
The latest Production `BattleSupplyHud` no longer uses mock values.

The shared battle controller now writes the existing real `BattleSupplyRuntime` data into the new HUD:
- food type / amount;
- salt;
- food/salt consumption;
- sustain turns.

If the Production supply panel exists, the old T02 panel stays hidden. Older scenes without the Production panel retain the T02 fallback.

## Battle_Main

`scenes/battle/Battle_Main.tscn` now instances:

`res://scenes/battle/Battle_Production.tscn`

This makes Battle_Main the QA target for the current Production ISO battle.

## Not switched yet

WorldMap still enters:

`res://Battle_Land.tscn`

That is intentional. P-1D will change the actual game entry only after Battle_Main passes Godot runtime QA.

## Runtime QA gate

Run `scenes/battle/Battle_Main.tscn` directly and confirm:
1. latest ISO battlefield;
2. Production top HUD/turn/momentum;
3. left/right rosters and collapse;
4. current actor HUD;
5. move range and facing UI;
6. unique skill/cutin;
7. enemy auto turn;
8. top action buttons;
9. battle log;
10. no duplicate legacy READY frames;
11. no parse/runtime errors.

For real supply/BattleContext verification, P-1D WorldMap handoff QA is required after the direct Battle_Main smoke check.
