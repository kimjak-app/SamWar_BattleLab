# HANDOFF TO CODEX

Before making changes, read:
1. `agent/WORKFLOW_MANAGER.md`
2. `agent/CODEX_WORKFLOW_RULES.md`
3. `agent/ARCHITECT_AGENT.md`
4. `agent/IMPLEMENTATION_AGENT.md`
5. `agent/QA_AGENT.md`
6. `agent/RUNTIME_QA_AGENT.md`
7. `agent/VISUAL_QA_AGENT.md`
8. `agent/WORLDMAP_RULES.md`
9. `agent/HERO_DATA_CONTRACT.md`
10. `agent/ARMY_DEPLOYMENT_RULES.md`
11. `agent/BATTLE_CONTEXT_CONTRACT.md`
12. `agent/BATTLE_ENGINE_RULES.md`
13. `agent/SKILL_SYSTEM_RULES.md`
14. `agent/GODOT_RULES.md`
15. `agent/CURRENT_STATE.md`
16. `agent/NEXT_TASKS.md`
17. `agent/HANDOFF_TO_CODEX.md`

Follow the autonomous execution and commit rules in `agent/CODEX_WORKFLOW_RULES.md`, including autonomous commit when the task provides an explicit commit message.
At the start of a new Codex session, always follow the `SamWar_BattleLab 자동 작업 권한 헤더` section in `agent/WORKFLOW_MANAGER.md` and `agent/CODEX_WORKFLOW_RULES.md`.
Role-based agent docs are responsibility guides. `agent/CODEX_WORKFLOW_RULES.md` remains the canonical source for task classification, autonomous execution, approval handling, and verification depth.
WorldMap integration must respect the `BattleContext` contract.
BattleEngine must not directly consume global world state.
Worldmap is not implemented yet, but the worldmap -> battle_context -> battle_engine contract direction is selected.

## Local Godot Execution Path
- Godot 실행파일은 설치형이 아닐 수 있으며 PATH에 없을 수 있다.
- Codex는 Godot 검증 전 `agent/LOCAL_ENV.md`가 존재하는지 확인한다.
- `agent/LOCAL_ENV.md`가 있으면 그 안의 Godot 실행 경로를 우선 사용한다.
- PATH의 `godot`, `godot4`, `godot_console`, `godot4_console` 명령이 실패해도, LOCAL_ENV.md의 exe 경로가 있으면 그 경로로 headless 검증을 시도한다.
- `agent/LOCAL_ENV.md`는 김작 로컬 PC 전용 파일이며 git commit 대상이 아니다.

## Stable Baseline
Current stable baseline is:

`v0.67z-3 Strategy Status Badge Near Facing Arrow Patch`

Latest docs/workflow baseline:

`v0.68 Agent Contract Split for WorldMap + Hero Scale Prep`

Latest UI patch:

`v0.68a-fix2 Status Icon Tight Arrow Anchor + Confusion Icon Patch`

## Core Scene And Scripts
- Core scene: `Battle_Fullscreen_Test.tscn`
- Core scripts:
  - `scripts/battle_web_import_test.gd`
  - `scripts/battle_unit_state.gd`
  - `scripts/unit_visual_slot.gd`

Do not modify casually:
- `Battle_Fullscreen_Test.tscn`

## Current Verified State
- Current MVP battle target is stable `5v5`.
- Round flow is stable:
  - `ROUND 1 = 3v3`
  - `ROUND 2 = 4v4`
  - `ROUND 3 = 5v5`
- Enemy AI multi-target engagement is improved and considered stable.
- Hero identity registry is applied by `hero_id`.
- Reinforcement arrival toast is stable.
- Victory / defeat result toast is stable.
- Reinforcement / round / result toast queue is stable.
- Bottom global command bar exists.
- Bottom command bar art-prep structure now exists under `assets/web_battle/ui/bottom_command/`.
- Bottom command buttons are now scene-authored `TextureButton` nodes with the 6 PNG assets connected directly in `Battle_Fullscreen_Test.tscn`.
- `bottom_command_bar_bg.png` is now applied as the scene-authored `CommandBar` background.
- The old black `CommandBar` panel fill is hidden via transparent panel styling.
- Bottom command bar background is treated as MVP-complete and not a blocker for the current baseline.
- 2D editor visibility for the bottom command buttons is restored.
- Legacy large `LeftPanel` / `RightPanel` info panels are hidden/deprecated.
- `BattleMiniLogPanel` and `FormationSlotGuideLayer` are now part of the battle UI.
- Formation slot guide shows only main `3` + reinforce `2` per side and is display-only.
- `UnitCloseupPanel` is hidden and reserved for future popup reuse.
- Formation guide cards now show portrait + name + troop count + troop icon + troop type.
- Formation guide status text is removed; active/reserve distinction is style-based.
- Current locked MVP battle-screen UX is:
  - left ally formation guide `5` cards
  - right enemy formation guide `5` cards
  - lower-left mini log
  - bottom command bar with `3` ink buttons + background panel
  - floating command panel over the battlefield interaction flow
