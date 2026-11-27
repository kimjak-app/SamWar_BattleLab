# 큐 39 보고 — 65개 성 + 빈 성(주인 없는 땅) 기본 상태 (CITIES65 0.7)

- 지시서: `agent/ORDER_CITIES65_PREVIEW_20261127.md` (21:25 변경·21:50 추가 포함)
- 가지: `feature/wm3d-cities65-preview-20261127`, 기준 `main` `c643eee`
- 커밋: 코드 `215de31` → 재고정 `7c27f3c`(마지막, `[skip ci]` 없음) → 이 보고서(`[skip ci]`)
- 데이터: orders 가지 `agent/data/cities65_0_7/` 7개 파일, `SHA256SUMS`와 6개 모두 일치(`cities65_source.json` `32b3d368…8d4e`, `regions.json` `a0a763c0…54d1`, `region_ids.png` `c9ae09aa…2478`, `region_dist.png` `b1976f65…2711`, 초안 2개 포함).

## 1. 확인 결과 (지시서 1절)

### 1-1. 성 목록이 정해지는 곳
| 자리 | 방식 | 이번 처리 |
|---|---|---|
| `worldmap_main.gd` `CITY_HUD_DATA` | 13개 고정 상수(한 줄에 성 하나) | 새 52줄 추가, `karakorum` 이름·지역 글자만 수정 |
| `WorldMap.tscn` `CityLayer` 2D 표식 13개 | main `_connect_city_markers`가 자식을 돌며 `_city_markers_by_id`에 등록, 3D 클릭은 `worldmap_3d_adapter.gd`가 이 표식의 `city_selected`를 다시 보냄 | 씬은 그대로(상도 이름 2줄만). 나머지 52개는 코드로 만듦(1-3) |
| `worldmap3d/maps/eastasia/markers.json` · `rule_data_eastasia.json` · `regions.json` + `region_ids.png`·`region_dist.png` | 3D 루트 `_ready`가 읽음. 3D 클릭은 지역 픽셀 → `regions.city_by_index` | 0.7로 교체(2절) |
| AI 대상·승리 판정 | `T03_KOREA_CITY_IDS`(한반도 4성)로 AI 생산·침공 쌍·승리가 묶여 있음 | 그대로 — 빈 성은 들어가지 않음 |

### 1-2. 주인 없는 성(`owner: ""`)을 각 경로가 견디는지
대부분의 경로가 이미 `owner` 빈 값을 건너뛴다(AI 세력 목록·증원·생산, 침공 쌍, 압박 계획, 외교 세력 목록·행동, 대외 교역 후보, 소유 도시 목록, 국가 창고 합계, 재상 시드, 성 안 창은 자국만). 그래서 **중립 세력은 만들지 않았다**(중립 id를 넣으면 오히려 AI 세력으로 잡혀 턴·외교·첩보 대상이 됨). 빈 값을 못 견디거나 막지 않던 곳만 고쳤다:
| 자리 | 전 | 후 |
|---|---|---|
| 정탐 4종(정보 수집·민심·충성도·반란) `spy_action_service.gd` `_validate_spy_action` | 자국만 거절 → 빈 성에도 실행됨 | 빈 성이면 `unclaimed_city` 거절("주인 없는 빈 성은 대상이 아닙니다.") |
| 2D 영토 덧칠 `worldmap_territory_controller.gd` | 빈 성마다 매번 "owner color missing" 경고 | 조용히 건너뜀(색 없음) |
| 3D 소유 동기화 `worldmap3d_root.gd` `set_city_owner` | `""`이면 false → 어댑터의 `unmapped_owners`에 쌓임 | `""` = 빈 성(회색 성·깃발, 영토 채움 없음) 허용 |
| 도시 창 세력 글자 `ui_formatter_helpers.gd` / `worldmap_city_info_panel_base.gd` | 빈 글자 / "정보 없음" | "주인 없음(빈 성)" |
빈 성 규칙은 `scripts/worldmap/worldmap_unclaimed_city_rules.gd`(`WorldMapUnclaimedCityRules`) 한 곳에 모았다(지시서 1-4: 차지 방법은 범위 밖, 규칙 자리만). 플레이어 공격은 원래 "적 도시만 공격" 규칙으로 막힌다.

