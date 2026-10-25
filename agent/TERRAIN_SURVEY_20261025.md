# 3D 전장 지형 조사 (2026-10-25)

- 브랜치: `feature/terrain-survey-20261025` (base `3f8f83e`)
- 조사만 했다. 코드·씬·에셋 변경 0. Godot 은 실행하지 않았다.
- 합격·불합격 판정은 하지 않는다.
- 표기: [사실] = 코드 파일:줄, 내가 돌린 명령, 공식 문서 URL. [추정] = 그 밖의 모든 것.
- 조사에서 돌린 명령: `git status`, `grep`, `python -I`로 `heightfield.json`과 `.glb`의 JSON 청크(glTF 헤더)를 읽었다. 렌더링 측정은 정리하는 쪽(조정자)이 `measure.gd`로 1회 했다("측정 (1회)" 절).
- 부속 표: `agent/data/TERRAIN_SURVEY_TREES_20261025.csv` (나무 17그루 위치·크기·화면 픽셀).

## 핵심

1. 지금 3D 전장은 Blender 에서 뽑은 `battlefield.glb` 한 개다. 노드 55개, 텍스처 0장, 단색 머티리얼 7개다. [사실] (glb JSON 청크)
2. 나무는 원뿔 2개 + 원기둥 1개짜리 소나무 17그루(MeshInstance3D 51개, 그루당 64삼각형)다. 풀·바위·길은 없다. [사실]
3. 카메라는 직교(orthogonal) 투영이다. size 60(줌 20~70), 초점에서 (43·sin0.32, 40, 43·cos0.32) m 떨어진 곳, 내려다보는 각 약 42.9°다. [사실] `lab_presentation.gd:10,50,212,252`
4. 1920×1080 기본 줌에서 1m = 18px 이다. 중간 크기 나무(높이 2.6m, 폭 1.4m)는 폭 약 25px, 높이 약 35~52px 이다. 한 칸(3m)은 가로 54px 이다. [사실 계산]
5. 풀 한 포기(0.3m 가정)는 기본 줌에서 약 5px 이다. 하나하나 읽히기 어렵다. [추정]
6. 2D 엔진에는 지형 규칙이 없다. 3D 의 강·숲·언덕은 그림일 뿐이다. 기본 배치에서 유닛 2개가 나무와 같은 칸에 선다. [사실] grep, 골든 칸
7. 권하는 순서: 측정 1회 → 나무 1그루를 3가지 방식으로 나란히 → 풀 한 구역 → 강 한 구간. 미술 방향과 에셋 제작은 김작·채코치가 정한다. [추정]

## 1. 현재 상태

### 1.1 장면이 만들어지는 길

| 단계 | 내용 | 근거 |
|---|---|---|
| 셸 | `Battle3D_ScenarioShell.tscn` 은 스크립트만 붙은 Node 하나 | [사실] `scenes/battle3d/Battle3D_ScenarioShell.tscn:1-6` |
| 랩 생성 | `start_scenario()` 가 `Battle3D_EnginePlayLab.tscn` 을 instantiate | [사실] `battle3d_scenario_shell.gd:9,118-120,129-140` |
| 랩 씬 | 스크립트만 붙은 Node3D 하나 | [사실] `scenes/battle3d/Battle3D_EnginePlayLab.tscn:1-6` |
| 상속 | `battle3d_engine_play.gd` 는 `lab_presentation.gd` 를 상속 | [사실] `battle3d_engine_play.gd:1` |
| 지형 로드 | `battlefield.glb` 를 instantiate 해서 add_child | [사실] `lab_presentation.gd:30-31` |
| 충돌 | 이름이 `Terrain`, `Ford` 인 메시만 trimesh 충돌 생성, 그림자 끔 | [사실] `lab_presentation.gd:72-77` |
| 환경 | 배경 단색 `18232e`, 주변광 단색, 톤맵 Linear, 하늘 없음 | [사실] `lab_presentation.gd:33-41` |
| 해 | DirectionalLight3D, 회전 (-55,-30,0), 그림자 켬, 그림자 거리 100 | [사실] `lab_presentation.gd:42-49` |
| 격자선 | ImmediateMesh 선 19+11 = 30개, 지형 높이 +0.05 | [사실] `lab_presentation.gd:154-162` |
| 2D 엔진 | `Battle_Main.tscn` 을 SubViewport(1280×720, 렌더 갱신 꺼짐) 안에 띄움 | [사실] `battle3d_engine_host.gd:5-14` |
| 렌더러 | Forward Plus, Windows 는 d3d12 | [사실] `project.godot:15,35` |

- 랩 로그 문자열에 `"renderer":"gl_compatibility"` 라고 적혀 있다. 실제 설정(Forward Plus)과 다르다. 문자열일 뿐이다. [사실] `lab_presentation.gd:62`

### 1.2 높이맵 `assets/battle3d/heightfield.json`

