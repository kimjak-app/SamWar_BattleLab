# HUD 블록 5 조사: 컷인 영상·결과 화면·토스트 (2026-10-25)

- 기준: 브랜치 `feature/hud-block5-cutin-survey-20261025`, 끝 커밋 `3f8f83e` (`git log -1`) [사실]
- 조사만 했다. 코드·씬·자원 변경 0. Godot는 실행하지 않았다. [사실]
- 표기: **[사실]** = 코드 file:line, 내가 돌린 명령, 공식 문서 URL로 확인. **[추정]** = 추론.
- 줄 번호 약어 (지금 커밋 기준으로 다시 셌다):
  - C = `scripts/battle_web_import_test.gd` (16,175줄, `wc -l`) [사실]
  - EP = `scripts/battle3d/battle3d_engine_play.gd` (1,523줄, `wc -l`) [사실]. 지난 제안서(1,465줄 기준)와 줄 번호가 다르다.
  - P = `scenes/battle/Battle_Production.tscn` (`Battle_Main.tscn`은 이 씬을 그대로 인스턴스한다, `Battle_Main.tscn:3-5`) [사실]
  - REGC = `scripts/ui/cutin/korea_mvp_hero_cutin_registry.gd`, HCP = `scripts/ui/cutin/hero_cutin_presentation.gd`
  - TL = `scripts/battle/services/battle_tactic_event_log_service.gd`
- 함께 만든 표: `agent/data/HUD_BLOCK5_CUTIN_REGISTRY_20261025.csv` (레지스트리 21줄, ffprobe 값 포함) [사실]

## 핵심

1. 컷인 영상이 있는 장수는 **21명**이다. 레지스트리 두 개(`korea_mvp` 13명 + `imjin_demo` 8명)에 모두 `enabled: true`이고, 영상·제목 그림 42개 파일이 **전부 있다**(빠진 파일 0). [사실: 아래 2절 명령]
2. 21개 영상은 모두 **Ogg Theora, 1280×720, 30fps, 120프레임, 4.000초, 소리 없음**이다. 합계 **262,267,064바이트(약 250.1 MiB)**, 제목 PNG 합계 18,387,439바이트(약 17.5 MiB). [사실: ffprobe]
3. Godot 4.6 코어가 지원하는 영상 형식은 Ogg Theora 하나다. 이 파일들은 그 형식이라 **그대로 재생된다고 본다.** 공식 문서로 형식 일치는 [사실], 실제 재생은 실행하지 않아 [추정]. 2D가 이미 같은 파일을 `VideoStreamPlayer`로 튼다(C:4816, HCP:58, HCP:75). [사실]
4. **엔진은 이미 컷인 동안 멈춘다.** 랩 안의 엔진(2D 전체)이 보이지 않는 SubViewport 안에서 컷인을 틀고, 끝나야(4.01초 tween 또는 4.60초 예비 타이머) 특기 효과를 적용한다(C:4840-4843, C:4867-4882, HCP:79-80). 랩은 그동안 `is_demo_animating`으로 입력을 막는다(C:4742, EP:577-579). 지금 랩은 이 4초 동안 글자만 띄운다. [사실]
5. 그래서 랩은 `skill_cast`(시작)와 첫 `skill_effect`(끝) 사이에 영상을 틀면 엔진 시간과 맞는다. 새 엔진 쓰기는 필요 없다. [추정]
6. 컷인 조회에 필요한 hero_id는 **기존 읽기 `_get_unique_skill_for_unit`의 `hero_id` 키**로 얻을 수 있다. 2D도 이 키를 먼저 쓴다(C:4847-4849). 리졸버는 hero_id가 빈 특기를 거절한다(`battle_skill_resolver.gd:85-86, 139-141`). N6은 2D의 "시전자-특기 주인 일치" 검사에만 쓰인다. [사실]
7. 새로 승인이 필요한 것은 사실상 **컷인 레지스트리(엔진 밖 정적 클래스) 사용 1건**과 **퇴각 대사 N13(보류 그대로) 1건**이다. 결과·라운드·지원군·특기 토스트는 랩이 이미 읽는 이벤트로 된다. [사실: 5절 표]
8. N5·N6은 승인됐고, 감싸기 함수(`hud_status_entries`·`hud_hero_id`)는 **블록 4-1 가지** `feature/hud-block41-ally-roster-actor-20261025`(끝 `ed4993b`, EP:207-217)에 있다. 이 조사의 기준 `3f8f83e`에는 아직 합쳐지지 않아 EP에는 N1~N4 `hud_*`만 있다(EP:150-176). [사실]

---

## 1. 컷인·영상 목록

### 1-0. 노드 위치 [사실]

| 노드 | 종류 | 위치 (P:줄) | 스크립트 변수 (C:줄) |
|---|---|---|---|
| `HeroCutinOverlay` | CanvasLayer, `layer = 40`, 처음 숨김 | P:6538-6540 | `hero_cutin_overlay` C:1356 |
| `HeroCutinOverlay/HeroCutinInputBlocker` | Control 1920×1080, `mouse_filter` 줄 없음 | P:6542-6546 | — |
| `HeroCutinOverlay/HeroCutinViewport` | Control 1152×648, 화면 가운데 | P:6548-6561 | — |
| `.../HeroCutinPresentation` | `scenes/ui/cutin/hero_cutin_presentation.tscn` 인스턴스 | P:6563 | `hero_cutin_presentation` C:1357 |
| 그 안 `CutinStage/VideoBackgroundPlayer` | VideoStreamPlayer, `expand = true`, 1014×570 (무대 1014×415로 잘림) | `hero_cutin_presentation.tscn:17-33` | HCP:22 |
| `BattleUI/SkillCutinLayer` | Control 전체 화면, 숨김 | P:3862-3870 | C:1348 |
| `BattleUI/SkillCutinLayer/VideoStreamPlayer_Cutin` | VideoStreamPlayer, `expand = true` | P:3882-3889 | C:1350 |
| `CutinOverlay` | CanvasLayer, 숨김, `CutinImage`·이름·대사 Label | P:6468-6476 | C:1370-1373 |
| `ResultOverlay/VideoStreamPlayer_Result` | VideoStreamPlayer, 숨김, `expand = true` | P:6503-6518 | C:1376 |

- `HeroCutinInputBlocker`는 `mouse_filter`를 적지 않았다(P:6542-6546). Control의 기본값은 마우스를 막는 STOP이라 컷인 동안 클릭을 막는다고 본다. [사실: 씬 / 추정: 기본값 동작]

