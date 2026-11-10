기준 화면: 새 장면 `scenes/battle3d/Battle3D_NavalHansando.tscn` (F6) — 기존 3D 전투 셸(`Battle3D_ScenarioShell`)을 수전 설정으로 연 것. 육전 `Battle3D_ScenarioShell.tscn`의 동작은 그대로여야 한다.
합격 기준: 김작이 위 장면을 F6로 열어 바다 전장(섬 포함)에서 거북선·판옥선 vs 왜 전투함을 **육전과 같은 조작으로 이동·공격**하고(배 종류마다 이동 거리 다름, 화포·화살·총 연출), 배마다 장수 얼굴 칩·병력 바가 보이고, 이순신 특기 "학익진"을 쓸 수 있고, F9로 캡처가 저장되면 합격. 육전 F6는 이전과 같아야 한다.

# 큐 35 — NAVAL-HANSANDO: 한산도 대첩 수전 시나리오 (3D 전장 재사용)

작성: 클코치 / 2026-11-10 19:40 (19:24판을 **대체**. 19:24판은 대본 재생 방식이었음 — 김작 19:26 정정: "이동은 육전과 같은 시스템, 배마다 이동 거리 다름, 무기는 화포·화살·총(화살·총은 육전 것 재사용), 육전 3D 테스트의 강을 전 전장에 적용하고 주변에 섬")
김작 승인: 11-10 19:22·19:26. 배 모델 = 록비서 신규(없으면 임시 모델), 왜군 장수 = 기존 일본 장수, 마감 = 이번 주 안(사업계획서 해상 전투 캡처).

## 0. 왜 하나
모두의 창업 2라운드 사업계획서에 넣을 **해상 전투 캡처**(멘토 숙제). 육전 3D 전장의 엔진·HUD·AI를 그대로 쓰고, **땅·병종·연출만 바다용으로 바꾼 시나리오**를 하나 추가한다. 월드맵 연결은 범위 밖.

## 1. 가지와 금지
- 새 가지 `feature/wm3d-naval-20261110` (`main` `8cc0640`에서). 푸시는 이 가지만. `main` 합류 없음.
- **`scripts/worldmap/worldmap_main.gd` 0줄** (바이트 고정).
- **`data/heroes/generated/*.json`은 수정 금지** (장수 엑셀에서 생성되는 파일. `tools/convert_hero_workbook.py`가 다시 만들면 덮어써지고, `validate_five_unit_type_*` 등 "병종 5개" 전제 검사기 9개가 걸려 있음).
- 기존 파일 수정은 **아래 §3에 적은 자리만, 기본값에서 동작 불변**(수전 설정이 꺼져 있으면 육전과 바이트 단위로 같은 결과). 그 밖의 기존 파일을 바꿔야 하면 멈추고 보고.
- 기존 시험·검사기·골든 **기대값을 바꾸지 않는다**. 전부 그대로 초록.
- 새 `.gd`·`.tscn`은 `.uid`까지 커밋. 푸시의 마지막 커밋은 코드 커밋(`[skip ci]` 금지).
- 임시 파일·캡처 원본은 `C:\eastwar_tmp\naval\` 안에서만.

## 2. 이미 있는 것 [사실, 클코치 `main 8cc0640` 확인]
- 병종 규칙은 데이터: `UnitTypeContract`(`scripts/battle/unit_type_contract.gd`)가 `CANONICAL_UNIT_TYPES` 5개(infantry·cavalry·archer·gunner·mounted_archer) 화이트리스트 + `HeroDesignDataRegistry.get_unit_type_rule()`로 `move_range`·`minimum/maximum_attack_range`·`counterattack_*`·`can_attack_after_move`·`can_move_after_attack`·피해 배율·`ai_behavior_profile`·`visual_key`를 읽는다.
- 이동 막힘: `battle_movement_query_service.gd:63`·`battle_production_controller.gd:149`가 `grid_controller.is_blocked(cell)`로 판정(T1 이동불가칸). → **바다 칸 = 보통 칸, 섬 칸 = 막힌 칸**으로 두면 물 위 이동 규칙을 새로 만들 필요가 없다.
- 3D 땅: `lab_heightfield.gd:17`과 `terrain_board_builder.gd`가 `res://assets/battle3d/heightfield.json`을, 랩이 `terrain_types.json`을 **고정 경로**로 읽는다. 지형 `WATER`(강, 수면 `WATER_SURFACE_Y = -0.12`)와 물 셰이더 `eastwar_terrain_20x20_water.gdshader`가 있다.
- 3D 병사 연출: `battle3d_unit_visuals.gd` `handles()`가 보병·기병·궁병·총병만 받는다. 화살·총 연출은 `battle3d_ranged_fx.gd`의 `fire_arrow_volley(archers, targets)`·`fire_gun_volley(gunners, targets)`(병사 노드 기준).
- 얼굴 칩·병력 바·배지: `battle3d_unit_markers.gd` `show_unit(...)`. HUD는 랩의 `hud_*` 함수를 읽는다.
- 셸은 `LAB_SCENE := "res://scenes/battle3d/Battle3D_EnginePlayLab.tscn"` 고정.
- **이순신 고유 특기 `yi_sun_sin_unique` "학익진"**: "수전 반경 3, 육상 반경 2로 약화"라고 데이터에 적혀 있다. 실제 코드가 수전/육상을 구분하는지 [미확인] → §4 조사 항목.
- 배 모델·배 병종 0건. 한산도 왜군 지휘관 와키자카는 장수 데이터에 없음.

