# 큐 44 보고 — 전장 엔진 캡처 도구 (록비서 2.5D 시안 ↔ 엔진 화면 비교)

- 지시서: `agent/ORDER_BATTLE_ENGINE_CAPTURE_20261128.md`
- 가지: `feature/battle3d-engine-capture-r2-20261128`, 기준 `main` `776b11d`(처음 `3182e75` 위 `feature/battle3d-engine-capture-20261128`에서 만든 뒤 4절대로 리베이스)
- 커밋: 코드 `6b6bc2f`(`[skip ci]` 없음, 리베이스 전 `77233b4`) → 이 보고서(`[skip ci]`)
- 전투 규칙, 칸 데이터(`terrain_types.json`, `heightfield.json`), 기존 기본값, 게임 장면은 바꾸지 않았다. `worldmap_main.gd`도 0줄이다.

## 1. 넣은 것
1. **셰이더** `scripts/battle3d/eastwar_terrain_20x20.gdshader`, 1d절 uniform 3개
   - `use_board_paint_tex`(기본 **false**)
   - `board_paint_tex`(source_color, 선형 + 밉맵, repeat 끔)
   - `board_paint_world_size`(기본 60.0)
   - 켜면 판(0~60 m) 안의 땅 색을 `v_world_pos.xz / board_paint_world_size`로 샘플한 그림으로 바꾼다. 바꾸는 위치는 진흙·검댕·눈 덧칠보다 앞이라, 그 덧칠과 칸 선·강조·경계선은 그림 위에 그대로 얹힌다.
   - 꺼져 있으면 `if (use_board_paint_tex)` 안쪽을 건너뛴다.
   - `outer_ground_world_size` 기본값 220은 그대로다.
2. **빌더** `terrain_board_builder.gd`
   - export 3개를 넣었다: `use_board_paint_texture`(false), `board_paint_texture`, `board_paint_world_size`(60).
   - `_apply_terrain_shader_material`이 이 셋을 셰이더에 넘긴다. 텍스처 없이 스위치만 켜면 꺼진 채로 둔다.
3. **캡처 도구** `tools/battle3d_capture.gd`(SceneTree 스크립트)
   - `Terrain20x20_Preview.tscn`을 그대로 띄우고 카메라만 바꾼다. 미리보기의 안내 글 패널은 숨긴다(엔진 화면만 찍으려고).
   - 두 프레임 기다린 뒤 `frame_post_draw`에서 PNG를 저장하고, 같은 이름의 `.json`을 남긴다(카메라 값·위치·피치, 요청/실제 해상도, 켠 옵션, Godot 버전, 커밋 해시).
   - 카메라
     - B: 직교, yaw 0.32, 수평 거리 43, 높이 28, 초점 (27, 0, 5.5), 크기 42, 피치 33.07°
     - A: 미리보기 시작 시점(판 가운데, 높이 40, 크기 60)
   - 옵션: `--camera A|B`, `--size WxH`, `--border on|off`, `--paint <폴더>`, `--outer-size <m>`, `--units on|off`, `--trees on|off`, `--out <폴더>`
   - `--paint` 폴더의 `board_paint.png`는 판 안(1-1)에, `outer_paint.png`는 판 밖(`outer_ground_tex`)에 입힌다. 각각 파일이 있을 때만 쓴다.
   - 헤드리스로 실행하면 "화면이 있는 실행 필요" 안내를 띄우고 **종료 코드 2**로 끝난다. 인자가 틀리면 종료 코드 3이다.

## 2. 시험 — `tests/scripts/test_battle3d_capture_options.gd` (C-track 등록)
`[BATTLE3D_CAPTURE] checks=25 failures=[]`
1. 셰이더 원문에서 세 uniform의 기본값(꺼짐, 60, repeat 끔)을 확인한다. 기존 기본값(경계선 켬, 판 밖 220)이 그대로이고, 셰이더 컴파일 목록에도 세 uniform이 있다.
2. 빌더
   - 그림이 없으면 `use_board_paint_tex == false`, `board_paint_tex == null`이고 경계선 켬·판 밖 220·판 밖 그림 켬이 전과 같다.
   - 스위치만 켜고 텍스처가 없으면 꺼진 채다.
   - 스위치·텍스처·크기를 주면 셋 다 셰이더로 넘어간다.
3. 인자
   - 카메라 B 값이 지시서 0절 숫자와 정확히 같다. 위치는 (40.53, 28, 46.32), 피치는 33.07°다.
   - `--border off`면 `show_border_line == false`다.
   - A, 1280×720, 부대·나무 끔, 판 밖 180도 확인하고, 출력 이름과 틀린 인자 5가지(거부)도 확인한다.
4. 헤드리스 실행: 실제로 Godot 하위 프로세스를 띄우고, 종료 코드 2와 안내 문구를 확인한다.
- 회귀: C-track 전체 219개(전투 BATTLE3D_*·TACTIC_*·ATTACK_* 포함) 모두 그대로다.

## 3. 클코드가 김작 PC에서 실행한 것
명령은 PowerShell 기준이다. 결과는 모두 저장소 밖에 있다.
```
godot --path C:\eastwar_tmp\battle-capture --script res://tools/battle3d_capture.gd -- --camera B --size 1920x1080 --border on  --out C:\eastwar_tmp\battle_captures\final
godot --path C:\eastwar_tmp\battle-capture --script res://tools/battle3d_capture.gd -- --camera B --size 1920x1080 --border off --out C:\eastwar_tmp\battle_captures\final
```
(`godot` = `C:\Users\seong\Desktop\godot\Godot_v4.6.2-stable_win64_console.exe`, 작업 트리 `77233b4`)

