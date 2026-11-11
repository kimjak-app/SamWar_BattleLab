기준 화면: `scenes/battle3d/Battle3D_NavalHansando.tscn` (F6). 육전 `Battle3D_ScenarioShell.tscn`은 그대로.
합격 기준: 김작이 F6에서 임시 상자 배 대신 **록비서 배 모델 4척(판옥선·거북선·아타케부네·세키부네)**이 물선에 맞게 떠 있고, 멈추면 돛이 접히고 움직이면 돛이 펴지며 노를 젓는 것을 보면 합격. 육전은 그대로.

# 큐 35 답신 3 — 배 모델 연결 (록비서 납품 6척 중 4척)

작성: 클코치 / 2026-11-11 22:10. 가지 `feature/wm3d-naval-20261110`(`3f1e070`) 위에서 잇는다. 김작 22:00 "어제 작업한 3D 배들(거북선 등) 수전 테스트에 올려보자".

## 0. 받은 파일 [사실, 클코치 검증]
- 위치(김작 PC): **`C:\eastwar_tmp\naval\ships\`** (클코치가 넣음). 게임용 GLB 6개 + `EASTWAR_SHIP_클코치_인계가이드_v2.md`(록비서 인계 가이드, **반드시 먼저 읽을 것**) + `SHIP_REPORT_KO.md` + `ship_oar_reference.gd`(참고용).
- sha256 앞 12자리(가이드 §2와 일치 확인함): `panokseon_game_v2` 4144db4aedf5 / `geobukseon_game_v2` ae40107222d5 / `jp_atakebune_game_v1` 0a5ea4b13fa2 / `jp_sekibune_game_v1` 47c30e6417cf / `cn_mengchong_game_v1` 63edba268e13 / `cn_doujian_game_v1` 7aff0405278f. 넣기 전에 다시 계산해 맞는지 본다(다르면 멈춤).
- 클코치 확인: 길이 1.0(Z축), 뱃머리 −Z(거북선 앞 포 `CannonSocket_F2` z −0.458, 1번 노가 −Z 쪽), **원점 = 선체 바닥 중앙**, `WaterLine` 빈 노드 y 0.056~0.076, 노 `Oar_L1~L4`·`Oar_R1~R4`, `MastSocket_n`→`MastFold_n`→`Mast_n`·`Sail_Open_n`·`Sail_Furled_n`(판옥선·거북선 2개, 나머지 1개), 애니메이션 `Oar_Row`(24프레임 루프), `Sail_Furled_n` 기본 scale 0.001, 재질 무광·돛만 `Sail_Mat`, 거북선 `CannonSocket_L1~L5·R1~R5·F1~F3` 13개, 삼각형 약 2,830~3,170, 텍스처 2048² 1장.
- **쓰지 않는 것**: `_lp` 저폴리판(아타케부네 lp 지붕 깨짐), v1 판옥선·거북선(돛 방향 오류, 이번 폴더엔 없음), 70 MB 원본·Tripo raw.

## 1. 넣을 파일
- `assets/battle3d/naval/` 아래에 **원래 이름 그대로** 복사: `panokseon_game_v2.glb`, `geobukseon_game_v2.glb`, `jp_atakebune_game_v1.glb`, `jp_sekibune_game_v1.glb`. (버전 이름 보존. 지금 코드의 `<unit_type>.glb` 고정 이름으로 바꾸지 않는다.)
- 중국 2척(`cn_mengchong_game_v1.glb` 몽충, `cn_doujian_game_v1.glb` 투함)도 같은 폴더에 넣어 둔다. **병종·규칙은 아직 없다**(김작: 중국 배 규칙은 나중). 이번 대본에 안 나온다.
- Godot 가져오기 설정(`.import`)은 기존 3D 병사 GLB와 같은 방식. 텍스처는 VRAM 압축(기본). 커밋 규칙은 기존 병사 GLB 관례를 따른다.

## 2. 연결 (`naval_unit_type_rules.json` + `battle3d_ship_visuals.gd`, 수전 전용 파일)
1. **경로는 규칙 파일에**: 배 4종 항목에 `"model_path": "res://assets/battle3d/naval/<파일>.glb"`를 추가. 연출 코드는 `model_path`가 있으면 그걸, 없으면 지금의 `<unit_type>.glb`를 찾고, 둘 다 없으면 임시 모형(지금처럼).
   - turtle_ship → geobukseon_game_v2.glb / panokseon → panokseon_game_v2.glb / atakebune → jp_atakebune_game_v1.glb / sekibune → jp_sekibune_game_v1.glb
2. **크기 맞춤은 `Hull` 노드로**: 지금 `fit_model`은 노·돛까지 포함한 전체 상자로 길이를 잰다. 모델에 `Hull`이 있으면 **`Hull` 메시 상자의 Z 길이**로 `ship_length`(2.2~2.8 m)에 맞춘다. 옆으로 돌리는 분기(`size.x > size.z`)는 `Hull` 기준으로만 판단(이 6척은 이미 −Z라 돌지 않아야 정상).
3. **물선 맞춤**: 원점이 바닥이므로 모델을 `WaterLine` 노드 높이(배율 적용 후)만큼 **아래로** 내려 `WaterLine`이 바다 수면 높이와 같게 한다. `WaterLine`이 없으면 지금처럼.
4. **돛·노 동작 (김작 확정 규칙, 가이드 §0)**:
   - 멈춤(idle): 돛 접힘 — `Sail_Furled_n` scale 1, `Sail_Open_n` scale 0.001. 노 정지. **시작할 때 GLB 기본값(펼침)을 접힘으로 바꿔 둔다.**
   - 이동 명령으로 움직이는 동안: 돛 펼침(scale 0.001↔1, 0.25초 정도 트윈 허용), `Oar_Row` 애니메이션 재생(루프).
   - 다시 멈추면 돛 접힘, 노 정지.
   - 숨길 때 `visible=false` 말고 **scale 0.001**(가이드: hide는 export 위치 틀어짐 경고). Godot에선 visible도 되지만 가이드와 같게.
5. **돛 색(나라 색)**: 각 배 인스턴스에서 `Sail_Mat` 재질만 복제해 albedo를 바꾼다(다른 배·선체·돛대 영향 없게). 값은 **[클코치 제안, 김작 미확정]** 조선 청 `#2F5D8A` / 일본 적 `#A3402A`(마커 적 색과 같음) / 중국 녹 `#2E7D32`(3D 팔레트 초와 같음). 규칙 파일이나 대본에 숫자로 두어 김작이 바꿀 수 있게. 이번 대본은 조선 = 아군, 일본 = 적이라 진영 색과도 맞는다. 기존 깃발 막대(임시 모형용)는 GLB일 때 그리지 않는다.
6. **포 위치**: 거북선은 `CannonSocket_*`(소켓 로컬 +Y가 바깥)을 화포 섬광·포탄 출발점으로 쓴다. 다른 배는 소켓이 없으니 지금 계산 위치 그대로(선체 폭·높이를 `Hull` 기준으로 다시 계산).
7. 흔들림·침몰·얼굴 칩·병력 바 위치는 지금 로직 그대로. 얼굴 칩이 돛대 위로 너무 높거나 선체에 묻히면 `geometry`로 맞추고 보고.