## 3. 만들 것
### 3-1. 수전 설정 스위치 (기존 파일, 최소)
- 셸·랩이 **수전 시나리오 설정**(예: `naval_scenario_path`, 기본 빈 값)을 받으면 아래 경로들을 수전용으로 바꾼다. 빈 값이면 지금과 완전히 같다.
- 새 장면 `scenes/battle3d/Battle3D_NavalHansando.tscn` = 셸 인스턴스 + 그 설정값 `res://data/battle3d/naval_hansando_scenario.json`.
- 허용하는 기존 파일 수정 자리: 셸/랩의 장면·땅 파일 경로를 설정에서 받게 하는 곳, `lab_heightfield.gd`·`terrain_board_builder.gd`의 heightfield 경로, `terrain_types.json` 경로, 병사 연출 선택(배면 배 연출로), `UnitTypeContract`가 수전 규칙 파일을 **추가로** 읽는 자리(§3-3). 이 밖은 멈춤.

### 3-2. 바다 전장
- 새 `assets/battle3d/naval/heightfield_hansando.json`·`terrain_types_hansando.json`: 육전 3D 테스트 가운데 강의 수면·물 셰이더 표현을 **20×20 전 칸**에 적용(전부 `WATER` 모양, 단 엔진상 이동 가능). 판 밖도 바다로 이어져 보이게.
- **섬**: 판 안에 섬 칸 3~5덩어리(총 10~18칸, 막힌 칸) — 북쪽에 좁은 물길(견내량 느낌)을 만드는 섬 2개, 가운데쪽 작은 섬 1~2개, 남쪽 큰 섬 1개(한산도 느낌). 판 밖 가장자리에도 섬·해안 실루엣. 섬 위 나무는 가볍게(기존 숲 군락 무게 주의, 섬당 삼각형 예산 적게).
- 시작 배치에서 **양쪽 모두 상대에게 갈 길이 있어야** 한다(도달 가능성 검사, §5).
- 지명 글자는 화면에 띄우지 않는다. 상단 HUD 제목만 "한산도 대첩".

### 3-3. 배 4종 규칙 (새 파일)
- 새 `data/battle3d/naval_unit_type_rules.json` — `unit_type_rules.json`과 같은 칸 구조. `UnitTypeContract`는 이 파일이 있을 때 4종을 **추가로** 인정한다(기존 5종과 그 값은 그대로, 육전 검사기 영향 0). 다른 방법이 더 안전하면 §4 조사 보고에 제안.
- 기본값 **[클코치 제안 · 김작 미확정, 데이터에서 바꿀 수 있음]**:

| unit_type | 이름 | 이동 | 공격 사거리 | 무기 연출 | 이동 후 공격 | 특징 |
|---|---|---|---|---|---|---|
| `turtle_ship` | 거북선 | 4 | 1~2 | 화포 | O | 받는 피해 −20%(덮개), 근접 돌격 강함 |
| `panokseon` | 판옥선 | 3 | 2~3 | 화포 + 화살 | O | 표준 전열함 |
| `atakebune` | 안택선 | 2 | 1~2 | 조총 + 화살 | O | 받는 피해 −10%, 근접 강함(등선 백병) |
| `sekibune` | 관선 | 4 | 1~2 | 조총 | O | 받는 피해 +10%, 빠름 |

