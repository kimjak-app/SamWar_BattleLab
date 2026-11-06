기준 화면: 새 가지 `feature/wm3d-integrate-20261106`에서 `res://WorldMap.tscn`(F6) — 성 안 창이 좌측 정보창 옆에 뜨고(CH-2b), 좌측 정보창 맨 위 띠로 끌리며(CH-2c), 5성 안 배치(CH-3)가 보이고, 오른쪽 아래가 해·달 턴 버튼(18번)이다. 한 가지(한 빌드)에서 전부 보인다.
합격 기준: 아래 5절 자동 기준 + C-track 4 shard·`Verify WorldMap3D` success. 최종 합격은 김작 F6 한 번(7절 체크 목록). 김작 승인 전에는 `main`에 합치지 않는다.

# ORDER_INTEGRATE_F6 — 흩어진 가지 3개를 한 가지에 합쳐 한 번에 F6 (클코치 작성, 2026-11-06)

## 0. 배경·효력
- 지금 F6 확인 대상이 가지 3개에 흩어져 있다: `feature/wm3d-cityhud-20261105`(CH-2b·CH-2c·CH-3, 끝 `ad80253`), `feature/wm3d-m7prep-20261105`(M7-1·M7-2·M7-4, 끝 `0bfff7c`), `feature/wm3d-turnbtn-20261106`(턴 버튼, 끝 `ff033bb`). 김작이 가지마다 체크아웃해 F6하기 번거로워 **통합 가지 하나**로 만든다(김작 11-06 14:08 승인).
- 클코치가 `git merge-tree`로 미리 본 [사실]: 세 가지 모두 `origin/main`(`ab9b739`) 위에서 서로 **겹치는 파일은 `.github/workflows/verify-c-track.yml` 하나뿐**이고, 어느 두 가지를 합쳐도 충돌은 이 파일 하나에서만 난다(테스트 목록에 각자 줄을 더함). 코드 파일 충돌은 0.
- 큐 규칙 그대로. 새 가지 `feature/wm3d-integrate-20261106`에만 push. **`main` push·병합 금지**(김작 승인 후 별도 지시서). 기존 3개 가지는 **수정하지 않는다**(읽기만).

## 1. 먼저 확인 (보고서 표)
1. 세 가지 끝 해시가 위와 같은가(다르면 새 끝을 쓰고 "달라짐"으로 표시, 멈추지 않음).
2. `git merge-base`로 각 가지의 시작(cityhud `9160baf`, m7prep `9160baf`, turnbtn `ab9b739`)이 `origin/main`(`ab9b739`)의 조상인지.
3. `verify-c-track.yml`의 테스트 목록 구조: 4 shard를 **줄 순서(인덱스)로 나누는지** 확인한다. CH-2c 보고서에 "인덱스 201 → shard 1"이 있다. 목록 중간에 줄이 끼면 기존 테스트의 shard 배정이 밀릴 수 있다 → 합친 뒤 어느 shard에 몇 개씩 들어갔는지 표로.

## 2. 해야 할 일
1. `origin/main`(`ab9b739`)에서 새 가지를 만든다.
2. 순서대로 `git merge --no-ff`: ① cityhud ② m7prep ③ turnbtn. 병합 커밋 메시지에 각 가지 끝 해시를 적는다.
3. 충돌은 `verify-c-track.yml`만 예상된다. 해결 규칙: **세 가지가 더한 줄을 전부 남기고(합집합) 기존 줄은 그대로**, 중복 줄 제거, 순서는 기존 목록 끝에 `m7prep`(M7 테스트) → `cityhud`(CH-2·CH-3) → `turnbtn` 순으로 붙인다. 다른 파일에서 충돌이 나면 **멈추고** 보고(해결하지 않는다).
4. 합친 뒤 `git diff --stat origin/main..HEAD`가 세 가지 diff의 합과 같은지(코드가 사라지거나 두 번 들어가지 않았는지) 확인한다.
5. 작은 연기(smoke) 테스트 1개를 더한다: `tests/scripts/test_worldmap_integrated_hud_smoke.gd`(+`.uid`, CI 목록 1줄) — 정식 `WorldMap.tscn`을 열고 ⓐ `TurnEndCompass`가 새 하늘 층(`SkyA`)을 가졌다 ⓑ `LeftPanelGrip` 띠가 좌측 정보창 첫 자식이다 ⓒ 도시 성 안 컨트롤러가 1개이고 한성을 열면 창이 좌측 패널 오른쪽에 붙는다 ⓓ 이 셋이 동시에 있어도 `TurnEndCompass`의 `turn_end_requested`가 1번만 나간다. 기존 테스트의 기대값은 바꾸지 않는다.

