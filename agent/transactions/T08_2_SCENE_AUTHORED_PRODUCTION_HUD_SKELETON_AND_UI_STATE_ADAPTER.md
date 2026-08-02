# T08-2 Scene-Authored Production HUD Skeleton & UI State Adapter

## Transaction Status

`IMPLEMENTED / AUTOMATED VALIDATION PASS / USER F5 QA PENDING / FINAL ART DEFERRED`

## Purpose

Create the production battle-HUD scene hierarchy and one normalized UI-state refresh path before final decorative PNG assets or the Hanseong battlefield master are integrated.

This transaction is the structural bridge between the completed T08-1 audit and later T08-3/T08-4 visual production. It must make the current battle flow readable and migration-safe without changing battle rules.

## Authoritative Baseline

- Repository: `kimjak-app/SamWar_BattleLab`
- Branch: `main`
- T08-1 audit: `agent/transactions/T08_1_BATTLE_UI_UX_CURRENT_STATE_AUDIT_AND_PRODUCTION_INFORMATION_ARCHITECTURE_DESIGN.md`
- T08 production plan: `agent/plans/T08_BATTLE_UI_UX_PRODUCTION_PLAN.md`
- Korea battlefield art plan: `agent/plans/KOREA_MVP_BATTLEFIELD_ART_MASTER_PLAN.md`
- Main battle scene: `Battle_Land.tscn`
- Main battle controller: `scripts/battle_web_import_test.gd`
- Momentum source: `scripts/battle/battle_momentum_state.gd`
- Production viewport: `1920 × 1080`, 16:9

## Protected Contracts

T08-2 must preserve all completed gameplay behavior.

- T01–T05 WorldMap, invasion, defense, occupation, logistics, recovery, and unification contracts.
- T06 hero authority, unique skills, cutins, Korean display, portraits, momentum, results, save/load, and enemy multi-actor flow.
- T07 five canonical unit types and shared player/AI action behavior.
- Momentum starts at `3` and is capped at `10`.
- Maximum battle turn remains `30`.
- Existing battle grid, movement, range, facing, AI, damage, reinforcement, supply, cutin, result, and snapshot rules.
- No terrain rules, cooperative attacks, common tactics, or numerical rebalancing are added here.

## Explicit Non-Goals

T08-2 does not:

- produce final ornamental UI art;
- create the 4K Hanseong battlefield;
- implement passable/impassable terrain metadata;
- revise momentum gain/loss mechanics;
- replace working cutin video/content;
- rebalance units or unique skills;
- delete legacy nodes before the new hierarchy is proven;
- perform an unrelated controller refactor.

---

# 1. Required Production Scene Hierarchy

Add a scene-authored production root under the existing `BattleUI` CanvasLayer.

```text
BattleUI
└─ ProductionHudRoot
   ├─ TopHudRoot
   │  ├─ AllyMomentumHud
   │  │  ├─ Frame
   │  │  ├─ SlotRow
   │  │  │  ├─ Slot01 ... Slot10
   │  │  └─ ValueLabel
   │  ├─ TurnHud
   │  │  ├─ Frame
   │  │  ├─ TurnLabel
   │  │  ├─ ActiveSideLabel
   │  │  └─ BattleTitleLabel
   │  └─ EnemyMomentumHud
   │     ├─ Frame
   │     ├─ SlotRow
   │     │  ├─ Slot01 ... Slot10
   │     └─ ValueLabel
   ├─ AllyRosterHud
   │  ├─ Slot01
   │  ├─ Slot02
   │  ├─ Slot03
   │  ├─ Reinforce01
   │  └─ Reinforce02
   ├─ EnemyRosterHud
   │  ├─ Slot01
   │  ├─ Slot02
   │  ├─ Slot03
   │  ├─ Reinforce01
   │  └─ Reinforce02
   ├─ InteractionGuideHud
   │  ├─ PhaseLabel
   │  ├─ InstructionLabel
   │  └─ DisabledReasonLabel
   ├─ ActorComparisonHud
   │  ├─ LeftActorPanel
   │  ├─ CenterContextPanel
   │  └─ RightSubjectPanel
   ├─ GlobalCommandHud
   ├─ BattleLogHud
   ├─ TooltipHud
   └─ FacingSelectionHud
```

The exact child controls inside roster and actor panels may be scene-authored reusable subscenes if that reduces duplication, but the major roots above must be visible and editable in `Battle_Land.tscn` or a packed production HUD scene instanced there.

