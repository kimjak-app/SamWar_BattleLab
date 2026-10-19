# Battle Runtime Refactor Plan

Status: Approved design baseline for the next battle refactor track.
Repository: `kimjak-app/SamWar_BattleLab`
Working branch at the time of approval: `recovery/worldmap-iso-sfx-services-20260912`
Plan revision: `BRP-20260919-1`

## Fast-resume rule

This file is the architecture/status source of truth, not a per-task execution checklist.

- Read it in full once when entering the Battle Runtime Refactor track or when the `Plan revision` changes.
- For consecutive B-1x tasks on the same revision, read only Sections 11–13 plus the active task audit/brief and any specifically relevant invariant section.
- A per-task brief should declare this plan revision and must not require a full reread of this document when the revision is unchanged.
- Execution/preflight/validation/closeout mechanics belong to `.agents/skills/samwar-dev/SKILL.md`, not to this plan.

## 1. Core decision

Do **not** refactor the current battle code while continuing to treat `*_Test` files as the production runtime.

Before the large battle refactor begins, separate the real battle runtime from test/scenario/QA layers.

The target relationship is:

```text
Production battle runtime = the authoritative battle implementation
		↓
Scenario / smoke / movement / skill / AI / visual QA tests = consumers or subclasses of production
```

The current direction must move away from:

```text
Test scene/script = de facto production runtime
		↓
more Test scenes/scripts inherit from it
```

## 2. Current observed hierarchy

Current scene chain:

```text
tests/scenes/Battle_UI_Production_Test.tscn
	↓
tests/scenes/Battle_UI_Production_Imjin_Test.tscn
	↓
tests/scenes/Battle_UI_Production_Imjin_IsoMovement_Test.tscn
```

Current script chain:

```text
scripts/battle_web_import_test.gd
	↓
tests/scripts/battle_ui_production_imjin_test.gd
	↓
tests/scripts/battle_ui_production_imjin_iso_movement_test.gd
```

Important interpretation:

- `Battle_UI_Production_Test.tscn` and `battle_web_import_test.gd` currently act much more like a real battle base/runtime than ordinary tests.
- `battle_ui_production_imjin_test.gd` is scenario-specific. It should remain an Imjin scenario fixture/extension, not become the generic battle engine.
- `battle_ui_production_imjin_iso_movement_test.gd` currently contains presentation experiment code on top of the inherited logical battle rules. Generic ISO functionality that becomes part of the actual game must eventually move out of `tests/` and into production battle modules.

## 3. When to remove the `Test` role from real battle code

The correct timing is **before the major battle runtime refactor**, not after it.

Approved sequence:

```text
B-0A Test Inventory & Ownership
	↓
B-0B Create canonical Production Battle runtime/skeleton
	↓
B-0C Promote generic battle + ISO runtime responsibilities from tests to production
	↓
B-1+ Refactor the production battle runtime by responsibility
	↓
Parity verification against the existing battle tests
	↓
Switch WorldMap battle entry to the canonical production battle scene
```

Do not wait until every refactor is complete before creating the production runtime. The production/runtime boundary must exist first so that later refactors have a clear owner.

## 4. Target production structure

Names can be adjusted during implementation, but the ownership model should be approximately:

```text
scenes/battle/Battle_Main.tscn
scripts/battle/battle_controller.gd
scripts/battle/... dedicated controllers/services/helpers
```

`Battle_Main.tscn` becomes the single canonical battle scene used by the actual game.

The battle controller should become an orchestration/wiring owner, while concrete responsibilities move into focused modules as needed.

Likely responsibility families to audit/extract include:

- turn / phase orchestration
- player action flow
- movement / path / facing
- attack / targeting / range
- skill execution
- AI turn execution
- unit runtime state
- battle result / victory / retreat
- reinforcement / formation
- HUD / presentation wiring
- camera / animation / cut-in orchestration
- ISO projection / overlay presentation

This is an audit list, not a mandate to create one file per bullet. Reuse existing clear owners before creating new files.

## 5. Test topology after promotion

Keep multiple tests. Do **not** merge all tests into one scene.

Target shape:

```text
tests/
  battle_smoke_test
  imjin_scenario_test
  movement_test
  skill_test
  ai_turn_test
  cutin_visual_qa
  sfx_preview
  other focused regression/QA tests
```

Tests should verify production behavior rather than secretly contain the only authoritative implementation of that behavior.

## 6. What should move to production

Move/promote code when it is a generic rule or runtime responsibility used by the real game, such as:

- turn progression
- unit state
- movement and attack execution
- AI invocation/orchestration
- skill execution
- victory/result handling
- production HUD wiring
- generic camera/animation sequencing
- generic ISO projection and overlay behavior once confirmed as the final battle presentation

