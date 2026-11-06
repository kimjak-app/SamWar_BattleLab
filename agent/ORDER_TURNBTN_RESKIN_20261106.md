기준 화면: 새 가지 `feature/wm3d-turnbtn-20261106`(시작 = `origin/main` `ab9b739`)에서 `res://WorldMap.tscn`(F6) 오른쪽 아래. 지금 나침반(240×240) 자리에 **금테 원형 틀 + 안개 낀 산 하늘 창 + 가운데 재생 아이콘**이 있고, 「턴 종료」 글자판은 없다. 눌러서 턴이 돌아가는 동안 하늘이 해→노을→달→새벽→해로 계속 순환하다가 턴 처리가 끝나면 **해(낮)에서 멈춘다**. 마우스를 창 위에 올리면 「턴 종료」 툴팁이 뜬다.
합격 기준: 지시서 6절 자동 기준 + C-track 4 shard·`Verify WorldMap3D` success. 최종 합격은 김작 F6(오른쪽 아래 버튼을 누르면 하늘이 도는 동안 턴이 **한 번만** 돌고, 턴 요약 팝업이 기존처럼 뜬다). `USE_DAYNIGHT_TURN_BUTTON` 기본 `true`.

# ORDER_TURNBTN_RESKIN — 월드맵 턴 종료 버튼 겉모습 교체 (클코치 작성, 2026-11-06)

## 0. 배경·효력
- 김작이 새 턴 버튼 그림(해·노을·달·새벽 4장 + 금테 틀)을 만들었다. 결정(김작 11-06 10:40): ① 클릭 영역 = 하늘 창 원 전체, ② 「턴 종료」 글자판 제거 + 호버 툴팁 「턴 종료」, ③ 런타임 텍스처는 512 세트(디코드 ≈6.3 MiB).
- **이 지시서는 겉모습 교체다. 새 노드·새 시그널·새 스크립트를 만들지 않는다.** 기존 `scripts/worldmap/worldmap_turn_compass.gd`(`WorldMapTurnCompass`, 노드 `WorldMapUI/TurnEndCompass`, 시그널 `turn_end_requested`)를 고친다.
- 큐 규칙(`agent/ORDER_QUEUE.md` 4·5·10절)을 그대로 따른다: 확인 질문 금지, 멈춤 조건이면 보고서만 남기고 멈춘다. push는 이 지시서의 새 가지 `feature/wm3d-turnbtn-20261106`에만. `main`·다른 가지 push 금지.
- 에셋 9장은 이 지시서 가지(`origin/feature/wm3d-orders-20261105`)의 `agent/assets/turnbtn_512/`에 있다. 읽는 법: `git show origin/feature/wm3d-orders-20261105:agent/assets/turnbtn_512/<파일>`(바이너리는 `git show … > 파일` 대신 `git archive`/`git checkout origin/feature/wm3d-orders-20261105 -- agent/assets/turnbtn_512/`로 작업 트리 밖 임시 폴더에 풀어서 복사).

