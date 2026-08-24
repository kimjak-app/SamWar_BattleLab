# WORLD_MAP_UI_PRODUCTION_PLAN

**Project:** SamWar_BattleLab / 삼국WAR  
**Phase:** WorldMap Production UI  
**Status:** Design Lock / W2 entry baseline  
**Date:** 2026-08-24  
**Working branch:** `feature/worldmap-background-refresh`  
**Main baseline:** `e0de54c965b3b2beab4110063c3e253e218acb7b`  
**Latest confirmed W1 implementation commit:** `0bbf2a8309c0c6be6663296fb337c8e716160928`

---

## 0. 문서 목적

이 문서는 월드맵을 본격적인 Production UI로 확장하기 위한 **구현 기준선**이다.

앞으로 새 세션을 시작할 때는 이 문서를 우선 기준으로 삼고, 실제 GitHub `main`, 현재 작업 브랜치, 로컬 HEAD, dirty 상태를 다시 확인한 뒤 작업한다.

핵심 원칙은 다음과 같다.

> **Production `WorldMap.tscn`을 곧바로 계속 뜯지 않는다.**  
> **얇은 WorldMap UI Test 씬 + 독립 UI 컴포넌트 구조에서 디자인·동작·실데이터 바인딩을 먼저 검증한 뒤 Production에 이식한다.**

---

# 1. 현재 W1 완료 기준선 — LOCK

## W1-1 ~ W1-4 WorldMap Background Refresh

현재 월드맵 배경은 신규 `동방천하도` 아트로 교체되었다.

### 확정 배경 자산

- `assets/source/worldmap/worldmap_master_4096x2912.png`
- 실제 Photoshop master: **4096 × 2912**
- Godot world 좌표는 기존 약 **2048 × 1456**을 유지
- 4분할 AtlasTexture + 0.5 scale 방식으로 기존 runtime 좌표계를 보존

### 확정 카메라 정책

- 16:9 화면에서 지도를 **왜곡 없이 화면 가득 cover**
- 제목/상단을 우선 보존
- 지도 원본 aspect와 viewport aspect 차이 때문에 하단 일부는 초기 화면에서 crop 가능
- 기존 pan / zoom 기능은 유지

### 도시 위치

신규 지도용 13개 도시 rough seed 배치는 완료되었다.

사용자가 Godot에서 `CityMarker_*` 부모 노드를 직접 미세 조정하면 도시 점, 이름, 선택 링, 클릭 영역, 관련 시각 요소가 함께 이동하는 구조를 유지한다.

### Route

도시 위치 변경 시 land / sea route의 양 endpoint가 해당 `CityMarker`를 자동 추종하도록 보정되었다.

---

# 2. W1-5 / W1-6 Turn-End Compass — LOCK

턴 종료 나침반 MVP 및 3-Layer refinement가 완료되었다.

## 최종 자산

- `assets/worldmap/ui/worldmap_turn_compass_base.png`
- `assets/worldmap/ui/worldmap_turn_compass_needle.png`
- `assets/worldmap/ui/worldmap_turn_compass_cap.png`

세 파일 모두 **1024 × 1024**, 동일 중심축 기준.

## 최종 구조

1. **Base** — 고정
2. **Needle** — 회전
3. **Cap** — 고정

회전은 `Needle` 레이어에만 적용한다.

## 최종 회전 계약

- 아군 턴 종료 클릭
- 기존 턴 종료 로직은 잠시 보류
- needle이 **정확히 1바퀴 연속 회전**
- 회전 완료 후 기존 턴 종료 / 적군 턴 처리 실행
- Base와 Cap은 회전하지 않음
- 중복 클릭 방지

### 중요

턴 처리와 회전을 동시에 실행하면 turn processing이 렌더링을 막아 회전이 끊겨 보였다. 따라서 **`Compass pre-roll -> original turn-end callback` 직렬 실행 구조를 유지**한다.