If generic ISO helpers are currently under `tests/scripts/`, promote them to the production battle domain when they become part of the actual game.

Examples currently used by the ISO test that must be audited for promotion:

- `battle_iso_grid_projection.gd`
- `battle_iso_range_overlay_tile.gd`
- `battle_iso_facing_arrow_tile_button.gd`
- `battle_iso_facing_indicator_label.gd`

Promotion does not mean blindly moving every file. Only generic production responsibility moves.

## 7. What should stay in tests / QA

Keep test-specific/scenario-specific code out of production, including:

- Imjin-only hero roster / scenario identity
- Imjin-only camera guards or scenario patches
- authored test fixtures
- forced QA states
- cut-in visual QA harnesses
- SFX preview harnesses
- experimental-only overrides that are not accepted game behavior
- temporary diagnostics / markers

`battle_ui_production_imjin_test.gd` should remain a scenario layer unless a specific piece of its behavior proves generic and is explicitly promoted.

## 8. ISO decision

The current ISO movement test is no longer treated as disposable merely because its filename contains `Test`.

It is the current candidate presentation direction for the actual SamWar battle screen.

However:

- logical battle rules remain authoritative and must not be changed merely to satisfy projection code;
- presentation-only ISO code should be separated from combat rules;
- generic ISO behavior should be promoted to production;
- Imjin-specific or experiment-only overrides remain in tests;
- parity with the existing logical battle behavior must be verified before switching the game entry point.

## 9. WorldMap integration rule

Do **not** immediately change WorldMap battle entry to the new `Battle_Main.tscn` as soon as the production skeleton is created.

First confirm parity for:

- battle context intake
- unit/hero deployment
- player/enemy turn order
- movement/attack/skill behavior
- AI behavior
- battle result output
- retreat/victory/defeat paths
- return to WorldMap
- wounded/recovery/result settlement integration

Only after these are green should WorldMap use the canonical production battle scene.

## 10. B-0 execution plan

### B-0A | Test Inventory & Ownership

Classify every battle-related scene/script as one of:

- Core/runtime candidate
- Scenario fixture
- Presentation experiment
- QA/regression test
- Legacy/dead candidate

Deliverable: ownership map and promotion list.

### B-0B | Canonical Production Battle Skeleton

Create the production battle scene/runtime boundary without changing battle behavior.

Do not delete the existing tests.
Do not switch WorldMap yet.
Do not redesign rules or balance.

### B-0C | Production Promotion / Parity Bridge

Move only confirmed generic runtime responsibilities from the current test hierarchy into production ownership.

Keep compatibility bridges thin where necessary.
Run old and new paths side-by-side or through focused parity tests until equivalent.

## 11. B-1 and later refactor rule

After B-0, refactor **the production runtime**, not the test hierarchy.

`battle_web_import_test.gd` is the main god-script candidate to audit. Its responsibilities should be separated gradually with checkpoints and regression tests, similar in discipline to the completed WorldMap refactor but not by blindly copying the same boundaries.

Battle refactoring is more sequencing-sensitive than WorldMap because input, turn order, AI, animation, timers, skills, movement, and scene state interact tightly.

Therefore:

- preserve call order;
- preserve signal timing;
- preserve await/timer sequencing;
- preserve combat values and balance;
- preserve AI decisions unless explicitly changing them;
- preserve input consumption and animation lifecycle;
- do not optimize merely to reduce line count.

## 12. Standing architecture rule

For future battle features:

1. First identify the production responsibility owner.
2. Add the feature to an existing appropriate Controller/Service/Helper when one exists.
3. Create a new dedicated module only for a genuinely independent responsibility.
4. Keep the canonical battle controller focused on wiring, orchestration, and scene-level coordination.
5. Do not put new real game logic back into `*_test.gd` simply because the current test scene is convenient.
6. Scenario-only behavior stays in scenario tests/fixtures.

## 13. Current status / next action

Verified on 2026-09-18:

- B-0A ownership audit recorded in `agent/BATTLE_RUNTIME_OWNERSHIP_AUDIT_20260918.md`.
- B-0B canonical production boundary created as `scenes/battle/Battle_Main.tscn` + `scripts/battle/battle_controller.gd`.
- B-0C generic ISO presentation modules promoted into `scripts/battle/presentation/iso/`.
- Production HUD and Imjin scenario consumers route through `scripts/battle/battle_controller.gd`.
- WorldMap still intentionally enters `res://Battle_Land.tscn`; do not switch it before the parity gate.

B-1 status:

- B-1A refreshed the god-script function baseline and locked the first extraction boundary.
- B-1B extracted `BattleMovementQueryService` with compatibility wrappers at HEAD `4169c1fcd3cbf2be20cd582b6c908a6dc1db1372`.
- B-1B-hotfix1 cleaned only the focused movement-test fixture teardown at HEAD `e601750b42bd05618cb5bfc7aaa6737d2dc22698`.
- B-1C extracted `BattleCombatQueryService`; the focused wrapper-parity fixture was corrected at final HEAD `e226ff02606182f3d97af25eddf35cf833b295e6`.
- B-1C final exact-head workflow run `35338064619` completed successfully with the combat focused test executing 29 checks / 0 failures and no hidden compile/invalid-call errors.
- Current `scripts/battle_web_import_test.gd`: 665,425 bytes / 15,859 lines / 859 functions.
- Existing caller surfaces remain compatibility wrappers; function count is therefore intentionally unchanged.
- AI scoring, attack execution, turn/phase sequencing, animation, BattleContext/BattleResult, and WorldMap handoff remain outside B-1C.

- B-1D extracted `BattleDamageFormulaService` at final HEAD `edfc67e25972b99031943c6575ccdf4b587c9d69`.
- B-1D exact-head workflow run `35340079442` completed successfully.
- Damage focused regression: 33 checks / 0 failures; hidden script/compile/load/invalid-call scan clean.
- Current `scripts/battle_web_import_test.gd`: 661,683 bytes / 15,806 lines / 859 functions.
- Wounded hero lookup/adjustment/logging remains controller-owned by design.

B-1E / B-1F / B-1G status:

- B-1E extracted acted-id action-lock bookkeeping/query state into `BattleActionLockStateService` while preserving controller-owned action flags, status consumption, sequencing, and resume compatibility.
- B-1F extracted enemy-AI per-turn destination/engagement reservation bookkeeping into `BattleEnemyAiReservationStateService`.
- B-1F focused runtime behavior was manually checked by the user on 2026-09-19 with no observed issue.
- B-1F audit: `agent/BATTLE_ENGINE_B1F_ENEMY_AI_RESERVATION_STATE_AUDIT_20260919.md`.
- B-1F execution brief: `agent/BATTLE_ENGINE_B1F_CODEX_ENEMY_AI_RESERVATION_STATE_20260919.md`.
- B-1G audit selected unique-skill cooldown registry bookkeeping as the next coherent state extraction.
- B-1G implementation is now present: `BattleUniqueSkillCooldownStateService` owns cooldown set/get/tick/clear/export/restore while controller wrappers retain hero-id resolution, round sequencing, buff ticking, skill policy, and resume I/O.
- B-1G preserves the exact resume key `cooldowns` and does not change snapshot schema or WorldMap routing.
- B-1G audit: `agent/BATTLE_ENGINE_B1G_UNIQUE_SKILL_COOLDOWN_STATE_AUDIT_20260919.md`.
- B-1G execution brief: `agent/BATTLE_ENGINE_B1G_CODEX_UNIQUE_SKILL_COOLDOWN_STATE_20260919.md`.

Current next action:

- B-1G manual runtime verification was reported successful by the user on 2026-09-19, including unique-skill use and turn progression.
- Pause the B-1x extraction sequence before B-1H.
- The active priority is P-1 Production Runtime Unification, beginning with P-1A WorldMap 16:9 Production Promotion Audit.

- 2026-10-19: P-1 and engine-core were merged on `integration/p1-engine-core-20261019` (WorldMap.tscn = P-1 version); all 25 CI validators and CI Godot tests pass on the merged tree. Open: `validate_p1b_16x9_functional_parity.py` garrison-title assertion (design decision pending) and the two P-1D roundtrip tests are not wired into CI.

B-1H status (2026-10-19): the P-1 production-entry duplication problem is resolved (merged on `integration/p1-engine-core-20261019`), so B-1H may begin.

- B-1H audit selected unique-skill buff state (attack turns/bonus, defense bonus) as the next state extraction.
- B-1H audit: `agent/BATTLE_ENGINE_B1H_UNIQUE_SKILL_BUFF_STATE_AUDIT_20261019.md`.
- B-1H execution brief: `agent/BATTLE_ENGINE_B1H_CODEX_UNIQUE_SKILL_BUFF_STATE_20261019.md`.
- Separate finding, not part of B-1H: buff state is absent from the resume snapshot (gameplay decision pending).

S1 status (2026-10-19): the 3D battle track needs engine actions to emit events, so the generic B-1x sequence is paused and a targeted split ("S1") runs instead.

