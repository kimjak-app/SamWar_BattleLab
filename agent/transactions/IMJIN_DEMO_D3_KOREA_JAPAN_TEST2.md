# IMJIN DEMO D3 KOREA-JAPAN TEST2

## Status

`IMPLEMENTED / CANONICAL HERO-ID HOTFIX APPLIED / LOCAL VALIDATOR RE-RUN REQUIRED / USER F6 QA PENDING`

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

The Test2 controller subclasses `scripts/battle_web_import_test.gd` and overrides the test roster lookup. `BattleUnitState` then rebuilds authoritative hero payloads through `HeroDefinitionRegistry.HERO_DATA`, so Test2 does not duplicate hero stats, unit rules, battle roles, or unique-skill definitions.

## Canonical hero-ID contract

New Test2 scenario code must use canonical IDs from the generated hero datasets directly.

Do not manually reintroduce legacy aliases such as:

- `yi_sunsin` -> canonical `yi_sun_sin`
- `jeong_dojeon` -> canonical `jeong_do_jeon`
- `gim_yusin` -> canonical `kim_yu_sin`

The existing Test1 source still contains some legacy IDs and is intentionally preserved unchanged in this transaction. Runtime alias compatibility for Test1 is separate from the rule that all newly written Test2 scenario data must use canonical IDs.

A regression was found during local validation after the initial D3 implementation: Test2 used `yi_sunsin`, causing generated-data lookup failure for Yi Sun-sin. The Test2 roster and Korea demo hero set were corrected to `yi_sun_sin`, and the validator now explicitly rejects legacy IDs in Test2.

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

- Main 01 — 이순신 (`yi_sun_sin`)
- Main 02 — 곽재우 (`gwak_jae_u`)
- Main 03 — 김덕령 (`kim_deok_ryeong`)
- Reinforce 01 — 권율 (`kwon_yul`)
- Reinforce 02 — 고경명 (`go_gyeong_myeong`)

### Japan

- Main 01 — 도요토미 히데요시 (`toyotomi_hideyoshi`)
- Main 02 — 시마즈 요시히로 (`shimazu_yoshihiro`)
- Main 03 — 가토 기요마사 (`kato_kiyomasa`)
- Reinforce 01 — 고니시 유키나가 (`konishi_yukinaga`)
- Reinforce 02 — 구로다 나가마사 (`kuroda_nagamasa`)

## Visual contract

- Existing Production battle UI and positioning are inherited unchanged.
- Test2 resolves missing hero visual registry entries from production `HeroDefinitionRegistry` rather than adding another authoritative hero database.
- Prepared `current_actor` portraits are preferred for Test2 close-up presentation where available.
- Korea and Japan unit-token visual keys are selected by scenario region/unit type; the shared battle controller already contains Korea/Japan token registries.
- No Test1 visual data is replaced.

## Future naval relationship

Test2 is intentionally scenario-isolated so the same pattern can later support a Naval Korea-vs-Japan test without duplicating the battle HUD.

Per `agent/IMJIN_DEMO_NAVAL_EXTENSION_PLAN.md`, future naval work remains separate:

- Ship Combat: 포격 / 화공 / 총 / 활 / 돌격박치기
- Boarding success: Deck Battlefield
- Deck Battlefield: reuse land-battle core/UI where possible

No naval rule, sea route, boarding transition, or ship combat is implemented in D3.

## Validation

Added:

```text
python tools/validate_imjin_demo_test2.py
```

The validator checks:

- Test2 inherits Test1 instead of copying the Production UI tree.
- Test1 Korea-vs-China roster remains source-compatible and unchanged by D3.
- Test2 exact Korea 5 / Japan 5 roster.
- Test2 scenario IDs are canonical generated-data hero IDs; known legacy aliases are rejected.
- All 10 Test2 heroes have generated base/profile/unique-skill records.
- Prepared current-actor portraits required by the new Imjin additions and existing Japan demo trio exist.
- Test2 contains no naval/temporary sea-route implementation.

The connector-only environment cannot execute the repository validator or Godot locally. After this hotfix, `python tools/validate_imjin_demo_test2.py` must be re-run in the local checkout before D3 static validation is marked PASS.

## User F6 QA gate

Run directly:

`res://tests/scenes/Battle_UI_Production_Imjin_Test.tscn`

Confirm:

1. Production Design1 HUD geometry is identical to Test1.
2. Ally roster is 이순신 / 곽재우 / 김덕령 / 권율 / 고경명.
3. Enemy roster is 도요토미 히데요시 / 시마즈 요시히로 / 가토 기요마사 / 고니시 유키나가 / 구로다 나가마사.
4. Hero names, portraits, troop types and current/max troops are correct.
5. Current Actor HUD follows each acting hero.
6. Move / attack / defend / unique skill / enemy turn work with the new roster.
7. Korea/Japan unit visuals are visually distinct and no China hero/token remains in Test2.
8. Reinforcement slots still obey the existing arrival contract.
9. Test1 still runs separately as Korea-vs-China with unchanged Design1 layout.

## Completion rule

D3 is not considered validation-complete merely because the scene and specialization exist. The canonical-ID validator must PASS locally after any Test2 roster change, and final visual acceptance still requires the user F6 gate.
