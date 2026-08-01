# HANDOFF TO CODEX

## SamWar_BattleLab 자동 작업 권한 헤더

이번 작업은 SamWar_BattleLab 폴더 내부 작업이다.

읽기 / 검색 / 코드 수정 / 씬 파일의 필요한 범위 수정 / 검증 실행 / agent 문서 업데이트 / 로컬 git commit까지는 모두 자동으로 진행한다.

중간에 확인 질문하지 말고, 지시문에 적힌 목표 완료까지 진행한다.

단, 아래 작업은 하지 않는다:

- git push
- 파일 삭제
- repo 밖 시스템 변경
- 프로그램 설치
- 패키지 전역 설치
- OS 설정 변경
- 요청 범위 밖 대규모 리팩토링

설치나 repo 밖 변경이 필요하다고 판단되면, 작업을 멈추고 이유와 대안을 보고한다.

작업 완료 후에는 수정 파일 목록, 검증 결과, 커밋 해시를 보고한다.

---

# T08-2 Scene-Authored Production HUD Skeleton & UI State Adapter

## Completion note

T08-2 is implemented in local commit `e07877e`. Its automated validators pass; Godot headless and F5 remain pending because the configured executable cannot be launched from this execution environment. The next roadmap transaction is T08-3 Production UI Art Pack and Theme Binding.

## Current locked baseline

- Repository: `kimjak-app/SamWar_BattleLab`
- Branch: `main`
- Remote design baseline at handoff creation: `453c67d64d41a97f7c791aceacab1b85f86df675` or later documentation-only descendant.
- T01–T05 Korea Four-City MVP world-turn, invasion, occupation, logistics, recovery, and unification contracts are protected.
- T06 hero authority, five-stat data, 39 unique skills, shared momentum, resolver integration, battle result parity, cutins, Korean display, portraits, save/load, and enemy multi-actor flow are implemented.
- T07 five-unit-type battle parity is implemented with dedicated gunner and mounted-archer visuals.
- T08-1 audit and production information architecture are complete.
- T08-2 implementation contract is locked.

## First actions

1. Confirm local branch is `main`.
2. Report local `HEAD`, remote `origin/main`, and dirty status.
3. Pull only when the working tree is clean and normal fast-forward pull is safe.
4. Read these documents before editing:
   - `agent/WORKFLOW_MANAGER.md`
   - `agent/TRANSACTION_DEVELOPMENT_RULES.md`
   - `agent/GODOT_RULES.md`
   - `agent/CURRENT_STATE.md`
   - `agent/NEXT_TASKS.md`
   - `agent/plans/T07_T11_BATTLE_ENGINE_MVP_COMPLETION_ROADMAP.md`
   - `agent/plans/T08_BATTLE_UI_UX_PRODUCTION_PLAN.md`
   - `agent/plans/KOREA_MVP_BATTLEFIELD_ART_MASTER_PLAN.md`
   - `agent/plans/T09_BATTLEFIELD_TERRAIN_HANDOFF_PLAN.md`
   - `agent/transactions/T08_1_BATTLE_UI_UX_CURRENT_STATE_AUDIT_AND_PRODUCTION_INFORMATION_ARCHITECTURE_DESIGN.md`
   - `agent/transactions/T08_2_SCENE_AUTHORED_PRODUCTION_HUD_SKELETON_AND_UI_STATE_ADAPTER.md`
5. Audit the exact local versions of:
   - `Battle_Land.tscn`
   - `scripts/battle_web_import_test.gd`
   - `scripts/battle/battle_momentum_state.gd`
   - current battle validators and local Godot command path.

Do not stop after the audit. Continue through implementation, validation, documentation update, and local commit unless a forbidden operation or genuine blocker is reached.

## Protected contracts

- `HeroDesignDataRegistry -> HeroRuntimeFactory -> BattleUnitState -> BattleSkillResolver` remains the single-authority hero path.
- Player and AI continue to share authoritative action, unit-type, and calculation rules.
- Momentum starts at `3` and is capped at `10`.
- Maximum battle turn remains `30`.
- Existing move, attack, unique skill, defend/wait, facing, AI, supply, reinforcement, cutin, result, WorldMap return, save/resume, and snapshot behavior remain unchanged.
- No terrain IDs, passability, movement cost, terrain modifiers, cooperative attacks, common tactics, or balance changes are added.
- Do not delete legacy scene nodes in this transaction.
- Do not integrate final UI PNG art or the final Hanseong battlefield image yet.

## Required implementation

### 1. Scene-authored production hierarchy

Add a major production root under the existing `BattleUI` CanvasLayer. Prefer the exact hierarchy locked in the transaction document:

```text
BattleUI
└─ ProductionHudRoot
   ├─ TopHudRoot
   │  ├─ AllyMomentumHud
   │  ├─ TurnHud
   │  └─ EnemyMomentumHud
   ├─ AllyRosterHud
   ├─ EnemyRosterHud
   ├─ InteractionGuideHud
   ├─ ActorComparisonHud
   ├─ GlobalCommandHud
   ├─ BattleLogHud
   ├─ TooltipHud
   └─ FacingSelectionHud
```

Major roots must exist in the scene or in one packed production HUD scene visibly instanced from `Battle_Land.tscn`. They must not be created as major layout nodes during `_ready()`.

Use provisional `Panel`, `StyleBoxFlat`, `Container`, `Label`, `ProgressBar`, `TextureRect`, and similar scene-authored controls. Final ornament textures are deferred.

### 2. Top HUD

Scene-author:

