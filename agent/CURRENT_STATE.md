# CURRENT STATE

## Latest protected implemented stage

### T07 Five Unit-Type Battle Completion

Status: `IMPLEMENTED / AUTOMATED VALIDATION PASS / DEDICATED VISUALS BOUND / USER F5 QA PENDING`

- Canonical unit types are infantry, cavalry, archer, gunner, and mounted_archer.
- Shared movement/range/action eligibility, gunner runtime, mounted-archer runtime, manual/auto damage parity, persistence, and Korean labels are implemented.
- Dedicated gunner and mounted-archer token resources are connected through canonical visual metadata.
- Korea production roster assignments remain unchanged.

## T08 design baseline

### T08-1 Battle UI/UX Current-State Audit & Production Information Architecture Design

Status: `AUDIT COMPLETE / PRODUCTION IA LOCKED`

Authoritative documents:

- `agent/transactions/T08_1_BATTLE_UI_UX_CURRENT_STATE_AUDIT_AND_PRODUCTION_INFORMATION_ARCHITECTURE_DESIGN.md`
- `agent/plans/T08_BATTLE_UI_UX_PRODUCTION_PLAN.md`
- `agent/plans/KOREA_MVP_BATTLEFIELD_ART_MASTER_PLAN.md`
- `agent/plans/T09_BATTLEFIELD_TERRAIN_HANDOFF_PLAN.md`

Locked production direction:

- 1920×1080 production UI.
- Top HUD separates ally momentum `current / 10`, battle turn `current / 30`, and enemy momentum `current / 10`.
- Left ally roster and right enemy roster.
- Bottom current actor / next AI / selected target / counterattack comparison HUD.
- Hanseong is the single master template before Sabi, Gyeongju, and Pyongyang.
- Defender role maps to city/fortress and attacker role maps to temporary camp independently of player/AI identity.
- T08 presentation remains separate from T09 terrain mechanics.

## Current implementation state

### T08-2 Scene-Authored Production HUD Skeleton & UI State Adapter

Remote implementation commit:

- `6b648369dc3b6f1e5d419c97acbe56ece79f9d0e`
- `feat: add production battle HUD skeleton and state adapter`

Status: `IMPLEMENTED / STATIC VALIDATORS PASS / USER F6 QA FAIL / HOTFIX REQUIRED / FINAL ART DEFERRED`

User F6 evidence:

- Godot reported 148 scene-instantiation errors.
- `ProductionHudRoot` descendants reported cascading `Parent path ... has vanished` messages.
- The production HUD overlapped itself and the legacy HUD.
- Large empty translucent panels obscured the battlefield.
- Top momentum/turn/title text was unreadable because of overlap.
- Legacy top/roster/log surfaces remained visible together with production surfaces.
- GDScript warned that local variable `visible` shadows the inherited `CanvasItem.visible` property.

Confirmed remote code defects:

- `Battle_Land.tscn` contains a standalone `+` line immediately before the `ProductionHudRoot` node declaration.
- `scripts/battle_web_import_test.gd` declares `var visible := ...` inside production roster refresh and then writes `slot.visible = visible`.
- The focused validator checks node-name strings and slot counts but does not reject malformed standalone scene lines, validate parent declaration order, or detect the shadowing declaration.

The 148 messages are treated as a cascading scene-instantiation failure, not as 148 independent feature defects.

## Immediate next transaction

### T08-2-hotfix1 Production HUD Scene Recovery, Layout & Legacy Visibility Correction

Status: `IMPLEMENTED / AUTOMATED STATIC VALIDATION PASS / USER F6 RETEST PENDING`

Required order:

1. Repair `Battle_Land.tscn` parse/instantiation integrity and remove all cascading vanished-parent errors.
2. Remove the `visible` shadowing warning without changing behavior.
3. Strengthen `validate_t08_2_production_hud.py` so malformed scene syntax and invalid parent order cannot pass.
4. Correct 1920×1080 production HUD bounds, initial visibility, and legacy/new-surface duplication.
5. Preserve T01–T07 gameplay, cutins, AI, battle calculations, save/resume, WorldMap handoff, and all protected validators.
6. Stop before T08-3 final UI graphics or Hanseong battlefield integration.

Hotfix1 evidence:

- Removed the standalone patch-marker line that invalidated the production HUD parent tree.
- Renamed the production roster local `visible` identifier to `should_show_slot`.
- Added production parent/declaration-order, malformed-line, default-visibility, layout-bound, legacy-parity, and shadowing checks to the focused validator.
- Local Godot headless launch remains unavailable from this execution environment; user F6 retest is required.

Authoritative execution instruction:

- `agent/HANDOFF_TO_CODEX.md`

## Protected baseline

- T01–T05 Korea Four-City MVP campaign contracts remain protected.
- T06 hero authority, unique skills, momentum, cutins, Korean display, portraits, result settlement, save/load, and enemy multi-actor flow remain protected.
- T07 five-unit-type behavior and values remain protected until T11 unless a reproducible defect requires correction.
- Momentum starts at `3` and is capped at `10`.
- Maximum battle turn remains `30`.
- Generated hero data remains authoritative.
- Player and AI continue to share canonical action and calculation paths.
- No T09 terrain rule or T10 tactic is added during this hotfix.

## Authoritative roadmap

- `agent/plans/T07_T11_BATTLE_ENGINE_MVP_COMPLETION_ROADMAP.md`

## T08-2B Legacy Battle Scene Recovery

- Runtime `Battle_Land.tscn` is restored to the supplied pre-T08 legacy HUD layout while retaining the current resource set, five-unit battle nodes, cutin/result/toast nodes, and the latest floating defend label.
- The T08 Production HUD is isolated in `tests/scenes/Battle_UI_Production_Test.tscn`; F5 stays on the WorldMap -> `Battle_Land.tscn` path and F6 of the test scene is the T08 visual-development path.
- Production HUD access is already optional in `battle_web_import_test.gd`, so the runtime scene safely uses legacy UI when that root is absent.
- Static validators pass; the configured local Godot executable is unavailable, so Godot/F5/F6 QA remains pending. T08-3A has not started.

## T08-2B-hotfix1 Legacy Momentum HUD Recovery

- User F5 confirmed the legacy battle layout except its central-top momentum display. Audit established that it was an existing runtime-created HUD, not a node removed from the supplied backup scene.
- `_configure_momentum_ui()` now restores that existing runtime HUD only when `ProductionHudRoot` is absent. The Production test scene remains unchanged and continues to use its scene-authored T08 momentum HUD.
- Momentum calculations, save/restore, and the 3/10 contract are unchanged. User F5 verification of the restored central-top ally/enemy values remains pending.
