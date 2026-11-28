# 보고 — 큐 44b 전장 밑그림 가이드 + 2D 빌보드 소품 (2026-11-28)

지시서: `agent/ORDER_BATTLE_GUIDE_BILLBOARD_44B_20261128.md`
브랜치: `feature/battle3d-guide-billboard-20261128` (main 2679c75에서 분기)

## 1. 한 일

| 파일 | 내용 |
|---|---|
| `tools/battle3d_capture_layers.gd` (새 파일) | 가이드 두 장 그리기, 좌표 변환, `props.json` 읽어 빌보드 세우기 |
| `tools/battle3d_capture.gd` | `--guide` 플래그, `--paint` 폴더에 `props.json`이 있으면 소품 세우기, 파일 이름에 `props` 꼬리표 |
| `tests/scripts/test_battle3d_capture_options.gd` | 4~7번 검사 추가 (`checks=40 failures=[]`) |

커밋: `7510304`(가이드 + 빌보드), `4f92f0d`(보이는 밑동, 채비서 108).

게임 로직은 바뀌지 않는다. 소품은 캡처 도구에서만 세운다.

## 2. 가이드 두 장 (원점·크기·축)

둘 다 2048×2048 PNG이고, 옆에 같은 이름의 `.json`이 있다.

| 파일 | 원점 (픽셀 0,0) | 한 변 | 셰이더 UV |
|---|---|---|---|
| `guide_board_60m.png` | 월드 (0, 0) | 60 m | `v_world_pos.xz / 60` |
| `guide_outer.png` | 월드 (−63, −75) | 180 m (`--outer-size 180`) | `(xz − play_center) / 180 + 0.5`, play_center = (27, 15) |

- 축: 월드 +x = 오른쪽(픽셀 x 증가), 월드 +z = 아래(픽셀 y 증가).
- 칠한 것:
  - 높이: 회색 음영. 어두울수록 낮다.
  - 등고선: 0.5 m마다 #5a4a3a.
  - 3 m 칸 경계: 흰색, board 그림만.
  - 숲 칸: #3c8c3c.
  - 물: #2f78d0.
  - 다리 바닥: #b07030. 다리 양 끝: #ff2020 점.
  - 성 칸: #a040c0.
  - 보드 네 모서리: #ffd000.
  - 바깥 그림의 플레이 영역 테두리: #ff8000.
- **성문**: 전투 데이터에 성문 칸이 따로 없다. 그래서 성 칸 (5,13)·(13,13)을 성/성문 표시로 함께 쓴다.
- 다리 끝 (월드 m): (23.63, 16.5) – (30.03, 16.5). 빌드된 다리 노드와 0.01 m 안에서 같다.
- 검사 6:
  - 보드 네 모서리와 다리 양 끝을 가이드 픽셀로 바꾼 값이 셰이더 UV 식과 1 px 안에서 같다(최대 오차 0).
  - (60,60)은 2048이다.
  - play_center는 outer 1024다.

만드는 법 (화면이 있는 실행만 된다. headless면 코드 2로 끝난다):

```
Godot --path . --script res://tools/battle3d_capture.gd -- --guide --outer-size 180 --out <폴더>
```

김작 PC에서 뽑은 가이드: `C:\dev\eastwar_art_local\guide\`. 파일은 `guide_board_60m.png/.json`, `guide_outer.png/.json`이고, 만드는 데 21초 걸렸다.

## 3. 빌보드 소품 (`props.json`)

`--paint <폴더>`에 `props.json`이 있으면 읽는다. 항목마다 이런 모양이다.

```json
{"image": "tree_a.png", "x": 12.5, "z": 30.0, "height_m": 4.0, "anchor": "bottom", "shadow": true}
```

- **보이는 밑동**을 그 자리 지형 높이에 맞춘다(채비서 108).
  - 그림 아래의 투명한 줄은 건너뛴다. 알파 컷이 남기는 alpha ≥ 0.5 픽셀이 처음 나오는 줄이 밑동이다.
  - 바위 잔풀처럼 밑동이 다른 곳이면 항목에 `"base_px": n`(그림 아래 끝에서 n줄 위)을 적어 직접 정한다.
  - 시험: 아래 3줄이 투명하고 흐린 픽셀 1개가 있는 PNG, 그리고 `base_px: 2` 항목. 둘 다 보이는 밑동이 지형과 0.05 m 안이다.
- 세로축 고정 빌보드(`BILLBOARD_FIXED_Y`)이고, 알파 컷으로 그린다.
- `shadow: true`면 바닥에 납작한 반투명 그림자를 깐다.
- 다음 항목은 경고 한 줄을 남기고 건너뛴다:
  - 그림이 없다.
  - 바깥 땅 범위 밖이다.
  - `height_m`이 0 이하다.
- `props.json`이 없으면 노드를 하나도 더하지 않는다. 기본 그림은 큐 44와 같다.
  - 같은 옵션으로 찍어 큐 44 캡처와 비교했다.
  - 강물 애니메이션 주변 8 px 밖에서 다른 픽셀은 5개다(가장자리 안티에일리어싱).

예제: `C:\dev\eastwar_art_local\props_example\`

- 나무 18그루는 숲 칸에 있고, 바위는 3개다.
- `--trees off`로 찍은 캡처는 `C:\dev\eastwar_art_local\captures\props_example\battle3d_camB_1920x1080_border_on_paint_notrees_props.png`와 `..._border_off_...`다.
- 나무와 바위가 서 있고, 그림자가 바닥에 깔린 것을 확인했다. 밑동 수정 뒤에 다시 찍었다.
- 예제 바위(`rock_a.png`)는 음영 없는 회색 타원이라 멀리서는 납작한 원판처럼 보인다. 서 있는 그림이 맞고, 오른쪽으로 엔진 그림자가 생긴다.
- 실제 판정은 록비서 그림(107 시안)으로 12호 비교 때 한다.

## 4. 검사

- `[BATTLE3D_CAPTURE] checks=40 failures=[]`
- 로컬 전체: 221/221 통과, 검증기 73/73 PASS(`7510304` 기준). 밑동 수정 `4f92f0d`은 캡처 도구와 그 시험만 바꿨다.
- CI C-track: **46153488124 4/4 초록** (`4f92f0d`)

그림 원본, 가이드, 예제 그림은 저장소 밖에만 있다. 공개 저장소에는 올리지 않았다.
