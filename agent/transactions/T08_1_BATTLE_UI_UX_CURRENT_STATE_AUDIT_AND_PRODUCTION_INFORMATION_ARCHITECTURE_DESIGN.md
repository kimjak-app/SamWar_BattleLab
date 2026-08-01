# T08-1 Battle UI/UX Current-State Audit & Production Information Architecture Design

## Transaction Status

`AUDIT COMPLETE / PRODUCTION IA LOCKED / IMPLEMENTATION NOT STARTED`

## Purpose

Audit the current `Battle_Land` presentation and runtime bindings, identify structural and UX risks, and lock a production information architecture before any major scene rewrite or final art integration.

This transaction changes documentation and planning contracts only. It does not change battle behavior, terrain behavior, balance, AI, cutins, save/load, or production scene layout.

## Audited Baseline

- Repository: `kimjak-app/SamWar_BattleLab`
- Branch: `main`
- Audit starting commit: `990a0f9c67f4150ca15ebefe896b5970b0f22a47`
- Main battle scene: `Battle_Land.tscn`
- Main battle controller: `scripts/battle_web_import_test.gd`
- Momentum source: `scripts/battle/battle_momentum_state.gd`
- Production target: `1920 × 1080`, 16:9

## Protected Contracts

- T01–T05 Korea Four-City MVP campaign and battle handoff remain protected.
- T06 hero authority, unique skills, cutins, portraits, Korean display, momentum, result settlement, save/load, and enemy multi-actor flow remain protected.
- T07 canonical five-unit-type behavior and visual metadata remain protected.
- Momentum starts at `3` and is capped at `10`.
- Maximum battle turn is `30`.
- Player and AI continue to share authoritative battle rules.
- T08 does not implement T09 terrain or T10 cooperative/common-tactic behavior.

---

# 1. Current-State Audit

## 1.1 Scene and Controller Coupling

`Battle_Land.tscn` is a very large single scene containing:

- battlefield art;
- unit slots and visual roots;
- click areas and markers;
- grid and range overlays;
- ally/enemy formation guides;
- top bar;
- battle-supply panel;
- hidden left/right test panels;
- mini battle log;
- bottom command bar;
- floating command panel;
- facing controls;
- round and skill toasts;
- cutin layers;
- result layers;
- reinforcement presentation;
- temporary QA guides and template nodes.

`scripts/battle_web_import_test.gd` owns both battle behavior and a large amount of UI state, layout adaptation, formatting, animation, runtime-node creation, scene-node binding, WorldMap handoff, cutins, results, logs, supply, momentum, overlays, AI presentation, and debug output.

### Finding

The existing structure is functional but test-oriented. A decorative reskin of current panels would preserve the same coupling and stale-state risk. T08 must establish a clearer scene hierarchy and a narrower UI-state adapter rather than only replacing textures.

## 1.2 Mixed Coordinate and Resolution Systems

Confirmed current scene evidence includes:

- full battle/UI guides authored across `1920 × 1080`;
- a main camera centered around `960, 540`;
- top, side, and bottom panels placed with explicit 1920×1080 offsets;
- some cutin/toast roots and older rules still using `1152 × 648` assumptions;
- `agent/GODOT_RULES.md` still describing `1152 × 648` as the standard battle viewport.

### Finding

The repository contains a legacy-resolution contract alongside the newly locked 1920×1080 production target. T08 must make 1920×1080 authoritative for battle UI layout while preserving cutin/video scaling compatibility.

## 1.3 Hardcoded Absolute Layout

The current UI relies heavily on absolute offsets, including:

- top bar;
- hidden left/right panels;
- mini log;
- formation guide panels;
- command bar;
- floating commands;
- facing selection;
- close-up panel;
- toast and cutin locations;
- unit-adjacent state frames and arrows.

### Finding

Absolute placement is acceptable for the initial 1920×1080 art direction, but the current hierarchy lacks clean production anchors and safe-zone ownership. T08 should use scene-authored anchor roots and containers where appropriate, with explicit 1920×1080 authoring first and scaling checks afterward.

## 1.4 Runtime-Created Major HUD Risk

The controller calls `_ensure_runtime_momentum_hud()` during `_ready()` and also contains `ensure/configure` patterns for HUD elements.

### Finding

Creating or ensuring a major momentum layout at runtime conflicts with the repository's editor-first Godot rule. The production momentum frame, slots, labels, and roots must exist in the scene. Runtime code should only update values, visibility, and animation.

## 1.5 Top-Bar Information

Current top-bar behavior includes:

- a large text title/status label;
- an ally/enemy turn banner;
- battle title formatting from WorldMap context.

Momentum is not part of a stable scene-authored top-center production hierarchy.

### Finding

The top bar does not yet express the final hierarchy: ally momentum `x/10`, turn `x/30`, enemy momentum `x/10`, active side, and concise battle title. These must become separate readable elements.

## 1.6 Force Overview Duplication

The scene includes:

- hidden generic left and right panels;
- a visible mini battle log;
- ally/enemy formation guide panels with five MVP slots each;
- unit-local portraits, HP bars, troop labels, status badges, and facing indicators;
- a unit close-up panel.

### Finding

The same hero/unit state is presented in multiple partial forms. T08 must distinguish:

- battlefield-local tactical markers;
- persistent side rosters;
- current actor/target comparison HUD;
- temporary close-up or tooltip.

Each role needs one clear source and one formatter path.

## 1.7 Battle Log Duplication

The controller binds `BattleUI/LeftPanel/BattleLogPreview`, while that panel is hidden. A separate `BattleMiniLogPanel` is visible. The controller also limits current battle-log lines.

### Finding

There is a high risk of updating hidden text while the player reads another log node. T08 must route battle events through one canonical log model and one visible compact view, with optional expanded history later.

## 1.8 Command-System Mismatch

The current scene contains both a bottom command bar and a floating ally command panel.

The floating panel includes:

- basic attack;
- unique skill;
- tactics;
- move;
- wait.

The controller currently connects the floating button named/labeled as move to `_on_defend_button_pressed()`.

### Finding

This is a concrete label/action mismatch risk. T08 must define command IDs separately from labels and validate that each visible label matches its handler intent.

The command system also needs explicit Korean disabled reasons rather than silent disabled buttons.

## 1.9 Interaction Phase Presentation

The controller already tracks phases including:

- ally turn;
- enemy turn;
- resolving;
- facing selection;
- attack selection;
- unique-skill target selection;
- strategy selection.

### Finding

The underlying phase model exists, but the production UI does not provide one consistent instruction surface. T08 should derive guidance, command availability, cancel behavior, overlays, and actor/target panel state from one normalized UI phase.

## 1.10 Current Actor, Next AI, and Target State

The controller tracks:

- active unit;
- active side;
- selected attack target;
- selected unique-skill caster/skill;
- current enemy AI actor;
- current attack target;
- enemy attack target;
- move snapshots and facing state.

### Finding

The data needed for the approved bottom comparison HUD already exists in runtime form. T08 must normalize it into:

- left current actor;
- right next AI actor by default;
- right selected target during targeting;
- right retaliation/counterattack target during resolution;
- an explicit state label.

## 1.11 Momentum Presentation

The authoritative momentum state currently confirms:

- `STARTING_MOMENTUM = 3`;
- `MAX_MOMENTUM = 10`;
- side values for ally and enemy;
- spend/gain/loss events;
- serialization and restore.

### Finding

The production HUD must display each side independently as `current / 10` and as a clear ten-stage gauge. T08 changes presentation only. Momentum mechanics are protected unless a separate approved gameplay transaction changes them.

## 1.12 Cutin and Overlay Restoration

The battle scene/controller contains several presentation layers:

- generic cutin overlay;
- hero cutin presentation scene;
- specialty/video cutin layer;
- unique-skill toast;
- round toast;
- reinforcement and retreat toasts;
- result overlay/video.

### Finding

T08 must not replace the working cutin content. It must define one UI-visibility/state restoration contract so the top HUD, roster panels, actor HUD, guidance, command controls, and overlays return to the correct state after every cutin or result transition.

## 1.13 Battlefield and UI Obstruction

The current scene uses a full-screen tactical area with units near screen edges and multiple overlays/panels occupying top, side, and bottom regions.

### Finding

Production safe zones must be validated against:

- all five ally slots;
- all five enemy slots;
- reinforcements;
- near-edge movement and targets;
- floating command placement;
- castle and camp landmarks;
- player-attacker and player-defender role mapping.

## 1.14 Battlefield Art Baseline

The current scene references one general battlefield texture. The Korea MVP requires four visual battlefields: Hanseong, Sabi, Gyeongju, and Pyongyang.

### Finding

Hanseong must be integrated first as the production art and UI master. The remaining battlefields reuse the same camera, UI, scene contract, and technical framing.

## 1.15 Terrain Handoff

Current range/cell overlays and occupancy behavior exist, but T08 is not authorized to add terrain passability or modifiers.

