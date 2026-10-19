# M1-b 구현 중간 점검 — 기존 contract validator 예외 필요

## 최신 상태 (아래 초기 점검보다 우선)

사용자가 독립 Lab 종료 시 오디오 정리를 허용했다. 신규 `battle3d_engine_host.gd`의 `_exit_tree`에만 정리를 구현했다. 기존 엔진/오디오/3D 파일은 수정하지 않았다.

신규 씬/표시 스크립트/호스트 구현 후 실제 Godot headless 통합 테스트 **139 checks, failures=[]**. 완료 함수를 직접 호출하지 않고 카메라 레이 → 셀 입력 → 엔진 Tween → 이벤트 → 표시를 검증했다. 선택/이동/방향 확정/취소/재이동, 10개 view 일치, 거절 시 40변수 지문 불변, 실제 실행 경로 재생, 우회 경로와 grid distance 구별, 엔진 phase가 연출보다 앞서 진행하는 경우, 오디오 정리, 새 인스턴스 초기화가 포함된다. 종료 때 ObjectDB 및 2 resources 경고가 남아 있다.

첫 전체 회귀 실행에서 **기존 `tools/validate_battle3d_contract.py:24`가 신규 엔진 호스팅을 금지하는 범위 충돌**을 발견했다. 이 validator는 C0–C3 조회 전용 단계의 불변조건을 모든 `scripts/battle3d/*.gd` 및 `test_battle3d_*.gd`에 적용한다:

```python
assert 'WorldMap.tscn' not in text and 'Battle_Main.tscn' not in text
```

그러나 M1-b 지시서 §2는 신규 host에서 `Battle_Main.tscn` 인스턴스를 명시적으로 요구하고, §3은 기존 validator 수정을 금지한다. 새 파일의 경로 문자열을 쪼개거나 간접 로딩해 이 검사를 우회하지 않았다. §3에 따라 기존 파일 수정 없이 멈추고 보고한다.

### 필요한 최소 조정 (미적용)

`tools/validate_battle3d_contract.py`의 해당 assert만 다음처럼 바꾸도록 허용 요청:

```diff
-    assert 'WorldMap.tscn' not in text and 'Battle_Main.tscn' not in text
+    assert 'WorldMap.tscn' not in text
+    if file != S/'battle3d_engine_host.gd':
+        assert 'Battle_Main.tscn' not in text
```

예외는 **신규 host 파일 하나만**이다. 기존 조회 Lab과 기존 테스트의 금지는 유지한다. 새 M1-b validator가 host의 호출/쓰기 경계를 추가 검사한다. 승인 전 변경하지 않는다.

### 검증 한계와 남은 작업

- 신규 통합 검사 139 checks PASS / 신규 범위 validator PASS.
- 전체 회귀는 완료하지 못했다. 기존 contract validator exit=1 확인 후 중단했다.
- Python subprocess로 실행한 다수 Godot 테스트 및 GUI 실행에서 native signal 11/exit 3221225477이 발생했다. 같은 기존 calendar 테스트를 PowerShell에서 직접 실행하면 10 checks PASS. 실행 경로/환경 문제 가능성이 있으나 원인 미확정이며 코드 문제로 단정하지 않는다.
- 실제 Godot GUI 창 확보 및 수동 캡처는 미완료. 초기 GUI 실행은 기본 renderer 및 compatibility 모두 native crash. 프로젝트 설정 변경 없음.
- 4종 변조 프로브, 전체 회귀 재실행, 최종 TIP 고정, 최종 검수 패키지는 미완료.
- 임시 모델은 infantry/cavalry를 재사용하며 archer/gunner 표시는 모델만 infantry로 대체, 실제 14필드와 병종 라벨은 보존한다.
- 신규 UI는 terrain ray로 셀을 선택한다. 인접 셀을 앞쪽 병사의 큰 pick box가 가로채지 않도록 신규 입력 코드만 조정했다.
- S1-2와 기존 3D/골든은 변경하지 않았다. 공격/AI/턴은 미연결이다.
- 다음 단계: 위 validator의 단일 파일 예외 승인 후 실행환경 원인 분석, 모든 필수 검증, 구현/TIP 고정 분리 커밋. 현재는 로컬 중간 체크포인트이며 push 없음.

원문 로그는 작업 폴더의 `M1B_integration.txt`, `M1B_Evidence/full_suite_results.json`, `M1B_Evidence/*.log`, `M1B_gui*_errors.txt`에 보존한다.

---

# 초기 착수 점검 (오디오 조정 승인 전 기록)

## §4 결과 (구현 완료 보고가 아님)

