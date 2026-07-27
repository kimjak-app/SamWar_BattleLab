# TRANSACTION ROADMAP

## Active

### T06 Hero Stats, Initial Loyalty & WorldMap UI Integration

Status: `IMPLEMENTED / USER GODOT QA PENDING`.

This is one complete user-facing transaction covering final fixed stats, initial loyalty, mutable runtime loyalty, save compatibility, and five-stat WorldMap UI display.

Implemented scope:

- 39 final fixed-stat records regenerated from the official workbook
- 39 `initial_loyalty` definitions
- new-game seed migration into legacy hero definitions
- runtime fixed-stat migration with current loyalty preservation
- compatibility aliases for legacy `command` and `war`
- five-stat UI normalization: `지휘 / 무 / 지 / 정 / 충`
- hero list/detail/deployment label coverage through the common generated stat-line pattern
- static integration validator and transaction document

Exit gate:

- `python tools/validate_hero_design_registry.py` PASS
- `python tools/validate_hero_battle_profile_integration.py` PASS
- `python tools/validate_hero_worldmap_stat_integration.py` PASS
- Godot parse/F5 PASS
- new-game values match the final workbook
- hero list/detail/invasion-defense deployment use the five-stat format
- save/load preserves changed current loyalty
- battle entry/return and profile movement/range remain normal
- no new parse error or warning

Protected scope:

- WorldMap city/faction/troop/settlement behavior
- BattleContext and battle result accounting
- current runtime loyalty is never reset by initial loyalty during load migration
- role passives, momentum, new unique-skill execution, AI skill use, VFX, and sound remain inactive

## Complete

- T06-3 Hero Design JSON Parity & Non-Destructive Loader: `COMPLETE`
- T06-2 Hero Workbook Schema & Validator/Converter: `IMPLEMENTED`
- T06-1 Hero Data Contract: `DESIGN COMPLETE`
- T06-0 Hero Definition Registry Extraction: `COMPLETE`
- T04–T05 Korea MVP Turn Loop & Unification Completion: `COMPLETE`
- T02 Player Invasion Logistics, Battle Supply & Occupation: `COMPLETE`
- T01 Korea MVP New Game Four-Faction Selection: `COMPLETE`
- T00 Documentation & MVP Architecture Foundation: `COMPLETE`

## Next

After the current integration passes, the next transaction must activate a complete playable mechanic set rather than another helper-only milestone.

Candidate next set:

- six-unit combat passives
- eight primary-role passives
- visible UI/log evidence
- balance safeguards and integrated battle QA

Momentum, 39 new unique skills, AI skill use, cutins, cooperative attacks, and VFX follow later complete transactions. Sound effects remain the final polish step.

## Later

- Tech-tree effect integration expansion
- Talent discovery and recruitment
- China scenario
- Japan scenario
- Naval expansion

## Blocked

None confirmed.