## Scene-Authoring Rules

- Major HUD nodes must not be created in `_ready()`.
- Anchors, offsets, safe zones, minimum sizes, and placeholder visual styles belong in the scene.
- Runtime code updates values, visibility, textures, states, and animation only.
- Final decorative textures are not required; use clean `StyleBoxFlat`, `Panel`, `NinePatchRect`, `TextureRect`, `Label`, `ProgressBar`, and `Container` placeholders.
- Dynamic values must not be baked into textures.
- Existing legacy UI remains available as a guarded fallback until the production hierarchy passes validation.
- Do not delete legacy nodes in this transaction.

---

# 2. Locked Information Contract

## 2.1 Top HUD

The top HUD presents three independent values.

- Ally momentum: `current / 10`, ten visual slots.
- Battle turn: `current / 30`.
- Enemy momentum: `current / 10`, ten visual slots.

Additional top information:

- concise active-side label;
- concise battle title from WorldMap context;
- no internal IDs;
- no combined or ambiguous turn/momentum number.

The production momentum roots and twenty slots must exist in the scene. Runtime code must stop treating a runtime-created major momentum HUD as the authoritative production path.

## 2.2 Side Rosters

Each side has three main slots and two reinforcement slots.

Each roster slot supports:

- hero portrait;
- Korean hero name;
- Korean unit-type label/icon;
- troop/HP value and bar;
- ready/acted/defeated/retreated/reinforcement state;
- status badges;
- unique-skill-ready indication;
- hidden state for unused slots.

Roster panels are persistent overview surfaces. Battlefield-local portrait badges and HP bars remain tactical markers and are not removed.

## 2.3 Actor Comparison HUD

Left panel:

- current acting unit;
- current actor state label `현재 행동`;
- portrait, name, unit type, troops/HP, statuses, action state.

Right panel priority:

1. selected target during attack/skill/strategy target selection → `선택 대상`;
2. retaliation/counterattack subject during resolution → `반격 대상`;
3. next computer/AI actor when known → `다음 행동`;
4. otherwise an explicit empty/standby state, never stale data.

Center context panel supports:

- phase/relationship icon or text;
- distance;
- expected damage when already available;
- counterattack availability when already available;
- side/rear relation when already available;
- reserved terrain-information field for T09, display-only and empty in T08-2.

Do not fabricate combat previews that do not already exist in runtime.

## 2.4 Interaction Guidance

One visible guidance surface must derive from the normalized phase.

Required phase meanings:

- unit selection;
- ally command selection;
- move destination selection;
- attack target selection;
- unique-skill target selection;
- strategy placeholder/selection where current behavior exists;
- facing selection;
- resolving;
- enemy turn;
- battle complete.

The guidance surface must state the next action and the cancel/back rule where applicable.

## 2.5 Commands

Production command controls must have stable command IDs distinct from their visible Korean labels.

At minimum, preserve and represent currently implemented commands:

- normal attack;
- unique skill;
- defend;
- wait;
- facing confirmation/selection;
- end turn;
- auto battle;
- retreat where valid;
- cancel/back.

Concrete mismatch to fix:

- A visible control labeled `이동` must not call `_on_defend_button_pressed()`.
- For T08-2, either connect a true move command to an `이동` control or label the existing defend handler as `방어`.
- Do not silently change gameplay behavior while correcting the label/handler contract.

Every disabled production command must expose a Korean reason through `DisabledReasonLabel`, tooltip text, or both.

## 2.6 Battle Log

Use one canonical recent-event source.

- The visible production log must not diverge from a hidden legacy log.
- Existing battle-log append behavior may remain internally, but one refresh path must feed the production log.
- Default compact view may remain limited to the existing recent-line policy.
- No debug-only IDs or English internal state names appear in user-visible log text.

---

# 3. UI State Adapter Contract

Introduce one normalized production-HUD state boundary.

Recommended new helper path:

```text
scripts/battle/ui/battle_hud_state_adapter.gd
```

The exact implementation may be a `RefCounted` helper or a narrowly scoped adapter owned by the controller, but it must produce one normalized dictionary or typed value consumed by one production refresh function.

## Required Normalized State

The adapter output must cover at least:

```text
turn
max_turn
active_side
phase
battle_title
ally_momentum
enemy_momentum
ally_roster
enemy_roster
left_actor
right_subject
right_subject_role
center_context
instruction
disabled_reason
command_states
recent_log
battle_complete
```

