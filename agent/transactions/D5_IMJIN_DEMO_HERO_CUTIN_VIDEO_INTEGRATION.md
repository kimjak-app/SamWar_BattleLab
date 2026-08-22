# D5 — Imjin Demo Hero Cutin Video Integration

## Status

`D5-1 VIDEO ENCODE + VIDEO-ONLY VALIDATION PASS / D5-2 TITLE PNG ASSET GATE / F6 QA PENDING`

## Goal

Integrate the eight newly authored Imjin demo hero cutin videos through the exact existing Godot cutin path used by Yi Sun-sin, Kwon Yul, and the Korea MVP roster.

Do not introduce a new playback widget or a parallel cutin engine.

## Existing production contract preserved

The runtime path remains:

1. canonical `hero_id` + `skill_id` resolve a cutin registry entry;
2. `HeroCutinPresentation` loads a `VideoStreamTheora` OGV background;
3. the existing presentation scene overlays hero name, separate skill-title texture, and dialogue;
4. the existing 4.01-second presentation timeline finishes and returns to the committed unique-skill flow;
5. if the video or title texture cannot load, the existing static fallback remains available.

The original `data/cutin/korea_mvp_hero_cutins.json` is not modified by D5.

`scripts/ui/cutin/korea_mvp_hero_cutin_registry.gd` now appends the separate `data/cutin/imjin_demo_hero_cutins.json` registry so Test1/Korea MVP entries remain isolated from the new demo manifest.

## D5 roster

- `gwak_jae_u` / 곽재우 / `gwak_jae_u_unique` / 홍의장군
- `go_gyeong_myeong` / 고경명 / `go_gyeong_myeong_unique` / 호남의병
- `kim_deok_ryeong` / 김덕령 / `kim_deok_ryeong_unique` / 충용장
- `toyotomi_hideyoshi` / 도요토미 히데요시 / `toyotomi_hideyoshi_unique` / 태합호령
- `shimazu_yoshihiro` / 시마즈 요시히로 / `shimazu_yoshihiro_unique` / 귀석만자
- `kato_kiyomasa` / 가토 기요마사 / `kato_kiyomasa_unique` / 칠본창
- `konishi_yukinaga` / 고니시 유키나가 / `konishi_yukinaga_unique` / 선봉교섭
- `kuroda_nagamasa` / 구로다 나가마사 / `kuroda_nagamasa_unique` / 세키가하라 조략

## Source MP4 mapping

User-authored sources are tracked under:

`assets/video_source_test/production_dry_run/imjin_demo/`

Some source filenames contain spelling mistakes. D5 treats those names only as source-file labels and maps them to canonical runtime IDs/output names:

- `곽재우컷인.mp4` -> `gwak_jae_u`
- `고경명컷인.mp4` -> `go_gyeong_myeong`
- `김덕룡컷인.mp4` -> `kim_deok_ryeong`
- `도요토미히데오시컷인.mp4` -> `toyotomi_hideyoshi`
- `시마즈요시히로컷인.mp4` -> `shimazu_yoshihiro`
- `가토기요마사.mp4` -> `kato_kiyomasa`
- `고니시유키나가컷인.mp4` -> `konishi_yukinaga`
- `구로다마사히로컷인.mp4` -> `kuroda_nagamasa`

Do not propagate source filename typos into canonical hero IDs or final runtime asset names.

## Encode contract

`tools/convert_imjin_demo_cutins.ps1` uses the established safe Theora family:

- target container: `.ogv`
- video codec: `libtheora`
- 1280x720
- 30 fps
- `yuv420p`
- `q:v 8`
- GOP `60`
- normalized target duration `4.01` seconds
- no audio (`-an`) because these authored cutin backgrounds are silent presentation layers

Repo-local FFmpeg is preferred:

- `tools/ffmpeg/bin/ffmpeg.exe`
- `tools/ffmpeg/bin/ffprobe.exe`

The script falls back to PATH only if those repo-local tools are absent.

Run from repository root on Windows:

```powershell
powershell -ExecutionPolicy Bypass -File tools/convert_imjin_demo_cutins.ps1
```

Then run:

```text
python tools/validate_imjin_demo_cutins.py --video-only
```

## D5-1 user validation result — PASS

