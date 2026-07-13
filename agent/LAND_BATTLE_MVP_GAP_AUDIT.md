# Land Battle MVP Full Content Gap Audit

## 1. Baseline

- Repository: `kimjak-app/SamWar_BattleLab`
- Branch: `main`
- Baseline commit: `f24a37f4fc8190f389263b476b0fc09a61fb1414`
- Main battle scene: `Battle_Land.tscn`
- Main battle script: `scripts/battle_web_import_test.gd`
- WorldMap integration: `scripts/worldmap/worldmap_main.gd`

## 2. Audit Method

- Read battle startup, WorldMap context/result handoff, movement/attack/unique-skill/AI/reinforcement/result paths, scene node inventory, assets, and prior Human-QA records.
- Searched the battle, scene, and agent documents for cooperative/assist attack terms; no land-battle implementation match was found.
- Classified only observed behavior as implemented. Missing evidence is marked `Unknown / Needs Manual Confirmation` rather than assumed.
- This is a documentation-only audit; no runtime, data, scene, or asset was changed.

## 3. Current Full Battle Flow

| Stage | Status | Evidence | Gap / risk |
|---|---|---|---|
| Player attack entry | Functional but Placeholder | `_start_player_attack_battle`, deployment payload/confirm functions, `_handoff_battle_context_to_battle_scene`. | Deployment exists but is not a final battle-context brief. |
| Invasion defense entry | Functional but Placeholder | Pending invasion context and `_confirm_defense_deployment`. | Same final brief and cancellation clarity gap. |
| Context receive | Functional | `_read_worldmap_battle_context_handoff`, `_apply_worldmap_battle_context_handoff`. | Context is logged/applied, not shown as a dedicated entry screen. |
| Battlefield startup | Functional | `reset_demo_state`, intro camera, roster/slot setup, `Battle_Land.tscn`. | Final UX/resolution validation needed. |
| Player actions | Functional | Move, basic attack, unique skill, facing, wait/end turn/cancel functions. | Feedback hierarchy and disabled-state explanations incomplete. |
| AI / reinforcement | Functional baseline | Enemy actor/target paths and reinforcement deployment functions. | Rule visibility, edge-case QA, and ally reinforcement decision incomplete. |
| Result / return | Functional but Placeholder | `_get_battle_result_state`, video/toast, payload build, WorldMap consume/apply. | In-battle result report is not yet an MVP-complete summary. |

## 4. Battle Entry Screen

**Status: Missing as a dedicated Battle_Land screen; P1.**

- Existing: WorldMap deployment payload carries source/target city, troops, food/gold/salt availability, naval/siege flags, and heroes (`_build_player_attack_deployment_payload`); defense payload follows the same pattern.
- Existing: WorldMap camera handoff and scene transition are implemented (`_handoff_battle_context_to_battle_scene`, `_start_worldmap_battle_entry_camera_handoff`).
- Missing: a Battle_Land pre-play screen that binds attacker/defender nation/city, commanders, selected roster, troop allocation, objective, supply, reinforcements, terrain when supplied, start, and cancel.
- Unknown / Needs Manual Confirmation: deployment panel final visual quality, its cancel behavior at every entry path, and aspect-ratio behavior.

## 5. Battle Scene Layout

| Area | Status | Evidence | Gap |
|---|---|---|---|
| Top HUD | Functional but Placeholder | `BattleUI/TopBar`, `TurnBanner`. | Objective, remaining forces, clear active-side state, and menu hierarchy need final binding/design. |
| Ally/enemy roster | Functional but Placeholder | Formation guide panels contain portrait/name/HP/status/skill-ready/troop-type elements for capacity slots. | Current values need audited final labels, resource/morale policy, enemy information disclosure, and unavailable-slot treatment. |
| Central battlefield | Functional | Grid, move/attack overlays, unit visuals, facing indicators, damage layer, markers, reinforcements. | Terrain semantics, skill range/target feedback, cooperative indicators, and a final visual language are incomplete. |
| Command UI | Functional but Placeholder | Bottom command bar and floating attack/unique skill/tactics/move/wait controls. | Cancel/action-disabled reason/consistent command ownership need P1 work. |
| Closeup/status | Functional but Placeholder | `UnitCloseupPanel`, status labels, formation guide. | Exact combat data and predicted enemy attack information are not yet a final contract. |

## 6. Command UX

**Status: Functional but Placeholder; P1.**

Existing paths cover direct move, attack selection/cancel, move rollback, unique-skill target selection/cancel, post-move facing, wait, end turn, auto battle, and retreat. Required MVP gaps are clear mode text, legal target/range communication, reason text for unavailable actions, predictable cancellation after every transient mode, and human QA for keyboard/mouse overlap and intro/cutin/result guards.

## 7. Cutin Audit