Per-unit normalized presentation state should include only available data, such as:

```text
unit_id
hero_id
display_name
portrait
unit_type_id
unit_type_name
current_troops
max_troops
hp_ratio
action_state
status_entries
unique_skill_ready
reinforcement_state
alive
visible
```

## Single Refresh Entry

Create one controller entry point, for example:

```gdscript
_refresh_production_battle_hud(reason: String = "")
```

The exact name may differ, but there must be one identifiable production refresh path.

It must update:

- top values and momentum slots;
- side rosters;
- actor/right-subject panels;
- guidance and disabled reason;
- command enabled/disabled state;
- compact log;
- production visibility around cutins/toasts/results.

Do not scatter final production label formatting across unrelated battle functions.

## Required Refresh Triggers

Refresh after all state changes that can alter player-visible information, including:

- initial reset;
- WorldMap battle-context application;
- roster construction;
- snapshot restore;
- round/turn transition;
- active-unit change;
- unit selection;
- command-phase change;
- move target selection/cancel/commit;
- attack target selection/cancel/commit;
- unique-skill target selection/cancel/commit;
- strategy state where current behavior exists;
- facing selection/cancel/commit;
- damage, healing, defeat, retreat, reinforcement, status change;
- momentum gain/spend/loss;
- cutin enter and exit;
- auto-battle toggle;
- battle result transition.

A practical wrapper or deferred refresh may be used to avoid duplicate updates during one resolution sequence, but stale UI is not acceptable.

---

# 4. Cutin, Toast, and Result Visibility Contract

Working cutin media remains untouched.

Before a full-screen presentation:

- capture the relevant production HUD visibility/phase state;
- suppress only the layers that should not compete with the presentation;
- preserve battle data and selection state unless the action commits a state transition.

After presentation:

- restore the production HUD from current authoritative battle state through the single refresh path;
- do not restore stale pre-cutin labels by copying old text;
- keep result UI authoritative after battle completion;
- prevent the command HUD from reappearing after victory/defeat.

Round, reinforcement, unique-skill, retreat, and result presentations must not leave the production HUD in a hidden or stale state.

---

# 5. Layout and Safe-Zone Contract

Author for `1920 × 1080` first.

- Top HUD remains compact and centered.
- Ally roster uses the left-edge safe zone.
- Enemy roster uses the right-edge safe zone.
- Actor comparison and commands use the lower safe zone.
- The battlefield center remains dominant.
- Existing five-unit deployment and reinforcement positions remain visible enough to play.
- Floating commands must avoid active unit, target, reachable cells, and production side panels.
- No critical labels or buttons clip at 1920×1080.
- Final Hanseong landmark validation is deferred to T08-4, but the skeleton must reserve castle/camp visibility.

T08-2 must not move gameplay slots solely to make placeholder panels fit unless a separate audited scene-layout migration is required.

---

# 6. Legacy Migration Strategy

The transaction must be reversible and low risk.

1. Add `ProductionHudRoot` and required nodes.
2. Bind the new hierarchy through the normalized refresh path.
3. Keep legacy panels/nodes present.
4. Hide or bypass legacy surfaces only after the matching production surface updates correctly.
5. Do not delete legacy nodes or functions yet.
6. Record every legacy surface still required after T08-2.

Expected legacy candidates to hide after parity is proven:

- old top bar presentation;
- hidden left/right test panels;
- duplicated mini-log source;
- old unit close-up surface where actor comparison replaces it;
- old formation-guide panels where production rosters replace them;
- old command presentation where production commands replace it.

Cutin, result, battlefield-local unit visuals, overlays, and tactical markers are not considered legacy for removal in this transaction.

---

# 7. Validation Requirements

## Automated Validation

Add a focused validator, following repository conventions, that verifies at least:

- `ProductionHudRoot` exists in the battle scene;
- required major child roots exist;
- ally momentum has exactly ten scene-authored slots;
- enemy momentum has exactly ten scene-authored slots;
- turn and momentum labels are separate;
- three main and two reinforcement roster slots exist per side;
- actor comparison left/center/right roots exist;
- interaction guidance and disabled-reason nodes exist;
- one production refresh entry exists;
- no major production momentum root is created only at runtime;
- production command label/handler mapping does not preserve the known `이동`→defend mismatch;
- required user-facing labels contain no raw internal IDs in the static scene;
- existing T06/T07 validators still pass.

