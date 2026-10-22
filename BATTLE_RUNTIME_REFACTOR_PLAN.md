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
- S2-2 (attack state/event separation; Codex designed and implemented without my brief, then independently verified and merged by Claude): `BattleAttackStateService` owns the original request-time damage application and basic-attack metadata/status/post-attack-move writes. Controller formula/log/Tween/finish/AI order stays fixed. `battle_action_event_log` adds ally `attack_resolved` at request, ally basic `action_completed` after the existing finish-time mark, and shared `unit_defeated` at first cleanup registration. Shared attack contract callers delegate identically; enemy attack events are not introduced. Both existing goldens and the A6b observer are unchanged. The pending-snapshot clear remains in the controller once at the same location. Scope and limitations: `agent/BATTLE_ENGINE_S2_2_EXECUTION_20261019.md`; evidence: `agent/BATTLE_ENGINE_S2_2_RESULT_20261019.md`.
- S2-2 independent review (clean base `3269385`, Linux): 21 files byte-identical to the bundle; full regression 31 validators + 59 Godot tests pass; Codex's counts reproduced exactly (shards 128/106, event parity 213, service 70); both goldens and the attack harness hashes equal the base. My own probes: 24 randomized attacks (11 mounted archers, moved/defending/low-HP targets, 2 kills) are byte-identical between base and S2-2 for all 10 units' 40 fields plus controller state; the same 24 scenarios give exactly one `attack_resolved` (ids/troops/defending/killed consistent with state), one `action_completed` for the actor, `unit_defeated` only for the killed target, local sequence 0..n-1, order resolved -> completed -> defeated.
- S2-2 coverage notes (non-blocking): (1) no oracle/event fixture uses `mounted_archer` or cavalry; the controller->service call for post-attack movement is protected statically (the validator catches deleting that line) and behaviorally only by the service unit test; my random run confirmed the flags (`post_attack_move_available`, remaining 2) on the real controller. (2) No fixture where an enemy attack kills an ally, so `unit_defeated` during the automatic enemy slot is covered only by shared-cleanup reasoning. (3) The validator pins exact text of the four functions, so any later edit to them needs an explicit re-pin. (4) Windows-only start-up crash (signal 11, 5 times) reported by Codex was not reproduced in my Linux runs (several full runs, no crash).
- M2-3D rules from S2-2: keep a separate cursor per log (`ally_move_event_log` and `battle_action_event_log` have independent sequences, never merge by sequence); there are no enemy attack/move events yet, so enemy results must come from state sync until M3; `unit_defeated` can be emitted by any cause and by either side; the event log is not in the resume snapshot.
- Next: M2-3D (3D attack command/range/result display and enemy-state synchronization; enemy-side targets only), then M3 (enemy AI / turn events). Each later validator must pin BASE..TIP like the S1-1/S2-1/S2-2 validators.
- CI now lists 31 validators and 59 Godot tests (all pass locally on the merged tree; the attack oracle runs as two 8-case shards, about 57 s and 45 s on my Linux box, event parity about 51 s, each under the 120 s per-test limit).

Relevant current records:

- `agent/BATTLE_ENGINE_B1E_ACTION_LOCK_STATE_AUDIT_20260918.md`
- `agent/BATTLE_ENGINE_B1F_ENEMY_AI_RESERVATION_STATE_AUDIT_20260919.md`
- `agent/BATTLE_ENGINE_B1F_CODEX_ENEMY_AI_RESERVATION_STATE_20260919.md`
- `agent/BATTLE_ENGINE_B1G_UNIQUE_SKILL_COOLDOWN_STATE_AUDIT_20260919.md`
- `agent/BATTLE_ENGINE_B1G_CODEX_UNIQUE_SKILL_COOLDOWN_STATE_20260919.md`

This document is the persistent source of truth for continuing the battle refactor in a new chat/session.

S2-2 CI adjustment: the original 16-case attack oracle still supports a full manual run; CI now uses two disjoint 8-case wrappers, each retaining two executions per case and unchanged golden comparison. Separate service/event tests avoid lengthening the old oracle. No remote CI run or push is claimed for this local stage.

