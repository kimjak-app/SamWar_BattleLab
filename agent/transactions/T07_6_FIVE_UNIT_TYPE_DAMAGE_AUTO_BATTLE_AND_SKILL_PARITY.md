# T07-6 Five Unit-Type Damage, Auto-Battle & Skill Parity

## Status

`IMPLEMENTED / AUTOMATED VALIDATION PASS / USER F5 QA PENDING`

- Manual tactical damage and automatic battle matchup queries call `UnitTypeContract.get_damage_context()` rather than maintaining separate matchup tables.
- The common context carries attacker/defender unit type, base and received modifiers, matchup, armor ignore, and side/rear type modifier while preserving existing 1.15 side and 1.30 rear multipliers.
- Automated battle normalizes legacy `gunpowder` only to canonical `gunner`, rejects unknown values from dominance selection, and covers all 39 hero profiles.
- Unique-skill and momentum contracts were not changed.

## Validation

- `tools/validate_five_unit_type_damage_auto_battle_and_skill_parity.py`
