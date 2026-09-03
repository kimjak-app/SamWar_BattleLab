# WORLDMAP HANDOFF

**Project:** SamWar_BattleLab / 삼국WAR  
**Working branch:** `experiment/imjin-iso-movement`  
**Starting HEAD for this handoff:** `e6852e65eadb490f67cd3e41308d4c434338ee8a`  
**Starting commit:** `월드맵 상단 메뉴 아이콘`  
**Date:** 2026-09-03

---

## 1. 현재 작업 위치

현재 월드맵 / 아이소메트릭 / 신규 월드맵 UI 작업은 **`experiment/imjin-iso-movement` 브랜치에서 계속 진행한다.**

`main`은 현재 작업 브랜치가 아니다.  
이 브랜치에서 기능과 시각 QA를 끝낸 뒤, 이상 없을 때만 최종적으로 `main`에 합친다.

새 세션에서는 반드시 아래 순서로 확인한다.

1. 이 파일 `agent/WORLDMAP_HANDOFF.md` 읽기
2. 브랜치가 `experiment/imjin-iso-movement`인지 확인
3. 해당 브랜치 최신 HEAD 확인
4. 해당 브랜치 기준 실제 파일 확인
5. 그 뒤에만 수정 / 구현

기본 브랜치 `main`을 현재 작업 기준으로 먼저 보지 않는다.

---

## 2. 방금 확정된 상단 메뉴 디자인

메뉴 순서:

1. 테크트리
2. 군사
3. 인사
4. 외교
5. 교역
6. 첩보
7. 정보
8. 시스템

확정 UX:

- 평상시: 8개 메뉴 모두 동일하게 문양 아이콘만 표시
- 테크트리도 예외 없이 기본 상태에서는 라벨을 표시하지 않음
- Hover: 같은 자리에서 문양을 약 `1.10x` 확대
- Hover: 문양 위에 작은 검은 금테 라벨과 메뉴명 표시
- Mouse out: 라벨은 사라지고 문양은 원래 크기로 복귀
- 클릭한 메뉴 id는 내부 selection 상태로 추적할 수 있으나, selection 때문에 라벨을 상시 노출하지 않음
- 아이콘 슬롯 자체는 움직이지 않음
- Hover 때문에 옆 아이콘 위치가 밀리지 않음
- 문양은 사용자가 Photoshop에서 시각적 크기를 맞춘 원본을 그대로 사용
- 엔진에서 메뉴별 임의 optical-scale 보정을 넣지 않음

---

## 3. 확정 아이콘 자산

경로:

`assets/ui/worldmap/top_menu/icons/`

파일:

- `wm_topmenu_techtree.png`
- `wm_topmenu_military.png`
- `wm_topmenu_personnel.png`
- `wm_topmenu_diplomacy.png`
- `wm_topmenu_trade.png`
- `wm_topmenu_intel.png`
- `wm_topmenu_info.png`
- `wm_topmenu_system.png`

아이콘 원본은 축소 재가공하지 않는다.  
표시 크기와 Hover 확대는 Godot UI에서 조절한다.

---

## 4. 이번 구현 범위

Production `WorldMap.tscn`은 직접 수정하지 않는다.

현재 실제 시각 QA 씬인:

`WorldMap_16x9_Test.tscn`

에 독립 컴포넌트:

`WorldMapTopNav.tscn`

을 `CanvasLayer`로 올린다.

TopNav 로직:

`scripts/worldmap/ui/worldmap_top_nav.gd`

기존 임시 단일 버튼:

`scripts/worldmap/ui/worldmap_tech_tree_test_button.gd`

은 파일 삭제하지 않고, Test scene에서 더 이상 instance/controller로 사용하지 않는다.

테크트리 메뉴 클릭은 기존 ProductionWorldMap의
`_open_domestic_tech_tree_overlay_mvp()`
호출을 그대로 유지한다.

다른 7개 메뉴는 이번 단계에서는 시각 hover / click selection 추적까지만 검증하고 실제 기능은 추가하지 않는다.

---

## 5. 1차 시각 QA 기준

사용자 F6 / 실행 화면에서 확인:

- 상단 바가 `동방천하도` 현판과 과하게 겹치지 않는가
- 아이콘 8개의 시각적 크기가 Photoshop 목업과 비슷한가
- 기본 상태에서 8개 모두 문양만 동일하게 보이는가
- 기본 상태에서 아이콘 디테일이 죽지 않는가
- Hover 확대가 과하지 않고 약 10% 수준으로 자연스러운가
- Hover한 메뉴에만 라벨이 나타나는가
- Mouse out 시 해당 라벨이 다시 사라지는가
- Hover 때문에 메뉴 row가 좌우로 흔들리지 않는가
- 테크트리 클릭이 기존 overlay를 정상적으로 여는가
- 좌우 국가/도시 패널, 지도 이동, 도시 클릭, 턴 종료 등 기존 월드맵 기능에 회귀가 없는가

시각 QA 전에는 Production `WorldMap.tscn`으로 이식하지 않는다.

---

## 6. 다음 단계

1. `WorldMap_16x9_Test.tscn`에서 상단 메뉴 1차 F6 QA
2. 사용자 피드백에 따라 bar 폭 / 아이콘 표시 크기 / 간격 / label 위치만 미세조정
3. TopNav visual lock
4. 이후 메뉴 기능 연결 범위를 하나씩 확정
5. 월드맵 작업 전체 QA PASS 후에만 `main` 통합 검토