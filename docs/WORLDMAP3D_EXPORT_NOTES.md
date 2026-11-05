# WorldMap3D — 내보내기·폴백·설정 메모 (T-WM3D-08)

## 1. 모바일 내보내기에서 3D 제외
- 원칙: 모바일 내보내기 프리셋에는 `worldmap3d/**`를 **제외 필터**로 넣는다. 저장소에는 `export_presets.cfg`가 아직 없어서, 프리셋을 처음 만들 때 이 필터를 함께 넣는다(T-WM3D-08에서는 프리셋을 만들지 않음).
- 코드는 이것을 전제로 짜여 있다. `scripts/`(2D 게임, C-track CI, 모바일)는 `worldmap3d/`의 클래스·파일을 타입이나 `preload`로 부르지 않는다. 3D 장면은 문자열 경로(`WorldMap3DSettings.SCENE_3D` = `res://worldmap3d/scenes/worldmap3d_eastasia.tscn`)로만 연다.
- C-track CI는 같은 상황을 `worldmap3d/.gdignore`로 재현한다(`verify-c-track.yml` "Exclude 3D world map from shard import"). 그래서 C-track의 모든 `WorldMap.tscn` 테스트는 2D로 돈다. 3D는 `verify-worldmap3d.yml`이 맡는다.

## 2. 3D 폴백 (3D가 없거나 꺼져 있으면 2D 그대로)
- `WorldMap.tscn`의 `WorldMap3DHost`(WorldMap 루트의 자식, `main_path = ".."`)가 main이 준비되기를 기다린 뒤(`await main.ready`) 판단한다.
  - 사용자 설정이 2D → 3D 레이어를 **만들지 않는다**(VRAM 0). main의 2D 카메라 컨트롤러·`$WorldMapRoot`를 그대로 쓴다.
  - 3D 파일이 없음(`ResourceLoader.exists` 실패) → 한 줄 안내(`[WorldMap3DHost] 3D map unavailable … -> 2D world map`)를 출력하고 2D를 유지한다. 오류는 내지 않는다.
- `worldmap_main.gd`는 3D를 모른다. 호스트가 main의 이름(`_camera_controller`, `_city_markers_by_id`, `_ensure_camera_controller` 등)에 붙는다. main에서 이름이 바뀌면 `tests/scripts/test_worldmap3d_host.gd`가 실패한다.
- 한 main에 호스트는 하나다. `WorldMap3D_Host_Test.tscn`처럼 바깥에 호스트를 하나 더 붙이면, 먼저 main을 차지한 `WorldMap.tscn` 쪽 호스트가 맡고 바깥 호스트는 `idle`로 쉰다.
- 전투 뒤에는 `result_return_destination = "res://WorldMap.tscn"`(main)로 같은 장면에 돌아오므로 3D도 그대로 다시 만들어진다. 불러온 도시 소유는 호스트가 0.25초마다 동기화한다.

## 3. 게임 저장 파일과 사용자 설정은 따로
| 무엇 | 파일 | 쓰는 곳 |
|---|---|---|
| 게임 진행(도시·턴 등) | `user://worldmap_left_panel_state.json` | `worldmap_main.gd` `_serialize_worldmap_state()` / `_write_worldmap_state_mvp()` |
| 소리 설정 | `user://samwar_audio.cfg` | `scripts/audio/game_audio.gd`(저장할 때 파일 전체를 새로 씀) |
| 월드맵 2D/3D, 3D 카메라 입력 A/B | `user://samwar_worldmap3d.cfg` (`[worldmap] map_view`, `camera_input_scheme`) | `scripts/worldmap/map3d/worldmap_3d_settings.gd`, 설정 팝업(`시스템` 메뉴) |
| 3D 메모리 측정 기록 | `user://wm3d_mem_log.csv` | `scripts/worldmap/map3d/worldmap_3d_mem_probe.gd` |

- 월드맵 설정을 소리 설정 파일에 넣지 않은 이유: `GameAudio._save_settings()`가 새 `ConfigFile`로 파일 전체를 덮어써서, 다른 섹션은 지워진다.
- 저장→불러오기로는 2D/3D·카메라 설정이 바뀌지 않는다(`test_worldmap3d_production.gd` 5c).

## 4. 3D 카메라 입력 방식 (실제 구현: `worldmap3d/scripts/worldmap_camera.gd` v2.2)
- 공통: 왼쪽 클릭 = 선택, 휠 = 확대·축소, WASD/화살표 = 이동, Q/E = 회전, 가운데 드래그 = 이동.
- A: 오른쪽 드래그 = 회전. B: 오른쪽 드래그 = 이동(회전은 Q/E로만).
- 맵 기본값은 `map_config.json` `camera.input_scheme`(동아시아 "A")이고, 사용자가 고르면 그 값이 우선한다.