| 항목 | 값 | 근거 |
|---|---|---|
| board | width 18, height 10, cell_size 3.0, sample_step 0.5, river_center 28.0, ford_row 5 | [사실] python 으로 읽음 |
| 샘플 | 109 × 61 (nx × nz), step 0.5m → 54 × 30 m | [사실] python |
| 높이 범위 | -0.32 ~ 4.36 m. 가장 높은 곳은 (x 9, z 5) | [사실] python |
| 읽는 곳 | `lab_heightfield.gd:11` 에서 JSON 을 통째로 파싱 | [사실] |
| 높이 계산 | 0.5m 격자 삼각형 2개로 선형 보간 | [사실] `lab_heightfield.gd:30-46` |
| 여울 | 여울 행 근처는 높이를 최소 0.14 로 올림 ("Blender 가 뽑은 여울 상판") | [사실] `lab_heightfield.gd:47-49` |
| 칸 종류 | 강: 강 중심선(`28 + 1.4·sin(z·0.25)`)에서 2.6m 안. 숲: `x<6 and z>11` 또는 `x>42 and z<9`. 언덕: 높이 >1.5. 나머지 평지 | [사실] `lab_heightfield.gd:52-58` |

`terrain()` 규칙으로 180칸을 분류한 결과다. [사실] python 으로 같은 식을 계산함. (`.` 평지, `H` 언덕, `T` 숲, `R` 강, `F` 여울)

```
y\x 012345678901234567
0   .HHHH....R....TTTT
1   HHHHHH...RR...TTTT
2   .HHHH....RR...TTTT
3   ..HH.....R........
4   TT......RR........
5   TT......FF........
6   TT......RR........
7   TT......RR...HHH..
8   TT.......R...HHH..
9   TT.......RR..HHH..
```

- 평지 114, 언덕 25, 숲 24, 강 15, 여울 2칸. [사실]
- 이 분류는 3D 랩의 hover 글자와 데모 이동(`lab_demo_port.gd:25,34`)에만 쓰인다. 엔진 이동에는 쓰이지 않는다(5장). [사실]

### 1.3 `battlefield.glb` 내용

glTF JSON 청크를 python 으로 읽었다. 생성기 "Khronos glTF Blender I/O v5.2.40". [사실]

| 노드 | 개수 | 삼각형(각) | 머티리얼 | 크기 |
|---|---|---|---|---|
| Terrain | 1 (서피스 3개) | 12,960 | Meadow·sage, Highland·moss, Riverbank·ochre | 0~54 × 0~30 m, 높이 -0.32~4.36 |
| Earth cutaway (판 옆면) | 1 | 672 | Exposed earth | 54 × 30, 높이 -1.3~1.85 |
| River | 1 | 240 | River·jade (metallic 0.22, roughness 0.26) | x 25.05~30.95, 높이 0.02 평면 |
| Ford | 1 (Cube, 스케일 4.4×0.14×2.1) | 12 | Riverbank·ochre | (26.83, 0.07, 16.5) |
| Pine trunk | 17 | 32 | Bark | 반지름 0.09~0.14 |
| Pine lower | 17 | 16 | Pine canopy | 폭 1.1~1.8 |
| Pine crown | 17 | 16 | Pine canopy | 폭 0.8~1.3 |
| **합계** | **55** | **15,972** | **7** | |

- 이미지·텍스처 0개. 모든 머티리얼은 단색 `baseColorFactor` 다. [사실]
- 메시 55개가 모두 따로 있다. 인스턴싱(같은 메시 공유) 없음. [사실] (mesh usage 모두 1)
- import 설정에 `generate_lods=true`, `create_shadow_meshes=true`. [사실] `battlefield.glb.import:25-26`
- 나무 그림자는 꺼지지 않는다. 그림자를 끄는 것은 Terrain·Ford 뿐이다. [사실] `lab_presentation.gd:73-75`
- 나무 17그루 위치·크기는 `agent/data/TERRAIN_SURVEY_TREES_20261025.csv` 에 있다. 높이 2.05~3.41m(평균 2.65), 폭 1.11~1.84m(평균 1.43). [사실]
- 나무는 왼쪽 숲 10그루, 오른쪽 위 숲 7그루다. 나무 15(셀 (0,3))는 숲 규칙 칸 밖에 있다. [사실] csv + 1.2 표
- 풀, 바위, 길, 덤불, 건물은 코드에도 glb 에도 없다. `MultiMeshInstance3D` 도 쓰지 않는다. [사실] `grep -rln MultiMesh scripts scenes` 결과 0건

### 1.4 유닛과 그 밖의 3D 요소

| 요소 | 만드는 곳 | 개수 |
|---|---|---|
| 유닛 루트 Node3D | `lab_presentation.gd:97-100` | 엔진 유닛 수만큼 [사실] |
| 병사 모델 | 유닛마다 glb 6개 (`%s_%s.glb`, 2행×3열) | [사실] `lab_presentation.gd:104-110` |
| 병사 종류 | infantry·cavalry 외 종류는 infantry 모델 | [사실] `battle3d_engine_play.gd:200` |
| 받침 원판 | CylinderMesh 48분할 | [사실] `lab_presentation.gd:85-94,111-113` |
| 이름표 | Label3D billboard | [사실] `lab_presentation.gd:114-121` |
| 클릭 상자 | StaticBody3D + BoxShape3D 2.4m, 충돌층 2 | [사실] `lab_presentation.gd:122-131` |
| 행동 배지 | Label3D, 유닛마다 1개 | [사실] `battle3d_engine_play.gd:202-208` |
| 선택 링 2개 | 원판 | [사실] `lab_presentation.gd:57`, `battle3d_engine_play.gd` _ready |

