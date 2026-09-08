# 삼국워 효과음 연결 — 2026-09-08

기준: `feature/worldmap-territory-techtree-hud`, `9c6309212282c8a7fef7e852b8fa5526e724c4e5`.
사용자 지시: 구조 분석 후 효과음 추가. 후속 요청으로 월드맵 상단 시스템에서 효과음 ON/OFF·볼륨·중복 재생 제한 및 영상 원음 ON/OFF·볼륨을 조절하도록 변경. 영상 원음 기본 OFF.

## 실제 연결

| 위치 | 트리거 | 소리 |
|---|---|---|
| 공통 메뉴 | 활성 BaseButton.pressed, 동적 생성 포함 | 목재 클릭 |
| 월드맵 도시 | _on_city_marker_selected | 도시 선택 |
| 월드맵 턴 | _on_ally_turn_end_pressed의 유효성 검사 통과 후 | 낮은 북 두 타 |
| 외교·첩보·무역 | action presentation 영상 시작 | 종음·바람·금속 동전음 |
| 행동 결과 | _show_result의 success 우선 판정, 없으면 ok | 성공/실패 구분 |
| 결과 닫기 | _hide_result, 표시 중인 경우만 | 두루마리 |
| 연구 | 완료 카드 실제 표시 | 상승 종음 |
| 부대 이동 | _show_move_dust_for_unit | 짧은 행군 |
| 공격·피격 | slash/spark 공통 시각 효과 진입 | 바람/금속 타격 |
| 원거리 | arrow projectile / gunner shot | 활시위/화승총 합성음 |
| 방어 | 유효 방어 확정 / 방어 피격 표시 | 금속 방어음 |
| 장수 스킬 | 공유 영상·구형 영상·정적 컷인 표시 | 북소리 |
| 라운드·지원군·승패 | 토스트 큐에서 실제 표시하는 순간 | 구분된 알림/승패음 |

21개 원본 합성 WAV. 실제 무기 녹음은 아님. 44.1kHz/16bit/mono, 페이드와 피크 제한. 외부 음원 없음. 같은 파일명으로 교체 가능.

## 오디오 구조

`GameAudio`를 첫 autoload로 등록. `SamWarSFX` 버스와 8개 플레이어, 전용 RandomNumberGenerator로 게임 판정 RNG에 영향 없음. 70/160ms 중복 제한. AudioEffectHardLimiter로 출력 제한. 초기 볼륨 65%. 음소거/볼륨은 별도 `user://samwar_audio.cfg`에 저장하여 게임 저장 스키마와 분리.

모든 VideoStreamPlayer는 생성 시 `SamWarVideo` 버스로 연결하고 플레이어 볼륨은 0dB로 유지. 버스에서 시스템 메뉴의 ON/OFF 및 볼륨을 적용하므로 재생 중인 영상과 새로 생성된 영상 모두 같은 설정을 사용. 강제 -80dB 코드는 제거. 영상의 재생·스킵·완료 콜백은 유지. 기본 원음 OFF. 기존 월드맵 오디오 setter도 공통 설정에 위임.

참조: [Godot 4.6 HardLimiter](https://docs.godotengine.org/en/4.6/classes/class_audioeffecthardlimiter.html), [VideoStreamPlayer bus](https://docs.godotengine.org/en/4.6/classes/class_videostreamplayer.html).

## 검증 결과

- `python3 tools/validate_samwar_sfx.py`: PASS. 21개 WAV 규격·무음 여부·피크·페이드·재생성 해시·등록 경로·정적 이벤트 ID 확인.
- `python3 tools/validate_single_side_exhaustion_turn_order.py`: PASS. 기존 턴 순서 정적 계약.
- `python3 tools/validate_worldmap_to_battle_input_lifecycle.py`: PASS. 월드맵→전투 입력 전환 정적 계약.
- `git diff --check`: PASS.
- Godot 실행기 미설치: GDScript 파싱, 리소스 임포트, 실제 씬 실행 및 청음 검증은 수행하지 못함. 자동 검증 PASS를 런타임 완료로 취급하지 않음.

## 남은 실제 검수

1. `tests/scenes/SFX_Preview.tscn` F6: 21개 소리 개별 청음. 볼륨·음소거 후 재실행하여 유지 확인.
2. 실제 월드맵 테스트 씬: 도시·메뉴·턴 종료·행동 성공/실패·연구 완료.
3. 외교/첩보/무역·장수·전투 결과 영상: 원음 무음, 스킵 후 정상 진행.
4. 전투: 아군/적군 이동·공격·화살·총·방어·정적/영상 스킬·지원군·승패.
5. 빠른 연속 클릭/자동전투: 소리 겹침, 지연, 청감 확인.

## 범위와 후속

이번 연결은 표시 계층에 한정. 전투 수치·AI·턴 처리·저장 데이터는 수정하지 않음. 공격 효과음은 기존 시각 효과 호출 시점에 맞춘 첫 연결이며, 각 병종 애니메이션 프레임별 정밀 폴리는 미적용. 상단 시스템 버튼에서 `WorldMapAudioSettings.tscn` 팝업을 열어 5개 설정 및 미리듣기를 사용. 설정은 즉시 적용·자동 저장. 중복 제한 OFF는 같은 소리의 70/160ms 간격 제한만 해제하며 최대 8동시 재생과 출력 리미터는 유지. 지속 환경음/BGM/성우 음성은 포함하지 않음.

## 시스템 메뉴 후속 변경

`WorldMapTopNav.tscn`에 편집 가능한 `WorldMapAudioSettings.tscn` 팝업 인스턴스 추가. `worldmap_top_nav.gd`의 system 버튼을 팝업에 연결. `worldmap_audio_settings.gd`가 토글·슬라이더·퍼센트 표시·미리듣기·닫기·ESC를 연결. 창을 열 때 현재 상태를 읽되 no-signal setter로 불필요한 저장/재생 방지.

`python3 tools/validate_samwar_audio_settings.py`: PASS. 실제 노드 경로와 메서드, 메뉴 진입, 다섯 설정의 읽기/쓰기, 영상 강제 음소거 제거를 정적 검증. 런타임 UI 및 재시작 설정 복원 검증은 아직 수행하지 못함.

추가 수동 검수: 상단 시스템 열기 → 효과음/영상 각각 ON/OFF 및 0/65/100% → 닫기/다시 열기 및 게임 재시작 → 월드맵 영상과 전투 컷인 모두 확인. 원음 트랙이 없는 영상에서는 ON이어도 원음이 나오지 않음. 볼륨 0%는 ON이어도 무음. 실제 팝업 크기/글자 잘림/입력 차단은 Godot에서 확인 필요.