| 결과 | 김작 PC 경로 |
|---|---|
| 엔진 그대로, 카메라 B, 둘레 선 켬 | `C:\eastwar_tmp\battle_captures\final\battle3d_camB_1920x1080_border_on.png` (+ `.json`, 커밋 `77233b4…`) |
| 엔진 그대로, 카메라 B, 둘레 선 끔 | `C:\eastwar_tmp\battle_captures\final\battle3d_camB_1920x1080_border_off.png` (+ `.json`) |

- **록비서 10호 그림**: 김작 PC에서 찾지 못했다(`C:\dev\eastwar_art_local` 없음, 바탕화면·문서·다운로드에도 `board_paint`·10호 파일 없음). 지시서대로 이 장은 건너뛰었다. 록비서가 원본 PNG를 올리면 아래 한 줄로 찍는다.
  ```
  godot --path <저장소> --script res://tools/battle3d_capture.gd -- --camera B --paint C:\dev\eastwar_art_local --outer-size 180 --out C:\dev\eastwar_art_local\captures
  ```
- `--paint` 경로 확인: 시험용 단색 체크무늬(`C:\eastwar_tmp\battle_paint_synthetic\board_paint.png` 8×8칸, `outer_paint.png` 단색)로 한 장 찍었다. 결과는 `C:\eastwar_tmp\battle_captures\synthetic\battle3d_camB_1920x1080_border_on_paint_outer180.png`다. 판 안은 체크무늬로 바뀌고, 칸 선·경계선·나무·부대·강은 그 위에 그대로 보인다. 판 밖은 지정한 색이 됐다. 시안 그림이 아니라 동작 확인용이다.

### 3-1. "꺼져 있으면 1픽셀도 다르지 않다" 확인
- 같은 명령(카메라 B, 경계선 켬)으로 두 쪽을 찍어 비교했다.
  - **원래 셰이더·빌더**(`3182e75` 그대로, 잠시 되돌려 찍음)
  - **이번 코드**
- 강물 셰이더가 시간에 따라 움직여서, 같은 코드끼리도 실행마다 강 영역 약 9.4만 픽셀이 달라진다.
- 원래 코드와 이번 코드 사이에 다른 픽셀은 모두 **강물 픽셀에서 4 px 안**에 있다. 시간에 따른 강 경계 흔들림이다. 강 밖(땅·산·칸 선·경계선·부대·나무)은 **1픽셀도 다르지 않다**.

## 4. CI
- **리베이스**: 큐 목록 지시(`main` `776b11d` 위로, 새 가지, 강제 푸시 없음)대로 했다.
  - 코드 커밋 `77233b4`가 새 가지 `feature/battle3d-engine-capture-r2-20261128`에서 **`6b6bc2f`**가 됐다.
  - `77233b4`와 `6b6bc2f` 사이에 다른 파일은 큐 43 보고서와 캡처 그림 7개(모두 `agent/`)뿐이고, 코드 파일 차이는 0개다.
  - 트리 해시: `77233b4` = `b75e7e25779e25f5eee1ec0b704c2d155171b0a4`, `6b6bc2f` = `aa23bc35342ce5dd14d14dc577721889435219e8`(`agent/` 7개만큼 다름).
- `Verify C-track refactor` 실행 **`46096102034`** (r2 가지, head `6b6bc2f`)
  - 결과: **초록**. 4개 묶음 모두 첫 실행에 success다. 끝난 시각 2026-11-28 02:23 UTC.
  - `[BATTLE3D_CAPTURE] checks=25 failures=[]`이고, 검증 스크립트 72개가 통과했다.
- 옛 가지 실행 `46094060970` (head `77233b4`)
  - 첫 실행: shard 0이 빨강이었다. 원인은 컷인 시간 검사 흔들림이다(`test_battle3d_cutin_result_toast.gd`, x4.0에서 [3.951, 3.943, 3.943, 3.989, 3.927] s, 기준 3.95 s 이상).
  - 이번 변경은 컷인과 관계없다. 같은 실행 shard 2에서도 `[BATTLE3D_CAPTURE] checks=25 failures=[]`였다.
  - 클코치가 `--failed`로 다시 돌린 2차는 4/4 초록이다. 클코드는 다시 돌리지 않았다.
- `Verify WorldMap3D`: 경로 조건에 걸리는 파일이 없어 돌지 않는다(3D·월드맵 변경 0).

## 5. 로컬 전체
- 작업 트리 `77233b4`(코드는 `6b6bc2f`와 같음): C-track 시험 219개(CI 목록, 4개 병렬) **219 실행, 219 종료 코드 0**.
- 검증 스크립트 72개 **72 통과**. 전장 지형 검사(`validate_battle3d_terrain_port.py`, `validate_battle3d_edge_scroll.py`, `validate_t2_forest_groves.py`)도 통과했다.

## 6. 남은 문제
1. 록비서 10호 원본 PNG가 오면 `--paint`로 한 장 더 찍어야 한다(3절 명령).
2. 강물이 시간에 따라 움직여서 캡처마다 강 영역이 조금씩 다르다. 시안 비교에는 지장이 없다. 강까지 완전히 같은 그림이 필요하면 물 셰이더 시간을 고정하는 옵션이 따로 필요하다(이번 허용 파일 밖).
3. 해상도가 화면보다 크면 창이 줄어들 수 있다. 실제 이미지 크기를 `.json`의 `image_size`에 남긴다. 이 PC에서는 1920×1080 그대로 나왔다.