### Finding

T08 may prepare visually readable roads, forests, river, bridges, walls, gates, cliffs, and route choices. T09 alone defines traversable, conditionally traversable, impassable, movement cost, pathfinding, unit-type interaction, AI, modifiers, and persistence.

---

# 2. Locked Production Information Architecture

## 2.1 Persistent HUD

### Top-center

- Ally momentum: `3 / 10` style dynamic display and ten-stage gauge.
- Battle turn: `current / 30`.
- Enemy momentum: `3 / 10` style dynamic display and ten-stage gauge.
- Active side/state accent.

### Top secondary information

- Concise battle title.
- Attacker → defender or battle objective where useful.
- Supply warning access without permanently occupying a large panel.

### Left edge

- Ally roster, five MVP slots maximum.
- Compact portrait/name/unit type/troop/action/status/skill-ready information.

### Right edge

- Enemy roster, mirrored hierarchy.

### Bottom actor-comparison HUD

- Left current actor.
- Right next AI / selected target / counterattack target.
- Center engagement information and state label.

### Bottom or lower corner

- Compact battle log.
- Global commands: auto, end turn, retreat where valid.

## 2.2 Contextual HUD

- Unit-local command panel near selected unit, only when it does not hide tactical cells.
- Move/attack/skill overlays.
- Facing selection.
- Terrain tooltip placeholder, hidden until T09.
- Damage/counterattack preview.
- Disabled-command explanation.

## 2.3 Modal Presentation

- Round toast.
- Reinforcement arrival.
- Unique-skill cutin.
- Retreat/defeat toast.
- Battle result.

Modal presentation temporarily suppresses conflicting controls, then restores the correct normalized UI state.

---

# 3. Locked Interaction/Phase Contract

## Normalized UI phases

1. `battle_intro`
2. `ally_unit_select`
3. `ally_command_select`
4. `move_target_select`
5. `attack_target_select`
6. `unique_skill_target_select`
7. `facing_select`
8. `action_resolving`
9. `enemy_action_preview`
10. `enemy_action_resolving`
11. `round_transition`
12. `cutin_presenting`
13. `battle_result`

The implementation may map existing internal phase IDs into these presentation states without rewriting core battle rules.

## Required phase outputs

Every normalized phase defines:

- current actor;
- optional comparison actor;
- comparison role label;
- instruction text;
- visible command set;
- command enabled/disabled state;
- Korean disabled reasons;
- visible overlays;
- cancel/back behavior;
- whether battlefield input is accepted;
- whether persistent HUD remains visible;
- restoration target after a modal overlay.

---

# 4. Proposed Scene Migration

## Target hierarchy

```text
BattleUI
├─ PersistentHud
│  ├─ TopHudRoot
│  ├─ AllyRosterHud
│  ├─ EnemyRosterHud
│  ├─ ActorComparisonHud
│  ├─ BattleLogHud
│  └─ GlobalCommandHud
├─ ContextHud
│  ├─ FloatingCommandHud
│  ├─ InteractionGuideHud
│  ├─ DisabledReasonHud
│  ├─ FacingSelectionHud
│  ├─ DamagePreviewHud
│  └─ TerrainInfoHud
├─ ToastHud
├─ CutinHud
└─ ResultHud
```

## Migration rules

- Do not delete protected working nodes in the first implementation transaction.
- Add the production skeleton, bind it behind a feature flag or controlled switch if necessary, and validate parity before retiring old presentation nodes.
- Major HUD roots exist in `.tscn`.
- Runtime-created momentum layout is migrated into scene-authored nodes.
- One UI-state refresh adapter updates the production HUD.
- Battle rules remain in existing authoritative runtime paths.
- Layout constants move to scene anchors/containers or explicit layout resources where practical.
- Final node names remain readable and stable.

---

# 5. Initial Production Asset Manifest

All final UI art is text-free unless the text is a fixed non-changing ornament explicitly approved.

## Top HUD

- top_hud_center_frame
- ally_momentum_frame
- enemy_momentum_frame
- momentum_slot_off
- momentum_slot_on_ally
- momentum_slot_on_enemy
- turn_counter_frame
- active_side_accent

## Side rosters

- ally_roster_frame
- enemy_roster_frame
- roster_slot_normal
- roster_slot_active
- roster_slot_acted
- roster_slot_defeated
- roster_slot_reinforcement_locked
- portrait_mask/frame
- unit_type_badge_frame
- status_badge_frame
- unique_skill_ready_badge
- troop_bar_frame

