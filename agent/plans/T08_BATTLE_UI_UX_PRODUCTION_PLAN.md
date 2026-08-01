# T08 Battle UI/UX Production Plan

## Purpose

T08 replaces the current test-oriented battle presentation with a production-quality interface for normal play, public demonstrations, crowdfunding, and investment presentations.

The renewed interface is designed once around the Hanseong battlefield and then reused without structural rewrites for Sabi, Gyeongju, Pyongyang, and later regional battlefields.

## Locked Production Target

- Production layout baseline: `1920 × 1080`, 16:9.
- Visual quality target: polished commercial Korean historical tactical strategy game.
- UI implementation target: reusable Godot scene assets and runtime-bound controls, not a flattened screenshot.
- Static decoration and dynamic information remain separated.
- T06 hero, cutin, portrait, unique-skill, momentum, result, and save/load behavior remains protected.
- T07 five-unit-type labels and action eligibility remain protected.

## Locked Top HUD Contract

The top-center HUD must show three separate concepts.

1. Battle turn
   - Current turn and maximum turn, for example `3 / 30`.
   - Maximum battle turn remains `30`.

2. Ally momentum
   - Starting momentum `3`.
   - Maximum momentum `10`.
   - Numeric value, for example `3 / 10`.
   - A clear ten-stage visual gauge or equivalent readable ten-step presentation.

3. Enemy momentum
   - Starting momentum `3`.
   - Maximum momentum `10`.
   - Numeric value, for example `3 / 10`.
   - Same visual grammar as the ally gauge.

Turn and momentum must never be visually merged into one value.

Changing numbers, names, gauges, and status values must be rendered by Godot nodes. They must not be baked into PNG assets.

## Locked Battle-Side Information Contract

### Ally force overview

- Compact vertical roster on the left edge.
- Up to three main units and two reinforcement slots for the Korea MVP.
- Each visible slot may show portrait, name, unit type, troop/HP state, action state, status badges, unique-skill readiness, and reinforcement state.
- The panel must not obscure critical tactical cells.

### Enemy force overview

- Mirrored compact vertical roster on the right edge.
- Same information hierarchy as the ally side.
- The visual treatment may use enemy accent colors but must preserve identical information meaning.

### Current actor and comparison HUD

Bottom-center or bottom-spanning combat HUD:

- Left: current active player-controlled hero or current actor.
- Right default: next computer/AI actor.
- Right during target selection: selected target.
- Right during retaliation resolution: counterattack target.
- The state label must explicitly distinguish:
  - `현재 행동`
  - `다음 행동`
  - `선택 대상`
  - `반격 대상`
- The center area may show engagement direction, distance, expected damage, counterattack availability, side/rear information, and later terrain modifiers.

The HUD must not imply that the right panel is always an enemy target.

## Command and Interaction Contract

The player must understand the current phase without reading debug logs.

Required command states:

- Unit selection.
- Move selection.
- Normal attack target selection.
- Unique-skill target selection.
- Defend/wait.
- Facing selection.
- Strategy/common-tactic placeholder state where relevant, without implementing T10 behavior.
- Cancel/back.
- End turn.
- Auto battle.
- Retreat where currently valid.

Every disabled command must expose a Korean reason through tooltip, status text, or an adjacent explanation area.

Command labels and behavior must agree. A button labeled `이동` must not execute defend behavior, and a button labeled `대기` must not silently execute another command.

## Battle Log and Message Hierarchy

Three message levels are separated.

1. Critical toast
   - Round start.
   - Reinforcement arrival.
   - Hero unique-skill presentation.
   - Defeat, retreat, victory, and defeat results.

2. Interaction guidance
   - Select a destination.
   - Select a target.
   - Select facing.
   - Action unavailable and reason.

3. Battle log
   - Recent deterministic events.
   - Compact default presentation with access to a larger log view later.

Duplicate hidden and visible log sources must be removed or routed through one formatter/state source.

## Static Asset and Dynamic Node Separation

### Static image assets

- Top HUD frame.
- Ally and enemy roster frames.
- Bottom actor/target comparison frame.
- Command button frames and ornamental chrome.
- Battle log frame.
- Momentum slot on/off visuals.
- HP/troop bar frames.
- Unit-type and status badge frames.
- Tooltip and terrain-info frame.

### Dynamic Godot nodes

