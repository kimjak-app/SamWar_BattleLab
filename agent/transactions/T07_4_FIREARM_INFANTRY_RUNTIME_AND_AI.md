# T07-4 Firearm Infantry Runtime & AI

## Status

`IMPLEMENTED / AUTOMATED VALIDATION PASS / USER F5 QA PENDING`

- Gunner uses the canonical move-2, range-1..3, no-move-and-fire contract for player and AI target eligibility.
- A valid stationary basic shot receives the structured +15% prepared-fire modifier, carries the structured 20% armor-ignore context, and commits a one-turn 40% post-fire penalty only after the shot commits.
- Logs use Korean messages: `준비 사격`, `방어 관통`, and `발사 후 화력 저하`.
- AI shares the same `is_unit_in_attack_range()` eligibility path, so a moved gunner cannot fire in the same actor turn.

## Validation

- `tools/validate_gunner_runtime_and_ai.py`
- `Battle_Land.tscn` headless load passed.