- C-0~C-3 (3D Field Lab connected to engine movement queries, read-only) merged; 3D tests pinned by B3D-F1 (VIEW_FIELDS contract, oblique camera click round trip).
- S1-0 (design-only audit, verified): `agent/BATTLE_ENGINE_S1_0_ACTION_EVENT_AUDIT_20261019.md`. Decisions F3 = option A on all five (move/cancel/facing first; keep prepare/hit/finish timing; B-1H not a prerequisite; keep RNG calls + roll-tape parity; keep asymmetries as-is).
- S1-1 (observation baseline, verified, merged): `BattleEventLogService`, `BattleStateFingerprintService`, real Battle_Main move oracle (7 cases x2 deterministic) with golden `tests/golden/battle_move_baseline_v0.json`; schema `agent/BATTLE_ENGINE_EVENT_SCHEMA_MIN_v0_20261019.md`. Controllers unchanged. The golden must stay unchanged through S1-2.
- S1-2 (ally move state into `BattleAllyMoveStateService`, verified, merged; M1-a of `EASTWAR_3D_BATTLE_MASTER_DESIGN_v1_0_20261019.md`): completion write split into `apply_destination` + `commit_move_metadata` at the original write positions, `move_path` passed as an extra default-valued argument of `_finish_basic_move_demo`; the S1-1 golden is unchanged and service-emitted events match it.
- M1-b (`Battle3D_EnginePlayLab`: real Battle_Main hosted in a SubViewport, 3D clicks -> the four existing controller calls, playback from the executed `unit_moved` path; verified, merged): 3D can select / move / confirm facing / right-click cancel on real engine state. Attack, enemy turn and turn end are not connected. Known follow-up: the detour case should also assert the playback path equals the executed path (my probe that shortened the playback path to start/end was not caught); the independent-audio cleanup in the host is for this standalone Lab only and must be revisited for M7.
- B3D-F2 (merged): the detour case now asserts the playback path equals the executed `unit_moved` path; my straight-line playback probe is caught (`detour playback equals engine executed path`).
- S2-1 (real ally attack observation baseline, verified, merged; M2 preparation): `tests/golden/battle_attack_baseline_v0.json` (15 cases, 10 units x 40 fields per checkpoint, each case run twice), `tests/scripts/support/battle_attack_oracle_harness.gd`, `tools/validate_battle_s2_1_attack_baseline.py` (pins BASE..TIP, env `S2_1_SCOPE_TIP`). No production script/scene/project change. Write-timing table in `agent/BATTLE_ENGINE_S2_1_RESULT_20261019.md`: damage/attacked flag/last_action/gunner status/momentum at request time; `has_acted`/`has_moved`/lock/status-tick/death cleanup at tween finish; then the engine's automatic enemy slot and next-ally selection.
- A7 finding (kept as a known boundary, no engine change): `_try_attack_enemy_target_from_attack_select` does not check target side; the ally guard lives in the 2D input layer (`_get_clicked_enemy_unit_at_position` -> `_get_alive_enemy_units`). M2-3D must pass enemy-side targets only and add an "ally click -> no attack call, state unchanged" test.
- Test gap found by my probe and closed by S2-2 step 0 (A6b): removing `_clear_pending_move_snapshot()` from `_finish_basic_attack_demo` had passed A6. My first description ("A6 seeds `has_moved`, so no real pending snapshot") was incomplete: Codex showed that in the normal input path facing confirmation already clears the snapshot, so the finish-time clear is not visible in state. A6b (real `_try_direct_move_to_cell` -> facing confirm -> attack) therefore pins it as a **call-preservation contract**: no clear call at request time, exactly one clear call in `resolving` at finish, plus the later `enemy_turn` clear recorded in the golden. S2-2 must keep that controller call at the same point (or change the assertion only with explicit approval). The assertion pins an implementation detail on purpose; it does not claim a user-visible state error.
- Other probes caught as expected: no momentum gain, gunner status magnitude, attacked flag removed, gunner moved-attack allowed, range check off, `last_action.type` changed, enemy slot skipped.
- Next: S2-2 (attack state/event separation, preserving the write timing above), then M2-3D (3D attack command), then M3 (enemy AI / turn). Each later validator must pin BASE..TIP like the S1-1/S2-1 validators.
- CI now lists 30 validators and 56 Godot tests (all pass locally on the merged tree; the attack oracle with A6b takes about 95 s of the 120 s per-test limit on my Linux box, so split it into shards before S2-2 adds cases).

Relevant current records:

- `agent/BATTLE_ENGINE_B1E_ACTION_LOCK_STATE_AUDIT_20260918.md`
- `agent/BATTLE_ENGINE_B1F_ENEMY_AI_RESERVATION_STATE_AUDIT_20260919.md`
- `agent/BATTLE_ENGINE_B1F_CODEX_ENEMY_AI_RESERVATION_STATE_20260919.md`
- `agent/BATTLE_ENGINE_B1G_UNIQUE_SKILL_COOLDOWN_STATE_AUDIT_20260919.md`
- `agent/BATTLE_ENGINE_B1G_CODEX_UNIQUE_SKILL_COOLDOWN_STATE_20260919.md`

This document is the persistent source of truth for continuing the battle refactor in a new chat/session.