- Hero names.
- Portrait textures.
- Unit-type names and icons.
- HP/troop values.
- Turn and momentum numbers.
- Gauge fill/slot activation.
- Status text and icons.
- Command enabled/disabled state.
- Battle log text.
- Targeting instructions.
- Damage/counterattack preview.
- Move, attack, skill, and later terrain overlays.

## Godot Scene Architecture Direction

The production UI must be scene-authored and visible in the Godot editor.

Recommended hierarchy:

```text
BattleUI
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
├─ FacingSelectionHud
├─ ToastHud
├─ CutinHud
└─ ResultHud
```

Important visual controls must not be created as major layout nodes during `_ready()`.

Runtime code may update values, state, visibility, animations, and temporary effects. Layout, anchors, safe zones, and major frames belong in the scene.

## Layout Safe-Zone Contract

- The center tactical field remains visually dominant.
- Side rosters use edge-safe zones.
- The top HUD does not cover the main engagement area.
- The bottom actor HUD and command controls preserve enough battlefield visibility for near-edge units.
- Floating commands must avoid the selected unit, target unit, and reachable cells.
- All critical information is checked at `1920 × 1080` first.
- Supported scaling is checked only after the production baseline is stable.

## Hanseong Master-Template Rule

Hanseong is the only battlefield used to approve the production template.

The following must be completed and approved together:

- New top HUD.
- Ally and enemy roster treatment.
- Current actor / next AI or selected target HUD.
- Commands and disabled-state feedback.
- Battle log and guidance hierarchy.
- Cutin return state.
- UI safe zones over the Hanseong battlefield.
- Attacker/defender role presentation.

Only after Hanseong passes user F5 QA may Sabi, Gyeongju, and Pyongyang inherit the template.

## T08 Transaction Sequence

### T08-1 Current-State Audit and Production Information Architecture

- Audit scene nodes, runtime bindings, coordinate systems, duplicated information, stale-state risks, and protected contracts.
- Lock this production plan, battlefield art handoff, and T09 terrain handoff.

### T08-2 Scene-Authored HUD Skeleton and State Adapter

- Create the production scene hierarchy without final decorative art.
- Preserve all battle actions and T06–T07 behavior.
- Create a single UI-state refresh path where practical.

### T08-3 Production UI Asset Pack

- Produce text-free reusable PNG assets.
- Bind NinePatchRect/TextureRect assets to the HUD skeleton.
- Keep dynamic values in runtime controls.

### T08-4 Hanseong Battlefield Presentation Master

- Integrate the approved 4K Hanseong master and its 1080p runtime derivative.
- Validate UI safe zones and attacker/defender landmarks.
- Do not implement terrain rules yet.

### T08-5 Interaction-State and Cutin Integration

- Move, attack, unique skill, defend/wait, facing, cancel, auto battle, end turn, and cutin return.
- Next-AI / selected-target switching.
- Korean disabled-state reasons.

### T08-6 Production QA and Reusable Template Lock

- Full battle flow at 1920×1080.
- Player attack and player defense contexts.
- Five-unit rosters, reinforcements, cutins, victory/defeat, save/resume.
- Lock the template for the remaining Korea MVP battlefields.

## Automated Validation Plan

Validators should confirm:

- Required production HUD nodes exist in the scene.
- No major HUD root is created only at runtime.
- Ally and enemy momentum render against maximum `10`.
- Battle turn renders against maximum `30`.
- No user-visible internal IDs.
- Required commands have bound handlers and Korean labels.
- Command label and execution intent match.
- Cutin/result overlays restore the intended UI state.
- Required art paths exist.
- No critical node path duplication or missing binding.

## User F5 QA Gates

1. Hanseong idle battle screen first impression.
2. Ally unit selection and current-actor HUD.
3. Move selection and cancel.
4. Attack target selection and target HUD.
5. Unique-skill availability, momentum cost feedback, cutin, and return.
6. Enemy multi-actor sequence and next-AI HUD.
7. Reinforcement arrival and side rosters.
8. Player attacking and player defending.
9. Victory, defeat, retreat, and WorldMap return.
10. No overlap or clipping at 1920×1080.

## Non-Goals

T08 does not implement:

- Terrain movement costs.
- Impassable terrain rules.
- Terrain combat modifiers.
- Cooperative attacks.
- New common tactics.
- Final numerical balance.

T08 may reserve visual locations for those systems, but placeholders must not simulate unimplemented gameplay.