## 1. 먼저 읽기 전용으로 확인 (보고서에 표로, 하나라도 다르면 멈춤)
클코치가 `main` `ab9b739`의 `worldmap_turn_compass.gd`를 읽고 쓴 [사실]이다. 실제 파일과 다르면 멈추고 보고.
1. 누르는 입구는 두 곳이다. ⓐ 글자판 버튼 `_plaque_button.pressed` → `_on_plaque_pressed()`가 `turn_end_requested.emit()`을 **먼저** 보내고 `_on_turn_button_pressed_serialized()`를 부른다. ⓑ 옛 턴 종료 버튼 `pressed`(다른 경로)는 `_install_pressed_wrapper`가 `_on_turn_button_pressed_serialized`로 바꿔 끼운다. → 새 클릭 영역은 ⓐ의 `_plaque_button` 자리를 대신해야 한다.
2. `_on_turn_button_pressed_serialized()` 흐름: 실제 턴 종료 상태인지 확인 → `_serializing_turn_end = true` → 옛 버튼 `disabled=true` → 글자판 숨김 → `_start_continuous_spin()` → **`SPIN_DURATION_SEC`(1.60초) 대기(시각 선행 연출)** → 옛 버튼 `disabled=false` → **`_invoke_original_pressed_callbacks()`(여기서 진짜 턴이 돈다)** → `_wait_for_completed_turn(pre_turn_token)`(최대 `TURN_WAIT_TIMEOUT_MSEC` 10000ms) → `_finish_spin_cleanly()` → `_serializing_turn_end = false`. 이 순서·상수(1.60초, 10초)는 **바꾸지 않는다.**
3. 글자판 가시 조건은 `_is_actual_turn_end_available()`(직렬화 중 아님, 옛 버튼 존재·활성, 글자에 "턴 종료" 포함·"편집" 미포함)이고 `_process`의 `_refresh_plaque_availability()`가 매 프레임 판정한다. → 새 클릭 영역도 **같은 조건**일 때만 클릭을 받는다.
4. 이 스크립트를 쓰는 곳 4곳: `ui/worldmap_turn_compass_installer.gd`, `worldmap_16x9_test_host.gd`, `worldmap_background_refresh_tool.gd`, 그리고 `TurnEndCompass` 이름으로 찾는 `ui/worldmap_turn_summary_controller.gd`·`ui/worldmap_turn_transition_late_guard.gd`. 검증기 `tools/validate_p1b_16x9_functional_parity.py`·`validate_p1b3_worldmap_interaction_presentation.py`가 노드 이름·스크립트 경로 문자열을 단언한다. 6곳이 바뀐 스크립트와 계속 맞는지 확인.
5. `Needle`/`Base`/`Cap`/`TurnEndPlaque`/`TurnEndPlaqueButton` 노드 이름을 참조하는 **테스트·검증기·다른 스크립트가 있는지** 전체 검색(클코치 검색은 `tests`·`tools`·`scripts`에서 0건이었으나 `.tscn`·`.json`·`.yml`은 미확인). 있으면 보고서에 목록.
6. `assets/ui/turn_button/`는 새 하위 폴더다(`assets/ui/`는 이미 있음). 이 지시서가 허용하는 유일한 새 폴더.

## 2. 해야 할 일
### 2-A. 에셋 복사
- 9장을 `res://assets/ui/turn_button/`에 그대로 복사: `turn_btn_frame.png`·`turn_btn_window_mask.png`·`turn_btn_center.png`·`turn_btn_center_hover.png`·`turn_btn_center_pressed.png`(각 512×512 RGBA), `sky_1_day.png`·`sky_2_dusk.png`·`sky_3_night.png`·`sky_4_dawn.png`(각 288×288 RGBA).
- 저장소 관례(`assets/worldmap/ui/*.png.import`가 커밋돼 있음)대로 `.import` 파일도 만들어 커밋한다(`godot --headless --import` 등). 텍스처 임포트 설정은 기본값, 바꿨다면 보고서에.
- 1024 마스터·`sizes/256`·`sizes/128`·미리보기는 **저장소에 넣지 않는다.**

### 2-B. 스크립트 (`worldmap_turn_compass.gd`)
1. 플래그: `const USE_DAYNIGHT_TURN_BUTTON := true`, 그리고 테스트가 끌 수 있게 `var use_daynight_turn_button := USE_DAYNIGHT_TURN_BUTTON`(인스턴스 값을 `_ready` 전에 바꿀 수 있어야 함). **노드·시그널·직렬화·대기 로직은 플래그와 무관하게 하나.** 플래그는 그리는 레이어와 클릭 모양만 가른다.
2. 레이어 (플래그 true, 아래→위): `SkyA`, `SkyB`(하늘 288 텍스처, 창 원에 맞춤), `Frame`(512 전체를 `COMPASS_SIZE` 240에 맞춤), `Center`(같은 캔버스, `TextureRect`). 전부 `mouse_filter = IGNORE`.
   - 좌표(마스터 1024 → 240 화면 배율 `240/1024`): 창 중심 `(510.5, 515.5)`×배율 ≈ `(119.6, 120.8)`, 창 지름 576×배율 = **135px**. 하늘 위치 = 창 중심 − 지름/2.
   - 플래그 false: 기존 `Base`/`Needle`/`Cap`/글자판 구성 그대로(코드 삭제 금지). 새 레이어는 만들지 않는다.
   - 새 텍스처는 `preload` 상수가 아니라 `load()`로 플래그 true일 때만 읽는다(false일 때 6MB를 올리지 않기 위해).