M2-3D independent review (merged, not pushed until the owner names the branch):
- Status: Codex implementation 1ee5282 (validator TIP pinned here) + report finalize commit on top of afe0367; engine, adapter, lab_presentation, goldens untouched
- My checks: full local regression 32 validators / 64 tests all pass; 4 mutation probes (enemy-only filter, input lock, visibility filter, range check removed) each caught by the new tests; 24 random scenarios (all five unit types, defending/low-HP/moved) driven through the 3D lab input vs engine-direct calls gave 0 differences in 40-field unit fingerprints + controller state at every stage
- Notes: info panel mouse_filter=IGNORE lets clicks pass through (M6 UI item); default 18x10 layout cannot reach an attack without M3, so a near-layout manual entry exists (not in CI); six tests were reported by Codex as reused evidence; F-key attack evidence is the owner's manual run
- CI now lists 32 validators and 64 Godot tests
- Next: M3 (enemy AI / turn events, enemy move/attack path animation), then M4-M6, M7 worldmap round trip needs separate approval

S3-1 independent review (builder: a separate Claude Code session on Opus 5.5; verifier: this reviewer; merged locally, not pushed until the owner names the branch):
- Status: implementation 1404c6c (validator TIP pinned here) on top of a19a08d (= d05d4f1 + Godot editor metadata resave of Battle3D_EnginePlayLab.tscn); builder wrote 17 additive recording lines in 11 controller functions plus an observation-only service `battle_enemy_event_log_service.gd` and independent `enemy_action_event_log` (9 event kinds)
- My checks: controller diff read line by line (additions only; validator proves controller minus recording lines == BASE byte for byte); full regression on Linux 33 validators / 68 tests all pass (builder's Windows run matched); 24 random multi-type enemy-turn scenarios BASE engine vs S3-1 engine gave 0 differences in unit fingerprints, controller state and both ally logs; events matched state (24 moves path/final cell, 9 attacks damage_applied == troop loss); six builder mutation probes reproduced (all caught by tests; P3 path-last-cell is caught by the semantics test, not by the validator)
- Findings for M3: defeat by enemy attack leaves phase `enemy_turn` with no `enemy_action_completed`; victory leaves phase `ally_turn` and is_demo_animating=false, so 3D must lock input on `battle_ended` / result state, not on phase; `enemy_waited` reason `wait` is used by two branches; reasons no_path / path_blocked / plan-stage no_target are unreachable in real play (seam-tested only); each enemy slot resolves exactly one actor then returns to the ally turn
- Existing behavior left untouched and reported: an enemy gunner moves and then attacks in one action although the unit type contract says can_attack_after_move=false (A/B decision for the owner)
- Environment note: builder saw a signal 11 in Godot's first fresh import on Windows (font import), retry succeeded; not reproduced on Linux
- CI now lists 33 validators and 68 Godot tests
- Next: M3 (3D enemy-turn playback from enemy_action_event_log with a third event cursor; no engine edits)

M3 independent review (builder: separate Claude Code session on Opus 5.5; verifier: this reviewer; merged locally):
- Status: implementation f357f07 (M3 validator pinned here; BASE 102713f) with zero engine diff; only 3D `battle3d_engine_play.gd`, one M2 harness assertion made playback-aware, new tests/validator/golden
- My checks: full regression on Linux 34 validators / 73 tests all pass; 24 random scenarios through the 3D lab input vs engine-direct calls (enemy turn included) gave 0 differences in unit fingerprints, controller state and both ally logs, with 12 enemy moves whose played 3D path equals the engine event path; builder's 9 mutation probes reproduced (tests caught all 9, validator catches 6 statically; double consumption, input-lock removal and queue-lock removal are caught only by the tests)
- Design gap found by the builder and confirmed: in the default 18x10 layout the six write calls cannot complete an ally turn unless an attack is possible (move + facing leaves has_acted false, and the engine locks other allies after the first move). Cause was my brief fixing six writes and omitting the existing engine wait command (`_end_ally_turn_by_wait`, the 2D wait button), which design v1.1 section 11.2 lists in the M3 row ("action complete / wait / turn progression supported by the engine"). A one-line correction plus tests is queued as M3-b: add `_end_ally_turn_by_wait` as the seventh write call and a 3D wait button; defend stays in M4
- Known notes: the screenshots were produced by injecting viewport input, not by a human; top round label can lag behind the roster (engine already in next round) while input stays locked (M6 item); round display starts at 1 and then follows events because `battle_round` is not in the read allowlist
- CI now lists 34 validators and 73 Godot tests

M3-b independent review (builder: separate Claude Code session on Opus 5.5; verifier: this reviewer; merged locally):
- Status: implementation 47f4fbf (builder's squashed commit; re-based onto the integration chain, M3-b validator BASE c7e4fe8, TIP pinned here) with zero engine diff; only `battle3d_engine_play.gd` (+49/-1), three new tests plus harness, new validator, workflow additions. Seventh write call `_end_ally_turn_by_wait` and a 3D wait button; defend stays in M4
- My checks: full regression on Linux 35 validators / 76 tests all pass (matches the builder's count); 24 random scenarios through the 3D lab wait button vs engine-direct `_end_ally_turn_by_wait` (enemy slot included, 5 of them with a confused actor that the engine rejects) gave 0 differences in unit fingerprints, controller state and enemy event logs
- Mutation probes (my own set of 9, run against the builder's new tests): wait button never disabled, acted-unit check removed, acceptance always true, phase guard removed, extra enemy-turn trigger were caught by tests and validator; the single-layer input-lock removal (builder's R7) is caught by the validator only, as the builder reported; enemy-turn guard removal likewise (another guard layer covers it); two were not caught by anything: enemy baseline captured after the wait call (only matters when an enemy slot ends instantly with damage, not reachable in the current cases) and the move-range overlay not cleared after wait (visual state only)
- Engine facts confirmed: wait leaves no event in the ally logs, the engine rejects wait during facing select and for a confused ally, a post-battle wait changes nothing (3D locks first); the default 18x10 layout reaches round 2 by 3D input alone (wait or move+facing+wait)
- Notes: screenshots are injected viewport input, not a human run; round label lag stays an M6 item; no hotkey for wait (M6)
- CI now lists 35 validators and 76 Godot tests
- Next: M4-a defend (3D only), S4-1 engine events for strategy/skill/reinforcement, then M4-b/c/d; see the M4 pre-audit

M4-a independent review (builder: separate Claude Code session on Opus 5.5; verifier: this reviewer; merged locally):
- Status: implementation 1577702 (M4-a validator pinned here; BASE ff25fdb) with zero engine diff; only `battle3d_engine_play.gd` (+52/-5), three new tests plus harness, new validator, workflow additions. Eighth write call `_on_defend_button_pressed`, a 3D defend button, and a read-only `is_defending` display (approved extension: unit badges and the unit panel, adapter untouched)
- My checks: patch applied cleanly on ff25fdb; full regression on Linux 36 validators / 79 tests all pass (matches the builder's count); 24 random scenarios through the 3D lab defend button vs engine-direct `_on_defend_button_pressed` (wounded and full-HP actors, confused actors the engine rejects, enemy slot included) gave 0 differences in unit fingerprints, controller state and enemy event logs (a first run showed 2 trailing-event differences that disappeared with a longer settle time, i.e. capture timing in my probe, not behavior)
- Engine facts confirmed by the builder and spot-checked: defend leaves no event in the ally logs; `enemy_attack_resolved.raw_damage` is already the post-defend value (a future "reduced by" display needs an event change); `is_defending` survives the enemy slot and is cleared when the next round starts; an enemy slot that ends instantly can start the next round inside the defend call (acceptance must not rely on `is_defending`); heal = max(1, round(missing HP x 0.10)) on both HP and troops; the engine does not itself refuse defend (or wait) after the battle has ended in one reachable state, only the 3D result lock does
- Mutation probes (my own set of 12 on the new code): wait/acceptance/phase/lock/badge/info-panel/extra-enemy-turn/wrong-command variants were caught by tests and validator; caught by the validator only: single-layer input-lock removal, enemy-turn guard removal, status-line troops text; acceptance by `is_defending` only was caught by the D4 equivalence case but not the rejections test; not caught by anything: enemy baseline captured after the defend call (only matters when an enemy slot ends instantly with damage, same gap as M3-b). My first probe run was invalid because my own untracked probe file tripped the validator's scope check; rerun on a clean tree
- Notes: screenshots are injected viewport input, not a human run, and none shows a defended unit being hit (the default layout's enemies only move); the unit list heading still reads "has_moved / has_acted"; no hotkey (M6)
- CI now lists 36 validators and 79 Godot tests
- Next: S4-1 engine events for strategy / skill / reinforcement (see the M4 pre-audit), then M4-b/c/d

S4-1 independent review (builder: separate Claude Code session on Opus 5.5; verifier: this reviewer; merged locally):
- Status: implementation 1d0f5b6 (S4-1 validator pinned here; BASE 608cb77), two builder commits applied on the integration tip (builder hashes 88d2033 / a6ef11b became 7a6ebe1 / 1d0f5b6 after `git am` and a committer-identity rewrite). Engine step (S): new independent `tactic_event_log` (strategy_cast, status_tick, skill_cast, skill_effect, skill_finished, reinforcement_arrived) plus a test-only strategy dice hook `strategy_roll_override`; controller +36/-2 (20 recording lines in 7 functions, 2 header lines, 2 dice helpers, 2 replaced dice lines); no 3D, existing service, golden or pinned validator changed; no consumer yet
- My checks: patch applied cleanly; validator passes live and pinned to the second commit (pinned to the first commit alone errors by design, the validator audits the whole range); full regression on Linux 37 validators / 88 Godot tests all pass (matches the builder's count); controller hunks read line by line (recording lines only, no new await/timer/RNG call, helper bodies identical to the replaced expressions when the hook is empty)
- Own equivalence check: 6 seeds x 10 steps of natural multi-round play (ally auto action, strategy, unique skill button, wait; one global seed, no per-action reseeding) on BASE vs new engine gave 0 differences in unit fingerprints, controller state, the three existing logs and the next random draw after every step, while the new engine recorded 39-43 tactic events per run
- Own probes: recording that consumes RNG (caught by validator and by my whole-play comparison; the builder's oracle misses this one, as the builder reported); status_tick emitted before the tick (caught by validator; my play comparison does not read the new log)
- Facts confirmed from the builder's pre-checks: strategy success = randf() <= rate and pool pick = randi() % size (basic tier still consumes one randi); FX also use the global RNG; all 44 unique skills have cooldown 0, so skill_finished.cooldown_turns is always 0 today and the cooldown-order probe is validator-only; extra damage flag `deterministic_followup` exists; `enemy_skill_used` stays an attempt record while `skill_cast` marks the committed cast; reinforcements arrive before `round_started` (round 2 reinforce_01, round 3 city_reinforce_02)
- Notes: golden was regenerated in the second commit for two cases only (K_rally_restore, K_commit_failure), generated from BASE both times; hook is a public member, guarded by the validator only (no use outside tests); strategy outcome fields use `effect_kind` and `turns_after` instead of the briefed names (reasons in the builder report)
- CI now lists 37 validators and 88 Godot tests
- Next: M4-b strategy and M4-d reinforcement display (3D, read this log), then M4-c skills

M4-b (3D strategy) and M4-d (3D reinforcement arrivals) independent review (builder: one overnight Claude Code session on Opus 5.5, two stages from the same base b3386e9; verifier: this reviewer; merged locally):
- Status: M4-b 3ea98f3 (fast-forward; validator pinned here, BASE b3386e9) and M4-d 22f4fac (cherry-picked onto M4-b with conflicts resolved by this reviewer; validator re-based onto 3ea98f3 and its handled-kind list widened to the three kinds of the shared fourth cursor). Zero engine/service/adapter diff in both. M4-b adds two write calls (`_on_strategy_button_pressed`, `_try_use_strategy_on_target`, ten in total) and three engine reads (`_can_use_strategy`, `_get_strategy_targets`, `_get_strategy_success_rate`); M4-d adds no write call and reads only `tactic_event_log`. Both stages used the S4-1 events and the shared `tactic_cursor`; the status badge reads the adapter's existing `status_effects` field instead of the approved direct read
- My checks: both patches applied cleanly on b3386e9; both validators pass pinned and live; full regression on the merged tree on Linux: 39 validators / 95 Godot tests (88 + 4 M4-b + 3 M4-d), all pass once the M4-b validator is pinned (it failed in live mode on the merged tree, as designed); 24 random scenarios through the 3D lab strategy button and target click vs engine-direct `_on_strategy_button_pressed` / `_try_use_strategy_on_target` (dice forced through the S4-1 hook in both runs, random tiers, targets, pre-existing shake/burn, confused casters the engine rejects, enemy slot included) gave 0 differences in unit fingerprints, controller state and all four logs, previews equal to the engine rate, and the 3D presentation list equal to the strategy_cast / status_tick events
- Own mutation probes: 10 on M4-b, 8 on M4-d. Caught by tests and validator: acceptance always true, outcome text inverted (validator and test), target call sent twice, reinforcement hold removed, everything shown, hold never released, arrival log missing, flush never called, waiting-cell click not rejected. Caught by tests only: preview rate constant, enemy tick not deferred. Caught by the validator only: badge status refreshed during a replay, phase check dropped, unknown kind stops consumption (both stages), arrival position offset. Not caught by anything: enemy baseline captured after the strategy call (same gap as M3-b / M4-a, only matters when an enemy slot ends instantly with damage) and the floating burn label showing damage + 1 (the combat line and status text come from the event and are compared, the Label3D text is not)
- Engine facts confirmed by the builder: the strategy phase is `strategy`; the four strategy queries are pure; in the default layout no ally can cast in round 1 (no enemy in range), round 2 can; 3D already builds models for all ten engine units and shows them by the engine deploy flag, so M4-d holds an arrival until the replayed `round_started` instead of creating nodes; clicking an undeployed unit's cell used to send one rejected move call and is now refused in 3D
- Merge note: the two stages edit the same cursor consumer; the merged `_consume_tactic_events` handles strategy_cast, status_tick and reinforcement_arrived, everything else (skill_*) is skipped with the cursor advancing, which M4-c will extend
- Notes: captures are injected viewport input with dice forced by the hook, not a human run; floating labels are small at the default camera (M6); 3D calls `_get_strategy_targets` every frame for the button state (cheap today, revisit if units grow); the button is disabled when no target is in range, so the 3D never creates the engine's "no valid target" log line
- CI now lists 39 validators and 95 Godot tests
- Next: M4-c unique skills (3D, read skill_cast / skill_effect / skill_finished), M5 scenario input, M6 screen cleanup

M4-c1 (3D ally unique skill) independent review (builder: separate Claude Code session on Opus 5.5; verifier: this reviewer; merged locally):
- Status: implementation 7c5f461 (fast-forward onto 4e0b034; validator pinned here, BASE 4e0b034) with zero engine/service/adapter diff. Only `battle3d_engine_play.gd` (+201/-4) changed besides tests, one harness, a new validator and the workflow. Two write calls added (`_on_unique_skill_button_pressed`, `_try_use_unique_skill_on_target`, twelve in total), a [특기] button, a momentum HUD line (reads `battle_momentum.get_value`), the 23 status display names, and the `skill_cast` / `skill_effect` / `skill_finished` kinds on the shared fourth cursor for allied casters (enemy casters are skipped until M4-c2)
- My checks: patch applied cleanly on 4e0b034; validator passes pinned and live; full regression on Linux 40 validators / 102 Godot tests (95 + 7 new), all pass; 44 random boards (one per unique skill: all 44 skills, random positions, troops, facings, statuses, momentum, casters, target picked at random among the engine's valid targets, enemy slot included) through the 3D lab skill button and target click vs engine-direct `_on_unique_skill_button_pressed` / `_try_use_unique_skill_on_target`: 40 castable boards gave 0 differences in unit fingerprints, controller state and all four logs, and the status lines, Label3D texts and momentum HUD equal strings built independently from the tactic events (all six effect kinds appeared); 4 boards the engine refused matched the disabled button. One momentum HUD difference in my first run disappeared once the probe waited for the enemy replay to finish (the HUD holds the value during a replay by design), i.e. capture timing in my probe, not behavior
- Own mutation probes: 16. Caught by tests and validator: momentum sign, cleanse label word, ally HUD reading the enemy value, finished kind dropped, momentum guidance removed, status name typo, move cells swapped (test only), cast cost sign (test only), any-cell target accepted (test only), marks not cleared on phase change (test only). Caught by the validator only: kill suffix dropped from the damage label (the rejections test does not check the label text), status line using turns instead of turns_after (equal in every covered case), auto-mode acceptance always true, momentum note never cleared. Not caught by anything: enemy baseline captured after the skill button (same gap as M3-b / M4-a / M4-b, only matters when an enemy slot ends instantly with damage) and `awaiting_enemy_result` not set after the target click (the flag is only written in 3D, never read, so this is inert)
- Notes: captures are injected viewport input, not a human run; floating labels are small and overlap when one unit gets several effects (M6); the damage log line appends the engine's damage-flag id as-is (e.g. advance_on_kill); the cooldown suffix of the finished line is never exercised because all 44 skills have cooldown 0; `skill_cost_up` raises the effective cost, so a button disabled for cost shows the generic engine-condition reason instead of the cost numbers
- CI now lists 40 validators and 102 Godot tests
- Next: S4-2 (engine, enemy strategy and enemy skill spread behind flags), then M4-c2 (3D replay of enemy skills and strategies), M5 scenario input, M6 screen cleanup

S4-2 (engine: enemy strategy and enemy skill spread behind flags) independent review (builder: separate Claude Code session on Opus 5.5; verifier: this reviewer; merged locally):
- Status: implementation 04ce32d (two builder commits applied on 8957b27; validator pinned here, BASE 8957b27). Engine change limited to `_resolve_strategy` split into the ally epilogue plus the shared `_resolve_strategy_effect`, the enemy strategy path (`_try_enemy_strategy_for_actor`, `_resolve_enemy_strategy`, one call after the ATTACK branch of `_play_enemy_ai_for_actor`) and the enemy spread hook in `_try_auto_unique_skill_for_actor`; a pure rules service, one new enemy event kind `enemy_strategy_used`, two flags both default false. 3D, existing goldens and existing pinned validators unchanged
- My checks: full regression on Linux 41 validators / 113 Godot tests, all pass; whole-battle BASE vs new with both flags false, 6 seeds, unit fingerprints, controller state and the three engine logs: 0 differences
- Own mutation probes: 17. Caught by tests: flag ignored, strategy before attack, duplicate status not blocked, no turn advance after strategy, `enemy_strategy_used` not recorded, enemy using the ally mark, ally path losing the acted mark, last use not recorded, yield condition inverted, penalty sign, plan target kept wrongly; rules service test only: never-used treated as newest, INT threshold off by one, acted ignored. Not caught by anything: spread applied to allies, other actors' acted state counted, high-value threshold set to 0
- Finding (design, not builder): the penalty based spread (40/20) does not meet its goal. Default layout, flag on: xiahou_dun 5, zhang_fei 2, guan_yu 0 versus 3/1/1 before, and the raw score gap (73 to 100) exceeds the penalty so the ranking never changes. Replaced by a rotation rule in S4-2c; the flags stay false until then. See `DESIGN_S4_AI_LEVEL_AND_BATTLE_SETUP_20261022.md`
- Notes: default starting enemies have INT below 80 and cannot cast; only reinforcement 02 casts from round 7 when enabled; the 3D does not show enemy strategies or skills until M4-c2 replay is merged; the flag default is not flipped here (a level option in S4-3 will drive both flags)
- CI now lists 41 validators and 113 Godot tests
- Next: S4-2c (rotation rule), S4-3 (battle setup port and AI level), M4-c2 review, M5-b, M5-c

M4-c2 (3D enemy unique skill replay) independent review (builder: separate Claude Code session on Opus 5.5; verifier: this reviewer; merged locally):
- Status: implementation 2b2340d (one builder commit applied on b83a402 after S4-2; validator re-pinned here with BASE b83a402) with zero engine/service/adapter diff. Only `battle3d_engine_play.gd` (+71/-10) changed besides tests, one harness, a new validator and the workflow. Twelve writes unchanged, no new read. Enemy-cast `skill_*` events wait for the replay of that caster's `enemy_skill_used` (hold queue), enemy-cast `strategy_cast` waits with its completion and the enemy's status ticks in log order, enemy skill lines carry the "적 " prefix with their own lists and label meta, the ally momentum note is untouched. Two existing M3 lines were changed: an enemy skill that finishes the battle no longer produces a second empty-slot summary (engine records `battle_ended` before `enemy_action_completed`), and a skill slot also gets the state diff summary (a skill's troop changes have no move/attack event)
- My checks: patch applied cleanly on 8957b27 and on b83a402; full regression on 8957b27 + patch on Linux 41 validators / 105 Godot tests, all pass; 44 random boards (one per unique skill, an enemy casts in its slot, ally waits) through the 3D lab vs engine-direct: 28 boards where the enemy cast (16 where it did not) gave 0 differences in unit fingerprints, controller state and all four logs, enemy skill lines, Label3D texts, momentum HUD, cursor, with nothing held or left over and the ally lists untouched (effect kinds seen: damage, heal, status, momentum; no move or cleanse from an enemy). A first run reported label differences that were my probe not reading the enemy label meta
- Own mutation probes: 16. Caught by tests: replay hold removed, prefix dropped, ally note overwritten by an enemy momentum effect, enemy label meta shared, enemy presentations into the ally list, empty-slot guard removed, state diff for skill slots removed (after-move case only), pending not flushed on open, open never closed, strategy not held, held sort reversed, enemy skill used does not open, completion does not close, ally-only check removed. Not caught by anything: an enemy cast clearing the ally momentum note (`skill_cast` branch) and leftovers not recorded (diagnostic list only). Validator column is not meaningful for the live-worktree probes
- Notes: captures are the same injected input style, not a human run; enemy move/cleanse effects were never produced by an enemy in the harness (ally side covered in M4-c1); the enemy skill text in the enemy replay line is still the skill id (existing M3 test asserts that); floating labels still small and overlapping (M6)
- CI list on this branch: 42 validators and 116 Godot tests (41 + 1, 113 + 3). The full run was done on 8957b27 + patch (41 / 105); on the merged tree I re-ran both validators and three tests (3D enemy skill mixed log, spread behavior, enemy turn default layout), all pass, not the whole list
- Next: M5-a review, S4-2c (with the use cap), S4-3, M5-b, M5-c, M6

M5-a (3D auto play and speed control) independent review (builder: separate Claude Code session on Opus 5.5; verifier: this reviewer; merged locally):
- Status: implementation 651ac37 (builder commit c855d27 re-applied on the merged M4-c2 tip 406bb73; the same-file conflicts with M4-c2 were additive and kept both sides; validator BASE re-pinned here to 406bb73 and TIP pinned to the implementation commit) with zero engine/service/adapter diff. `battle3d_engine_play.gd` (+103/-1) gained [자동 ▶/■] and [속도 1x/2x/4x] buttons, the 13th write call `_toggle_full_auto_battle` (one call site, acceptance read back from the new read property `is_full_auto_battle_enabled`), an auto input lock in `_input_locked` and the shared command block reason, quiet (event-less) ally action lines, and `Engine.time_scale` only in `_apply_speed` / `_exit_tree` (restored to 1.0)
- My checks: full regression on the merged tree (M4-c2 + M5-a) on Linux 43 validators / 121 Godot tests, all pass (42 + 1 validators, 116 + 5 tests: S4-2, M4-c2 and M5-a, S4-2c not included); 8 random boards (random types, troops, facings, statuses, positions, a random unique skill for every unit, random momentum) run to the end with the engine's full auto from the 3D [자동] button vs the engine's `_toggle_full_auto_battle` called directly, both at 4x: 0 differences in unit fingerprints, controller state, all four logs, tactic cursor, and nothing held; endings were defeat (3), victory (2) and the engine's safety step limit turning auto off (3); the builder's own 1x vs 4x determinism result (rounds 2 to 4 identical) was reused, not re-run
- Own mutation probes: 14. Caught by tests and validator: speed step changed, time scale not restored (test), start lock skipped, stop text changed, auto end text dropped, attack button enabled in auto, input lock removed, `auto_was_on` wrong. Caught by tests only: double press guard removed, auto button never disabled, speed cycle skipping. Caught by the validator only: acceptance check removed, quiet action condition inverted. Not caught by anything: the range marks not cleared when auto starts
- Notes: engine does not wait for the 3D replay during auto, so the next ally action can start while the 3D is still replaying (state equals the engine, the display overlaps); an engine hold port plus the 3D signal are planned (S4-3 part C, M5-a2); `_note_quiet_auto_actions` exports the whole action and tactic logs every frame while auto is on (cost grows with the log, M6); the 3D cannot tell a wait from a confused turn (no approved read); captures are injected input, not a human run
- Next: S4-2c (rotation and use cap) review, S4-3 (setup port, AI level, auto presentation hold), M5-a2, M5-b, M5-c
