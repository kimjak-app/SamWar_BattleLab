# IMJIN DEMO D3 KOREA-JAPAN TEST2

## Status

`IMPLEMENTED / MANUAL F6 STATE-CONTAMINATION BUG FOUND / CANONICAL AUTHORITY + PORTRAIT HOTFIX APPLIED / LOCAL VALIDATOR RE-RUN + USER F6 QA REQUIRED`

## Purpose

Create a separate Korea-vs-Japan Production UI test scene for the `모두의 창업` demo while preserving the existing Korea-vs-China Test1 unchanged.

This is a demo/test scenario. It is not a new production WorldMap battle route and does not add naval gameplay yet.

## Architecture

Test2 inherits the existing production test scene:

`Battle_UI_Production_Test.tscn`

and replaces only the scenario/controller specialization through:

- `tests/scenes/Battle_UI_Production_Imjin_Test.tscn`
- `tests/scripts/battle_ui_production_imjin_test.gd`

The full Production HUD node tree is therefore shared rather than copied.

The Test2 controller subclasses `scripts/battle_web_import_test.gd`. The inherited Test1 builder still owns common battle wiring, positions, troop allocation, action flags, and UI integration; Test2 then rebinds each of the ten created `BattleUnitState` objects to the scenario's canonical hero ID.

That second step is mandatory because `BattleUnitState.unit_id` is the production authority trigger: assigning a registered hero ID rebuilds the authoritative hero payload from `HeroDefinitionRegistry.HERO_DATA` / generated design data, refreshing unit type, combat stats, ranges, and unique-skill definition.

## Canonical hero-ID contract

New Test2 scenario code must use canonical IDs from the generated hero datasets directly.

Do not manually reintroduce legacy aliases such as:

- `yi_sunsin` -> canonical `yi_sun_sin`
- `jeong_dojeon` -> canonical `jeong_do_jeon`
- `gim_yusin` -> canonical `kim_yu_sin`

The existing Test1 source still contains some legacy IDs and is intentionally preserved unchanged in this transaction. Runtime alias compatibility for Test1 is separate from the rule that all newly written Test2 scenario data must use canonical IDs.

A first regression was found during local validation after the initial D3 implementation: Test2 used `yi_sunsin`, causing generated-data lookup failure for Yi Sun-sin. The Test2 roster and Korea demo hero set were corrected to `yi_sun_sin`, and the validator explicitly rejects legacy IDs in Test2.

## Manual F6 bug found after the canonical-ID hotfix

The first successful Test2 F6 launch exposed a deeper problem that static roster-ID validation had missed.

The visible roster names were Korea/Japan, but the actual underlying `BattleUnitState` objects were still the inherited Test1 heroes. This caused exact cross-contamination such as:

- 곽재우 surface -> inherited 정도전 state -> `개혁령` and wrong unit type;
- 김덕령 surface -> inherited 권율 state -> `행주대첩` and wrong unit type;
- 권율 / 고경명 -> inherited Test1 reinforcement state -> missing/wrong unique skill and unit type;
- Japan slots -> inherited China Test1 combat states and unit types.

The bottom Current Actor HUD appeared more correct because its test bridge directly re-queried `HeroDesignDataRegistry`, while the floating command panel correctly reflected the **actual** stale `BattleUnitState.unique_skill_definition`. The mismatch therefore exposed a real scenario-state authority bug, not a UI-label bug.

### Hotfix contract

`tests/scripts/battle_ui_production_imjin_test.gd` now overrides `_create_demo_unit_states()`:

1. call `super._create_demo_unit_states()` to preserve the tested Test1 battle wiring;
2. map all ten Test2 capacity slots to their canonical scenario hero IDs;
3. set each state's final `slot_id`;
4. assign `unit_state.unit_id = hero_id` to invoke `BattleUnitState` authoritative rebuild;
5. apply only scenario presentation metadata (`nation`, `visual_key`, `portrait_key`) after authority rebuild.

Do **not** replace this with manual copies of hero stats/skills inside Test2. Test2 must remain a thin scenario layer over production hero authority.

## Test1 lock

Existing Test1 remains Korea 5 vs China 5:

### Korea

- 이순신
- 정도전
- 권율
- 김유신
- 을지문덕

### China

- 관우
- 장비
- 하후돈
- 유비
- 제갈량

No Test1 roster replacement is authorized by this transaction.

## Test2 roster

### Korea

- Main 01 — 이순신 (`yi_sun_sin`) — 궁병 — 학익진
- Main 02 — 곽재우 (`gwak_jae_u`) — 보병 — 홍의장군
- Main 03 — 김덕령 (`kim_deok_ryeong`) — 기병 — 충용장
- Reinforce 01 — 권율 (`kwon_yul`) — 보병 — 행주대첩
- Reinforce 02 — 고경명 (`go_gyeong_myeong`) — 보병 — 호남의병

### Japan

