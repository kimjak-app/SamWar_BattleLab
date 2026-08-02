# CURRENT STATE

## Video Cutin Hotfix 3 — canonical hero identity and 13-hero audit

- The cutin authority is `scripts/ui/cutin/korea_mvp_hero_cutin_registry.gd::canonicalize_hero_id()`. Legacy runtime IDs `yi_sunsin`, `jeong_dojeon`, `gim_yusin`, and `gwon_yul` normalize before the committed caster/skill parity gate and before registry, portrait, title, and video lookup.
- The 13 Korea MVP contract is Yi Sun-sin, Uija Wang, Kim Yu-sin, Kim Chun-chu, Jeong Do-jeon, Jang Bo-go, Heukchi Sangji, Gyebaek, Kwon Yul, Gwanggaeto, Eulji Mundeok, Dorim, and Cheok Jun-gyeong. Every registered OGV/title/portrait loads and starts through `HeroCutinPresentation` in the Godot scene-tree test; static fallback is false. Kwon Yul retains its existing legacy portrait path, without copying or renaming assets.
- Guan Yu remains intentionally unregistered and takes the normal static fallback with no unrelated video. Turn scheduler, supply, UI geometry, Theme, fonts, `Battle_Land.tscn`, and the Production HUD remain unchanged by the hotfix.
- Status: `VIDEO CUTIN HOTFIX3 IMPLEMENTED / CANONICAL ID CONTRACT PASS / ALL 13 KOREA MVP CUTINS PLAYBACK PASS / USER F5-F6 QA PENDING`.

## Runtime Hotfix 2 — actual hero video cutin playback

- The first cutin hotfix passed registry/resource checks but user F5 still selected the static path. The actual static texture is assigned by `_show_unique_skill_toast_over_unit()` through `_get_unique_skill_cutin_texture()`; for Yi Sun-sin it is `res://assets/web_battle/skill_cutins/yi_sunsin_hakikjin.png`, not a reinforcement/ready flag.
- The root was pair-only runtime aliasing: actual WorldMap payloads can combine canonical hero IDs with runtime skill IDs. Registry normalization now resolves hero and skill IDs independently before lookup.
- `HeroCutinPresentation/CutinStage/VideoBackgroundPlayer` now has an actual test covering stream assignment, `play_cutin()`, two processed frames, and `VideoStreamPlayer.is_playing()` for Yi runtime, Yi mixed canonical/runtime, and Kwon Yul requests. `[CUTIN_TRACE]` records each F5 route and explicit fallback reason.
- Status: `VIDEO CUTIN HOTFIX2 IMPLEMENTED / ACTUAL PLAYBACK TEST PASS / USER F5 QA PENDING`. Turn-order F5 QA PASS remains protected; UI work stays paused.

## T08 Runtime Emergency Hotfix — alternating initiative and registered video cutins

- T08-3C visual QA exposed two runtime regressions; all T08 visual work is paused pending user F5 turn/cutin QA. Current-action width, lower HUD, Theme, font, and test-only Preview geometry remain untouched.
- Cause 1: `c0949a9` changed each enemy completion into `_advance_enemy_turn_or_return_to_ally()`, which deferred the next enemy actor; its `_return_to_ally_turn()` guard also redirected control back to the enemy while any enemy remained. The restored boundary returns after one enemy actor and starts a new Battle Turn only after both valid sides complete.
- Cause 2: runtime requests (`yi_sunsin/hakikjin_barrage`, etc.) did not match the registered canonical IDs (`yi_sun_sin/yi_sun_sin_unique`, etc.). The registry miss entered the legacy static toast path. Registry-bound aliases now route registered heroes to their existing OGV/title resources first; reinforcement/ready-flag resources are not registry fallbacks.
- New Python and Godot regression checks cover 3v3, 3v2, 2v3, unavailable-actor sequencing, round/supply boundary, and five runtime hero OGV loads. Status: `RUNTIME HOTFIX IMPLEMENTED / AUTOMATED VALIDATION PASS / USER F5 QA PENDING`.

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

## T08-3A Battle UI Theme & Font First Pass

- T08-2B and hotfix1 user F5 QA passed: the runtime legacy scene is normal, including its restored central-top momentum HUD.
- T08-3A is isolated to `tests/scenes/Battle_UI_Production_Test.tscn`. `assets/ui/battle_ui_theme.tres` applies NotoSerifKR Bold, Medium, and Regular to the three top Production HUD panels only.
- Static Theme variations cover panels, title/value/secondary labels, slot row spacing, and ally/enemy filled/empty slots. User F6 visual approval remains pending; do not start T08-3B.
- No before/after screenshot was captured by the headless validation run; user F6 at 1920×1080 is the visual comparison record for this first pass.

