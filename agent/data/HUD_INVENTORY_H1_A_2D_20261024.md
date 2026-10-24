# H1-A — 2D 전투 HUD 블록 인벤토리 (읽기 전용, 2026-10-24)

- 기준: 워크트리 `scratchpad/h1/wt`, 커밋 `dccb306c794207c966c210f71d4928f75cf5ad28`.
- 워크트리는 바꾸지 않았다. Godot 실행 없음. 커밋 없음. 정적 읽기와 grep만 했다.
- 사각형 계산은 scratchpad의 파서 스크립트(`scratchpad/h1/tools/parse_tscn.py`, 워크트리 밖)로 했다. offset + anchor × 부모 크기 + 부모 원점 방식이다. 컨테이너 자식(layout_mode=2)은 계산하지 못했다.
- 표기: **사실** = 코드·씬 줄 근거 있음. **추정** = 추론.
- 약어:
  - **P** = `scenes/battle/Battle_Production.tscn` (6,564줄)
  - **C** = `scripts/battle_web_import_test.gd` (16,175줄; H0 때 16,070줄에서 늘었다)
  - **PC** = `scripts/battle/battle_production_controller.gd` (326줄)
  - **A** = `scripts/battle/ui/battle_hud_state_adapter.gd` (108줄)
  - **RB** = `scripts/battle/presentation/production/battle_roster_hud_controller.gd` (98줄, 씬 노드 이름 `ProductionRosterContentParityBridge`)
  - **CA** = `scripts/battle/presentation/production/battle_current_actor_hud_controller.gd` (449줄, 노드 `ProductionBottomHudPreviewBridge`)
  - **RP** = `scripts/battle/presentation/production/battle_roster_presentation_controller.gd` (440줄, 노드 `ProductionRosterCollapseExperiment`)
  - **SL** = `scripts/battle/presentation/production/battle_status_empty_legend_controller.gd` (108줄)
  - **CAH** = `scenes/battle/ui/CurrentActorInfoHud.tscn` (573줄)
- 스크립트 상속(사실): P 루트 스크립트 `battle_iso_production_controller.gd` → PC → `scripts/battle/battle_controller.gd`(9줄) → C. `Battle_Main.tscn`은 P를 instance만 한다.
- 헬퍼 노드 5개가 P 루트 자식이다(P:171-184). 모두 `get_parent()`로 컨트롤러를 읽는다. RB·CA·SL은 매 프레임 `_process`로 쓴다.

---

## §A 블록 표

화면 사각형은 1920×1080 기준 `x1..x2 × y1..y2`이다. ProductionHudRoot(P:3930)는 offset (−3, 2)..(1917, 1082)이고, 아래 값에 이미 더했다. 모두 **정적 계산(사실)**이다. 런타임에 위치를 바꾸는 곳은 비고에 적었다.

| # | 블록 | 노드 경로 (P:줄) | 노드 수 | 화면 사각형 | 기본 표시 | 실제 표시 | 상태 |
|---|---|---|---|---|---|---|---|
| A0 | HUD 루트 | `BattleUI/ProductionHudRoot` (3930) | 280 (씬) + 런타임 추가 | −3..1917 × 2..1082 | 보임 | 전투 종료 시 숨김 (C:15908) | 컨테이너 |
| A1 | 상단 HUD (기세 ◆ + "N / 30") | `.../TopHudRoot` (3939) | 52 | 497..1417 × 20..120 | 보임 | 보임 | **완료** (3D `scenes/battle3d/Battle3D_TopHud.tscn`) |
| A2 | 아군 로스터 | `.../AllyRosterHud` (4444) | 70 | 54..324 × 150..674 (프레임 텍스처 15..361 × 106..720) | 보임 | 보임 (접기 가능) | 포트 대상 |
| A3 | 적군 로스터 | `.../EnemyRosterHud` (5089) | 70 | 1595..1865 × 156..680 (프레임 1557..1903 × 111..725) | 보임 | 보임 (접기 가능) | 포트 대상 |
| A4 | 로스터 측면 배너 2개 | `.../AllyRosterSideBanner` (4422), `.../EnemyRosterSideBanner` (4433) | 1 + 1 | 347..407 × 123..249 / 1504..1564 × 126..252 | 보임 | 보임, 클릭 시 접기 | 포트 대상(표현 전용) |
| A5 | 로스터 접힘 초상 레이어 (런타임) | `.../AllyRosterPortraitOnlyLayer`, `.../EnemyRosterPortraitOnlyLayer` (RP:189-216에서 생성) | 각 11 | 아군 초상 x 5..77, 적군 x 1837..1909; y 252+78·i, 72×72 (RP:10-12, 435-437) | 숨김 | 접었을 때만 | 포트 대상(표현 전용) |
| A6 | 현재 행동 장수 HUD (하단 중앙) | `.../CurrentActorInfoHud` (CAH, CA:45-48에서 `add_child`) | 55 (씬) + 런타임 약 10 | 451..1463 × 825..1045 (배경 텍스처 439..1475 × 818..1052) | 보임 | 보임 | 포트 대상 |
| A7 | 유닛 비교 HUD (legacy) | `.../ActorComparisonHud` (5763) | 10 | 536..1378 × 888..1048 | 보임(씬) | **매 프레임 숨김** (CA:57, 429-432) | 폐기 상태 |
| A8 | 안내문 HUD | `.../InteractionGuideHud` (5726) | 4 | 459..1301 × 828..894 | 숨김(P:5727) | 숨김. 켜는 코드 없음 | 폐기 상태 |
| A9 | 전투 기록(로그) | `.../BattleLogHud` (5858) | 4 | 39..301 × 793..1055 | 보임 | 보임 | 포트 대상 |
| A10 | 보급 HUD | `.../BattleSupplyHud` (6043) | 39 | 1580..1870 × 830..1050 | 보임(씬) | 월드맵 전투일 때만 (C:1687-1689) | 포트 대상(조건부) |
| A11 | 빈/숨김 패널 | `.../GlobalCommandHud` (5850), `.../TooltipHud` (5897), `.../FacingSelectionHud` (5912) | 1 / 2 / 1 | 1457..1899 × 826..902 / 1457..1899 × 744..814 / 717..1197 × 742..812 | 숨김 | GlobalCommand·Tooltip 영구 숨김. FacingSelectionHud는 facing_select 때 보이지만 자식 없음 (C:15932-15934) | 내용 없음 |
| A12 | 보급 미리보기 (legacy) | `.../BottomHudRoot/BattleSupplyPreviewPanel` (5920, 5929) | 24 | 1312..1890 × 880..1060 | 숨김(P:5921) | 숨김. CA:371-380이 폰트만 바꿈 | 폐기 상태 |
| B1 | 상단 명령 버튼 (자동/턴 종료/후퇴) | `BattleUI/CommandBar` (3356) — ProductionHudRoot 밖 | 9 | 바 1337..1913 × −3..86. 버튼은 런타임 재배치: 자동 1607..1675, 턴 종료 1693..1761, 후퇴 1779..1847, 모두 y 27..95 (RP:14-17, 94) | 보임 | 버튼 3개만 보임 | 포트 대상 |
| B2 | 부대 명령 패널 (기본공격/고유특기/책략/방어/대기) | `BattleUI/FloatingAllyCommandPanel` (3451) | 6 | 씬 0..176 × 0..214. 런타임에 행동 유닛 옆으로 이동 (C:6292) | 숨김 | 아군 유닛 선택 시 보임 (C:6222-6268) | 포트 대상 |
| B3 | 방향 선택 | `BattleUI/FacingSelectionPanel` (3776), `BattleUI/FacingArrowPanel` (3824) | 6 / 5 | 720..1200 × 878..980 / 0..280 × 0..280(런타임 이동) | 숨김 | facing_select 때. iso는 화살표 패널을 유닛 근처에 놓음 (`battle_iso_production_controller.gd:219`) | 월드 부착 UI |
| B4 | 결과 후 월드맵 복귀 버튼 (런타임) | `BattleUI/WorldMapResultReturnButton` (C:2889-2908에서 생성) | 1 | 850..1070 × 942..984 (anchor 0.5/1.0 + offset, 1920×1080 가정) | 숨김 | 월드맵 전투 + 결과 확정 시 (C:2911-2928) | 포트 대상(결과 화면) |
| T1 | 라운드/결과/지원군 토스트 | `BattleUI/RoundToastRoot` (3505) | 3 | 루트 0..1920 × 0..1080, 이미지 550..1370 × 300..720 | 숨김 | 이벤트 때 | 토스트 |
| T2 | 고유특기 토스트 | `BattleUI/UniqueSkillToastRoot` (3540) | 4 | 0..1152 × 0..648 (구 해상도 수치) | 숨김 | 컷인 대체 경로 때 | 토스트 |
| T3 | 장수 퇴각 토스트 | `EnemyRetreatToastLayer` (6419, layer 30) / `EnemyRetreatToastRoot` | 6 | 크기 440×104. C:10361-10364는 740..1180 × 820..924로 놓지만 RP:153-160이 매 프레임 화면 중앙 740..1180 × 488..592로 다시 옮김 | 숨김 | 장수 전멸 때 | 토스트 |
| T4 | 결과 오버레이 (영상) | `ResultOverlay` (6503, CanvasLayer) | 5 | 씬 0..1152 × 0..720. 영상 패널은 런타임 비율 계산 (C:374-377) | 숨김 | 결과 영상 재생 때 | 결과 화면 |
| T5 | 컷인 | `CutinOverlay` (6468), `HeroCutinOverlay` (6538, layer 40), `BattleUI/SkillCutinLayer` (3862) | 5 / 4(+instance) / 8 | HeroCutinViewport 384..1536 × 216..864 (anchor 0.5 해석) | 숨김 | 고유특기 때. 특기 영상 컷인 동안 ProductionHudRoot 숨김 (C:4925-4926, 복귀 C:10238) | 연출 |
| L | legacy HUD (production이 숨김) | `BattleUI/TopBar` (2350, 3), `BattleUI/BattleMiniLogPanel` (2572, 3), `BattleUI/FormationSlotGuideLayer` (2596, 85), `BattleUI/UnitCloseupPanel` (3722, 6), `BattleUI/LeftPanel` (2521, 3), `BattleUI/RightPanel` (2551, 2), `BattleUI/T02BattleSupplyAnchor` (2377, 24), `*ReadyFrame` 5개, `*FacingIndicator` 10개 | — | TopBar 48..1872 × 24..88, MiniLog 2..264 × 876..1060 | 일부 보임(씬) | TopBar·MiniLog·FormationSlotGuide·UnitCloseup는 C:15950-15960이 숨김. Left/Right는 C:6982-6988이 숨김. T02 보급은 production 보급이 있으면 숨김 (C:1687-1689). ReadyFrame은 CA:329-347이 숨김 | 포트 불필요 |
| R | 대체 기세 HUD | `RuntimeMomentumHudLayer` (C:16095-) | — | — | — | `production_hud_root == null`일 때만 생성 (C:6802-6805). Production에서는 없음 | 포트 불필요 |