### 1-1. 영웅 컷인 (레지스트리 영상) `_play_committed_hero_cutin` C:4782-4844

- **호출 시점** [사실]
  - 특기 확정 함수 `_begin_unique_skill_sequence` C:4715에서 부른다(C:4754).
  - 그 전에 기세를 쓰고(C:4735) `skill_cast`를 기록한다(C:4738, TL:97-108). 즉 **`skill_cast`는 컷인보다 먼저 로그에 들어간다.**
  - 이 함수에 들어오는 길: 수동 대상 선택(C:4585), 자동 판단 후 0.42초 미리보기(C:4615 → C:4706 → C:4712, `UNIQUE_SKILL_AUTO_PREVIEW_DURATION` C:51), 미리보기 확정(C:3758).
  - **아군·적군 모두** 이 길을 탄다. 이 함수에는 진영 검사가 없다(C:4782-4844).
- **필요한 값** [사실]
  - 시전자 hero_id: `_get_hero_id_for_unit_state` C:4790 (= N6, C:8769-8777).
  - 특기 주인 hero_id: `skill_data.hero_id`, 없으면 위 값(C:4791 → C:4847-4849).
  - `skill_id`(C:4794). 두 hero_id를 별칭표로 바꾼다(C:4792-4793, REGC:11-16, 108-115).
  - 두 값이 다르면 영상 없이 끝낸다(C:4796-4799).
  - `find_entry(hero, skill)`(C:4800, REGC:134-144) → `video_path`, `skill_title_texture_path`(C:4814-4815), `hero_name`, `dialogue`, `dialogue_offset_x`, `hero_name_offset_x`(C:4832-4837).
- **재생 줄** [사실]
  - `ResourceLoader.load(video_path) as VideoStream`, 제목도 `load`(C:4816-4817). 하나라도 null이면 실패(C:4818-4821).
  - 실행 기록 `active_hero_cutin_execution`에 토큰을 넣는다(C:4822-4829).
  - `hero_cutin_overlay.visible = true`(C:4830) → `configure(...)`(C:4831-4838, HCP:54-62: 글·`video.stream`·제목 그림 지정) → `set_playback_speed(1.0)`(C:4839) → `play_cutin()`(C:4840).
  - `play_cutin`(HCP:67-80): `video.volume_db = 0`, 글 층이 켜져 있으면 `GameAudio.play_sfx("skill")`, `video.play()`, 루트 tween이 `full_video_duration`(4.01초, HCP:12)을 기다린 뒤 `_finish_cutin`.
  - 예비 타이머 4.60초(`HERO_CUTIN_SIGNAL_FALLBACK_DELAY` C:53, C:4843).
- **끝 조건** [사실]
  - `cutin_finished` 시그널(HCP:177-180) → `_on_hero_cutin_finished` C:4852 (연결 C:10170-10171), 또는 예비 타이머 C:4856-4864.
  - 끝나면 `_complete_hero_cutin_execution` C:4867-4882: 오버레이를 숨기고 **그제서야** 효과 적용 `_apply_unique_skill_effect_if_valid`(C:4881)와 마무리 `_finalize_unique_skill_action`(C:4882)을 부른다.
  - 영상 길이(4.000초)가 아니라 tween 4.01초가 끝을 정한다. `VideoStreamPlayer.finished`는 쓰지 않는다(HCP 전체에 `finished` 연결 없음).
- **2D가 멈추나** [사실]
  - 멈춘다. 확정 때 `is_demo_animating = true`, `is_unique_skill_presenting = true`, 단계 `PHASE_RESOLVING`(C:4742-4750).
  - `_can_use_unique_skill`·`_can_actor_use_unique_skill`은 `is_unique_skill_presenting`이면 false(C:3636, 3659). 입력 함수들은 `is_demo_animating`이면 돌아간다(C:3317, 3438, 3479, 3510 등).
  - 컷인 중복 요청은 막는다(C:4786-4789, "presentation_busy").
  - 마무리에서 두 깃발을 풀고 다음 차례로 간다(C:5923-5953).

### 1-2. 특기 영상 컷인 (옛 방식) `_show_specialty_skill_video_cutin` C:4895-5010

- **호출 시점**: 1-1이 false를 돌려줄 때만(C:4764). [사실]
- **아군만**: `_get_specialty_skill_video_cutin_hero_id`가 `side != "ally"`이면 빈 값(C:5013-5019). 설정이 있는 장수는 `SPECIALTY_SKILL_CUTIN_CONFIGS` 5명(yi_sunsin, kwon_yul, jeong_dojeon, gim_yusin, eulji_mundeok; C:232 이하). [사실]
- **값**: 초상·제목 그림(C:4904-4914), 영상 후보 목록 `SPECIALTY_SKILL_CUTIN_VIDEO_PATHS`(C:204-231). 첫 후보는 1920×1080 2초 Theora다(아래 2-4). [사실]
- **재생 줄**: 효과음(C:4917) → 배치(C:4922, C:10174-10224) → `is_specialty_skill_cutin_playing = true`, 하단 HUD 숨김(C:4924-4926) → 후보마다 `FileAccess.file_exists` 후 `ResourceLoader.load`, 실패하면 `VideoStreamTheora.new()`에 `file` 지정(C:5030-5087, C:5125-5151) → `specialty_skill_cutin_video.play()`(C:4963) → tween(C:4981-5009). [사실]
- **끝 조건**: tween 끝 `_hide_specialty_skill_cutin`(C:5009, C:10227-10252). 효과는 `SPECIALTY_SKILL_CUTIN_TOTAL_DURATION` 1.38초 뒤 타이머(C:303, C:4766, C:4778), 마무리는 1.38+0.75초 뒤(C:184, C:4767, C:4779). [사실]
- **멈추나**: 1-1과 같은 깃발(C:4742-4750)이 이미 켜져 있다. [사실]

### 1-3. 특기 토스트 (영상 없을 때) `_show_unique_skill_toast_over_unit` C:5313-5389

- **호출 시점**: 1-1, 1-2가 모두 false일 때(C:4768-4770). [사실]
- **값**: 그림 `skill_data.cutin_image_path`, 없으면 `GENERIC_SKILL_TOAST_FALLBACK_PATH`(C:162, C:5445-5450). 1-1의 실패 경로가 레지스트리 정적 대체 그림 경로를 `skill_data["cutin_image_path"]`에 써 넣는다(C:4803-4809, REGC:29-36, 157-167). 글 `toast_text`(C:5356, resolver:71 "%s!"). [사실]
- **재생 줄**: 효과음(C:5338), tween(C:5362-5389). [사실]
- **끝**: tween 끝 `_hide_unique_skill_toast`(C:5389). 효과 0.47초 뒤(`UNIQUE_SKILL_EFFECT_APPLY_DELAY` C:183 = 0.04+0.14+0.06+0.08+0.15), 마무리 1.22초 뒤(C:185, C:4778-4779). [사실: 상수 / 합계는 내가 더함]
- **멈추나**: 같은 깃발(C:4742-4750). [사실]

