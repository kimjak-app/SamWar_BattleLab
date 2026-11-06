기준 화면: 새 가지 `feature/wm3d-cityhud4-20261106`(시작: **25번 HUDFIX가 `main`에 합류된 뒤의 `origin/main` 끝**, 해시는 시작 때 확인해 보고서에 기록)에서 F6로 `WorldMap.tscn`을 열고 내 도시(한성·평양·건업·에도·교토)를 눌렀을 때, 성 안 그림에 **그 도시가 완료한 테크의 건물만** 그려진다(생활 건물·민가·배경은 항상). 시장은 완료된 가장 높은 단계 하나, 항구 자리는 무역항이 있으면 무역항. 테크를 완료하면 창이 열려 있는 동안 건물이 켜진다.
합격 기준: 6절 자동 기준 전부 + `main` 수정 0줄 + C-track 4 shard·`Verify WorldMap3D` 초록. 최종 합격은 김작 F6(7절 체크리스트).

# 지시서 — CITY-HUD CH-4: 성 안 건물을 테크 완료와 연동

- 작성: 클코치, 2026-11-06 20:40. **상태: 보류** — 큐 27번. 김작이 25번(HUDFIX) F6를 합격시키고 `main`에 합류한 뒤 "준비됨"으로 바꾼다. 그 전에는 시작하지 않는다.
- **김작 결정 [사실]**: 11-05 "생활 5종은 새 테크 연동(전까지 기본 표시)", "시장 3단계 그림 교체", "항구→무역항 교체(조선소 별도 슬롯)", CH-3 D1~D7 록비서 추천대로; **11-06 20:18 "창고 B 추천대로" = 창고는 생활 건물(장식)이며 항상 표시**(상업 테크 아님).
- 시작 전제(어긋나면 멈춤, 1절): 컨트롤러에 `TitleLabel`·`CloseButton`이 없다(25번 반영). `main` 정본에 이 지시서가 쓰는 파일이 있다.

## 0. 규칙
큐 10절·상시 규칙. **`worldmap_main.gd`·`worldmap3d/` 수정 0줄**(읽기 호출만). 허용 파일: `scripts/worldmap/ui/worldmap_city_interior_controller.gd`, 같은 폴더의 `worldmap_city_interior_layouts.gd`(필요 시에만), 아래 테스트들. 그림 그리기 좌표·도킹·창 겉틀·닫기 규칙(25번)은 **바꾸지 않는다.** 허용 오차 조정·재실행으로 때우기 금지. 막히면 `agent/REPORT_CITYHUD_CH4_STOP_20261106.md`로 멈춘다(이 항목만).

## 1. 클코치가 미리 확인한 것 [사실, `origin/main` 042b070 기준]
- 배치표 `assets/worldmap/city_buildings/city_layouts.json`: 5성(`hanseong`·`pyeongyang`·`jianye`·`edo`·`kyoto`), 항목마다 `kind`(`building`/`decoration`), `building_key`, **`tech_id`**(건물 25종은 카탈로그 id와 같고, **생활 5종(`life_office`·`life_storehouse`·`life_smithy`·`life_academy`·`life_temple`)은 빈 문자열 `""`**), `slot_candidates`(시장: `[commerce_grand_market, commerce_permanent_market, commerce_street_market]`, 교토 항구 자리: `[commerce_trade_port, commerce_port]`, 앞일수록 높은 단계), `coastal_only`, `compare_only`, `draw_as`(`sprite`/`overlay_piece`), `ax/ay/scale/x/y/w/h`.
- 테크 완료 읽기: `main.call("_get_completed_city_domestic_tech_snapshot_mvp", city_id)` → `Dictionary {tech_id: bool}`(복사본). 단건: `_is_city_domestic_tech_completed_mvp(city_id, tech_id)`. 완료 **전용 신호는 없다**.
- `_draw_city(city_id)`는 지금 `items_for_city(city_id, coastal)`(compare_only와, 비해안의 coastal_only 제외)를 전부 그린다. 컨트롤러는 열려 있는 동안 매 프레임 `_process`가 `_update_dock()`을 돈다.
- 교토 항목에 `commerce_port`(`compare_only`=true, 그리지 않음), `commerce_trade_port`(슬롯 후보 `[trade_port, port]`), `commerce_shipyard`(별도 슬롯, `tech_id` `commerce_shipyard`)가 따로 있다.
- 시작 전 확인할 [미확인] 두 가지: ① 시장 후보별 그림 크기가 다르다(노점·상설 128px, 대형 더 큼) → 같은 "발 자리"에 맞추는 법은 배치표 `ax/ay`와 `item_top_left()` 코드로 확인(CH-3 보고서 "발 자리" 설명 참조) ② 게임 시작 직후 도시별 완료 테크가 실제로 비어 있는지.

## 2. 규칙 (표시 조건)
항목마다 위에서부터 판정:
1. `compare_only` → 그리지 않는다(지금과 같음). 비해안 도시의 `coastal_only` → 그리지 않는다(지금과 같음).
2. `kind == decoration`(민가 등) → **항상** 그린다.
3. `tech_id == ""`(생활 5종, 창고 포함) → **항상** 그린다.
4. `slot_candidates`가 있다 → 후보를 **앞에서부터** 보며 그 도시가 완료한 첫 후보를 고른다. 있으면 **그 후보 그림 하나만** 같은 발 자리에 그린다(`region_style`·`load_texture` 그대로). 하나도 없으면 그 슬롯은 **비운다**(그리지 않음).
5. 그 밖의 건물 → `snapshot.get(tech_id, false)`가 true일 때만 그린다.
- 판정은 **창이 열린 도시** 기준이다(도시별 완료 목록). 배경은 항상 그린다.
- 그리기 순서(`z`)·좌표는 배치표 그대로. 안 그린 항목은 `_drawn_items`에도 들어가지 않는다.