앵커 해석 메모(사실):
- `AllyRosterHud/RosterHeader/HeaderLabel`은 소수 anchor(−1.346, −0.795)를 쓴다. 해석 결과 151..349 × 133..177. 적군은 1692..1890 × 140..184.
- `EnemyMomentumHud/Frame`은 음수 offset(−75)이라 1033..1269로 부모 밖까지 나간다(A1, 완료 블록이라 영향 없음).
- 컨테이너 자식(`SlotRow` 아래 `SlotNNWrapper`, `BattleSupplyPreviewPanel/Margin/Content/...`)은 레이아웃 계산이 필요해 **해석하지 못했다**.
- CanvasLayer 바로 아래(T3·T4·T5)는 viewport 기준이다. 1920×1080으로 가정했다.

---

## §A 블록별 상세

### A1 상단 HUD — **완료**

- 3D 포트 완료(`scenes/battle3d/Battle3D_TopHud.tscn`). 여기서는 짧게만 적는다.
- 자원: `41_top_hud_frame_full` → `res://assets/ui/battle/production_hud/top/top_hud_frame_full.png`, `38_battle_ui_theme` → `res://assets/ui/battle_ui_theme.tres`, `42_turn_hud_title_medium` → `res://assets/font/noto_serif_kr/NotoSansCJKkr-Medium.otf`. SubResource `AllyDiamond{Filled,Empty}`, `EnemyDiamond{Filled,Empty}`, `StyleBoxEmpty_top_hud_transparent`.
- 채움: `_refresh_production_momentum_slots` C:15962-15972, `TurnLabel` C:15912 ("%d / %d"). `ValueLabel`·`ActiveSideLabel`·`BattleTitleLabel` 쓰기(C:15910-15911, 15913-15914)는 노드가 없어 아무 일도 안 한다(사실, P에 `name="ValueLabel"` 0개).
- 버튼 없음.

### A2·A3 아군/적군 로스터

1. 노드:
   - 각 70노드: 루트 Panel, `RosterFrameFull`(TextureRect), `RosterHeader`(+`HeaderIcon` 숨김, `HeaderLabel` "아군 편성"/"적군 편성"), 슬롯 5개 `Slot01·Slot02·Slot03·Reinforce01·Reinforce02`(각 13노드).
   - 슬롯 자식: `Portrait`(64×64), `NameLabel`, `UnitTypeLabel`, `TroopsLabel`, `TroopBar`, `ActionStateLabel`, `StatusLabel`, `UniqueSkillReadyLabel`, `HpLabel`, `TroopIconRect`(40×40), `TroopTypeLabel`, `UniqueSkillReadyIcon`.
   - 아군 슬롯 y: 196..288, 290..382, 384..476, 478..570, 572..664 (x 54..324). 적군 슬롯 y: 200..292 … 576..668 (x 1595..1865).
2. 자원 (복사 목록):
   - `38_battle_ui_theme` → `res://assets/ui/battle_ui_theme.tres` (variation `ProductionRosterPanelAlly/Enemy`, `ProductionRosterCard*`, `ProductionRosterHeroName`, `ProductionRosterStatus`, `ProductionRosterTroops`, `ProductionRosterUnitType`)
   - `43_roster_panel_frame_full` → `res://assets/ui/battle/production_hud/roster/roster_panel_frame_full.png`
   - `35_unique_skill_ready_icon` → `res://assets/web_battle/ui/formation_guide/unique_skill_ready_icon.png`
   - SubResource `RosterHeaderIconStyle`, `RosterHeaderTransparentStyle`
   - 런타임 텍스처: 초상(`_get_closeup_portrait_texture_for_unit` C:7603 → 영웅 레지스트리 경로), 병종 아이콘(`_get_troop_icon_texture_for_visual_key` C:7557 → 유닛 토큰 텍스처, 방향 반영)
