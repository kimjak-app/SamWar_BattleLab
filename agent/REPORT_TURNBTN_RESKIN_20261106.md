기준 화면: 새 가지 `feature/wm3d-turnbtn-20261106`(시작 `main` `ab9b739`, 코드 `32e9b05`)에서 `res://WorldMap.tscn` 오른쪽 아래. 나침반 자리(240×240)에 금테 원형 틀 + 하늘 창 + 가운데 재생 아이콘이 있고 「턴 종료」 글자판은 없다. 누르면 하늘이 해→노을→달→새벽으로 돌다가 턴이 끝나면 해에서 멈춘다. 창 위에 마우스를 올리면 툴팁 「턴 종료」.
합격 기준: 지시서 6절 자동 기준(새 테스트 43/0, 플래그 끔 포함) + C-track 4 shard success. `Verify WorldMap3D`는 경로 조건으로 실행되지 않음(7절). 최종 합격은 김작 F6.

**김작이 할 일 (F6)**: `WorldMap.tscn` F6 → 오른쪽 아래 버튼 클릭 → ① 하늘이 해→노을→달→새벽으로 도는지 ② 턴이 한 번만 지나가는지(달력·턴 수 +1) ③ 턴 요약 팝업 ④ 끝나면 낮에서 멈추는지 ⑤ 창 가장자리 바깥(금테)을 눌러도 안 눌리는지 ⑥ 툴팁 「턴 종료」.

# REPORT TURNBTN RESKIN — 월드맵 턴 종료 버튼 겉모습 교체 (2026-11-06)

## 요약
- [사실] 기존 `WorldMapTurnCompass`(노드 `TurnEndCompass`, 시그널 `turn_end_requested`, 직렬화 흐름)를 그대로 두고, 그리는 층과 클릭 모양만 바꿨습니다.
  - 새 노드 클래스·새 시그널·새 스크립트는 없습니다.
  - `SPIN_DURATION_SEC`(1.60)·`TURN_WAIT_TIMEOUT_MSEC`(10000)·직렬화 순서·`_get_turn_token`·`_install_pressed_wrapper`는 0줄 변경입니다.
  - 기존 줄에서 바뀐 것은 3줄입니다(`_ready`의 두 빌드 호출을 플래그 분기로 감쌈).
- [사실] 시작 `ab9b739` → 끝 `32e9b05`(코드 1커밋). 22개 파일 +727 / −3: 에셋 9장 + `.import` 9개, 스크립트, 새 테스트 + `.uid`, CI 목록 +1줄.
- [사실] 새 테스트 `test_worldmap_turn_button_daynight.gd` 43/0. 기존 월드맵 CI 테스트 37개 모두 통과(턴 컨트롤러 11/0 포함). 검증기 72/72, p1b 검증기 두 개 통과.

## 1. 먼저 확인한 [사실] (`main` `ab9b739`, 모두 일치)
| # | 지시서 | 실제 | 일치 |
|---|---|---|---|
| 1 | 입구 두 곳: ⓐ `_plaque_button.pressed → _on_plaque_pressed()`(시그널 먼저, 그다음 직렬화) ⓑ 옛 버튼 `pressed`는 `_install_pressed_wrapper`가 바꿔 끼움 | 99행 연결, 160~167행(`turn_end_requested.emit()` 뒤 `_on_turn_button_pressed_serialized()`), 134~157행 | 예 |
| 2 | 직렬화: 확인 → 플래그 → 옛 버튼 비활성 → 글자판 숨김 → 연속 회전 → 1.60초 → 옛 버튼 활성 → 원래 콜백 → 턴 완료 대기(최대 10000ms) → 마무리 → 플래그 해제 | 170~203행 그대로 | 예 |
| 3 | 글자판 가시 = `_is_actual_turn_end_available()`, `_process`의 `_refresh_plaque_availability()`가 매 프레임 | 295~314행, 59~61행 | 예 |
| 4 | 사용처: installer, `worldmap_16x9_test_host.gd`, `worldmap_background_refresh_tool.gd`, turn summary·late guard(`TurnEndCompass` 이름으로 찾음), 검증기 2개 | 모두 노드 이름·스크립트 경로·시그널(`turn_end_requested`)·`bind_world_scene`만 씁니다. 바뀐 스크립트와 맞습니다. 검증기 두 개(`validate_p1b_16x9_functional_parity.py`, `validate_p1b3_…`) 통과. 그 밖에 `worldmap_16x9_editor_preview.gd:163-166`이 `TurnEndCompass` 이름을 씁니다(편집기 미리보기, 이름만). | 예 |
| 5 | `Needle`/`Base`/`Cap`/`TurnEndPlaque`/`TurnEndPlaqueButton` 이름 참조 | `tests`·`tools`·`scripts`·`.tscn`·`.json`·`.yml` 전체 검색: 이 스크립트 자신 외 0건 | 예 |
| 6 | `assets/ui/turn_button/`가 유일한 새 폴더 | 새 폴더는 이것 하나(`assets/ui/`는 원래 있음) | 예 |