### 1-3. 2D 표식 52개 — 씬 추가 대신 코드 생성 (덜 바꾸는 쪽)
- 씬에 넣으면 노드 52개 × 자식 5개(수백 줄)가 늘고, 씬 텍스트를 읽는 시험·검사기(`test_worldmap3d_roads`·`test_worldmap3d_color_parity`·`validate_p1b1_worldmap_visual_baseline`)의 13개 기대가 함께 깨진다.
- 그래서 `scripts/worldmap/worldmap_city_roster_service.gd`가 `_connect_city_markers` 첫 줄에서 기존 표식 하나를 복사해 52개를 만든다(이름·지역·주인 `""`·0.7 이웃·길 종류, 위치는 기존 13개 2D 위치와 3D km의 최소제곱 맞춤). 2D 지도는 3D HUD에서 숨겨져 있고, 3D 클릭·HUD·턴 코드는 13개와 똑같이 이 표식을 본다. main 변경은 호출 1줄.
- **기존 13개 성의 게임 이웃(2D 표식 `neighbors`·`route_types`)은 그대로 두었다.** 0.7에서는 평양–한성 같은 직통이 없어져 기존 13성끼리의 길이 빈 성을 거쳐야 하는데, 빈 성은 공격·교역 대상이 아니라 한반도 4성 MVP(AI 침공·승리)가 끊긴다. 그래서 그림(3D 길)은 0.7 그대로, 기존 13성끼리의 게임 연결은 v2.4 그대로, 새 성의 연결은 0.7(육로 `land`, 바닷길 `sea`를 명시)로 했다. 13성 게임 연결을 0.7로 바꾸는 것은 세력 배치(P2) 때 결정 — 9절.

## 2. 넣은 것
| 항목 | 내용 |
|---|---|
| 성 | 65개(기존 13 + 새 52), 위치·이름·유형·지역 번호 0.7 그대로 |
| 기존 13개 | id·주인·병력·인구·등급 그대로. `karakorum` 표시 이름 **상도**(HUD·3D 깃발·2D 표식), 위치 0.7(116.185E 42.358N), 지역 라벨 **내몽골**, HUD 지역 글자 "내몽골". 다른 성 교역 문구 속 "카라코룸" 2곳도 "상도" |
| 지역 | `regions.json` + 두 텍스처를 0.7 굽기본으로 교체(65개 지역). 새 52개 라벨은 `label_ko`가 없어 성 이름으로 표시 |
| 길 | 3D `roads` 100 · `sea_routes` 20(0.7 그대로). 건업–강동·오사카–히로시마·큐슈–가고시마는 육로, 수군 연구 요구 없음 |
| 건물 양식 | `rule_data` 성마다 `building_style`(kr/cn/jp) 그대로. 2D 표식 `region_id`도 양식에 맞춤(kr→한반도, cn→중국대륙, jp→일본열도) |
| 세력 | 13개 그대로(추가 0) |

### 새 52개 성 기본값 (표시용 최소값, 세력·병력·장수 없음)
| 키 | 값 |
|---|---|
| owner / nation | `""` |
| troops | 0 |
| population | 1000 |
| population_rating / commerce_rating | 1 / 1 |
| gold / food | 0 / 0 |
| public_order / commerce / agriculture / defense | 50 / 10 / 10 / 1 |
| loyalty | 50 |
| governor / 장수 | 없음(`governor_policy_id` = `follow_chancellor`) |
| resource_seed / yield_seed | 모두 0 |
| domestic_seed | 민심 50 · 치안 50 · 농업 10 · 상업 10 · 안정 50 |
| region / region_key | 0.7 `area`(예: 만주·중원) / 양식별 지역 키 |
| 3D 규칙 | owner `""`, troops 0, population 1000, grade 1, capital false |