On 2026-08-22 the user reran the conversion after replacing the Gwak Jae-u and Go Gyeong-myeong MP4 sources with corrected-duration versions, then executed:

```text
python tools/validate_imjin_demo_cutins.py --video-only
```

Observed result:

- `gwak_jae_u`: source=True / ogv=True / enabled=True
- `go_gyeong_myeong`: source=True / ogv=True / enabled=True
- `kim_deok_ryeong`: source=True / ogv=True / enabled=True
- `toyotomi_hideyoshi`: source=True / ogv=True / enabled=True
- `shimazu_yoshihiro`: source=True / ogv=True / enabled=True
- `kato_kiyomasa`: source=True / ogv=True / enabled=True
- `konishi_yukinaga`: source=True / ogv=True / enabled=True
- `kuroda_nagamasa`: source=True / ogv=True / enabled=True

Final validator line:

`D5 IMJIN DEMO CUTIN VALIDATION PASS (VIDEO-ONLY): 8 canonical cutin contracts`

Therefore D5-1 video conversion/resource contract is manually locked PASS. Final D5 remains open only because the separate title PNG resources and live F6 presentation QA are still pending.

## Final OGV names

- `assets/ui/cutin/videos/gwak_jae_u__hongui_janggun__cutin_bg_theora_q8_1280x720.ogv`
- `assets/ui/cutin/videos/go_gyeong_myeong__honam_uibyeong__cutin_bg_theora_q8_1280x720.ogv`
- `assets/ui/cutin/videos/kim_deok_ryeong__chungyongjang__cutin_bg_theora_q8_1280x720.ogv`
- `assets/ui/cutin/videos/toyotomi_hideyoshi__taehap_horyeong__cutin_bg_theora_q8_1280x720.ogv`
- `assets/ui/cutin/videos/shimazu_yoshihiro__gwiseok_manja__cutin_bg_theora_q8_1280x720.ogv`
- `assets/ui/cutin/videos/kato_kiyomasa__chilbonchang__cutin_bg_theora_q8_1280x720.ogv`
- `assets/ui/cutin/videos/konishi_yukinaga__seonbong_gyoseop__cutin_bg_theora_q8_1280x720.ogv`
- `assets/ui/cutin/videos/kuroda_nagamasa__sekigahara_joryak__cutin_bg_theora_q8_1280x720.ogv`

## D5-2 title PNG asset gate

The existing cutin implementation requires both the OGV and a separate skill-title texture. D5 intentionally does not replace this with dynamic text or a new rendering path.

Required title PNG files:

- `assets/ui/cutin/titles/gwak_jae_u__hongui_janggun__title.png`
- `assets/ui/cutin/titles/go_gyeong_myeong__honam_uibyeong__title.png`
- `assets/ui/cutin/titles/kim_deok_ryeong__chungyongjang__title.png`
- `assets/ui/cutin/titles/toyotomi_hideyoshi__taehap_horyeong__title.png`
- `assets/ui/cutin/titles/shimazu_yoshihiro__gwiseok_manja__title.png`
- `assets/ui/cutin/titles/kato_kiyomasa__chilbonchang__title.png`
- `assets/ui/cutin/titles/konishi_yukinaga__seonbong_gyoseop__title.png`
- `assets/ui/cutin/titles/kuroda_nagamasa__sekigahara_joryak__title.png`

At D5-1 PASS, these eight title PNGs are still the remaining asset gate. Until they are supplied, video-only validation can pass but final cutin validation must remain pending.

The registry `dialogue` fields are intentionally blank for the new eight entries rather than inventing character lines. They can be authored later without changing the video routing contract.

## Final validation

After OGV and title PNG assets exist:

```text
python tools/validate_imjin_demo_cutins.py
python tools/validate_all_korea_mvp_video_cutins.py
python tools/validate_actual_video_cutin_playback.py
```

Then F6 Test2 manual QA:

1. each of the eight new heroes routes to the correct video;
2. hero name matches the actor;
3. skill-title PNG matches the actual unique skill;
4. no black/rainbow/corrupt Theora output;
5. cutin exits normally after the existing timeline;
6. the unique-skill effect executes exactly once;
7. Hongui Janggun still enters its post-skill 3-cell reposition phase after the cutin/effect sequence;
8. no Test1 Korea-vs-China cutin regression.

Do not mark D5 complete until final validator + F6 checks pass.