3. 채우는 코드 (쓰기 주체가 둘이다, 사실):
   - (a) 이벤트 갱신: `_refresh_production_roster` C:15997-16017 (어댑터 A:20-31 결과 사용)
     - 슬롯 `visible` ← 어댑터 `visible` (용량 슬롯 활성 필터 A:24-25)
     - `NameLabel` ← display_name, `UnitTypeLabel` ← 병종명, `TroopsLabel` ← "병력 %d / %d"(current_hp/max_hp), `ActionStateLabel`, `StatusLabel`, `UniqueSkillReadyLabel`, `TroopBar.value`
     - 강조 테두리: `_apply_production_roster_actor_highlight` C:16045-16077. 현재 행동자(`_get_production_roster_current_actor` C:16020: 적 턴이면 `current_enemy_ai_actor_state`, 아군 입력 단계면 `active_unit_state`) 또는 다음 적 행동자 미리보기(`_get_production_roster_next_enemy_actor` C:16032 → `_get_next_available_enemy_ai_actor` C:13587)
   - (b) 매 프레임: RB `_sync_side`/`_sync_slot` RB:35-82
     - `TroopBar`·`ActionStateLabel`·`UniqueSkillReadyLabel`·`UnitTypeLabel`·`TroopsLabel` 숨김 (RB:40-44). 그래서 (a)가 쓴 값 대부분은 화면에 안 보인다.
     - `NameLabel` ← `unit.display_name` (RB:67)
     - `HpLabel` ← "병력 %d / %d" (`current_troops`/`max_troops`, RB:69)
     - `Portrait.texture` ← C `_get_closeup_portrait_texture_for_unit` (RB:71)
     - `TroopIconRect.texture` ← C `_get_troop_icon_texture_for_visual_key("", unit)` (RB:73)
     - `TroopTypeLabel` ← 병종명 (RB:76)
     - `StatusLabel` ← C `_get_formation_status_summary_text` (C:4216 → `_get_unit_status_summary_text_compact`) (RB:78), 빈 문자열이면 숨김
     - `UniqueSkillReadyIcon.visible` ← C `_is_unique_skill_ready_for_formation_guide` (C:7483: 쿨다운 0 + `_can_use_unique_skill`) (RB:82)
   - 화면에 실제 보이는 값 목록(사실 기반): 초상, 장수명, "병력 현재 / 최대", 병종 아이콘, 병종명, 상태 요약 문자열, 고유특기 준비 아이콘, 현재/다음 행동자 금색 테두리, 슬롯 표시 여부.
   - 주의(추정): (a)는 용량 필터를 거친 목록, (b)는 필터 없는 `_get_all_unit_states_in_slot_order`의 순번을 쓴다. 미배치 슬롯이 끼면 이름은 (b)가, 표시 여부는 (a)가 정해 순번이 어긋날 수 있다.
4. 버튼: 슬롯 자체에는 버튼이 없다. 접힘 상태의 아군 초상 클릭 → `_controller.call("_select_ally_unit", unit, true, true, false)` (RP:231-240).

### A4·A5 로스터 측면 배너 / 접힘 초상

1. 배너 각 1노드(TextureRect). 접힘 위치: 아군 (4,115), 적군 (1856,115) + 루트 offset → 화면 (1,117), (1853,117) (RP:440-441).
2. 자원: `44_roster_side_banner_ally` → `res://assets/ui/battle/production_hud/roster/roster_side_banner_ally.png`, `45_roster_side_banner_enemy` → `res://assets/ui/battle/production_hud/roster/roster_side_banner_enemy.png`.
3. 채움: 값 없음. 접힘 초상은 로스터 슬롯 `Portrait.texture`를 복사한다 (RP:347-350). 죽음/미배치면 회색 (RP:382-389, `_is_unit_state_deployed_by_capacity_slot` C:9238). 테두리는 현재/다음 행동자 (RP:352).
   - 진영 턴 전환 시 배너 펄스 `_maybe_pulse_roster_side_banner` C:6020 (C:5980에서 호출).
4. 버튼: 배너 좌클릭 → 접기/펼치기 `_set_collapsed` (RP:219-228). 엔진 쓰기 없음.

### A6 현재 행동 장수 HUD (`CurrentActorInfoHud`)

1. 노드:
   - CAH 루트 offset 454,823..1466,1043 (+ 루트 −3,2) → 451..1463 × 825..1045. z_index 6.
   - 영역(CA:70-80이 런타임에 offset을 다시 씀): `PortraitSlot` 463..633 × 837..1033, `InfoArea` 645..1089, `StatusArea` 1101..1321, `TerrainArea` 1333..1451 (y 모두 837..1033). 계산은 CA 값 기준(사실), 최종 렌더는 미확인.
   - 런타임 추가 노드: `StatusTitleIcon`(CA:139-153), `Bound*` TextureRect 7개(CA:382-404), `BoundUniqueSkillReadyBadge`(CA:279-299, 573..657 × 807..891), SL의 `ProductionEmptyStatusLegend` + 라벨 7개(SL:37-70).
   - `DefenseStat`(CAH:274) 숨김, `WoundedLabel` 숨김(CA:183).
2. 자원 (복사 목록):
   - CAH `1_theme` → `res://assets/ui/battle_ui_theme.tres`, `2_hud_background` → `res://assets/ui/battle/current_actor_hud/current_actor_hud_bg.png`
   - CA preload: `res://assets/web_battle/ui/formation_guide/unique_skill_ready_icon.png`, `res://assets/font/noto_serif_kr/NotoSerifKR-Bold.otf`, `res://assets/ui/battle/current_actor_icons/{stat_command,stat_might,stat_intellect,unique_skill,status_header,terrain_plain}.png` (CA:9-16)
   - 초상: `res://assets/heroes/portraits/current_actor/<country>/<country>_<hero_id>.png` (CA:256, 270), 실패 시 C:7603 폴백 (CA:202-203)
   - 데이터: `res://scripts/worldmap/hero_design_data_registry.gd` (CA:8)
3. 채우는 코드: CA `_sync_current_actor_info` CA:155-219, 매 프레임.
   - 대상: `controller.get("active_unit_state")` 하나뿐 (CA:159). null이면 "대기"/"-" 초기화 (CA:221-238).
   - 값 목록:
     - `InfoArea/NameLabel` ← `unit.display_name` (CA:177)
     - `InfoArea/TroopClassLabel` ← 병종명 (레지스트리 `battle_profile.unit_type` 우선, CA:178-181)
     - `InfoArea/TroopRow/TroopsLabel` ← "병력 %d / %d" (`current_hp`/`max_hp`, CA:182)
     - `StatsRow/{Command,Might,Intellect}Stat/Value` ← "지휘 %d"/"무력 %d"/"지력 %d" (레지스트리 stats 우선, CA:185-190)
     - `UniqueTraitArea/UniqueTraitLabel`·`UniqueTraitSummaryLabel` ← 고유특기 이름·설명 (레지스트리 우선, 없으면 `unit.unique_skill_definition`, CA:171-195)
     - `PortraitSlot` ← current_actor 초상 (CA:201-205)
     - `BoundUniqueSkillReadyBadge.visible` ← C `_can_use_unique_skill(unit)` (CA:293-296), 펄스
     - `InfoArea/TroopRow/TroopTypeIconSlot` ← C `_get_troop_icon_texture_for_visual_key("<country>_<unit_type>", null)` 후 폴백 (CA:208-216)
     - `StatusArea/StatusRow01..05` ← C `_get_unit_status_display_entries(unit)`(PC:310이 덮어씀 → C:4061) 중 "부상" 제외 최대 5개 (CA:301-327)
     - 빈 상태 범례 표시 여부 ← SL:79-99 (같은 함수)
     - `TerrainArea/TerrainNameLabel`·`TerrainEffectLabel` ← `worldmap_battle_context`의 `terrain_name`·`terrain_defense_text`·`terrain_move_text`, 없으면 "평지"/"방어 0%"/"이동 0%" (CA:349-368, 17-19)
   - 적 턴에 대해(사실+추정): CA는 `current_enemy_ai_actor_state`를 읽지 않는다(사실). 적 턴에는 `active_unit_state`가 마지막으로 행동한 아군으로 남거나(추정), 아군이 모두 행동했으면 null이 되어 "대기"가 된다 (C:8460, 사실).