병사 glb 내용. [사실] python 으로 glb 읽음.

| 파일 | 노드 | 메시 | 삼각형 | 대략 크기 |
|---|---|---|---|---|
| ally/enemy_infantry.glb | 8 | 8 | 228 | 폭 1.9, 높이 약 2.0 m [추정: 노드 이동값만 더한 근사] |
| ally/enemy_cavalry.glb | 14 | 14 | 476 | 폭 1.9, 높이 약 2.7 m [추정: 같은 근사] |

### 1.5 정적으로 센 개수

기본 배치는 10유닛이다(아군 5, 적 5). cavalry 2(guan_yu, xiahou_dun), 나머지 8은 infantry 모델이다. [사실] `tests/golden/battle3d_m3_start_v0.json` layouts/default, `battle3d_engine_play.gd:200`

| 묶음 | 노드 | MeshInstance3D | 삼각형(LOD0) |
|---|---|---|---|
| battlefield.glb | 56 (루트 포함) + 충돌체 4 | 55 | 15,972 |
| 병사 (infantry 8유닛 × 6) | 48 × 9 = 432 | 384 | 10,944 |
| 병사 (cavalry 2유닛 × 6) | 12 × 15 = 180 | 168 | 5,712 |
| 유닛 루트·원판·Label·클릭 | 10 × 5 = 50 | 10 | 원판 (CylinderMesh 48분할, 수백 각 [추정]) |
| 격자선 | 30 | 30 | 선(삼각형 아님) |
| **3D 소계** | **약 750** [추정] | **약 597** [추정] | **약 34,500** [추정] |

- 병사 수는 병력 비율로 0~6명이 보인다. 보이는 수는 런타임에 바뀐다. [사실] `battle3d_engine_play.gd:736-738`
- 증원 유닛은 도착 전에는 숨는다. 실제 그리는 수는 이보다 적다. [추정]
- 2D 엔진 씬(SubViewport 안), HUD 노드는 위 표에 넣지 않았다. 측정에서 전체 노드는 2,065개였다("측정 (1회)" 절). [사실]
- **나무 51개 메시는 3D 메시 약 600개 중 약 9% 다.** 그리기 비용은 병사 쪽이 더 크다. [추정]

## 2. 전투 카메라 숫자

| 항목 | 값 | 근거 |
|---|---|---|
| 투영 | 직교 `PROJECTION_ORTHOGONAL` | [사실] `lab_presentation.gd:50` |
| FOV | 직교라서 쓰지 않음 (기본값 75 는 원근 전용) | [사실] https://docs.godotengine.org/en/4.6/classes/class_camera3d.html |
| size 기본 | 60 | [사실] `lab_presentation.gd:10,211` |
| 줌 범위 | 휠 한 칸 ±3, 20~70 | [사실] `lab_presentation.gd:252` |
| HOME | 초점 판 중앙 (27, 0, 15), yaw 0.32, zoom 60 | [사실] `lab_presentation.gd:8-10,269-272` |
| 위치 | focus + (sin(yaw)·43, 40, cos(yaw)·43) 후 `look_at(focus)` | [사실] `lab_presentation.gd:212-213` |
| 거리 | √(43² + 40²) = 58.73 m | [사실 계산] |
| 내려다보는 각 | atan(40/43) = 42.93° | [사실 계산] |
| 방위(yaw) | 0.32 rad = 18.3°. Q/E 와 가운데 버튼 드래그로 돌림 | [사실] `lab_presentation.gd:9,262,275` |
| far | 200 | [사실] `lab_presentation.gd:51` |
| keep_aspect | 코드에서 안 바꿈 → 기본 KEEP_HEIGHT | [사실] grep, 문서 위 URL |
| 엔진 플레이 랩 | 카메라 값을 바꾸지 않고 `make_current()` 만 함 | [사실] `battle3d_engine_play.gd:214`, grep |

Godot 4.6 문서: size 는 "keep_aspect 에 따라 너비 또는 높이의 지름(미터)" 이다. 기본 keep_aspect 는 KEEP_HEIGHT 다. [사실] 위 URL

### 2.1 나무 한 그루는 몇 픽셀인가

식. [사실 계산]

- 1m 당 픽셀 `ppm = 화면 높이 / size = 1080 / size`
- 직교라서 거리와 상관없이 같은 크기다.
- 화면 가로 폭 = 나무 폭 W × ppm
- 화면 세로 = 서 있는 높이 H 는 cos(θ) 배로 줄고, 땅 위 깊이는 sin(θ) 배로 보인다(θ = 42.93°).
  - 최소 `H·cosθ·ppm` (줄기~꼭대기만)
  - 최대 `(H·cosθ + W·sinθ)·ppm` (아래 가지의 앞뒤 폭까지)

입력: 나무 높이·폭은 glb 노드 이동값 + accessor min/max 로 구했다. [사실] csv