| Item | Status | Evidence | Gap |
|---|---|---|---|
| Unique-skill static cutin | Functional | Ten `assets/web_battle/skill_cutins/*.png` assets correspond to the ten registry heroes. | Verify every registry path at runtime and define fallback visual quality. |
| Specialty video cutin | Partially implemented | `SkillCutinLayer`, video player, per-hero specialty config and assets for five Korean heroes. | Chinese roster has no verified specialty-video configuration; must use intentional fallback, not implicit failure. |
| Playback safety | Functional baseline | Video load/direct Theora fallback and cutin completion paths exist. | Manual QA still needed for skip behavior, duplicate prevention, camera/HUD restoration, and all asset failure cases. |
| General attack/counter/hit/critical/death cutin | Incomplete | Damage, shake, retreat and toast mechanisms exist. | No unified general-combat cutin specification. |
| Cooperative cutin | Missing | No cooperative implementation match. | Depends on Cooperative Attack MVP. |

## 8. Cooperative Attack Audit

**Status: Missing; P1.**

No code, scene, or documentation implementation was found for cooperative/assist attack. Required before claiming MVP completion: rules for trigger, distance/adjacency/facing/type/relationship, participant cap, lead/support roles, damage/accuracy/critical/counterattack/action cost, skill interaction, reinforcement eligibility, AI policy, player feedback/failure reasons, and a minimal cutin/feedback sequence.

## 9. Full Production Roster Audit Required

**Status: Required P1 inventory and MVP readiness audit; do not infer the full roster from `TEST_BATTLE_ROSTER`.**

Land Battle MVP hero scope includes every hero actually registered and deployed across the Korean, Chinese, and Japanese WorldMap regions. `TEST_BATTLE_ROSTER` is only a tactical sample roster for Battle_Land feature verification and existing unique-skill, cutin, and reinforcement QA; it must not define or limit the production MVP roster.

The authoritative inventory sources investigated for the follow-up are `scripts/worldmap/worldmap_main.gd` WorldMap hero registry/data and its city `stationed_hero_ids`/`hero_ids` assignments. This hotfix does not estimate or write a full hero list. The follow-up must construct the inventory from those actual WorldMap sources, including every Korea, China, and Japan regional deployment.

Required inventory/readiness columns:

| Country | Region | City | Hero ID | Hero name | Affiliation | Unit type | Stats | Normal skill | Unique skill | Static cutin | Video cutin | Cutin fallback | Cooperative relationship/candidate | AI availability | Battle-data completeness | Placeholder | MVP readiness |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Required | Required | Required | Required | Required | Required | Required | Required | Required | Required | Required | Required | Required | Required | Required | Required | Required | Required |

Gaps: no single audited canonical balance sheet across HP/attack/defense/speed/move/range/action economy; cooperative targets are absent; video cutin coverage is asymmetric; and every WorldMap-context hero requires an explicit validation matrix before MVP lock. Cutin, skill, balance, and cooperative-attack audits must use the full WorldMap roster rather than the sample roster.

## 10. Hero / Unit / Skill Balance Audit

**Status: Incomplete; P1 baseline / P2 tuning.**

- Unique skill effects/powers/target modes exist in `UNIQUE_SKILL_REGISTRY` for the sample roster; the full WorldMap inventory must verify each production hero's actual battle skill contract.
- Current observable types include cavalry, infantry, archer, and gunner visual keys, but this audit did not locate a single authoritative type-interaction/terrain/balance table.
- P1: capture the actual baseline, action and cooldown rules, skill target/range, status duration, and AI valuation for every deployed Korea/China/Japan WorldMap MVP hero.
- P2: tune numbers only after a reproducible scenario matrix exists.

## 11. AI Audit

**Status: Simple but MVP-capable baseline; P1 verification.**

Evidence includes actor/target candidate adapters, enemy acted-state tracking, movement/attack flow, auto-battle controls, unique-skill target/value functions, result guards, and Human QA through prior helper locks. Gaps are a visible AI intent policy and a manual matrix for blocked routes, no-action actor, skill decision, facing, reinforcement arrival, and victory/defeat boundary. Cooperative AI is missing because the parent system is missing.

## 12. Reinforcement Audit

**Status: Enemy arrival functional; P1 rule presentation.**

- Existing: capacity slots, visual slots, AI eligibility after deploy, arrival toast, round-2 reinforcement pair and city-reinforcement metadata/arrival for the second pair.
- Confirmed prior Human QA: enemy reinforcement arrival and subsequent turn/AI/battle/result/WorldMap flow `PASS`.
- Ally reinforcement: `NOT APPLICABLE — 현재 전투 구조에서 미지원`; it is not a failed extraction and is Post-MVP unless a player-facing design is approved.
- Gap: arrival rules/source/timing must be shown to the player; sample fixed-round behavior needs a documented MVP rule versus test scaffold distinction.

## 13. Result Screen Audit

**Status: Functional but Placeholder; P1.**

Existing result state is based on alive deployed-side counts; result video paths, video-to-toast fallback, overlay, and WorldMap return-button enablement exist. Current `ResultOverlay` contains backdrop/video/image/title controls. Missing MVP report fields are attacker/defender result, city effect, troop survivors/losses, hero survival/retreat data where authoritative, and a clear explanation of the result applied on return. Capture/XP/merit/loot/relations require separate implemented data contracts and remain unknown/not final.