4. 버튼 없음. 툴팁만 있다 (CA:198, 289, 327).

### A7 유닛 비교 HUD (legacy) — 숨김

- 10노드: `LeftActorPanel/{RoleLabel,DetailLabel}`, `CenterContextPanel/{ContextLabel,TerrainPlaceholderLabel}`, `RightSubjectPanel/{RoleLabel,DetailLabel}`.
- 자원: `38_battle_ui_theme`.
- 채움: C:15917-15925 (`_refresh_production_actor_panel` C:16081-16092). 값: "현재 행동", 오른쪽 역할("선택 대상"/"다음 행동"/"대기", A:32-39), "%s\n%s · 병력 %d / %d\n%s", "거리 %d · 반격 확인 중" (A:71-74).
- CA가 매 프레임 `visible=false` (CA:57, 429-432). 화면에 나오지 않는다(사실).

### A8 안내문 HUD — 숨김

- `PhaseLabel`, `InstructionLabel`, `DisabledReasonLabel`. 채움 C:15927-15929 (A:79-99 문구).
- P:5727 `visible = false`. 켜는 코드 없음(grep `InteractionGuideHud` → C:15927-15929만).

### A9 전투 기록 (BattleLogHud)

1. 4노드: `BattleLogFrameBg` 39..301 × 793..1055, `TitleLabel` "전투 기록" 133..237 × 799..827, `RecentLogLabel` 69..242 × 843..1015 (173×172, autowrap 2, clip 없음, 최대 줄 제한 없음).
2. 자원: `38_battle_ui_theme` (variation `ProductionBattleLogPanel`/`ProductionBattleLogTitle`/`ProductionBattleLogBody`: 본문 NotoSerifKR-Regular 15px, 제목 NotoSerifKR-Bold 19px, 테마 :240-251), `47_battle_log_panel_full` → `res://assets/ui/battle/production_hud/battle_log/battle_log_panel_full.png`.
3. 채움: C:15930-15931 `"\n".join(state.recent_log)` ← A:49 `controller.get("battle_log_lines")`. 줄 앞에 "- " 없음. §C 참조.
4. 버튼 없음.

### A10 보급 HUD (BattleSupplyHud)

1. 39노드: `SupplyFrameBg`, `TitleLabel`, `DividerTop`(숨김), `CenterDivider`, `AllyHeaderLabel`/`EnemyHeaderLabel`, 행 8개 `{Ally,Enemy}{Food,Salt,Consume,Sustain}Row/{Icon,Label,Value}`. 아군 열 x 1597..1720, 적군 열 1732..1855, 행 y 914/942/970/998 (각 28px).
2. 자원: `38_battle_ui_theme`, `49_supply_frame` → `res://assets/ui/battle/production_hud/battle_supply/battle_supply_panel_full.png`, `50_supply_icon_food` → `.../battle_supply/icons/supply_icon_food.png`, `51_supply_icon_salt` → `.../icons/supply_icon_salt.png`, `52_supply_icon_consume` → `.../icons/supply_icon_consume.png`, `53_supply_icon_sustain` → `.../icons/supply_icon_sustain.png`.
3. 채움: `_refresh_battle_supply_hud` C:1732-1754 → `_refresh_production_battle_supply_side` C:1769-1795.
   - 값: 식량 라벨(식량 종류 이름 또는 "식량"), 식량 양, 소금 양, 소비 "식량/소금"(턴당), 지속 "N턴"/"30턴+"/"-".
   - 원천: `battle_supply_runtime.snapshot()`의 attacker/defender, `_sum_alive_deployed_troops_for_side` (C:3105), `ExpeditionSupplyCalculator.salt_per_turn`/`food_per_turn`/`predict_supply`.
   - 갱신 시점: `_settle_battle_supply_turn` (C:1699) 끝 C:1717. 즉 보급 설정 시(1턴)와 라운드 시작(C:11404)뿐이다. 전투 중 병력이 줄어도 즉시 갱신하지 않는다(사실).
   - 표시 조건: `_has_worldmap_battle_context()` 이고 runtime 있음 (C:1677-1678). 테스트 전투에서는 숨김.
4. 버튼 없음.

### A11·A12 빈/숨김 패널 — 포트 불필요

- `GlobalCommandHud`(자식 0), `TooltipHud/TooltipLabel`, `FacingSelectionHud`(자식 0), `BottomHudRoot/BattleSupplyPreviewPanel`. 값을 쓰는 코드는 `FacingSelectionHud.visible`(C:15932-15934)과 CA의 폰트 덮어쓰기(CA:371-380)뿐.

### B1 상단 명령 버튼 (CommandBar)

1. 9노드: `BottomCommandBarBackground`(숨김), `CommandBarLabel`(숨김), `BasicAttackButton`/`MoveButton`/`WaitButton`(숨김, C:6121-6129), `EndTurnButton`, `AutoBattleButton`, `RetreatButton` (TextureButton).
2. 자원:
   - 씬: `28_bottom_end_turn_normal` → `res://assets/web_battle/ui/bottom_command/bottom_cmd_end_turn_normal.png`, `29_..._pressed` → `bottom_cmd_end_turn_pressed.png`, `30_bottom_auto_normal` → `bottom_cmd_auto_normal.png`, `31_..._pressed` → `bottom_cmd_auto_pressed.png`, `32_bottom_retreat_normal` → `bottom_cmd_retreat_normal.png`, `33_..._pressed` → `bottom_cmd_retreat_pressed.png`, `34_bottom_command_bar_bg` → `bottom_command_bar_bg.png` (모두 `res://assets/web_battle/ui/bottom_command/`).
   - **실제 화면 텍스처는 RP가 덮어쓴다** (RP:22-24, 100-103): `res://assets/ui/battle/top_actions/auto_battle_button.png`, `end_turn_button.png`, `retreat_button.png`. normal/hover/pressed/disabled 모두 같은 텍스처.
3. 채움: 위치·크기·hover/press 스케일 tween (RP:69-150). disabled 상태: C:5990-5997 (`end_turn_button.disabled`), 자동 버튼 `_refresh_auto_battle_button_state` C:6405-6413 (툴팁 "자동중지"/"자동전투").
4. 버튼 (연결 위치 → 처리 함수):
   - 자동: C:1441 → `_toggle_full_auto_battle` (C:13848)
   - 턴 종료: C:1439 → `_end_ally_turn_by_wait` (C:6482). 대기와 같은 함수.
   - 후퇴: **처리기 2개**
     - ① RP:86-87 → `_on_top_action_retreat_pressed` RP:163-180: 연출 중이면 무시 → 자동전투 중지 → `battle_result_reason="retreat"`, `forced_battle_result_state="defeat"` → 로그 "아군이 전장에서 후퇴합니다." → `_try_show_battle_result_toast_if_needed` → 복귀 버튼 갱신. **월드맵 문맥 검사 없음.**
     - ② C:1443 → `_on_retreat_button_pressed` C:6152-6166: 월드맵 공격전이 아니면 "현재 전투에서는 후퇴할 수 없습니다." 로그 후 종료. 결과가 확정됐으면 종료. 아니면 `forced_battle_result_state="retreat"` + 로그 "후퇴 명령 · 생존 병력과 남은 보급이 출발 도시로 복귀합니다." + `_return_to_worldmap_with_result` (C:2935, 즉시 씬 전환).
     - 활성 상태: RP:84가 `disabled=false`로 두지만, 부모 `_ready`의 `_configure_command_bar`(C:1444 → C:6132)가 다시 `disabled=true`로 만든다. 월드맵 문맥 적용 시 `_refresh_retreat_button_state`(C:1641 → C:6140-6149)가 "월드맵 + 플레이어 공격전 + 미확정"일 때만 켠다(사실). disabled 텍스처가 normal과 같아 꺼져 보이지 않는다(사실, RP:103).
     - 현재 동작(추정): 자식 `_ready`가 먼저라 ①이 먼저 연결되고 먼저 실행된다. ①이 결과를 "defeat"로 확정하므로 ②는 `_is_battle_result_finalized()`에 걸려 바로 끝난다. 결과: 공격전에서 후퇴를 누르면 "패배" 토스트/영상 + "월드맵으로 돌아가기 · 패배" 버튼이 나오고, "retreat" 결과·즉시 복귀는 일어나지 않는다. 테스트 전투에서는 버튼이 disabled라 아무 일도 없다.
   - hover/press: RP:116-138 (표현 전용).