## Actor comparison HUD

- actor_hud_left_frame
- actor_hud_right_frame
- actor_hud_center_connector
- next_action_badge
- selected_target_badge
- counterattack_badge
- expected_damage_frame

## Commands

- floating_command_frame
- command_button_normal
- command_button_hover
- command_button_pressed
- command_button_disabled
- global_command_bar_frame
- auto/end-turn/retreat button states

## Logs and tooltips

- battle_log_frame
- interaction_guide_frame
- disabled_reason_frame
- tooltip_frame
- terrain_info_frame_placeholder

## Bars and indicators

- HP/troop bar background
- ally fill
- enemy fill
- action-ready indicator
- action-complete indicator
- facing indicator frame/arrow treatment

## Battlefield

- Hanseong 4K master
- Hanseong 1080p runtime derivative
- Hanseong UI-safe-zone review overlay
- Hanseong terrain-authoring reference placeholder

---

# 6. Implementation Transactions

## T08-2 Scene-Authored Production HUD Skeleton and UI State Adapter

- Add the target HUD hierarchy in the scene.
- Create normalized presentation state mapping.
- Scene-author momentum, turn, rosters, actor comparison, guidance, log, and global command roots.
- Keep final decorative art provisional.
- Preserve all current actions.

## T08-3 Production UI Art Pack and Theme Binding

- Produce and commit approved text-free UI assets.
- Bind assets through TextureRect/NinePatchRect/StyleBoxTexture or explicit theme resources.
- Keep dynamic values as controls.

## T08-4 Hanseong Battlefield Master Integration

- Produce 4K master and 1080p derivative.
- Integrate without terrain mechanics.
- Validate castle/camp role mapping and safe zones.

## T08-5 Full Interaction, Disabled Reasons, Next-AI/Target HUD, and Cutin Restoration

- Complete phase-dependent interaction UI.
- Fix command label/handler mismatches.
- Add Korean disabled reasons.
- Validate next AI, selected target, and counterattack states.
- Preserve working cutin media and restore UI correctly.

## T08-6 Production QA and Reusable Template Lock

- Player attack and defense.
- Five-unit rosters and reinforcements.
- Move, attack, skill, facing, wait, auto, end turn, retreat.
- Save/resume and result return.
- 1920×1080 overlap/clipping review.
- Lock template for Sabi, Gyeongju, and Pyongyang.

---

# 7. Validator Plan

Add focused validators that confirm:

- required production node paths exist;
- production HUD roots are scene-authored;
- momentum maximum is read/displayed as `10`;
- maximum turn is displayed as `30`;
- ally and enemy roster slot counts support the Korea MVP contract;
- command IDs map to the intended handlers;
- labels do not expose internal IDs;
- no hidden duplicate log is treated as the only updated player log;
- modal cutin states have a valid restoration target;
- required asset paths exist;
- player attack/defense role does not hardcode ally to camp or enemy to castle;
- T08 contains no terrain-cost/modifier behavior.

---

# 8. User F5 QA Gates

## Gate A — Idle and readability

- Hanseong battlefield and production HUD load cleanly.
- Turn and both momentum values are immediately readable.
- No critical overlap or clipping.

## Gate B — Ally interaction

- Current actor updates.
- Commands match labels.
- Move, attack, skill, facing, and cancel guidance is clear.
- Disabled reasons are visible in Korean.

## Gate C — Enemy sequence

- Right actor panel shows the next AI actor before action.
- It changes to the relevant target during resolution.
- Multi-actor enemy flow remains intact.

## Gate D — Cutins and toasts

- Unique-skill cutin plays.
- No stale panels remain over the cutin.
- Correct UI state returns afterward.

## Gate E — Battle-role parity

- Player attacker is staged from the camp side.
- Player defender is staged from the city/fortress side.
- UI remains ally/enemy based while battlefield landmarks remain attacker/defender based.

## Gate F — End-to-end regression

- Reinforcements, auto battle, victory, defeat, retreat, save/resume, and WorldMap return continue to work.

---

# 9. Explicit Non-Goals

T08-1 does not:

- modify `Battle_Land.tscn`;
- modify `battle_web_import_test.gd`;
- generate final UI PNG files;
- generate the Hanseong battlefield;
- add terrain IDs or map metadata;
- add movement costs or impassable cells;
- add cooperative attacks;
- add common tactics;
- rebalance momentum or unit values.

## Completion Decision

T08-1 is complete when this audit and the three authoritative plan documents are committed and project pointers designate T08-2 as the next implementation transaction.