| 줌(size) | ppm | 작은 나무 (H 2.05, W 1.11) | 중간 나무 (H 2.62, W 1.42) | 큰 나무 (H 3.41, W 1.84) |
|---|---|---|---|---|
| 20 (최대 확대) | 54.0 | 폭 60px, 높이 81~122px | 폭 77px, 높이 104~156px | 폭 99px, 높이 135~202px |
| **60 (기본)** | **18.0** | **폭 20px, 높이 27~41px** | **폭 25px, 높이 35~52px** | **폭 33px, 높이 45~67px** |
| 70 (최대 축소) | 15.4 | 폭 17px, 높이 23~35px | 폭 22px, 높이 30~45px | 폭 28px, 높이 39~58px |

같은 식으로 본 다른 크기. [사실 계산]

| 대상 | 기본 줌(18px/m) |
|---|---|
| 한 칸 3m | 가로 54px, 화면 깊이 3·sinθ·18 = 37px |
| 판 전체 54×30m | 가로 약 972px (yaw 0 기준), 세로 약 368px + 높이 |
| 화면이 덮는 땅 | 가로 106.7m, 깊이 60/sinθ = 88.1m |
| 병사 1명 높이 약 2.0m | 약 26~36px [추정: 병사 크기가 근사값] |
| 풀 한 포기 0.3m | 약 5px [추정: 풀 크기는 가정] |
| 바닥 텍스처 1m 에 필요한 해상도 | 기본 18 texel/m, 최대 확대 54 texel/m (화면 1px = 1texel 기준) [추정] |

- 기본 줌에서 판 전체가 화면 안에 넉넉히 들어간다. [추정: yaw·높이를 단순화한 계산]
- 나무는 기본 줌에서 병사와 비슷한 크기(25~35px)다. 나무가 유닛을 가리는지가 큰 비교 항목이 된다. [추정]

## 3. 방법 비교 (Godot 4.6)

공식 문서에서 확인한 사실만 [사실] 로 적었다. 품질·성능·난이도는 모두 [추정] 이다. "우리 카메라"는 직교, 42.9°, 기본 18px/m 를 말한다.

### 3.0 확인한 문서

| 내용 | 근거 |
|---|---|
| MultiMesh 는 많은 물체를 한 번의 draw call 로 그린다. 인스턴스별 시야 컬링은 안 되고 통째로 그리거나 안 그린다. 넓으면 여러 MultiMesh 로 나누라고 한다 | [사실] https://docs.godotengine.org/en/4.6/tutorials/performance/using_multimesh.html |
| 빌보드 모드: Enabled, Y-Billboard, Particle | [사실] https://docs.godotengine.org/en/4.6/tutorials/3d/standard_material_3d.html |
| Alpha Scissor 는 Alpha blend 보다 빠르고 정렬 문제가 없다. 그림자를 드리운다. 잎·울타리에 맞다 | [사실] 같은 URL |
| Triplanar 매핑: UV 대신 X·Y·Z 세 방향 투영을 노멀로 섞는다. World Triplanar 가능 | [사실] 같은 URL |
| Visibility range(HLOD): 노드마다 시작·끝 거리, 페이드, Visibility Parent | [사실] https://docs.godotengine.org/en/4.6/tutorials/3d/visibility_ranges.html |
| 셰이더로 PlaneMesh 정점을 높이맵(노이즈 텍스처)만큼 올리는 지형 예제 | [사실] https://docs.godotengine.org/en/4.6/tutorials/shaders/your_first_shader/your_first_3d_shader.html |

- 직교 카메라는 거리에 따라 크기가 안 바뀐다. 거리 기반 LOD·visibility range 의 이득이 원근보다 작다. [추정]
- 판이 54×30m 로 작고 거의 다 화면에 있다. 시야 컬링 이득도 작다. [추정]

### 3.1 나무

| 방법 | 우리 카메라에서 품질 | 성능 | 제작 난이도 | 필요한 에셋 |
|---|---|---|---|---|
| A. 교차 카드(quad 2~3장 십자, Alpha Scissor) | 기본 줌 25px 에서는 그림 품질이 그대로 보여 좋을 수 있다. 42.9° 위에서 보면 카드가 얇게 보이거나 십자 모양이 드러날 수 있다. Q/E 로 돌리면 더 보인다 | 그루당 4~6 삼각형. 매우 가볍다. Alpha Scissor 는 blend 보다 빠르다(문서) | 낮음~중간. 잎 그림의 알파 경계가 품질을 좌우 | 투명 배경 나무 그림 1~3장(512² 안팎), 위에서 본 각도용 그림이 따로 필요할 수 있음 |
| A'. Y-Billboard 카드 1장 | 항상 카메라를 본다. 42.9° 에서 바닥에 붙은 느낌이 약하고 납작해 보일 수 있다 | 가장 가벼움 | 낮음 | 위 그림 1장 |
| B. 로우폴리 모델 (지금 원뿔 64각 또는 손으로 200~800각) | 18px/m 에서 실루엣이 깔끔하다. 돌려도 모양이 맞다. 지금 원뿔은 "장난감" 느낌 | 그루당 수백 각 × 17그루 = 수천~1만 각. 병사(약 1.7만 각)와 비슷한 규모 | 중간. 스타일 통일이 관건 | 모델 1~5종, 텍스처 또는 버텍스 컬러 |
| C. 이미지→3D 생성 모델 후 감축(decimate) | 생성 결과에 따라 다르다. 25px 에서는 세부가 거의 안 보여 감축 손실이 잘 안 드러날 수 있다. 잎이 덩어리로 뭉개질 수 있다 | 감축 후 1~5천 각 목표면 17그루 1.7만~8.5만 각. 텍스처 메모리 늘어남 | 중간~높음. 생성·정리·UV·감축·스타일 맞춤 반복 | 원본 이미지, 생성 도구, Blender 정리 시간, 라이선스 확인 |

