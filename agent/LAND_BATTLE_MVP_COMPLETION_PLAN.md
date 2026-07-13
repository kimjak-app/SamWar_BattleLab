# Land Battle MVP Completion Plan

## 1. Vision

v0.73 changes the goal from safe Stage B helper refactoring to completing one coherent land-battle mode. The mode must be understandable at entry, playable through a full tactical battle, and connected to an authoritative WorldMap outcome.

## 2. MVP Completion Definition

`Land Battle MVP is complete when the player can enter battle from the WorldMap, understand the battle context, play a full battle with the MVP roster and battle systems, view the result, and return to the WorldMap with the result correctly applied.`

한국어 완료 정의:

- 월드맵에서 전투 진입
- 전투 진입 화면에서 상황 파악
- 전장 진입 및 초기 배치 확인
- 배치·이동·공격·스킬·방향·대기 수행
- 컷인과 협동 공격의 MVP 범위 동작
- AI와 증원 진행
- 승패 판정 및 결과 확인
- 결과의 월드맵 반영과 정상 복귀

위 흐름이 막힘 없이 이어질 때만 육상전투 MVP를 완료로 판정한다.

## 3. Full Battle Flow

| Flow step | Current implementation | MVP expected state | Required UI / input / output | Failure point / completion condition |
|---|---|---|---|---|
| WorldMap battle event | Player attack and invasion context builders exist in `scripts/worldmap/worldmap_main.gd`. | One entry contract for attack and defense. | City selection/event, deployment input, validated context. | No context loss; invalid entry gives an actionable message. |
| Deployment / entry preparation | `PlayerAttackDeploymentPanel` is opened through `_open_player_attack_deployment`; defense uses the same deployment family. | Player confirms side, cities, roster, troops, supply, and objective before transition. | Hero/troop allocation, confirm/cancel. | Binding must match the context sent to battle. |
| Battle entry context screen | No dedicated `Battle_Land.tscn` entry-summary screen was found; context is logged and roster applied in `_apply_worldmap_battle_context_handoff`. | A short, readable battle brief before tactical input. | Attack/defense, cities, commanders, units, troops, supply, reinforcements, objective, start/cancel. | Player can identify what battle is being entered and return safely before start. |
| Battlefield load / intro | `Battle_Land.tscn` has intro camera, grid, roster slots, and initial state setup. | Initial camera, deployment, and HUD are readable at supported resolutions. | Skip-capable intro and gameplay UI restoration. | No hidden/blocked input after intro. |
| Player turn | Move, attack select, unique skill target selection, facing selection, wait, end turn, and cancel paths exist in `battle_web_import_test.gd`. | Every command clearly communicates legal targets, cost, and completion. | Command bar/floating panel, overlays, feedback. | No stuck phase or ambiguous cancel state. |
| Cutin / action resolution | Unique-skill toast/cutin, specialty video cutin, damage/status/retreat feedback exist. | Defined fallback and return-to-play behavior for all MVP actions. | Cutin layer, skip/fallback policy, restored HUD. | No duplicate cutin, frozen turn, or missing asset crash. |
| Enemy AI | Enemy actor/target selection, movement, attack, unique-skill evaluation, and end-turn paths exist. | Predictable MVP behavior that always terminates a turn. | AI feedback and errors logged. | No blocked-path or no-action turn lock. |
| Reinforcement | Two slot pairs and arrival flows exist; current sample behavior deploys both sides, with city-reinforcement metadata for the second pair. | Rules explain who arrives, when, where, and why. | Arrival notice, slot/portrait/AI integration. | No overlap, invisible unit, or actor/target inclusion before deploy. |
| Result | Alive deployed-side count produces victory/defeat; video/toast and return button paths exist. | A readable result report precedes return. | Result summary and WorldMap return action. | Result must be finalized once and return payload generated once. |
| WorldMap return | Battle builds a result payload; WorldMap consumes it and applies player attack or invasion outcome. | Cities, troops, selected city/panels, and summary all agree. | Post-battle summary, refreshed WorldMap UI. | No duplicate result application or orphaned context. |

## 4. Battle Entry Screen

The entry screen is MVP scope. It must show attacker/defender nation and city, battle type and objective, terrain when available, commanders, participating heroes, troop type/count, morale/supply when data exists, planned reinforcements, and explicit start/cancel actions.