### 1-4. `CutinOverlay` (옛 노드)

- `show_cutin()`(C:2695-2698)을 부르는 곳이 scripts·tests 안에 없다(grep `show_cutin`). 이 노드는 숨기기만 한다(C:2702, 2709, 2823-2824, 3295). [사실]
- 블록 5에서 옮길 대상이 아니라고 본다. [추정]

### 1-5. 결과 영상 `_play_battle_result_video_before_toast` C:2811-2838

- **호출 시점**: `_try_show_battle_result_toast_if_needed` C:10637-10655. 결과가 정해지고(C:10638-10640), 퇴각 토스트가 다 끝나야 한다(C:10644-10645). 부르는 곳: `_cleanup_dead_units` 끝(C:14128), 퇴각 큐가 빌 때(C:10344, C:10437), 30라운드(C:11397). [사실]
- **값**: 결과 상태 → 경로 `victory_result_theora_q8_1920x.ogv` / `defeat_result_theora_q8_1920x.ogv`(C:371-372, C:2763-2768). [사실]
- **재생 줄**: `ResourceLoader.load` 후 실패하면 Theora 직접 생성(C:2771-2808) → 깃발 `is_battle_result_video_playing = true`(C:2822) → 배경 어둡게·영상 판(화면 폭 0.88, 16:9, 높이 최대 0.60, C:373-377, C:2735-2760) → `play()`(C:2833). 예비 타이머 4.35초(C:373, C:2834-2836). [사실]
- **끝 조건**: `VideoStreamPlayer.finished`(연결 C:2731-2732, C:2841) 또는 예비 타이머(C:2845-2848) → 영상 숨김 → 결과 토스트 "승리!"/"패배"(C:2851-2861, C:2883-2886, C:10492-10507). [사실]
- **멈추나**: 결과가 정해지면 판이 끝난 상태다. `_handle_battle_end_guard`가 비결과 토스트를 지우고 자동전투를 멈춘다(C:10614-10634). 영상 깃발은 중복 재생만 막는다(C:2814-2815). [사실]

### 1-6. 토스트 큐 (라운드·지원군·결과) `_enqueue_battle_toast` C:10510-10537

| 토스트 | 호출 (C:줄) | 값 | 길이·우선순위 | 효과음 |
|---|---|---|---|---|
| 라운드 | `_start_new_round` C:11416 → `_show_round_start_banner` C:10465 → C:10472-10473 | 글 "BATTLE %d", 기본 그림(C:10101) | 머무름 1.15초, 우선 0 | `round_start` (C:10566) |
| 지원군 | `_try_deploy_reinforce_01_pair` C:9453, `_try_deploy_city_reinforce_02_pair` C:9488 → C:10476-10489 | 글 "지원군 도착!"(C:165), 그림(C:164). 도착 부대가 없으면 건너뜀(C:10480-10482) | 0.82초, 우선 100 | `reinforcement` |
| 결과 | C:2886 → C:10492-10507 | "승리!"/"패배"(C:367-368), 그림(C:365-366) | 1.1+2.0초, 우선 200, 크기 1.18배(C:369-370) | `victory`/`defeat` |

- 재생: `_play_next_battle_toast` C:10540-10568 → `_show_battle_toast` C:10665-10711(들어오기 0.42초 + 0.12 + 머무름 + 나가기 0.32초). 끝 `_finish_battle_toast_playback` C:10736-10742가 다음 것을 튼다. [사실]
- 결과가 정해지면 비결과 토스트는 막힌다(C:10518-10520, C:10555-10559, C:10591-10611). [사실]
- **멈추나**: 멈추지 않는다. `is_battle_toast_playing`은 큐 안에서만 쓰인다(C:10541, 10603, 10695, 10739, grep). 노드는 `MOUSE_FILTER_IGNORE`(C:10096-10104). [사실]

### 1-7. 퇴각(전멸) 토스트 C:10310-10440

- **호출**: `_cleanup_dead_units` C:14095-14128. 처음 죽은 부대마다 한 번(C:14102-14103), 한 번 정리에 최대 3개(C:346, C:14104-14106), 넘으면 로그 "%s 전투이탈"(C:14108). 같은 함수가 `unit_defeated`를 기록한다(C:14114). [사실]
- **값**: `unit_id`, `side`, `display_name`, 대사 `_get_defeat_retreat_line`(C:10453-10462, 표 C:348-361, 해시로 고름 C:10461), 초상 `_get_retreat_toast_portrait_texture`(C:10442-10450). [사실]
- **재생**: 큐(C:10322-10334) → C:10351-10395. 첫 장 1.2초, 다음 장 1.0초 머무름(C:341-342), 들어오기 0.12초, 나가기 0.18초(C:344-345). 크기 440×104(C:347), 화면 아래쪽 가운데(C:10362-10366). [사실]
- **끝**: `_finish_defeat_retreat_toast` C:10421-10439. 큐가 비면 결과 토스트를 시도한다(C:10436-10437). [사실]
- **멈추나**: 전투 흐름은 멈추지 않는다. 결과 영상·결과 토스트만 기다린다(C:10644). [사실]

---

## 2. 컷인 레지스트리 전체 표

### 2-1. 구조 [사실]

- 레지스트리 파일 2개: `data/cutin/korea_mvp_hero_cutins.json`(REGC:4), `data/cutin/imjin_demo_hero_cutins.json`(REGC:5-7). `data/cutin/` 안에 다른 파일은 없다(`ls`).
- `load_entries()`는 korea_mvp만(REGC:46-51, 주석 "13-hero"). 실제 조회 `find_entry`는 둘 다 본다(REGC:54-67, 134-144).
- 첫 조회 때 `FileAccess`로 JSON을 읽어 정적 변수에 캐시한다(REGC:42-43, 59-67, 89-105). 엔진 상태가 아니다.
- 다른 나라용 레지스트리 클래스는 없다. `KoreaMvpHeroCutinRegistry`를 쓰는 스크립트는 C, 디버그 미리보기, 검증기 2개뿐이다(grep). imjin_demo 안에 일본 장수 5명이 들어 있다(아래 표).
- 영상 없는 장수용 정적 그림: 삼국지 5명(관우·장비·하후돈·유비·제갈량, REGC:29-35), 그 밖은 공용 그림(REGC:36).

