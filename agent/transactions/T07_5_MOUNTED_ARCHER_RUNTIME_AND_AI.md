# T07-5 Mounted Archer Runtime & AI

## Status

`IMPLEMENTED / AUTOMATED VALIDATION PASS / USER F5 QA PENDING`

- The canonical mounted-archer contract is move 4, attack 1..2, move-and-attack enabled, basic damage -8%, received damage +8%, and side bonus +6%.
- `BattleUnitState` persists explicit attack-local fields: `attacked_this_turn`, `post_attack_move_available`, and `remaining_post_attack_move`; a committed mounted-archer attack grants the structured two-cell post-attack allowance.
- Unit visual/type normalization and formation labels now preserve `mounted_archer` as `궁기병`; absent dedicated visual assets retain a safe infantry-template fallback without changing the canonical unit type.

## Validation

- `tools/validate_mounted_archer_runtime_and_ai.py`
- Godot `Battle_Land` load passed.
