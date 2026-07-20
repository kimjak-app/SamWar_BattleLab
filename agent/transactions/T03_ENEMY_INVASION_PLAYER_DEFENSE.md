# T03 ENEMY INVASION & PLAYER DEFENSE COMPLETION

Status: `DESIGN LOCKED / IMPLEMENTATION NOT STARTED`.

This transaction completes restrained Korea-MVP AI war selection, AI expedition logistics, player defense formation, direct or automatic defense, AI-versus-AI resolution, battle presentation, atomic settlement, persistence, and duplicate protection. T02 remains the protected baseline for supply, casualty categories, wounded recovery, occupation, faction elimination, and result idempotency.

## Player-Visible Transaction

When the player ends a turn, eligible Korea AI cities may attempt at most one invasion. An AI attack on a player city opens a defense choice. Direct defense enters the existing `Battle_Land` scene after player formation; automatic defense uses a separate deterministic resolver. An AI attack on another AI city is resolved automatically.

Automatic results are applied and checkpointed before presentation. At the next player-turn presentation boundary, the WorldMap darkens, plays the generic five-second AI battle video, then replaces the same panel with a result report. Skipping the video skips only presentation and never changes the already committed result.

## Locked Korea MVP Scope

- Active cities only: Hanseong, Pyongyang, Gyeongju, and Sabi.
- Active factions are the runtime owners of those cities: Joseon, Goguryeo, Silla, and Baekje.
- The selected player faction is never hard-coded; all remaining active factions are AI.
- Inactive China, Japan, and naval content remains preserved and does not enter T03 candidate selection.
- Different active Korea faction ownership is hostile for this MVP. Diplomacy, treaties, neutrality, and relationship-weighted war require a later transaction.

## Existing-Structure Audit Lock

1. The legacy AI invasion roll is globally aggressive (`45%`) and searches enemy-to-player adjacency only. It has no sufficient resource gate, peace grace, or global cooldown.
2. Player defense formation exists, but the current automatic-defense route does not provide a genuine separate strategic resolver.
3. Existing enemy-invasion BattleContext supply is incomplete; defense contexts can carry zero gold, food, and salt instead of the authoritative city stock.
4. AI attackers do not currently create a T02-equivalent gold/food/salt expedition cargo transaction.
5. Strategic side identity is attacker AI and defender city owner; the tactical mapping must continue to place the player on the ally side when defending.
6. Legacy enemy-invasion settlement is not at T02 occupation, casualty, wounded, ownership-cache, and defeated-faction parity.
7. `Battle_Land` already enforces the absolute 30-turn cap; reaching turn 30 without capture is a defender victory.
8. Save/load currently clears pending enemy-invasion state. T03 must persist the event and presentation/result guards needed to resume without losing or duplicating an action.
9. Candidate selection must be scenario-scoped instead of scanning every retained WorldMap region.
10. T02 supply arithmetic, loss splitting, wounded queues, occupation helpers, ownership-cache rebuilding, elimination checks, and applied-result IDs are reusable when invoked through side-neutral T03 boundaries.
11. The player-attack handoff rollback is not a valid player-defense rollback. T03 requires its own pre-handoff snapshot and rollback route.

## Restrained AI War Policy

Hard eligibility and willingness are separate.

An attack candidate must satisfy all of the following:

- attacker and target are different runtime factions;
- both cities belong to the active Korea scenario and are adjacent;
- the attacker is AI-controlled;
- neither faction is already defeated;
- attacker city healthy troops are at least `160`;
- at least one battle-eligible stationed general can command the expedition;
- at least one healthy soldier remains in the source-city garrison;
- the source city can pay required gold and at least one initial food-consumption turn;
- no unresolved T03 transaction blocks a new invasion.

MVP willingness rules:

- no AI invasion during the first three completed world turns of a new game;
- base invasion chance is `20%` per enemy phase when candidates exist;
- at most one invasion occurs in the entire active scenario per enemy phase;
- any invasion starts a two-turn global war cooldown;
- an eligible adjacent pair is chosen without player-target bias;
- target-strength weighting is deferred until it has an explicit balance rule.

These values are T03 balance constants and must have focused deterministic tests.

## Force Formation And Logistics

The AI expedition is formed only from the attacking source city's authoritative healthy troops, stationed battle-eligible generals, and `resource_stock`. It leaves at least one healthy garrison soldier. Command caps and existing general eligibility rules apply.

