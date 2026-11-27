기준 화면: `scenes/battle3d/Terrain20x20_Preview.tscn`(F6) — 전장 땅을 카메라 B로 찍은 엔진 화면 PNG.
합격 기준: 김작 PC에서 명령 한 줄로 카메라 B(1920×1080) 엔진 화면 PNG가 나오고, 같은 화면을 둘레 선 켬/끔과 록비서 그림 땅 켬/끔으로 찍을 수 있다. 게임 동작·기존 장면 화면은 바뀌지 않는다(그림 땅 기본값 꺼짐). CI C-track 4 초록이면 클코치가 `main`에 합친다.

# 큐 44 — 전장 엔진 캡처 도구 (록비서 2.5D 시안 ↔ 엔진 화면 비교용)

작성: 클코치 / 2026-11-28 08:10. 근거: 록비서 `61_록비서_전장그림_골문서.md` 6절 3번. 지금 시안은 파이썬 미리보기라서 엔진에서 같은 화면이 나오는지 확인한 적이 없다. 클코치 `62_…` 회신 1절 3번.
전장 그림 보완 단계는 클코치 판단으로 진행한다(김작 11-28 07:26). 이 큐는 비교 도구만 만들고, 게임 화면·규칙은 바꾸지 않는다.
기준은 `main` 최신(큐 43 합류 뒤면 그 main). 새 가지 `feature/battle3d-engine-capture-20261128`. 푸시 승인. **큐 43 다음 순서.**

## 0. 지금 상태 (클코치 확인, `83c50e0`)
- `scripts/battle3d/eastwar_terrain_20x20.gdshader`: 땅은 `v_world_pos.xz` 월드 UV로 칠하고, 판 밖은 `outer_ground_tex`(220 m), 절벽은 triplanar로 칠한다. 둘레 선은 `show_border_line = true`, 색 (0.92, 0.84, 0.58), 폭 0.12 m다.
- `scripts/battle3d/terrain_preview.gd`: 단독 미리보기 장면. 카메라는 직교, `yaw 0.32`, `zoom 60`이고 캡처 횟수 변수가 있다.
- 록비서 카메라 B: 직교, yaw 0.32, 수평 거리 43, 높이 28, 초점 월드 (27, 0, 5.5), 크기 42, 피치 약 33도.

## 1. 넣는 것
1. **판 안 그림 땅 uniform**: 셰이더에 `use_board_paint_tex`(기본 **false**), `board_paint_tex`(source_color, 선형 + 밉맵, repeat 끔), `board_paint_world_size`(기본 60.0)를 넣는다. 켜지면 판 안 땅 색을 `v_world_pos.xz / board_paint_world_size`로 샘플한 그림으로 바꾼다. 꺼져 있으면 지금과 **1픽셀도 다르지 않아야** 한다.
2. **판 밖 그림 크기**: `outer_ground_world_size`를 캡처 도구에서 180으로 바꿀 수 있게 한다(기본값 220은 유지).
3. **캡처 도구** `tools/battle3d_capture.gd`(SceneTree 스크립트, 화면이 있는 실행 전용):
   - `godot --path . --script res://tools/battle3d_capture.gd -- --camera B --size 1920x1080 --border off --paint <폴더> --out <폴더>`
   - 미리보기 장면을 그대로 만들고 카메라를 B 값으로 놓는다(A도 선택 가능). 두 프레임 기다린 뒤 뷰포트 이미지를 PNG로 저장한다.
   - `--paint <폴더>`: 그 폴더의 `board_paint.png`(판 안), `outer_paint.png`(판 밖)를 읽어 1-1·1-2로 입힌다. **이 폴더는 저장소 밖**(예: `C:\dev\eastwar_art_local`)에 둔다. 저장소에 원본 그림을 올리지 않는다(공개 저장소이고 아직 시안이라서).
   - `--units off`(부대 숨김), `--trees off`(나무 숨김) 선택 가능.
   - 화면 없이 실행하면(헤드리스) "화면이 있는 실행 필요" 메시지를 띄우고 종료 코드 2로 끝낸다.
4. 출력 PNG 옆에 같은 이름의 `.json`(카메라 값, 해상도, 켠 옵션, Godot 버전, 커밋 해시)을 남긴다.

## 2. 시험 — `tests/scripts/test_battle3d_capture_options.gd`, `[BATTLE3D_CAPTURE] checks=N failures=[...]`, C-track 등록 (화면 없이 가능한 것만)
1. `use_board_paint_tex` 기본값은 false이고, 셰이더 파라미터에 그림 텍스처가 없을 때 기존 값이 그대로다.
2. 캡처 도구의 인자 해석: 카메라 B 값이 위 0절 숫자와 정확히 같고, `--border off`이면 `show_border_line == false`다.
3. 헤드리스 실행에서는 종료 코드 2와 안내 메시지가 나온다.
4. 회귀: 전투 시험 전체(BATTLE3D_*, TACTIC_*, ATTACK_* 등) 그대로.

## 3. 클코드가 김작 PC에서 한 번 실행 (보고서에 첨부)
- 엔진 그대로, 카메라 B, 둘레 선 켬과 끔 → PNG 2장.
- 록비서 10호 그림 파일이 김작 PC에 있으면 `--paint`로 1장을 더 찍는다. 없으면 이 단계는 건너뛰고, 록비서가 공유폴더에 원본 PNG를 올린 뒤에 찍는다.

## 4. 허용 파일
- `eastwar_terrain_20x20.gdshader`(1-1·1-2 uniform만)
- `terrain_board_builder.gd`(그 uniform을 넘기는 export만)
- 새 `tools/battle3d_capture.gd`, 새 시험, `verify-c-track.yml`

전투 규칙·칸 데이터(`terrain_types.json`, `heightfield.json`)·기존 기본값은 바꾸지 않는다.

## 5. 보고·푸시
- 코드 커밋 → 푸시 → CI
- 보고서 `agent/REPORT_BATTLE3D_CAPTURE_20261128.md` `[skip ci]`에 3절 PNG 경로(김작 PC 로컬)와 실행 명령을 적는다. PNG 자체는 공유폴더에 'NN_클코드_…'로 올려도 된다.