- `ai_behavior_profile`은 기존 프로필 중에서 고른다(새 AI 금지). 판옥선·안택선 = 사격형, 거북선·관선 = 돌격형 근처.
- 시나리오에서 장수의 병종을 배로 **덮어쓰는** 방식(장수 데이터 수정 금지). 엔진이 시나리오 단위 병종 지정을 지원하는지 §4 조사.

### 3-4. 배 연출
- 새 `scripts/battle3d/naval/battle3d_ship_visuals.gd`: 배 GLB(`assets/battle3d/naval/{type}.glb`)가 있으면 쓰고, 없으면 **임시 모델**(코드 생성): 판옥선 넓은 2층 갑판+돛대 / 거북선 낮은 선체+등껍질 덮개+용머리, 돛 없음 / 안택선 큰 선체+누각 / 관선 길고 낮은 선체+돛 1. 아군 푸른 깃발, 적 붉은 깃발. 물 위 흔들림(롤·피치 ±2°, 배마다 위상 다르게).
- 배 길이: 판옥선 4.8 m, 거북선 4.2 m, 안택선 5.4 m, 관선 3.9 m(칸 3 m 기준, 한 칸을 넘어도 겹침 표현 허용).
- 이동: 육전 병사처럼 칸을 따라 미끄러지듯 이동하고 진행 방향으로 선수를 돌린다.
- **무기**:
  - 화포(새): 배 측면 포구 섬광 + 포탄 호 + 착탄 물기둥/피격 연기. 새 `scripts/battle3d/naval/battle3d_cannon_fx.gd`.
  - 화살·총: 기존 `battle3d_ranged_fx.gd` 재사용. 병사 노드 대신 **배 위 빈 노드(사수 자리 3~5개)**를 넘긴다. `ranged_fx`를 고쳐야만 되면 고칠 자리와 이유를 보고(육전 결과 불변 조건).
  - 판옥선은 화포 뒤 화살, 안택선은 조총 뒤 화살 순서로 한 공격에 둘 다.
- 격파: 병력 0이면 기울며 가라앉고 연기(육전 퇴각 연출 대신). 로스터 카드는 육전처럼 퇴각 표시.
- 얼굴 칩·병력 바: `battle3d_unit_markers.gd`를 그대로 쓰고 배 화면 상자를 `geometry`로 넘겨 위치를 맞춘다(상수 수정 금지, 안 맞으면 보고).
- 병종 이름 표시: 거북선/판옥선/안택선/관선. 로스터 병종 아이콘이 없으면 빈칸.

### 3-5. 시나리오 (`data/battle3d/naval_hansando_scenario.json`)
기본 편성 **[클코치 제안 · 김작 미확정]** (기존 44명 안에서만):

| 쪽 | 배 | 장수 | 병력 |
|---|---|---|---|
| 조선 | 판옥선(기함) | 이순신 `yi_sun_sin` | 3000 |
| 조선 | 거북선 | 김덕령 `kim_deok_ryeong` | 2000 |
| 조선 | 판옥선 | 장보고 `jang_bo_go` | 2500 |
| 조선 | 판옥선 | 곽재우 `gwak_jae_u` | 2500 |
| 조선 | 판옥선 | 고경명 `go_gyeong_myeong` | 2500 |
| 왜 | 안택선(기함) | 가토 기요마사 `kato_kiyomasa` | 3500 |
| 왜 | 관선 | 고니시 유키나가 `konishi_yukinaga` | 2500 |
| 왜 | 관선 | 구로다 나가마사 `kuroda_nagamasa` | 2500 |
| 왜 | 관선 | 시마즈 요시히로 `shimazu_yoshihiro` | 2500 |
| 왜 | 관선 | 혼다 타다카츠 `honda_tadakatsu` | 2500 |

- 시작 배치: 왜 함대는 북쪽 물길 안쪽, 조선 함대는 남쪽 넓은 바다에 넓게. 승리 조건·증원은 육전 기본과 같게(증원 없음이 기본, 있으면 보고).

### 3-6. 캡처
- **F9** = 현재 화면(HUD 포함) PNG를 `C:\eastwar_tmp\naval\captures\hansando_{시각}.png`(없으면 `user://captures/`), **Shift+F9** = HUD 숨기고 캡처. 디버그·에디터 실행에서만. 새 노드로 붙인다(셸 수정 최소).

