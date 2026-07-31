# T07-3 Shared Movement, Range, Counterattack & Action Eligibility

## Status

`IMPLEMENTED / AUTOMATED VALIDATION PASS / USER F5 QA PENDING`

## Contract

- `UnitTypeContract` is the common movement, min/max-range, counterattack-range, action-eligibility, and damage-context authority.
- `BattleUnitState` derives move and maximum attack range from that authority and snapshots action-local mounted-archer fields.
- Manual target checks and AI target selection both use `is_unit_in_attack_range()`, which delegates to `UnitTypeContract.can_unit_attack()`.
- Movement records origin, destination, and Manhattan moved distance in `last_action`; invalid target selection does not alter action flags.
- Gunner movement is therefore rejected before target-selection and never consumes an action. Counterattack remains metadata-driven rather than copied from attack range.

## Validation

- `tools/validate_five_unit_type_action_eligibility.py`
- Godot project parse passed.
