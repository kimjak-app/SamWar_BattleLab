# T06-9 Hero Data Parity

Status: `IMPLEMENTED / STATIC VALIDATION PASS / USER GODOT QA DEFERRED`

## Goal

Lock one canonical hero identity and mutable-state flow across:

`WorldMap → city/formation → battle context → BattleUnitState → battle result → WorldMap return → save/load`

## Implemented

- WorldMap battle-context hero records are rebuilt through `HeroRuntimeFactory.build_runtime_hero` before legacy presentation and tech modifiers are added.
- Canonical leadership, martial, intelligence, politics, unit type, movement, attack range, role, and unique-skill authority remain protected by the Factory/BattleUnit path.
- Battle results now include explicit `attacker_hero_outcomes` and `defender_hero_outcomes` keyed by canonical hero ID.
- Each outcome records survival, current/max HP, current/max troops, allocated troops, unit type, and unique-skill ID.
- T02 player-attack return settles every participating attacker, not only surviving IDs.
- Surviving heroes return as normal; defeated heroes return as wounded with recovery turns instead of remaining `deployed` without a city.
- Generic invasion/result handling consumes explicit hero outcomes and only uses the old placeholder behavior for legacy result payloads.
- Last-battle troop values and transaction ID are stored in mutable hero runtime state and therefore survive normal save migration.
- Typed-array fallback for outcome IDs was corrected in hotfix1.

## Compatibility

- Existing city ownership, troop settlement, wounded troop queues, cargo return, and T01–T05 transaction accounting remain unchanged.
- Legacy battle-result payloads without hero outcomes continue through the previous compatibility path.
- Canonical generated hero JSON is unchanged.

## Validation

- `tools/validate_hero_design_registry.py` PASS
- `tools/validate_t06_t07_playable_transaction.py` PASS
- T06-9 parity token/contract validation PASS
- `git diff --check` PASS
- GitHub runner Godot step is conditional; user F5 QA is deferred.

## Commits

- Main implementation: `4566fb66713826bf889ee93a086dd8b4d943f1ee`
- Typed outcome ID correction: `a711c5e4e1832fd8155e9f78143b909ede25e8d5`