- 기준: fetch 후 `origin/integration/p1-engine-core-20261019` = `22b7ee73f567132ad1b8060adae4a4bb8d2f5e8c` 일치.
- 브랜치: `feature/battle3d-m1b-engine-move-20261019`. push 없음.
- 신규 진단 테스트만 작성. 기존 컨트롤러/서비스/3D/프로젝트/워크플로 수정 없음.
- SubViewport 1280×720, UPDATE_DISABLED, Container 없이 Battle_Main 호스팅.
- 10유닛 생성, intro skip 후 ally_turn 진입.
- 이순신 선택 후 UI hover=false, 2D 이동 범위 overlay=true.
- 기존 `_try_direct_move_to_cell(Vector2i(3,7))` 수락. 완료 함수 직접 호출 없이 타이머/프레임 진행으로 facing_select 도달, 실제 cell=(3,7), unit_moved 실행 경로 [[3,8],[3,7]].
- **전투 SubViewport 삭제 0.5초 후에도 전역 GameAudio SFXVoice0가 round_start.wav 재생 중. 두 번 관찰.**
- 3D 활성 카메라/HUD 화면 격리, 재시작 오염, 실제 데스크톱 조작은 아직 미검증.

## 멈춘 이유

사용자가 적용을 지시한 M1-b 지시서 §4는 착수 가정이 다르면 구현 전 보고하도록 하고, §4.4는 GameAudio를 관찰만 하고 변경하지 않도록 한다. §5.5는 씬 종료 시 오디오 잔류 없음을 요구한다. 현재 호스팅 방식은 자동으로 이 조건을 만족하지 않는다. §6.7에 따라 기존 문제를 수정하지 않고 보고한다.

이는 영구 루프나 새 회귀로 판정한 것이 아니다. 전투 씬보다 오래 사는 전역 효과음의 **재생 잔류**가 확인된 것이다. 기존 전역 음성 풀의 종료 정책과 새 Lab의 종료 요구가 다르다.

## 원인과 최소 조정안 (미적용)

`project.godot`의 GameAudio는 autoload다. `scripts/audio/game_audio.gd`가 자식 SFXVoice0..7을 소유하며, 컨트롤러 `_play_next_battle_toast` 경로에서 round_start를 재생한다. Battle_Main을 삭제해도 GameAudio는 삭제되지 않는다. 기존 S1 테스트는 마지막에 음성 종료 대기와 stop/stream 해제로 정리하지만, 이는 테스트 정리 코드이지 실제 Lab 종료 정책이 아니다.

권장: **독립 M1-b 진입점에 한해**, 신규 host의 종료 시 전역 SFX 음성 정리를 허용하도록 지시서 §4.4를 좁게 조정한다. 기존 파일 diff는 0으로 유지한다. 신규 host에 예상되는 최소 코드 형태:

```gdscript
func _exit_tree() -> void:
    var audio = get_tree().root.get_node_or_null("GameAudio")
    if audio == null:
        return
    for voice in audio.get_children():
        if voice is AudioStreamPlayer:
            voice.stop()
            voice.stream = null
```

이는 독립 Lab의 전역 SFX 전체를 멈춘다. 월드맵과 공유하는 M7에 그대로 적용하면 안 된다. 기존 GameAudio 소스, 영구 음량/활성 설정은 바꾸지 않는다. 승인 전 적용하지 않는다.

대안: 종료 시 기존 one-shot 음성의 자연 종료를 허용하고, 제한시간 내 종료 및 재시작 중복 여부를 검사하도록 §5.5를 변경한다. 요구를 낮추는 변경이므로 임의 선택하지 않았다.

## 표시 에셋 확인

실제 roster는 infantry/cavalry 외 archer/gunner도 포함한다. 기존 `_spawn_unit`은 unit_type 그대로 GLB 경로를 만들지만, 에셋은 양측 infantry/cavalry만 존재한다. 기존 파일을 고치지 않고 신규 스크립트에서 표시용 복사본만 infantry 임시 모델로 매핑하고, 14필드 실제 view/병종 라벨은 원본을 보존하는 방식으로 처리 가능하다. 이 사항 자체는 엔진 변경 사유가 아니다.

## 검증

실행: `godot --headless --path . --script res://tests/scripts/test_battle3d_engine_move_preflight.gd`

최종 진단 테스트 exit=1. 이동 점검 성공, 오디오 종료 조건 실패를 의도적으로 드러낸다. CI에는 추가하지 않았다. 종료 시 ObjectDB leak 및 resources 3 경고도 출력되었으며 원인 분류는 미완료다. 전체 회귀/4종 음성 프로브/실제 3D 입력 테스트는 아직 실행하지 않았다.

핵심 원문:

```text
M1B PREFLIGHT roster=10 phase=ally_turn
M1B PREFLIGHT ui_hover=false overlay=true
M1B PREFLIGHT accepted=true
M1B AUDIO AFTER FREE SFXVoice0 playing=true stream=(res://assets/audio/sfx/round_start.wav)
M1B MOVE PREFLIGHT PASS
M1B EXIT AUDIO FAIL: global voice still playing after scene free
EXIT=1
```

전체 실행 출력은 별도 `M1B_preflight_output.txt`로 제공한다. M1-b 구현 커밋/완료가 아니라 착수 점검 체크포인트다. 다음 단계는 오디오 종료 정책 조정 확정 후 신규 3D 연결 구현이다. 공격/적 턴은 계속 범위 밖이다.