관련 스크립트:

- `scripts/worldmap/worldmap_turn_compass.gd`
- `scripts/worldmap/worldmap_background_refresh_tool.gd`

이 구조는 W2 UI 작업에서 임의로 변경하지 않는다.

---

# 3. WorldMap 최종 UI 방향

현재 확정 목업을 Production 목표로 삼는다.

## 3.1 기본 화면

### 중앙

- `동방천하도`가 메인 전략 공간
- 도시 / 항로 / 이동 / 선택 / 이벤트 등 실제 world interaction 유지

### 상단 중앙 메뉴

목업 기준 메뉴:

- 테크트리
- 군사
- 인사
- 외교
- 교역
- 첩보
- 정보
- 시스템

상단 메뉴는 월드맵의 **국가 운영 허브** 역할을 한다.

### 좌측 패널

플레이어 국가 중심 정보.

현재 목업 기준 주요 영역:

- 플레이어 국가 / 턴 / 수도
- 국가 안정도
- 세금 수준
- 재상 / 국가 운영 인물
- 국가 창고 / 자원
- 아군 턴 종료
- 저장 / 불러오기 / 초기화
- 이번 턴 행동 / 로그

### 우측 패널

현재 선택한 도시 중심 정보.

목업 기준 주요 영역:

- 도시 이름 / 세력
- 안정도
- 민심 / 치안 / 상업 / 농업 등 도시 상태
- 태수
- 주둔 무장
- 선택 도시 관련 액션

**좌측 = 국가 전체**, **우측 = 현재 선택 대상**이라는 정보 계층을 유지한다.

---

# 4. Modal / System Window 방향

테크트리 등 대형 시스템은 별도 scene 전환이 아니라 **현재 월드맵 위에 modal/window로 연다.**

## TechTree 목표

목업 기준:

- 중앙 대형 modal
- 국가 테크트리 / 도시 테크트리를 같은 화면에서 비교 가능
- 노드 연결선
- 연구 가능 / 잠김 / 완료 / 진행 상태 구분
- 하단 선택 기술 상세 정보
- 닫기 버튼
- 내부 scroll 가능

배경 월드맵은 계속 존재하되, modal이 열릴 때 입력 / z-order가 명확해야 한다.

---

# 5. W2 핵심 아키텍처 — LOCK

## 결론

**Thin WorldMap Test Harness + Independent UI Components** 방식으로 간다.

전투 UI에서 검증된 "production 보호 → test에서 완성 → production 이식" 원칙을 월드맵에도 적용한다.

다만 거대한 `WorldMap.tscn`을 통째로 복사하는 방식은 사용하지 않는다.

## 5.1 금지

- `WorldMap.tscn` 완전 복사본을 장기간 별도 유지
- `worldmap_main.gd` 전체 복제
- Production 본체에서 디자인 실험 반복
- 하나의 거대한 신규 `.gd`에 모든 UI 로직을 몰아넣기
- UI를 이유로 기존 저장/턴/도시/외교/장수 로직을 동시에 리팩터링

## 5.2 목표 구조

### Test Host

예정 이름:

- `WorldMap_UI_Test.tscn`

역할:

- 실제 WorldMap 환경을 최대한 그대로 사용
- 신규 Production UI 컴포넌트를 overlay / instance
- 실제 해상도, camera, city selection, input, modal z-order까지 검증

정확한 instance / inherited scene 방식은 **W2-1 실제 scene tree 감사 후 확정**한다.

### 독립 UI Component 후보

예정 명칭이며 W2-1 감사에서 실제 repo naming에 맞춰 확정한다.

- `WorldMapTopNav.tscn`
- `WorldMapNationPanel.tscn`
- `WorldMapCityPanel.tscn`
- `WorldMapModalRoot.tscn`
- `WorldMapTechTreeWindow.tscn`

필요 시 군사 / 인사 / 외교 등도 독립 컴포넌트로 확장한다.

---

