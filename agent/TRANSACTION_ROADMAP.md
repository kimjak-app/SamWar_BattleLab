# TRANSACTION ROADMAP

## Active

### T06-7 Hero Unique Skills & Shared Momentum

Status: `IMPLEMENTED / RUNTIME STATIC VALIDATION PASS / USER GODOT QA PENDING`.

This is one complete playable transaction covering side-shared momentum, all 39 canonical unique skills, player UI, AI use, logs, and battle save/resume.

Implemented scope:

- shared momentum start `3`, cap `10`, basic-attack gain `+1`
- commit-only skill cost with cancel/failure no-charge behavior
- 39 effect types mapped into ten resolver archetypes
- canonical Registry → Factory → BattleUnit → Resolver direction
- player momentum/cost UI and effect/resource logs
- AI resolver scoring under identical resource/target rules
- battle runtime snapshot save/restore/clear lifecycle
- runtime validator and GDScript transaction smoke

Exit gate:

- `python tools/validate_t06_t07_playable_transaction.py` PASS
- Godot parse/F5 PASS
- 39-skill resolver smoke PASS
- player/AI gain, spend, cancel, invalid target, and insufficient resource behavior normal
- battle save/resume roundtrip normal
- no new parse error or warning

Protected scope:

- WorldMap city/faction/troop/settlement behavior
- BattleContext and battle result accounting
- T01–T05 WorldMap and result accounting
- final workbook-derived hero JSON remains unchanged
- existing cutin/VFX presentation is reused
- sound remains inactive

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

- T06-7 Godot/F6 correction-only QA
- missing 39-hero cutin assets and video/light-burst presentation comparison
- six-unit and eight-role combat passives
- cooperative attacks and VFX expansion

Sound effects remain the final polish step.

## Later

- Tech-tree effect integration expansion
- Talent discovery and recruitment
- China scenario
- Japan scenario
- Naval expansion

## Blocked

None confirmed.