### 2-2. 장수별 표 [사실: JSON 줄 + ffprobe]

모든 영상: theora, 1280×720, 30/1 fps, 120프레임, 4.000초, 소리 없음, `.ogv`(ogg). 모든 항목 `enabled: true`, 영상·제목 파일 모두 있음.

| # | 레지스트리 (JSON 줄) | hero_id | 이름 | 특기 | video_path 파일명 (`res://assets/ui/cutin/videos/`) | 영상 바이트 | 제목 PNG 바이트 |
|---|---|---|---|---|---|---|---|
| 1 | korea_mvp :5 | yi_sun_sin | 이순신 | 학익진 | yi_sun_sin__hagikjin__cutin_bg_theora_q8_1280x720.ogv | 17,272,556 | 1,254,857 |
| 2 | korea_mvp :6 | uija_wang | 의자왕 | 삼천궁녀 | uija_wang__samcheon_gungnyeo__…1280x720.ogv | 18,959,396 | 899,863 |
| 3 | korea_mvp :7 | kim_yu_sin | 김유신 | 삼한통일 | kim_yu_sin__samhan_tongil__…1280x720.ogv | 14,105,863 | 781,652 |
| 4 | korea_mvp :8 | kim_chun_chu | 김춘추 | 나당연합 | kim_chun_chu__nadang_yeonhap__…1280x720.ogv | 17,499,007 | 701,069 |
| 5 | korea_mvp :9 | jeong_do_jeon | 정도전 | 개혁령 | jeong_do_jeon__gaehyeongnyeong__…1280x720.ogv | 16,934,892 | 1,118,487 |
| 6 | korea_mvp :10 | jang_bo_go | 장보고 | 청해진 | jang_bo_go__cheonghaejin__…1280x720.ogv | 16,858,348 | 1,162,263 |
| 7 | korea_mvp :11 | heukchi_sangji | 흑치상지 | 백제부흥 | heukchi_sangji__baekje_buheung__…1280x720.ogv | 13,769,934 | 941,929 |
| 8 | korea_mvp :12 | gyebaek | 계백 | 황산벌 | gye_baek__hwangsan_beol__…1280x720.ogv | 16,584,816 | 800,735 |
| 9 | korea_mvp :13 | kwon_yul | 권율 | 행주대첩 | gwon_yul__haengju_daecheop__…1280x720.ogv | 14,705,905 | 701,989 |
| 10 | korea_mvp :14 | gwanggaeto | 광개토대왕 | 영락대제 | gwanggaeto__yeongnak_daeje__…1280x720.ogv | 15,385,816 | 779,038 |
| 11 | korea_mvp :15 | eulji_mundeok | 을지문덕 | 살수대첩 | eulji_mundeok__salsu_daecheop__…1280x720.ogv | 16,422,942 | 847,717 |
| 12 | korea_mvp :16 | dorim | 도림 | 흑백책략 | dorim__heukbaek_chaekryak__…1280x720.ogv | 19,839,281 | 790,644 |
| 13 | korea_mvp :17 | cheok_jun_gyeong | 척준경 | 검왕돌파 | cheok_jun_gyeong_cutin_bg_theora_q8_1280x720_verified.ogv | 15,701,459 | 1,029,574 |
| 14 | imjin_demo :6 | gwak_jae_u | 곽재우 | 홍의장군 | gwak_jae_u__hongui_janggun__…1280x720.ogv | 4,829,872 | 820,136 |
| 15 | imjin_demo :20 | go_gyeong_myeong | 고경명 | 호남의병 | go_gyeong_myeong__honam_uibyeong__…1280x720.ogv | 5,153,755 | 907,115 |
| 16 | imjin_demo :34 | kim_deok_ryeong | 김덕령 | 충용장 | kim_deok_ryeong__chungyongjang__…1280x720.ogv | 5,853,669 | 870,356 |
| 17 | imjin_demo :48 | toyotomi_hideyoshi | 도요토미 히데요시 | 태합호령 | toyotomi_hideyoshi__taehap_horyeong__…1280x720.ogv | 4,756,751 | 766,339 |
| 18 | imjin_demo :62 | shimazu_yoshihiro | 시마즈 요시히로 | 귀석만자 | shimazu_yoshihiro__gwiseok_manja__…1280x720.ogv | 6,438,129 | 708,086 |
| 19 | imjin_demo :76 | kato_kiyomasa | 가토 기요마사 | 칠본창 | kato_kiyomasa__chilbonchang__…1280x720.ogv | 7,002,598 | 875,809 |
| 20 | imjin_demo :90 | konishi_yukinaga | 고니시 유키나가 | 선봉교섭 | konishi_yukinaga__seonbong_gyoseop__…1280x720.ogv | 6,392,604 | 813,379 |
| 21 | imjin_demo :104 | kuroda_nagamasa | 구로다 나가마사 | 세키가하라 조략 | kuroda_nagamasa__sekigahara_joryak__…1280x720.ogv | 7,799,471 | 816,402 |

- 파일명의 "…"은 `__cutin_bg_theora_q8_`를 줄인 것이다. 전체 경로와 제목 경로는 CSV에 있다. [사실]
- 제목 경로는 모두 `res://assets/ui/cutin/titles/<slug>__title.png`이다(CSV `title_path`). [사실]

### 2-3. 숫자 [사실: 명령]

| 항목 | 값 |
|---|---|
| 영상 있는 장수 | **21명** (korea_mvp 13, imjin_demo 8) |
| 빠진 파일 | **0개** (영상 21, 제목 21 모두 있음) |
| 영상 합계 | 262,267,064 B ≈ 250.1 MiB (korea_mvp 214,040,215 / imjin_demo 48,226,849) |
| 영상 크기 범위 | 4,756,751 ~ 19,839,281 B |
| 제목 PNG 합계 | 18,387,439 B ≈ 17.5 MiB |
| 결과 영상 2개 | 21,727,212 B (승리 13,550,758 / 패배 8,176,454), theora 1920×1080 30fps + vorbis 48kHz 2채널, 4.011초 |
| `assets/ui/cutin/videos/` 전체 | 375,840,273 B (`du -cb`). 레지스트리 밖 옛 파일 약 113.6 MB 포함 |
| `.import` 파일 | 영상 옆에 없음. `.uid`만 있음(`ls`) |

