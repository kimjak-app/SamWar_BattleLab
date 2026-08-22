# IMJIN DEMO D4 QA HANDOFF

## Status

`IMPLEMENTATION COMPLETE / USER GODOT QA REQUIRED`

## Scope summary

### Production path

- D0: 44-hero generated-data runtime contract normalized.
- D1: five new Imjin heroes registered in production WorldMap hero registry.
- D2: existing WorldMap -> formation -> Battle_Land contract reused without Imjin-specific schema.

### Demo-only path

- D3: separate inherited Korea-vs-Japan Test2 added.
- Existing Korea-vs-China Test1 preserved.
- Test2 shares Production Design1 scene/UI and uses production hero authority.

## Automated/static validators

Run from repository root:

```text
python tools/validate_imjin_d0_d1_worldmap_hero_integration.py
python tools/validate_imjin_demo_test2.py
```

Then run existing project validators relevant to the current Battle_Land baseline if available in the local checkout.

The GitHub connector environment used for this transaction cannot execute local Godot or repository Python, so execution PASS is not claimed until run locally.

## F5 Production QA

Start the normal project with F5.

### WorldMap registration

1. Open Hanseong hero UI.
2. Confirm 곽재우 / 고경명 / 김덕령 are present and clickable.
3. Confirm their names and portraits resolve without placeholder/missing-resource errors.
4. Confirm existing Hanseong heroes remain present.

### Formation and battle handoff

1. Start any currently legal Korea MVP land invasion through the normal WorldMap attack flow.
2. Put at least one new Korea hero in the attack formation.
3. Confirm formation accepts the hero normally.
4. Enter battle once; no duplicate transition.
5. Confirm the same new hero appears in Battle_Land with:
   - correct display name;
   - intended portrait;
   - generated troop type;
   - current/max troop values;
   - generated battle stats/profile;
   - generated unique skill.
6. Move/attack/defend/use unique skill where applicable.
7. Finish or retreat through the existing result flow and confirm return to WorldMap remains normal.

### Japan production registration

When inspecting Osaka through the existing WorldMap UI, confirm 가토 기요마사 / 구로다 나가마사 are registered there. Do not create a temporary Korea-Japan sea route merely to force a battle; maritime routing is future naval scope.

## F6 Test1 regression QA

Run:

`res://tests/scenes/Battle_UI_Production_Test.tscn`

Confirm:

- Korea vs China roster is unchanged.
- Design1 HUD geometry is unchanged.
- Existing movement/attack/skill/turn/reinforcement behavior remains intact.

## F6 Test2 demo QA

Run:

`res://tests/scenes/Battle_UI_Production_Imjin_Test.tscn`

Expected Korea roster:

- 이순신
- 곽재우
- 김덕령
- 권율
- 고경명

Expected Japan roster:

- 도요토미 히데요시
- 시마즈 요시히로
- 가토 기요마사
- 고니시 유키나가
- 구로다 나가마사

Confirm:

1. Same Production Design1 HUD as Test1.
2. No China hero remains in Test2.
3. Korea/Japan unit visuals are distinguishable.
4. Prepared portraits display correctly, especially the newly added five and the existing Japan demo trio.
5. Current Actor HUD updates for all actors.
6. Move / attack / defend / unique skill / enemy turn are functional.
7. Reinforcement slots preserve existing arrival timing.
8. No WorldMap result-return UI incorrectly appears in the standalone Test2.
9. No missing-resource, parser, or invalid-parent errors appear in Godot Output.

## Demo recording gate

Do not record the `모두의 창업` footage until:

- F5 production new-hero handoff passes;
- F6 Test1 regression passes;
- F6 Test2 roster/visual/action QA passes.

After those gates, Test2 is the preferred battle recording scene for the Korea-vs-Japan demo.

## Future naval reminder

Before any naval implementation begins, read:

`agent/IMJIN_DEMO_NAVAL_EXTENSION_PLAN.md`

Locked future combat structure:

- Ship Combat: 포격 / 화공 / 총 / 활 / 돌격박치기
- Boarding success -> Deck Battlefield
- Deck Battlefield reuses land-battle core/UI as much as practical
- Test2's scenario isolation is the intended architectural stepping stone, not a naval implementation itself.