## 3. 기존 시험·검사기 변경 표
| 파일 | 전 | 후 | 이유 |
|---|---|---|---|
| `test_worldmap3d_roads.gd` | 3D 규칙 13+5, 2D 길 18개 = 3D 길 집합, 3D 경로 13+5, 통계 13/5 | 3D 규칙 100+20(쌍 120개 중복 없음), 2D·3D 둘 다 있는 길은 종류 같음, 3D 경로 100+20, 통계 100/20 | 0.7 길. 2D 씬 길 18개는 기존 13성 게임 연결(1-3) |
| 같은 파일, 바닷길 점 수 | `p.size() > 3` | `p.size() >= 3` | 건업–양주는 한 하구를 끼고 있어 경로가 성 → 바다 칸 하나 → 성(3점). 바다 칸 위 검사는 그대로 |
| `test_worldmap3d_host.gd` | 표식 13 | 65 | 성 65 |
| `test_worldmap3d_production.gd` | 어댑터·3D 성 13 | 65 | 성 65 |
| `tools/p1_exact_delta.py` | main = P0 체크포인트 | P0 → `CITIES65_CHECKPOINT` `215de31` 정확한 차이 60줄(+57/−3: 빈 성 52줄·주석 1줄·호출 1줄·상도 3줄) | 지시서 4절 재고정 |
기존 확인은 모두 유지(줄인 확인 0).

## 4. 새 시험 `tests/scripts/test_worldmap_cities65_preview.gd`
`[CITIES65_PREVIEW] checks=322 failures=[]` (C-track 등록, P1 시험 뒤)
1. 성 65개(HUD·3D 규칙·3D 위치·게임 표식), id 중복 0, 기존 13개 주인·병력·인구·등급 그대로 ✔
2. 성 중심이 자기 지역 번호 픽셀 위 65/65 ✔
3. 육로 100·바닷길 20, 3쌍은 지도 데이터 `land` + 게임 길 종류 `land` + 수군 연구 불필요(수군 미연구 새 게임), 대조군 큐슈–오사카는 여전히 수군 필요 ✔
4. 상도: 이름(HUD·3D·2D 표식)·위치·지역 라벨 내몽골, 옛 직통 길(상도–평양·상도–업성·한성–평양·성도–건업) 없음 ✔
5. 빈 성 그대로 턴 5번: 새 성 소유 변화 0, 기존 13성 소유 유지, 오류 0 ✔
6. 저장→불러오기 65성 같음 / 옛 세이브(13성만) 불러오기 → 새 52개 기본값, 기존 값 손실 없음 ✔
7. P0·P3·P1 회귀: 세 시험 모두 C-track에 그대로(아래 전체 실행 포함)
8. 평양 메뉴 → 옆 빈 성(개성) 클릭: 선택이 개성으로 바뀌고 메뉴 닫힘, 이전 성 기준 첩보·출전 버튼을 눌러도 상태 변화 0, 개성 공격 불가 → 다시 평양: 메뉴 정상 ✔
9. 턴 뒤 + 저장/불러오기 사본 뒤: AI 생산·침공 쌍·압박 계획, 외교 세력·5개 행동, 정탐 5개 행동(개성 정보 수집은 `unclaimed_city`로 거절), 대외 교역 후보, 승리 도시 목록, 출전 대상, 소유 도시 목록(저장 포함), 국가 창고 도시 — 빈 성 0 ✔
- 지시서 6절대로 지도 데이터 검수(3쌍 `land`)와 실제 출전 이동은 구분했다. 빈 성을 끼운 실제 출전은 세력·병력 배치 뒤.

## 5. CI
- `Verify C-track refactor` 실행 `46044665812` (head `7c27f3c`): **초록**, 4개 묶음(shard 0~3) 모두 success, 재실행 없음. 끝난 시각 2026-11-27 18:08 UTC.
- `Verify WorldMap3D` 실행 `46044665719` (head `7c27f3c`): **초록**, 단계별 Import·WorldMap3D tests·scene load·Diff check 모두 success(작업의 `continue-on-error`에 기대지 않은 실제 통과). 끝난 시각 17:50 UTC.