### B2 부대 명령 패널 (FloatingAllyCommandPanel)

1. 6노드: `FloatingBasicAttackButton`(12..164 × 12..46), `FloatingUniqueSkillButton`(52..86), `FloatingTacticsButton`(92..126), `FloatingMoveButton`(132..166, 글자 "방어"), `FloatingWaitButton`(172..206). 패널 위치는 런타임에 행동 유닛 옆 (C:6292-).
2. 자원: ExtResource 없음. 스타일은 코드 `_apply_floating_command_button_style` (C:6169).
3. 채움: `_refresh_floating_ally_command_panel` C:6222-6268.
   - disabled: 기본공격·방어·대기 ← `current_phase==ally_turn && !is_demo_animating && _is_active_ally_action_available()` (C:14051)
   - 고유특기: disabled ← `_can_use_unique_skill(active_unit_state)`; 글자 "%s · 기세 %d" (`_get_unique_skill_for_unit` C:3625, `_get_effective_unique_skill_cost` C:5486); 툴팁 "공용 기세 %d/%d · 소비 %d"
   - 책략: disabled ← `_can_use_strategy` (C:3832); 글자 `STRATEGY_NAME`; 지력 80 미만 툴팁 "지력 80 이상 필요"
   - 표시 조건 `_should_show_floating_ally_command_panel` C:6198
4. 버튼:
   - 기본공격 C:1446 → `try_basic_attack` (C:3433)
   - 고유특기 C:1448 → `_on_unique_skill_button_pressed` (C:3681)
   - 책략 C:1450 → `_on_strategy_button_pressed` (C:3781)
   - 방어(노드명 FloatingMoveButton) C:1452 → `_on_defend_button_pressed` (C:6416)
   - 대기 C:1454 → `_end_ally_turn_by_wait` (C:6482)
   - 숨김 CommandBar 버튼: BasicAttack C:1434 → `try_basic_attack`, Move C:1435 → `play_basic_move_demo` (C:3314), Wait C:1437 → `_end_ally_turn_by_wait`

### B3 방향 선택

- `FacingSelectionPanel/{FacingTitleLabel, FaceLeft/Right/Up/Down}`, `FacingArrowPanel/4개`. 연결 C:1456-1470 → `_select_post_move_facing.bind(FACING_*)` (C:6755). iso는 화살표 패널을 타일 버튼으로 바꾸고 유닛 근처로 옮긴다 (`battle_iso_production_controller.gd:209-246`). 월드 좌표 부착 UI라 HUD 고정 사각형이 없다.

### B4 결과 화면 (복귀 버튼 + 토스트 + 영상)

- 결과 판정: `_get_battle_result_state` C:10571-10580 (`forced_battle_result_state` 우선, 아니면 생존 집계), `_is_battle_result_finalized` C:10583.
- 결과 표시 순서: `_try_show_battle_result_toast_if_needed` C:10637-10655 → 결과 영상(`ResultOverlay/VideoStreamPlayer_Result`, `res://assets/ui/result/videos/victory_result_theora_q8_1920x.ogv`, `defeat_result_theora_q8_1920x.ogv`, C:371-372) → `_show_battle_result_toast` C:10492 (RoundToastRoot에 `res://assets/web_battle/ui/results/battle_result_victory.png` / `battle_result_defeat.png`, 글자 "승리!"/"패배", C:365-368).
- ProductionHudRoot는 결과 확정 시 숨긴다 (C:15908).
- 복귀 버튼 `WorldMapResultReturnButton`: 글자 "월드맵으로 돌아가기 · 승리/패배/후퇴" (C:2911-2928). 클릭 → `_on_worldmap_result_return_pressed` C:2931 → `_return_to_worldmap_with_result` C:2935 (씬 전환 `WORLDMAP_SCENE_PATH`).
- ResultOverlay 씬 자원: `7_result` → `res://assets/web_battle/ui/results/battle_result_victory.png`.

### T1~T5 토스트·컷인

- T1 `RoundToastRoot`: 자원 `12_round_toast_texture` → `res://assets/web_battle/ui/round_toast/round_toast_ink_war_01.png`, 셰이더 `11_round_toast_shader` → `res://assets/web_battle/ui/round_toast/round_toast_ink_spread.gdshader`(C 사용). 글자 "BATTLE %d" (C:10473), 지원군 "지원군 도착!" + `res://assets/web_battle/ui/reinforcement/reinforcement_arrival_toast_01.png` (C:163-165, 10476-), 결과 토스트(B4). 큐 `_enqueue_battle_toast` C:10510.
- T2 `UniqueSkillToastRoot`: `_show_unique_skill_toast_over_unit` C:5313. 컷인 영상 경로가 없을 때 대체.
- T3 장수 퇴각 토스트: 값 = 장수명, 대사(`_get_defeat_retreat_line` C:10453, 해시로 고정 선택), 초상, 진영 색. 트리거 `_cleanup_dead_units` C:14105. 3개 초과분은 로그 "%s 전투이탈" (C:14108).
- T4 ResultOverlay: B4 참조.
- T5 컷인: `HeroCutinOverlay` (instance `37_hero_cutin_presentation` → `res://scenes/ui/cutin/hero_cutin_presentation.tscn`), `SkillCutinLayer` (`36_yi_sun_sin_video_cutin_portrait` → `res://assets/ui/cutin/portraits/yi_sun_sin_cutin.png`), `CutinOverlay` (`8_cutin` → `res://assets/web_battle/skills/cutins/yi_sunsin_hakikjin.png`). 입력 차단 `_sync_production_cutin_input_blocker` PC:52-55.

### 공통 복사 목록 요약 (ProductionHudRoot 안 ExtResource 13개, 사실)

`35_unique_skill_ready_icon`, `38_battle_ui_theme`, `41_top_hud_frame_full`, `42_turn_hud_title_medium`, `43_roster_panel_frame_full`, `44_roster_side_banner_ally`, `45_roster_side_banner_enemy`, `47_battle_log_panel_full`, `49_supply_frame`, `50~53_supply_icon_*`. 테마는 폰트 3개(`res://assets/font/noto_serif_kr/NotoSerifKR-{Bold,Medium,Regular}.otf`)만 외부 참조한다(테마 ext_resource 3개). 서브리소스 7개(다이아몬드 4, 로스터 헤더 2, 상단 투명 1). CurrentActorInfoHud와 RP 상단 버튼 텍스처는 위 각 절에 따로 적었다.

---

## §B 값 출처 표

열 뜻:
- **즉시/이벤트**: "즉시" = 엔진 상태를 아무 때나 읽으면 최신. "이벤트" = 2D가 특정 호출 때만 다시 쓴다(값 자체는 즉시 읽기 가능할 수 있음).
- **읽기 경로**: "기존-A" = 어댑터 A가 이미 읽음. "기존-H" = 헬퍼(RB/CA/RP/SL)가 이미 `controller.get/call`로 읽음. "신규" = 2D HUD 리더가 읽지 않고 C 안에서 직접 계산하거나 노드 글자에 있음 → 새 읽기 경로 필요(이름 후보 제시, 결정 아님).

