# 큐 45 보고 — 장수 119명 등록 (정의만, 주둔 없음)

- 지시서: `agent/ORDER_HERO_REGISTER_119_20261128.md`
- 가지: `feature/hero-register-119-20261128`, 기준 `main` `6b6bc2f`
- 커밋: 코드·데이터·초상화 `0745c2e`(`[skip ci]` 없음) → 이 보고서(`[skip ci]`)
- `worldmap_main.gd`는 0줄 바뀌어서 재고정할 것이 없다.
- 규칙 값(전투 공식, 충성도 규칙, 특기 효과 수치)은 바꾸지 않았다. 배치도 없다.
- **main 병합은 김작 능력치 승인 뒤**다(지시서 0절). 118명 `review_status`는 "로컬 검토 제안", 조운은 "Quorum 검토용 초안"이고, 정의마다 `stats_approved: false`다.

## 1. 등록 결과
- **등록 수 163** = 기존 44 + 새 119.
  - `HeroDefinitionRegistry.HERO_DATA` 163명, `HeroDesignDataRegistry.get_all_hero_ids()` 163명.
  - 새 ID는 서로 겹치지 않고, 44명과도 겹치지 않는다. 표시 이름 163개도 모두 다르다.
- **원본 자료**
  - Drive 68 JSON(`roster_245_20261128.json`, 245명)과 Drive 74 표(119명 이름·ID·원본 파일)를 쓴다.
  - 둘 다 김작 PC에 동기화된 `G:\내 드라이브\EASTWAR_채클코치_개발협업\`에서 읽었다.
  - 74 표 119행은 68의 이름·ID와 모두 일치한다.
  - 병종은 보병 58, 기병 37, 궁병 18, 기마궁병 6이다(지시서 1절과 같음).
- **저장소에 넣은 자료** (`data/heroes/source/`, `.gdignore`로 Godot 가져오기에서 뺌. CSV가 번역 파일로 가져와지지 않게 하려는 것이다)
  - `roster_245_20261128.json`: Drive 68 원본 그대로.
  - `hero_portrait_candidates_74_20261128.csv`: 74 표를 옮긴 것(name, hero_id, source_file, drive_id, source_folder).
  - `portrait_map_119_20261128.csv`: 초상화 결과(name, hero_id, source_file, drive_id, output_path, source_size).
  - `placement_A_revised_20261128.json`: Drive 67 3절 최종 배치표(39성, 주둔 163명, 그중 기존 44). **자료로만 두었고 코드에서 읽지 않는다**(큐 46용).
- **등록 경로**
  - `tools/convert_hero_workbook.py`에 JSON 입력 어댑터(`--roster-json … --ids-csv … --portrait-map …`)를 더했다. 엑셀 경로는 그대로다.
  - 어댑터는 다음 파일 끝에 119명을 덧붙인다.
    - `hero_base_stats`, `hero_battle_profiles`, `hero_initial_loyalty`, `hero_unique_skills` 4개
    - `HeroDefinitionRegistry.LEGACY_IDENTITY_DATA`
  - 각 파일의 원래 모양(들여쓰기 / 한 줄에 한 항목 / 한 줄 압축)을 그대로 따른다.
  - 이미 있는 ID가 있으면 아무것도 쓰지 않고 멈춘다. 두 번 돌리면 거부되는 것을 확인했다.
  - `unit_type_rules`는 바꿀 필요가 없었다. 쓰는 병종 4개가 모두 이미 있다.
- **새 정의의 필드**
  - 이름, 역할, 고유특기(`skill_effect_type`은 원안 그대로), 초상화 경로를 넣었다.
  - `hanja`, `roster_faction`(명단의 국가 이름), `description`(명단 bio), `review_status`(원문 그대로), `stats_approved: false`도 넣었다.
  - **주둔 3필드(`assigned_city_id`, `city_id`, `location_city_id`)와 세력 4필드(`faction_id`, `force_id`, `side`, `nation`)는 빈 문자열로 둔다.**
  - 세력 4필드도 비운 이유: `worldmap_main.gd`의 세력 목록 수집(`_get_known_non_player_faction_ids`)과 재상 후보 대체 탐색이 모든 장수의 세력 값을 읽는다. 값이 있으면 없는 세력이 생기거나 다른 세력의 재상으로 뽑힐 수 있다. 키는 있고 값만 빈 상태라 둘 다 이 장수들을 건너뛴다.
  - 병력·지휘 등급처럼 명단에 없는 값은 만들어 넣지 않았다.

## 2. 기존 44명 diff 0줄 증거
| 파일 | 줄 기준 diff | 증거 |
|---|---|---|
| `hero_base_stats.json` | +833 / −0 | 옛 파일에서 맨 끝 `\n  ]\n}\n`을 뺀 텍스트가 새 파일의 바이트 접두어다. 앞 44개 레코드도 같다 |
| `hero_initial_loyalty.json` | +120 / −1 | 바뀐 1줄은 44번째 레코드 줄 끝에 붙은 쉼표다(JSON 문법상 피할 수 없다). 그 앞은 바이트 그대로이고 레코드 값도 같다 |
| `hero_battle_profiles.json` | +1 / −1 | 원래 한 줄짜리 압축 JSON이라 그 한 줄이 바뀐다. 옛 텍스트에서 끝 `]}\n`을 뺀 부분이 새 텍스트의 바이트 접두어이고, 앞 44개 레코드도 같다 |
| `hero_unique_skills.json` | +1 / −1 | 위와 같다 |
| `hero_definition_registry.gd` | +119 / −0 | 기존 1~51줄과 파일 끝 10줄이 그대로다 |
- 시험 2번: 44명의 `get_hero()`를 정렬 키 JSON으로 만들어 `6b6bc2f` 스냅숏과 비교하면 모두 같다.

## 3. 초상화 — 119장 모두 만듦, "초상화 없음" 0명
- **원본 위치**: 2K 원본은 김작 PC의 동기화 폴더 `G:\내 드라이브\EASTWAR_장수초상화\`에서 읽었다(록비서작업 한국·일본·중국 118장, 루트 중국 폴더의 조운 1장).
  - 지시서의 `C:\dev\eastwar_art_local\portraits_2k\`는 아직 없다. 대신 이 폴더를 `--src`로 바로 넘겼다. 이 폴더도 저장소 밖이다.
  - 74 표의 파일 이름은 이 폴더 안에서 모두 한 군데에만 있다.
- **원본은 커밋하지 않았다.**
- **도구** `tools/make_hero_portraits.py --src <원본 폴더> --map data/heroes/source/hero_portrait_candidates_74_20261128.csv --out assets/heroes/portraits`
  - 기존 규격(512×512, PNG RGB 8비트)으로 만든다.
  - 원본 119장은 모두 1536×2048이라 가운데 1536×1536을 잘라 줄였다(늘리지 않음).
  - 한 장 최대 455 KB이고, 119장 합계는 49.4 MB다(한도 1 MB / 100 MB 안).
  - `.import` 119개도 함께 커밋했다.
- **region 폴더**: 기존 china 42, korea 32, japan 32, mongol 2에 더해 **새 폴더 3개**를 만들었다.
  - `steppe` 4(돌궐), `tibet` 4(토번), `manchuria` 3(청)
  - 명단의 국가(faction)가 돌궐·토번·청·몽골이면 그 폴더를 쓰고, 나머지는 region(중국·한반도·일본)을 따른다.
- **확인할 것**: 가운데를 잘라서 몇 장은 머리 위쪽(관·머리띠)이 조금 잘린다. 지시서대로 가운데 자르기를 했다. 위쪽 기준으로 자를지는 록비서 검수 때 정해 주세요.

## 4. 새 특기 3종 — **중요: 엔진에 이미 있는 타입이다**
- 9명의 `skill_effect_type`은 원안 그대로 남겼다(`charge_aoe` 5, `mounted_team_buff` 3, `command_debuff` 1). 다른 타입으로 바꾸지 않았다.
- **[사실] 이 세 타입은 지금 전투 해석기(`scripts/battle/battle_skill_resolver.gd` `ARCHETYPE_BY_EFFECT_TYPE`)에 이미 연결되어 있다.**

  | 타입 | 지금 연결된 동작 | 이미 쓰는 기존 장수 |
  |---|---|---|
  | `charge_aoe` | `damage_area` | 겐신 |
  | `mounted_team_buff` | `buff_team_area` | 징기스칸 |
  | `command_debuff` | `debuff_single` | 혼다 마사노부 |

  - 74번 표의 "등록된 8명의 현행 동작"이 이 세 명을 포함한다.
- 그래서 지시서 3절·5-6의 "`charge_aoe` 장수가 특기를 쓰면 효과 0 + `[SKILL_UNIMPLEMENTED]`"는 **그대로 따르지 않았다.** 그렇게 하면 겐신·징기스칸·혼다 마사노부의 특기가 꺼져서 "기존 44명 변화 0"과 부딪힌다.
- 대신 이렇게 했다.
  1. **엔진이 정말 모르는 타입**은 효과 없이 건너뛴다. `validate_skill`이 `unsupported_effect_type`으로 실패하므로 목표도 계획도 없고 기세도 쓰지 않는다. 그리고 타입마다 처음 한 번 `[SKILL_UNIMPLEMENTED] type=… skill=…` 한 줄을 남긴다. 크래시는 없다. 시험 6은 가짜 타입으로 이 동작을 확인한다.
  2. 9명은 지금 그 타입의 기존 동작을 그대로 받는다. 이번 큐는 배치가 없어서 실제 전투에는 나오지 않는다.
- **큐 45b에 필요한 결정**: 45b는 이 세 타입에 새 효과를 넣는다. 그러면 기존 세 장수의 특기도 같이 바뀐다. 다음 중 하나를 정해 주세요.
  - (가) 기존 세 장수도 새 효과로 바꾼다.
  - (나) 새 효과는 새 타입 이름(예: `charge_aoe_v2`)이나 플래그로 나누고, 기존 세 장수는 그대로 둔다.

## 5. 시험 — `tests/scripts/test_hero_register_119.gd` (C-track 등록): `[HERO_REG119] checks=44 failures=[]`
- **기준 스냅숏**: `6b6bc2f` 코드에서 `tools/make_hero_reg119_baseline.gd`를 돌려 `tests/fixtures/hero_reg119/`에 남겼다.
  - 내용: 44명 정의, 새 게임 세계, 그 기준 코드가 쓴 수동 저장과 턴 체크포인트, 각각 불러온 뒤의 세계.
  - 시험과 같은 캡처 코드(`tests/scripts/support/hero_reg119_capture.gd`)를 쓴다.
- **확인하는 것**
  1. 163명, ID와 이름 중복 없음, 설계 데이터 로드 오류 없음, `runtime_factory_error` 0명.
  2. 기존 44명 정의 = `6b6bc2f`.
  3. 새 게임: 도시별 주둔, 플레이어 보유 장수, 장수 상태 전부가 `6b6bc2f`와 같다. 새 119명은 주둔·보유·상태 어디에도 없고, 무주공산에도 없다.
  4. `6b6bc2f`에서 쓴 수동 저장(`user://worldmap_manual_save.json`)과 턴 체크포인트를 불러와도 3과 같다.
  5. 119명: `get_hero`가 값을 돌려준다(지시서의 `get_definition`은 이 저장소에 없어 `get_hero`로 확인).
     - 능력치, 병종, 초기 충성, 특기 타입이 명단과 같다.
     - `stats_approved == false`이고 `review_status`가 원문과 같다. 초안 표시는 조운 한 명에게만 있다.
     - 주둔·세력 필드가 비어 있고, 9명은 원안 타입이 그대로다.
  6. 모르는 타입: 효과 0, 크래시 없음, 로그 1줄(`[SKILL_UNIMPLEMENTED] type=hero_reg119_unknown_effect …`). 세 타입이 해석기에 이미 있다는 사실(4절)도 확인한다.
  7. 초상화 119장: 512×512 RGB이고 `load()`가 null이 아니다.