## 6. 로컬 전체
- 작업 트리 `7c27f3c`: C-track 시험 214개(CI 목록 그대로, 4개 병렬) **214 실행, 214 종료 코드 0**. 검증 스크립트 72개 **72 통과**.
- WorldMap3D 시험 8개(`test_worldmap3d_*`) 모두 통과: adapter 56 · camera_controller 61 · camera_external_input 20 · color_parity 57 · host 58 · mem_probe 37 · production 28 · roads 172 checks, failures 0. (`ci_worldmap3d_scene_load.gd`는 저장소에 없어 CI도 건너뜀.)

## 7. 김작 F6 안내 (`WorldMap.tscn`, 합격 기준 ①~⑤)
1. ① 지도를 멀리 → 성 65개가 보이고 이름이 맞는지(예: 한반도에 개성·철원·제주, 일본에 히로시마·가고시마, 중국에 장안·대도). 몽골 쪽 성은 **상도**, 내몽골 위치.
2. ② 지역 경계가 65개로 나뉘어 보이는지, 호수에 가짜 경계가 없는지. 새 성 지역은 채움색 없이(빈 땅) 경계만.
3. ③ 새 성(예: 개성) 클릭 → 도시 창, 세력 "주인 없음(빈 성)", 병력 0. 행동 메뉴는 뜨지 않음(외교·첩보·무역·출전 없음).
4. ④ 기존 13개 성: 주인·병력 그대로(평양 고구려 280, 한성 플레이어 300 …).
5. ⑤ 턴 넘기기 몇 번 → 오류·멈춤 없음, 새 성 주인 그대로.
- 참고: 3D 길은 0.7(120개)로 그려진다. 다만 기존 13성끼리의 게임 연결은 그대로라(1-3) 평양→한성 침공처럼 지금 있던 행동은 그대로 일어난다.

## 8. 바뀐 파일
`worldmap_main.gd`(+57/−3), `WorldMap.tscn`(상도 2줄), `worldmap3d/maps/eastasia/{markers,regions,rule_data_eastasia}.json`·`textures/region_{ids,dist}.png`, `worldmap3d/scripts/worldmap3d_root.gd`, 새 `scripts/worldmap/worldmap_unclaimed_city_rules.gd`·`worldmap_city_roster_service.gd`(+`.uid`), `spy_action_service.gd`, `diplomacy_spy_helpers.gd`, `worldmap_territory_controller.gd`, `ui_formatter_helpers.gd`, `worldmap_city_info_panel_base.gd`, 시험 3개 + 새 시험(+`.uid`), `verify-c-track.yml`, `tools/p1_exact_delta.py`.

## 9. 남은 문제
- 기존 13성끼리의 게임 연결(이웃·길 종류)은 v2.4 그대로다. 0.7 길로 바꾸면 한반도 4성 사이 직통이 사라져 MVP 침공·승리가 끊기므로 세력·병력 배치(P2) 때 같이 정해야 한다. 그때 `WorldMap.tscn` 2D 길 18개도 정리.
- 새 52개 지역은 `label_ko`가 없어 지역 라벨이 성 이름으로 나온다(0.7 데이터 상태 그대로).
- 2D 영토 덧칠은 소유 성만 세므로 한도 64를 넘지 않는다. 빈 성이 차지되기 시작하면 한도(`MAX_CITIES` 64, 셰이더 포함)를 올려야 한다.
- `bake_meta.json`의 `region_count: 13`은 실행 중 읽지 않아 그대로 두었다(굽기 도구가 저장소 밖).
- 빈 성 차지(공격·점령·생성 무장 시작)는 범위 밖 — `WorldMapUnclaimedCityRules` 한 곳을 고치면 된다.