## 3. 하지 말 것
- `main`·기존 3개 가지·`PROGRESS_WM3D.md` 수정 금지. 충돌 해결 외의 코드 수정 금지(smoke 테스트 추가 제외). `worldmap_main.gd`·씬 수정 금지. 설정 파일 수정 금지.
- 테스트 기대값 완화·삭제 금지.

## 4. 수정·추가 경로 (이것이 전부)
- 병합으로 들어오는 파일 전부 + `verify-c-track.yml` 충돌 해결
- 추가: `tests/scripts/test_worldmap_integrated_hud_smoke.gd`(+`.uid`), `agent/REPORT_INTEGRATE_F6_20261106.md`
- 그 밖은 멈춤.

## 5. 합격 기준 (자동)
- 로컬: 새 smoke 테스트 통과 + 세 가지 각자의 새 테스트(`test_worldmap_city_interior_*`, `test_worldmap_left_panel_grip`, `test_worldmap_turn_button_daynight`, `test_battle3d_worldmap_*`)가 합친 가지에서도 통과 + 검증기 전체 통과.
- push 후 **C-track 4 shard success + `Verify WorldMap3D` success** 확인(실행 번호를 보고서에).
- 입력 수명주기 테스트(`test_worldmap_to_battle_input_lifecycle.gd`)가 이 PC에서 300초 시간 초과인 것은 알려진 로컬 문제다(CH-2b 보고서). CI 결과를 기준으로 한다.

## 6. 보고서
맨 위 두 줄 "기준 화면 / 합격 기준" + 병합 3건의 커밋 해시 + 충돌 해결 전후 줄 diff + shard 배정 표 + 로컬·CI 결과 원문 + 김작 F6 체크 목록(7절 그대로) + 못 본 것.

## 7. 김작 F6 체크 목록 (보고서 맨 위에도 적을 것)
1. 클코드가 `feature/wm3d-integrate-20261106`을 체크아웃해 준 상태에서 F6로 `WorldMap.tscn`.
2. **성 안 창(CH-2b)**: 한성(내 도시)을 누르면 좌측 정보창 오른쪽에 붙어 뜨는가. 창이 떠 있어도 지도 드래그·휠이 되는가. 적 성을 누르면 닫히는가.
3. **좌측 정보창 띠(CH-2c)**: 맨 위 얇은 띠를 끌면 정보창이 움직이고 성 안 창이 따라오는가.
4. **5성 안 배치(CH-3)**: 5성 안이 참고 그림처럼 보이는가, 다른 도시는 안내 글인가.
5. **턴 버튼(18번)**: 오른쪽 아래 버튼을 누르면 하늘이 해→노을→달→새벽으로 도는가, 턴이 한 번만 지나가는가(달력·턴 수 +1), 턴 요약 팝업이 뜨는가, 끝나면 낮에서 멈추는가, 금테 바깥을 눌러도 안 눌리는가, 호버 툴팁 「턴 종료」.
6. M7(3D 전투 후퇴·복귀)은 **월드맵에서 3D 전장으로 가는 길(M7-3)이 아직 없어 F6로는 못 본다.** 자동 테스트로만 확인한다.