- **탐색·등용 후보 목록**: 현재 코드에 장수 탐색·등용(재야) 기능 자체가 없다(코드 전체 검색). 비교할 후보 목록이 없어서, 장수 목록을 쓰는 곳을 대신 확인했다. 재상 후보와 원군 후보는 도시 주둔 목록에서 뽑으므로 새 장수가 들어가지 않는다.

## 6. 검증기
- **CI 72개 통과.**
- `tools/validate_hero_*` 4개는 163명 기준으로 통과한다. 바꾼 이유는 다음과 같다.
  - `validate_hero_five_unit_assignment.py`: 앞 44명의 분포 14/12/11/4/3은 그대로 잠그고, 덧붙인 119명의 분포 58/37/18/0/6을 따로 검사하게 했다.
  - `validate_hero_design_registry.py`: **`6b6bc2f`에서 이미 실패하던 검증기**였다(39명 시절 값). 163명 합계로 고쳤다: 병종 72/49/29/4/9, 기세 1:2·2:41·3:102·4:18.
  - `validate_hero_battle_profile_integration.py`, `validate_hero_runtime_authority.py`: 데이터에서 수를 읽어서 그대로 통과한다.
- 44를 박아 둔 CI 밖 검증기 3개도 163에 맞췄다.
  - `validate_imjin_d0_d1_worldmap_hero_integration.py`: 44 → 163. `EXPECTED_HERO_COUNT` 문자열 검사도 함께 바꿨다.
  - `validate_five_unit_type_damage_auto_battle_and_skill_parity.py`: 44 → 163.
  - `validate_t06_t07_playable_transaction.py`: 앞 44명 기세 분포는 그대로 두고 119명 분포를 따로 검사한다.
- `validate_unique_skill_korean_display.gd`: 163/163 통과.

## 7. CI
- `Verify C-track refactor` 실행 **`46103052111`** (head `0745c2e`): **초록**. 4개 묶음 모두 첫 실행에 success, 끝난 시각 2026-11-28 03:51 UTC. `[HERO_REG119] checks=44 failures=[]`, 검증 스크립트 72개 통과.
- `Verify WorldMap3D`: 경로 조건에 걸리는 파일이 없어 돌지 않는다.

## 8. 로컬 전체
- 작업 트리에서 C-track 시험 220개(CI 목록, 4개 병렬): **220 실행, 220 종료 코드 0**.
- 검증 스크립트 72개: **72 통과**.

## 9. 남은 것
1. 김작 능력치 승인(118명, 조운 초안). 승인되면 `stats_approved: true`로 바꾸는 별도 커밋을 만든다.
2. 4절의 45b 결정 (가)/(나).
3. 초상화 위쪽 잘림 검수(3절).
4. 배치는 큐 46에서 한다(`placement_A_revised_20261128.json`).
