기준 화면: `feature/wm3d-cityhud-20261105`(CH-2 위, 코드 커밋 `328ee04`·`a63e137`)에서 `res://WorldMap.tscn`을 열고 내 도시(한성·평양·건업·에도·교토)를 누르면 성 안 창이 배치표대로 배경·건물·민가를 그린다(참고 그림 `reference/<city>_interior_noshadow_v2.png`와 같은 배치). 나머지 도시는 CH-2 자리 표시 글, 카라코룸은 열리지 않음. 테크 연동 없음(CH-4).
합격 기준: 지시서 `agent/ORDER_CITYHUD_CH3_LAYOUT_20261105.md` 원문 7절 자동 기준 1~9(클코치 보정 반영) + 그림 비교 10번(2px 이내) + CI success. 김작 F6는 CH-4 뒤에 한 번에.

# 보고서 — CITYHUD CH-3: 성 안 건물을 제자리에 놓기

## 요약 (3줄)
1. 됐나: 됐다. 커밋 ① `328ee04` D5 그림 24장 교체 + 매니페스트 24행 `bytes`·`md5` 갱신, ② `a63e137` 배치표·배경 5·민가 14(+`.import` 19) + 레이아웃 도우미 + 컨트롤러 + 테스트 + CI 한 줄. 새 테스트 `[CITY_INTERIOR_LAYOUT] checks=93 failures=[]`, 검증기 72/72(커밋 뒤), CH-1 482·CH-2 74·3D 8종 통과.
2. 그림 비교(10번): 이 PC에서 창 있는 Godot로 5성 캔버스를 k=1로 캡처해 `_noshadow_v2`와 비교 — 5성 모두 항목별 최적 이동 0px, 평균 픽셀 차이 0.79~1.07(0~255).
3. 막힌 것: 없음. 해석 2가지(교토 "해안 7종", "CH-2 임시 격자")는 아래 "택한 해석".