## 4. 조사 먼저 (코드 수정 전, 보고서 첫 절)
아래를 코드로 확인해 표로 적고, **멈춤 조건이 아니면 그대로 구현을 이어간다**:
1. `UnitTypeContract`에 수전 규칙 파일을 추가로 읽게 할 가장 작은 자리, 그리고 5종 전제 검사기(`validate_five_unit_type_*` 등)가 영향받는지.
2. 시나리오 단위로 유닛 병종을 지정할 수 있는지(장수 데이터 수정 없이).
3. 막힌 칸(`is_blocked`)을 시나리오별로 줄 수 있는지(T1 숲 군락이 쓰는 방식).
4. 학익진 특기의 반경이 수전/육상을 실제로 구분하는지, 구분한다면 무엇으로 판단하는지.
5. AI가 새 병종 이름을 받으면 어떤 프로필 경로로 가는지(예외·기본값).
6. 셸이 `LAB_SCENE`·땅 경로를 설정으로 받게 할 최소 변경 자리.
- 멈춤 조건: 1·2·3 중 하나라도 **기존 검사기 기대값을 바꾸거나 §3-1 허용 자리 밖을 고쳐야만** 될 때.

## 5. 시험 (헤드리스, C-track 등록 — 30번 치트 시험 등록 방식 그대로)
`[NAVAL_HANSANDO] checks=N failures=[]`. 최소:
1. 수전 장면 로드, 배 10척(조선 5·왜 5), 대본 hero_id 10개 전부 장수 데이터에 존재(없으면 실패).
2. 배 4종 이동 거리가 규칙 파일 값과 같다(각 종류 1척씩 빈 바다에서 이동 가능 칸 수 확인).
3. 섬 칸으로는 이동 불가, 시작 위치에서 양쪽 모두 상대 쪽으로 도달 가능.
4. 화포·화살·총 공격이 각 배 종류의 무기 연출로 이어진다(연출 호출 기록).
5. 격파 시 침몰 연출 호출, 승패 판정 정상.
6. GLB 없을 때 임시 모델로 대체, 오류 없음.
7. 전투 끝까지 자동 진행해도 멈추지 않는다(이순신 학익진 1회 이상 포함).
8. **수전 설정이 없을 때 육전 결과가 이전과 같다**(기존 골든·동등성 시험 그대로 통과 + 같은 시드 육전 한 판 비교).
9. 기존 C-track 4 shard·WorldMap3D 전부 초록.

## 6. 보고와 증거
- 보고서 `agent/REPORT_NAVAL_HANSANDO_20261110.md`(5줄 종료 루틴). 첫 절 = §4 조사표.
- 바꾼 기존 파일 표(파일·줄·이유·기본값 불변 근거).
- 증거(창 모드 1920×1080 실제 실행) `agent/evidence/naval_hansando/`: ① 전장 전경(섬 포함) ② 함대 이동 범위 표시 ③ 화포 일제 사격 ④ 거북선 근접 돌격 ⑤ 학익진 컷인/토스트 ⑥ 침몰 ⑦ HUD 뺀 전경. 성능: 전투 중 평균 fps(GTX 1660, 측정만).
- [선택] 모바일 가로 비율(2400×1080) 1장. HUD가 깨지면 깨진 그대로 + 보고만.

## 7. 범위 밖
월드맵 해전 지점 연결, 새 장수(와키자카 등) 추가, 장수 데이터·엑셀 수정, 2D 수전, 모바일 HUD 대응, 사운드, 바람·조류 같은 새 규칙.

## 부록 A. 록비서 배 모델 납품 규격 (김작 → 록비서)
- 4종: 거북선 `turtle_ship.glb`, 판옥선 `panokseon.glb`, 안택선 `atakebune.glb`, 관선 `sekibune.glb` → `assets/battle3d/naval/`. 받으면 임시 모델이 자동 교체된다.
- 축: +Y 위, 뱃머리 −Z, 원점 = 배 중심의 **물선 높이**, 단위 m.
- 길이: 판옥선 4.8 m, 거북선 4.2 m, 안택선 5.4 m, 관선 3.9 m(게임 축소값).
- 삼각형: 배당 3,000 이하(10척 동시). 재질 1~2개, 텍스처 1024 이하.
- 빈 노드(있으면 좋음): 포구 `Gun_L1…`·`Gun_R1…`, 사수 자리 `Shooter_1…`, 깃발 `Flag`(색 바꾸기), 돛 `Sail`, 거북선 `DragonHead`.
- 고증: 거북선은 돛 내린 전투 상태, 판옥선은 2층 갑판·노, 안택선은 누각형 상부. 깃발에 실존 가문 문장 금지.
