# 큐 45: 장수 119명 등록 (정의만, 주둔 없음)

기준 화면: `main` `6b6bc2f`에서 F6로 새 게임을 시작해 월드맵 인사 창과 장수 정보를 연다. 기존 44명의 주둔, 보유, 탐색 후보는 지금과 똑같다. 새 119명은 장수 정의 조회와 초상화 로드만 된다.
합격 기준: 아래 1~6절 시험이 모두 통과한다(CI C-track 4/4, 72개 검증기 포함). 새 게임과 기존 저장 불러오기에서 기존 44명의 상태가 바뀌지 않는다. 최종 합격은 김작 F6다.

## 0. 근거 (김작 확정만)
- 배치: A 수정안, 김작 11-28 08:52 (Drive 67). 이번 큐는 **등록만** 하고 배치는 큐 46에서 한다(채비서 76).
- 김작 11-28 10:44~10:45 (Drive 77, 록비서 김작지시):
  - 초상화: Drive 2K 119장을 쓴다.
  - 조운: 이번 119명에 넣는다. 초안 표시는 유지한다.
  - 새 특기 3종: 기존 특기로 바꾸지 않고, 엔진에 새 효과로 넣는다. 구현은 **별도 큐**(45b)에서 하고, 이번 큐는 데이터만 보존한다.
- **미확정:** 118명의 명단 능력치 승인. 구현과 시험은 지금 진행해도 되지만, **main 병합은 김작 승인 뒤에 한다**(클코치가 판단).

## 1. 대상
- 명단: Drive 68 JSON (`1jtwEHnnWI5r7QhO9GHworRZ9j7LqOEJI`). 그중 A 수정안에 배치된 163명에서 이미 등록된 44명을 뺀 **119명**이다. 이름과 ID는 Drive 74 표를 따른다.
- 명단에서 쓰는 값: 능력치, 병종, 특기, `review_status`, 설명.
  - 병종 분포: 보병 58, 기병 37, 궁병 18, 기마궁병 6.
- 원본 JSON은 저장소에 넣어도 된다. 텍스트이고 비밀 정보가 없다. 위치는 `data/heroes/source/roster_245_20261128.json`.

## 2. 등록 경로 (기존 파이프라인 그대로)
- `tools/convert_hero_workbook.py` 경로를 써서 `data/heroes/generated/*.json` 5개에 119명을 추가한다.
  - 대상 파일: `hero_base_stats`, `hero_battle_profiles`, `hero_initial_loyalty`, `hero_unique_skills`, `unit_type_rules`(필요할 때만).
  - 변환 도구가 JSON 입력을 받지 못하면 입력 어댑터만 추가한다. 엑셀 경로는 바꾸지 않는다.
- `scripts/worldmap/hero_definition_registry.gd`에 정의를 추가한다(44 → 163명).
- **`assigned_city_id`, `city_id`, `location_city_id`는 빈 값으로 둔다.** seeder(`worldmap_registered_hero_seeder.gd` L91-124)가 주둔 목록에 넣지 않게 하기 위해서다.
- 기존 44명의 정의, 값, 순서는 한 바이트도 바꾸지 않는다. diff에서 기존 줄 삭제나 수정이 0이어야 한다.
- `review_status`는 원문을 그대로 보존한다.
  - 118명: 로컬 검토 제안.
  - 조운: Quorum 검토용 초안.
  - 정의마다 `stats_approved: false` 필드를 넣는다. 김작이 승인하면 true로 바꾸는 별도 커밋을 만든다.

## 3. 새 특기 3종 (데이터만 보존)
- 대상 9명:
  - `charge_aoe` 5명: 사나다 유키무라, 시마즈 이에히사, 아술, 하후연, 묵철가한.
  - `mounted_team_buff` 3명: 고연무, 안페양고, 빌게가한.
  - `command_debuff` 1명: 대문의.
- `skill_effect_type`에는 원안 값을 그대로 넣는다. 엔진에 아직 효과가 없으므로 넣을 때 다음을 지킨다.
  - 전투 엔진이 모르는 타입을 만나면 **아무 효과 없이 건너뛰고 로그 한 줄**(`[SKILL_UNIMPLEMENTED] type=...`)을 남긴다. 크래시가 나면 안 된다.
  - 다른 타입으로 몰래 대체하지 않는다.
  - 이번 큐는 배치가 없어서 실제 전투에 나오지 않는다. 그래도 위 동작은 시험으로 확인한다.
- 효과 구현은 큐 45b에서 한다. 클코치가 따로 지시서를 쓴다.