## Godot Checks

Run locally:

- project parse/headless load;
- `Battle_Land.tscn` load;
- focused T08-2 validator;
- existing battle momentum validator;
- existing five-unit-type validator;
- any currently required battle/cutin/snapshot validator affected by modified files.

Warnings or errors introduced by T08-2 are blockers.

## User F5 QA Gate

T08-2 is not visually complete, but F5 must confirm:

- battle starts normally;
- top ally/enemy momentum reads `3 / 10` at a fresh battle;
- turn reads `1 / 30` at a fresh battle;
- side rosters show the actual WorldMap/test roster without stale slots;
- selected/current actor appears on the left comparison panel;
- right panel switches among standby, next AI, selected target, and retaliation contexts when those states occur;
- commands still execute the same battle actions;
- disabled reason is readable in Korean;
- battle log updates in the visible production log;
- cutin returns to the correct HUD state;
- reinforcement, retreat, victory/defeat, and save/resume do not leave stale production UI;
- no critical overlap or clipping at 1920×1080.

Final visual approval is deferred to T08-3 and T08-4.

---

# 8. Required Documentation Update

At completion, update:

- this transaction document with modified files, validation evidence, F5 status, and remaining legacy nodes;
- `agent/CURRENT_STATE.md`;
- `agent/NEXT_TASKS.md`;
- `agent/HANDOFF_TO_CODEX.md`;
- `agent/CHANGELOG.md` if repository workflow requires it.

## Completion State

T08-2 is complete only when:

- the production HUD skeleton is scene-authored;
- one normalized state adapter and one production refresh path drive it;
- existing battle actions remain functional;
- the known command-label mismatch is eliminated;
- automated checks pass;
- local Godot load passes;
- user F5 QA is recorded as PASS or the exact remaining defect is documented.

## Implementation Record

- ProductionHudRoot, top HUD 20 momentum slots, both five-slot rosters, actor comparison, guidance, log, tooltip, command, and facing roots were scene-authored in Battle_Land.tscn.
- battle_hud_state_adapter and _refresh_production_battle_hud provide the normalized production refresh boundary; legacy floating defend now reads 방어.
- PASS: focused T08-2 validator, T06/T07 transaction validator, five-unit completion, damage parity, and git diff --check.
- Godot headless and local F5 were not run because the configured executable is unavailable to this execution environment.
- Retained legacy surfaces: TopBar, BattleMiniLogPanel, FormationSlotGuideLayer, UnitCloseupPanel, CommandBar/floating commands, cutin/result/toast layers, and tactical markers.

## T08-2-hotfix1 Record

- User F6 FAIL root cause: a standalone `+` line immediately before ProductionHudRoot caused a cascading vanished-parent scene-instantiation failure; it was removed.
- Renamed the roster refresh local `visible` to `should_show_slot`, preserving `slot.visible` engine-property writes.
- Production refresh now hides redundant legacy TopBar, formation guide, mini-log, and close-up surfaces when the production HUD is visible. Empty actor/subject/center surfaces collapse; the reserved T09 field is hidden and empty by default.
- The focused validator now rejects patch/conflict residue, parses parent paths and declaration order, checks HUD rect/default visibility parity, and rejects local `visible` declarations.
- PASS: focused T08-2-hotfix1 validator plus T06/T07 and T07 five-unit validators. Godot headless was unavailable in this execution environment; user F6 retest remains pending.

## Commit Message

```text
feat: add production battle HUD skeleton and state adapter
```

## T08-2B Recovery / Isolation Record

- The current Production HUD scene was preserved unchanged at `tests/scenes/Battle_UI_Production_Test.tscn` for F6 and future T08-3A work.
- Runtime `Battle_Land.tscn` now uses the inspected pre-T08 legacy HUD layout. Current battle resources, unit-type nodes, cutin/result/toast nodes, root script, WorldMap handoff target, and latest floating defend label remain present.
- `ProductionHudRoot` is intentionally absent from the runtime scene. Its controller reference and refresh route are optional/null-safe; the full HUD remains active in the test scene.
- `tools/validate_t08_2_production_hud.py` now validates the production test scene, and `tools/validate_t08_battle_scene_isolation.py` enforces runtime/test separation, NodePath/resources, momentum/turn and WorldMap entry contracts.
- Static validation PASS. Godot executable path in `agent/LOCAL_ENV.md` was unavailable in this session; user F5/F6 QA is pending. T08-3A was not started.
