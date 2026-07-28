# TRANSACTION ROADMAP

## Active

### T06-9 Hero Data Parity

Status: `IMPLEMENTED / STATIC VALIDATION PASS / USER GODOT QA DEFERRED`.

Implemented scope:

- canonical WorldMap → formation → battle payload authority
- explicit attacker/defender per-hero battle outcomes
- defeated participating heroes return wounded instead of remaining orphaned in deployed state
- surviving heroes return normal with city/faction identity preserved
- legacy result-payload compatibility
- mutable last-battle result fields preserved by save migration

Exit gate:

- `python tools/validate_hero_design_registry.py` PASS
- `python tools/validate_t06_t07_playable_transaction.py` PASS
- T06-9 parity contract validation PASS
- Korea MVP F5 save/return QA deferred by user

## Complete

- T06-8 Unique-Skill Battle Calculation: `IMPLEMENTED / STATIC PASS`
- T06-7 Hero Unique Skills & Shared Momentum: `IMPLEMENTED`
- T06-3 Hero Design JSON Parity & Non-Destructive Loader: `COMPLETE`
- T06-2 Hero Workbook Schema & Validator/Converter: `IMPLEMENTED`
- T06-1 Hero Data Contract: `DESIGN COMPLETE`
- T06-0 Hero Definition Registry Extraction: `COMPLETE`
- T04–T05 Korea MVP Turn Loop & Unification Completion: `COMPLETE`
- T02 Player Invasion Logistics, Battle Supply & Occupation: `COMPLETE`
- T01 Korea MVP New Game Four-Faction Selection: `COMPLETE`
- T00 Documentation & MVP Architecture Foundation: `COMPLETE`

## Next

### T06-10 Hero Cutin & Battle Presentation

- T06-10A standalone Gwanggaeto two-image preview: `PREVIEW VISUAL HOTFIX IMPLEMENTED / USER VISUAL QA PENDING`.
- This is an experiment-only step; it does not mark T06-10 complete or connect a battle call path.
- audit existing 39-hero portrait, title, video, and cutin assets
- compare video-background and light-burst presentation samples
- lock shared cutin timing and fallback presentation
- produce and connect missing Korea MVP hero assets first
- expand to China/Japan heroes after scenario activation

Correction-only T06-8/T06-9 QA may interrupt this sequence only for confirmed Godot runtime defects.

## Later

- six-unit and eight-role combat passives
- cooperative attacks and VFX expansion
- tech-tree effect integration expansion
- talent discovery and recruitment
- China scenario
- Japan scenario
- naval expansion

Sound effects remain the final polish stage.

## Blocked

None confirmed.