- Floating command panel exists and remains click-to-open.
- Direct move-click UX remains stable.
- Post-move floating panel auto-reopen remains stable.
- Active ally pulse uses the unified root pulse with pivot lock at around `1.5x`.
- `5v5` full auto result path is reachable.
- Headless project / scene launch are expected to remain `0` errors and `GDScript` warnings are expected to remain `0`.
- `AutoBattleButton`, `EndTurnButton`, and `RetreatButton` are now `TextureButton` nodes with existing handlers reused.
- Existing handlers remain reused.
- `RetreatButton` remains a disabled placeholder.
- Current test battle `10` heroes have `hero_id`-based unique skill registry entries.
- Ally manual unique skill use is enabled through `FloatingUniqueSkillButton`.
- Floating unique skill hover tooltip text is intentionally suppressed; button text remains the visible label.
- Formation guide cards include an enlarged `64 x 64` `UniqueSkillReadyIcon` for the currently usable active ally only.
- Deployment markers now sync from scene-authored `Slot` / `UnitVisualRoot` anchors at runtime start and before demo state creation, so moving a unit slot/root in the Godot 2D editor changes the actual deployment marker/grid-cell source as well as the visual group.
- `UnitMarker` nodes are retained as compatibility runtime sync targets and should not be deleted casually.
- Token, portrait, HP bar, troop label, shadow, move dust, click area, READY frame, facing indicator, and status badges are treated as one root-relative visual attachment set through the `UnitVisualSlot` registry.
- Click areas remain scene-level `Area2D` nodes for compatibility, and READY/facing/status overlays remain UI/FX layer nodes, but all are positioned from the slot-synced visual anchor.
- Battlefield status badges now sit tighter to the facing arrow with one ally/enemy/support/reinforce rule: right-facing badges sit left of the arrow, left-facing badges sit right of the arrow, and up/down-facing badges use the nearby arrow side that avoids the unit body center.
- Confusion battlefield badges show turn count only, such as `2`, instead of the old `◎2` form.
- Ally manual unique skill use now requires range/target selection before resolution.
- Unique skill range overlays are purple and valid target cells are gold/orange.
- Unique skill toast backdrop is hidden/transparent so only the cutin image and skill name read visually.
- Unique skill presentation is a caster-anchored ink toast with cutin image + skill name for `2200ms`.
- Unique skills have MVP effects for `cannon_aoe`, `ally_attack_buff`, `self_defense_single`, and `single_damage_adjacent_shake`.
- Unique skill damage numbers are larger red labels and unique skills trigger short camera shake.
- Auto battle can use available ally unique skills before falling back to basic attack / movement / wait.
- Enemy AI can use available unique skills on enemy turns and after movement rechecks.
- Unique skill ranges are first-normalized: melee skills require close engagement and AOE remains mid-range.
- Enemy/auto unique skill selection now checks high-value or fallback-value conditions instead of using every ready skill.
- Enemy movement, approach, and basic attack pressure are restored in full-auto flow.
- Unique skill readiness is cooldown-state based; old one-use gating is removed.
- Directional damage bonus is active for basic attacks, enemy hits, and single-target attack unique skills.
- Directional multipliers are front `1.0`, side `1.15`, back `1.3`.
- Formation guide troop icons are readable again while `UniqueSkillReadyIcon` remains `64 x 64`.
- `SkillInfoPanel` remains deferred and is not implemented in the current scene.
- Detailed unique skill range balance remains deferred.

## Recommended Next Task
- Current stable behavior baseline: `v0.67z-3 Strategy Status Badge Near Facing Arrow Patch`
- Current docs/contract baseline: `v0.68 Agent Contract Split for WorldMap + Hero Scale Prep`
- Next candidates:
  - `v0.68 WorldMap ↔ BattleContext Contract MVP`
  - `v0.68b Hero/Army Deployment Contract MVP`
- 김작 F6 visual QA remains before treating layout feel as final: move `Slots/AllyReinforce01Slot` and confirm ROUND 2 김유신 spawn plus HP/troop/portrait/click/facing/status alignment.
- 김작 F6 visual QA also remains for status badge placement: confirm ally/enemy/support/reinforce badges stay close to the unit, sit just behind or beside the facing arrow, avoid up/down body-center overlap, show confusion as `N`, and do not heavily overlap the face or arrow.

## Important Direction
- Keep the current battle screen interaction baseline stable before new UX/art expansion.
- Enemy AI multi-target engagement is completed stable functionality, not an open known-issue track.
- Scene portrait textures are not the final identity source of truth.
- `capacity_slot_id -> assigned_hero_id -> HERO_REGISTRY` remains the intended identity path.
- Worldmap integration should build on the current stable `5v5` roster/battle contract path.
- The battle engine must not choose heroes directly; it should consume future `BattleContext.roster`.
- Worldmap / army systems own encounter creation, battle type, terrain, region, and `map_variant_id` selection.
- BattleEngine must not directly consume global world state.
- Contract docs for this direction live in `agent/WORLDMAP_RULES.md`, `agent/HERO_DATA_CONTRACT.md`, `agent/ARMY_DEPLOYMENT_RULES.md`, `agent/BATTLE_CONTEXT_CONTRACT.md`, `agent/BATTLE_ENGINE_RULES.md`, and `agent/SKILL_SYSTEM_RULES.md`.

## Do Not Break
Canonical regression guard details are also tracked in `agent/QA_AGENT.md`.

- Damage / move / attack formulas.
- Hero identity registry behavior.
- Reinforcement deploy timing.
- Reinforcement / round / result toast queue.
- Direct move-click.
- Right-click rollback / cancel behavior.
- Floating panel click-to-open behavior.
- Post-move panel reopen.
- Active ally pulse pivot lock.
- Current `5v5` actor / target parity.
