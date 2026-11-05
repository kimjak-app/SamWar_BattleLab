기준 화면: 없음(보이는 화면 변화 0). 읽기 전용 감사이며 코드·테스트·워크플로·씬·에셋을 고치지 않았다. 대상은 `feature/wm3d-intake-20261101` HEAD `55314eb`(코드는 `cbe28c0`과 같음)에서 "3D 월드맵 성 클릭 → 고정 시점 2.5D 성 안 건물 허드창" 구현 가능성이다.
합격 기준: 김작이 이 보고서만 읽고 "어떤 단계로 몇 개 파일을 고쳐 성 안 허드창을 넣을지" 판단할 수 있다(F6 없음). 확인 못 한 것은 [미확인]으로 적었다.

# REPORT — AUDIT-CITYHUD: 성 안 건물 2.5D 허드창 (읽기 전용 감사, 2026-11-05)

## 3줄 요약
1. **가능성: 가능[추정], `worldmap_main.gd` 수정 0줄로 할 수 있다.**
   - 도시 클릭은 2D와 3D 모두 마커의 `city_selected` 신호를 거친다(`scripts/worldmap/map3d/worldmap_3d_adapter.gd:93-100`). 새 노드도 이 신호를 받을 수 있다.
   - 테크 완료 데이터는 main의 공개 래퍼 `_get_completed_city_domestic_tech_snapshot_mvp(city_id)`(`worldmap_main.gd:8742`)로 읽는다. 기존 배지 UI가 이미 이렇게 읽는다(`worldmap_tech_badge_summary_controller.gd:156-163`).
   - 건물 30종 중 테크가 있는 25종의 id는 **카탈로그와 25/25 일치**한다.
2. **가장 큰 장애:**
   - ① "성 아이콘 클릭"이 지금은 따로 없다. 3D 선택은 **도시 영역 아무 데나** 누르면 된다(`worldmap3d/scripts/worldmap3d_root.gd:602-606`). 그래서 클릭마다 창을 열면 공격 대상 고르기 같은 기존 선택 흐름을 가린다. **여는 방법을 정해야 한다.**
   - ② 에셋 90장(+`.import` 90개)을 둘 기존 폴더가 마땅하지 않다. 새 폴더 `assets/worldmap/city_buildings/`는 승인이 필요하다.
   - ③ 성 안 슬롯 좌표 데이터가 아직 없다. 계획서 §6의 그림 배치는 글자 그림이라 좌표가 아니다.
3. **김작이 정할 것:** 아래 "정해야 할 질문" Q1~Q8. 특히 Q1 창 여는 방법, Q2 에셋 폴더, Q4 카라코룸(몽골) 그림.

## 택한 해석
- **생활 5종(관청·창고·대장간·학당·사찰):** 김작 결정 두 개("새 테크와 연동", "기본건물이면 일단 포함")를 합친 클코치 해석을 그대로 따랐다. **새 테크가 생기기 전까지 모든 도시에 기본 건물로 표시**하고, 새 테크 id가 생기면 표시 조건만 바꾼다.
  - 코드 영향[추정]: 건물 표에 `required_tech_id`를 두고, 생활 5종은 빈 값("" = 항상 표시)으로 둔다. 새 테크가 생기면 그 칸에 id를 넣는다. 파일명 `bld_life_<영문>_<지역>.png`는 바뀌지 않으므로 **그림·로드 코드는 그대로**다.
  - 새 테크의 이름·티어·턴·비용·선행은 이 감사에서 정하지 않았다(김작·채코치 영역). 필요한 항목만 Q7에 올렸다.