- ally momentum numeric label and exactly ten slots;
- turn `current / 30` label;
- active-side label;
- battle-title label;
- enemy momentum numeric label and exactly ten slots.

At a fresh battle the UI must read:

- ally momentum `3 / 10`;
- turn `1 / 30`;
- enemy momentum `3 / 10`.

Do not change momentum mechanics. Replace or bypass runtime-created major momentum layout as the production authority, but preserve a safe legacy fallback until validation passes.

### 3. Side rosters

Scene-author three main and two reinforcement slots per side.

Each production slot supports actual runtime data for:

- portrait;
- Korean hero name;
- Korean unit type;
- current/max troops or HP presentation;
- action state;
- status entries;
- unique-skill readiness;
- reinforcement/unused/dead/retreated visibility state.

Do not alter battlefield-local unit visuals.

### 4. Actor comparison HUD

Bind:

- left: current actor with `현재 행동`;
- right selected target with `선택 대상` during targeting;
- right counterattack/retaliation subject with `반격 대상` during resolution when available;
- otherwise right next known enemy AI actor with `다음 행동`;
- otherwise explicit standby/empty state, never stale prior data.

The center panel may show only already-authoritative values such as distance, expected damage, counterattack, or side/rear relation. Reserve an empty terrain field for T09; do not simulate terrain.

### 5. Interaction guidance and commands

Map the existing phase values into one visible Korean guidance surface.

Cover at least:

- unit/command selection;
- move target selection;
- attack target selection;
- unique-skill target selection;
- current strategy state where already implemented;
- facing selection;
- resolving;
- enemy turn;
- battle complete.

Add one visible Korean disabled-reason field or tooltip path.

Fix the known mismatch without changing gameplay semantics:

- a control visibly labeled `이동` must not call `_on_defend_button_pressed()`;
- either connect true move behavior to `이동` or present the existing handler as `방어` in the production command surface.

### 6. Normalized state adapter and one refresh entry

Introduce one normalized production-HUD state boundary. Preferred helper path:

```text
scripts/battle/ui/battle_hud_state_adapter.gd
```

A different narrowly scoped path is allowed only when it better fits the current architecture.

The normalized state must cover the fields specified in the T08-2 transaction, including turn, max turn, active side, phase, title, momentum, both rosters, left actor, right subject/role, center context, instruction, disabled reason, command states, recent log, and battle-complete state.

Create one identifiable controller refresh entry, such as:

```gdscript
_refresh_production_battle_hud(reason: String = "")
```

All production surfaces must be updated from this path rather than formatting final labels across unrelated functions.

Refresh after every state transition listed in the transaction document: reset, WorldMap handoff, roster setup, snapshot restore, turn/round, active unit, selections and cancellations, action commits, facing, damage/heal/status/death/retreat/reinforcement, momentum changes, cutin enter/exit, auto toggle, and battle result.

Use a safe deferred/coalesced refresh when necessary to avoid repeated work during one resolution sequence.

### 7. Battle log

Feed the visible production battle log from one canonical recent-event source. Do not leave the player reading a different node from the one runtime updates.

Preserve the current compact recent-line policy unless a larger history already exists.

### 8. Cutin/toast/result restoration

Do not replace cutin media or effects.

Suppress only necessary production layers during full-screen presentations. After each presentation, rebuild visible UI from current authoritative state through the production refresh path rather than restoring copied stale label text.

Do not allow commands to reappear after battle completion.

### 9. Legacy migration

- Keep legacy nodes and working paths present.
- Hide or bypass a legacy surface only after the matching production surface has parity.
- Record all legacy surfaces still required after T08-2.
- No file or node deletion.

## Required validator

Add a focused repository validator following existing conventions. It must verify at least:

- `ProductionHudRoot` and required major roots;
- exactly ten ally and ten enemy scene-authored momentum slots;
- separate turn and momentum labels;
- three main plus two reinforcement slots per side;
- left/center/right actor-comparison roots;
- interaction instruction and disabled-reason nodes;
- one identifiable production refresh entry;
- production command mapping does not retain visible `이동`→defend mismatch;
- no raw internal IDs in static user-facing production labels;
- existing T06/T07 validator compatibility.

## Verification

Run the locally available Godot executable and repository validators.

Required minimum:

- Godot project parse/headless load;
- `Battle_Land.tscn` headless load;
- new focused T08-2 validator;
- battle momentum validator;
- five-unit-type validator;
- affected cutin/snapshot/battle validators;
- no new warnings or errors.

Then perform the maximum automated runtime smoke test available locally. Do not fabricate user F5 results.

## Documentation and commit

Update:

- `agent/transactions/T08_2_SCENE_AUTHORED_PRODUCTION_HUD_SKELETON_AND_UI_STATE_ADAPTER.md`
- `agent/CURRENT_STATE.md`
- `agent/NEXT_TASKS.md`
- `agent/HANDOFF_TO_CODEX.md`
- `agent/CHANGELOG.md` when consistent with current workflow.

Record:

- modified files;
- exact validator/Godot commands;
- PASS/FAIL results;
- local F5 status as not run unless actually run;
- remaining risks and legacy nodes.

Commit only in-scope tracked changes with:

```text
feat: add production battle HUD skeleton and state adapter
```

Do not push.

## Completion report

Return:

1. local starting and ending HEAD;
2. modified files;
3. implemented UI hierarchy and adapter summary;
4. command mismatch resolution;
5. validation commands and results;
6. local commit hash;
7. remaining risks;
8. exact user F5 checks still required.
