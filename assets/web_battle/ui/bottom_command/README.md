# Bottom Command Bar Art Asset Prep

This folder is reserved for the bottom global command bar button art.

## Planned asset filenames
- `bottom_cmd_auto_normal.png`
- `bottom_cmd_auto_pressed.png`
- `bottom_cmd_end_turn_normal.png`
- `bottom_cmd_end_turn_pressed.png`
- `bottom_cmd_retreat_normal.png`
- `bottom_cmd_retreat_pressed.png`

## Recommended specs
- same size for all buttons
- transparent PNG
- normal / pressed state pair
- ink wash / ink splash style
- recommended first test size: `256x96` or `240x96`

## Text strategy
- baked text in the image is allowed for fixed-label buttons
- Godot label overlay strategy is recommended when runtime text can change
- `AutoBattleButton` currently swaps between `자동전투` and `자동중지`, so overlay text is safer than baking a fixed label into the art

## Current integration status
- existing handlers are reused
- current nodes are scene-authored `TextureButton` controls
- PNGs are connected directly in `Battle_Fullscreen_Test.tscn`
- `RetreatButton` remains a disabled placeholder while still showing button art

## Current runtime mapping target
- `AutoBattleButton` -> `bottom_cmd_auto_normal.png` / `bottom_cmd_auto_pressed.png`
- `EndTurnButton` -> `bottom_cmd_end_turn_normal.png` / `bottom_cmd_end_turn_pressed.png`
- `RetreatButton` -> `bottom_cmd_retreat_normal.png` / `bottom_cmd_retreat_pressed.png`
