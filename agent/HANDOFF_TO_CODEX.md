# HANDOFF TO CODEX

Before making changes, read:
1. `agent/GODOT_RULES.md`
2. `agent/CURRENT_STATE.md`
3. `agent/NEXT_TASKS.md`

## Stable Baseline
- Current stable baseline is `v0.64y Ally Ready Frame + Unit Selection Close-up Panel Verified`.
- Do not treat `v0.65` as reached yet.

## Core Scene And Script
- Core scene: `Battle_Fullscreen_Test.tscn`
- Core script: `scripts/battle_web_import_test.gd`

## Current Battle Loop
1. One ally actor acts
2. One enemy AI actor acts
3. Remaining ally actor acts
4. Remaining enemy AI actor acts
5. New round starts

Current 2v2 setup:
- Ally: 이순신, 정도전
- Enemy: 관우, 장비

## Verified Current Features
- Ally selection for 이순신 / 정도전
- Movement
- Post-move facing selection
- Right-click move rollback during facing select
- Basic attack button -> attack range display -> click 관우 / 장비 to attack
- Right-click attack cancel
- HP 0 cleanup
- 관우 / 장비 alternating enemy AI
- READY frame for available allies
- `UnitCloseupPanel` for selected ally

## Main Working Principles
- Scene controls layout
- Code controls behavior
- Godot 2D editor placement -> `Ctrl+S` -> `F6` reflection

## Do Not Break
- Do not bump to `v0.65`
- Do not change `attack_range`
- Do not change `move_range`
- Do not change `distance formula`
- Do not overwrite unit size / placement by code
- `UnitCloseupPanel` position must remain scene-authored
- `READY frame` must not block clicks
- Preserve right-click rollback / attack cancel behavior
- Preserve current ally / enemy turn order

## Recommended Next Task
- `v0.64z Battle UX Polish / Round Toast Image Slot`
- Add a scene-authored `TextureRect` slot so the current center round text banner can later be swapped to an image banner.
- Keep current text banner behavior stable while adding that slot.
