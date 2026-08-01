# HANDOFF TO CODEX

## Current locked baseline

- T01–T05 Korea Four-City MVP world-turn, invasion, occupation, logistics, recovery, and unification contracts are protected.
- T06 hero authority, five-stat data, 39 unique skills, shared momentum, resolver integration, battle result parity, cutins, Korean display, portraits, and enemy multi-actor flow are implemented.
- T07 five-unit-type battle parity is implemented with dedicated gunner and mounted-archer visuals.
- T07 status: `IMPLEMENTED / AUTOMATED VALIDATION PASS / DEDICATED VISUALS BOUND / USER F5 QA PENDING`.
- T08-1 UI/UX current-state audit and production information architecture are complete.

## Protected contracts

- `HeroDesignDataRegistry -> HeroRuntimeFactory -> BattleUnitState -> BattleSkillResolver` remains the single-authority hero path.
- Player and AI consume shared unit-type action eligibility and damage metadata.
- Gunner and mounted archer remain canonical unit types and are not forced into the Korea production roster.
- T06 cutin, momentum, unique-skill, Korean display, portrait, result-settlement, and save/load contracts remain protected.
- Momentum starts at `3` and is capped at `10`.
- Maximum battle turn remains `30`.
- Existing side/back multipliers remain protected until T11 unless explicitly rebalanced.
- T08 changes presentation and UI state organization only; no terrain mechanics are added.

## Authoritative roadmap and design package

Read before planning work:

- `agent/plans/T07_T11_BATTLE_ENGINE_MVP_COMPLETION_ROADMAP.md`
- `agent/transactions/T08_1_BATTLE_UI_UX_CURRENT_STATE_AUDIT_AND_PRODUCTION_INFORMATION_ARCHITECTURE_DESIGN.md`
- `agent/plans/T08_BATTLE_UI_UX_PRODUCTION_PLAN.md`
- `agent/plans/KOREA_MVP_BATTLEFIELD_ART_MASTER_PLAN.md`
- `agent/plans/T09_BATTLEFIELD_TERRAIN_HANDOFF_PLAN.md`
- `agent/GODOT_RULES.md`

Official order:

1. T07 — Five Unit-Type Battle Completion
2. T08 — Battle UI/UX Renewal
3. T09 — Battlefield Terrain & Tactical Map System
4. T10 — Cooperative Attack & Common Tactics
5. T11 — Korea MVP Full Balance & Final Battle QA

## Locked T08 visual direction

- Production layout baseline: 1920×1080.
- Top center:
  - ally momentum `current / 10`;
  - battle turn `current / 30`;
  - enemy momentum `current / 10`.
- Left ally roster and right enemy roster.
- Bottom HUD:
  - left current actor;
  - right next AI actor by default;
  - right selected target during targeting;
  - right counterattack target during retaliation.
- Major HUD roots are scene-authored.
- Dynamic names, numbers, portraits, gauges, statuses, logs, and command states remain runtime controls.
- Hanseong is the first and only production template until user F5 approval.
- Defender role maps to city/fortress and attacker role maps to temporary camp regardless of ally/enemy identity.
- T08 does not implement terrain passability, movement cost, or modifiers.

## Next transaction

### T08-2 Scene-Authored Production HUD Skeleton & UI State Adapter

Implement the production hierarchy without final decorative art.

Required scene roots:

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

The exact hierarchy may be adjusted only when required by existing scene constraints, but the information ownership and readable node names must remain.

Required runtime work:

- Map existing battle phases into normalized presentation states.
- Create one coherent production HUD refresh adapter where practical.
- Bind current actor, next enemy AI actor, selected target, and counterattack target.
- Bind turn and ally/enemy momentum values.
- Bind ally/enemy five-slot MVP rosters.
- Bind interaction guidance and Korean disabled reasons.
- Preserve existing move, attack, unique skill, defend/wait, facing, auto, end-turn, retreat, supply, cutin, result, save/resume, and WorldMap-return behavior.
- Keep current working UI available until production parity is validated.

Known audit risks to address:

- Mixed 1920×1080 and legacy 1152×648 presentation assumptions.
- Runtime-created major momentum HUD.
- Hidden legacy battle log versus visible mini log duplication.
- Duplicate unit-state presentations with no single refresh ownership.
- Floating `이동` command currently connected to defend behavior.
- Absolute layout without production safe-zone roots.
- Cutin/toast/result restoration across several overlay systems.

Verification:

- Godot parse/load.
- Existing T06–T07 validators.
- New required-node and binding validator.
- Command label/intent validator.
- No terrain behavior added.
- User F5 gates for selection, move, attack, skill, cutin return, enemy multi-actor flow, reinforcement, and result.

Do not:

- delete working scene nodes;
- integrate final UI PNG assets in T08-2;
- integrate the final Hanseong battlefield in T08-2;
- add terrain, cooperative attack, or common-tactic behavior;
- change battle balance.