Current source: WorldMap provides a deployment panel and `_build_player_attack_deployment_payload` with city, troop, supply, route, siege, and hero data. The handoff begins immediately after confirmation. `Battle_Land.tscn` receives and logs context but has no dedicated pre-battle brief. The plan therefore treats an in-battle context brief as the first P1 implementation boundary.

## 5. Battle Scene Main Layout

MVP layout responsibilities:

- Top HUD: turn, active side, objective, remaining forces/pressure, menu, end turn.
- Ally/enemy information: hero, portrait, troop type/count, HP/resource, status, skill readiness, facing, formation/reinforcement state.
- Central field: grid, move/attack/skill ranges, target/facing feedback, terrain, reinforcement entry, damage/heal/status feedback.
- Bottom command area: move, attack, unique skill, facing, wait, cancel, end turn; auto/retreat remain clearly labelled as mode choices.

`Battle_Land.tscn` already contains `TopBar`, side panels, mini log, formation guide panels, command bar, floating command panel, closeup panel, facing controls, range overlays, and unit visual slots. These are functional scaffolding, not yet a final MVP information hierarchy; the Gap Audit assigns presentation/data-binding gaps by element.

## 6. Player Command Flow

The MVP command loop is select unit → inspect → move/attack/skill/wait → choose facing if required → observe resolution → select next unit/end turn. Existing code provides the core actions and cancellation/rollback hooks. MVP completion requires consistent disabled states, a visible reason for unavailable actions, range/target feedback, and a reliable return to the normal turn state after every cancellation, cutin, or failed selection.

## 7. Cutin System

### General battle cutin

General attack, counterattack, hit, critical, death, and retreat feedback should have a minimum readable presentation. Existing code has move dust, damage preview/popups, shake-related paths, retreat toast, and result video/toast; it does not establish a separate full general-combat cutin contract.

### Unique-skill cutin

MVP requires hero image, hero/skill name, optional quote/video, bounded playback, fallback on missing resource, no duplicate playback, restored camera/HUD, and resumed turn flow. The current specialty system contains hero-specific Korean video/portrait/title configurations for Yi Sun-sin, Kwon Yul, Jeong Do-jeon, Gim Yusin, and Eulji Mundeok; the `UNIQUE_SKILL_REGISTRY` contains image-cutins for all ten sample heroes. Missing/unsupported video must remain a fallback-to-static/toast path, not a blocker.

### Cooperative-attack cutin

If cooperative attack enters MVP, its presentation must identify lead/support heroes, attack name, participants, resulting damage, and return-to-turn behavior. It should be designed only after the core cooperative rules exist.

## 8. Cooperative Attack System

Cooperative attack is a P1 design-and-implementation requirement, not an assumed current feature. Current repository search found no land-battle cooperative/assist attack implementation.

The MVP design must explicitly define: trigger/adjacency/distance/facing/unit-type/relationship conditions, participant cap, lead/support ordering, support count, damage/accuracy/critical/counterattack interaction, action cost, skill interaction, reinforcement eligibility, AI use, UI eligibility and failure reasons, and cutin presentation. Complex combinations and replay-grade presentation are Post-MVP.

## 9. MVP Hero Roster

The fixed sample roster in `TEST_BATTLE_ROSTER` is the verified tactical-MVP inventory. WorldMap context can supply different hero data, so non-sample values must be treated as context-driven rather than assumed from this table.