## 3. 시험·증거
- `[NAVAL_HANSANDO]`에 추가: 배 4종이 GLB로 뜨는지(`model_sources == "glb"`), 맞춘 뒤 `Hull` 길이 = `ship_length`(±1%), `WaterLine` 높이 = 수면(±1 cm), 시작 때 돛 접힘, 이동 중 돛 펼침 + `Oar_Row` 재생, 멈추면 접힘, 돛 색이 배끼리 섞이지 않음(재질 복제), GLB 해시가 0절 값과 같음.
- 기존 시험(임시 모형 경로 포함)은 그대로 통과: GLB가 없을 때 임시 모형 시험은 `model_path`를 비운 설정으로 유지.
- C-track 4 shard 초록. 마지막 커밋은 코드 커밋.
- 증거 `agent/evidence/naval_hansando/ships_*.jpg`: ① 전경(10척) ② 판옥선·거북선 가까이(돛 접힘) ③ 이동 중(돛 펼침·노 젓기) ④ 거북선 화포(소켓 위치) ⑤ 아타케부네·세키부네 가까이 ⑥ 침몰. 성능: 이전 44.1 fps 대비 측정.
- 보고서에 "답신 3" 절 추가(5줄 종료 루틴). 가이드 §9의 남은 문제(새 4척 노 구멍 위치 추정, 거북선 지붕 판자 비뚤어짐 등)가 게임 화면에서 눈에 띄는지 한 줄씩.

## 4. 범위 밖
중국 배 병종·규칙, 저폴리판, 1024 텍스처판, 돛대 눕히기, 수전 피해 2갈래·배 내구(김작 "기억만"), 판 크기.