- 쓴 명령: `ffprobe -v error -count_packets -show_entries stream=codec_type,codec_name,width,height,r_frame_rate,pix_fmt,nb_read_packets:format=duration` (ffmpeg 8.1.1, WinGet 설치본), 크기는 `os.path.getsize`·`du -cb`. [사실]
- 화소 형식은 모두 yuv420p. [사실: ffprobe]
- 비트레이트는 큰 파일이 약 34~40 Mbps다(바이트×8÷4초). [사실: 계산]

### 2-4. 레지스트리 밖 2D 옛 경로의 영상 [사실: ffprobe]

| 파일 | 형식 | 쓰는 곳 |
|---|---|---|
| `yi_sun_sin_cutin_bg_theora_q8_1920x.ogv` 외 `kwon_yul`·`jeong_do_jeon`·`kim_yu_sin`·`eulji_mundeok` `_q8_1920x.ogv` 5개 | theora 1920×1080, 2.005초, vorbis 있음 | 1-2 옛 방식 첫 후보(C:189-202) |
| `yi_sun_sin_cutin_bg_theora_540p.ogv` | theora 960×540, 24fps, 3초 | 1-2 둘째 후보(C:190) |
| `yi_sun_sin_cutin_bg_vp8.webm`, `cheok_jun_gyeong_..._vp9_crf16_1920x.webm` | VP8 / VP9 | 후보 목록에 webm이 있으나(C:208) 코어 미지원(3절) |
| `*_cutin_bg.mp4` 3개 | H.264 + AAC | 후보 끝(C:211, 217, 223). 코어 미지원(3절) |

### 2-5. 영상 없는 장수 처리 (2D 대체) [사실]

1. 레지스트리에 없으면 `get_static_fallback_image_path`로 PNG 경로를 `skill_data`에 넣고 false(C:4802-4809).
2. 아군이고 옛 설정 5명이면 1-2 옛 영상 컷인(C:4764-4767).
3. 아니면 1-3 특기 토스트(그림 + "특기명!")(C:4768-4770).
- 지난 제안서 기준 랩 기본 편성(`TEST_BATTLE_ROSTER` C:498-509)이라면, 아군 5명(yi_sunsin, jeong_dojeon, kwon_yul, gim_yusin, eulji_mundeok)은 별칭으로 레지스트리 1·5·9·3·11번에 닿는다(REGC:11-28). 적 5명(삼국지)은 레지스트리에 없어 정적 PNG 토스트로 간다(REGC:29-35). [사실: 표 대조 / 추정: 랩 편성이 이 표를 쓰는지는 실행 확인 없음]

---

## 3. 형식과 엔진 지원

### 3-1. 공식 문서 [사실: URL]

- Godot 4.6 "Playing videos": 코어가 지원하는 형식은 Ogg Theora 하나다. 소리는 Ogg Vorbis 트랙을 쓸 수 있다. H.264/H.265는 특허 때문에 코어에 없다. WebM은 4.0에서 빠졌다. 디코딩은 CPU가 한다. 데스크톱은 1080p·30fps 이하를 권한다. — https://docs.godotengine.org/en/4.6/tutorials/animation/playing_videos.html
- `VideoStreamPlayer`: `finished` 시그널, `expand`, `paused`, `speed_scale`, `volume_db`, `bus`, `buffering_msec`, `stream_position`. — https://docs.godotengine.org/en/4.6/classes/class_videostreamplayer.html
- 프로젝트는 Godot 4.6이다(`project.godot:15` `config/features=PackedStringArray("4.6", "Forward Plus")`). [사실]

### 3-2. 비교

| 항목 | 코어 지원 | 레지스트리 21개 | 결과 영상 2개 |
|---|---|---|---|
| 컨테이너·코덱 | Ogg Theora | ogg + theora [사실] | ogg + theora [사실] |
| 소리 | Vorbis | 없음 [사실] | vorbis 2채널 [사실] |
| 해상도 권장(데스크톱) | 1080p 이하 | 720p [사실] | 1080p [사실] |
| 결론 | — | **그대로 재생 가능** [추정: 형식 일치는 사실, 실행 확인 없음] | 그대로 재생 가능 [추정] |

- 2D가 이미 같은 파일을 `ResourceLoader.load(...) as VideoStream`으로 읽어 튼다(C:4816). 그래서 랩에서도 같은 경로로 읽힐 것이다. [사실: 코드 / 추정: 랩 실행]
- webm·mp4 옛 파일은 코어에서 못 튼다. 랩에서 쓰지 않는다. [사실: 문서 / 추정: 권장]

### 3-3. 2D 재생 순서 (줄 단위) [사실]

1. C:4814-4815 레지스트리에서 경로 두 개를 꺼낸다.
2. C:4816 `ResourceLoader.load(video_path) as VideoStream` (Theora 스트림 자원).
3. C:4817 제목 PNG를 `Texture2D`로 읽는다.
4. C:4830 CanvasLayer(층 40)를 보인다.
5. C:4831 → HCP:58 `video.stream = video_stream`, HCP:59 제목 그림.
6. C:4839 → HCP:64-65 속도 1.0 (tween 시간 나눗셈에만 씀, 영상 `speed_scale`은 안 건드림).
7. C:4840 → HCP:72 `video.volume_db = 0.0`, HCP:73-74 `GameAudio.play_sfx("skill")`, HCP:75 `video.play()`.
8. HCP:76-80 tween: 글 층 일정(HCP:137-151) 후 4.01초에 `_finish_cutin`.
9. HCP:177-180 `reset_cutin()`(HCP:96 `video.stop()`) 후 `cutin_finished`.
10. C:4867-4882 오버레이 숨김 → 효과 → 마무리.

---

## 4. 3D 연결 방법

### 4-1. 지금 랩이 받는 것과 시점 [사실]