## T08-3A-hotfix1 Top HUD Alignment & Density Polish

- User F6 feedback is reflected in the Production test scene only: top-HUD titles, slot rows, and values are center aligned; Turn HUD is compacted to 300×88; panel background alpha is reduced to 0.84.
- Static validators and Godot project/test-scene headless load passed. User F6 recheck is pending; T08-3B remains unstarted.

## T08-3B Emergency Isolation Rollback

- T08-3B's shared `battle_hud_state_adapter.gd` and `battle_web_import_test.gd` changes affected both the Production test scene and the F5 runtime `Battle_Land` presentation despite no `Battle_Land.tscn` diff.
- Reverted the three remote-main T08-3B commits (`f525c8b`, `27fb7d1`, `227bcd9`) with safe revert commits. The adapter, battle script, Production test scene, and Theme exactly match the T08-3A-hotfix1 baseline `84c8b44`.
- T08-3B is incomplete and frozen. Await user F5/F6 recovery QA; any future roster work requires a fully test-scene-isolated styling path designed by ChatCoach.

## T08-3B0 Production Roster Legacy Content Parity

- The Production test scene now mirrors the legacy roster information contract only: `Portrait`, `NameLabel`, `HpLabel`, `TroopIconRect`, and `TroopTypeLabel` are the default card content; `StatusLabel` and `UniqueSkillReadyIcon` are conditional and default hidden.
- `TroopBar`, `ActionStateLabel`, and `UniqueSkillReadyLabel` remain as protected existing test NodePaths but are default hidden, so the test scene no longer shows repetitive non-legacy status text.
- `tests/scripts/battle_ui_production_test_roster.gd` is attached only to the Production test scene and reads existing battle state/visual resolvers without changing shared runtime scripts, Theme, or `Battle_Land.tscn`. The T08-3A top HUD is unchanged.
- Static validators and Godot project/runtime/test-scene loads pass. User F6 structure QA is pending; T08-3B1 Theme/Font work has not started.

## T08-3B1 Production Roster Theme & Font

- User F6 confirmed the T08-3B0 roster content structure. T08-3B1 applies only Production-roster Theme variations in `assets/ui/battle_ui_theme.tres` and `tests/scenes/Battle_UI_Production_Test.tscn`.
- Hero names use NotoSerifKR Bold 19; troop values use Medium 15; troop types use Medium 14. Ally panels/cards use low-saturation blue-black at alpha 0.78/0.70; enemy panels/cards use dark red-brown at alpha 0.78/0.70, with 1px subdued borders.
- Existing portrait and troop-icon resources/geometry remain unchanged. No selected-card variation was added because the protected test-only bridge has no safe selection-presentation signal; selection styling remains deferred.
- `Battle_Land.tscn`, shared battle scripts, bridge data logic, and the locked T08-3A top HUD are unchanged. Automated validators and Godot headless loads pass; user F6 visual QA is pending. T08-3C has not started.

## T08-3B1-hotfix1 Legacy Status Placement

- User F6 visual QA found `StatusLabel` overlapping the right-bottom `TroopTypeLabel` in the Production roster. The test scene now places every status row at `80, 66–188, 88`: below troop values on the left, with the locked troop-type area beginning at x=196.
- The test-only bridge now reads the existing legacy formatter, preserving strings such as `◆ 방어 태세` without changing status calculation, combat state, or shared scripts.
- Status uses the existing NotoSerifKR Medium 13 variation and remains default hidden. All 10 cards use the same geometry; panels, cards, portraits, troop icons/types, T08-3A top HUD, and `Battle_Land.tscn` are unchanged.
- Automated validators and Godot headless loads pass. User F6 status QA is pending; T08-3C has not started.

## T08-3C Bottom HUD Theme, Font & Supply Preview

- T08-3B1-hotfix1 user F6 QA PASS is recorded as the entry gate. T08-3C is isolated to `tests/scenes/Battle_UI_Production_Test.tscn`, `assets/ui/battle_ui_theme.tres`, and `tests/scripts/battle_ui_production_test_bottom_hud.gd`.
- The lower information layout is left `BattleLogHud`, center `ActorComparisonHud` with `InteractionGuideHud`, and right `BottomHudRoot/BattleSupplyPreviewPanel`.
- The Preview uses normal test-only samples: turn `3 / 30 · 잔여 27`, ally `820/120/34/24`, enemy `740/80/31/23`. `SHOW_WARNING_SAMPLE` provides a default-off salt-warning visual check.
- Battle_Land, BattleSupplyRuntime, WorldMap context, shared scripts, top HUD, and rosters are unchanged. Status: `T08-3C IMPLEMENTED / AUTOMATED VALIDATION PASS / USER F6 BOTTOM HUD VISUAL QA PENDING`.