- Main 01 — 도요토미 히데요시 (`toyotomi_hideyoshi`) — 보병 — 태합호령
- Main 02 — 시마즈 요시히로 (`shimazu_yoshihiro`) — 총병 — 귀석만자
- Main 03 — 가토 기요마사 (`kato_kiyomasa`) — 보병 — 칠본창
- Reinforce 01 — 고니시 유키나가 (`konishi_yukinaga`) — 총병 — 선봉교섭
- Reinforce 02 — 구로다 나가마사 (`kuroda_nagamasa`) — 기병 — 세키가하라 조략

## Visual contract

Two portrait surfaces are intentionally separate:

1. **Roster / ordinary battle close-up portrait**
   - use normal portrait assets under `assets/heroes/portraits/korea|japan/`;
2. **central-bottom Current Actor HUD**
   - use the dedicated cinematic `assets/heroes/portraits/current_actor/...` contract through the existing bottom-HUD bridge.

The initial Test2 implementation incorrectly wrote a `current_actor` cinematic path into `closeup_portrait_path`, causing large/cinematic images to leak into roster slots. The hotfix removes that coupling and resolves normal portraits explicitly for Test2 registry entries.

Additional rules:

- Existing Production battle UI and positioning are inherited unchanged.
- Test2 resolves hero authority from production `HeroDefinitionRegistry` rather than adding another authoritative hero database.
- Korea and Japan unit-token visual keys are selected by scenario nation/unit type.
- No Test1 visual data is replaced.

## Gwak Jae-u `홍의장군` implementation note

The generated data is authoritative and already defines:

- skill: `홍의장군`;
- effect: `encirclement_debuff`;
- enemy-area debuff;
- description includes `사용 후 1칸 재배치`.

The previous `개혁령` display was **not** an intentional placeholder for the unimplemented reposition. It was the stale Jeong Do-jeon Test1 state described above.

Current resolver support already covers the encirclement debuff portion. The explicit post-skill 1-cell manual reposition remains a separate functional completion item because the existing resolver `move` command currently means deterministic retreat; it must not be faked as a retreat. Do not mark `홍의장군` full behavior complete until that reposition interaction has its own safe implementation/QA.

## Future naval relationship

Test2 is intentionally scenario-isolated so the same pattern can later support a Naval Korea-vs-Japan test without duplicating the battle HUD.

Per `agent/IMJIN_DEMO_NAVAL_EXTENSION_PLAN.md`, future naval work remains separate:

- Ship Combat: 포격 / 화공 / 총 / 활 / 돌격박치기
- Boarding success: Deck Battlefield
- Deck Battlefield: reuse land-battle core/UI where possible

No naval rule, sea route, boarding transition, or ship combat is implemented in D3.

## Validation

Run:

```text
python tools/validate_imjin_demo_test2.py
```

The validator now checks:

- Test2 inherits Test1 instead of copying the Production UI tree.
- Test1 Korea-vs-China roster remains source-compatible and unchanged by D3.
- Test2 exact Korea 5 / Japan 5 canonical roster.
- known Test2 legacy aliases are rejected.
- all ten states are covered by the Test2 authority-rebind path.
- all ten generated unit types match the locked Test2 expectation.
- battle-profile unique-skill IDs match generated unique-skill records.
- all ten generated skill names match the locked Test2 expectation.
- normal roster portrait assets exist separately from cinematic Current Actor assets.
- the Test2 registry function no longer assigns a Current Actor cinematic image as `closeup_portrait_path`.
- WorldMap registered-hero city seeding contract is present.
- Test2 contains no naval/temporary sea-route implementation.

The connector-only environment cannot execute the repository validator or Godot locally. After pulling this hotfix, the validator must be re-run in the local checkout before D3 static validation is marked PASS.

## User F6 QA gate

After pulling the branch and restarting Godot once, run directly:

`res://tests/scenes/Battle_UI_Production_Imjin_Test.tscn`

Confirm:

1. Production Design1 HUD geometry is identical to Test1.
2. Ally roster is 이순신 / 곽재우 / 김덕령 / 권율 / 고경명.
3. Enemy roster is 도요토미 히데요시 / 시마즈 요시히로 / 가토 기요마사 / 고니시 유키나가 / 구로다 나가마사.
4. Roster portraits use ordinary portrait art, never the central-bottom Current Actor cinematic image.
5. Exact unit types match the locked table above.
6. Current Actor HUD follows each acting hero and may use the dedicated Current Actor art.
7. Floating command panel unique-skill name matches the Current Actor HUD/generated skill for every ally actor.
8. Move / attack / defend / supported unique skill / enemy turn work with the new roster.
9. Korea/Japan unit visuals are visually distinct and no China hero/token remains in Test2.
10. Reinforcement slots still obey the existing arrival contract.
11. Test1 still runs separately as Korea-vs-China with unchanged Design1 layout.

## Completion rule

D3 is not considered validation-complete merely because the scene and specialization exist. The strengthened validator must PASS locally after any Test2 roster/authority/portrait change, and final visual acceptance still requires the user F6 gate.