## 2. 바꾼 것 (`scripts/worldmap/worldmap_turn_compass.gd`)
- 플래그 `const USE_DAYNIGHT_TURN_BUTTON := true`(27행)와 인스턴스 값 `var use_daynight_turn_button`(`_ready` 전에 바꿀 수 있음).
  - 켜짐 → `_build_daynight_layers()`(100행).
  - 꺼짐 → 기존 `_build_compass_layers()` + `_build_turn_end_plaque()` 그대로(코드 삭제 0).
- 새 텍스처는 플래그가 켜졌을 때만 `load()`합니다(`preload` 아님).
- 층(아래→위): `SkyA`, `SkyB`, `Frame`, `Center`(모두 `TextureRect`, `MOUSE_FILTER_IGNORE`).
  - 하늘 창: 마스터 1024의 중심 (510.5, 515.5)·지름 576 × 240/1024 → 중심 (119.63, 120.82), 지름 135px(`get_window_circle()`, 133행).
  - `Frame`·`Center`는 240 캔버스 전체에 맞춥니다.
- 클릭 영역 `TurnEndHitArea`
  - 내장 `TextureButton`에 240×240 원형 `BitMap` 클릭 마스크(반지름 67.5px, 156행)를 줬습니다. 원 밖(금테·사각 모서리)의 클릭은 GUI가 이 버튼을 고르지 않아 지도로 갑니다.
  - 가시 조건은 `_is_actual_turn_end_available()`와 같습니다(`_refresh_hit_area_availability`, 192행, `_process`에서). 직렬화가 시작되면 `_hide_plaque_immediately()`에서 바로 숨깁니다.
  - `pressed → _on_plaque_pressed`로 기존 함수를 그대로 다시 씁니다(복제 없음). 툴팁 "턴 종료", 커서 `CURSOR_POINTING_HAND`.
  - 호버하면 `turn_btn_center_hover.png`, 누르는 동안은 `turn_btn_center_pressed.png`와 하늘 `self_modulate` 0.92, 나머지는 `turn_btn_center.png`. 연출 중에는 교체하지 않습니다. 루트 `scale`·`rotation`은 건드리지 않습니다.
- 하늘 순환
  - 시작: `_start_continuous_spin()`이 켜짐이면 `_start_sky_cycle()`(418행)을 부릅니다. Tween 하나(`set_loops`, `tween_method` 0→1, `CYCLE_SEC = 1.4`)가 `_apply_sky_progress`(205행)를 돌립니다. 구간 `i = floor(p×4)`에서 `SkyA = skies[i]`, `SkyB = skies[(i+1)%4]`, `SkyB.modulate.a = ease_in_out_sine(t)`입니다.
  - 마무리: `_finish_spin_cleanly()`가 켜짐이면 `_finish_sky_cycle()`(430행)을 부릅니다. 지금 진행도에서 1.0(다음 낮)까지 `max(0.08, 1.4 × 남은 비율)`초 이어 돈 뒤, 진행도 0(`SkyA` = 낮, `SkyB` 알파 0)으로 정리합니다. 타임아웃 경로도 기존처럼 `_wait_for_completed_turn` 뒤 같은 마무리를 지납니다.
- `_layout_compass()`: 켜짐이면 새 층과 클릭 영역도 240 기준으로 다시 놓습니다. 화면 위치(여백 상수)는 그대로입니다.
- 에셋 9장은 지시서 가지의 `agent/assets/turnbtn_512/`에서 `git archive`로 작업 트리 밖 임시 폴더에 풀어 복사했습니다(파일 크기 그대로).
  - 512×512 RGBA 5장, 288×288 RGBA 4장.
  - `.import` 9개는 `godot --headless --editor --import`로 만든 기본값입니다(`compress/mode=0`, 밉맵 없음, 바꾼 것 없음).
  - 1024 마스터·256·128·미리보기는 넣지 않았습니다.
  - `turn_btn_window_mask.png`는 복사·임포트만 했고 런타임에서는 읽지 않습니다(클릭 원은 코드의 중심·지름으로 만듦, 택한 해석 1).