| 순서 | 엔진 (C) | 랩 (EP) |
|---|---|---|
| 1 | 아군 수동: `_try_use_unique_skill_on_target`(EP:1238) → C:4585 → C:4715 | 랩이 부르는 쓰기 |
| 1' | 아군 자동 모드(대상 자동): `_on_unique_skill_button_pressed`(EP:1192) → 미리보기 0.42초(C:4697-4712) | EP:1195-1206 수락 판정 |
| 2 | 기세 소비, `skill_cast` 기록(C:4735-4738) | 아군: `_click_skill_cell`이 바로 `_consume_tactic_events`(EP:1245). 자동은 `_process`(EP:359) |
| 3 | 컷인 재생 시작, `is_demo_animating = true`(C:4742, 4840) | `skill_cast` → `_present_skill_event`(EP:1044-1045, 1267-1271): Label3D 특기명 1.6초 + 상태 줄. 입력은 "연출 중"으로 거절(EP:577-579) |
| 4 | 4.01초 뒤 `skill_effect`들, `skill_finished`(C:4881-4882, C:5935) | `_present_skill_effect`(EP:1277-1298), "특기 종료"(EP:1274-1275) |
| 적 | 같은 길. 적 턴은 엔진이 앞서 가고 `enemy_skill_used`(C:4612) | 적 특기 이벤트는 재생이 `enemy_skill_used`에 닿을 때까지 보류(EP:1046-1047, 888-891, 1337-1341) |

- 요청서의 "~EP:1198-1202"는 지금 `request_skill`의 수락 판정 부분(EP:1195-1206)이다. `skill_cast`를 받는 곳은 EP:1044-1047과 EP:1267-1271이다. [사실]
- `skill_cast` 이벤트 필드: `caster_id`, `side`, `skill_id`, `effect_type`, `target_mode`, `target_id`, `momentum_cost`(TL:100-108). **hero_id는 없다.** [사실]
- 엔진의 `HeroCutinOverlay`는 엔진 노드 안에 있다. 엔진은 `UPDATE_DISABLED` SubViewport(`battle3d_engine_host.gd:7`) 안에 있어 화면에 그려지지 않는다. [사실: 코드 / 추정: 영상 디코딩은 그래도 돈다]

### 4-2. 방법 비교

| 방법 | 내용 | 좋은 점 | 나쁜 점 |
|---|---|---|---|
| **(a1) 공용 컷인 씬 재사용** | 랩 CanvasLayer에 `scenes/ui/cutin/hero_cutin_presentation.tscn`을 인스턴스. `configure`/`play_cutin`/`cutin_finished`를 그대로 씀 | 2D와 같은 그림·글 일정(HCP:12-20). 코드 적음. 엔진 수정 0 | `play_cutin(true)`이 `GameAudio.play_sfx("skill")`을 또 부름(HCP:73-74). 다만 같은 효과음은 70ms 안이면 무시된다(`game_audio.gd:96-98`, `_duplicate_limit_enabled`일 때). 글 층과 효과음이 같은 인자에 묶여 있다(HCP:70-74) [사실] |
| (a2) 랩 전용 VideoStreamPlayer | 랩이 직접 `VideoStreamPlayer` + 제목 TextureRect + Label을 만듦 | 랩이 시간·소리를 완전히 정함 | 2D 글 일정·배치를 다시 만들어야 함. 모양이 어긋날 수 있음 [추정] |
| (b1) 엔진 SubViewport를 그대로 보이기 | 엔진의 컷인을 화면에 비춤 | 2D와 완전히 같음 | 호스트 `UPDATE_DISABLED`를 바꿔야 하고 2D 전장 전체가 같이 그려짐. 엔진/호스트 변경이라 범위 밖 [추정] |
| (b2) 3D 공간에 띄우기 | `VideoStreamPlayer`의 텍스처를 시전자 위 Quad/Sprite3D에 | 3D다운 연출 | 2D와 다름. 카메라 각도에 따라 읽기 어려움 [추정] |
| (b3) 정지 그림만 | 제목 PNG + 초상 + 이름 | 자원 작음(제목 17.5 MiB) | 김작 결정("영상 재생")과 다름 |

- 권장 [추정]: **(a1)**. 2D와 같은 부품이라 모양 차이가 가장 작다.

### 4-3. 시점·멈춤

- 3D 연출을 따로 멈출 필요는 거의 없다. 엔진이 이미 컷인 4.01초 동안 효과를 미룬다(C:4867-4882). 랩은 `skill_cast`에서 컷인을 열고 `skill_effect`가 오면 효과 글을 띄우면 된다. [사실: 엔진 / 추정: 랩 시간]
- 다만 랩 컷인이 엔진보다 늦게 시작하면(적 재생 지연) 효과가 컷인 위로 먼저 보일 수 있다. 컷인이 열려 있는 동안 같은 시전자의 `skill_effect` 표시를 잠시 보류하는 규칙이 필요하다(적 특기 보류 EP:58-63과 같은 방식). [추정]
- 아군 수동: 랩이 `skill_cast`를 거의 바로 받는다(EP:1245). 시간 차 작음. [사실: 코드 / 추정: 차이]
- 적: 재생이 `enemy_skill_used`에 닿을 때 연다(EP:888-891). 엔진도 그 특기에서 4초 멈추므로 재생 대기열이 크게 밀리지 않는다고 본다. [추정]
- 속도 2×/4×: 랩은 `Engine.time_scale`을 바꾼다(EP:1406). 엔진 tween·타이머는 그만큼 빨라진다. `VideoStreamPlayer`가 같은 배율로 빨라지는지는 확인하지 못했다(문서에 언급 없음). 영상이 tween보다 늦게 끝날 수 있다. [추정]
- 자동전투: 랩은 `_presentation_busy()`일 때 엔진 자동 진행을 붙잡는다(EP:1474-1493, 기존 쓰기 `set_auto_presentation_hold`). 컷인 재생 중을 이 판정에 넣으면 연속 특기가 겹치지 않는다. [사실: 기존 구조 / 추정: 넣을 위치]

### 4-4. 소리 [사실]

- 컷인 영상 21개는 소리 트랙이 없다(ffprobe). 소리는 효과음 `skill` 하나다(HCP:73-74).
- 엔진 안 컷인도 `GameAudio`(자동 로드, `project.godot:20`)로 효과음을 낸다. 그래서 지금 랩에서도 특기 효과음이 이미 난다고 본다. [추정: 실행 확인 없음]
- 결과 영상은 Vorbis 소리가 있다. 엔진이 SubViewport 안에서 결과 영상을 틀 때 소리가 이미 나는지 확인하지 못했다. 랩이 또 틀면 두 번 들릴 수 있다. [추정]
- 랩은 나갈 때 `GameAudio` 음성을 모두 멈춘다(`battle3d_engine_host.gd:23-30`). [사실]

### 4-5. 여러 특기 연속 (대기열)

- 2D는 대기열이 없다. 재생 중 새 요청은 영상 없이 다른 길로 간다(C:4786-4789). [사실]
- 엔진은 특기 중 다른 특기를 받지 않는다(C:3636, 3659). 그래서 같은 순간 두 컷인은 엔진에서 생기지 않는다. [사실]
- 랩에서는 적 재생 지연 때문에 "앞 컷인이 아직 안 끝났는데 다음 `skill_cast` 도착"이 생길 수 있다. 선입선출 대기열 하나 + 하나씩 재생을 권한다. [추정]