Gold uses the T02 expedition price: `20 gold / 100 troops`. AI food loading targets the 30-turn battle ceiling, limited by source-city stock. Optional salt loading targets the same endurance and is also limited by stock. Confirmation atomically detaches generals, troops, gold, all loaded food types, and salt into the pending transaction; failed handoff or validation restores the snapshot exactly once.

The defending city uses its own healthy troops, eligible stationed generals, and city `resource_stock`. Direct player defense allows the player to choose eligible generals and troop allocations. Automatic player defense uses the same eligible pool and deterministic automatic allocation policy used by AI defenders.

## Multi-Food Supply Contract

Each battle side uses a food-stock map rather than a single runtime food balance:

```text
food_stock = { rice, barley, seafood }
```

- At each consumption boundary, consume the food with the greatest remaining amount.
- Stable tie order is `rice`, then `barley`, then `seafood`.
- If the current food reaches zero, spill the unmet need into the next greatest stock during the same battle turn.
- Desertion occurs only when total food across all three types cannot cover that turn's final need.
- Salt shortage keeps the T02 rule that increases aggregate food need by `10%`.
- BattleResult returns every remaining food amount, remaining salt, and the current selected food type for UI/reporting.
- Legacy single-food BattleContext keys are normalized into the map for compatibility and remain readable during migration.
- T02 player invasion may continue loading one selected food type; the new runtime map still represents that cargo correctly. Expanding its deployment UI to load multiple foods is not silently included in T03.

## BattleContext Side Contract

Strategic fields stay role-based and never depend on player identity:

- `attacker_*`: invading city, faction, generals, troop allocation, and expedition cargo.
- `defender_*`: target city, owner faction, generals, troop allocation, and city supply snapshot.
- `player_side`: `attacker`, `defender`, or empty for AI-versus-AI.
- `resolution_mode`: `direct` or `automatic`.
- `transaction_id`: deterministic identity for the one strategic battle.

For direct player defense, WorldMap converts strategic defender to the tactical ally side and strategic attacker to the tactical enemy side. Battle_Land remains a consumer of prepared context and never chooses armies or mutates WorldMap ownership directly.

## Deterministic Automatic Resolver

Automatic resolution is a separate module and does not run a hidden reduced version of `Battle_Land`. It accepts normalized BattleContext and produces the same strategic BattleResult schema used by settlement.

Recommended module boundaries:

- `scripts/worldmap/t03/auto_battle_resolver.gd`
- a side-neutral extension of the existing battle-supply runtime, or a small T03 multi-food helper if changing the shared class would risk T02 behavior

The resolver simulates at most 30 abstract rounds:

1. consume both sides' food and salt once;
2. apply food-shortage deserters;
3. compute both sides' bounded combat power;
4. apply simultaneous combat losses;
5. stop when one side has no healthy troops;
6. otherwise continue, with turn 30 producing defender victory.

Locked balance shape:

- troop count is the dominant factor;
- leadership, war, attack, and defense provide bounded general modifiers;
- existing city-defense and applicable technology modifiers are reused rather than duplicated;
- troop-type matchup is capped at `±5%`;
- unique-skill presence contributes at most `+5%` as a documented automatic-battle modifier and does not execute tactical skill scripts;
- deterministic random swing is capped at `±5%`;
- the random seed derives from `transaction_id`, so reload/retry produces the same result.

Exact coefficient arithmetic must be written beside focused tests before runtime implementation. It may not make hero stats, matchup, skills, or randomness outweigh the deployed army without an explicit design revision.

Combat losses reuse T02's no-rounding-loss split into healthy survivors, wounded, and dead. Supply loss is recorded separately as deserters. The result records completed round, winner, every casualty category, surviving generals, and remaining cargo/supply for both sides.

## Direct Defense Flow

1. Persist pending invasion event and transaction identity.
2. Show attacker, target, and direct/automatic defense choices.
3. For direct defense, open player defense formation without strategic mutation.
4. On final confirmation, atomically detach both sides into BattleContext.
5. Hand off to `Battle_Land`; if the transition fails, restore the exact pre-handoff snapshot.
6. Consume a matching BattleResult once, settle it atomically, checkpoint, and queue the result presentation.

Retreat by the defender is an attacker victory and city occupation. Closing or cancelling before final confirmation mutates nothing.

## Automatic And AI-Versus-AI Flow

Automatic player defense and AI-versus-AI use the same resolver. AI-versus-AI never opens `Battle_Land` and never waits for player formation. Settlement happens immediately within the enemy phase, while its presentation is queued for the next player-turn boundary.

Presentation source:

- committed source: `assets/video_source/worldmap/ai_faction_battle_source.mp4`
- runtime target: `assets/ui/worldmap/videos/ai_faction_battle_theora_q8_1280x720.ogv`
- source specification: H.264/AAC, 1280x720, 25 fps, five seconds
- target display: centered 16:9 panel, normally 1152x648 at 1920x1080

During the video, display only neutral attacker/defender labels. After playback or skip, replace that panel with the detailed result report. A report example includes attacker, target, winner, and returning healthy/wounded troops. Presentation acknowledgement is persisted so it cannot replay indefinitely.

## Settlement Contract

All paths settle by strategic attacker/defender side, not player/enemy labels.

- Defender victory: ownership is unchanged. Attacker surviving generals, healthy troops, and wounded return to the source city; attacker expedition cargo is lost. Defender survivors and wounded remain in the target city, and consumed defender supplies remain deducted.
- Attacker victory: target ownership changes to the attacker faction. Surviving attacker generals, healthy troops, wounded, and remaining cargo stay in the occupied city. The occupied city has no governor.
- Losing defender generals are never deleted. T02's adjacent same-faction retreat/alignment and last-city rules apply unchanged.
- Ownership mutation rebuilds player-city aggregation and AI ownership caches, then checks faction elimination and Korea player victory/defeat.
- The same settlement rules apply whether either side is player-controlled or both are AI-controlled.

## Persistence And Duplicate Protection

Persist at minimum:

- pending invasion event and its roll/world-turn identity;
- deterministic `transaction_id` and resolver seed inputs;
- transaction stage needed to resume or safely roll back;
- applied `result_id` registry;
- queued automatic-battle result reports and acknowledgement state;
- global peace-grace/cooldown state.

The full live BattleContext may remain transient only after a confirmed strategic snapshot can restore or resume safely. Result settlement writes a checkpoint before presentation. Reapplying an already consumed result or replaying presentation must be a no-op. A transaction ID should be derived from stable inputs such as T03, world turn, attacker city, and defender city rather than wall-clock time.

## Technology Boundary

Reuse only technology effects already evidenced by current helpers, including applicable national/city battle and city-defense modifiers. T03 does not invent new technology values. AI receives the same applicable effects as a player-controlled faction when the authoritative runtime technology state supports it. Unknown effects remain `Needs Runtime Audit` and must be listed in implementation evidence.

## Implementation Sequence

### T03-A — Contracts And Pure Calculation

- define normalized side-aware BattleContext/BattleResult extensions;
- implement and test multi-food consumption with same-turn fallback;
- implement deterministic force allocation and automatic resolver;
- verify 30-turn defender victory and casualty conservation.

### T03-B — Restrained AI Selection And Transaction State

- scenario-scoped candidate collection;
- peace grace, chance, one-war limit, and cooldown;
- AI force/cargo construction;
- pending-event persistence and rollback snapshots.

### T03-C — Player Defense And Settlement Parity

- direct/automatic defense choice and formation;
- correct tactical side handoff;
- T02-parity result settlement for every player/AI side combination;
- ownership cache, elimination, victory/defeat, checkpoint, and duplicate guards.

### T03-D — AI Battle Presentation

- convert and import the supplied video;
- implement dimmed WorldMap video panel, skip, result-card replacement, and report queue;
- persist acknowledgement and verify presentation never controls settlement.

### T03-E — Integrated QA And Completion Lock

- four starting factions: AI attacks player, player direct defense, and player automatic defense;
- AI-versus-AI attacker/defender combinations;
- every food fallback order, salt exhaustion, total-food exhaustion, and desertion;
- attacker/defender victory, turn limit, retreat, occupation, last city, elimination, and unification;
- save/reload before choice, after confirmation boundary, after settlement, and before/after report acknowledgement;
- duplicate BattleResult and duplicate report replay attempts;
- F5 manual QA and final Editor Output verification.

## Acceptance Gate

T03 becomes `COMPLETE` only when one playable persisted enemy phase supports restrained AI war selection, player direct and automatic defense, AI-versus-AI battle, side-correct logistics and settlement, the 30-turn rule, saved result reporting, and all four Korea starting factions without changing protected T02 behavior.

## Explicit Non-Goals

- diplomacy, treaties, alliances, hostility scores, or peace negotiation;
- multi-war enemy phases;
- strategic target-strength weighting or faction personality;
- tactical playback of AI-versus-AI battles;
- prisoner/recruitment/loyalty implementation;
- multiple-food selection UI for the existing T02 player invasion transaction;
- broad WorldMap or Battle_Land refactoring unrelated to T03.