| Nation / side | Hero ID / name | Unit visual type | Base combat data | Move / range | Unique skill | Cutin asset status | Cooperative target | AI | Balance / placeholder | MVP |
|---|---|---|---|---|---|---|---|---|---|---|
| Korea / ally main | `yi_sunsin` / 이순신 | `korea_cavalry` | Context/sample state; no canonical per-hero stat table located in this audit. | Context/sample state. | 학익진, cannon AoE, power 44. | Static image + specialty portrait/title/video. | Unimplemented. | Yes, shared AI path. | Needs explicit balance sheet. | Yes |
| Korea / ally main | `jeong_dojeon` / 정도전 | `korea_gunner` | Context/sample state. | Context/sample state. | 개혁령, ally attack buff. | Static image + specialty assets. | Unimplemented. | Yes. | Needs explicit balance sheet. | Yes |
| Korea / ally main | `kwon_yul` / 권율 | `korea_infantry` | Context/sample state. | Context/sample state. | 행주대첩, ally attack buff. | Static image + specialty assets. | Unimplemented. | Yes. | Needs explicit balance sheet. | Yes |
| Korea / reinforcement | `gim_yusin` / 김유신 | `korea_archer` | Context/sample state. | Context/sample state. | 삼국통일 돌격, self defense/single target, power 50. | Static image + specialty assets. | Unimplemented. | Yes after deploy. | Reinforcement rules need finalization. | Yes |
| Korea / reinforcement | `eulji_mundeok` / 을지문덕 | `korea_gunner` | Context/sample state. | Context/sample state. | 살수대첩 매복, single damage + adjacent shake, power 48. | Static image + specialty assets. | Unimplemented. | Yes after deploy. | Reinforcement rules need finalization. | Yes |
| China / enemy main | `guan_yu` / 관우 | `china_cavalry` | Context/sample state. | Context/sample state. | 언월참, self defense/single target, power 54. | Static image; no verified specialty-video config. | Unimplemented. | Yes. | Needs explicit balance sheet. | Yes |
| China / enemy main | `zhang_fei` / 장비 | `china_infantry` | Context/sample state. | Context/sample state. | 장판파열, single damage + adjacent shake, power 50. | Static image; no verified specialty-video config. | Unimplemented. | Yes. | Needs explicit balance sheet. | Yes |
| China / enemy main | `xiahou_dun` / 하후돈 | `china_infantry` | Context/sample state. | Context/sample state. | 맹장돌파, self defense/single target, power 50. | Static image; no verified specialty-video config. | Unimplemented. | Yes. | Needs explicit balance sheet. | Yes |
| China / reinforcement | `liu_bei` / 유비 | `china_archer` | Context/sample state. | Context/sample state. | 인덕의 깃발, ally attack buff. | Static image; no verified specialty-video config. | Unimplemented. | Yes after deploy. | Reinforcement rules need finalization. | Yes |
| China / reinforcement | `zhuge_liang` / 제갈량 | `china_gunner` | Context/sample state. | Context/sample state. | 팔진도, ally attack buff. | Static image; no verified specialty-video config. | Unimplemented. | Yes after deploy. | Reinforcement rules need finalization. | Yes |

## 10. Unit / Skill / Hero Balance

MVP balance needs a recorded, testable matrix for HP/troop count, attack, defense, speed, movement, range, action economy, skill cost/cooldown, effect duration, and AI valuation. The audit found operational unique-skill effect types and numeric powers in `UNIQUE_SKILL_REGISTRY`, but no single authoritative per-hero balance table for the full roster. Unit visuals include cavalry, infantry, archer, and gunner keys; formal type interactions, terrain effects, and role differentiation need verification before claiming balance complete.

No numbers are changed by this plan. First balance work must capture an evidence-based baseline and scenarios rather than tune ad hoc.

## 11. AI

The existing AI has actor candidates, target selection, movement, facing/action helpers, unique-skill evaluation, acted-state tracking, and result guards. It is sufficient evidence for a functional MVP baseline, but MVP QA must exercise blocked routes, no legal action, end-turn, reinforcement arrival, low-health targets, unique skill decisions, and victory/defeat edge cases. Cooperative attack AI is unimplemented until that system exists.

## 12. Reinforcement

Enemy reinforcement arrival is Human-QA locked as working. The scene and runtime currently support both ally and enemy capacity slots, but the previously locked QA records ally reinforcement entry as `NOT APPLICABLE — 현재 전투 구조에서 미지원`. For MVP, ally reinforcement remains Post-MVP unless a concrete player-facing rule, roster source, entry condition, and WorldMap contract are designed and implemented. MVP must still clearly display enemy arrival timing/source and preserve slot, visual, AI, and result integration.

## 13. Battle Result Screen

Current result behavior is victory/defeat determination, video-or-toast fallback, result overlay, and a WorldMap return button when context/result are available. MVP requires a true result report: attacker/defender outcome, surviving/retreated/dead heroes where data is authoritative, troop losses/survivors, city ownership result, and a clear return action. Captures, XP, merit, loot, relationship changes, and detailed history are explicitly data-dependent and must be shown only when implemented.

## 14. WorldMap Result Handoff

