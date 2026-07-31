# T07-7 UI, Visual Resource, Persistence & Full QA

## Status

`IMPLEMENTED / AUTOMATED VALIDATION PASS / USER F5 QA PENDING`

- `BattleUITextFormatHelper` centralizes canonical Korean type names: 보병, 기병, 궁병, 총병, 궁기병. `support` is not a unit type.
- Runtime battle snapshots include gunner status effects plus mounted-archer post-attack movement state.
- The existing visual template fallback remains safe when a dedicated mounted-archer asset is unavailable; the canonical `unit_type` is never changed for fallback.
- Canonical visual metadata now resolves Japan gunner to `japan_gunner_01.png` and Mongol mounted archer to `mongol_horse_archer.png`; both source files and `.import` records are verified.

## Automated QA

- Five T07 validators pass.
- Godot project parse, `Battle_Land.tscn`, and `WorldMap.tscn` headless loads pass.

## User F5 QA

- Korea: infantry/cavalry/archer move and attack; multi-actor AI; unique skill/cutin/momentum; result return to WorldMap.
- Gunner: stationary prepared fire; moved-fire rejection; penetration and post-fire penalty text; AI never fires after moving.
- Mounted archer: move then fire; at-most-two-cell post-attack relocation; no second attack; AI keeps range; snapshot restore retains relocation state.