### 4-6. 파일 복사 대 같은 경로

| 방법 | 저장소 영향 | 비고 |
|---|---|---|
| 같은 `res://` 경로 참조 | 0바이트 | 2D 자원을 읽기만 함. 권장 [추정] |
| 3D용 폴더로 복사 | 작업 트리 +262.3 MB(영상) +18.4 MB(제목). git은 같은 내용을 같은 객체로 저장하므로 팩 증가는 작을 것 [추정] | 내보내기 패키지는 두 벌이 될 것 [추정] |

- 지금 저장소 팩 크기 1.39 GiB(`git count-objects -vH`). 영상은 일반 git 파일이다(`.gitattributes`에 LFS 줄 없음, `git lfs ls-files` 결과 없음). [사실]
- 권장 [추정]: 복사하지 않고 레지스트리 경로를 그대로 쓴다.

---

## 5. 읽기 정리 (새 승인이 필요한 것만)

### 5-1. 랩이 이미 받는 것 [사실]

- 엔진 읽기(`engine.call`): `_get_unique_skill_for_unit`(EP:1190, 1212, 1226, 1259), `_get_closeup_portrait_texture_for_unit`(N2, EP:159), `_get_troop_icon_texture_for_visual_key`(N3, EP:168), `_get_formation_status_summary_text`(N4, EP:175) 외 기존 목록.
- 필드: `display_name`(N1, EP:150-153).
- 이벤트: `skill_cast`/`skill_effect`/`skill_finished`(tactic 로그, EP:1044-1047), `reinforcement_arrived`(EP:1038-1043), `unit_defeated`(battle_action 로그, EP:747-748), `round_started`(EP:896-900), `battle_ended`(EP:831-832 수신 / EP:901-905 재생), `enemy_skill_used`(EP:888-891), `enemy_attack_resolved.killed`(EP:804).
- N5·N6 감싸기 함수는 블록 4-1 가지(`ed4993b`)에 있고 이 기준에는 아직 없다. 승인된 상태이므로 아래에서 "새 승인 불필요"로 둔다. [사실]

### 5-2. 블록 5에 필요한 값 → 출처

| 필요한 값 | 출처 | 새 승인 |
|---|---|---|
| 특기 주인 hero_id | `_get_unique_skill_for_unit(caster)["hero_id"]` (기존 읽기). 2D도 이 값을 먼저 쓴다(C:4849). 리졸버가 빈 값을 거절(resolver:85-86, 139-141) | 불필요 [사실] |
| 시전자 hero_id (일치 검사) | N6 `_get_hero_id_for_unit_state` (승인됨) | 불필요 |
| skill_id | `skill_cast.skill_id` (TL:103) | 불필요 [사실] |
| 영상·제목·대사·이름 | `KoreaMvpHeroCutinRegistry.find_entry` (엔진 밖) | **필요 (R1)** |
| 특기 토스트 그림 | `_get_unique_skill_for_unit`의 `cutin_image_path` 키(있을 때). 없으면 R1의 `get_static_fallback_image_path` | R1에 포함 |
| 퇴각 이름·초상 | N1, N2 | 불필요 |
| 퇴각 대사 | N13 `_get_defeat_retreat_line` | **보류 그대로 (N13)** |
| 결과·라운드·지원군 | 기존 이벤트 | 불필요 |
| 결과 영상 경로 | C:371-372 상수. 엔진 읽기 대신 랩 상수로 같은 경로를 적을 수 있다 | 불필요(상수) [추정] |

### 5-3. 새 승인 표 (갱신)

| 이름 | 무엇 | 부작용 | 승인 안 할 때 대안 | 잃는 것 |
|---|---|---|---|---|
| **R1** 컷인 레지스트리 사용 (REGC) | `canonicalize_hero_id`, `canonicalize_skill_id`, `find_entry`, `get_static_fallback_image_path` (엔진 밖 정적 함수) | 첫 호출 때 JSON 2개를 `FileAccess`로 읽어 정적 캐시(REGC:59-67, 89-105). 파일이 없으면 `push_error`(REGC:90-105). `find_entry`는 복사본을 줌(REGC:143). `get_static_fallback_image_path`는 `ResourceLoader.exists`만(REGC:163-165). 엔진 상태·난수·시그널 없음 [사실] | 랩에 21줄 표를 따로 둔다(JSON 복제) | 레지스트리와 따로 놀 위험. 장수 추가 때 두 곳 수정 [추정] |
| R1에 따른 자원 읽기 | 영상 `ResourceLoader.load(...) as VideoStream`, 제목 `Texture2D` | Godot 자원 캐시만. 엔진 사전 없음. 첫 읽기 때 프레임이 늦어질 수 있음(영상 최대 19.8 MB) [사실: 크기 / 추정: 지연] | 전투 시작 때 편성 장수 것만 미리 읽기 | — |
| **N13** `_get_defeat_retreat_line` (C:10453-10462) | 퇴각 대사 | 없음(해시 선택 C:10461) [사실] | 랩 고정 문구 또는 대사 없음 | 부대별 대사 5종 |

- 지난 제안서의 "보류: N6 + 컷인 레지스트리"는 이제 "N6 승인됨 + **R1만** 결정"으로 바뀐다. [사실: 5-2]
- 부르면 안 되는 함수는 지난 제안서와 같다: `_play_committed_hero_cutin`(넘긴 `skill_data`를 고침 C:4805, 연출 시작), `_try_show_battle_result_toast_if_needed`, `_handle_battle_end_guard`(C:10614-10634). [사실]
- 검증기 주의 [사실]: 옛 3D 검증기들의 FORBIDDEN에 `result_toast`, `result_video`가 있다(`tools/validate_battle3d_m5c_option_panel.py:41`). m5c에는 `create_timer`, `speed_scale`도 있다(:43). 이 검증기들은 고정 커밋을 본다(지난 제안서 0-4). 새 랩 코드 이름에서 이 글자를 피하면 안전하다. [추정]

---

## 6. 토스트 5종 3D 연결표 (지금 코드로 다시 확인)