3. 글자판: 플래그 true면 `TurnEndPlaque`(그림)을 만들지 않는다. 클릭 영역은 `TurnEndPlaqueButton`을 **대체하는 원형 클릭 컨트롤**(예: `Control`을 상속하고 `_has_point(point)`를 창 중심·반지름 67.5px 원 거리 판정으로 재정의, 이름 `TurnEndHitArea`). 사각 `Button` 모서리가 맵 클릭을 막으면 안 된다.
   - 가시·클릭 조건은 1절 3항의 `_is_actual_turn_end_available()`와 같다. 조건이 거짓이면 `visible=false`(또는 `mouse_filter=IGNORE`)로 맵 클릭을 통과시킨다. 페이드 연출은 필요 없다.
   - `pressed`에 해당하는 동작은 기존 `_on_plaque_pressed()` 본문(= `turn_end_requested.emit()` 후 직렬화 함수 호출)을 **그대로** 재사용한다. 복제 금지.
   - `tooltip_text = "턴 종료"`(마우스 올리면). 커서는 `CURSOR_POINTING_HAND`.
4. 호버/눌림 그림: 호버 → `turn_btn_center_hover.png`, 누르는 동안 → `turn_btn_center_pressed.png`, 나머지 → `turn_btn_center.png`. 연출(직렬화) 중에는 교체를 생략해도 된다. 루트 `scale`·`rotation` 변경 금지(클릭 원이 어긋난다). 눌림은 텍스처 교체와, 원하면 `SkyA`/`SkyB`의 `modulate` 살짝 어둡게(예: 0.92)로만 표현.
5. 하늘 순환(바늘 회전 대체): `_start_continuous_spin()`이 플래그 true일 때 바늘 대신 하늘을 돌린다.
   - 하나의 `Tween` 루프(`set_loops`, `tween_method` 진행도 0→1, 주기 `CYCLE_SEC := 1.4`). 구간 4개(day→dusk→night→dawn→day) 각 0.35초, 진행도에서 구간 번호 `i = floor(p*4)`와 구간 내 비율 `t`를 구해 `SkyA = skies[i]`, `SkyB = skies[(i+1)%4]`, `SkyB.modulate.a = ease_in_out_sine(t)`. (구간마다 콜백으로 텍스처 갈아끼우는 방식 말고, 위 한 함수로.)
   - 선행 연출 `SPIN_DURATION_SEC`(1.60)은 **그대로**(1.4초 주기와 안 맞아도 됨, 반복되므로).
   - 마무리 `_finish_spin_cleanly()`: 플래그 true면 현재 진행도에서 **다음 낮(진행도 1.0)까지 남은 만큼**만 이어서 돌린 뒤(최소 0.08초, 기존 공식과 같은 모양) `SkyA = day`, `SkyB.modulate.a = 0`, 진행도 0으로 정리한다. 낮에서 멈추는 것이 합격 조건이다.
   - 타임아웃(10초 상한)에서도 같은 마무리를 지난다(기존 코드가 이미 `_wait_for_completed_turn` 뒤 `_finish_spin_cleanly`로 모임, 그 구조 유지).
6. `_layout_compass()`: 새 레이어도 `COMPASS_SIZE` 기준으로 재배치(창 좌표 포함). 위치(오른쪽 아래 여백 `RIGHT_MARGIN_RATIO`·`MIN_RIGHT_MARGIN`·`BOTTOM_MARGIN`)는 **바꾸지 않는다.**
7. 12지 링은 장식(고정). 시각·계절 연동은 이번에 하지 않는다.