## 진행 기록 (정본 `PROGRESS_WM3D.md` 대신 여기에 쓴다)
- 2026-11-06 — 큐 11번(M7-1) 완료 뒤 큐를 다시 읽음(12번 앞에 끼운 항목 없음) → 12번 시작. 가지 끝은 `70392ba`(MERGE-MAIN 보고서, CH-2 보고서 `846f128` 위 문서 커밋 1개) — 코드 HEAD는 CH-2와 같아 큐 10절대로 진행.
- 입력: zip 크기 64,054,220 B, SHA-256 `a1988dc05aa10b7467368c8b066cdedae00c584f21e7194d21b5d6a88d4e9bb2` 일치. 항목 90개, `..`·절대 경로 0, 최상위 `EASTWAR_CityHUD_CH3_20261105` 하나 → `C:\eastwar_tmp\ch3_extract\`에 풂(정본 폴더 밖, 압축 푼 폴더 안에서 인터프리터 실행 없음).
- 마지막 코드 커밋 `a63e137` / 이 보고서 `agent/REPORT_CITYHUD_CH3_20261105.md` / CI 아래 5절.
- 다음 할 일: 큐를 다시 읽고 새 항목이 없으면 5분마다 확인(큐 10절).

## 택한 해석
- **교토 "해안 7종"**: [사실] 배치표의 교토 `coastal_only` 항목은 7개인데, 그중 항구(`commerce_port`, z 26)가 `compare_only`이기도 하다. 원문 7절 4번("교토 30개 = 건물 25, 항구 비교본 제외 + 민가 5")과 D4("따로 둔 항구 비교본은 쓰지 않음")를 따르면 그려지는 해안 항목은 6개다. 항구는 무역항(z 28, 발 자리 (672, 736))의 `slot_candidates`에 들어 있어 CH-4가 고를 수 있다. 그래서 7절 7번 "해안 7종이 그려진다"를 "해안 7종 = 그려진 6개 + 무역항 자리 후보의 항구"로 읽고 테스트로 못 박았다.
- **"CH-2 임시 격자"**: [사실] CH-2 창에는 격자가 없고 가운데 안내 글("건물 그림은 다음 단계에서 연결됩니다")만 있다. 배치표가 없는 도시는 그 안내 글을 그대로 보인다(격자를 새로 만들지 않음 — 덜 바꾸는 쪽).
- **해안 판정**: main의 `_is_city_coastal_for_city_tech(city_id)`를 `call`로 읽기만 한다(main 0줄). 이 이름을 컨트롤러의 `MAIN_MEMBERS`에 넣어 CH-2 테스트가 존재를 검사한다(그래서 CH-2 테스트 검사 수 73 → 74).
- **건물 그림 스타일**: 배치표의 `region_style`(kr/cn/jp)로 `WorldMapCityBuildingAssets.load_texture(building_key, region_style)`. 민가는 항목의 `texture` 경로. null이면 그 칸만 건너뜀(오류 없음).
- **그리기**: 창 몸통 `InteriorArea`(`clip_contents`) 안에 1280×768 `InteriorCanvas`(`clip_contents`, D7 잘림) 하나, 그 안에 배경 → 항목을 배치표 순서대로 `TextureRect`(선형 필터, `mouse_filter = IGNORE`, `STRETCH_SCALE`)로 추가. 창 몸통 크기가 바뀌면(`resized`) `k = min(W/1280, H/768)`, `off`로 캔버스의 `scale`·`position`을 맞춘다. 닫으면(`close`) 그린 노드를 모두 지워 텍스처 참조를 놓는다. 다른 도시로 바뀌면 지우고 다시 그린다.
- **CI 등록**: CH-2 두 줄 바로 뒤(마지막 목록 끝)에 한 줄 → 인덱스 200 → shard 0. 추가 전 네 shard가 50개씩 같아 어느 쪽이든 같은 무게. 로컬 14초.
- **배치표 좌표**: 고치지 않았다. 캔버스 밖으로 나가는 항목은 지시서가 말한 둘뿐 [사실]: 에도 z 28 `deco_minga_compound_a_jp` 아래 32px, 교토 z 25 `deco_minga_compound_a_jp` 오른쪽 32px. `flip_h`는 5성 모두 false. 이상해 보이는 좌표는 찾지 못했다.

## 1. 바뀐 파일 (5절 목록 안)
| 커밋 | 파일 |
|---|---|
| ① `328ee04` | `assets/worldmap/city_buildings/` v2 PNG 24장 덮어쓰기(이름·크기·색 형식 동일 확인), `city_buildings_manifest.txt` 24행의 `bytes`·`md5`만(머리글·나머지 66행 불변). 재import 뒤 `.import` 변경 0 |
| ② `a63e137` | `city_layouts.json`, `interior_bg_<city>.png` 5, `deco_minga_*.png` 14 + `.import` 19(설정은 CH-1 그림과 같음: `compress/mode=0`, `mipmaps/generate=false`; JSON은 `.import` 없음), `scripts/worldmap/ui/worldmap_city_interior_layouts.gd`(+`.uid`), `scripts/worldmap/ui/worldmap_city_interior_controller.gd`, `tests/scripts/test_worldmap_city_interior_layouts.gd`(+`.uid`), `.github/workflows/verify-c-track.yml`(+1줄) |
- `worldmap_main.gd`·`worldmap3d/`·`WorldMap.tscn` 변경 0. 레포에 넣지 않은 것: `reference/`·`backgrounds/`·`build_ch3.py`·`*.csv`·`_check.json`·`README_KO.md`·zip.

## 2. 새 테스트 `tests/scripts/test_worldmap_city_interior_layouts.gd`
실제 `WorldMap.tscn`, 2D 지도.
- 자료(기준 1~3): JSON 읽힘, 성 정확히 5개, 성마다 건물+민가 수(19+11, 19+9, 20+9, 21+8, 26+5), `kind == building`의 키가 `BUILDING_KEYS` 안 + 그림 `ResourceLoader.exists`, 배경·민가 경로 존재, `ay` 오름차순, `ax == x + w/2`, `ay == y + h`, `w·h == round(src·1.25)`, 교토 compare_only 1·coastal_only 7, `items_for_city` 거르기, `canvas_transform(960×576)` → k 0.75.
- 그리기(기준 4·5·7): 5성 각각 실제로 열어 그린 수(한성 30, 평양 28, 건업 29, 에도 29, 교토 30 = 건물 25 + 민가 5), 배경이 맨 아래 1280×768, 배치표 순서, compare_only 0, 해안 항목(교토 6 + 무역항 후보의 항구 = 7종, 다른 4성 0), main 해안 판정(교토만 true), 노드마다 텍스처 있음·`IGNORE`, 창 몸통 1280×768(k 1)·960×576(k 0.75)·1000×768(k 0.78125, 세로 여백)에서 왼쪽 위·크기가 공식과 1px 이내.
- 전환·닫기(기준 8): 한성 → 에도 전환 시 에도만 다시 그림, 닫기 버튼·Esc로 닫히고 그린 노드 0.
- 배치표 없는 도시(기준 6): 경주는 열리고 안내 글이 보이며 캔버스 숨김, 카라코룸은 `no_art`.

## 3. 로컬 검증 (결과 줄 원문)
| 항목 | 결과 |
|---|---|
| 새 테스트, 고치기 전(컨트롤러 원복) | exit=1 `[CITY_INTERIOR_LAYOUT] checks=24 failures=["controller draws castle layouts (CH-3 API)"]` |
| 새 테스트, 고친 뒤 | exit=0 `[CITY_INTERIOR_LAYOUT] checks=93 failures=[]` (14초) |
| CH-1 테스트(D5 교체 뒤) | `[CITY_BUILDING_ASSETS] checks=482 failures=[]` |
| CH-2 테스트 | `[CITY_INTERIOR] checks=74 failures=[]` (해안 판정 이름 1개 존재 검사 추가분) |
| `test_worldmap_diplomacy_routing` | `[DIPLOMACY_ROUTING] PASS: 172 checks, 0 failures` |
| 3D 8종 | adapter 56/0, camera_controller 61/0, camera_external_input 20/0, color_parity 57/0, host 58/0, mem_probe 37/0, production 28/0, roads 121/0 |
| 검증기, 작업 트리 | `validators=72 pass=71 fail=1` — `validate_worldmap_trade_phase2_extraction.py: FAIL: UI/scene restoration or modification detected`(CH-2 때와 같은 작업 트리 검사) |
| 검증기, 커밋 뒤 깨끗한 트리 | `validators=72 pass=72 fail=0` |
| 장면 `--quit-after 5` 오류 줄 | WorldMap 0, WorldMap3D_Host_Test 0, WorldMap_UI_Test 0, WorldMap_16x9_Test 1(`1 resources still in use at exit` — CH-2 보고서대로 기준 커밋에서도 같음) |
| `git diff --check` | 출력 없음 |

## 4. 그림 비교 (원문 10번, 보정: 기준 `reference/<city>_interior_noshadow_v2.png`)
방법: 이 PC에서 창 있는 Godot(`--path .`, headless 아님)로 실제 컨트롤러가 그린 `InteriorCanvas`를 1280×768 SubViewport에 옮겨 k=1로 캡처(임시 스크립트, 레포에 남기지 않음) → Python(numpy·PIL, 정본 폴더·압축 푼 폴더 밖에서 실행)으로 참고 그림과 비교. 항목마다 배치표 사각형 안에서 ±4px 이동을 모두 시험해 차이가 가장 작은 이동을 찾았다.
| 성 | 평균 픽셀 차이(0~255) | 항목 수 | 항목별 최적 이동 최대 | 2px 넘는 항목 | 이동 0에서 항목 차이 최대 |
|---|---|---|---|---|---|
| hanseong | 0.955 | 30 | 0px | 0 | 2.40 |
| pyeongyang | 0.936 | 28 | 0px | 0 | 3.19 |
| jianye | 0.787 | 29 | 0px | 0 | 2.51 |
| edo | 0.895 | 29 | 0px | 0 | 2.29 |
| kyoto | 1.066 | 30 | 0px | 0 | 2.85 |
- 5성 모두 모든 항목이 이동 0px에서 가장 잘 맞는다 → 2px 기준 통과. 남는 1 안팎의 차이는 크기 조정(1.25배) 보간 차이로 보인다[추정].
- 참고: 첫 캡처에서 한성만 크게 달랐는데(평균 40.7), 창이 처음 열린 직후 몸통 `resized`가 캡처 스크립트가 맞춘 k=1을 창 크기의 k로 되돌린 탓이었다(캡처 방법 문제, 제품 동작은 정상: 창 크기에 맞춰 줄어듦). 캡처 직전에 k=1을 다시 맞춰 재캡처한 값이 위 표다.

## 5. CI [사실]
| run | 커밋 | 결과 | job |
|---|---|---|---|
| `42066451862` Verify C-track refactor | `a63e137` | **success** | shard 0 `127381733126` / shard 1 `127381732770` / shard 2 `127381731968` / shard 3 `127381732767` 모두 success |

- job 로그 원문: shard 0 `[CITY_INTERIOR_LAYOUT] checks=93 failures=[]`·`[CUTIN] checks=16 failures=[]`, shard 2 `[CITY_BUILDING_ASSETS] checks=482 failures=[]`, shard 3 `[CITY_INTERIOR] checks=74 failures=[]`.
- 커밋 ①·② 를 함께 push해 CI는 끝 커밋 `a63e137`에서 한 번 돌았다(① 단독 run 없음).
- `Verify WorldMap3D`: **실행 안 됨**(경로 조건 — `WorldMap.tscn`·3D 파일 변경 없음). 로컬 대체: 3D 8종 통과(3절).

## 6. 막힌 것
- 없음.

## 7. diff (`git diff --output-indicator-context='|' 70392ba a63e137`, PNG·`.import`·`city_layouts.json` 제외 — JSON은 입력 zip의 `repo_ready` 원본 그대로 복사; 바뀌지 않은 줄 표시는 `|`)
- 전체 규모: 70 files changed, 4629 insertions(+), 33 deletions(-)
```diff
diff --git a/.github/workflows/verify-c-track.yml b/.github/workflows/verify-c-track.yml
index bcc2554..3c74a45 100644
--- a/.github/workflows/verify-c-track.yml
+++ b/.github/workflows/verify-c-track.yml
@@ -412,6 +412,7 @@ jobs:
|            tests/scripts/test_worldmap_spy_controller_extraction.gd
|            tests/scripts/test_worldmap_city_building_assets.gd
|            tests/scripts/test_worldmap_city_interior_window.gd
+            tests/scripts/test_worldmap_city_interior_layouts.gd
|          )
|          index=$(cat "$RUNNER_TEMP/ci_test_index" 2>/dev/null || echo 0)
|          for test_script in "${tests[@]}"; do
diff --git a/assets/worldmap/city_buildings/city_buildings_manifest.txt b/assets/worldmap/city_buildings/city_buildings_manifest.txt
index 9cdae3e..65a4225 100644
--- a/assets/worldmap/city_buildings/city_buildings_manifest.txt
+++ b/assets/worldmap/city_buildings/city_buildings_manifest.txt
@@ -1,10 +1,10 @@
|file,kind,group,name_ko,region,size_px,bytes,md5
|bld_commerce_street_market_kr.png,game,1 상업·병영,노점시장,kr,128x128,20853,45a0398cd4547f5849211da7f9f32f15
|bld_commerce_street_market_cn.png,game,1 상업·병영,노점시장,cn,128x128,19112,a81443bc62ba436dae573d40ec7f5e46
-bld_commerce_street_market_jp.png,game,1 상업·병영,노점시장,jp,128x128,20898,6645ba409bc7e83680cc2c0cb2ee3006
+bld_commerce_street_market_jp.png,game,1 상업·병영,노점시장,jp,128x128,21024,f0e906db7ba3e7f264f8876053f6039e
|bld_commerce_permanent_market_kr.png,game,1 상업·병영,상설시장,kr,128x128,18101,17bee5e656c4c71b29de34b3ac6a97e0
|bld_commerce_permanent_market_cn.png,game,1 상업·병영,상설시장,cn,128x128,19397,dd580c9fec7508b4283f153c7d19cbb1
-bld_commerce_permanent_market_jp.png,game,1 상업·병영,상설시장,jp,128x128,18917,413424262fc49a1994f73c4a5d280e46
+bld_commerce_permanent_market_jp.png,game,1 상업·병영,상설시장,jp,128x128,18926,c9c810c10d810df52724284eae69ec72
|bld_commerce_grand_market_kr.png,game,1 상업·병영,대형시장,kr,192x128,30732,200fb08ece079b391dd4e30cd77659b8
|bld_commerce_grand_market_cn.png,game,1 상업·병영,대형시장,cn,192x128,25738,18214cdc906fe497beecc343fe651bab
|bld_commerce_grand_market_jp.png,game,1 상업·병영,대형시장,jp,192x128,30156,0c696b8f148d6c357b57bf9e635c6428
@@ -26,51 +26,51 @@ bld_mil_iron_gate_jp.png,game,2 성곽,철문,jp,128x128,25853,587754a7907a7f68f
|bld_mil_watchtower_kr.png,game,2 성곽,망루,kr,64x128,13388,27fc81710e8f9fe0f924392626ba49fc
|bld_mil_watchtower_cn.png,game,2 성곽,망루,cn,64x128,11400,0234b02e68936e51a8c00c2bfb364946
|bld_mil_watchtower_jp.png,game,2 성곽,망루,jp,64x128,11732,2b1c0ec220e6d1b95c4ad946b7a993ff
-bld_mil_beacon_kr.png,game,2 성곽,봉화대,kr,64x128,6361,f4cd483ef49bbdec02504c468350f243
+bld_mil_beacon_kr.png,game,2 성곽,봉화대,kr,64x128,10714,f69dc0c70f55a1e768ad9fffbeda6118
|bld_mil_beacon_cn.png,game,2 성곽,봉화대,cn,64x128,10832,0850e7f5c5ed95371a19674560a19d20
|bld_mil_beacon_jp.png,game,2 성곽,봉화대,jp,64x128,12923,d97caaebfe157d782e6fcdb8b28f560e
|bld_mil_iron_fortress_kr.png,game,2 성곽,철옹성,kr,256x256,86988,7cac3632c46eb1290f6d0e616404191a
|bld_mil_iron_fortress_cn.png,game,2 성곽,철옹성,cn,256x256,76628,b7842ce5663a806778fd4bab3c750d6e
|bld_mil_iron_fortress_jp.png,game,2 성곽,철옹성,jp,256x256,83810,281ef25734f85ca236b0c330fa1615a5
-bld_mil_moat_kr.png,game,2 성곽,해자,kr,256x64,7373,2599985f41548b1f2669ab6749d9f98c
-bld_mil_moat_cn.png,game,2 성곽,해자,cn,256x64,7030,58df2b7d54a1af64508f6876a47ebf1f
-bld_mil_moat_jp.png,game,2 성곽,해자,jp,256x64,7393,c14f93b147a02bafc3ea44bf4ab8fff3
-bld_mil_double_moat_kr.png,game,2 성곽,이중 해자,kr,256x64,8888,27d76e53d6a1bb19c4161409b6ae4bf1
-bld_mil_double_moat_cn.png,game,2 성곽,이중 해자,cn,256x64,8596,442b790ea086edc81c8ae718c932c122
-bld_mil_double_moat_jp.png,game,2 성곽,이중 해자,jp,256x64,8793,356e00adf4c256548fdb20e624c829b9
+bld_mil_moat_kr.png,game,2 성곽,해자,kr,256x64,8138,fc9bd923d3cdba050afd76d70e3b8f54
+bld_mil_moat_cn.png,game,2 성곽,해자,cn,256x64,6909,2e409d7e739039f74a1110dce3e4512f
+bld_mil_moat_jp.png,game,2 성곽,해자,jp,256x64,8721,70ede807efec89b2b2910914cd281bb9
+bld_mil_double_moat_kr.png,game,2 성곽,이중 해자,kr,256x64,11133,9b82a2d76d307ad983e8b6a912cab55c
+bld_mil_double_moat_cn.png,game,2 성곽,이중 해자,cn,256x64,9812,f37ba4e4a2437493b3c8221aac372810
+bld_mil_double_moat_jp.png,game,2 성곽,이중 해자,jp,256x64,10893,3b372b2e4c78d5e4e5cf92ceeca3afae
|bld_agri_irrigation_kr.png,game,3 들판,관개수로,kr,256x128,37890,e370f96c24c72d3a6ec2289808176498
|bld_agri_irrigation_cn.png,game,3 들판,관개수로,cn,256x128,36516,0828940e419a9032027447532d170f85
|bld_agri_irrigation_jp.png,game,3 들판,관개수로,jp,256x128,37755,b86491df69dc9d0f3bdccd09e394b3cc
|bld_agri_reservoir_kr.png,game,3 들판,저수지,kr,192x128,40577,ef296ec2b1286ad5152048b5e9c9a972
|bld_agri_reservoir_cn.png,game,3 들판,저수지,cn,192x128,28857,50cd1b108ae88940a2629e8b54a1836d
|bld_agri_reservoir_jp.png,game,3 들판,저수지,jp,192x128,36547,843406b226dd6948dddb5ad1f2ace857
-bld_agri_granary_zone_kr.png,game,3 들판,곡창지대,kr,256x128,44253,b2f03afffb6faa1b7c516f789a109504
-bld_agri_granary_zone_cn.png,game,3 들판,곡창지대,cn,256x128,42100,c5d31b36db6da6a152a71c7733f7ec1b
-bld_agri_granary_zone_jp.png,game,3 들판,곡창지대,jp,256x128,41667,c835203fa363f99b3c9a76e2af7cfdeb
-bld_agri_pasture_kr.png,game,3 들판,목초지,kr,192x128,32375,05bab7c143a0536d1c4481d786b71375
-bld_agri_pasture_cn.png,game,3 들판,목초지,cn,192x128,30969,e72d28780645826320a5369d96c5e1e7
-bld_agri_pasture_jp.png,game,3 들판,목초지,jp,192x128,33536,8679a6da4ce55a0047386ec3ff0af801
+bld_agri_granary_zone_kr.png,game,3 들판,곡창지대,kr,256x128,43927,454575a95bf7637e00c3902b665d4fc2
+bld_agri_granary_zone_cn.png,game,3 들판,곡창지대,cn,256x128,41845,db986d74be6fbca7ef748285e0d16a1c
+bld_agri_granary_zone_jp.png,game,3 들판,곡창지대,jp,256x128,41341,d6f113531c67f6f497768cb663b9a750
+bld_agri_pasture_kr.png,game,3 들판,목초지,kr,192x128,31676,66ef3ecbfdd288567d5d5c28d5f593da
+bld_agri_pasture_cn.png,game,3 들판,목초지,cn,192x128,31547,460383d00099f1fa745d95c344f8d372
+bld_agri_pasture_jp.png,game,3 들판,목초지,jp,192x128,31964,b87fdfe3be56cbb7b5149ddf3b3bf737
|bld_agri_ranch_kr.png,game,3 들판,목장,kr,192x128,30021,24ead59a4c915089740cbec100036f83
|bld_agri_ranch_cn.png,game,3 들판,목장,cn,192x128,29162,04623efee2aa636b3ef040bba8ef050e
|bld_agri_ranch_jp.png,game,3 들판,목장,jp,192x128,31074,fc2652817b94f37ad81a678d8e5884b0
|bld_fish_village_kr.png,game,4 해안,어촌,kr,192x128,33739,281ce299cf3672e32094235ddfedaa92
-bld_fish_village_cn.png,game,4 해안,어촌,cn,192x128,34043,eba3064229038cfcca6135e81a77350c
+bld_fish_village_cn.png,game,4 해안,어촌,cn,192x128,33614,e73d7fd621a2c6b039830953f5dcf009
|bld_fish_village_jp.png,game,4 해안,어촌,jp,192x128,34821,f6ea9a3fed0bed1f4740a8e397988c5f
|bld_fish_salt_field_kr.png,game,4 해안,염전,kr,192x128,29688,b310a86bce164549f225588464f37af6
|bld_fish_salt_field_cn.png,game,4 해안,염전,cn,192x128,31984,d6c5b10bf77a2227e3b69b932ed41ca8
|bld_fish_salt_field_jp.png,game,4 해안,염전,jp,192x128,32464,a76e08d2b274690f625114922ebaff02
|bld_fish_salt_warehouse_kr.png,game,4 해안,소금창고,kr,128x128,24419,7f7e859795c0d9ee80afbca05c249589
-bld_fish_salt_warehouse_cn.png,game,4 해안,소금창고,cn,128x128,26312,47d14a173130e1e03a617a0d343621f7
+bld_fish_salt_warehouse_cn.png,game,4 해안,소금창고,cn,128x128,24098,7b93ac92460177a3a6af9e02cdcc43e9
|bld_fish_salt_warehouse_jp.png,game,4 해안,소금창고,jp,128x128,24363,2b97b848903c1c5f94e2813019b59ddf
|bld_fish_dried_supply_base_kr.png,game,4 해안,건어물 보급기지,kr,128x128,21741,9f205732f0f525746ceb5c607237dd57
-bld_fish_dried_supply_base_cn.png,game,4 해안,건어물 보급기지,cn,128x128,21869,2d625eee505291dc3f457626e550ebbc
+bld_fish_dried_supply_base_cn.png,game,4 해안,건어물 보급기지,cn,128x128,23708,f5048deb4d783de4ee23794dab8a3c16
|bld_fish_dried_supply_base_jp.png,game,4 해안,건어물 보급기지,jp,128x128,23264,4bd2ac3a0d585d0b4a3eeea2de003004
|bld_commerce_port_kr.png,game,4 해안,항구,kr,192x128,31476,0a86ba017deff0a8732c4795d959e5bc
|bld_commerce_port_cn.png,game,4 해안,항구,cn,192x128,29494,a63b34542cc64510c0b3724b902dd53f
|bld_commerce_port_jp.png,game,4 해안,항구,jp,192x128,28357,313b644c0b06e8e668ff1ba3ae6aa852
-bld_commerce_shipyard_kr.png,game,4 해안,조선소,kr,192x128,38557,87367d2b1b22c3bc29c552de593d3b85
-bld_commerce_shipyard_cn.png,game,4 해안,조선소,cn,192x128,37142,55cb9f2f0623cd81217a811d31f97779
-bld_commerce_shipyard_jp.png,game,4 해안,조선소,jp,192x128,37835,11bcc29952787c691fd341eab4cb355b
+bld_commerce_shipyard_kr.png,game,4 해안,조선소,kr,192x128,40128,a09ce980f09884111b82954b0a249f93
+bld_commerce_shipyard_cn.png,game,4 해안,조선소,cn,192x128,35118,6eddd0a71ef35d2467efb97b04a9d7c6
+bld_commerce_shipyard_jp.png,game,4 해안,조선소,jp,192x128,31029,ba6beb005942a3262daabae025db2c30
|bld_commerce_trade_port_kr.png,game,4 해안,무역항,kr,256x128,44159,e6cbd5f6ce6daf16e8d7f5b88655a0d8
|bld_commerce_trade_port_cn.png,game,4 해안,무역항,cn,256x128,40564,141109b22d8959b9c326302df3a05c38
|bld_commerce_trade_port_jp.png,game,4 해안,무역항,jp,256x128,34426,d7fad4765ac64ce821c6b05e3c8dfc79
@@ -82,10 +82,10 @@ bld_life_storehouse_cn.png,game,5 생활,창고,cn,128x128,23301,420f2ca69d0f1a1
|bld_life_storehouse_jp.png,game,5 생활,창고,jp,128x128,24577,84f19e1fe8e181234b6b051389b8aaf4
|bld_life_smithy_kr.png,game,5 생활,대장간,kr,128x128,25691,fefbbf3237da907c5185414fd65e77fc
|bld_life_smithy_cn.png,game,5 생활,대장간,cn,128x128,21568,585c8a0fdfe4060991908889fe18a4c4
-bld_life_smithy_jp.png,game,5 생활,대장간,jp,128x128,26100,d96cb6cb47cfbb9f608666b5f6a61816
+bld_life_smithy_jp.png,game,5 생활,대장간,jp,128x128,22039,f7997f29a548f53f804aab826e9b6c1d
|bld_life_academy_kr.png,game,5 생활,학당,kr,128x128,26780,35816d3e7ee1d57c758492b8629f2351
|bld_life_academy_cn.png,game,5 생활,학당,cn,128x128,22954,4184bb65d806d552ff81b9a2d04e2781
-bld_life_academy_jp.png,game,5 생활,학당,jp,128x128,25597,a711b5c4a76df205bd36f6910c3f2b1c
-bld_life_temple_kr.png,game,5 생활,사찰,kr,128x192,34745,1cf228f66b73093061ea025007ce1e7b
+bld_life_academy_jp.png,game,5 생활,학당,jp,128x128,19226,950a09b1c25fe8d121849549ec0f89c8
+bld_life_temple_kr.png,game,5 생활,사찰,kr,128x192,17874,2bf230278e640e6578291578b0965fbc
|bld_life_temple_cn.png,game,5 생활,사찰,cn,128x192,26383,27c65c1e34205a239ea435404350189c
|bld_life_temple_jp.png,game,5 생활,사찰,jp,128x192,26146,a1e7abe35e16412b39596d2935b3ef5e
diff --git a/scripts/worldmap/ui/worldmap_city_interior_controller.gd b/scripts/worldmap/ui/worldmap_city_interior_controller.gd
index d5795e3..060d5b0 100644
--- a/scripts/worldmap/ui/worldmap_city_interior_controller.gd
+++ b/scripts/worldmap/ui/worldmap_city_interior_controller.gd
@@ -6,7 +6,8 @@ extends Node
|## pick emit the same signal) with CONNECT_DEFERRED, so main's own handler has already run. Opens only for the
|## player's own city when no target / turn / modal state is active; otherwise records why in last_reject_reason.
|## Reads main state only (get()/call()), never writes it. Main is held as a plain Node; no WorldMap3D* classes are named.
-## The window is built in code; building art goes in later steps (CH-3/CH-4).
+## The window is built in code. CH-3: a city with a castle layout (WorldMapCityInteriorLayouts) is drawn from it on a
+## 1280x768 canvas scaled into the window's body; other cities keep the CH-2 placeholder. Tech-driven visibility is CH-4.
|
|const MAIN_META := "wm_city_interior_controller"
|const WINDOW_LAYER := 50   # free between TopNav (40) and the tech tree overlay (60)
@@ -14,6 +15,8 @@ const TURN_PHASE_PLAYER := "player"
|const WINDOW_SIZE := Vector2(960, 600)
|const PLACEHOLDER_TEXT := "건물 그림은 다음 단계에서 연결됩니다"
|const BUILDING_ASSETS_PATH := "res://scripts/worldmap/ui/worldmap_city_building_assets.gd"
+const LAYOUTS_PATH := "res://scripts/worldmap/ui/worldmap_city_interior_layouts.gd"
+const COASTAL_CHECK := "_is_city_coastal_for_city_tech"   # main, read only
|
|## Checked in this order after "own city". [kind, main member name]. Kinds: flag = bool true blocks,
|## text = non-empty String blocks, visible = node visible blocks, method_true = call() true blocks,
@@ -42,7 +45,7 @@ const MODAL_GUARDS := [
|## Other main members this controller relies on (the test checks they still exist).
|const MAIN_MEMBERS := [
|	"_city_markers_by_id", "_camera_controller", "_is_city_owned_by_player_mvp", "_ensure_camera_controller",
-	"_normalize_turn_phase",
+	"_normalize_turn_phase", COASTAL_CHECK,
|]
|
|@export var main_path: NodePath = NodePath("..")
@@ -56,6 +59,11 @@ var _layer: CanvasLayer = null
|var _title_label: Label = null
|var _close_button: Button = null
|var _building_assets: Script = null
+var _layouts: Script = null
+var _placeholder: Label = null
+var _interior_area: Control = null   # the window body; the canvas is scaled and centred in it
+var _canvas: Control = null          # "InteriorCanvas", 1280x768 layout pixels
+var _drawn_items: Array = []         # the layout item of each drawn node, in draw order (tests)
|
|
|func _ready() -> void:
@@ -69,6 +77,8 @@ func _ready() -> void:
|	main = m
|	if ResourceLoader.exists(BUILDING_ASSETS_PATH):
|		_building_assets = load(BUILDING_ASSETS_PATH)
+	if ResourceLoader.exists(LAYOUTS_PATH):
+		_layouts = load(LAYOUTS_PATH)
|	if not main.is_node_ready():   # root child: main._ready builds the markers after us
|		await main.ready
|	_connect_markers()
@@ -100,6 +110,32 @@ func get_connected_marker_count() -> int:
|	return _connected_markers.size()
|
|
+func get_canvas() -> Control:
+	return _canvas
+
+
+func get_interior_area() -> Control:
+	return _interior_area
+
+
+func get_placeholder() -> Label:
+	return _placeholder
+
+
+## The layout item of each drawn canvas node (background excluded), in draw order.
+func get_drawn_items() -> Array:
+	return _drawn_items.duplicate()
+
+
+## Scales and centres the 1280x768 canvas in an area of this size (k = min(W/1280, H/768)).
+func apply_canvas_transform(area_size: Vector2) -> void:
+	if _canvas == null or _layouts == null:
+		return
+	var transform: Dictionary = _layouts.canvas_transform(area_size)
+	_canvas.scale = Vector2.ONE * float(transform.k)
+	_canvas.position = transform.off
+
+
|## Tries to open (or retarget) the window for city_id. Returns true when the window shows that city afterwards.
|func try_open(city_id: String) -> bool:
|	var reason := get_reject_reason(city_id)
@@ -109,6 +145,7 @@ func try_open(city_id: String) -> bool:
|	_open_city_id = city_id
|	_ensure_window()
|	_title_label.text = "%s — 성 안" % _city_display_name(city_id)
+	_draw_city(city_id)
|	_layer.visible = true
|	_block_camera_input()
|	return true
@@ -142,6 +179,7 @@ func close() -> void:
|	_open_city_id = ""
|	if _layer != null:
|		_layer.visible = false
+	_clear_canvas()   # lets the textures go
|	_unblock_camera_input()
|
|
@@ -275,10 +313,80 @@ func _ensure_window() -> void:
|	_close_button.text = "닫기"
|	_close_button.pressed.connect(close)
|	header.add_child(_close_button)
-	var body := Label.new()
-	body.name = "PlaceholderLabel"
-	body.text = PLACEHOLDER_TEXT
-	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
-	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
-	body.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
-	column.add_child(body)
+	_interior_area = Control.new()
+	_interior_area.name = "InteriorArea"
+	_interior_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
+	_interior_area.clip_contents = true
+	_interior_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
+	_interior_area.resized.connect(func(): apply_canvas_transform(_interior_area.size))
+	column.add_child(_interior_area)
+	_placeholder = Label.new()
+	_placeholder.name = "PlaceholderLabel"
+	_placeholder.text = PLACEHOLDER_TEXT
+	_placeholder.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
+	_placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
+	_placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
+	_interior_area.add_child(_placeholder)
+	_canvas = Control.new()
+	_canvas.name = "InteriorCanvas"
+	_canvas.size = Vector2(1280, 768)
+	_canvas.clip_contents = true   # D7: items past the canvas edge are cut, as in the reference
+	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
+	_canvas.visible = false
+	_interior_area.add_child(_canvas)
+
+
+## The castle layout when the city has one (background, then items in layout order), else the CH-2 placeholder.
+func _draw_city(city_id: String) -> void:
+	_clear_canvas()
+	var has_layout := _layouts != null and bool(_layouts.has_layout(city_id))
+	_placeholder.visible = not has_layout
+	_canvas.visible = has_layout
+	if not has_layout:
+		return
+	var layout: Dictionary = _layouts.get_layout(city_id)
+	var background := str(layout.get("background", ""))
+	if ResourceLoader.exists(background):
+		_add_canvas_texture("Background", load(background), Vector2.ZERO, Vector2(1280, 768), false)
+	var coastal := bool(main.call(COASTAL_CHECK, city_id))
+	var region_style := str(layout.get("region_style", ""))
+	for item in _layouts.items_for_city(city_id, coastal):
+		var texture: Texture2D = null
+		if str(item.get("kind", "")) == "building":
+			if _building_assets != null:
+				texture = _building_assets.load_texture(str(item.get("building_key", "")), region_style)
+		else:
+			var path := str(item.get("texture", ""))
+			if ResourceLoader.exists(path):
+				texture = load(path)
+		if texture == null:
+			continue   # missing art: skip the slot quietly
+		var node := _add_canvas_texture("Item_%d_%s" % [int(item.get("z", 0)), str(item.get("building_key", ""))], texture,
+			_layouts.item_top_left(item), Vector2(float(item.get("w", 0)), float(item.get("h", 0))), bool(item.get("flip_h", false)))
+		node.set_meta("layout_item", item)
+		_drawn_items.append(item)
+	apply_canvas_transform(_interior_area.size)
+
+
+func _add_canvas_texture(node_name: String, texture: Texture2D, top_left: Vector2, size: Vector2, flip: bool) -> TextureRect:
+	var rect := TextureRect.new()
+	rect.name = node_name
+	rect.texture = texture
+	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
+	rect.stretch_mode = TextureRect.STRETCH_SCALE
+	rect.flip_h = flip
+	rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
+	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
+	rect.position = top_left
+	rect.size = size
+	_canvas.add_child(rect)
+	return rect
+
+
+func _clear_canvas() -> void:
+	_drawn_items.clear()
+	if _canvas == null:
+		return
+	for child in _canvas.get_children():
+		_canvas.remove_child(child)
+		child.free()
diff --git a/scripts/worldmap/ui/worldmap_city_interior_layouts.gd b/scripts/worldmap/ui/worldmap_city_interior_layouts.gd
new file mode 100644
index 0000000..b83f41a
--- /dev/null
+++ b/scripts/worldmap/ui/worldmap_city_interior_layouts.gd
@@ -0,0 +1,63 @@
+class_name WorldMapCityInteriorLayouts
+extends RefCounted
+
+## CITY-HUD CH-3: reads the five castle layouts (city_layouts.json, from the CH-3 asset pack) once and hands them to the
+## city interior window. Coordinates are 1280x768 canvas pixels, origin top left; (ax, ay) is an item's foot (bottom
+## centre), its rect is (ax - w/2, ay - h) with size (w, h) already scaled. Items are listed in draw order. The layout
+## coordinates are data from the pack and are never adjusted here.
+
+const LAYOUTS_PATH := "res://assets/worldmap/city_buildings/city_layouts.json"
+const CANVAS_SIZE := Vector2(1280, 768)
+
+static var _layouts: Dictionary = {}
+static var _loaded := false
+
+
+static func has_layout(city_id: String) -> bool:
+	return _all_layouts().has(city_id)
+
+
+## {} when the city has no layout.
+static func get_layout(city_id: String) -> Dictionary:
+	var layout: Variant = _all_layouts().get(city_id, {})
+	return layout if layout is Dictionary else {}
+
+
+## The items to draw, in draw order: without compare_only items, and without coastal_only items unless the city is coastal.
+static func items_for_city(city_id: String, is_coastal: bool) -> Array:
+	var items: Array = []
+	var raw: Variant = get_layout(city_id).get("items", [])
+	if not raw is Array:
+		return items
+	for item in raw:
+		if not item is Dictionary:
+			continue
+		if bool(item.get("compare_only", false)):
+			continue
+		if bool(item.get("coastal_only", false)) and not is_coastal:
+			continue
+		items.append(item)
+	return items
+
+
+## k = min(W/1280, H/768); the canvas keeps its ratio and is centred: screen = off + canvas_point * k.
+static func canvas_transform(area_size: Vector2) -> Dictionary:
+	var k := minf(area_size.x / CANVAS_SIZE.x, area_size.y / CANVAS_SIZE.y)
+	return {"k": k, "off": (area_size - CANVAS_SIZE * k) * 0.5}
+
+
+## The item's top-left on the canvas: (ax - w/2, ay - h).
+static func item_top_left(item: Dictionary) -> Vector2:
+	return Vector2(float(item.get("ax", 0)) - float(item.get("w", 0)) * 0.5, float(item.get("ay", 0)) - float(item.get("h", 0)))
+
+
+static func _all_layouts() -> Dictionary:
+	if _loaded:
+		return _layouts
+	_loaded = true
+	if not FileAccess.file_exists(LAYOUTS_PATH):
+		return _layouts
+	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(LAYOUTS_PATH))
+	if parsed is Dictionary and (parsed as Dictionary).get("layouts") is Dictionary:
+		_layouts = (parsed as Dictionary)["layouts"]
+	return _layouts
diff --git a/scripts/worldmap/ui/worldmap_city_interior_layouts.gd.uid b/scripts/worldmap/ui/worldmap_city_interior_layouts.gd.uid
new file mode 100644
index 0000000..553fcf9
--- /dev/null
+++ b/scripts/worldmap/ui/worldmap_city_interior_layouts.gd.uid
@@ -0,0 +1 @@
+uid://cyg7q624idjla
diff --git a/tests/scripts/test_worldmap_city_interior_layouts.gd b/tests/scripts/test_worldmap_city_interior_layouts.gd
new file mode 100644
index 0000000..93e6d68
--- /dev/null
+++ b/tests/scripts/test_worldmap_city_interior_layouts.gd
@@ -0,0 +1,223 @@
+extends SceneTree
+
+# CITY-HUD CH-3: the five castle layouts (assets/worldmap/city_buildings/city_layouts.json) drawn in the city interior
+# window (scripts/worldmap/ui/worldmap_city_interior_controller.gd + worldmap_city_interior_layouts.gd) on the real
+# WorldMap.tscn in the 2D map view.
+# 1-3. layout data: 5 castles, counts, keys and paths, ay order, rect rules
+# 4-5. drawn nodes per castle and their canvas rect at k = 1 and at other window sizes (1 px)
+# 6. no-layout cities: gyeongju opens with the CH-2 placeholder, karakorum stays no_art
+# 7. coastal_only only for a coastal city (main's coastal check, read only); compare_only never drawn
+# 8. close button / Esc close the window and drop the drawn nodes
+
+const WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"
+const CONTROLLER_NODE := "WorldMapCityInteriorController"
+const LAYOUTS := preload("res://scripts/worldmap/ui/worldmap_city_interior_layouts.gd")
+const ASSETS := preload("res://scripts/worldmap/ui/worldmap_city_building_assets.gd")
+const EXPECTED_COUNTS := {"hanseong": [19, 11], "pyeongyang": [19, 9], "jianye": [20, 9], "edo": [21, 8], "kyoto": [26, 5]}
+const EXPECTED_DRAWN := {"hanseong": 30, "pyeongyang": 28, "jianye": 29, "edo": 29, "kyoto": 30}
+const KYOTO_COASTAL_KINDS := 7   # coastal_only items in the layout, the port among them
+const KYOTO_COASTAL_DRAWN := 6   # the port item is also compare_only (D4): the port stays a slot candidate of the trade port
+const NO_LAYOUT_CITY := "gyeongju"
+const NO_ART_CITY := "karakorum"
+const SCALE := 1.25
+
+var _checks := 0
+var _failures: Array[String] = []
+
+
+func _initialize() -> void:
+	call_deferred("_run")
+
+
+func _run() -> void:
+	_check_layout_data()
+	_expect(change_scene_to_file(WORLDMAP_SCENE_PATH) == OK, "WorldMap scene transition starts")
+	for i in 4:
+		await process_frame
+	var worldmap := current_scene
+	_expect(worldmap != null and worldmap.scene_file_path == WORLDMAP_SCENE_PATH, "WorldMap scene loaded")
+	if worldmap == null:
+		_finish()
+		return
+	var host := worldmap.get_node_or_null("WorldMap3DHost")
+	if host != null and bool(host.get("active")):
+		host.call("set_map_view_3d", false)
+		await process_frame
+	var ctl := worldmap.get_node_or_null(CONTROLLER_NODE)
+	_expect(ctl != null, "controller node exists")
+	if ctl == null:
+		_finish()
+		return
+	_expect(ctl.has_method("get_canvas") and ctl.has_method("apply_canvas_transform"), "controller draws castle layouts (CH-3 API)")
+	if not ctl.has_method("get_canvas"):
+		_finish()
+		return
+	var markers: Dictionary = worldmap.get("_city_markers_by_id")
+	var player_faction := str(worldmap.call("_get_current_player_faction_id"))
+
+	# 4-5, 7. each castle drawn from its layout
+	for city_id in EXPECTED_DRAWN:
+		_expect(markers.has(city_id), "marker exists: %s" % city_id)
+		if not markers.has(city_id):
+			continue
+		var owner_before := str(markers[city_id].get("owner_faction_id"))
+		markers[city_id].set("owner_faction_id", player_faction)
+		var opened := bool(ctl.call("try_open", city_id))
+		_expect(opened, "%s opens (reason %s)" % [city_id, str(ctl.get("last_reject_reason"))])
+		if opened:
+			await process_frame
+			_check_drawn_city(ctl, worldmap, city_id)
+		ctl.call("close")
+		markers[city_id].set("owner_faction_id", owner_before)
+
+	# retarget: an open castle switched to another one is redrawn for the new one only
+	var owners_before := {}
+	for city_id in ["hanseong", "edo"]:
+		owners_before[city_id] = str(markers[city_id].get("owner_faction_id"))
+		markers[city_id].set("owner_faction_id", player_faction)
+	ctl.call("try_open", "hanseong")
+	ctl.call("try_open", "edo")
+	var drawn: Array = ctl.call("get_drawn_items")
+	var canvas: Control = ctl.call("get_canvas")
+	_expect(str(ctl.call("get_open_city_id")) == "edo" and drawn.size() == EXPECTED_DRAWN.edo and canvas.get_child_count() == EXPECTED_DRAWN.edo + 1,
+		"retarget hanseong -> edo redraws edo only (%d items, %d nodes)" % [drawn.size(), canvas.get_child_count()])
+
+	# 8. close button and Esc drop the drawn nodes
+	(ctl.call("get_close_button") as Button).emit_signal("pressed")
+	_expect(not bool(ctl.call("is_open")) and canvas.get_child_count() == 0 and (ctl.call("get_drawn_items") as Array).is_empty(), "close button closes and frees the drawn nodes")
+	ctl.call("try_open", "edo")
+	await process_frame
+	root.push_input(_esc())
+	await process_frame
+	_expect(not bool(ctl.call("is_open")) and canvas.get_child_count() == 0, "Esc closes and frees the drawn nodes")
+	for city_id in owners_before:
+		markers[city_id].set("owner_faction_id", owners_before[city_id])
+
+	# 6. cities without a layout
+	_expect(not LAYOUTS.has_layout(NO_LAYOUT_CITY) and LAYOUTS.get_layout(NO_LAYOUT_CITY).is_empty(), "%s has no layout" % NO_LAYOUT_CITY)
+	var no_layout_owner := str(markers[NO_LAYOUT_CITY].get("owner_faction_id"))
+	markers[NO_LAYOUT_CITY].set("owner_faction_id", player_faction)
+	_expect(bool(ctl.call("try_open", NO_LAYOUT_CITY)), "%s opens" % NO_LAYOUT_CITY)
+	var placeholder: Label = ctl.call("get_placeholder")
+	_expect(placeholder.visible and not canvas.visible and canvas.get_child_count() == 0, "%s shows the CH-2 placeholder, no canvas" % NO_LAYOUT_CITY)
+	ctl.call("close")
+	markers[NO_LAYOUT_CITY].set("owner_faction_id", no_layout_owner)
+	var karakorum_owner := str(markers[NO_ART_CITY].get("owner_faction_id"))
+	markers[NO_ART_CITY].set("owner_faction_id", player_faction)
+	_expect(not bool(ctl.call("try_open", NO_ART_CITY)) and str(ctl.get("last_reject_reason")) == "no_art", "%s stays closed (no_art)" % NO_ART_CITY)
+	markers[NO_ART_CITY].set("owner_faction_id", karakorum_owner)
+	_finish()
+
+
+func _check_layout_data() -> void:
+	var file_text := FileAccess.get_file_as_string(LAYOUTS.LAYOUTS_PATH)
+	var parsed: Variant = JSON.parse_string(file_text)
+	_expect(parsed is Dictionary and (parsed as Dictionary).get("layouts") is Dictionary, "city_layouts.json parses")
+	if not (parsed is Dictionary):
+		return
+	var layouts: Dictionary = parsed["layouts"]
+	_expect(layouts.size() == 5 and EXPECTED_COUNTS.keys().all(func(c): return layouts.has(c)), "exactly the 5 castles %s" % str(layouts.keys()))
+	var keys := ASSETS.all_building_keys()
+	for city_id in EXPECTED_COUNTS:
+		var layout: Dictionary = LAYOUTS.get_layout(city_id)
+		var items: Array = layout.get("items", [])
+		var buildings := items.filter(func(i): return str(i.get("kind")) == "building").size()
+		var decorations := items.filter(func(i): return str(i.get("kind")) == "decoration").size()
+		_expect([buildings, decorations] == EXPECTED_COUNTS[city_id] and buildings + decorations == items.size(),
+			"%s counts %d+%d" % [city_id, buildings, decorations])
+		_expect(ResourceLoader.exists(str(layout.get("background", ""))), "%s background exists" % city_id)
+		var style := str(layout.get("region_style", ""))
+		var bad: Array[String] = []
+		var previous_ay := -INF
+		for item in items:
+			var key := str(item.get("building_key", ""))
+			if str(item.get("kind")) == "building":
+				if not keys.has(key):
+					bad.append("key %s" % key)
+				elif not ResourceLoader.exists(ASSETS.texture_path(key, style)):
+					bad.append("art %s_%s" % [key, style])
+			elif not ResourceLoader.exists(str(item.get("texture", ""))):
+				bad.append("deco %s" % str(item.get("texture", "")))
+			var ax := float(item.ax)
+			var ay := float(item.ay)
+			if ay < previous_ay:
+				bad.append("ay order z%d" % int(item.z))
+			previous_ay = ay
+			if ax != float(item.x) + float(item.w) * 0.5 or ay != float(item.y) + float(item.h):
+				bad.append("anchor z%d" % int(item.z))
+			if int(item.w) != roundi(float(item.src_w) * SCALE) or int(item.h) != roundi(float(item.src_h) * SCALE):
+				bad.append("size z%d" % int(item.z))
+		_expect(bad.is_empty(), "%s keys, paths, ay order and rect rules %s" % [city_id, str(bad)])
+	# items_for_city filters
+	var kyoto_all: Array = LAYOUTS.get_layout("kyoto").get("items", [])
+	var compare_only := kyoto_all.filter(func(i): return bool(i.get("compare_only", false))).size()
+	var coastal_only := kyoto_all.filter(func(i): return bool(i.get("coastal_only", false))).size()
+	_expect(compare_only == 1 and coastal_only == KYOTO_COASTAL_KINDS, "kyoto has 1 compare_only and %d coastal_only items" % KYOTO_COASTAL_KINDS)
+	var inland_kept := kyoto_all.filter(func(i): return not bool(i.get("compare_only", false)) and not bool(i.get("coastal_only", false))).size()
+	_expect(LAYOUTS.items_for_city("kyoto", true).size() == kyoto_all.size() - 1 and LAYOUTS.items_for_city("kyoto", false).size() == inland_kept,
+		"items_for_city drops compare_only always and coastal_only inland")
+	var t: Dictionary = LAYOUTS.canvas_transform(Vector2(960, 576))
+	_expect(is_equal_approx(float(t.k), 0.75) and (t.off as Vector2).is_equal_approx(Vector2.ZERO), "canvas_transform 960x576 -> k 0.75")
+
+
+func _check_drawn_city(ctl: Node, worldmap: Node, city_id: String) -> void:
+	var coastal := bool(worldmap.call("_is_city_coastal_for_city_tech", city_id))
+	_expect(coastal == (city_id == "kyoto"), "%s coastal (main) = %s" % [city_id, str(coastal)])
+	var canvas: Control = ctl.call("get_canvas")
+	var drawn: Array = ctl.call("get_drawn_items")
+	_expect(canvas.visible and not (ctl.call("get_placeholder") as Label).visible, "%s draws the canvas" % city_id)
+	_expect(drawn.size() == EXPECTED_DRAWN[city_id] and canvas.get_child_count() == drawn.size() + 1, "%s draws %d items (+ background), got %d / %d nodes" % [city_id, EXPECTED_DRAWN[city_id], drawn.size(), canvas.get_child_count()])
+	_expect(LAYOUTS.items_for_city(city_id, coastal) == drawn, "%s drawn in layout order" % city_id)
+	_expect(not drawn.any(func(i): return bool(i.get("compare_only", false))), "%s draws no compare_only item" % city_id)
+	var coastal_drawn := drawn.filter(func(i): return bool(i.get("coastal_only", false))).size()
+	_expect(coastal_drawn == (KYOTO_COASTAL_DRAWN if city_id == "kyoto" else 0), "%s draws %d coastal_only items" % [city_id, coastal_drawn])
+	if city_id == "kyoto":
+		# the 7 coastal kinds: 6 drawn items + the port as a slot candidate of the drawn trade port
+		var coastal_keys := {}
+		for item in drawn:
+			if bool(item.get("coastal_only", false)):
+				coastal_keys[str(item.building_key)] = true
+				for candidate in item.get("slot_candidates", []):
+					coastal_keys[str(candidate)] = true
+		_expect(coastal_keys.size() == KYOTO_COASTAL_KINDS and coastal_keys.has("commerce_port"), "kyoto: the %d coastal kinds are drawn or slotted %s" % [KYOTO_COASTAL_KINDS, str(coastal_keys.keys())])
+		_expect(drawn.filter(func(i): return str(i.get("kind")) == "building").size() == 25 and drawn.filter(func(i): return str(i.get("kind")) == "decoration").size() == 5, "kyoto: 25 buildings + 5 houses")
+	var background := canvas.get_child(0) as TextureRect
+	_expect(background != null and background.texture != null and background.size.is_equal_approx(Vector2(1280, 768)), "%s background 1280x768 at the bottom" % city_id)
+	for area in [Vector2(1280, 768), Vector2(960, 576), Vector2(1000, 768)]:
+		ctl.call("apply_canvas_transform", area)
+		var t: Dictionary = LAYOUTS.canvas_transform(area)
+		var k := float(t.k)
+		var off: Vector2 = t.off
+		var bad: Array[String] = []
+		for index in drawn.size():
+			var node := canvas.get_child(index + 1) as TextureRect
+			var item: Dictionary = drawn[index]
+			if node == null or node.get_meta("layout_item", {}) != item or node.texture == null or node.mouse_filter != Control.MOUSE_FILTER_IGNORE:
+				bad.append("node %d" % index)
+				continue
+			var want_top_left := off + Vector2(float(item.ax) - float(item.w) * 0.5, float(item.ay) - float(item.h)) * k
+			var want_size := Vector2(float(item.w), float(item.h)) * k
+			var got_top_left := canvas.position + node.position * canvas.scale
+			var got_size := node.size * canvas.scale
+			if got_top_left.distance_to(want_top_left) > 1.0 or (got_size - want_size).abs().x > 1.0 or (got_size - want_size).abs().y > 1.0:
+				bad.append("z%d %s vs %s" % [int(item.z), str(got_top_left), str(want_top_left)])
+		_expect(bad.is_empty(), "%s rects within 1 px at area %s (k %.4f) %s" % [city_id, str(area), k, str(bad.slice(0, 3))])
+
+
+func _esc() -> InputEventKey:
+	var event := InputEventKey.new()
+	event.pressed = true
+	event.keycode = KEY_ESCAPE
+	return event
+
+
+func _expect(condition: bool, label: String) -> void:
+	_checks += 1
+	if not condition:
+		_failures.append(label)
+		push_error("[CITY_INTERIOR_LAYOUT_FAIL] %s" % label)
+
+
+func _finish() -> void:
+	print("[CITY_INTERIOR_LAYOUT] checks=%d failures=%s" % [_checks, str(_failures)])
+	quit(0 if _failures.is_empty() else 1)
diff --git a/tests/scripts/test_worldmap_city_interior_layouts.gd.uid b/tests/scripts/test_worldmap_city_interior_layouts.gd.uid
new file mode 100644
index 0000000..9c7aea0
--- /dev/null
+++ b/tests/scripts/test_worldmap_city_interior_layouts.gd.uid
@@ -0,0 +1 @@
+uid://o8gx4n0etdop
```

## 8. 종료 루틴
1. 코드 커밋 `328ee04`·`a63e137` push, 원격 = 로컬.
2. 압축 푼 폴더 `C:\eastwar_tmp\ch3_extract\`는 삭제 예정(삭제는 김작 승인 후, 지금은 남겨 둠). zip 원본 `C:\eastwar_tmp\EASTWAR_CityHUD_CH3_20261105.zip`은 그대로.
3. 보고서 커밋 `[skip ci]`, 이 가지에만.
4. 정본 가지·`main`·`PROGRESS_WM3D.md` 손대지 않음, `worldmap_main.gd`·`worldmap3d/` 0줄.
5. 김작 F6(CH-4 뒤): 5성이 참고 그림처럼 보이는지, 다른 도시는 안내 글인지, 닫으면 월드맵으로 돌아오는지.