- 공통: 같은 메시를 공유(인스턴싱)하면 지금처럼 메시 55개를 따로 두는 것보다 낫다. [추정]
- 공통: 나무 그림자가 켜져 있다(1.3). 카드 방식은 그림자 모양도 같이 봐야 한다. [사실] + [추정]

### 3.2 풀

| 방법 | 우리 카메라에서 품질 | 성능 | 제작 난이도 | 필요한 에셋 |
|---|---|---|---|---|
| A. 바닥 타일 텍스처만 (지금 단색 → 풀 텍스처) | 풀 한 포기가 5px 라 대부분 텍스처로 충분할 수 있다. 확대(54px/m)에서는 평평해 보인다 | 거의 0. 텍스처 메모리만 | 낮음. 반복 무늬(타일링) 티를 감추는 것이 일 | 이음매 없는 풀·흙 텍스처 1~3장(1024² 안팎) |
| B. A + `MultiMeshInstance3D` 풀 카드 | 확대할 때 입체감. 기본 줌에서는 점 노이즈처럼 보일 수 있다. 유닛 발을 가릴 수 있다 | 문서상 한 번의 draw call. 통째로 그려지므로 판을 몇 구역으로 나누면 됨(문서). 수천~수만 장 × 2각 [추정] | 중간. 칸·강·길 위에는 안 나도록 배치 규칙 필요 | 풀 카드 그림 1~4장, 배치 스크립트 또는 툴 |
| C. A + 셰이더 색 변화(노이즈로 밝기·색 얼룩) | 단색보다 자연스러움. 타일 반복 티를 줄임 | 픽셀 셰이더 비용 조금 | 중간 | 노이즈 텍스처(엔진 내 생성 가능) |

### 3.3 흙길·강·산

| 방법 | 우리 카메라에서 품질 | 성능 | 제작 난이도 | 필요한 에셋 |
|---|---|---|---|---|
| A. 텍스처 스플랫(splat) 섞기: 마스크 텍스처 RGBA 로 풀·흙·바위·강변을 섞는 셰이더 | 경계가 부드럽다. 길·강변을 그림처럼 그릴 수 있다 | 셰이더 1개, 텍스처 4~5장 | 중간. 마스크를 그릴 도구가 필요(Blender 페인트 또는 코드 생성) | 지면 텍스처 3~4종, 마스크 1장(54×30m 를 0.5m 단위면 108×60 이상) |
| B. 지금처럼 Blender 에서 머티리얼별 서피스로 나눔 (Terrain 3서피스) | 경계가 삼각형 모양으로 딱딱하다. 단색이면 더 그렇다 | 가장 단순 | 낮음. 이미 쓰는 방식 | Blender 원본(.blend) — 저장소에 있는지 못 찾음 |
| C. 강을 별도 메시 + 물 셰이더 (흐르는 노멀맵, 깊이 색) | 지금 평면 0.02m 보다 물처럼 보임. 위에서 42.9° 라 반사보다 색·흐름이 중요 [추정] | 투명 1장. 정렬 비용 작음 | 중간 | 노멀맵 1~2장, 셰이더 |
| D. 산·언덕: 높이맵 메시 그대로 + Triplanar 바위 텍스처(문서) | 경사면 텍스처 늘어짐을 줄임 | 샘플 3배 | 낮음~중간 | 바위 텍스처 1장 |
| E. 판 밖 배경 산: 별도 메시 또는 그림 카드 | 판 가장자리 단색 배경(`18232e`)을 메움 | 작음 | 중간 | 산 모델 또는 그림 |

### 3.4 지형 애드온

| 애드온 | 확인한 사실 | 우리에게 맞는가 |
|---|---|---|
| Terrain3D (TokisanGames) | MIT 라이선스. C++ GDExtension. [사실] https://github.com/TokisanGames/Terrain3D . v1.0.2-stable 릴리스 노트에 "Supports Godot 4.4-4.7", 4.6 지원 추가, compatibility 모드 셰이더 수정이 적혀 있다. v1.1.0-rc1 은 "Supports Godot 4.5-4.8+". [사실] https://github.com/TokisanGames/Terrain3D/releases (릴리스 날짜의 연도는 페이지에 없었다) | 넓은 지형용이다. 54×30m 판에는 기능이 크다. 높이를 `heightfield.json` 과 맞추는 다리가 필요하다. 클릭 충돌은 지금 `Terrain` 이름 메시를 찾는다(5장) [추정] |
| HTerrain (Zylann, godot_heightmap_plugin) | MIT 라이선스. 전부 GDScript. 현재 버전은 "Godot 4.6+" 대상. 작가가 "active" 개발이 아니고 버그 수정만 한다고 적음. [사실] https://github.com/Zylann/godot_heightmap_plugin , https://raw.githubusercontent.com/Zylann/godot_heightmap_plugin/master/LICENSE.md | 스플랫·풀 기능이 있다고 알려져 있으나 이번에 문서로 확인하지 않았다 [추정]. 같은 다리 문제 [추정] |
| 애드온 없음 (지금 glb + 셰이더) | — | 판이 작고 높이 원천이 이미 있다. 셰이더·MultiMesh 만으로 3.1~3.3 을 시험할 수 있다 [추정] |

