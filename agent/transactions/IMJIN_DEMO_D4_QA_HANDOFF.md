# IMJIN DEMO D4 QA HANDOFF

## Status

`MANUAL F5 PRODUCTION HANDOFF PASS / MANUAL F6 TEST2 PASS / STATIC VALIDATORS + TEST1 REGRESSION STILL REQUIRED / HONGUIJANGGUN REPOSITION REMAINS`

## Scope summary

### Production path

- D0: 44-hero generated-data runtime contract normalized.
- D1 identity layer: five new Imjin heroes registered in production `HeroDefinitionRegistry`.
- D1 runtime city layer: first F5 QA showed those identities were **not yet entering mutable WorldMap city rosters**.
- Hotfix: reusable `RegisteredHeroCitySeeder` now bridges `assigned_city_id` from production hero registry into mutable WorldMap city/runtime state, with a runtime-state anti-teleport guard.
- D2: existing WorldMap -> formation -> Battle_Land contract remains the intended reusable production path.
- **2026-08-22 manual F5 re-QA PASS:** user confirmed new heroes can be used from WorldMap through formation and successfully enter the real battle scene.
- The F5 battle screen is still the older Production battle UI. This is expected because Design1 has not yet been ported from the Production Test scene into the real `Battle_Land` scene; that UI migration is a separate future transaction and is not an Imjin integration failure.

### Demo-only path

- D3: separate inherited Korea-vs-Japan Test2 exists and existing Korea-vs-China Test1 remains untouched.
- First canonical-ID bug (`yi_sunsin`) was fixed earlier.
- First successful F6 visual QA then exposed a deeper state-authority bug: Test2 changed roster identities but inherited the actual Test1 `BattleUnitState` hero authority.
- Resulting symptoms included 곽재우 showing 정도전's `개혁령`, 김덕령 showing 권율's `행주대첩`, other missing/wrong skills, and Korea/Japan unit types inheriting Test1 Korea/China values.
- Hotfix: Test2 now calls the inherited state builder for common wiring, then rebinds all ten states through canonical hero IDs so `BattleUnitState` rebuilds unit type/stats/unique skill from production hero authority.
- Initial Test2 also leaked central-bottom `current_actor` cinematic art into roster `closeup_portrait_path`.
- Hotfix: roster/ordinary close-up uses normal portrait assets; the central-bottom Current Actor HUD keeps its separate cinematic portrait contract.
- A read-only Dictionary runtime error was then found in `_get_hero_registry_entry()` because Test2 attempted to mutate a parent registry Dictionary directly.
- Hotfix: Test2 now deep-duplicates the registry entry before applying presentation overrides.
- **2026-08-22 manual F6 re-QA PASS:** user confirmed the Korea-vs-Japan Test2 now runs successfully through live battle after the authority/portrait/read-only hotfix series.

## Known separate functional remainder

`gwak_jae_u` / `홍의장군` generated data already contains the intended encirclement debuff and `사용 후 1칸 재배치` description.

The stale `개혁령` command label was **not** a placeholder for this. It was the Test1 state-contamination bug and is fixed by the Test2 authority rebind.

The resolver already supports the encirclement debuff portion. The explicit post-skill **manual 1-cell reposition** is still a separate functional completion item because the existing generic resolver `move` command means deterministic retreat. Do not fake this behavior as retreat movement; add and QA a dedicated interaction before declaring `홍의장군` behavior complete.

## Automated/static validators

After pulling the latest feature branch, run from repository root:

```text
python tools/validate_imjin_d0_d1_worldmap_hero_integration.py
python tools/validate_imjin_demo_test2.py
```

Both must PASS after the current hotfix series.

The D0-D1 validator checks the production registry-to-city bridge in addition to the 44-hero data/identity contract.

The Test2 validator checks:

- all ten canonical scenario IDs;
- authority-rebind path after inherited Test1 state construction;
- exact generated unit types;
- profile/unique-skill ID parity;
- exact generated skill names;
- ordinary roster portrait availability;
- separation of ordinary roster portraits from Current Actor cinematic portraits;
- WorldMap registered-hero city-seeding contract.

The GitHub connector environment cannot execute local Godot or repository Python, so static validator PASS is not claimed here until re-run locally.

## F5 Production QA

### Manual status

**PASS reported by user on 2026-08-22:** WorldMap -> formation -> real battle entry works with the new hero integration.

### Remaining checks before merge

1. Open Hanseong hero UI and retain existing 이순신 / 정도전 / 권율 plus 곽재우 / 고경명 / 김덕령.
2. Inspect Osaka and retain 가토 기요마사 / 구로다 나가마사 with the existing roster.
3. Reopen WorldMap and confirm no duplicate hero is seeded.
4. Confirm an already moved/deployed/captured hero is not snapped back to its registry city by the seeder.
5. Keep in mind: real F5 `Battle_Land` still uses the older UI until the separate Design1-to-Production migration transaction.

## F6 Test1 regression QA

Run:

`res://tests/scenes/Battle_UI_Production_Test.tscn`

Still required before merge:

- Korea vs China roster unchanged.
- Design1 HUD geometry unchanged.
- Existing movement/attack/skill/turn/reinforcement behavior intact.

## F6 Test2 demo QA

### Manual status

**PASS reported by user on 2026-08-22:** Korea-vs-Japan Test2 runs successfully in live battle after the latest hotfixes.

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

Before final merge, retain these checks:

1. Same Production Design1 HUD as Test1.
2. No China hero remains in Test2.
3. Every roster portrait uses the ordinary hero portrait, not Current Actor cinematic art.
4. Current Actor HUD may use prepared cinematic images and updates for all actors.
5. Every displayed troop type matches the locked list above.
6. For every ally actor, Current Actor HUD unique-skill name and floating command-panel unique-skill name agree.
7. Move / attack / defend / supported unique skill / enemy turn are functional.
8. Reinforcement slots preserve existing arrival timing.
9. No WorldMap result-return UI incorrectly appears in standalone Test2.
10. No missing-resource, parser, invalid-parent, or read-only Dictionary errors appear in Godot Output.

## Demo recording gate

Do not record the `모두의 창업` footage until:

- updated D0-D1 validator PASS;
- strengthened Test2 validator PASS;
- F5 production handoff PASS is retained;
- F6 Test1 regression PASS;
- F6 Test2 PASS is retained;
- 홍의장군 post-skill 1-cell reposition behavior is implemented and QA'd if it will be demonstrated.

After those gates, Test2 is the preferred battle recording scene for the Korea-vs-Japan demo.

## Future Production UI reminder

The current F5 real battle scene still shows the older Production UI. The Design1 UI built and validated in `Battle_UI_Production_Test.tscn` must later be migrated into the real `Battle_Land` path as a dedicated transaction. Do not treat the old F5 UI as a regression from this Imjin integration work.

## Future naval reminder

Before any naval implementation begins, read:

`agent/IMJIN_DEMO_NAVAL_EXTENSION_PLAN.md`

Locked future combat structure:

- Ship Combat: 포격 / 화공 / 총 / 활 / 돌격박치기
- Boarding success -> Deck Battlefield
- Deck Battlefield reuses land-battle core/UI as much as practical
- Test2's scenario isolation is the intended architectural stepping stone, not a naval implementation itself.