Current handoff uses engine metadata, a battle result payload, and WorldMap apply paths for player attack/invasion. Existing paths handle city result application, troop outcome summaries, selection/UI refresh, and a post-battle summary card. MVP completion requires roundtrip tests for attack victory/loss/retreat and invasion victory/loss/retreat, with no duplicate application after re-entry. Hero capture/wound/death currently has placeholder treatment and must not be represented as final until its persistent data contract exists.

## 15. UX / Presentation Standards

- Text and icons must identify active side, selected actor, legal action, invalid-action reason, target, and action completion.
- Range, facing, status, reinforcement, and result information must remain readable at supported aspect ratios; manual confirmation is required for final resolution coverage.
- Cutins/video must be skippable or timeout-safe, restore the gameplay HUD, and never suppress input after completion.
- Placeholder art/data must be visibly treated as placeholder in planning and not mistaken for final content.

## 16. Priority Classification

- **P0 — progress blocker:** crashes, entry/context loss, turn/AI lock, victory/defeat failure, result apply failure, return failure, or save corruption. No confirmed P0 is recorded by this documentation audit; all require ongoing regression testing.
- **P1 — MVP required:** battle entry context screen, final information hierarchy/command feedback, result report, core cooperative attack rules/presentation, MVP roster data validation, cutin fallback coverage, and reinforcement rule presentation.
- **P2 — completion quality:** general combat presentation, sound/transitions, richer damage/status feedback, balance tuning, AI improvement, and UI polish.
- **Post-MVP:** ally reinforcement system, all heroes receiving bespoke video cutins, complex cooperative combinations, replay/history, advanced AI, detailed statistics, high-end camera work, persistent capture/wound/death/resource-loot features until their contracts exist.

## 17. Milestone Plan

| Milestone | Scope | Gate |
|---|---|---|
| v0.73-01 | Completion plan and full gap audit. | Documentation-only baseline. |
| v0.73-02 | **Battle Entry Context Screen MVP**. | Shows verified context and has safe start/cancel; no duplicate context mutation. |
| v0.73-03 | Battle main HUD information hierarchy and data-binding audit/fix. | Active side, objective, roster/status/resources and command feedback are readable. |
| v0.73-04 | Command UX finalization. | Legal/illegal states, cancel/rollback, facing and skill targeting clear. |
| v0.73-05 | MVP hero roster/data validation and balance baseline. | Every active MVP hero has verified combat/skill/presentation data. |
| v0.73-06 | Cutin asset and playback completion. | Fallback, skip/timeout, HUD/camera restoration, and asset matrix pass. |
| v0.73-07 | Cooperative Attack MVP. | Explicit rules, UI, AI policy, and tests. |
| v0.73-08 | AI MVP behavior pass. | No-action/blocked/reinforcement/endgame cases complete. |
| v0.73-09 | Reinforcement presentation and rules. | Enemy rules visible; ally decision remains explicit. |
| v0.73-10 | Battle Result Screen MVP. | Battle outcome report matches authoritative payload. |
| v0.73-11 | Result → WorldMap final handoff QA/hardening. | Attack/invasion outcomes apply once and refresh correctly. |
| v0.73-12 | Land Battle full playthrough QA. | Full player journey matrix passes. |
| v0.73-13 | Land Battle MVP Complete Lock. | All P0/P1 gates and QA evidence pass. |

## 18. QA Strategy

Use automated parse/headless scene checks for every implementation, plus manual scripted roundtrips for player attack and invasion. Each milestone records tested input, context, roster, skill/cutin path, AI/reinforcement behavior, result, returned WorldMap state, and whether an item was not performed. Do not infer PASS for video, resolution layout, or input behavior from headless output alone.

## 19. Complete Lock Criteria

Land Battle MVP can lock only when all P0/P1 items have an implemented owner, documented data contract, automated smoke coverage where feasible, and Human gameplay QA showing WorldMap entry → context understanding → full battle → result → correctly applied WorldMap return. Known Post-MVP exclusions must be explicit, non-blocking, and not masquerade as completed features.

## 20. Post-MVP Exclusions

The Post-MVP list includes player/ally reinforcement, full bespoke video coverage for every hero, complex cooperative combinations, deep AI, replay/history, detailed combat statistics, advanced camera/sound polish, and persistence systems for capture/wounds/death/loot until their data contracts are implemented.