## 4. 시험 설계 (단계별)

**미술 방향과 에셋 제작은 김작(소유자)과 채코치(아트 코치)가 정한다.** 아래는 비교 틀만 정한다. 어느 방식을 고를지는 적지 않는다.

공통 조건 [추정]:

- 기존 씬·스크립트는 건드리지 않는다. 새 시험 씬 1개(예: `scenes/battle3d/tests/TerrainLook_*.tscn`)를 따로 만든다.
- 카메라는 `lab_presentation.gd` 와 같은 값: 직교, size 20/60/70, 오프셋 (sin0.32·43, 40, cos0.32·43), yaw 0.32 와 ±0.6.
- 해·환경도 `lab_presentation.gd:33-49` 와 같은 값.
- 병사 glb 1개 유닛(6명)을 옆에 세워 크기를 비교한다.
- 매 단계 1920×1080 스크린샷 + 0단계의 측정 스크립트 값(draw call, 삼각형, 프레임 시간).

| 단계 | 입력 | 비교 항목(기준 아님) | 예상 공수 [추정] |
|---|---|---|---|
| 0. 기준 측정 | 지금 전장 그대로, `measure.gd` 1회 | 프레임 시간, draw call, 삼각형, 노드 수, 스크린샷 | 조정자 실행 30분 |
| 1. 나무 1그루 × 3방식 나란히 | 평지 칸 3개 (예: (6,3), (7,3), (8,3) — 1.2 표에서 평지) 에 A 교차 카드, B 로우폴리, C 생성 후 감축. 높이 약 2.6m 로 맞춤 | 줌 20/60/70 에서 실루엣, 병사와 구분, yaw 돌릴 때 모양, 그림자 모양, 가장자리 계단(앨리어싱)·깜빡임, 그루당 삼각형·draw call, 만드는 데 든 시간 | 시험 씬 0.5일 + 에셋 1그루당 0.5~2일 (C 가 가장 김) |
| 2. 풀 한 구역 | 3×3 칸(9×9m). A 타일 텍스처, B A+MultiMesh 카드(밀도 2~3단계), C A+노이즈 색 | 기본 줌에서 차이가 보이는지, 확대 때 입체감, 유닛 발·받침 원판 가림, 반복 무늬 티, draw call·프레임 시간 차이 | 1~2일 + 텍스처·카드 그림 |
| 3. 강 한 구간 | 강 칸 3~4칸(예: x 8~9, y 3~5, 여울 포함). A 지금 평면 단색, B 물 셰이더, C 강변 스플랫 + 물 메시 | 강과 여울이 칸 단위로 읽히는지, 강변 경계 모양, 격자선과 겹침, 투명 정렬 문제, 비용 | 1~2일 + 텍스처 |
| 4. (다음) 전장 전체 적용 | 1~3 에서 고른 방식 | 0단계와 같은 측정 | 단계 1~3 결과로 다시 추정 |

- 단계마다 "보기 좋다"는 판단은 김작·채코치가 스크린샷을 보고 한다. 코드 쪽은 숫자와 그림만 낸다. [추정]
- 단계 1 의 C(이미지→3D)는 생성 도구의 라이선스·출처 확인이 먼저다. 김작이 정한다. [추정]

## 5. 18×10 격자 · heightfield · 2D 씬 연결이 주는 제약