2D 갱신 트리거(사실): `_refresh_production_battle_hud` 호출 C:1501(ready), 3310(reset), 6017(phase 변경 `_set_phase` 끝), 6786(로그 추가), 6806(기세 구성), 6845(`_refresh_momentum_ui`), 8170·8240(적 행동자 선택), 10238(컷인 종료). RB·CA·SL·RP는 매 프레임.

| 블록 | 값 | 엔진 출처 (file:line) | 즉시/이벤트 | 읽기 경로 (이름 후보) |
|---|---|---|---|---|
| A1 | 기세 아군/적군 | `battle_momentum` C:924 → `get_value(side)` | 즉시 / 2D는 이벤트 | 기존-A (A:14-19) — 완료 |
| A1 | 라운드 N / 30 | `battle_round` C:988, 최대 `ExpeditionSupplyCalculator.BATTLE_MAX_TURNS`(C:11396 근처) / A `MAX_TURN` A:4 | 즉시 / 2D는 이벤트 | 기존-A (A:42) — 완료 |
| A2·A3 | 슬롯 순서·진영 | `_get_all_unit_states_in_slot_order` C:14307 | 즉시 | 기존-A (A:22-23), 기존-H (RB:26, RP:429) |
| A2·A3 | 슬롯 표시 여부 | `_is_unit_state_active_by_capacity_slot` C:9247 | 즉시 / 2D는 이벤트 | 기존-A (A:24-25) |
| A2·A3 | 장수명 | `BattleUnitState.display_name` (`scripts/battle_unit_state.gd:19`) | 즉시 | 기존-A·H (A:65, RB:67) |
| A2·A3 | 병력 현재/최대 (보이는 HpLabel) | `current_troops`/`max_troops` (unit_state:35-36; `apply_damage` :238-242에서 hp와 같이 감소) | 즉시 | 기존-H (RB:69). 어댑터는 `current_hp`/`max_hp`를 읽음(A:55-56) |
| A2·A3 | 초상 텍스처 | `_get_closeup_portrait_texture_for_unit` C:7603 → `_get_hero_id_for_unit_state` C:8769 | 즉시 | 기존-H (RB:71). 어댑터 `portrait`는 항상 null (A:65) |
| A2·A3 | 병종 아이콘 | `_get_troop_icon_texture_for_visual_key` C:7557 (방향 반영 토큰) | 즉시 | 기존-H (RB:73) |
| A2·A3 | 병종명 | `unit_type` (unit_state:24) + 로컬 변환표 (RB:91-98) | 즉시 | 기존-H |
| A2·A3 | 상태 요약 | `_get_formation_status_summary_text` C:4216 | 즉시 | 기존-H (RB:78) |
| A2·A3 | 고유특기 준비 | `_is_unique_skill_ready_for_formation_guide` C:7483 | 즉시 | 기존-H (RB:82) |
| A2·A3·A5 | 현재 행동자 강조 | `_get_production_roster_current_actor` C:16020 (`current_phase` C:911, `current_enemy_ai_actor_state` C:978, `active_unit_state` C:950) | 즉시 / 2D 로스터 강조는 이벤트, 접힘 테두리는 매 프레임 | 기존-H (RP:358-359). 어댑터 밖 |
| A2·A3·A5 | 다음 적 행동자 미리보기 | `_get_production_roster_next_enemy_actor` C:16032 → `_get_next_available_enemy_ai_actor` C:13587 | 즉시 | 기존-H (RP:364-365) |
| A5 | 회색 처리 | `is_alive()` (unit_state:234), `_is_unit_state_deployed_by_capacity_slot` C:9238 | 즉시 | 기존-H (RP:385-386) |
| A6 | 대상 유닛 | `active_unit_state` C:950 | 즉시 | 기존-A (A:8), 기존-H (CA:159) |
| A6 | hero_id | `_get_hero_id_for_unit_state` C:8769 + 별칭표 CA:21-26 | 즉시 | 기존-H (CA:242-243) |
| A6 | 이름·병력 | `display_name`, `current_hp`/`max_hp` (unit_state:19, 33-34) | 즉시 | 기존-H |
| A6 | 병종명 | 레지스트리 `HeroDesignDataRegistry.get_battle_profile(hero_id).unit_type` → 없으면 `unit_type` | 즉시(정적 데이터) | 기존-H (CA:166, 179-180). 엔진 밖 데이터 |
| A6 | 지휘/무력/지력 | 레지스트리 `get_base_stats(hero_id).stats` (CA:165) → 폴백 `unit.leadership`/`martial`/`intelligence` | 즉시(정적 데이터) | 기존-H. 주의: `BattleUnitState`에 `leadership` 필드가 없다(grep 0) |
| A6 | 고유특기 이름·설명 | 레지스트리 `get_unique_skill_for_hero` → 폴백 `unique_skill_definition` (unit_state:46) | 즉시 | 기존-H (CA:167, 171-195) |
| A6 | 특기 사용 가능 배지 | `_can_use_unique_skill` C:3631 | 즉시 | 기존-H (CA:293-294) |
| A6 | 병종 아이콘 | `_get_troop_icon_texture_for_visual_key` C:7557 | 즉시 | 기존-H (CA:211-215) |
| A6 | 상태 행 1~5 | `_get_unit_status_display_entries` PC:310 → C:4061 | 즉시 | 기존-H (CA:303-304, SL:83-86) |
| A6 | 지형 이름·효과 | `worldmap_battle_context` C:913의 `terrain_name`/`terrain_defense_text`/`terrain_move_text`, 기본 "평지/방어 0%/이동 0%" | 즉시(전투 중 불변) | 기존-H (CA:352) |
| A6 | 초상 | 파일 경로 규칙(CA:256, 270), 폴백 C:7603 | 즉시(정적) | 기존-H |
| A7 | 비교 패널 값 | `active_unit_state`, `selected_attack_target_state` C:959, `get_unit_grid_distance` C:15219 | 즉시 / 이벤트 | 기존-A. 화면에 안 나옴 |
| A8 | 단계·안내·불가 사유 | `current_phase` + `_is_battle_result_finalized` C:10583 → A:79-99 문구 | 즉시 / 이벤트 | 기존-A. 화면에 안 나옴 |
| A9 | 최근 로그 4줄 | `battle_log_lines` C:912 (최대 `MAX_BATTLE_LOG_LINES` 4, C:133), 추가 `_append_battle_log` C:6781 | 배열은 즉시 / 2D는 로그 추가 이벤트 | 기존-A (A:49) |
| A10 | 표시 여부 | `_has_worldmap_battle_context` C:2927(`worldmap_battle_context` 비었는지) + `battle_supply_runtime` C:914 | 즉시 | 신규 (`has_worldmap_battle_context` 류 읽기) |
| A10 | 식량 종류·양, 소금 양 | `battle_supply_runtime.snapshot()` (`scripts/t02/battle_supply_runtime.gd`) attacker/defender, 진영 매핑 `_is_worldmap_player_attack_context` C:1922 | 값은 즉시 / 2D는 라운드 정산 이벤트(C:1717) | 신규 (`get_battle_supply_snapshot`, `is_player_attacker` 후보) |
| A10 | 소비·지속 턴 | `_sum_alive_deployed_troops_for_side` C:3105 + `ExpeditionSupplyCalculator.salt_per_turn/food_per_turn/predict_supply` | 계산값 / 2D는 이벤트 | 신규 (`get_supply_hud_rows(side)` 후보, 또는 위 2개 + 계산기 직접 호출) |
| B1 | 자동 버튼 상태·툴팁 | `is_full_auto_battle_enabled` C:974 + can_issue 조건 (C:5980-5987) | 즉시 / 이벤트 | 신규 (`can_issue_ally_command` 후보). C 내부 계산 |
| B1 | 턴 종료 활성 | 같은 can_issue 조건 (`current_phase`, `is_demo_animating` C:906, 결과 확정, 인트로 카메라, `_is_active_ally_action_available` C:14051) | 즉시 / 이벤트 | 신규 (같은 후보) |
| B1 | 후퇴 활성 | `_has_worldmap_battle_context` + `_is_worldmap_player_attack_context` C:1922 + `_is_battle_result_finalized` C:10583 (C:6140-6149) | 즉시 / 이벤트(문맥 적용·누를 때만) | 신규 (`can_retreat` 후보) |
| B2 | 명령 활성 | `_is_active_ally_action_available` C:14051, `_can_use_unique_skill` C:3631, `_can_use_strategy` C:3832 | 즉시 / 이벤트 | 일부 기존-H (`_can_use_unique_skill`만 CA가 읽음). 나머지 신규 |
| B2 | 특기 이름·비용 | `_get_unique_skill_for_unit` C:3625, `_get_effective_unique_skill_cost` C:5486, 기세 `battle_momentum` | 즉시 | 신규 (비용 함수) |
| B4 | 결과 상태 | `forced_battle_result_state` C:917 / `_get_battle_result_state` C:10571 | 즉시 | 부분 기존-A (`_is_battle_result_finalized` A:40). 상태 문자열은 신규 (`get_battle_result_state` 후보) |
| B4 | 결과 이유 | `battle_result_reason` C:918 ("elimination"/"retreat"/"turn_limit") | 즉시 | 신규 |
| T1 | 라운드 토스트 숫자 | `battle_round` (C:10473) | 이벤트 (라운드 시작) | 엔진 이벤트 `enemy_action_event_log.emit("round_started")` C:11417 (2D 읽기는 아님) |
| T3 | 퇴각 장수 | `_cleanup_dead_units` C:14095-14116 (이름·대사·초상) | 이벤트 | 신규. 엔진 이벤트 `battle_action_event_log.emit("unit_defeated")` C:14114 있음 |
| (제목) | 전투 제목 | `BattleUI/TopBar/TopBarLabel` 노드 글자 (C:1645-1659가 `worldmap_battle_context`로 씀) | 이벤트(문맥 적용 1회) | 기존-A가 **노드**를 읽음 (A:11-13). 현재 화면에 쓰는 곳 없음 (BattleTitleLabel 노드 없음) |