# 6. W2-1 구조 감사 범위

새 세션 첫 작업은 **W2-1 WorldMap UI Boundary Audit**이다.

전체 코드를 무작정 재작성하지 않는다.

다음 경계만 우선 정확히 실측한다.

1. `WorldMap.tscn` 실제 scene tree
2. `worldmap_main.gd` 실제 줄 수와 책임 범위
3. `WorldMapUI` root 및 현재 좌/우 패널 구조
4. 상단 메뉴 / 버튼 생성 및 signal 연결 위치
5. 도시 선택 event → 우측 패널 refresh 흐름
6. 국가 데이터 → 좌측 패널 refresh 흐름
7. 아군 턴 종료 callback
8. 저장 / 불러오기 이후 UI refresh hook
9. modal / popup 현재 관리 방식
10. camera pan / zoom과 UI input 분리 방식
11. viewport resize 대응 방식
12. current production UI 중 재사용할 것 / 폐기할 것 분류

### W2-1 Deliverable

- UI 경계 audit 결과
- 안전하게 분리 가능한 component 목록
- production logic과 강결합된 지점 목록
- `WorldMap_UI_Test.tscn` 생성 방식 확정

---

# 7. 작업 로드맵

## W2-1 — WorldMap UI Boundary Audit

실제 구조 감사 및 테스트 아키텍처 확정.

## W2-2 — WorldMap_UI_Test Harness

- 얇은 test host 생성
- 실제 map / camera / city selection 유지 확인
- Production 본체와 test layer의 책임 분리

## W2-3 — Top Navigation

목업 기준 상단 메뉴바 구현.

검증:

- hover
- selected
- disabled
- modal open / close
- 해상도 대응

## W2-4 — Left Nation Panel

국가 운영 패널 구현.

1차는 sample data로 layout lock, 이후 실제 데이터 바인딩.

## W2-5 — Right City Panel

선택 도시 정보 패널 구현.

검증:

- empty state
- city selected
- city changed
- governor / stationed heroes
- 관련 도시 정보 refresh

## W2-6 — Modal Framework + TechTree

- 공용 modal host
- z-order / mouse capture
- close contract
- TechTree window 이식

## W2-7 — Real Data Binding

sample data를 제거하고 실제 runtime data와 연결.

특히 국가 상태, 자원, 도시 정보, 태수 / 장수, turn refresh, save/load refresh를 실제 source of truth와 연결한다.

## W2-8 — Production Integration / Regression

Test에서 승인된 UI만 Production으로 이식.

회귀 테스트 후 merge 준비.

---

# 8. UI 구현 원칙

## 8.1 Sample First, Real Data Second

디자인을 잡는 동안 domain logic까지 동시에 건드리지 않는다.

1. sample data로 layout / interaction 확정
2. 실제 source of truth 감사
3. real data binding
4. refresh QA

순서를 지킨다.

## 8.2 Source of Truth 단일화

UI 내부에 gameplay 데이터를 복제 저장하지 않는다.

UI는 기존 runtime/domain 상태를 **표시하고 명령을 전달**하는 역할로 유지한다.

## 8.3 Component 책임 분리

각 UI component는 자신의 표시와 입력만 책임진다.

예:

- TopNav는 메뉴 상태 / 클릭
- NationPanel은 국가 정보 표시
- CityPanel은 선택 도시 표시
- ModalRoot는 modal open/close 및 input ownership

월드맵 core turn / save / city / diplomacy logic을 component 안에 새로 구현하지 않는다.

## 8.4 Production 보호

Test QA PASS 전에는 기존 Production 기능을 삭제하거나 대규모 교체하지 않는다.

필요한 경우 adapter / presenter / refresh hook을 추가하되, 기존 gameplay contract를 먼저 보존한다.

---

# 9. Visual / UX 기준

## 9.1 스타일