## 4. 초상화
- 원본 2K PNG는 **저장소에 넣지 않는다**(공개 저장소).
  - 김작이나 록비서가 Drive 74 표의 119장을 저장소 밖 폴더 `C:\dev\eastwar_art_local\portraits_2k\`에 받아 둔다.
  - 파일명은 Drive 원본 그대로 둔다.
- 새 도구 `tools/make_hero_portraits.py --src <그 폴더> --map <74 매핑 csv> --out assets/heroes/portraits`:
  - 기존 초상화와 같은 규격으로 만든다: **512×512, PNG RGB(8비트, 알파 없음)**, 경로는 `assets/heroes/portraits/<region>/<region>_<hero_id>.png`.
  - 정사각형이 아니면 가운데를 잘라서 맞춘다. 늘리지 않는다.
  - 결과 목록을 `data/heroes/source/portrait_map_119_20261128.csv`로 남긴다. 열은 이름, ID, 원본 파일명, Drive ID, 출력 경로, 원본 크기.
  - region은 명단의 국가 값을 기존 폴더(china, korea, japan, mongol)에 맞춘다. 새 지역(돌궐, 토번, 여진 등)은 `steppe`, `tibet`, `manchuria`처럼 폴더를 새로 만들고 보고서에 적는다.
- 매핑 csv(Drive 74 표를 옮긴 것)도 `data/heroes/source/`에 넣는다.
- 원본 받기가 늦어지면 초상화 없이 정의만 먼저 올려도 된다. 이때 `portrait_path`는 빈 값으로 두고, 검증기는 "초상화 없음" 목록을 출력한다. 초상화는 같은 브랜치에 후속 커밋으로 올린다.
- 파일 크기: 한 장에 1 MB를 넘지 않는다(기존 512 초상화는 약 0.4 MB). 브랜치 전체가 100 MB를 넘지 않는다.

## 5. 시험 (`tests/scripts/test_hero_register_119.gd`, 태그 `[HERO_REG119]`, C-track 목록에 추가)
1. 등록 수 163. 새 119명의 ID가 서로 겹치지 않고 기존 44명과도 겹치지 않는다. 이름도 겹치지 않는다.
2. 기존 44명의 정의 사전이 `6b6bc2f` 시점과 완전히 같다(값을 스냅샷으로 비교).
3. 새 119명 모두 주둔 필드 3개가 비어 있다. 새 게임을 시작한 뒤 확인할 것:
   - 도시별 주둔 목록, 플레이어 보유 장수, 탐색/등용 후보 목록이 `6b6bc2f`와 같다(스냅샷 비교).
   - 새 장수가 무주공산에 들어가지 않는다.
4. 기존 저장(수동 슬롯 `user://worldmap_manual_save.json`과 턴 체크포인트)을 불러와도 3과 같다.
5. 새 장수 정의 조회: 119명 모두 `get_definition`이 값을 돌려준다. `stats_approved == false`. 조운은 초안 표시가 있다. 새 특기 9명은 원안 타입이 그대로 남아 있다.
6. 모르는 특기 타입: 전투 엔진에 `charge_aoe` 장수를 넣어 특기를 쓰게 하면 크래시 없이 효과 0이고, `[SKILL_UNIMPLEMENTED]` 로그가 1줄 남는다.
7. (초상화가 있으면) 119장 모두 512×512 RGB이고, `load()`가 null이 아니다.
- `tools/validate_hero_*` 검증기는 163명 기준으로 통과해야 한다. 검증기 기대값(44)을 바꿀 때는 그 이유를 보고서에 적는다.

## 6. 금지
- 규칙 값 변경 금지: 전투 공식, 충성도 규칙, 특기 효과 수치.
- `worldmap_main.gd` 변경 금지. 꼭 바꿔야 하면 `tools/p1_exact_delta.py`에 새 체크포인트를 잡고 이유를 보고서에 적는다.
- 배치 금지. A 수정안의 도시 정보는 `data/heroes/source/placement_A_revised_20261128.json`에 자료로만 넣고, 코드에서 읽지 않는다.
- 2K 원본을 커밋하지 않는다. force push와 브랜치 삭제를 하지 않는다.

## 7. 브랜치와 보고
- 브랜치: `feature/hero-register-119-20261128`. 바탕은 `main` `6b6bc2f`.
- 보고서: `agent/REPORT_HERO_REGISTER_119_20261128.md`에 다음을 적는다.
  - 등록 수, region 폴더, 초상화 없음 목록, 검증기 결과, CI run 번호.
  - 기존 44명의 diff가 0줄이라는 증거.