## 3. 로컬 결과 (원문, 사용자 폴더는 임시 폴더)
```
[TURN_BUTTON_DAYNIGHT] checks=43 failures=[]
[WORLDMAP_TURN_CONTROLLER] PASS: 11 checks, 0 failures
CI 목록의 test_worldmap_*.gd 37개: 37/37 exit 0
P-1B 16:9 functional parity validation: PASS (real-tech exception enforced)
P-1B-3 Production WorldMap interaction/presentation static validation: PASS
validators=72 pass=72 fail=0   (작업 트리, 커밋 뒤 깨끗한 트리 모두)
```
새 테스트(가짜 월드 씬: 옛 버튼 "턴 종료" + 호출을 세는 콜백 + 턴·달력 라벨, `bind_world_scene`):
- ⓐ 이름 `TurnEndCompass`, 시그널 있음(켜짐·꺼짐 둘 다).
- ⓑ 켜짐은 새 층 5개가 있고 옛 층·글자판이 없음, 꺼짐은 그 반대. 층 4개 `IGNORE`, 툴팁·커서, 창 원 좌표, 하늘 위치·크기, 시작은 낮.
- ⓒ 실제 마우스 이동을 뷰포트에 넣고 `gui_get_hovered_control()`로 확인: 창 중심 참, 반지름 −2 참, 반지름 +3(오른쪽·아래 금테) 거짓, 사각 모서리 거짓, 가운데 아이콘 참. 호버 텍스처도 확인.
- ⓓ 클릭 1번 → 시그널 1번 + 옛 콜백 1번(1.6초 뒤). 연출 중 두 번 더 눌러도 그대로 1번. 연출 중 하늘이 실제로 바뀜.
- ⓔ 턴 라벨을 바꾸면 연출이 끝나고 `SkyA`가 낮, `SkyB` 알파 0. 꺼짐이면 바늘 0. 클릭 영역이 다시 보임.
- ⓕ 옛 버튼이 "편집"이거나 `disabled`이면 클릭 영역이 숨고, 눌러도 시그널·콜백 0.
- 플래그 꺼짐으로 ⓐⓓⓔⓕ도 통과(옛 나침반으로 돌아감).

## 4. 스크린샷 (창 렌더, 240×240, `agent/evidence/`)
| 파일 | 상태 | 크기(B) | SHA-256 |
|---|---|---|---|
| `turnbtn_day.png` | 진행도 0 | 76,847 | `16893004344f06a57c752fed0bc42d0d833cf8457b0f8466c4d9e933e8f4fffa` |
| `turnbtn_dusk.png` | 0.25 | 76,440 | `6d38758a1547fbafe3ad9e1d5a5087f9406dfecabc68b31d85531d4270a706f4` |
| `turnbtn_night.png` | 0.5 | 76,704 | `573c21673f61592e6ef485df370b5658d38b713d38d48ea8dc306a78dae6ac40` |
| `turnbtn_dawn.png` | 0.75 | 76,645 | `00e999235aca910f963a19653a49fbec584f889e4cc9941ec482137985d74214` |

배경은 단색(어두운 남색)입니다. 하늘이 금테 창 안에 맞게 들어가는 것을 눈으로 확인했습니다.

## 5. 메모리
- [사실] 켜짐일 때 읽는 텍스처 8장(하늘 4 + 가운데 3 + 틀 1)의 RGBA8 디코드 합은 5,521,408 B(5.27 MiB)입니다. 지시서의 ≈6.3 MiB는 마스크(512²×4 = 1 MiB)까지 9장이고, 마스크는 런타임에서 읽지 않습니다.
- [사실] 같은 실행에서 `Performance.RENDER_TEXTURE_MEM_USED`는 21.24 MB였습니다. 단독 장면(배경·기본 글꼴 포함) 전체 값이라, 버튼만의 증가분은 아닙니다.

## 6. 택한 해석
1. **원형 클릭**
   - 지시서 예시는 `Control`을 상속하고 `_has_point`를 재정의하는 것이었습니다. 하지만 3절이 "새 노드 클래스 금지"라서 내장 `TextureButton`의 클릭 마스크(원형 `BitMap`)로 같은 동작을 만들었습니다.
   - 원은 지시서의 마스터 좌표(중심·지름)로 코드에서 그립니다.
   - 마스크 그림(`turn_btn_window_mask.png`)도 측정해 보니 512 기준 중심 (255.5, 257.5), 지름 288로 같은 원이었습니다(1024 기준 중심 (511, 515), 지름 576).
2. **하늘 그림**: 하늘 4장은 이미 원 모양(모서리 알파 0)이라 마스크로 따로 자르지 않았습니다.
3. **12지 링**: 장식으로 고정했습니다(틀 그림에 포함).

## 7. 미검증·CI
- **미검증**: ⓖ 타임아웃 경로(턴이 끝나지 않아 10초를 다 기다리는 경우). 상수를 바꾸지 않고는 10초를 기다려야 해서 테스트하지 않았습니다. 코드상 기존과 같이 `_wait_for_completed_turn` 뒤 같은 마무리를 지납니다.
- **김작 F6에서만 확인 가능**: 실제 게임 화면에서 지도 클릭이 금테 바깥에서 통과하는지(테스트는 가짜 월드에서 GUI 고르기만 확인), 턴 요약 팝업이 기존처럼 뜨는지(관련 자동 테스트 없음).
- [사실] 코드 커밋 `32e9b05`: Verify C-track refactor run `42162300047` **success**(shard 0~3 모두 success). CI 로그에서 `[TURN_BUTTON_DAYNIGHT] checks=43 failures=[]`, `[WORLDMAP_TURN_CONTROLLER] PASS: 11 checks, 0 failures`를 확인했습니다.
- Verify WorldMap3D는 이 커밋에서 실행되지 않았습니다(경로 조건: 3D 경로를 건드리지 않음).