---

## §C 2D 로그 패널이 적 행동을 보여주는 방식

### C-1 로그를 쓰는 함수

- 유일한 입구는 `_append_battle_log(line)` C:6781-6786이다(사실).
  - `battle_log_lines.append(line)` → 4줄 초과분 `pop_front()` (C:6782-6784, `MAX_BATTLE_LOG_LINES := 4` C:133)
  - `_refresh_battle_log()` C:6966-6979 (legacy `LeftPanel/BattleLogPreview`, `BattleMiniLogPanel/BattleMiniLogLabel`; 둘 다 production에서 숨김)
  - `_refresh_production_battle_hud("log")` → `BattleLogHud/RecentLogLabel` (C:15930-15931)
- 호출 지점: 133곳 (C 122, PC 11). 로그는 저장/복원된다 (C:6876 저장, C:6919-6923 복원).
- 리셋: `battle_log_lines.clear()` C:3254.

### C-2 적 턴에 나오는 줄 (형식 문자열 원문, C 기준)

적 턴 진입 (아군 행동 뒤에 아군 쪽 함수가 씀):
- `"적군 턴"` — C:3621(공격), 3979(책략), 4374(혼란), 5952(특기 종료), 6468(방어), 6517(대기), PC:251(재배치 후)
- 아군이 모두 행동해 적이 연속 행동할 때는 "적군 턴" 줄이 없다 (C:8457-8462, 사실).

적 행동자 1명의 흐름 (`_play_enemy_ai_for_actor` C:8161-8221):
- 행동자 선택 자체를 알리는 줄은 **없다**(사실). 대신 `current_enemy_ai_actor_state` 대입 + 로스터 강조 갱신만 한다 (C:8168-8170).
- 행동 불가: `"%s은 혼란 상태로 행동할 수 없습니다."` (C:8172)
- 행동 가능 적 없음: `"행동 가능한 적군 없음"` (C:8154)
- 대상 없음: `"적 행동 대상 없음"` (C:8190)
- 대기: `"%s 대기"` (C:8205, 이동 후 C:8376)
- 이동: `"%s 접근"` (C:8220). 실패 `"%s 이동 경로 없음"` (C:8214), `"%s 이동 경로 막힘"` (C:8289). 목적지 칸은 줄에 없다.
- 기본 공격 (`_enemy_reaction_hit_on` C:8384-8408, 피해 적용 시점):
  - 피해가 0보다 크면 `_gain_momentum_for_basic_attack` (C:6789-6797): `"%s 기본공격 성공: 기세 +%d"` 와 `"%s 피격: 진영 기세 -%d"`. 두 번째 줄의 `%s`는 진영 id 원문("ally")이다(사실, C:6795-6796).
  - 방향: `"후방 공격!"` / `"측면 공격!"` (C:5822-5826)
  - 전멸: `"%s 전멸"` (C:14115), 토스트 3개 초과 시 `"%s 전투이탈"` (C:14108)
  - 마지막에 `"%s 반격"` (C:8408). 적의 **공격**인데 글자는 "반격"이다(사실). 피해 숫자는 로그에 없다(화면 숫자 FX로만 나옴, C:8401).
- 고유특기 (`_try_auto_unique_skill_for_actor` C:4588-4618 → 미리보기 → 발동):
  - `"%s 고유특기 선택"` (C:4611)
  - `"%s이 %s을 발동!"` + `"%s 기세 %d 소비 · 잔여 %d"` (C:4755-4760 또는 4771-4776)
  - 효과 줄: `"%s 기세 +%d"`/`"%s 기세 -%d"` (C:5586, 5592), 요약 `"%s · %s · 피해 %d / 상태 %d / 회복 %d"` (C:5599-5605), 구 효과 경로 `"적군 다수에게 %d 피해"`, `"%s에게 %d 피해"`, `"%s 공격력 상승"` (C:5685-5749)
- 책략 (`_try_enemy_strategy_for_actor` C:4005 → `_resolve_enemy_strategy` C:4040 → 공용 `_resolve_strategy_effect` C:3983-4002):
  - `"%s이 책략을 펼쳤습니다."` (C:3986)
  - `"책략 성공! %s에게 %s %d턴!"` (C:3997) 또는 `"책략 실패!"` (C:4001)
- 상태 지속 피해: `"%s 화상 피해 %d"` (C:4234)
- 아군 차례 복귀: `"아군 턴 복귀"` (C:8474), 아군 없음 `"행동 가능한 아군 없음"` (C:8469)

라운드 시작 (`_start_new_round` C:11386-11416):
- `"라운드 종료: 아군 기세 +%d / 적군 기세 +%d"` (C:11402)
- (보급 정산) `"군량이 고갈되어 병사 %d명이 이탈했습니다."` (C:1716, 월드맵 전투만)
- `"BATTLE %d 시작"` (C:11413)
- 지원군: `"지원군 선봉 등장"` (C:9454), `"도시 지원군 도착"` (C:9489)
- 30턴 초과: `"30턴 동안 성을 함락하지 못했습니다. 방어군이 전장을 지켜냈습니다."` (C:11396)

### C-3 줄 수와 스크롤

