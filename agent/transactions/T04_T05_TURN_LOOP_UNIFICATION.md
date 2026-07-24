# T04–T05 KOREA MVP TURN LOOP & UNIFICATION COMPLETION

Status: `COMPLETE — GODOT 4.6 INTEGRATED F5 QA PASS`.

This is one integrated transaction. It completes the player-visible flow from `아군 턴 종료` through enemy actions, city production, domestic/research resolution, recovery, next-turn entry, Korea victory/defeat evaluation, persistence, and terminal presentation.

## Player-Visible Transaction

1. The player ends the current turn.
2. A deterministic T04 transaction ID is created and checkpointed.
3. Active Korea AI cities receive one baseline production tick, then existing reinforcement, strategic action, and T03 invasion logic runs.
4. Player-owned cities receive production in their authoritative city `resource_stock`.
5. Existing upkeep, trade, loyalty, public support, conscription, diplomacy/spy cooldown, research progress/completion, technology effect, and market processing runs once.
6. Month-boundary wounded soldiers and wounded generals recover through the existing recovery contract.
7. The next player turn begins, the completed transaction ID is persisted, and the WorldMap checkpoints automatically.
8. If the player owns all four Korea cities, the victory screen opens. If the player owns zero, the defeat screen opens.

## Locked Scope

- Active cities: Hanseong, Pyongyang, Gyeongju, and Sabi.
- The player faction remains `GameSession.player_faction_id`; no Hanseong hard-code is introduced.
- Existing T02/T03 battle, occupation, supply, casualty, and report contracts remain protected.
- AI uses existing reinforcement, strategy, and invasion behavior plus baseline city production.
- AI research remains disabled because the current runtime explicitly records it as unimplemented. T04–T05 does not invent AI research state or technology effects.
- No T06 hero/cutin/balance work and no T07 terrain/map work is included.

## Turn Resolution State

The persisted `player_state` adds:

- `turn_resolution_state`
- `completed_turn_resolution_ids`
- `last_turn_resolution_result`
- `last_ai_domestic_apply_turn`
- `last_ai_domestic_apply_result`

Transaction identity is `t04-{source_turn}-{player_faction_id}`. Existing subsystem guards remain authoritative inside the transaction:

- `last_enemy_faction_turn_processed_turn`
- `enemy_invasion_roll_turn`
- `last_domestic_apply_turn`
- existing trade, market, research, diplomacy, spy, revolt, and battle-result guards

Saving during the enemy phase preserves `turn_phase`, `domestic_apply_pending`, and the T04 stage. Loading resumes through the same guarded flow instead of forcing the save back to player phase.

## Resource Source Of Truth

T02 established city `resource_stock` as authoritative. T04–T05 therefore applies:

- each player city’s production to that city;
- AI baseline production to its owning city;
- player-wide positive deltas to the capital first;
- player-wide costs capital-first, then remaining owned cities in stable order;
- `player_state.resource_stock` only as a compatibility aggregate rebuilt from owned city stock.

Research payment scope remains unchanged: national research uses owned-city aggregate with capital-first payment; city research uses the selected city.

## Outcome State

The persisted `game_outcome` contains:

- `status`: `active`, `victory`, or `defeat`;
- deterministic `outcome_id`;
- `resolved_turn`;
- `owned_city_count`;
- result-save acknowledgement.

Terminal outcome is immutable. Once victory or defeat is recorded, turn end, new invasion, and enemy-turn continuation are blocked. Loading restores the same terminal screen. The screen provides `결과 저장` and `새 게임`.

## UI And Save

- `WorldMap.tscn` contains a scene-authored `T05OutcomePresentation`.
- The left status hint can display the last completed turn result.
- The save schema is `v0.76`.
- `GameSession.has_valid_save()` checks the same WorldMap save path used by the runtime, so the title-screen `이어하기` button detects real saves.

## Automated Verification

- `scripts/worldmap/t04_t05/turn_outcome_rules.gd`: pure transaction ID and outcome rules.
- `scripts/t04_t05/t04_t05_smoke_test.gd`: pure rule checks plus full turn advance, completion guard, city-stock mutation, victory creation, and save/load restoration.
- Static checks cover patch whitespace, scene node paths, duplicate function definitions, balanced delimiters, save fields, and forbidden T06/T07 scope.

## Completion Evidence

Godot 4.6 integrated F5 QA passed on the user runtime environment:

1. all four player starts ended multiple turns correctly;
2. each turn advanced once with no duplicate production, research, recovery, AI action, or invasion;
3. saving during enemy phase resumed and completed the same transaction;
4. research completion presentation remained functional;
5. wounded soldier/general recovery followed month boundaries;
6. player capture of the fourth city opened victory;
7. loss of the last player city opened defeat;
8. terminal save/load restored the same screen;
9. title-screen `이어하기` detected the runtime save;
10. final Godot Output had no new errors or warnings.

T04–T05 is therefore locked `COMPLETE`. Later transactions must preserve these turn, persistence, resource, and terminal-outcome contracts unless a separately approved migration explicitly replaces them.

## Explicit Non-Goals

- AI technology research or new technology values;
- new domestic systems, balance changes, diplomacy systems, or battle formulas;
- T06 hero cutin/balance/unique skills;
- T07 terrain and multi-map expansion;
- broad WorldMap refactoring.
