# IMJIN DEMO D4 QA HANDOFF

## Status

`MANUAL QA FOUND REAL D1/D3 GAPS / HOTFIX SERIES APPLIED / BOTH LOCAL VALIDATORS MUST RE-RUN / USER GODOT F5+F6 RE-QA REQUIRED`

## Scope summary

### Production path

- D0: 44-hero generated-data runtime contract normalized.
- D1 identity layer: five new Imjin heroes registered in production `HeroDefinitionRegistry`.
- D1 runtime city layer: first F5 QA showed those identities were **not yet entering mutable WorldMap city rosters**.
- Hotfix: reusable `RegisteredHeroCitySeeder` now bridges `assigned_city_id` from production hero registry into mutable WorldMap city/runtime state, with a runtime-state anti-teleport guard.
- D2: existing WorldMap -> formation -> Battle_Land contract remains the intended reusable production path.

### Demo-only path

- D3: separate inherited Korea-vs-Japan Test2 exists and existing Korea-vs-China Test1 remains untouched.
- First canonical-ID bug (`yi_sunsin`) was fixed earlier.
- First successful F6 visual QA then exposed a deeper state-authority bug: Test2 changed roster identities but inherited the actual Test1 `BattleUnitState` hero authority.
- Resulting symptoms included 곽재우 showing 정도전's `개혁령`, 김덕령 showing 권율's `행주대첩`, other missing/wrong skills, and Korea/Japan unit types inheriting Test1 Korea/China values.
- Hotfix: Test2 now calls the inherited state builder for common wiring, then rebinds all ten states through canonical hero IDs so `BattleUnitState` rebuilds unit type/stats/unique skill from production hero authority.
- Initial Test2 also leaked central-bottom `current_actor` cinematic art into roster `closeup_portrait_path`.
- Hotfix: roster/ordinary close-up uses normal portrait assets; the central-bottom Current Actor HUD keeps its separate cinematic portrait contract.

## Known separate functional remainder

`gwak_jae_u` / `홍의장군` generated data already contains the intended encirclement debuff and `사용 후 1칸 재배치` description.

The stale `개혁령` command label was **not** a placeholder for this. It was the Test1 state-contamination bug and is addressed by the Test2 authority rebind.

The resolver already supports the encirclement debuff portion. The explicit post-skill **manual 1-cell reposition** is still a separate functional completion item because the existing generic resolver `move` command means deterministic retreat. Do not fake this behavior as retreat movement; add and QA a dedicated interaction before declaring `홍의장군` behavior complete.

## Automated/static validators

After pulling the latest feature branch, run from repository root:

```text
python tools/validate_imjin_d0_d1_worldmap_hero_integration.py
python tools/validate_imjin_demo_test2.py
```

Both must PASS after the current hotfix series.

The D0-D1 validator now checks the production registry-to-city bridge in addition to the 44-hero data/identity contract.

The Test2 validator now checks not merely roster IDs but also:

- all ten canonical scenario IDs;
- authority-rebind path after inherited Test1 state construction;
- exact generated unit types;
- profile/unique-skill ID parity;
- exact generated skill names;
- ordinary roster portrait availability;
- separation of ordinary roster portraits from Current Actor cinematic portraits;
- WorldMap registered-hero city-seeding contract.

The GitHub connector environment cannot execute local Godot or repository Python, so no post-hotfix execution PASS is claimed in this document.

## F5 Production QA

Because `project.godot` now has a new autoload, restart Godot once after pulling before F5 QA.

### WorldMap registration

1. Open Hanseong hero UI.
2. Existing 이순신 / 정도전 / 권율 must remain present.
3. Confirm 곽재우 / 고경명 / 김덕령 are now present and clickable.
4. Confirm their names and normal portraits resolve without placeholder/missing-resource errors.
5. Inspect Osaka and confirm 가토 기요마사 / 구로다 나가마사 appear with the existing city roster.
6. Reopen WorldMap and confirm no duplicate hero is seeded.

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
6. Move/attack/defend/use supported unique skill where applicable.
7. Finish or retreat through the existing result flow and confirm return to WorldMap remains normal.
8. Confirm an already moved/deployed/captured hero is not snapped back to its registry city by the seeder.

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

Before F6, require:

```text
python tools/validate_imjin_demo_test2.py
```

PASS.

Then run:

`res://tests/scenes/Battle_UI_Production_Imjin_Test.tscn`

Expected Korea roster / type / skill:

- 이순신 — 궁병 — 학익진
- 곽재우 — 보병 — 홍의장군
- 김덕령 — 기병 — 충용장
- 권율 — 보병 — 행주대첩
- 고경명 — 보병 — 호남의병

Expected Japan roster / type / skill:

- 도요토미 히데요시 — 보병 — 태합호령
- 시마즈 요시히로 — 총병 — 귀석만자
- 가토 기요마사 — 보병 — 칠본창
- 고니시 유키나가 — 총병 — 선봉교섭
- 구로다 나가마사 — 기병 — 세키가하라 조략

Confirm:

1. Same Production Design1 HUD as Test1.
2. No China hero remains in Test2.
3. Every roster portrait is the ordinary hero portrait, not the central-bottom Current Actor cinematic image.
4. Current Actor HUD may use the prepared cinematic `current_actor` image and updates for all actors.
5. Every displayed troop type matches the locked list above.
6. For every ally actor, Current Actor HUD unique-skill name and floating command-panel unique-skill name agree.
7. Move / attack / defend / supported unique skill / enemy turn are functional.
8. Reinforcement slots preserve existing arrival timing.
9. No WorldMap result-return UI incorrectly appears in the standalone Test2.
10. No missing-resource, parser, or invalid-parent errors appear in Godot Output.

## Demo recording gate

Do not record the `모두의 창업` footage until:

- updated D0-D1 validator PASS;
- strengthened Test2 validator PASS;
- F5 production new-hero city + battle handoff passes;
- F6 Test1 regression passes;
- F6 Test2 roster/portrait/type/skill/action QA passes.

After those gates, Test2 is the preferred battle recording scene for the Korea-vs-Japan demo.

## Future naval reminder

Before any naval implementation begins, read:

`agent/IMJIN_DEMO_NAVAL_EXTENSION_PLAN.md`

Locked future combat structure:

- Ship Combat: 포격 / 화공 / 총 / 활 / 돌격박치기
- Boarding success -> Deck Battlefield
- Deck Battlefield reuses land-battle core/UI as much as practical
- Test2's scenario isolation is the intended architectural stepping stone, not a naval implementation itself.