## 3. 갱신 방식 (main 0줄)
- 창이 열려 있는 동안 `_process`에서 **열린 도시의 완료 목록 사본**을 마지막으로 그린 것과 비교하고, **달라졌을 때만** 다시 그린다. 신호를 새로 만들거나 main에 훅을 달지 않는다. 비용 한계: 열려 있을 때만, 한 도시만, Dictionary 비교 1회(보고서에 한 줄로 측정).
- 도시를 바꿔 열 때(`try_open`)는 처음부터 규칙대로 그린다.

## 4. 개발용 "전부 표시" 스위치
- 컨트롤러 변수 `debug_show_all`(기본 false). true면 2절 3~5번을 무시하고 CH-3처럼 배치표 전부(compare_only·비해안 coastal_only 제외)를 그린다.
- 창이 열려 있을 때 쓸 키 조합으로 켜고 끈다. 키는 클코드가 기존 단축키와 겹치지 않는 것을 `grep`으로 확인해 정하고 보고서에 적는다(ESC·F키 중 이미 쓰이는 것 금지). 출시본에서 쓰이지 않게 하려면 `OS.is_debug_build()`일 때만 동작시킨다.

## 5. 테스트
- `test_worldmap_city_interior_layouts.gd`의 CH-3 숫자 검사(한성 30·평양 28·건업 29·에도 29·교토 30, 배치표 순서, 그림 비교 포함)는 **`debug_show_all = true`로 돌려서 그대로 유지**한다(검사를 약하게 하지 말 것). 이를 위한 수정만 허용.
- 새 검사(같은 파일 또는 새 파일 `test_worldmap_city_interior_tech_link.gd`, 새 파일이면 C-track 목록 **끝**에 추가). 테크 완료 상태는 기존 배지 테스트가 쓰는 방식으로 만든다(새 우회로 금지):
  1. **완료 0개**: 한성은 배경 + 생활 5종 + 민가만(항목 수 원문), 테크 건물 0.
  2. 건물 1개 완료(예: `mil_barracks`) → 그 건물만 늘고 나머지 그대로.
  3. **시장**: 완료 없음 → 슬롯 비움 / 노점 → 노점 그림 / 노점+상설 → 상설 하나만 / +대형 → 대형 하나만. 매번 그려진 시장 그림이 **1개**임.
  4. **교토 항구 자리**: 항구만 완료 → 항구 그림, 무역항까지 완료 → 무역항 하나만, `compare_only` 항구는 어느 경우에도 안 그림. 조선소는 `commerce_shipyard` 완료일 때만(별도).
  5. **비해안 도시(한성)**: 해안 테크가 완료돼 있어도 해안 건물 안 그림.
  6. **도시별**: 한성이 완료한 테크가 평양 창에 나타나지 않음.
  7. **열려 있는 동안 갱신**: 창이 열린 채 테크를 완료시키면 프레임을 몇 번 돌린 뒤 건물이 켜짐. 같은 목록이면 다시 그리지 않음(그린 횟수 카운터).
  8. `debug_show_all`: true → CH-3 숫자와 같음, false로 돌리면 규칙대로 복귀.
  9. 안 그린 항목은 `_drawn_items`에 없음.
- 기존 CH-2·CH-2b/2c·스모크·그립 테스트 전부 변화 없이 통과.

## 6. 자동 합격 기준
위 테스트 전부 통과 + 기존 테스트 변화 0 + `main` 수정 0줄 + 변경 파일이 허용 목록 안 + C-track 4 shard·`Verify WorldMap3D` 초록(알려진 `[CUTIN]` 흔들림은 4절 규칙대로 근거와 함께 기록, 재실행·오차 조정 금지).

## 7. 김작 F6 체크리스트 (보고서 맨 아래에 그대로 옮길 것)
1. **새 게임 시작 직후** 한성을 눌러 창을 연다 → 건물은 거의 없고 생활 5종·민가·배경만 보인다.
2. 테크트리에서 한성 테크 하나를 완료시킨다 → 창이 열려 있으면 그 건물이 켜진다(닫았다 열어도 유지).
3. 시장 테크를 단계별로 완료 → 같은 자리 그림이 바뀐다(겹쳐 쌓이지 않음).
4. 교토(해안)에서 항구 → 무역항 → 조선소.
5. "전부 표시" 키로 5성이 CH-3 모습으로 돌아오는지.
- 클코드는 위 2번의 "빠르게 테크를 완료시키는 방법"을 **기존 개발/테스트 경로 중에서** 찾아 보고서에 쓴다(새 치트 만들기 금지; 없으면 없다고 쓴다).

## 8. 보고서
`agent/REPORT_CITYHUD_CH4_20261106.md`: 맨 위 "기준 화면 / 합격 기준" 두 줄 + 3줄 요약 + 1절 [미확인] 두 건의 확인 결과 + 시작 `main` 해시 + 변경 요약 + 5절 결과 숫자 + 갱신 비용 한 줄 + 키 조합과 근거 + F6 체크리스트 + 종료 루틴 5줄. 보고서·증거는 새 가지에 `[skip ci]`. 끝낼 때 정본 작업 폴더를 이 가지로 체크아웃해 둔다.

## 9. 하지 않는 것
`main` 푸시·`worldmap_main.gd`·`worldmap3d/` 수정, 배치표 좌표 수정, 25번 겉틀 수정, 레이아웃 없는 도시의 안내 글자(`PLACEHOLDER_TEXT`) 변경, 새 테크 데이터 추가(생활 5종 연동은 나중), 허용 오차·재실행.