## 14. WorldMap Handoff Audit

**Status: Functional baseline; P1 QA hardening.**

- Entry: Engine metadata context, WorldMap camera handoff, `change_scene_to_file`, then Battle roster/context application.
- Return: battle result payload is placed in Engine metadata; WorldMap consumes it once through `_consume_worldmap_battle_result_if_any` and dispatches player-attack/invasion apply paths.
- Existing application evidence: city outcome, troop result summary, city selection, panel refresh, post-battle result card, and pending-invasion clearing.
- Gaps: explicitly test all attack/invasion victory/loss/retreat permutations, ensure results are never applied twice after re-entry, and separate final persistent hero consequences from `_apply_invasion_hero_state_placeholder` behavior.

## 15. Asset / Placeholder Audit

| Asset area | Status | Gap |
|---|---|---|
| Battlefield portraits/tokens | Functional baseline | Final per-context coverage and resolution QA needed. |
| Static skill cutins | Functional for ten sample registry heroes | Runtime path/fallback matrix needs verification. |
| Specialty video portraits/titles/videos | Partial | Verified Korean five-hero set; no equivalent verified Chinese specialty-video set. |
| Victory/defeat video | Functional baseline | Asset load fallback and player-facing result report need QA. |
| Cooperative assets | Missing | Cannot be planned as existing content. |
| General combat presentation assets | Incomplete | Requires a bounded MVP visual specification. |

## 16. Bug / Risk Inventory

| Priority | Risk | Evidence / mitigation target |
|---|---|---|
| P0 watch | Context/result loss, duplicate result application, return failure, turn/AI freeze. | Existing guards and prior QA reduce risk, but full roundtrip matrix is required. |
| P1 | No dedicated battle entry context screen. | Context is applied/logged only; implement readable brief and safe cancel. |
| P1 | Result is video/toast-oriented rather than a complete report. | Build report from authoritative payload fields only. |
| P1 | Cooperative attack absent. | Define and implement bounded core system; do not assume present. |
| P1 | Full Korea/China/Japan WorldMap Hero Roster Inventory and MVP Readiness Audit is missing. | Build the inventory from authoritative WorldMap registry/data/city assignments, then create the validation matrix before tuning. |
| P1 | Cutin coverage/fallback asymmetric. | Add asset/fallback matrix and playback QA. |
| P2 | HUD/command presentation hierarchy and resolution behavior. | Final layout/data binding QA. |
| Post-MVP | Ally reinforcement and persistent hero outcomes. | Keep explicit until approved contracts exist. |

## 17. Priority Matrix

| Classification | Items |
|---|---|
| P0 | No confirmed open blocker; maintain entry/turn/AI/result/return regression watch. |
| P1 | Battle entry context screen; command/HUD clarity; result report; cooperative attack; **Full Korea/China/Japan WorldMap Hero Roster Inventory and MVP Readiness Audit**; 전체 월드맵 장수 데이터·스킬·컷인·밸런스 readiness 검증; cutin fallback coverage; reinforcement rule presentation; WorldMap permutation QA. |
| P2 | General combat feedback, audio/transition polish, balance tuning, AI improvement, UI polish. |
| Post-MVP | Ally reinforcement, all bespoke videos, complex cooperative combinations, replay/history, advanced AI/camera, capture/wound/death/loot persistence. |

## 18. Recommended Milestones

1. `v0.73-02 Battle Entry Context Screen MVP` — selected first because the entry contract already exists but the player cannot yet review its applied battle context inside the tactical flow.
2. Battle HUD / command UX finalization.
3. `v0.73-06 Full WorldMap Hero Roster Inventory & MVP Readiness Audit` — inventory and validate every actually deployed Korea/China/Japan WorldMap hero; divide follow-up implementation by nation, region, and hero group based on the audit.
4. Cutin fallback/playback completion.
5. Cooperative Attack MVP.
6. AI and reinforcement presentation/rule passes.
7. Battle Result Screen MVP.
8. Result → WorldMap final handoff QA.
9. Full playthrough QA and MVP Complete Lock.

## 19. Changed Files

- Added `agent/LAND_BATTLE_MVP_COMPLETION_PLAN.md`.
- Added this audit document.
- Updated `agent/NEXT_TASKS.md`.

## 20. Validation

- Baseline HEAD and clean worktree were checked before documentation changes.
- Audit findings were derived from the cited scene/script/assets and previous Human-QA documents.
- Godot project parse: `PASS` (`--headless --editor --path . --quit`).
- `Battle_Land.tscn` headless load: `PASS`.
- Final diff must contain documentation only.

## 21. Next Recommended Task

`v0.73-02 Battle Entry Context Screen MVP`

Reason: it is the highest confirmed P1 gap at the start of the user-visible tactical flow, has an existing WorldMap context contract to bind, and can be scoped without changing combat formulas, AI rules, or result semantics.