| 토스트 | 2D 값 (C:줄) | 랩 연결점 (EP:줄, 시점) | 지금 랩 표시 | 새 읽기 | 지난 제안서와 다른 점 |
|---|---|---|---|---|---|
| T-a 라운드 | "BATTLE %d", `battle_round`. C:11416 → C:10465-10473. 이벤트 `round_started` C:11417 | `_present_enemy_event` "round_started" EP:896-900 (**재생 시**). `current_round` EP:897 | 상태 줄 "라운드 %d", `turn_label`(EP:448) | 없음 | 줄 번호만: EP:841→899, EP:390→448 |
| T-b 지원군 | "지원군 도착!"(C:165), 그림 C:164. C:9453, 9488 → C:10476. 이벤트 `reinforcement_arrived`(C:9442-9480, TL:171-174) | `_consume_tactic_events` EP:1038-1043 → `_present_arrival` EP:1138-1167. 그 라운드 `round_started` 재생까지 보류(EP:1039-1041, 1134-1136) | 상태 줄 + Label3D "지원군 도착" 2초(EP:1154-1167) | 없음 | 줄 번호만: EP:1080→1138. 2D는 라운드당 1장, 랩은 부대마다 1개(그대로) |
| T-c 퇴각/전멸 | `display_name`, 대사 C:10453, 초상 C:10442, 진영 색 C:10377-10380. C:14102-14108, 최대 3장. 이벤트 `unit_defeated` C:14114 | 아군 행동: `unit_defeated` EP:747-748 (**수신 시**). 적 공격 격파: `enemy_attack_resolved.killed` EP:804 (수신 시 요약), 재생은 `_show_enemy_hit`(EP:879). 특기 격파: `skill_effect.killed` EP:1282-1283 | "격파 · id" 전투 기록, 특기 "−N 격파" Label3D | N1·N2(승인됨), **N13 보류** | 줄 번호만. 시점 문제 그대로: `unit_defeated`는 적 재생보다 먼저 온다 [사실]. 재생 쪽 `killed`에 맞추기 권장 [추정] |
| T-d 특기 | `toast_text` "%s!"(resolver:71), 그림 `cutin_image_path`(C:5445-5450). 영상 컷인이 없을 때만(C:4768-4770) | `skill_cast` EP:1044-1047 → EP:1267-1271. 적은 EP:888-891 후 EP:1331-1341 | Label3D 특기명, 상태 줄 "특기 · id · 이름 (기세 −N)" | 이름 없음. 그림은 R1 | **블록 5 결정으로 영상 컷인(1-1)이 주 경로, T-d는 영상 없는 장수용 대체**가 된다 |
| T-e 결과 | 영상 C:371-372 → 토스트 "승리!"/"패배"(C:367-368). 퇴각 토스트가 끝난 뒤(C:10644) | `battle_ended` 수신 EP:831-832 (`battle_result`), 재생 EP:901-905 (`result_overlay`). 셸 `result_label`(SH:238) | `result_overlay` 글 "승리"/"패배" | 없음 | 줄 번호만: EP:774→832, EP:845-846→903-904. 결과 영상에 소리가 있다는 점 추가(4-4) |

- 랩의 결과 토스트도 2D처럼 "퇴각 토스트 → 결과 영상 → 결과 토스트" 순서를 지켜야 한다(C:10644-10648). [사실: 2D / 추정: 랩 규칙]
- 결과가 정해진 뒤 라운드·지원군 토스트를 막는 규칙(C:10518-10520)도 같이 옮겨야 한다. [추정]

---

## 김작이 정할 것

1. 컷인 방식: (a1) 공용 컷인 씬 재사용 / (a2) 랩 전용 / 그 밖.
2. R1(컷인 레지스트리 엔진 밖 사용)을 승인할지. 안 하면 랩에 21줄 표를 복제한다.
3. 영상 파일: 같은 `res://` 경로 참조(0바이트) / 3D용 복사(+262 MB 작업 트리).
4. 적 장수 컷인도 틀지. 2D는 적도 레지스트리에 있으면 영상을 튼다(C:4782-4844에 진영 검사 없음). 지금 레지스트리에 일본 장수 5명이 있다(imjin_demo 17-21번). 이들이 어느 진영으로 나오는지는 확인하지 않았다.
5. 영상 없는 장수(지금 기본 편성의 삼국지 적 5명 등): 2D처럼 T-d 정지 그림 토스트 / 지금 랩 글자 그대로.
6. 속도 2×/4×에서 컷인: 같이 빨라지게 / 1×로 고정 / 건너뛰기.
7. 결과 영상 소리: 랩이 영상을 틀 때 소리 켬/끔 (엔진 쪽에서 이미 나는지 실행 확인 필요).
8. 퇴각 대사 N13 승인 / 랩 고정 문구 / 대사 없음.
9. 랩 결과 화면을 덮을 때 `result_overlay`를 숨길지(테스트 영향, 지난 제안서 (d)) / 남겨 두고 위에 그릴지.
10. 컷인 재생 중 자동전투 붙잡기(`_presentation_busy`에 넣기)를 할지.

## 못 한 것

- Godot를 실행하지 않았다. 아래는 모두 확인 못 했다.
  - 랩에서 `.ogv`가 실제로 열리고 재생되는지.
  - 엔진 SubViewport 안의 컷인 영상이 디코딩되는지, 그 CPU 비용, 효과음·결과 영상 소리가 랩에서 이미 들리는지.
  - `Engine.time_scale`이 `VideoStreamPlayer` 재생 속도에 주는 영향(공식 문서에 없음).
  - 랩 시나리오의 실제 hero_id·skill_id(슬롯 메타 `assigned_hero_id`, `design_unique_skill` 내용). 그래서 "기본 편성 아군 5명 영상, 적 5명 정지 그림"은 [추정]이다.
  - `_get_unique_skill_for_unit` 결과에 `cutin_image_path` 키가 실제로 있는지(`UNIQUE_SKILL_REGISTRY` C:524-655에는 있으나 실제 정의는 `design_unique_skill`에서 온다, `battle_unit_state.gd:90-92`).
  - 첫 라운드 "BATTLE 1" 토스트가 랩(인트로 건너뜀)에서 나오는지.
- Theora 헤더를 Python으로 직접 읽지는 않았다. ffprobe(ffmpeg 8.1.1)가 있어 그것으로 쟀다.
- git 객체 중복 제거로 "복사해도 팩이 거의 안 커진다"는 부분은 실제 커밋으로 재지 않았다([추정]).
- 2D 옛 방식(1-2)의 tween 상수 일부(`SPECIALTY_SKILL_CUTIN_TEXT_*`)는 값을 다 읽지 않았다. 총 길이 1.38초(C:303)만 확인했다.