| # | 제약 | 근거 | 지형 설계에 주는 뜻 [추정] |
|---|---|---|---|
| K1 | 3D 판 크기의 원천은 `heightfield.json` (18×10, 3m). 엔진 크기 원천은 `Battle_Production.tscn:733-734`. 둘을 비교하는 검사가 없다 | [사실] `agent/N4_GRID_SIZE_AUDIT_20261024.md` 요약, L5 | 지형은 54×30m 고정으로 만든다. 판 크기를 바꾸면 heightfield 와 glb 를 같이 다시 만들어야 한다(감사 L1, L2) |
| K2 | 높이 함수 `height()` 가 유닛 접지, 격자선, 클릭 보정에 모두 쓰인다 | [사실] `lab_presentation.gd:137,161,232`, `battle3d_grid_projection.gd:22-46`(파일 내 줄) | 보이는 지형 메시가 heightfield 와 어긋나면 유닛이 뜨거나 묻힌다. 새 지형은 같은 높이를 쓰거나 heightfield 를 같이 다시 뽑아야 한다 |
| K3 | 클릭은 충돌층 1, 이름이 `Terrain`·`Ford` 인 메시 충돌만 맞힌다. 나무는 클릭에 안 걸린다 | [사실] `battle3d_grid_projection.gd:15-16,48-51`(파일 내 줄), `lab_presentation.gd:72-77` | 지형 메시를 나누거나 이름을 바꾸면 클릭이 깨질 수 있다. 나무·풀·바위는 충돌층 1 에 넣으면 안 된다 |
| K4 | 2D 엔진에는 지형 규칙이 없다. `battle_web_import_test.gd`, `battle_grid_controller.gd`, `scripts/battle/` 서비스에서 `river`/`forest`/`terrain` 을 grep 하면 HUD 파일 하나만 나온다. HUD 지형 칸은 기본값 "평지 / 방어 0% / 이동 0%" | [사실] grep, `battle_current_actor_hud_controller.gd:17-19` | 3D 의 강·숲·언덕은 보기만 다르다. 엔진 이동은 강 칸도 막지 않는다(엔진 플레이 랩은 엔진 질의를 씀, `battle3d_movement_adapter.gd:13-21`). 강을 "못 건너는 물"처럼 그리면 규칙과 그림이 어긋난다 |
| K5 | 기본 배치에서 guan_yu (14,2) 칸에 나무 2그루(칸 중심에서 0.61m, 1.05m), ally_reinforce_02_test_unit (1,7) 칸에 나무 2그루(0.22m, 1.30m) | [사실] 골든 칸 + csv | 유닛 받침 원판 반지름 1.05m(`lab_presentation.gd:111`) 안에 나무가 선다. 나무를 칸 가장자리나 유닛이 서지 않는 칸에 두는 배치 규칙이 필요하다 |
| K6 | 숲 규칙은 미터 상수 (`x<6 and z>11`, `x>W-12 and z<9`) 이고 나무 위치는 glb 에 따로 굳어 있다. 나무 15 는 숲 칸 밖 | [사실] `lab_heightfield.gd:56`, csv | 나무 배치와 칸 종류의 원천이 둘이다. 새 나무 배치는 칸 데이터에서 만들도록 하는 편이 어긋남이 적다 |
| K7 | 2D 전투 배경은 그림 한 장 `battlefield_3200x1800_worldmap_test_01.png` | [사실] `scenes/battle/Battle_Production.tscn:6` | 2D 그림과 3D 지형은 연결이 없다. 같은 전장으로 보이게 할지는 김작이 정한다 |
| K8 | 카메라 기본 줌·범위는 54×30m 판에 맞춘 값 | [사실] 감사 L10, `lab_presentation.gd:10,252` | 판 밖(가장자리 밖 배경)이 화면에 보인다(2.1 표: 화면 106×88m). 판 밖 배경도 설계 대상이다 |
| K9 | 강 중심 28m, 여울 행 5 가 heightfield 의 board 값과 `height()`/`terrain()` 의 식에 들어 있다 | [사실] `lab_heightfield.gd:15-17,48,54` | 강 모양을 바꾸면 JSON 값과 식, glb 강 메시를 같이 바꿔야 한다 |
| K10 | `battle3d_connect_lab.gd:90-91` 은 `range(18)`, `range(10)` 하드코딩 | [사실] | 크기 변경 시 함께 고칠 곳(감사 L8) |

## 측정 (1회)

조정자가 `measure.gd` 를 1회 돌린 뒤 채운다. 실행:

```
godot --path <worktree> --resolution 1920x1080 --script C:\Users\seong\AppData\Local\Temp\claude\C--dev\6eee60ae-acc5-4425-8d33-e3933a95e558\scratchpad\q\c_measure\measure.gd -- --out=<dir>
```

출력: `<dir>/terrain_measure.json`, `<dir>/terrain_measure.png`.

| 항목 | JSON 키 | 값 |
|---|---|---|
| Godot 버전 / 렌더러 / 드라이버 / GPU | godot_version, rendering_method, rendering_driver, video_adapter | 4.6.2-stable / forward_plus / d3d12 / NVIDIA GeForce GTX 1660 |
| 준비까지 프레임 | ready_wait_frames | 2 |
| 프레임 시간 평균 / 최대 / p95 (ms) | frame_ms | 16.68 / 26.98 / 16.79 (300프레임) |
| TIME_PROCESS 평균 / 최대 (ms) | time_process_ms | 22.38 / 33.14 |
| FPS 평균 | fps | 59.8 (최소 59, 최대 60) |
| draw call / 프레임 | draw_calls_in_frame | 798 (300프레임 내내 같음) |
| primitive / 프레임 | primitives_in_frame | 96,936 |
| object / 프레임 | objects_in_frame | 2,550 |
| 비디오·텍스처·버퍼 메모리 | performance_monitors.RENDER_* | 526.6 MB / 171.3 MB / 30.7 MB |
| 전체 노드 수 | scene.nodes, performance_monitors.OBJECT_NODE_COUNT | 2,065 / 2,065 (셸·랩·2D 엔진·HUD 포함) |
| MeshInstance3D 수 (전체 / 보임) | scene.mesh_instance_3d, mesh_instance_3d_visible | 649 / 452 |
| MultiMeshInstance3D 수 | scene.multimesh_instance_3d | 0 |
| 삼각형 (전체 / 보임, LOD0) | scene.triangles_all, triangles_visible | 31,628 / 26,156 (아래 주의 ①: `ImmediateMesh` 42개는 0으로 셈) |
| battlefield.glb 몫 / 병사 몫 | scene.by_source.battlefield_glb, soldier_glb | 땅: 노드 60, 메시 55, 삼각형 14,972 / 병사: 노드 612, 메시 552, 삼각형 16,656(보임 11,184) |
| 카메라 실제값 | camera | 직교, size 60, zoom 60, yaw 0.32, 위치 (40.53, 40.0, 55.82), 회전 (-42.93°, 18.33°, 0), near 0.05, far 200, keep_aspect 1(KEEP_HEIGHT) — §2 계산과 같음 |
| 1.5 정적 추정과 차이 | — | 땅 메시 55는 같음. 땅 삼각형은 실측 14,972 대 정적 15,972(1,000 차이, 원인 미확인 [추정: glb 안 한 메시를 셀 때 차이]). 3D 메시 약 597(정적) 대 실측 649(그 밖 42개는 `ImmediateMesh` 격자·표시선). 삼각형 약 34,500(정적) 대 31,628(실측, ImmediateMesh 제외) |