- 보관 줄 수: 최대 **4줄**(사실, C:133). 새 줄이 오면 가장 오래된 줄을 버린다(FIFO, C:6783-6784).
- 표시: `"\n".join(4줄)`을 Label 글자로 통째로 바꾼다(사실, C:15931). 줄 앞 "- " 없음. 스크롤 컨테이너·애니메이션·색 구분 없음.
- 라벨 173×172px, 15px 폰트, 단어 줄바꿈, 자르기 없음(사실, P:5887-5895, 테마:243). 긴 줄이 여러 번 접히면 라벨 높이를 넘을 수 있다(추정, 렌더 미확인).
- 적 1명의 접근+공격이 4~6줄을 만든다("접근", "기본공격 성공", "피격", 방향, 전멸, "반격"). 그래서 공격 직후에는 "X 접근" 줄이 이미 밀려 사라질 수 있다(추정, 줄 수 계산 근거).

### C-4 "현재 적 행동자" 줄이 있는가

- **없다(사실).** 로그 패널은 지나간 줄만 보여준다. 행동자 선택 시점(C:8168-8170)에 로그를 쓰지 않는다.
- 2D에서 "지금 행동 중인 적"을 보여주는 것은 로그가 아니라 **로스터 카드 금색 테두리**다 (`_get_production_roster_current_actor` C:16020-16029, 적 턴이면 `current_enemy_ai_actor_state`). 갱신 트리거는 C:8170·8240 `_refresh_production_battle_hud("enemy-actor")`.
- 하단 현재 행동 HUD(A6)는 `active_unit_state`만 읽어 적 행동자를 보여주지 않는다(사실, CA:159).
- legacy 비교 패널(A7)에는 "다음 행동" 역할(A:37-39)이 있지만, 조건이 `active_unit_state`가 적일 때뿐이고 패널은 숨겨져 있다(사실).
- 3D 랩 비교(사실만): 3D의 "적 행동 중 · …" 줄은 `scripts/battle3d/battle3d_engine_play.gd:819`에서 `event.unit_id`로 만든다. 2D에서 같은 시점의 엔진 이벤트는 `enemy_action_event_log.record_unit("enemy_actor_selected", …)` C:8169이다.
- 결론(사실 기반 정리): 2D 로그는 "지나간 일 4줄"이고, 3D 줄은 "지금 행동 중인 적"이다. 목적이 다르다. 2D에서 같은 목적을 맡는 것은 로스터 강조 테두리다. 판단은 하지 않는다(3D 쪽 판단은 다른 에이전트 몫).

---

## H0와 다른 점

| H0 내용 | 현재(`dccb306`) | 근거 |
|---|---|---|
| C 16,070줄, 함수 줄 번호 | C 16,175줄. 대부분 약 +100 밀림. 예: `_refresh_production_battle_hud` 15799 → **15904**, `_append_battle_log` 6681 → **6781**, 버튼 연결 1426-1462 → **1434-1470**, `_on_retreat_button_pressed` 6052 → **6152**, `_refresh_retreat_button_state` 6040 → **6140**, `battle_log_lines` 904 → **912**, `battle_round` 980 → **988**, `current_enemy_ai_actor_state` 970 → **978**, `selected_attack_target_state` 951 → **959**, `_get_all_unit_states_in_slot_order` 14202 → **14307**, `_is_unit_state_active_by_capacity_slot` 9146 → **9247**, `_is_battle_result_finalized` 10482 → **10583**, `_get_closeup_portrait_texture_for_unit` 7503 → **7603**, `_get_hero_id_for_unit_state` 8669 → **8769**, `get_unit_grid_distance` 15114 → **15219** | grep |
| `_refresh_production_battle_hud` 호출 지점 1492, 3210, 5917, 6686, 6706, 6745, 8069, 8139, 10137 | **1501, 3310, 6017, 6786, 6806, 6845, 8170, 8240, 10238** | grep |
| 어댑터 `battle_round`는 A:41 | **A:42** (A:41은 return 시작) | A |
| P·RB·CA·RP·어댑터 줄 번호 | P 줄 번호는 H0와 같다(6,564줄). RB·CA·RP 줄 번호도 같다 | 직접 확인 |
| 현재 행동 HUD "통솔/무력/지력" | 실제 글자는 **"지휘 %d" / "무력 %d" / "지력 %d"** | CA:188-190 |
| 로스터 "병력" 출처를 어댑터 A:20-30으로 기술 | 화면에 보이는 `HpLabel`은 RB가 **`current_troops`/`max_troops`**로 쓴다. 어댑터가 쓰는 `TroopsLabel`(current_hp)은 RB가 숨긴다 | RB:44, 69; C:16012 |
| 상단 버튼 텍스처: 씬 bottom_command 텍스처 | 실제 화면 텍스처는 RP가 `res://assets/ui/battle/top_actions/*.png`로 덮어쓴다 | RP:22-24, 100-103 |
| 후퇴 처리기 실행 순서·disabled 재설정 "미확인" | `_configure_command_bar`(C:6132)가 RP의 `disabled=false`를 덮어 다시 끈다. 월드맵 공격전에서만 C:6140-6149가 켠다. 실행 순서는 추정(①RP 먼저)이며, 그 경우 결과가 "defeat"로 확정되어 ②의 "retreat" 복귀 경로는 실행되지 않는다 | C:1444, 6132, 6152-6166; RP:84, 163-180 |
| 퇴각 토스트 위치 언급 없음 | C가 하단(740..1180 × 820..924)에 놓지만 RP가 매 프레임 화면 중앙(740..1180 × 488..592)으로 옮긴다 | C:10361-10364; RP:66, 153-160 |
| 보급 HUD 채움 C:1657-1697 | **C:1732-1795**. 갱신은 보급 정산(설정·라운드 시작) 때뿐 | C:1717, 11405 |
| 로그 패널 줄 수 언급 없음 | 최대 4줄 FIFO, "- " 없이 join | C:133, 6781-6786, 15931 |
| legacy 로그 패널 `BattleMiniLogPanel` 미기재 | 존재(P:2572). 같은 4줄을 "- " 붙여 표시. production이 숨김 | C:6966-6979, 15957-15958 |

---

## 미확인

1. 같은 시그널(후퇴 `pressed`)에 연결된 두 처리기의 실제 호출 순서. 자식 `_ready` 먼저 → 연결 순서대로 호출로 추정했다. 실행하지 않았다.
2. 렌더 결과 전체. 라벨 넘침, 접힘 레이어 겹침, CA가 바꾼 offset의 실제 모양은 캡처 없이 수치로만 계산했다.
3. 컨테이너 자식(상단 다이아몬드 `SlotNNWrapper`, `BattleSupplyPreviewPanel` 내부)의 화면 사각형. 컨테이너 레이아웃이 필요해 계산하지 않았다.
4. `ResultOverlay` 결과 영상 패널 크기. 비율 상수(C:374-377)로 보면 1152×648 근처로 추정하지만 계산 함수는 읽지 않았다.
5. 적 턴 동안 `active_unit_state`가 정확히 무엇인지(마지막 아군 유지 여부). `C:8460`의 null 대입만 확인했다.
6. CA:185-187에서 레지스트리 stats가 비었을 때 `int(unit.get("leadership"))`가 null을 받아 오류를 낼지. `BattleUnitState`에 `leadership` 필드가 없음은 확인했다.
7. RB(필터 없음)와 `_refresh_production_roster`(용량 필터 있음)의 슬롯 순번이 실제로 어긋나는 전투가 있는지.
8. `RecentLogLabel`이 4줄 이상 접힐 때 라벨 밖으로 넘치는지(clip 없음은 사실).
9. `FloatingAllyCommandPanel` 런타임 위치 계산(C:6292 이후) 전체는 읽지 않았다.