- 현재 `동방천하도`의 고지도 / 황동 / 목판 / parchment 계열 유지
- UI가 지도보다 튀지 않되 게임 조작 요소는 확실히 읽혀야 함
- 금색 강조는 selection / active / important action에 제한적으로 사용

## 9.2 지도 위 정보 우선순위

1. 현재 선택 도시 / 선택 경로
2. 도시 marker
3. 도시 이름
4. route / sea route
5. 이벤트 / 이동 표시
6. 장식 요소

장식이 gameplay marker를 가리지 않는다.

## 9.3 Empty / Active State

좌우 패널은 선택 전과 선택 후가 명확히 달라야 한다.

특히 우측 CityPanel은:

- 미선택: `도시를 선택하세요`
- 선택: 실제 도시 정보

두 상태를 명확히 구분한다.

## 9.4 Modal

modal이 열릴 때:

- background world interaction 차단 여부 명확
- modal 내부 scroll만 작동
- 닫기 동작 일관
- modal 뒤 WorldMap runtime 상태는 유지

---

# 10. QA Gate

각 W2 작업은 최소 다음을 확인한다.

### Static / Structure

- parse error 없음
- node path 오류 없음
- 기존 signal 중복 연결 없음
- scene / script 책임 과밀화 없음

### Runtime

- 1920×1080 기준 layout 정상
- camera pan / zoom 정상
- 도시 선택 정상
- 좌우 panel 입력이 map input과 충돌하지 않음
- Turn End 정상
- 3-Layer Compass 정상
- modal z-order 정상
- modal close 후 input 복귀 정상
- save/load 후 UI refresh 정상

### Regression

신규 UI 작업 때문에 아래가 깨지면 FAIL:

- 기존 도시 클릭
- route
- camera
- turn progression
- save/load
- hero/city state
- 기존 world gameplay

---

# 11. Git / 작업 운영 규칙

1. **모든 작업은 작업번호를 붙인다.**
2. 작업 시작 전 실제 최신 branch / HEAD / `main` / dirty 상태를 확인한다.
3. 예상하지 못한 사용자 변경은 reset / restore / stash / delete하지 않는다.
4. 큰 변경 전에 target file의 최신 SHA를 재확인한다.
5. user asset / `.import` 파일을 임의 삭제하지 않는다.
6. local Godot live QA는 사용자가 수행하고, assistant는 repo/static 검증을 최대한 선행한다.
7. Test QA PASS 후 Production 이식.
8. Production 이식 후 regression PASS 전까지 merge하지 않는다.

---

# 12. 다음 세션 시작 지시문

새 채팅에서는 아래 기준으로 시작한다.

> **채코치, SamWar_BattleLab 새 세션 시작. `WORLD_MAP_UI_PRODUCTION_PLAN.md`를 기준 문서로 잡고 W2-1 WorldMap UI Boundary Audit부터 진행해줘. 먼저 실제 최신 branch/HEAD/main/dirty 상태를 재확인하고, `WorldMap.tscn`, `worldmap_main.gd`, WorldMapUI, 좌우 패널, 도시 선택 refresh, 턴 종료, modal/popup, save/load UI refresh 경계를 감사한 뒤 `WorldMap_UI_Test.tscn`의 안전한 thin test 구조를 확정해줘. Production 본체는 아직 대규모 수정하지 말 것. 모든 작업은 반드시 작업번호를 붙일 것.**

---

# 13. 최종 결정

월드맵은 이제 단순한 배경 화면이 아니라 삼국WAR의 **메인 전략 허브**로 개발한다.

전투 UI에서 사용한 안전한 검증 흐름을 발전시켜:

> **독립 UI Component 제작 → 실제 WorldMap Test Host에서 검증 → 실데이터 바인딩 → Regression → Production 이식**

순서로 진행한다.

이 문서의 설계 방향을 변경해야 할 경우, 코드부터 바꾸지 말고 먼저 설계 변경 내용을 사용자와 확인한 뒤 문서를 갱신한다.