측정 결과 [사실, 원문 zip `evidence/measure/terrain_measure.json`·`terrain_measure.png`·`run.log`]:
- 1회 실행(2026-10-25, 이 PC, 렌더링 창 1920×1080, [기본 배치] 시작 화면, 120프레임 준비 뒤 300프레임).
- ① 정적 세기 중 `ImmediateMesh`(랩의 격자선·표시선 42개)에서 `surface_get_primitive_type`이 없어 스크립트 오류가 42번 났다. 그 메시는 삼각형 0으로 세어졌다. 프레임 측정값(draw call·primitive·시간)에는 영향이 없다. 측정 스크립트를 고쳐 다시 돌리지는 않았다(지시: Godot 1번).
- ② FPS 60은 수직 동기화 상한으로 보인다 [추정]. 그래서 프레임 시간 16.7ms는 "여유가 있다"는 뜻일 뿐, 한계 성능이 아니다.
- ③ draw call 798·primitive 96,936에는 3D 전장 말고도 랩 안 2D 엔진(`Battle_Main`)의 화면과 HUD가 들어 있다 [추정]. 3D 땅만의 몫은 따로 재지 않았다.

측정 주의 [추정]:

- 삼각형 수는 LOD0 기준이다. import 에 `generate_lods=true` 라 실제 그린 수(primitives_in_frame)와 다를 수 있다.
- 프레임 시간은 창 모드·수직동기에 묶일 수 있다. 다른 작업이 Godot 을 쓰는 중이면 값이 흔들린다.
- 랩이 `_ready` 에서 `res://../EASTWAR_C0C3_Evidence/runtime_events.jsonl` 을 연다(`lab_presentation.gd:27`). 폴더가 있으면 그 파일을 덮어쓴다. [사실] 코드

## 김작이 정할 것

1. 미술 방향: 사실풍 / 손그림풍 / 로우폴리풍. 채코치와 함께.
2. 나무 방식(A 카드, B 로우폴리, C 생성 후 감축) 중 무엇을 시험할지, 에셋을 누가 만들지.
3. 이미지→3D 생성 도구를 쓸지, 쓴다면 출처·라이선스 기준.
4. 강·숲·언덕을 규칙(이동·방어)으로 만들지, 그림으로만 둘지 (K4). 규칙이면 2D 엔진 작업이다.
5. 나무가 유닛 칸에 들어와도 되는지 (K5).
6. 2D 배경 그림과 3D 지형을 같은 전장으로 맞출지 (K7).
7. 판 크기 18×10 을 유지할지 (K1). 바뀌면 지형을 다시 만든다.
8. 지형 애드온을 들일지, 지금 glb + 셰이더로 갈지.
9. 판 밖 배경(산·하늘)을 그릴지 (K8).

## 못 한 것

- 조사 중에는 Godot를 돌리지 않았다. 렌더링 측정은 `measure.gd`로 **1회만** 했다("측정 (1회)" 절). 그 실행에서 정적 삼각형 세기가 `ImmediateMesh` 42개를 0으로 셌고, 고쳐서 다시 재지는 않았다. 3D 땅만의 draw call 몫은 따로 재지 못했다.
- `RenderingServer.frame_post_draw` 시그널은 4.6 문서 페이지가 너무 길어 문서로 확인하지 못했다. 같은 시그널을 이 저장소가 이미 쓴다(`lab_presentation.gd:329`). [사실]
- 병사 glb 의 정확한 높이: 노드 이동값만 더한 근사다. 회전·스케일·중첩 변환은 반영하지 않았다.
- Blender 원본(.blend)과 heightfield 를 뽑은 스크립트가 저장소에 있는지 찾지 못했다(이번에 찾아보지 않았다).
- Terrain3D 의 Forward Plus·D3D12 실제 동작, HTerrain 의 4.6 실제 동작은 확인하지 않았다. 릴리스 노트 글만 읽었다.
- Terrain3D 릴리스 날짜의 연도: 페이지에 없어 확인 못 했다.
- 3.1~3.3 표의 품질·성능·난이도는 모두 실측 없는 추정이다.
- 2D 배경 그림에 지형이 그려져 있는지 보지 않았다(감사 문서도 못 봤다고 적음).
- 엔진에서 유닛이 실제로 강 칸에 멈출 수 있는지 실행으로 확인하지 않았다(K4 는 grep 근거).
