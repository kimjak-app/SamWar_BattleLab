기준 화면: `scenes/battle3d/Battle3D_NavalHansando.tscn` (F6). 육전 `Battle3D_ScenarioShell.tscn`의 정보창은 지금과 같아야 한다.
합격 기준: 김작이 수전 F6에서 정보창 오른쪽 끝 지형 칸이 **"바다" 글자 + 바다 그림**으로 나오는 것을 보면 합격. 육전은 "평지"와 평지 그림 그대로.

# 큐 35 답신 4 — 정보창 지형 칸을 칸의 실제 지형으로 (수전 = 바다) + 이순신 병력

작성: 클코치 / 2026-11-11 23:58. 가지 `feature/wm3d-naval-20261110`(`6156bc3`) 위에서 잇는다. 김작 23:24: "평지를 바다로 바꿀 수 있어? 지금은 그림이야. 나중엔 바다면 바다, 서 있는 곳이 평지면 평지 이런 식으로 맞게 표시되게 할 거야."

## 1. 지금 [사실, `6156bc3`]
- `scripts/battle3d/battle3d_current_actor_hud.gd` 17~21행: `ICON_TERRAIN_PLAIN`(`assets/ui/battle/current_actor_icons/terrain_plain.png`), `TERRAIN_NAME := "평지"`, `TERRAIN_DEFENSE := "방어 0%"`, `TERRAIN_MOVE := "이동 0%"` 고정. `_set_terrain()`(197행)이 이 고정 글자를 쓴다. 그림은 146행에서 고정으로 묶는다.
- 3D 판은 칸마다 지형을 안다(`lab_heightfield.gd` 79행 `hill`/`plain`, 수전 판은 `terrain_types_hansando.json`의 바다·섬).

## 2. 할 것
1. **지형 표 파일** 새로 `data/battle3d/terrain_hud_labels.json`: 칸 지형 이름 → `{ "name": 표시 글자, "icon": 그림 경로 }`.
   - `sea` → `"바다"`, `res://assets/ui/battle/current_actor_icons/terrain_sea.png`
   - `plain` → `"평지"`, `terrain_plain.png`
   - `hill` → **`"평지"`, `terrain_plain.png`** (지금 육전 화면을 바꾸지 않기 위해. 언덕 글자·그림은 나중에 김작이 이 줄만 바꾼다)
   - `island` → `"섬"`, `terrain_plain.png` (배는 섬에 못 서므로 보통 안 나옴)
   - 표에 없는 지형 → 지금처럼 `"평지"` + 평지 그림.
2. 정보창이 **현재 행동 유닛이 선 칸의 지형**을 랩에서 읽어 표에서 글자·그림을 고른다. 유닛이 바뀌거나 이동하면 다시 고른다. 방어·이동 %는 **0% 그대로**(엔진에 지형 효과 규칙 없음, 나중 조류 규칙 때 같이).
3. **바다 그림**: 김작 PC `C:\eastwar_tmp\naval\icons\terrain_sea_300.png`(300×300, sha256 앞 12자리 `98619b95e602`, 원본 1024판은 같은 폴더 `terrain_sea.png`)를 `assets/ui/battle/current_actor_icons/terrain_sea.png`로 복사(`.import`는 `terrain_plain.png`와 같은 설정). 클코치가 Higgsfield로 만들고 평지 그림과 테두리 크기·바탕색을 맞춰 확인함.
4. 바꿀 수 있는 기존 파일: `battle3d_current_actor_hud.gd`(고정 → 표 읽기)와, 칸 지형을 넘겨줘야 하면 `battle3d_engine_play.gd`에 읽기 함수 하나. 그 밖은 멈춤.

## 2-2. 이순신 병력 (김작 23:57 "당연 더 쎄야지")
- [사실, `6156bc3`] 장수 교체 때 병력이 배를 따라가서 이순신(거북선) 설계값 2000(화면 80), 김덕령(판옥선) 3000(화면 120)이 됐다.
- 대본 `data/battle3d/naval_hansando_scenario.json`에서 **두 사람의 병력만 맞바꾼다**: 이순신 거북선 `troops_design` 3000(화면 120), 김덕령 판옥선 2000(화면 80). 배 종류·시작 칸은 `6156bc3` 그대로. 이순신이 조선 함대 **기함**이다(대본에 기함 표시가 있으면 이순신 쪽으로).
- 수전 시험에 장수-병력 조합을 보는 항목이 있으면 같이 고친다.

## 3. 시험·증거
- 수전: 배가 선 칸에서 정보창 글자 `"바다"`, 그림 경로 `terrain_sea.png`.
- 육전: 평지 칸·언덕 칸 모두 `"평지"` + 평지 그림(지금과 같음). 기존 정보창 시험 기대값 그대로.
- 표 파일에 없는 지형이면 평지로 떨어지는지.
- C-track: shard 0 육전 컷인 길이 검사(알려진 문제)만 빨가면 멈추지 말고 보고. 그 밖의 실패는 멈춤. 마지막 커밋은 코드 커밋.
- 증거 `agent/evidence/naval_hansando/terrain_sea_hud.jpg`(수전 정보창, 이순신 차례로 찍어 병력 120 / 120이 보이게), `terrain_plain_hud_land.jpg`(육전 정보창). 보고서에 "답신 4" 절.

## 4. 범위 밖
지형별 방어·이동 효과, 언덕·숲 그림, 조류.