### 2-C. 테스트 (새 파일 `tests/scripts/test_worldmap_turn_button_daynight.gd`(+`.uid`) + CI 목록 한 줄)
가짜 월드 씬(옛 턴 종료 버튼 `"턴 종료"` 글자, 턴 라벨·달력 라벨, 호출 횟수 세는 콜백)으로 `bind_world_scene`을 붙여 검증:
- ⓐ 노드 이름 `TurnEndCompass`로 설치되고 시그널 `turn_end_requested`가 있다(이름 불변).
- ⓑ 플래그 true: `SkyA`·`SkyB`·`Frame`·`Center` 존재, `TurnEndPlaque` 없음. 플래그 false: `Base`·`Needle`·`Cap`·글자판 존재, 새 레이어 없음.
- ⓒ 클릭 원 판정: 창 중심 → true, 창 가장자리 안쪽(반지름 −2px) → true, 반지름 +3px(금테 쪽) → false, 컨트롤 사각 모서리 → false, 가운데 아이콘 중심 → true.
- ⓓ 클릭 한 번 = `turn_end_requested` **정확히 1회** + 옛 콜백 **정확히 1회**(더블 턴 없음). 직렬화 중 두 번째 클릭은 무시(콜백 1회 유지).
- ⓔ 턴 라벨이 바뀐 뒤 옛 버튼이 다시 "턴 종료" 상태가 되면 마무리가 일어나고, 그 뒤 `SkyA`가 `sky_1_day` 텍스처, `SkyB.modulate.a == 0`.
- ⓕ 옛 버튼이 "편집" 글자이거나 `disabled`이면 클릭 영역이 숨겨져(또는 입력 무시) 클릭해도 시그널이 안 나간다.
- ⓖ 타임아웃 경로(턴이 안 끝남)는 10초를 실제로 기다리지 말고, 상수를 건드리지 않고도 되는 방법이 없으면 **생략하고 보고서에 "미검증"** 으로 적는다(`TURN_WAIT_TIMEOUT_MSEC` 값 변경 금지).
- 기존 컴퍼스 관련 테스트·`test_worldmap_turn_controller_extraction.gd`·턴 요약 팝업 테스트가 그대로 통과해야 한다(기대값 완화 금지; 노드 이름 참조 테스트가 있으면 그 이름만 갱신).

## 3. 하지 말 것
- 새 노드 클래스·새 시그널(`end_turn` 등) 추가 금지. 연출이 끝난 뒤에야 시그널을 보내는 방식 금지. 옛 나침반 노드를 따로 살려 두고 새 버튼과 **함께** 옛 버튼 `pressed`에 연결하기 금지(턴이 두 번 돈다).
- `SPIN_DURATION_SEC`(1.60)·`TURN_WAIT_TIMEOUT_MSEC`(10000)·직렬화 순서·`_get_turn_token`·`_install_pressed_wrapper` 로직 변경 금지.
- `worldmap_main.gd`·턴 요약 컨트롤러·late guard·installer·HUD 컨트롤러 수정 금지(1절 4항에서 맞지 않으면 멈춤).
- 1024 마스터 에셋을 저장소에 넣기 금지. 설정 파일(`samwar_worldmap3d.cfg`) 수정 금지.

## 4. 수정·추가 경로 (이것이 전부)
- 수정: `scripts/worldmap/worldmap_turn_compass.gd`, CI 테스트 목록 파일(한 줄)
- 추가: `assets/ui/turn_button/*.png` 9장 + `.import` 9개, `tests/scripts/test_worldmap_turn_button_daynight.gd`(+`.uid`), `agent/REPORT_TURNBTN_RESKIN_20261106.md`
- 그 밖의 경로가 필요하면 멈춤.

## 5. 로컬 검증
1. 1절 확인표 완료.
2. `godot --headless` 로 새 테스트 + 기존 컴퍼스·턴 요약·턴 컨트롤러 테스트 + `tools/validate_p1b*` 두 개 통과.
3. 헤드리스 렌더 가능하면 플래그 true 4상태(해·노을·달·새벽) 240px 스크린샷을 `agent/evidence/turnbtn_*.png`로(불가능하면 보고서에 "미검증").
4. 플래그 false로 같은 테스트 중 ⓐⓓⓔ가 통과(옛 나침반 복귀).

## 6. 합격 기준 (자동) + 보고
- 위 5절 전부 통과, 새 가지 push, C-track 4 shard·`Verify WorldMap3D` success(CI 확인).
- 보고서 `agent/REPORT_TURNBTN_RESKIN_20261106.md`: 1절 확인표(실제 코드와 다른 점 표시), 변경 요약, 시작/끝 해시, 메모리 측정(플래그 true 로드 후 텍스처 합계), "택한 해석", 미검증 항목(타임아웃 경로 등).
- 김작이 할 일(보고서 맨 위에 적을 것): F6 → 오른쪽 아래 버튼 클릭 → ① 하늘이 해→노을→달→새벽으로 도는지 ② 턴이 한 번만 지나가는지(달력·턴 수 +1) ③ 턴 요약 팝업 ④ 끝나면 낮에서 멈추는지 ⑤ 창 가장자리 바깥(금테)을 눌러도 안 눌리는지 ⑥ 툴팁 「턴 종료」.