- **시장 3단계:** 같은 슬롯에서 **완료된 가장 높은 단계 하나만** 그린다(김작 확정). 카탈로그도 노점 → 상설 → 대형의 선행 사슬이라(`domestic_tech_catalog.gd:54-56`) 높은 단계가 완료되면 낮은 단계도 반드시 완료돼 있다[사실].
- **상업 "창고"와 생활 "창고"의 동일 여부:** 추정하지 않았다. 사실만 적고 Q5로 남겼다.
- **"성 아이콘 클릭"의 범위:** 지금 코드에는 성 아이콘만 골라 누르는 경로가 없다. 그래서 판정은 "도시 선택 신호로 창을 여는 것"을 기준으로 했다. 아이콘만 골라 누르게 하려면 `worldmap3d/` 수정이 필요하다(1-1).
- 그림 원본은 김작 PC의 `C:\Users\seong\Desktop\EASTWAR_CityBuildings_Plan_20261102\`(압축 푼 폴더)와 같은 이름의 `.zip`(200,966,129 바이트)에 있다. **레포에 복사하지 않았다.** 확인만 했다.
  - `phase2_buildings/manifest.csv`의 game 90행 중 87장은 같은 폴더에서 md5가 일치했다.
  - 관청 3장은 manifest 경로가 `anchors/…`인데 폴더 맨 위에 있었고, md5는 3장 모두 일치했다. → **90/90 일치**[사실].
- 조사 일부(테크 데이터·도시·에셋 규칙 목록)는 하위 에이전트에 맡겼다. 결론에 쓴 줄은 클코드가 직접 다시 열어 확인했다(`worldmap_main.gd:607·916·8742·10337-10340`, 카탈로그 `:39-91` 53개와 25개 id 존재, 배지 컨트롤러 `:156-163`, `worldmap_city_marker.gd:25`, `WORLDMAP_RULES.md:230`, `CONFIRMED_techtree_design.md:164-165`).

## 1. 조사 결과

### 1-1. 성(도시) 클릭 경로
| 단계 | 위치 | 라벨 |
|---|---|---|
| 3D 클릭 | 카메라 `select_requested` → `worldmap3d_root.gd:602 _on_select` → 화면 좌표를 지면으로 바꾸고 **지역 id(region) → 도시 id**로 찾음 → `city_selected.emit(cid, r)`(`:606`). 성 모양 마커(절차형 자리표시, `:14·51`)를 맞혔는지는 보지 않음 | [사실] |
| 3D → 게임 | 어댑터 `_on_root_city_selected`(`worldmap_3d_adapter.gd:93-100`)가 빈 id를 무시하고 `city_pick_forwarded` 신호(`:8`)를 낸 뒤 2D 마커의 `city_selected.emit(marker)`를 대신 부름 | [사실] |
| 2D 클릭 | 마커 `city_selected.emit(self)`(`scripts/worldmap_city_marker.gd:199-200`) | [사실] |
| main 처리 | `_connect_city_markers`(`worldmap_main.gd:1395-1402`) → `_on_city_marker_selected`(`:1405-1428`): 선택 표시, `selected_city_id`, `city_info_panel.show_city(marker)`, 통합 패널 갱신 | [사실] |
| 지금 열리는 패널 | `$WorldMapUI/CityInfoPanel`(`scripts/worldmap_city_info_panel.gd`, `WorldMap.tscn:1877`)과 `$WorldMapUI/CityDetailPanel`(`WorldMap.tscn:1736`). 지시서가 예로 든 `WorldMapCityPanel.tscn`(레포 루트)은 스크립트 없는 빈 Control이고 `WorldMap_UI_Test.tscn`에서만 씀 | [사실] |

- **새 허드창 자리 제안[추정]:** 기존 패널 안이 아니라 **별도 창**으로 둔다. 배지 컨트롤러처럼 `WorldMap` 루트 직속 Node(`WorldMap.tscn:251` 선례)가 코드로 자기 `CanvasLayer`를 만든다. 성 안 그림은 192~256 px 건물 여러 채가 들어가는 넓은 화면이라, 왼쪽 도시 패널 안에는 들어가지 않는다.
- **여는 방법(Q1):** 아래 셋 중 김작이 고른다.
  - (a) 도시 선택마다 자동으로 열기: 공격 대상 고르기 등과 충돌하므로 비추천.
  - (b) 선택된 도시에 "성 안 보기" 버튼: 추천. 버튼을 새 창 노드가 자기 층에 직접 만들면 main·`CityInfoPanel` 수정이 0이다.
  - (c) 같은 도시 두 번 클릭.
  - "아이콘 자체를 눌러야 열림"을 원하면 3D 루트에 마커 판정을 추가해야 한다(`worldmap3d/scripts/worldmap3d_root.gd` 수정). 2D는 마커 노드 자체를 누르는 방식이다(`worldmap_city_marker.gd:199-200`).

### 1-2. 테크 완료 데이터
| 항목 | 위치 | 라벨 |
|---|---|---|
| 기본값 | `worldmap_main.gd:916` `"city_domestic_tech_completed": {}` | [사실] |
| 쓰기 | 연구 서비스 `domestic_tech_research_service.gd:443-464`(완료 시 `:452`), 정규화 `:466-478`. 도시 상태 사본 `city_tech["completed"]` `:455-457·481-488` | [사실] |
| 읽기 API | 서비스 `get_city_completed_snapshot(city_id)`, `is_city_completed(city_id, tech_id)`(`:154-166`). main 래퍼 `_get_completed_city_domestic_tech_snapshot_mvp`(`:8742`), `_is_city_domestic_tech_completed_mvp`(`:8072`) | [사실] |
| main 밖에서 읽기 | 배지 컨트롤러가 `world_map.call("_get_completed_city_domestic_tech_snapshot_mvp", city_id)`로 읽음(`worldmap_tech_badge_summary_controller.gd:156-163`), 도시는 `world_map.get("selected_city_id")`. **같은 방식으로 main 수정 없이 읽을 수 있다** | [사실] |
| 저장 | `_serialize_worldmap_state`가 `_player_state` 전체를 `player_state`로 저장·복원(`:12729-12753`). 건물 표시용으로 따로 저장할 것은 없다 | [사실] |
| 완료 신호 | **전용 신호 없음.** main의 signal은 2개뿐이고 연구 완료용이 아니다(`:3-4`). 완료는 이벤트 배열로 돌아와 연출 대기열에 들어가고(`:9729-9737`), 배지 갱신은 main이 노드 이름으로 `refresh_from_runtime`을 부른다(`:9630-9633`). 연출 쪽 신호는 `presentation_completed`·`presentation_queue_empty`(`domestic_tech_completion_presentation_controller.gd:4-5`) | [사실] |

- 갱신 방법 제안[추정]: **창을 열 때마다 스냅샷을 다시 읽는다.** 창이 열린 동안은 턴이 진행되지 않게(모달) 하면 그것으로 충분하다. main 수정이 필요 없다.
- "완료 연출과 동시에 성 안 그림이 켜지는 장면"을 원하면 연출 컨트롤러의 `presentation_completed` 신호에 연결하는 방법이 있다. 그 노드를 찾는 경로는 [미확인]이다.

### 1-3. 건물 ↔ 테크 id 대조 (카탈로그 `domestic_tech_catalog.gd:39-91`, 도시 테크 53개 확인)
| # | 건물 | 파일명(×kr/cn/jp) | 테크 id | 카탈로그 | 비고 |
|---|---|---|---|---|---|
| 1 | 노점시장 | `bld_commerce_street_market_*` | `commerce_street_market` | 있음 `:54` | 시장 1단계 |
| 2 | 상설시장 | `bld_commerce_permanent_market_*` | `commerce_permanent_market` | 있음 `:55` | 선행 노점시장 |
| 3 | 대형시장 | `bld_commerce_grand_market_*` | `commerce_grand_market` | 있음 `:56` | 선행 상설시장 |
| 4 | 대상단 | `bld_commerce_merchant_guild_*` | `commerce_merchant_guild` | 있음 `:57` | 대형시장 + 국가 테크 |
| 5 | 조폐소 | `bld_commerce_mint_*` | `commerce_mint` | 있음 `:58` | 대형시장 + 국가 화폐 통일 |
| 6 | 병영 | `bld_mil_barracks_*` | `mil_barracks` | 있음 `:63` | 코드 이름 "병영 설치" |
| 7 | 성벽 강화 | `bld_mil_wall_upgrade_*` | `mil_wall_upgrade` | 있음 `:82` | 오버레이 |
| 8 | 철문 | `bld_mil_iron_gate_*` | `mil_iron_gate` | 있음 `:88` | 코드 이름 "철문 설치" |
| 9 | 망루 | `bld_mil_watchtower_*` | `mil_watchtower` | 있음 `:85` | |
| 10 | 봉화대 | `bld_mil_beacon_*` | `mil_beacon` | 있음 `:86` | |
| 11 | 철옹성 | `bld_mil_iron_fortress_*` | `mil_iron_fortress` | 있음 `:89` | 오버레이 |
| 12 | 해자 | `bld_mil_moat_*` | `mil_moat` | 있음 `:83` | 띠 |
| 13 | 이중 해자 | `bld_mil_double_moat_*` | `mil_double_moat` | 있음 `:84` | 띠 |
| 14 | 관개수로 | `bld_agri_irrigation_*` | `agri_irrigation` | 있음 `:40` | |
| 15 | 저수지 | `bld_agri_reservoir_*` | `agri_reservoir` | 있음 `:43` | |
| 16 | 곡창지대 | `bld_agri_granary_zone_*` | `agri_granary_zone` | 있음 `:42` | |
| 17 | 목초지 | `bld_agri_pasture_*` | `agri_pasture` | 있음 `:44` | |
| 18 | 목장 | `bld_agri_ranch_*` | `agri_ranch` | 있음 `:45` | 선행 목초지 |
| 19 | 어촌 | `bld_fish_village_*` | `fish_village` | 있음 `:47` | 해안 전용, 코드 이름 "어촌 형성" |
| 20 | 염전 | `bld_fish_salt_field_*` | `fish_salt_field` | 있음 `:52` | 해안 전용 |
| 21 | 소금창고 | `bld_fish_salt_warehouse_*` | `fish_salt_warehouse` | 있음 `:53` | 해안 전용 |
| 22 | 건어물 보급기지 | `bld_fish_dried_supply_base_*` | `fish_dried_supply_base` | 있음 `:51` | 해안 전용 |
| 23 | 항구 | `bld_commerce_port_*` | `commerce_port` | 있음 `:59` | 해안 전용 |
| 24 | 조선소 | `bld_commerce_shipyard_*` | `commerce_shipyard` | 있음 `:60` | 해안, 선행 항구 |
| 25 | 무역항 | `bld_commerce_trade_port_*` | `commerce_trade_port` | 있음 `:61` | 해안, 선행 **조선소**(항구 → 조선소 → 무역항) |
| 26 | 관청 | `bld_life_office_*` | (없음) | 없음 | 생활, 임시 기본 표시 |
| 27 | 창고 | `bld_life_storehouse_*` | (없음) | 없음 | 생활, 임시 기본 표시. Q5 |
| 28 | 대장간 | `bld_life_smithy_*` | (없음) | 없음 | 생활, 임시 기본 표시 |
| 29 | 학당 | `bld_life_academy_*` | (없음) | 없음 | 생활, 임시 기본 표시 |
| 30 | 사찰 | `bld_life_temple_*` | (없음) | 없음 | 생활, 임시 기본 표시 |

- **일치 25 / 없음 5(생활)**[사실]. 이름이 다른 id 0개, 철자가 틀린 id 0개.
- **"창고":** 카탈로그에는 일반 "창고"가 없고, 이름에 창고가 들어가는 것은 `fish_salt_warehouse`(소금창고, `:53`)뿐이다[사실]. 기획서 `agent/CONFIRMED_techtree_design.md:164`에 상업 테크 "창고"(`:165` "조건: 대형시장 완료 + 목재 보유")가 있고, `:168-169` 대형창고, `:225` 효과 "자원 보관량 +20%"가 있다. 즉 **기획에는 있고 카탈로그에는 없다**[사실]. 생활 "창고"와 같은 것인지는 Q5다.
- 생활 5종의 현재 데이터상 근거: 카탈로그·도시 데이터 어디에도 이 5종을 가리키는 id나 키는 없다[사실]. 근거는 록코치 계획서뿐이다.

### 1-4. 도시 데이터
- 출처: `const CITY_HUD_DATA`(`worldmap_main.gd:597-610`, 13곳)[사실]. 지시서는 이 줄을 "해안 건물 조건"으로 적었지만 **실제로는 도시 데이터 표 자체**다. 해안 판정은 `_is_city_coastal_for_city_tech`(`:10337-10340`)가 한다. `type` 문자열에 `coastal`·`port`·`maritime`이 들어 있으면 해안이다[사실].

| 지역(그림) | 도시(id, type) |
|---|---|
| kr | 한성 `hanseong` commercial_capital, 평양 `pyeongyang` production_city, 경주 `gyeongju` commercial_capital, 사비 `sabi` river_trade_city |
| cn | 낙양 `luoyang` commercial_capital, 업성 `yecheng` military_fortress, 성도 `chengdu` production_city, 건업 `jianye` river_trade_city |
| jp | 교토 `kyoto` **coastal_trade_city**, 오사카 `osaka` commercial_capital, 큐슈 `kyushu` **coastal_trade_city**, 에도 `edo` military_fortress |
| (몽골, 그림 없음) | 카라코룸 `karakorum` military_fortress, `northern_steppe`, `mongol_faction` |

- **해안 도시는 교토(`:607`)와 큐슈(`:609`) 2곳뿐**이다[사실]. 3D 데이터 `worldmap3d/maps/eastasia/rule_data_eastasia.json:184·204`도 같다. 저장된 도시 상태가 실행 중에 우선하지만(`:12852-12857`), type을 바꾸는 코드는 찾지 못했다[미확인]. 오사카는 이름과 달리 해안이 아니다(commercial_capital).
- 지역 판정: 지금 코드에서 지역 스타일을 고르는 곳은 성 아이콘 선택(`scripts/worldmap_city_marker.gd:166-186 _get_castle_icon_texture`) 하나다[사실].
  - city_id를 직접 매칭하고(`:167-175`), 없으면 `region_id`로 고른다. 몽골은 `northern_steppe` 또는 `mongol_faction`이면 ordo, 그 밖의 기본값은 china다.
  - 성 아이콘 표시는 꺼져 있다(`:25 CASTLE_ICON_VISUALS_ENABLED := false`).
  - 이 함수는 마커의 내부 함수다. 허드창은 `region_key`(`korean_peninsula`/`china_mainland`/`japanese_archipelago`/`northern_steppe`) → `kr/cn/jp` 표를 자기 쪽에 두는 편이 안전하다[추정].
- **카라코룸(몽골):** 그림 3지역(kr/cn/jp)에 몽골이 없다. 어디에 매핑할지 [미확인] → Q4.
- 평양 고구려 스타일은 계획서 결정대로 kr 세트를 쓴다(계획서 §6-2).

### 1-5. 에셋 반입 형태
- 규칙[사실]
  - `agent/WORLDMAP_RULES.md:230`: `assets/ui/tech_icons/**`·`assets/ui/tech_icons_ui64/`와 **"any `.import` file"**의 수정·이동·삭제·재생성·reimport를 금지한다.
  - `:231`: 그 작업 차수에는 assets·`.import` 변경 허가가 없다.
  - `:336-338`: UI64 아이콘 선택 순서는 고정이다.
  - **새 파일 추가 자체를 막는 문구는 없다.** 다만 "any `.import`" 문구가 새 `.import` 생성까지 포함하는지는 해석이 갈린다 → 반입 지시서에서 명시 허가를 권한다[추정].
- `.import`는 PNG와 함께 커밋한다(레포의 `assets/**/*.png.import` 587개 추적, `.gitignore`는 `.godot/`·`.import/`만 제외)[사실]. **90장 반입 = PNG 90 + `.import` 90 = 180 파일**이다.
- 가져오기 설정: `project.godot`에 importer 기본값이 없다. 기존 `.import`는 583/587이 `compress/mode=0`(무손실), 582/587이 `mipmaps/generate=false`다[사실]. 같은 값을 쓰면 된다. 2D UI 그림이라 밉맵은 필요 없다[추정].
- 폴더[사실]: `assets/worldmap/city_buildings/` 같은 폴더는 없다. `assets/` 안에 `.gdignore`도 없다.
- 반입 위치 후보[추정]:

| 후보 | 장점 | 단점 |
|---|---|---|
| ① 새 폴더 `assets/worldmap/city_buildings/` | 180 파일이 따로 모임, 경로 조합이 단순 | **새 폴더**(이번 큐 6절 규칙상 허가 필요) |
| ② 기존 `assets/worldmap/ui/` | 새 폴더 없음 | 월드맵 HUD 그림 7장(14 파일)에 180 파일이 섞임 |
| ③ 기존 `assets/worldmap/city_icons/` | 도시 그림 성격 | 성 4장 폴더에 180 파일이 섞임 |

  - 클코드 추천은 ①이다. 단 김작 허가가 필요하다(Q2).
- 로드 방법[추정]: 경로 `"res://<폴더>/bld_%s_%s.png" % [이름, 지역]`을 만들고 `ResourceLoader.exists`로 확인한 뒤 `load`한다. 없으면 그 슬롯을 비운다(오류 없이). 생활 5종은 이름이 `life_<영문>`이다.
- 모바일: 2D 그림이라 모바일 제외 대상이 아니다[추정]. 내보내기 프리셋이 아직 없다(`docs/WORLDMAP3D_EXPORT_NOTES.md` 1절). 용량은 파일 합계 2,626,681 바이트(manifest game 90행 합계, 클코드 계산)로 레포 `assets/`(1.3 GB) 대비 작다.

### 1-6. 허드창 구현 위치와 입력
- 스크립트 폴더[추정]: 기존 `scripts/worldmap/ui/`(월드맵 UI 컨트롤러들이 있는 곳)가 맞다. 씬 없이 코드로 만들면 새 `.tscn`도 필요 없다(08 설정 화면과 같은 방식). 3D 전용이 아니므로 `scripts/worldmap/map3d/`는 맞지 않다. 2D 월드맵에서도 같은 창이 열려야 하기 때문이다.
- 층 순서[사실]

| 층 | 값 |
|---|---|
| 3D 레이어 | -10(`worldmap_3d_adapter.gd:11`) |
| `WorldMapUI` | 1(기본, `WorldMap.tscn:1288`) |
| 도시 행동 | 35(`worldmap_city_action_controller.gd:48`) |
| `TopNavCanvas` | 40(`WorldMap.tscn:260-261`) |
| 테크트리 | 60(`domestic_tech_tree_presentation_controller.gd:27`) |
| 완료 연출 | 80(`domestic_tech_completion_presentation_controller.gd:139`) |

  - 허드창은 **45~55**가 맞다[추정]: 상단 메뉴(40)보다 위, 테크트리(60)·완료 연출(80)보다 아래.
- 3D 입력 차단[사실+추정]
  - 3D 카메라는 `external_input` 모드다. main의 `_unhandled_input`(`worldmap_main.gd:1124`)이 카메라 컨트롤러로 넘겨줄 때만 움직인다. 창의 배경 Control이 `MOUSE_FILTER_STOP`이면 마우스·휠이 `_unhandled_input`까지 가지 않으므로 3D 카메라가 움직이지 않는다[추정, Godot GUI 입력 순서].
  - 키보드(WASD/QE)는 3D 컨트롤러의 `input_blocked`(`worldmap_3d_camera_controller.gd:12·139`)로 막는다. 이 변수는 있지만 **지금 아무도 켜지 않는다**(테스트 `test_worldmap3d_camera_controller.gd:88-92`만 사용)[사실]. 허드창이 호스트(그룹 `HOST_GROUP`)를 통해 컨트롤러를 찾아 켜고 끄면 된다[추정].
  - 2D 컨트롤러에는 이런 변수가 없다(포커스된 LineEdit/TextEdit만 검사, `scripts/worldmap/camera/worldmap_camera_controller.gd:238-247`)[사실]. 2D에서 WASD를 막으려면 별도 방법이 필요하다(창이 키 입력을 `set_input_as_handled`로 먹기 등)[추정].
  - `SubViewportContainer`는 `MOUSE_FILTER_IGNORE`라(`adapter:40`) 허드창과 겹쳐도 클릭을 뺏지 않는다[사실].

### 1-7. `worldmap_main.gd` 수정 필요 여부
- **0줄로 가능[추정].**
  - 열기: 새 노드가 마커들의 `city_selected` 신호에 연결하거나(2D·3D 공통), 3D만이면 어댑터 `city_pick_forwarded`에 연결한다. `selected_city_id`는 `main.get()`으로 읽는다.
  - 데이터: `main.call("_get_completed_city_domestic_tech_snapshot_mvp", id)`와 `CITY_HUD_DATA`(`main.get_script().get_script_constant_map()`, 07에서 쓴 방식)로 읽는다.
  - 붙이기: `WorldMap.tscn`에 노드 1개를 추가하거나(08 호스트와 같은 방식), 호스트가 런타임에 만든다.
- 핀 재고정 영향 0. M7·2-E와 묶을 필요가 없다.
- 단 다음 경우에는 main 수정이 필요해진다[추정]:
  - (a) 창이 열린 동안 턴 종료·전투 진입을 main 쪽에서 막아야 할 때(창이 모달이면 불필요)
  - (b) 테크 완료 순간에 main이 창을 직접 갱신하게 하고 싶을 때(`:9630` 배지와 같은 방식)

### 1-8. 성 안 배치(슬롯) 데이터
- 필요한 항목[추정]
  - 도시별 슬롯 목록. 슬롯마다:
    - `slot_id`, `zone`(상업/군사/성곽/생활/들판/해안)
    - 화면 좌표 `pos`(창 캔버스 px, **그림 하단 중앙 = 슬롯 점**. 그림이 RGBA 투명, 하단 중앙 정렬로 만들어짐, README)
    - 그리는 순서(y 정렬 또는 `z`)
    - `candidates`(같은 자리에서 높은 단계가 이기는 목록. 예: 시장 `[grand, permanent, street]`, 항구 자리 `[trade_port, port]`는 Q3 결과에 따름)
    - `coastal_only`
  - 성벽 강화·해자·이중 해자·철옹성은 점이 아니라 **둘레 띠·덮개**라서, 슬롯 대신 "경로(점 목록) + 조각 반복" 또는 "전체 덮개 좌표"가 필요하다.
  - 도시 공통 배경(성 바닥·기본 성벽)도 필요하다. 그림 목록에 없다 → Q6.
- 슬롯 수 추정[추정, 계획서 §6 글자 배치에서 셈]
  - 성 안 점 슬롯: 관청·시장·병영·대상단·조폐소·학당·사찰·창고·대장간·철문 각 1, 망루 2~3, 봉화대 1 = 약 13~14
  - 들판 5
  - 띠·덮개 4(성벽 강화·철옹성·해자·이중 해자)
  - → **비해안 도시 약 22~23개, 교토(해안 시연) 약 28개**(해안 6자리: 어촌·염전·소금창고·건어물·항구/무역항·조선소)
  - 샘플 4성 + 교토 = 5도시 → 약 115개 좌표
  - 이 좌표는 그림을 실제로 놓아 봐야 정해진다. 계획서 §7의 4단계("합성 미리보기 + 슬롯 좌표표", 록코치)가 아직이다[사실, 계획서]. **좌표표가 반입 전에 필요하다.**
- 13개 도시 전부를 하려면 도시별 배치가 13벌 필요하다. 지역별 공통 배치 3벌(kr/cn/jp)로 시작하는 방법도 있다(Q8).

### 1-9. 성능·메모리
- 파일 합계 2,626,681 바이트(90장)[사실].
- 픽셀 합계 2,076,672 px(manifest 크기에서 계산). 무손실(`compress/mode=0`)로 가져오면 GPU에 RGBA8로 올라가므로 **90장 전부 약 7.9 MB**, 밉맵을 켜면 약 10.6 MB다[추정, 계산].
- 한 도시의 창에는 한 지역 세트(최대 30장)만 쓰므로 **약 2.6 MB**다[추정].
- 창이 열릴 때 그 지역 그림만 `load`하고, 닫을 때 참조를 놓으면 상시 비용은 0에 가깝다[추정]. 3D 월드맵 VRAM(06~08)에 비하면 작다.
- 측정: 07 메모리 프로브 `WorldMap3DMemProbe.shared().sample("city_hud_open")`을 창이 열릴 때 부르면 `wm3d_mem_log.csv`에 한 줄이 남는다(같은 열 형식)[사실, 08 프로브 API]. 코드 1~2줄이다.

### 1-10. 약한 에셋 8개(README_KO "약한 항목")
- 모두 **표현 품질 문제**다(지역 간 비슷함, 크기, 색, 덤불, 가짜 글자)[사실, README]. 파일 누락이나 크기 규격 위반은 없다(manifest 크기와 md5 90/90 일치). → **반입을 막는 항목이 아니라 후속 교체 후보**다[추정].
- 교체할 때 **파일명과 캔버스 크기를 유지하면 코드 변경은 0**이다.
  - `.import` 파일은 경로·uid·설정만 담으므로 그림만 바뀌면 내용이 그대로일 것으로 본다[추정]. 다만 Godot가 다시 가져올 때 `.import`를 다시 쓰는지는 실험 필요 [미확인].
  - 캔버스 크기를 바꾸면 슬롯 앵커가 하단 중앙이라 위치는 유지되지만, 겹침은 다시 봐야 한다.

## 2. 판정표
| 질문 | 판정 | 근거 |
|---|---|---|
| 성 클릭 → 새 창을 main 수정 없이 열 수 있나 | **가능[추정]**(도시 선택 기준). "아이콘만 눌러야 열림"은 `worldmap3d/` 수정 필요 | 어댑터 `:93-100`, main `:1395-1428`, 3D 지역 판정 `worldmap3d_root.gd:602-606` |
| 테크 완료 데이터를 main 밖에서 읽을 수 있나 | **가능[사실]** | 배지 컨트롤러 `:156-163`이 이미 `_get_completed_city_domestic_tech_snapshot_mvp`(`main:8742`)로 읽음 |
| 건물 30종의 테크 id가 카탈로그와 일치하나 | **일치 25 / 없음 5(생활)**, 불일치 0 | 카탈로그 `:39-91`(53개) 대조, 1-3 표 |
| 에셋 90장을 지금 규칙대로 반입할 수 있나 | **부분** | 새 파일 금지 문구는 없지만 `.import` 문구 해석과 새 폴더 허가가 필요(`WORLDMAP_RULES.md:230-231`, 큐 6절). 기존 폴더 ②③이면 새 폴더 없이 가능 |
| 김작이 정해야 할 질문 | 아래 Q1~Q8 | |

### 정해야 할 질문 (추정으로 정하지 않음)
- **Q1** 창 여는 방법: (a) 도시 선택마다 자동 / (b) "성 안 보기" 버튼(클코드 추천, main 0줄) / (c) 두 번 클릭 / (d) 3D 성 아이콘 자체 클릭(`worldmap3d/` 수정).
- **Q2** 에셋 폴더: 새 폴더 `assets/worldmap/city_buildings/` 허가 여부(클코드 추천), 아니면 기존 `assets/worldmap/ui/`. 그리고 새 `.import` 90개 생성 허가(`WORLDMAP_RULES.md:230` "any `.import`" 해석).
- **Q3** 항구 → 무역항도 같은 자리 교체인지(시장과 같은 방식이면 교체 제안, 확정 아님). 참고로 카탈로그 사슬은 항구 → 조선소 → 무역항이다.
- **Q4** 카라코룸(몽골)은 kr/cn/jp 중 어느 세트를 쓰는지, 아니면 창을 열지 않을지.
- **Q5** 상업 테크 "창고"(기획서 `:164`, 카탈로그에 없음)와 생활 "창고"가 같은 것인지.
- **Q6** 천수각 같은 성 기본 건물과 성 바닥·기본 성벽 배경: 별도 그림을 만들지, 철옹성 덮개나 배경 그림에 포함할지. 그리고 빛 방향(좌상단 가정)과 "어두운 모퉁이" 위치.
- **Q7** 생활 5종에 붙일 새 테크(이름·티어·턴·비용·선행)를 언제 정할지. 이 감사는 목록만 올린다: 관청·창고·대장간·학당·사찰 각 1개, 또는 일부만.
- **Q8** 배치 범위: 샘플 4성 + 교토만 할지, 13개 도시 전부 할지, 지역별 공통 배치 3벌로 할지. 그리고 슬롯 좌표표(계획서 §7의 4단계)를 누가 언제 만드는지.

## 3. 단계 분해안 (제안만, 적용 금지)
| 단계 | 내용 | 예상 수정 경로 | 위험 | 김작 F6 |
|---|---|---|---|---|
| **CH-1 에셋 반입** | PNG 90 + `.import` 90, 로드 헬퍼(경로 조합 + `exists` 폴백), 반입 확인 테스트(90장 로드·크기) | `assets/worldmap/city_buildings/`(Q2) 180 파일, `scripts/worldmap/ui/` 헬퍼 1개, `tests/scripts/` 테스트 1개 | 낮음. `.import` 규칙 해석 | 없음(자동 확인) |
| **CH-2 창 틀과 클릭 연결** | 빈 성 안 창(층 45~55, 모달, 닫기·Esc), Q1 방식으로 열기, 3D 키 입력 차단(`input_blocked`), 2D 키 차단 | `scripts/worldmap/ui/` 새 스크립트 1개, `WorldMap.tscn` 노드 1개(또는 호스트가 생성), 테스트 1개 | 중간. 입력 가로채기·기존 선택 흐름 | 3D·2D에서 열고 닫기, 열린 동안 카메라 안 움직임 |
| **CH-3 슬롯 데이터와 샘플 성** | 지역 판정 표, 슬롯 데이터(JSON 또는 상수), 샘플 4성 배치 | 데이터 파일 1개(위치 Q2·Q8), CH-2 스크립트 | 중간. 좌표표 선행 필요(Q8), 겹침 | 한성·평양·건업·에도 화면 |
| **CH-4 테크 완료 → 켜기** | 스냅샷으로 표시, 시장 단계 교체, 생활 5종 임시 기본 표시, 열 때마다 갱신, (선택) 메모리 프로브 한 줄 | CH-2·CH-3 스크립트, 테스트 | 낮음. main 0줄 | 테크 완료 전후 비교, 저장 → 불러오기 뒤 유지 |
| **CH-5 해안 시연(교토)** | 해안 6자리, `coastal_only` | 데이터, 테스트 | 낮음 | 교토 해안 건물, 비해안 도시엔 안 나옴 |

**추천 순서: CH-1 → CH-2 → CH-4 → CH-3 → CH-5.**
- 이유: CH-4(데이터 → 그림 켜기)는 임시 격자 배치로도 증명할 수 있다. 그러면 좌표표(Q8)를 기다리는 CH-3과 갈라 진행할 수 있다.
- 다섯 단계 모두 `worldmap_main.gd` 0줄이 목표라서 M7·2-E의 재고정과 독립이다.
- CH-1은 Q2 답이 오기 전에는 시작하지 않는다.

## 4. 막힌 것
- 없음. 다만 아래는 확인하지 못했다.
  - 새 `.import` 생성이 `WORLDMAP_RULES.md:230`에 걸리는지 [미확인, 해석 문제]
  - 그림 교체 시 `.import` 재기록 여부 [미확인, 실험 필요]
  - 연출 컨트롤러 노드 경로 [미확인]

## 5. 종료 루틴
1. 정본 `C:\dev\SamWar_BattleLab_cc`, 가지 `feature/wm3d-intake-20261101`. 시작 HEAD `55314eb`, 작업 트리 깨끗. 코드·에셋 변경 0. 그림 원본은 레포에 복사하지 않음.
2. 새로 만든 것: 이 보고서 1개(+`agent/PROGRESS_WM3D.md` 한 줄).
3. push한 것: 보고서 커밋 1개(`[skip ci]`)만 `feature/wm3d-intake-20261101`에, force 없음.
4. CI: `[skip ci]`라 없음.
5. 김작이 결정할 것: Q1~Q8, 단계 순서.
