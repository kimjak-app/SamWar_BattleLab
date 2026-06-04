# NEXT TASKS

## Next: F6 Visual QA for Archer Volley Readability
- `v0.70-9b` tunes the visual-only multi-arrow volley for archer normal/basic attacks.
- Current archer units expected to show the volley:
  1. Yi Sunsin / `yi_sunsin` / `korea_archer`.
  2. Kim Yu-sin / `gim_yusin` / `korea_archer`.
  3. Liu Bei / `liu_bei` / `china_archer`.
- The effect uses runtime `Line2D` arrows and impact pins only; no arrow asset file was added.
- The volley now uses 9 arrows, slower `0.34`-`0.50` second travel, and wider `0.05`-`0.12` second launch stagger.
- Manual visual QA should confirm:
  1. Yi Sunsin, Kim Yu-sin, and Liu Bei basic attacks fire a clearly heavier stream of small arrows.
  2. Arrows are slower and readable in flight, distinct from future gunner-shot speed.
  3. Arrows land near the target with small scattered impact pins and do not cover the unit too heavily.
  4. Jeong Do Jeon, Kwon Yul, Eulji Mundeok, Guan Yu, Zhang Fei, Xiahou Dun, and Zhuge Liang basic attacks do not show arrow volley.
  5. Strategy and unique/special skills, including Hakikjin cannon AOE, Samguk Tongil charge, and Salsu Daechop, do not show arrow volley.
  6. Damage, hit results, turn progression, and WorldMap return behavior remain unchanged.

## Next: F6 Visual QA for Mirrored Yi Sunsin / Eulji Mundeok Cutin Layouts
- `v0.70-8b` mirrors only Yi Sunsin and Eulji Mundeok specialty cutin layouts.
- Expected layout:
  1. Yi Sunsin: hero portrait right, Hakikjin title image left.
  2. Eulji Mundeok: hero portrait right, Salsu Daechop title image left.
  3. Kwon Yul / Jeong Do Jeon / Kim Yu-sin remain hero portrait left, title image right.
- No cutin video mapping, q8 OGV asset, fallback chain, special-skill trigger logic, or WorldMap logic changed.
- Manual visual QA should confirm:
  1. Yi Sunsin unique skill shows the mirrored composition cleanly.
  2. Eulji Mundeok unique skill shows the mirrored composition cleanly.
  3. Mirrored portrait entry direction feels natural from the right.
  4. Mirrored title placement remains readable on the left.
  5. Kwon Yul, Jeong Do Jeon, and Kim Yu-sin layouts did not drift.
  6. Battle flow returns normally after each cutin.

## Next: F6 Visual QA for Kim Yu-sin / Eulji Mundeok Special-Skill Cutins
- `v0.70-8 Kim Yu-sin + Eulji Mundeok Special-Skill Cutin Integration` adds both heroes to the existing specialty unique-skill cinematic cutin path.
- Scope is explicitly special-skill activation only. There is no reinforcement-arrival cutin hook.
- Runtime first-candidate paths are:
  1. `res://assets/ui/cutin/videos/kim_yu_sin_cutin_bg_theora_q8_1920x.ogv`
  2. `res://assets/ui/cutin/videos/eulji_mundeok_cutin_bg_theora_q8_1920x.ogv`
- Title PNG paths are:
  1. `res://assets/ui/cutin/titles/kim_yu_sin_samguktongil_title.png`
  2. `res://assets/ui/cutin/titles/eulji_mundeok_salsudaecheop_title.png`
- Portrait PNG paths are:
  1. `res://assets/ui/cutin/portraits/kim_yu_sin_cutin.png`
  2. `res://assets/ui/cutin/portraits/eulji_mundeok_cutin.png`
- Manual visual QA should confirm:
  1. Kim Yu-sin cutin plays when using his unique skill, not when he appears as reinforcement.
  2. Eulji Mundeok cutin plays when using his unique skill, not when he appears as reinforcement.
  3. No black-screen playback appears.
  4. Portrait and title image appear.
  5. Skill effect and battle flow resume after the cutin.
  6. Existing Yi Sunsin, Kwon Yul, and Jeong Do Jeon cutins remain unaffected.
- If accepted, later visual tuning can adjust Kim Yu-sin and Eulji Mundeok per-hero layout values independently.

## Next: F6 Visual QA for Kim Yu-sin Tactical Cell Clickability
- `v0.70-7b Kim Yu-sin Tactical Cell Clickability Root-Cause Fix` changes ally-turn input priority so valid highlighted move-cell clicks run before ally unit selection.
- This targets the repeated case where Kim Yu-sin is selected and a reachable cell below/near Kwon Yul appears highlighted but clicking it selects or hits the nearby ally click area instead of moving.
- Command panel scoring now makes detached viewport-corner fallbacks much less likely, keeping the panel closer to the selected unit when possible.
- Manual visual QA should confirm:
  1. Select Kim Yu-sin.
  2. Confirm the command panel does not jump far to the lower-left or lower-right unless there is no usable near placement.
  3. Confirm the highlighted move cell below/near Kwon Yul can be clicked if it is visibly reachable.
  4. Confirm blocked cells are not shown as reachable move targets.
  5. Confirm `이동`, `기본공격`, `책략`, `고유특기`, `방어`, and `대기` still work normally.
  6. Confirm battle flow remains stable after movement and command selection.
- No cutin/video/mapping QA is required for this patch beyond confirming those files were untouched.

## Next: F6 Visual QA for Replaced Jeong Do Jeon q8 Cutin Video
- `v0.70-6b Jeong Do Jeon Source Replacement + q8 Theora Regeneration` regenerated the existing first-candidate q8 Theora OGV from the newly replaced source MP4.
- Runtime first-candidate path remains unchanged:
  `res://assets/ui/cutin/videos/jeong_do_jeon_cutin_bg_theora_q8_1920x.ogv`
- The title PNG path remains unchanged:
  `res://assets/ui/cutin/titles/jeong_do_jeon_gaehyeokryeong_title.png`
- Manual visual QA should confirm:
  1. Jeong Do Jeon now displays the newly replaced video in the actual battle flow.
  2. No black-screen playback appears.
  3. The 개혁령 title image still appears correctly.
  4. The cutin exits and battle flow returns normally.
  5. Yi Sunsin and Kwon Yul q8 cutins remain unaffected.

## Next: F6 Visual QA for Tactical Panel Distance and Move Cell Clickability
- `v0.70-7a Tactical Panel Distance Clamp + Move Cell Clickability Fix` tightens the previous overlap avoidance so the floating panel prefers nearby positions and only uses screen-corner fallbacks as a last resort.
- Valid highlighted move-cell clicks now run before enemy unit hit testing, which targets the reported cell below/near Xiahou Dun being visually reachable but not clickable.
- Manual visual QA should confirm:
  1. Select Kim Yu-sin.
  2. Confirm the command panel no longer feels detached in the lower-right corner unless every nearby position is clearly worse.
  3. Confirm the highlighted move cell below/near Xiahou Dun can be clicked if it is visibly reachable.
  4. Confirm unreachable/blocked cells are not shown as move targets.
  5. Confirm `이동`, `기본공격`, `책략`, `고유특기`, `방어`, and `대기` still work normally.
  6. Confirm battle flow remains stable after movement and target selection.
- If accepted, this becomes the tactical command panel placement/input baseline before considering draggable panel behavior.

## Next: F6 Visual QA for Tactical Command Panel Grid Overlap
- `v0.70-7 Tactical Command Panel Grid Overlap Avoidance` adds automatic placement avoidance for `FloatingAllyCommandPanel` and hides the panel during explicit target-selection phases.
- Manual visual QA should confirm:
  1. Select an ally near visible reachable hexes.
  2. Confirm the floating command panel chooses a position that does not cover important move/attack cells when possible.
  3. Click `기본공격`, `책략`, or `고유특기` and confirm the panel hides or stops blocking target cells/units.
  4. Click a movement or target cell that used to be blocked by the panel.
  5. Confirm the intended move/attack/skill/strategy flow proceeds.
  6. Right-click cancel from target selection and confirm the command panel can return normally.
- If accepted, treat this as the tactical command panel non-blocking baseline before considering a draggable panel.

## Next: F6 Visual QA for Kwon Yul / Jeong Do Jeon q8 Theora Dry Runs
- `v0.70-6a Kwon Yul + Jeong Do Jeon q8 Theora Production Dry Runs` encoded and connected both heroes to new q8 1920x Theora dry-run assets.
- Runtime first-candidate paths are:
  1. `res://assets/ui/cutin/videos/kwon_yul_cutin_bg_theora_q8_1920x.ogv`
  2. `res://assets/ui/cutin/videos/jeong_do_jeon_cutin_bg_theora_q8_1920x.ogv`
- Title PNG paths are wired:
  1. `res://assets/ui/cutin/titles/kwon_yul_haengjudaecheop_title.png`
  2. `res://assets/ui/cutin/titles/jeong_do_jeon_gaehyeokryeong_title.png`
- Both q8 OGVs load as `VideoStreamTheora`; both title PNGs load as `CompressedTexture2D`; Godot headless project and `Battle_Fullscreen_Test.tscn` load passed.
- Manual visual QA should confirm:
  1. Kwon Yul q8 video and title image appear in the actual battle flow.
  2. Jeong Do Jeon q8 video and title image appear in the actual battle flow.
  3. Neither cutin shows black-screen playback or obvious color corruption.
  4. Battle flow returns after each cutin.
  5. Per-hero layout overrides are sufficient for later independent tuning.
- If playback is accepted, next patch should tune Kwon Yul and Jeong Do Jeon cinematic layouts separately instead of sharing identical Yi Sunsin values.

## Next: F6 Visual QA for Yi Sun-sin Final Exit Snap
- `v0.70-5e Yi Sun-sin Final Exit Snap Tuning` keeps the accepted Hakikjin readable-hold and large-burst behavior, but shortens the tail after that event.
- Hakikjin still exits before Yi Sunsin; Yi Sunsin now remains only briefly afterward before the full cutin snaps out.
- Timing baseline: full cutin exit starts at `1.18s`, final fade duration is `0.14s`, and total cutin duration is now `1.38s`.
- Manual visual QA should confirm:
  1. Hakikjin still exits before Yi Sunsin.
  2. Yi Sunsin no longer lingers too long after the title burst.
  3. The final cutin disappearance feels sharp and decisive.
  4. Battle rhythm resumes more immediately.
  5. q8 Theora playback and battle-flow return still work.
- If accepted, this should be treated as the current Yi Sunsin final-exit timing baseline.

## Next: F6 Visual QA for Hakikjin Readable Hold and Large Burst Fade
- `v0.70-5d Hakikjin Readable Hold + Large Burst Fade Tuning` keeps Yi Sunsin composition stable and focuses on Hakikjin readability.
- Hakikjin now appears at readable base size, holds briefly, then expands dramatically to `2.25` while fading and drifting upward.
- Hakikjin still disappears before Yi Sunsin exits, preserving the dynamic cutin rhythm.
- Manual visual QA should confirm:
  1. Hakikjin stays visible long enough to read.
  2. Hakikjin grows very large while disappearing.
  3. Yi Sunsin remains well positioned.
  4. The cutin feels more satisfying overall.
  5. q8 Theora playback and battle-flow return still work.
- If accepted, this should be treated as the current Yi Sunsin readable-title-burst baseline.

## Next: F6 Visual QA for Hakikjin Large Burst-Out
- `v0.70-5c Yi Sun-sin Vertical Balance + Hakikjin Large Burst-Out Tuning` keeps Yi Sunsin scale roughly stable and moves the oversized portrait down slightly for top/bottom balance.
- Hakikjin now appears at base size, rapidly grows much larger, and disappears while continuing to enlarge.
- Manual visual QA should confirm:
  1. Yi Sunsin top/bottom spacing feels balanced.
  2. Hakikjin grows dramatically while disappearing.
  3. The cutin feels more impactful and less label-like.
  4. q8 Theora playback remains clean.
  5. Battle-flow return still works.
- If accepted, this should be treated as the current Yi Sunsin title-burst baseline.

## Next: F6 Visual QA for Yi Sun-sin Dominance and Hakikjin Burst
- `v0.70-5b Yi Sun-sin Dominance + Hakikjin Pop-and-Burst Tuning` further enlarges and left-shifts the Yi Sunsin portrait.
- Hakikjin title image now performs a short burst: appears, expands strongly, and fades/disappears instead of sitting statically.
- Manual visual QA should confirm:
  1. Yi Sunsin dominates the left side enough.
  2. Hakikjin appears, expands, and disappears clearly.
  3. The cutin feels more dynamic and forceful.
  4. q8 Theora playback remains clean.
  5. Battle-flow return still works.
- If accepted, this becomes the current Yi Sunsin hero-cutin presentation baseline.

## Next: F6 Visual QA for Hakikjin Title Image Cutin Impact
- `v0.70-5a Yi Sun-sin Hero Scale + Skill Title Image Impact Tuning` removes the `이순신` name text and replaces the plain `학익진!` label with `assets/ui/cutin/titles/yi_sun_sin_hakikjin_title.png`.
- The Yi Sunsin portrait is now much larger, pushed left/center-left, and allowed to overflow the cutin panel for a stronger hero-splash silhouette.
- Manual visual QA should confirm:
  1. Yi Sunsin is large and heroic enough.
  2. `이순신` text is fully gone.
  3. The Hakikjin PNG title reads clearly and feels premium.
  4. Hero whoosh and title pop feel forceful rather than floaty.
  5. q8 Theora playback and battle-flow return still work.
- If the title image is accepted, this becomes the Yi Sunsin presentation baseline before adapting the same image-title approach to other hero cutins.

## Next: F6 Visual QA for Yi Sun-sin Cinematic Cutin Polish
- `v0.70-5 Yi Sun-sin Cutin Cinematic Layout Polish` upgrades presentation while preserving the q8 Theora production dry-run playback baseline.
- Current Yi Sunsin cutin still tries `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv` first, with the 540p Theora / VP8 WebM / legacy OGV-WebM / MP4 fallback chain preserved.
- The foreground portrait is larger and more heroic, the thick yellow diagonal slash has been replaced by a restrained steel-blue/sea-spray accent, and `이순신` / `학익진!` now use stronger staged typography.
- Manual visual QA should check:
  1. Yi Sunsin portrait scale and presence.
  2. `학익진!` impact and readability against the moving OGV.
  3. Removal/replacement of the tacky yellow slash.
  4. Overall cinematic/naval/martial feel.
  5. Clean cutin exit and post-cutin battle-flow return.
- If accepted, treat the Yi Sunsin q8 Theora cinematic layout as the visual baseline before expanding the same pipeline to Kwon Yul / Jeong Do Jeon.

## Next: Expand q8 Theora Cutin Pipeline After Yi Sun-sin Visual Baseline
- Use the Yi Sunsin q8 Theora and layered cinematic presentation as the reference direction.
- Candidate expansion path:
  1. Prepare or verify source assets for Kwon Yul and Jeong Do Jeon.
  2. Encode separate q8 or performance-appropriate Theora candidates without overwriting existing production files.
  3. Connect one hero at a time with fallback chains preserved.
  4. Run manual F6 QA for playback, color, text readability, cutin exit, and battle-flow return.

## Next: Expand q8 Theora Cutin Pipeline After Yi Sun-sin Manual QA Pass
- `v0.70-4a Yi Sun-sin q8 Theora Manual QA Documentation` records a successful manual Godot battle-flow QA pass.
- Stable baseline: commit `f3d53e0` connects Yi Sunsin to `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv` first, with existing fallbacks preserved.
- User confirmed the actual battle-flow cutin displays cleanly: no black-screen lock, no obvious color corruption, and acceptable q8 1920x Theora quality for production dry-run.
- Recommended next candidates:
  1. Confirm the Yi Sunsin q8 dry-run checkpoint as the stable cutin-video baseline.
  2. Extend the q8 Theora encode/connect pipeline to Kwon Yul and Jeong Do Jeon cutins.
  3. Run focused QA for cutin exit, unique-skill effect continuation, and battle-flow return.
  4. Document q8 file-size and runtime-performance criteria if the 1920x asset becomes the production default.

## Next: F6 Visual QA for Yi Sun-sin q8 Theora Production Cutin Dry Run
- `v0.70-4 Production Cutin Theora Dry Run - Yi Sun-sin q8` is implemented.
- Current Yi Sunsin cutin dry-run path is `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv`.
- Source: `assets/video_source_test/production_dry_run/yi_sun_sin_cutin_source_02s.mp4`.
- Output: `assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv` plus Godot sidecar `assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_q8_1920x.ogv.uid`.
- Output spec: Theora, 1920x1080, yuv420p, 30fps, duration `2.000000`, size `7580014` bytes.
- Godot headless project load, battle scene load, and direct resource verification passed; the OGV loads as `VideoStreamTheora`.
- Kimjak F6/manual QA should trigger Yi Sunsin's specialty cutin in the real battle flow and confirm: q8 OGV is selected, playback starts, no black screen, colors match the source tone, the clip finishes, the 3-second cutin presentation exits, post-cutin unique-skill effect applies, and battle flow resumes.
- Existing production MP4/WebM/540p OGV files are preserved and remain fallbacks.

## Next: Apply Safe Theora Preset to Production Candidate
- `v0.70-3 Portable FFmpeg Setup + Theora Safe Encode Execution` is complete.
- Safe test outputs now exist under `assets/video_test/theora_safe/`.
- Recommended safe preset is q7 1280x:
  - `fps=30,scale=1280:-2:flags=lanczos,format=yuv420p`
  - `libtheora -q:v 7 -g 60`
  - `libvorbis -q:a 4`
- q7 and q8 both load in Godot as `VideoStreamTheora`, reach `is_playing=true`, render non-black frames, and preserve normal source-like color in captured frames.
- q7 is preferred for production-candidate conversion because it is `3426729` bytes versus q8 `7295937` bytes and meets the stability/color goal.
- Next task should convert a production candidate into a separate test/proposed output first, then manually verify in the real cutin layer before replacing any production asset.
- Do not overwrite `assets/ui/cutin/videos/` directly without an explicit production replacement task.

## Next: Complete v0.70-2 Theora Safe Encoding Playback QA
- `v0.70-2 Theora Safe Encoding Test + Godot Color Playback Verification` is partially complete.
- Source confirmed: `assets/video_source_test/cutin_test_01.mp4`.
- Test output folder prepared: `assets/video_test/theora_safe/`.
- Godot test scene prepared: `scenes/dev/video_theora_test.tscn`.
- Current blocker: `ffmpeg` is not available in PATH and no repo-local FFmpeg binary was found, so no q7/q8 `.ogv` files were generated.
- Next local action when FFmpeg is available:
  - `ffmpeg -y -i "assets/video_source_test/cutin_test_01.mp4" -vf "fps=30,scale=1280:-2:flags=lanczos,format=yuv420p" -c:v libtheora -q:v 7 -g 60 -c:a libvorbis -q:a 4 "assets/video_test/theora_safe/test_safe_q7_1280x.ogv"`
  - `ffmpeg -y -i "assets/video_source_test/cutin_test_01.mp4" -vf "fps=30,scale=1920:-2:flags=lanczos,format=yuv420p" -c:v libtheora -q:v 8 -g 60 -c:a libvorbis -q:a 4 "assets/video_test/theora_safe/test_safe_q8_1920x.ogv"`
  - If audio encoding fails, retry q7 with `-an` to create `assets/video_test/theora_safe/test_safe_q7_1280x_noaudio.ogv`.
- Then open `scenes/dev/video_theora_test.tscn`, switch between q7/q8/noaudio candidates, and record whether each loads as `VideoStream`, plays non-black frames, and preserves normal color.
- Do not copy test output into `assets/ui/cutin/videos/` until Godot visual playback is confirmed.

## Next: v0.70-11 Cutin Safe Theora Encoding Test
- `v0.70-10A VideoStreamPlayer Debug Checkpoint Documentation` is complete as a documentation-only checkpoint after `v0.70-10`.
- Current cutin presentation is stable: Yi Sunsin cutin layer, PNG portrait, hero/skill text, centered layout, 3-second exit, post-cutin unique-skill effect flow, busy guard, and PNG/text fallback are intact.
- VideoStreamPlayer progress: the Theora 540p OGV reached Godot editor recognition as a `VideoStream` after FileSystem selection, and a local `.ogv.uid` sidecar appeared.
- Current blocker: Theora 540p OGV playback appears rainbow/glitch-corrupted, so the active hypothesis is Theora encoding/decoding compatibility, not missing file or VideoStreamPlayer layout/z-index/size.
- Keep pursuing VideoStreamPlayer because intro, specialty cutins, battle result videos, worldmap event cutscenes, opening, and ending all need a real video pipeline. Image sequence fallback remains a last-resort alternative.
- Recommended next task goal: create and test a more conservative Godot-friendly Theora encode.
- Candidate 360p safe encode:
  - `ffmpeg -y -i "assets/ui/cutin/videos/yi_sun_sin_cutin_bg.mp4" -t 3 -vf "scale=640:360:flags=lanczos,fps=24,format=yuv420p" -pix_fmt yuv420p -c:v libtheora -q:v 5 -g 48 -an "assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_360p_safe.ogv"`
- Candidate 540p q6/g64 retry:
  - `ffmpeg -y -i "assets/ui/cutin/videos/yi_sun_sin_cutin_bg.mp4" -t 3 -vf "scale=960:540,fps=24,format=yuv420p" -pix_fmt yuv420p -c:v libtheora -q:v 6 -g 64 -an "assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_540p_q6_g64.ogv"`
- Next chat reading order:
  - `agent/WORKFLOW_MANAGER.md`
  - `agent/CODEX_WORKFLOW_RULES.md`
  - `agent/GODOT_RULES.md`
  - `agent/CURRENT_STATE.md`
  - `agent/NEXT_TASKS.md`
  - `agent/HANDOFF_TO_CODEX.md`
  - `agent/CHANGELOG.md`
  - `agent/SESSION_LOG.md`

## Next: v0.70-11 VideoStreamPlayer Final Fix or Alternative Pipeline Decision
- `v0.70-10 VideoStreamTheora Direct Load Test` is complete.
- Ally Yi Sunsin cutin now selects `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_theora_540p.ogv` before VP8 WebM, legacy OGV, snake_case WebM, and MP4.
- Candidate diagnostics now include `FileAccess`, `ResourceLoader`, load-null, class, `is VideoStream`, and failure-guess fields.
- Theora 540p OGV has a ResourceLoader path plus a direct `VideoStreamTheora.new()` fallback path that sets the dynamic `file` property when available.
- `CUTIN_VIDEO_DEBUG_FORCE_TOP` remains available for local visual isolation and is committed as `false`.
- The centered cutin banner/card layout, PNG/text fallback, 3-second timing, busy guard, and post-cutin unique-skill effect flow are preserved.
- Kimjak F6 QA remains decisive for actual video frame visibility and console log interpretation.
- Recommended next tasks:
  - `v0.70-11 VideoStreamPlayer Final Fix or Alternative Pipeline Decision`
  - `v0.70-12 Specialty Skill Cutin Visual Polish`
  - `v0.70-13 Add Kwon Yul and Jeong Do Jeon Cutins`
  - `v0.70-14 WorldMap Final IA Blueprint + Panel Skeleton`

## Next: v0.70-10 Specialty Skill Cutin Visual Polish
- `v0.70-9 VideoStreamPlayer Cutin Debug Pass` is complete.
- Ally Yi Sunsin cutin still prioritizes `vp8 webm > ogv > webm > mp4` and selects `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg_vp8.webm` first when present.
- The first SamWar practical VideoStreamPlayer diagnostics are now in place for candidate load results, player state, size, z-order, parent state, and delayed `is_playing()` checks.
- `CUTIN_VIDEO_DEBUG_FORCE_TOP` is available for local visual isolation and is committed as `false`.
- `_debug_play_cutin_video_only()` is available as a manual QA helper and does not run automatically.
- The centered v0.70-6/v0.70-9 cutin banner/card layout and PNG/text fallback are preserved.
- No unique-skill effect logic, formulas, AI, battle result, wounded/prisoner/death, overlay, camera, pop wave, direction-selection, or WorldMap UX logic was intentionally changed.
- Recommended next cutin polish tasks:
  - `v0.70-10 Specialty Skill Cutin Visual Polish`
  - `v0.70-11 Add Kwon Yul and Jeong Do Jeon Cutins`
- Recommended WorldMap follow-up:
  - `v0.70-12 WorldMap Final IA Blueprint + Panel Skeleton`

## Next: v0.70-7 Specialty Skill Cutin Visual Polish
- `v0.70-6 Cutin WebM Video Connection + Center Layout Fix` is complete.
- Ally Yi Sunsin cutin now prioritizes WebM video candidates, keeps PNG/text fallback, and uses a centered cutin banner/card layout with center scale/fade timing instead of side-biased slide placement.
- Kwon Yul and Jeong Do Jeon WebM assets are present but not wired to activation yet.
- No battle rules, formulas, AI, battle result, wounded/prisoner/death, overlay, camera, pop wave, direction-selection, or WorldMap UX logic was intentionally changed.
- Recommended next cutin polish tasks:
  - `v0.70-7 Specialty Skill Cutin Visual Polish`
  - `v0.70-8 Add Kwon Yul and Jeong Do Jeon Cutins`
- Recommended WorldMap follow-up:
  - `v0.70-9 WorldMap Final IA Blueprint + Panel Skeleton`

## Deferred: v0.70-9 WorldMap Final UX/UI Information Architecture
- `v0.69-14A GDScript Reload Warning Cleanup Before v0.70` is complete; v0.70 can continue with reload-warning cleanup already applied.
- `v0.69-14 EASTWAR Strategic Logic Final Checkpoint` closes the v0.69 strategic logic track.
- WorldMap final UX/UI work is deferred until after the first battle visual polish pass.
- WorldMap v0.70 remains primarily an information architecture and UX/UI pass over the v0.69 logic, not a new strategic-logic expansion pass.
- WorldMap v0.70 main goals:
  1. 도시 패널 재구성
  2. 태수 임명 UI
  3. 재상/국가 운영 UI
  4. 테크트리 전용 창 + 아이콘/이미지 연결
  5. 무역/시세/외교/첩보 UI
  6. 병력 이동 from/to/amount UI
  7. 재상 병력 재배분 제안 카드 UI
  8. 반란 경고/위험 표시
  9. v0.69 로직 F6 수동 검증
- High-risk follow-ups after v0.70 UI foundation:
  1. 실제 반란 발생
  2. 도시 neutral 전환
  3. 반란 진압 전투
  4. 암살
  5. 동맹 군사 지원 실제 병력 이동
  6. 공동 침공

## Current v0.69-13 Espionage Action Foundation Status
- `v0.69-13 Espionage Action Foundation MVP` is complete in code/docs.
- Implemented loyalty disruption, revolt instigation, and wedge driving as helper/API-only spy actions.
- Existing `v0.69-11` info gathering and `v0.69-11B` publicSupport disruption remain the foundation and were not rewritten.
- Shared `spy_cooldown` now covers information gathering, publicSupport disruption, loyalty disruption, revolt instigation, and wedge driving.
- Detection applies relation score penalties but never auto-converts status, declares war, breaks alliance, triggers revolt, or changes city owner.
- Assassination, actual revolt occurrence, owner neutral conversion, suppression battle, war declaration, and espionage UI remain unimplemented.
- `GUIDE_v0.69_12_13_to_v0.70.md` was not present in the repo; this pass followed the explicit task text.
- v0.69 strategic/diplomacy/espionage foundation can now move toward final UX/UI architecture.
- Recommended next task:
  - `v0.70-1 WorldMap Final UX/UI Information Architecture`
  - Alternative: `v0.69-13A Espionage/Diplomacy Foundation Audit`

## Current v0.69-12 Diplomacy Action Foundation Status
- `v0.69-12 Diplomacy Action Foundation MVP` is complete in code/docs.
- Implemented helper/API-only alliance proposal, military support request, and trade agreement proposal.
- Alliance proposal pays the provided `resource_package`, uses deterministic acceptance chance, and on success sets `allied` plus `alliance_turns_remaining`.
- Military support is allowed only for `allied` relations and records acceptance/rejection only. No troop movement, joint invasion, or battle handoff exists.
- Military support rejection penalty is `-20`; third and later repeated rejection penalty is `-40`.
- Trade agreement requires relation score `>= 50`, costs `gold 200 + silk 50`, and applies a separate Phase A trade route bonus `+0.15`.
- `GUIDE_v0.69_12_13_to_v0.70.md` was not present in the repo; this pass followed the explicit task text.
- No declaration of war, alliance expiry turn processing, trade transaction execution, diplomacy UI, or auto diplomacy exists yet.
- Recommended next task:
  - `v0.69-13 Diplomacy/Trade/Alliance Duration Audit`
  - Alternative: `v0.70-1 WorldMap Final UX/UI Information Architecture`

## Current v0.69-11B Espionage Public Support Disrupt Status
- `v0.69-11B Espionage Public Support Disrupt MVP` is complete in code/docs.
- Only publicSupport disruption is implemented as an offensive espionage action.
- Cost is fixed at `gold 300`; effect is political aptitude-based.
- Detected disruption cancels the publicSupport effect and applies relation score `-30`.
- Status does not auto-convert to hostile and war is not declared.
- The action uses shared `spy_cooldown`: base `8`, primary political chancellor `6`.
- No loyalty disruption, revolt instigation, alienation, assassination, real revolt, or espionage UI exists yet.
- Recommended next task:
  - `v0.69-11C Espionage Detection Penalty Audit`
  - Alternative: `v0.69-10C Alliance War Status Foundation MVP`

## Current v0.69-11 Espionage Info Gathering Status
- `v0.69-11 Espionage Info Gathering MVP` is complete in code/docs.
- Spy info gathering is chancellor-driven and requires political aptitude.
- Detection is recorded only; no relation/status/war/revolt penalty is applied yet.
- Spy cooldown is stored in `_player_state["spy_cooldown"]`, with base `6` turns and primary political chancellor `4` turns.
- No publicSupport disruption, loyalty disruption, revolt instigation, alienation, assassination, espionage UI, alliance, trade agreement, or war declaration exists yet.
- Recommended next task:
  - `v0.69-11B Espionage Public Support Disrupt MVP`
  - Alternative: `v0.69-10C Alliance War Status Foundation MVP`

## Current v0.69-10B Tribute Diplomacy Action Status
- `v0.69-10B Tribute Diplomacy Action MVP` is complete in code/docs.
- Tribute costs `gold 300` + `silk 100` and increases relation score by deterministic `+20`.
- Tribute uses a separate `tribute_cooldown` field set to `5` turns; existing relation `cooldown` is not reused.
- Status does not auto-convert to allied/hostile from tribute score changes.
- No alliance proposal, trade agreement, declaration of war, espionage, revolt instigation, specialty trade execution, or diplomacy UI exists yet.
- Recommended next task:
  - `v0.69-10C Alliance War Status Foundation MVP`
  - Alternative: `v0.69-11 Espionage Info Gathering MVP`

## Current v0.69-10 Diplomacy Relation Score Status
- `v0.69-10 Diplomacy Relation Score MVP` is complete in code/docs.
- `faction_relations` now carries `score 0..100` alongside existing `status` and `cooldown`.
- `relation_band` is derived from score and remains separate from `status`.
- Allied/hostile conversion is not automatic; future explicit diplomacy actions must change status.
- Phase A trade multiplier remains status-based and unchanged.
- No tribute, trade agreement, alliance proposal, declaration of war, espionage, revolt instigation, specialty trade execution, or diplomacy UI exists yet.
- Recommended next task:
  - `v0.69-10B Tribute Diplomacy Action MVP`
  - Alternative: `v0.69-11 Espionage Info Gathering MVP`

## Current v0.69-9 Trade Market Price Status
- `v0.69-9 Trade Deepening Data Market Price MVP` is complete in code/docs.
- Trade deepening is now started as a separate market-price data layer and does not replace Phase A inter-faction trade income.
- Market prices are deterministic and recorded in `_player_state["last_trade_market_result"]`.
- No manual trade, resource exchange, trade agreement, maritime trade, pirate loss, hero trade trait, random volatility, or trade UI exists yet.
- Recommended next task:
  - `v0.69-9B Specialty Trade Data MVP`
  - Alternative: `v0.69-10 Diplomacy Relation Score MVP`

## Current v0.69-8B Tech Effect Application Status
- `v0.69-8B Tech Effect Application MVP` is complete in code/docs.
- Implemented effects: `legal_reform` one-time publicSupport `+5`, `tax_reform` domestic gold income `+10%`, `street_market` city domestic gold income `+5%`, `barracks` automatic conscription gate, and `conscription_system` automatic conscription add `+10%`.
- Recognized but no consumer yet: `national_foundation`, `improved_farming_tools`, and `fishing_village`.
- Trade income is not affected by `tax_reform` or `street_market`.
- Battle effects, special units, tech UI, and auto tech selection remain unimplemented.
- Next implementation candidate:
  - `v0.69-9 Trade Deepening MVP`

## Current v0.69-8 Tech Start Progress Pipeline Status
- `v0.69-8 Tech Start Progress Pipeline MVP` is complete in code/docs.
- National and city tech now share the MVP lifecycle: start after checks, pay cost, register `in_progress`, decrement `remaining_turns`, and move to `completed`.
- Completed entries record `effect_summary` and `effect_applied: false`; actual tech effects remain unimplemented.
- There is still no tech UI, no auto tech selection, and no governor/chancellor auto progress selection.
- Superseded by `v0.69-8B`: first Tech Effect Application MVP is complete.

## Current v0.69-7A Tech Data Consistency Audit Status
- `v0.69-7A National City Tech Data Consistency Audit` is complete in code/docs.
- National/city tech references, prerequisite IDs, cost keys, aptitude types, and image placeholder fields have been audited.
- The documented national tech `logistics_system` / `병참 제도` was added so `dried_fish_supply_base` has a valid `required_national_tech` reference.
- `_validate_tech_data_consistency()` is available as a QA/debug helper only and does not mutate gameplay state.
- Placeholder conditions remain deliberately blocking and documented.
- Superseded by `v0.69-8`: Tech Start/Progress Pipeline MVP is complete.

## Current v0.69-7 City Tech Tree Data Status
- `v0.69-7 City Tech Tree Data MVP` is complete in code/docs.
- City tech now has data definitions, per-city runtime state containers, lookup helpers, requirement checks, cost checks, and start-eligibility checks.
- This pass does not start city tech, deduct costs, progress turns, complete techs, apply effects, add UI, or run governor auto tech selection.
- `icon_path` and `image_path` are present as empty-string placeholders for later tech UI image connection.
- Placeholder conditions are deliberately blocking: `governor_type_turns`, `food_surplus_turns`, `connected_supply_city_count`, and `has_hero_yi_sunsin`.
- Superseded by `v0.69-7A`: National/City tech data consistency audit is complete.

## Current v0.69-6 National Tech Tree Data Status
- `v0.69-6 National Tech Tree Data MVP` is complete in code/docs.
- National tech now has data definitions, player state containers, lookup helpers, requirement checks, cost checks, and start-eligibility checks.
- This pass does not start research, deduct costs, progress turns, complete techs, apply effects, or add UI.
- Placeholder conditions are deliberately blocking: `chancellor_type_turns`, `allied_faction_count`, `neutral_faction_count`, `has_city_tech_mint`, and `has_silkroad_or_trade_port`.
- Superseded by `v0.69-7`: City Tech Tree Data MVP is complete.

## Current v0.69-5 Revolt Warning Status
- `v0.69-5 Revolt Warning Foundation MVP` is complete in code/docs.
- Revolt warning uses the combined `publicSupport + loyalty` condition.
- `warning`: both publicSupport and loyalty are `<= 40`.
- `danger`: both publicSupport and loyalty are `<= 30`.
- The system records warning/danger counts in `last_revolt_warning_result` and shows minimal City Detail/turn-summary text.
- Actual revolt occurrence, city neutralization, suppression battles, espionage revolt agitation, map markers, and final UI are not implemented.
- Real F6 mouse-based UX verification remains deferred to the June City Detail/WorldMap UI overhaul.
- Superseded by `v0.69-6`: National Tech Tree Data MVP is complete.

## Current v0.69-4 Recruitment/Conscription Status
- `v0.69-4 Recruitment/Conscription Foundation MVP` is complete in code/docs.
- Conscription is loyalty-based and represents slow free troop growth. It runs automatically during the domestic turn and adds up to `100` troops per owned city if the city is below its loyalty-based conscription capacity.
- Recruitment is publicSupport-based and represents immediate paid troop growth. It is implemented as helper/API logic only; no explicit recruitment button or panel exists yet.
- Recruitment cost is `gold = amount` and `food = amount / 2`. MVP food deduction uses the national food pool in order: `rice -> barley -> seafood`.
- Neither conscription nor recruitment reduces population in this MVP.
- Recruitment does not directly reduce publicSupport or loyalty; recruitment fatigue/publicSupport decline remains deferred.
- Current City Detail display remains a minimal temporary surface for conscription/recruitment values.
- Real F6 mouse-based UX verification remains deferred to the June City Detail/WorldMap UI overhaul.
- Superseded by `v0.69-5`: revolt warning foundation is complete.

## Current v0.69-3A Strategic Logic Checkpoint Status
- `v0.69-3A Strategic Logic Checkpoint Documentation` is complete as a documentation-only checkpoint.
- `v0.69-1 Public Support MVP`, `v0.69-2 Seasonal Loyalty From Public Support MVP`, and `v0.69-3 Troop Move Loyalty Efficiency Final Patch` are complete.
- The v0.69 strategic foundation chain is locked at logic level: `publicSupport` -> seasonal `loyalty` -> troop movement loss.
- Current verification remains headless/API-centered. Actual F6 mouse-based UX verification is deferred until the June city information panel and WorldMap UX/UI redesign phase.
- Current City Detail UI is a minimal temporary display/connection layer, not the final player-facing UX.
- June UI work should include feature-by-feature manual checks for publicSupport display, seasonal loyalty display, troop movement preview/status copy, and C2 approval movement result readability.
- Superseded by `v0.69-4`: recruitment/conscription foundation is complete. UX verification should still be coordinated with the later UI overhaul rather than treated as complete now.

## Current v0.69-3 Troop Move Loyalty Efficiency Status
- `v0.69-3 Troop Move Loyalty Efficiency Final Patch` is complete in code/docs.
- C1 manual troop movement now uses source-city loyalty as the final movement efficiency formula.
- Movement is no longer total-preserving: commanded troops all depart, only `floor(commanded_amount * from_loyalty / 100.0)` arrive, and the remainder is recorded as loss.
- C2 chancellor rebalance approval continues through `_move_troops`, so approved C2 movement uses the same loyalty-based loss formula.
- `publicSupport` is not directly used by troop movement. Movement uses the current city loyalty value after any seasonal publicSupport-to-loyalty effects have already been applied.
- Superseded by `v0.69-4`: recruitment/conscription foundation is complete; F6 mouse UX verification is still deferred to the June UI pass.

## Current v0.69-2 Seasonal Loyalty Status
- `v0.69-2 Seasonal Loyalty From Public Support MVP` is complete in code/docs.
- `publicSupport` remains the fast domestic-stability axis and changes every turn through v0.69-1 logic.
- City `loyalty` now receives a slow seasonal adjustment from publicSupport only on `turn_number % 10 == 0`.
- Existing P0-2 city loyalty drift remains active and separate.
- Payroll/gold surplus and equipment surplus seasonal loyalty factors are documented in the confirmed design but intentionally deferred.
- Superseded by `v0.69-3`: troop movement now consumes the current loyalty value as movement efficiency.

## Current v0.69-1 Public Support Status
- `v0.69-1 Public Support MVP` is complete in code/docs.
- City-level `publicSupport` now exists as a separate city runtime field from `loyalty` / `cityLoyalty`, with default `70`, `0..100` clamp, minimal save/load preservation, and `last_public_support_result` turn output.
- Public support drift currently uses MVP tax, food, commerce, and supply isolation inputs and clamps total delta to `-7..+3`.
- Superseded by `v0.69-2`: publicSupport now affects loyalty on seasonal turns while existing P0-2 city loyalty drift remains separate.
- Next required task after v0.69-2: `v0.69-3 Troop Move Loyalty Efficiency Final Patch`.
- Remaining risks: food/commerce surplus checks are MVP approximations from current stock/recent result state; final UI/UX remains deferred.

## v0.69 EASTWAR Strategic Simulation Foundation Roadmap
- v0.68b is closed at `v0.68b-13-6C2 Chancellor Troop Rebalance Suggestions` / commit `aec588b`.
- v0.69 work starts from strategic simulation foundations, not UI-first expansion.
- The official `agent/CONFIRMED_*` design documents now reflect the latest confirmed inputs from `_incoming_confirmed_designs/`. The incoming folder is staging input only and must not be committed by future roadmap/documentation tasks.
- Implement systems in this order:
  1. `v0.69-1 Public Support MVP` - complete.
  2. `v0.69-2 Seasonal Loyalty From Public Support MVP` - complete.
  3. `v0.69-3 Troop Move Loyalty Efficiency Final Patch` - complete.
  4. `v0.69-4 Recruitment/Conscription Foundation MVP` - complete.
  5. `v0.69-5 Revolt Warning Foundation MVP` - complete.
  6. `v0.69-6 National Tech Tree Data MVP` - complete.
  7. `v0.69-7 City Tech Tree Data MVP` - complete.
  8. `v0.69-8 Trade Deepening MVP`
  9. `v0.69-9 Diplomacy/Espionage Foundation MVP`
  10. `v0.70-1 WorldMap Final UX/UI Information Architecture`
- Immediate post-data candidates before committing to the next roadmap branch:
  - `v0.69-8 Tech Start/Progress Pipeline MVP`
  - `v0.69-6B National Tech Start/Progress MVP`
- Confirmed design inputs are locked in:
  - `agent/CONFIRMED_LOYALTY_PUBLICSUPPORT_DESIGN.md`
  - `agent/CONFIRMED_NATIONAL_TECHTREE_DESIGN.md`
  - `agent/CONFIRMED_CITY_TECHTREE_DESIGN.md`
  - `agent/CONFIRMED_TRADE_SYSTEM_DESIGN.md`
  - `agent/CONFIRMED_DIPLOMACY_ESPIONAGE_REVOLT.md`

## Current Troop Rebalance C2 Status
- `v0.68b-13-6C2 Chancellor Troop Rebalance Suggestions` is complete in code/docs as C2 suggestion calculation only.
- No UI, suggestion card surface, automatic redistribution, direct troop writes, resource changes, battle changes, or save/load core rewrites were implemented.
- `_calculate_troop_rebalance_suggestions()` computes candidate moves from existing supply role state: `hub/rear` suppliers with surplus and `frontline` demand cities with shortage.
- Every suggestion is validated by C1 `_can_move_troops`; C2 does not call `_set_city_runtime_troops` and does not directly set `troops`.
- `_apply_troop_rebalance_suggestion()` is the future approval hook and only delegates to `_move_troops(from, to, amount)`.
- QA confirmed suggestion calculation does not change world or city troop totals, start state has 0 suggestions, a crafted multi-city scenario generates a valid suggestion, apply preserves total troops, and save/load preserves the moved troop state via the existing C1 path.
- Remaining risks: no UI approval path yet; `ROLE_TARGET_GARRISON_RATIO` was absent and is now a first-pass table; manual F6 QA remains for future UI flow.
- Next candidates: `City Panel Rebuild / Chancellor Suggestion UI` or `Troop Move UI from/to/amount Control Polish`.

## Current Troop Move C1 Status
- `v0.68b-13-6C1 Troop Move Manual MVP` is complete in code/docs as C1 only.
- Manual troop movement is implemented through existing City Detail internal/supply tab action: selected player city is source, first connected player-owned city is destination, and amount is capped at 100 and available surplus above minimum garrison.
- C2 chancellor suggestions and automatic redistribution are not implemented.
- Movement writes only via `_set_city_runtime_troops`; source loses the amount and destination gains the same amount.
- Peacetime gate reuses existing `_enemy_turn_mvp_pending`, pending invasion event, pending battle context, battle context meta, and player turn phase checks. No new lock flag was added.
- QA confirmed total troop preservation, min-garrison rejection, no-supply-path rejection, pending-invasion rejection, save/load troop preservation, and moved troops reflected in player attack BattleContext input.
- Remaining risks: minimal UI only, no explicit amount/target selector yet, and manual F6 mouse QA remains recommended.
- Next candidate: `v0.68b-13-6C2 Chancellor Troop Rebalance Suggestions`.

## Current City Info Display Spacing Status
- `v0.68b-13-5A City Info Display Spacing Micro Polish` is complete as display formatting only.
- The pass added section titles, line breaks, and consistent empty-state copy to the 13-5 trade/supply/loyalty display helper output.
- Route display is capped with a simple `routes.slice(0, 3)` in existing order and an `외 N개` suffix; no route sorting, prioritization, or source array mutation was added.
- Calculation logic, result structures, real resource/loyalty/upkeep/troop values, P0-1, P0-2, Phase A, Phase B, battle/invasion/defense, save/load, and Phase C were not changed.
- Remaining risk: manual visual F6 QA is still recommended for final spacing/font rendering.
- Next candidate: `v0.68b-13-6 Phase C Internal Troop Rebalance MVP`.

## Current City Info Trade/Supply/Loyalty Display Status
- `v0.68b-13-5 City Info Trade Supply Loyalty Display Polish` is complete in code/docs as display-only polish.
- Internal/supply tab now surfaces existing Phase B supply result fields for the selected city: role, supplied/isolated state, income multiplier, loyalty delta, and security delta.
- Internal/supply tab now surfaces latest city loyalty drift factors from existing result state: tax, security, economy, military, supply, supply_security, control, and `reasons[]`.
- External trade tab now surfaces latest Phase A trade result state: route count, applied totals with player totals fallback, gold/rice/barley/seafood/salt summary, and selected-city route snippets.
- Turn result/status text now includes display-only summaries for trade income, supply state counts, and city loyalty drift counts/large drops.
- No P0-1/P0-2/Phase A/Phase B calculation logic, result structure, resource values, loyalty values, upkeep values, Phase C troop redistribution, battle/invasion/defense logic, or save/load core code was changed.
- Remaining risks: headless QA only; long text may need visual spacing polish; supply tab display uses the existing supply calculation helper and can refresh the runtime summary.
- Next candidates: `v0.68b-13-6 Phase C Internal Troop Rebalance MVP` or additional `Supply/Trade UI Polish`.

## Current Phase B F6 QA Closeout Status
- `v0.68b-13-4A Supply Connectivity F6 QA Closeout` is complete as QA/documentation only; no new feature implementation was done.
- Start state verified: Hanseong is hub, only Hanseong is owned, no frontline bonus, no isolated penalty, and turn end advances normally.
- Connected multi-city scenario verified: player-owned Pyeongyang, Gyeongju, and Sabi classify as supplied frontlines with friendly paths to Hanseong; supplied-frontline count drives income `x1.10`, loyalty `+1`, security `+1`, and bounded hero-upkeep discount.
- Isolated scenario verified with player-owned Kyoto disconnected from Hanseong: isolated frontline income `x0.80`, loyalty `-2`, security `-1`; no isolated upkeep surcharge is applied in the MVP.
- Save/load verified: loaded ownership/city runtime data can be used to recalculate supply from topology; `last_supply_state_result` is only a runtime summary and may be stale immediately after load until recalculation overwrites it.
- Light regressions verified: Phase A trade income, city loyalty/runtime save-load, `faction_relations` save payload, player attack context build, and enemy invasion/defense event creation.
- Remaining risks: headless/API-driven QA only, no visual supply-state UI, stale loaded `last_supply_state_result` before recalculation, and no Phase C troop redistribution.
- Next candidates: `v0.68b-13-5 Phase C Internal Troop Rebalance MVP` or `City Info Supply State Display Polish`.

## Current Phase B Supply Connectivity Status
- `v0.68b-13-4 Phase B Supply Connectivity Bonus MVP` is complete in code/docs.
- Phase B is implemented as a connectivity bonus/penalty system layered into existing domestic income, P0-2 city loyalty drift, and hero upkeep. It does not move resources and does not split the national warehouse.
- Supply state is recalculated once per domestic turn through `_calculate_all_city_supply_states()` and stored for inspection in `last_supply_state_result`.
- `last_supply_state_result` structure: `hub_id`, `supplied_frontline_count`, `isolated_count`, and `city_states` keyed by city id with role/supplied/isolated/income/loyalty/security fields.
- Starting state expectation: Hanseong is the supply hub; with only Hanseong owned, there should be no frontline supply bonus or isolation penalty.
- Not implemented: Phase C troop redistribution, city-level warehouses, city-to-city resource movement, isolated-frontline upkeep surcharge, supply UI, and battle/invasion/defense supply effects.
- `worldmap_test_FULL.gd` is treated as an untracked source integration file and must not be committed unless explicitly requested.
- Remaining manual QA: F6 multi-city ownership frontline/rear classification, connected frontline income `x1.10`, loyalty/security bonus, supplied-frontline upkeep discount, crafted isolation case income `x0.80` and loyalty/security penalties, and save/load confirming supply state recalculates from ownership rather than persisted values.
- Next recommended task: F6/manual QA and balance review for Phase B supply, then only proceed to Phase C troop redistribution if explicitly scoped.

## Current Final Domestic/Trade/Loyalty Merge QA Status
- `v0.68b-13-3 Final Merged WorldMap Domestic Trade Loyalty QA` is complete in code/docs.
- `worldmap_test_FULL.gd` was applied to `scripts/worldmap_test.gd`.
- Integrated state includes P0-1 governor income, P0-2 city loyalty drift, Phase A trade income, and trade tuning C.
- Trade tuning C confirmed: `TRADE_GLOBAL_DAMPENER := 0.5`, `TRADE_FOOD_FACTOR := 1.5`.
- Static Hanseong trade check: Pyeongyang, Gyeongju, and Sabi are the 3 adjacent trade routes; tuned gold income is approximately +40 total.
- F6 manual QA remains: turn-end trade display, city loyalty divergence at high tax, city loyalty save/load, `faction_relations` save/load, governor income sanity, and light battle/invasion/defense entry regression.
- Phase B supply connectivity is not implemented. Next recommended task: `v0.68b-13-4 Phase B Supply Connectivity Bonus MVP`.

## Current City Loyalty Drift Status
- `v0.68b-13-2 City Loyalty Drift Patch Acceptance QA` is complete in code/docs.
- P0-2 city loyalty drift now applies per owned city through `_get_mutable_city_runtime_state` and `_city_runtime_states`.
- P0-1 `city_loyalty_loss_multiplier` is now consumed for city tax loyalty drift. `recruitable_troops_bonus` remains intentionally unconnected.
- City runtime save/load now minimally preserves `loyalty` / `cityLoyalty`; save/load core structure was not rewritten.
- Phase A trade was not implemented by this task. In this branch Phase A already exists, so future merges must keep `_apply_domestic_turn_mvp` ordering clear: P0-1 governor income, Phase A trade income if present, hero upkeep, national loyalty, P0-2 city loyalty drift.
- Remaining manual QA: F6 high-tax multi-turn city loyalty drift, national-vs-city loyalty separation, save/load persistence, low-security city decline, and political/admin governor mitigation.

## Current Inter-Faction Trade Income Status
- `v0.68b-13-2A Inter-Faction Trade Income MVP` is complete in code/docs.
- Phase A only was implemented: player-owned cities scan adjacent other-faction city markers, calculate route income, apply player totals through `_apply_resource_delta(...)`, and store `last_inter_faction_trade_result`.
- `last_inter_faction_trade_result` structure is `turn`, `route_count`, `player_totals`, `routes`, and `applied_player_totals`.
- Relation state is lazy and flat under `_player_state["faction_relations"]`; keys are sorted `a|b`, and missing keys fall back to `neutral`.
- Not implemented: Phase B internal supply network, Phase C troop redistribution, diplomacy manipulation UI, trade setting UI, and P0-2 loyalty/recruitment consumers.
- Remaining manual QA: F6 turn-end resource increase, same-faction route exclusion, hostile/suspended route exclusion, warehouse cap clamp via `_apply_resource_delta`, and save/load preservation of `faction_relations`.

## Current Governor Income Effect QA Status
- `v0.68b-13-1 Governor Income Effect Patch Acceptance QA` is complete in code/docs.
- Required P0-1 gates now exist in `scripts/worldmap_test.gd`: `GOVERNOR_PRIMARY_RATE`, `GOVERNOR_SECONDARY_RATE`, `_calculate_city_domestic_effects`, `_apply_governor_type_effect`, `_apply_governor_policy_effect`, the `city_effects: Dictionary = {}` city-income parameter, and the player-income city-effects pass-through.
- Verification completed with `rg`, Godot headless project load, and Godot headless `WorldMap_Test.tscn` load. `--check-only` timed out locally and should be retried if a stable check-only command is available.
- Remaining QA: F6 assign a Hanseong governor, compare turn-end income before/after, save/load, then repeat. Be aware current Hanseong candidates can round to no visible income delta at default values; inspect effect presence/logs if the UI resource numbers do not move.
- Expected non-consumers: `city_loyalty_loss_multiplier` and `recruitable_troops_bonus` are present in effects but not consumed by current Godot loyalty/recruitment systems yet.

## Current Troop Accounting Parity Status
- `v0.68b-12b-31 Player/Defense Troop Accounting Parity Fix` is complete in code.
- Player attack now pre-decrements defender city garrison using defender allocation before battle handoff.
- Enemy invasion defense now pre-decrements both enemy attacker source city and player defender source city, then applies allocated troop outcomes on result return.
- Defense victory/defeat now use troop woundedQueue: defense win returns player survivors/wounded to defender city and enemy wounded to attacker city; defense loss sends enemy survivors/wounded to the captured city and player wounded to nearest player-owned neighbor if found.
- Remaining QA: F6 player attack win/loss, defense win/loss, save/load woundedQueue, and WorldMap turn recovery.
- Next recommended patch: commandRank/commandLimit allocation clamp or a dedicated F6 QA/hotfix pass if manual testing finds troop accounting drift.

## Current Web-Parity Gap Audit Status
- `v0.68b-12b-30 Invasion Attack Web Parity Gap Audit` is complete as a docs-only audit.
- New audit document: `agent/INVASION_ATTACK_WEB_PARITY_GAP_AUDIT.md`.
- Next P0 patch should address player attack defender garrison pre-decrement and enemy invasion defense troop allocation/result parity.
- Defense parity must include source-city pre-decrement for both player defender and enemy attacker, allocated troop result payloads, woundedQueue application, and retreat-city wounded return when defense is lost.
- P1 follow-up: commandRank/commandLimit allocation clamp and F6 save/load/turn recovery QA.

## Current Web-Parity Troop Allocation Status
- `v0.68b-12b-29A Web-Parity Troop Allocation Wounded Queue Import` is complete in code.
- Player attack confirmation now subtracts total allocated sortie troops from the source city immediately, while preserving `attacker_total_allocated_troops`, source before/after troops, and per-hero allocation metadata in BattleContext.
- Battle units preserve `allocated_troops` / `initial_allocated_troops`; troop counts are used for post-battle survivor/wounded/dead calculations only and do not scale HP, attack, or defense.
- Player attack outcome follows web parity: victory uses HP-ratio survivors, wounded = floor(losses * 0.30), dead = remainder; defeat forces survivors to 0, wounded = floor(allocated * 0.50), dead = remainder.
- Troop woundedQueue is city-level soldier recovery data, separate from hero wound state. Queue entries recover into city garrison after 3 WorldMap strategy turns.
- Remaining manual QA: F6 deploy 1200 from a 5000-garrison city, confirm immediate 3800 source troops, win/lose a player attack, save/load owner/garrison/woundedQueue, and advance turns until wounded troops recover.
- Still deferred: troop-count combat scaling, in-battle supply effects, defender pre-battle garrison decrement parity, troop type composition, siege-specific formulas, loot, and prisoner soldier handling.

## Current Player Attack MVP Status
- `v0.68b-12b-26 Player City Attack MVP Import` is complete in code.
- Enemy cities directly adjacent to a player-owned city can enable the selected-city `공격` button.
- Player attack uses `source: player_attack`, `type: attack`, player source city as attacker, and target enemy city as defender.
- The battle scene maps player attack attacker roster to ally slots and defender roster to enemy slots while preserving enemy-invasion defense mapping.
- Player victory changes target city owner to `player`; player defeat keeps target owner unchanged. Existing casualty/result-card/save-load paths are reused.
- Remaining manual QA: F6 select adjacent/non-adjacent enemy cities, confirm button state, enter battle, verify context side mapping, win/loss result application, save/load persistence, and enemy-invasion regression.
- Still deferred: deployment hero selection, troop allocation, sea/route-type attack, 2-hop attack, marching/supply, siege-specific UI, AI counterattack, and enemy hero recruit/conversion.

## Current Wounded Recovery Status
- `v0.68b-12b-26 Wounded Hero Recovery Turn MVP` is complete in code.
- Wounded heroes receive `wounded_turns_remaining = 3` when the placeholder wound is applied.
- Recovery ticks once per WorldMap strategy turn through `_advance_world_turn_mvp()`; battle turns do not reduce the counter.
- UI marker format is `[부상 N턴]`, and recovery to `0` resets `status` to `normal`, clears `wounded`, removes the badge, and disables v25 penalties.
- Existing save/load persists the recovery counter through `worldmap_hero_state`; old wounded saves without the counter are normalized to 3 turns.
- Remaining manual QA: F6 wound result, save/load, turn advance 3 -> 2 -> 1 -> normal, then confirm battle penalty is gone.
- Still deferred: treatment UI, recovery items, ability-based recovery duration, prisoner release/recruit/execute, and death handling.

## Current Wounded Hero Battle Penalty Status
- `v0.68b-12b-25 Wounded Hero Battle Penalty MVP` is complete in code.
- Wounded heroes still enter battles and keep `[부상]` badges; captured/dead heroes remain excluded.
- MVP penalty values: attack damage `75%`, defense represented as incoming damage `120%`, and unique-skill numeric effects `70%`.
- The battle scene reads wounded state through the existing WorldMap context hero registry / hero registry lookup and does not add save fields.
- Remaining manual QA: F6 wounded hero save/load, enter a new battle, confirm `[부상]` remains and `[WOUNDED_PENALTY]` logs appear for attack/defense/skill cases.
- Still deferred: wound recovery turns, treatment UI, prisoner systems, death handling, and refined stat-based wound balance.

## Current Captured Hero Battle Exclusion Status
- `v0.68b-12b-24 Captured Hero Battle Exclusion MVP` is complete in code.
- Captured heroes remain visible in city rosters with `[포로]`, but they are excluded from WorldMap invasion attacker/defender/support battle rosters.
- Exclusion applies to `captured == true`, `status == "captured"`, and safety `dead == true`; wounded heroes still enter battles.
- Battle scene context assignment also blocks captured/dead context heroes and deactivates the affected slot.
- Remaining manual QA: F6 capture a hero, save/load, confirm the city panel still shows `[포로]`, then start another battle and confirm that hero is absent from formation/battlefield.
- Still deferred: prisoner movement/holding UI, recruit/execute/release, wound recovery, wounded penalties, and real death handling.

## Current Hero State Visual Badge Status
- `v0.68b-12b-23 Hero State Visual Marker Roster Badge MVP` is complete in code.
- Hero status display priority is `dead` -> `captured` -> `wounded` -> normal; normal heroes show no badge.
- WorldMap city hero lists and battle formation panels now append `[부상]`, `[포로]`, or `[사망]` when the runtime/context hero state says so.
- Post-battle result card state summaries use the same badge style for consistency.
- Captured heroes are still allowed to remain in city rosters and battle rosters for this placeholder phase.
- Remaining manual QA: F6 invasion, save, load, then confirm right city panel and battle formation panel preserve the badges without breaking layout.

## Current Hero State Placeholder Status
- `v0.68b-12b-22 Hero Wound Capture Placeholder MVP` is complete in code.
- Losing-side hero status placeholder rule is deterministic: first eligible losing hero becomes wounded, second eligible losing hero becomes captured, dead is never applied.
- Captured heroes remain in city rosters for this MVP; no prison/movement/recruit/execution/recovery system exists yet.
- Hero status changes are runtime overrides and persist through existing `worldmap_hero_state` save/load.
- Post-battle result card now shows a one-line hero status summary.
- Remaining manual QA: F6 invasion result, save, load, and confirm wounded/captured status remains while rosters stay intact.

## Current Result Panel Status
- `v0.68b-12b-21 Post Battle Result Panel Polish MVP` is complete in code.
- WorldMap invasion battle return now creates a display-only result summary for defender win, attacker win, retreat, and unknown result paths.
- The left World HUD shows a compact post-battle result card with ownership change/retention, city troop change, attacker source-city troop change, and occupation troops when available.
- Result summary is not persisted; save/load continues to persist actual owner/troop/hero runtime state only.
- Remaining manual QA: F6 defense win/loss return should confirm the result card reads clearly and does not block city panel/worldmap operation.
- Still deferred: prisoner/wound/death display, resource loot display, detailed battle statistics, and a full result report UI.

## Current Casualty / Hero State Status
- `v0.68b-12b-20 Invasion Casualty Formula Hero State MVP` is complete in code.
- Invasion results now calculate MVP attacker/defender losses and apply clamped city troop changes for defense victory and defense defeat.
- Attacker victory now assigns occupation troops from attacker survivors/fallback values and leaves the attacker source city with the remaining clamped troop count.
- `worldmap_hero_state` now persists `status`, `wounded`, `captured`, and `dead` with default `normal` / `false` values for old save data.
- Remaining manual QA: F6 defense win/loss save/load should confirm owner/troops persist, hero state defaults save/load, and no pending invasion duplicate appears.
- Still deferred: actual wound/capture/death rolls, hero removal/holding movement, resource looting, detailed battle-power casualty balance, AI strategy recalculation, and multi-invasion queues.

## Current Persistence Status
- `v0.68b-12b-19 WorldMap Battle Result Save/Load Persistence MVP` is complete in code.
- Battle-result city owner/troop runtime overrides now persist through save/load via `worldmap_city_state`.
- City stationed hero ids and hero current city ids now persist through `worldmap_city_state` / `worldmap_hero_state`, merged over seed data on load.
- Pending invasion event/context is cleared in saved/restored state, preventing resolved invasions from reappearing after reload.
- Remaining manual QA: F6 invasion result, save, load, city marker/right panel owner and troops, hero roster source for a new battle, and no duplicate pending invasion UI.

## Previous Hotfix Status
- `v0.68b-12b-18c Reinforcement Toast Auto Battle Final Stop Hotfix` is complete in code.
- Support arrival toast now skips when the actual arriving unit list is empty; inactive/hidden WorldMap context support slots are excluded from arrival checks.
- Battle result finalized guards now block deferred turn, enemy action, auto action, round-start toast, reinforcement toast, and support deployment paths.
- Remaining manual QA: F6 invasion with no support should not show the turn-3 support toast, sample battle should still show support toast when sample reinforcements arrive, and auto battle should stop immediately after victory/defeat.

## Previous Hotfix Status
- `v0.68b-12b-18b Roster Panel Source Auto Battle End Hotfix` is complete in code.
- WorldMap enemy-invasion formation panels now hide empty/inactive context slots and no longer display sample roster heroes from stale capacity-slot unit state fallback.
- Auto battle result guards stop the full-auto loop at victory/defeat and block deferred auto tick / ally-turn scheduling after battle end.
- Remaining manual QA: F6 백제/사비 invasion should verify no 김유신/을지문덕/유비/제갈량 panel leak when those heroes are not in context, auto battle stops immediately at result, and worldmap return remains stable.

## Previous Hotfix Status
- `v0.68b-12b-18a Reinforcement Fallback Leak + Toast Facing Layer Hotfix` is complete in code.
- Enemy-invasion WorldMap context slots no longer use `TEST_BATTLE_ROSTER` when requested heroes are missing; missing support remains an inactive empty slot.
- Direct `Battle_Fullscreen_Test.tscn` sample battle fallback remains intact when no WorldMap invasion context is present.
- Remaining manual QA: 사비/백제 invasion must not show `liu_bei` / `zhuge_liang` as support, and turn/reinforcement/unique-skill toasts must hide facing arrows until the toast ends.

## Current Stable Baseline
Behavior baseline: `v0.67z-3 Strategy Status Badge Near Facing Arrow Patch`

Docs/contract baseline: `v0.68 Agent Contract Split for WorldMap + Hero Scale Prep`

Latest UI patch: `v0.68a-fix6 Vertical Facing Status Badge Side Edge Snap Fix`

Latest camera/background patch: `v0.68a-3 Battlefield Large Background Apply + Camera Clamp`

Latest skill presentation patch: `v0.68a-4-hotfix6 Unique Skill Cutin Punch Motion`

Latest worldmap foundation patch: `v0.68b-1 WorldMap Four-Tile Canvas Foundation`

Latest worldmap marker patch: `v0.68b-3 WorldMap City Castle Icon Apply`

Latest worldmap route patch: `v0.68b-4 WorldMap Route Layer Path2D MVP`

Latest worldmap route hotfix: `v0.68b-4-hotfix1 WorldMap Land Route Visibility Tuning`

Latest worldmap route FX patch: `v0.68b-5 WorldMap Sea Route Arrow Flow FX MVP`

Latest worldmap selected city UI patch: `v0.68b-6 WorldMap Selected City Panel Web Parity MVP`

Latest worldmap functional marker patch: `v0.68b-6a WorldMap Castle Icon Visual Disable Functional Marker Patch`

Latest worldmap HUD structure patch: `v0.68b-8 WorldMap Web HUD Panel Structure Import MVP`

Latest worldmap HUD visual patch: `v0.68b-8 WorldMap Web HUD Visual Parity MVP`

Latest worldmap HUD data patch: `v0.68b-9 WorldMap HUD Data Binding MVP`

Latest worldmap domestic web parity patch: `v0.68b-10 WorldMap Domestic Affairs Web Source Parity MVP`

Latest worldmap draggable HUD patch: `v0.68b-11 WorldMap Independent Draggable Panels + Top Banner Cleanup MVP`

Latest worldmap unified panel patch: `v0.68b-12 WorldMap Unified City Detail Diplomacy Panel MVP`

Latest worldmap unified panel UX patch: `v0.68b-12a Unified City Panel UX Fix + Web Content Parity Patch`

Latest worldmap left HUD content patch: `v0.68b-12b Left World HUD Web Content Parity`

Latest worldmap seed data audit patch: `v0.68b-12b-0 WorldMap Hero City Seed Data Structure Audit`

Latest session handoff docs patch: `v0.68b-12b-0.5 Session Handoff Docs Update Before New Chat`

Latest worldmap seed import patch: `v0.68b-12b-1 WorldMap Hero City Seed Data Import`

Latest worldmap left panel binding QA patch: `v0.68b-12b-2 WorldMap Left Panel Seed Binding QA`

Latest worldmap left panel controls patch: `v0.68b-12b-2 WorldMap Left Panel Web Parity Controls MVP`

Latest worldmap left panel policy/warehouse patch: `v0.68b-12b-3 WorldMap Chancellor Policy + National Warehouse Web Parity MVP`

Latest worldmap warehouse UI cleanup patch: `v0.68b-12b-3a WorldMap National Warehouse Card UI Cleanup`

Latest worldmap turn/save patch: `v0.68b-12b-4 WorldMap Turn End + Save Management Web Parity MVP`

Latest worldmap turn cycle patch: `v0.68b-12b-5 WorldMap Enemy Turn Return / Turn Cycle MVP`

Latest worldmap domestic apply patch: `v0.68b-12b-6 WorldMap Turn Domestic Apply Web Parity MVP`

Latest worldmap domestic apply QA patch: `v0.68b-12b-7 WorldMap Domestic Apply Visual QA + Balance Check`

Latest worldmap enemy invasion audit patch: `v0.68b-12b-8 WorldMap Enemy Invasion Web Logic Audit`

Latest worldmap enemy invasion event patch: `v0.68b-12b-9 WorldMap Enemy Invasion Event MVP`

Latest worldmap enemy invasion choice UI patch: `v0.68b-12b-10 WorldMap Enemy Invasion Choice UI MVP`

Latest worldmap right city panel cleanup patch: `v0.68b-12b-10a WorldMap Right City Info Panel Web Parity Cleanup`

Latest worldmap hero portrait binding patch: `v0.68b-12b-10b WorldMap Hero Portrait Asset Binding MVP`

Latest worldmap BattleContext bridge patch: `v0.68b-12b-11 WorldMap Enemy Invasion BattleContext Bridge`

Latest worldmap battle scene handoff patch: `v0.68b-12b-12 WorldMap Enemy Invasion Battle Scene Handoff MVP`

Latest battle roster context patch: `v0.68b-12b-13 Battle Roster Context Apply MVP`

Latest worldmap battle result return patch: `v0.68b-12b-14 WorldMap Battle Result Return MVP`

Latest worldmap invasion result apply patch: `v0.68b-12b-15 WorldMap Invasion Result Ownership Troop Apply MVP`

Latest worldmap invasion result hotfix: `v0.68b-12b-15-hotfix1 ReadOnly City Dictionary Troop Apply Fix`

Latest worldmap hero battle contract patch: `v0.68b-12b-16 WorldMap Hero Battle Data Unique Skill Contract MVP`

Latest worldmap hero placement data patch: `v0.68b-12b-16b Hero Placement Data Patch`

Latest hero portrait import metadata audit: `v0.68b-12b-16c Hero Portrait Import Metadata Audit`

Latest actual hero portrait binding patch: `v0.68b-12b-17 Actual Hero Portrait Binding + Skill Toast UI MVP`

Latest battlefield portrait/skill hotfix: `v0.68b-12b-17a Battlefield Portrait Scale + Skill Name Hotfix`

Latest invasion reinforcement source patch: `v0.68b-12b-18 Invasion Reinforcement Source Rule MVP`

Latest worldmap unified panel hotfix: `v0.68b-12b-14-hotfix1 Unified Panel Chrome Nil Visible Guard`

Latest warning cleanup hotfix: `v0.68b-12b-14-hotfix3 Owner Shadow Warning Cleanup`

Current stable baseline: `v0.68b-12b-18 Invasion Reinforcement Source Rule MVP`

Baseline commit: local HEAD after `v0.68b-12b-18`

Latest worldmap marker hotfix: `v0.68b-2-hotfix1 WorldMap City Marker Coordinate Space Fix`

Latest worldmap tile hotfix: `v0.68b-2-hotfix2 WorldMap Tile Editor Seam Fix`

Latest worldmap manual layout patch: `v0.68b-2-hotfix3 WorldMap Manual Tile Layout Control`

Latest worldmap marker attachment hotfix: `v0.68b-2-hotfix6 WorldMap City Marker Node2D NameLabel Fix`

## Priority 1
`v0.68b-12b-18a Invasion Reinforcement F6 QA Follow-up`

Goal:
- F6-check WorldMap invasion manual defense and confirm reinforcement source rules keep distant city heroes out of unrelated battles

Scope:
- no Save/Load expansion, hero movement/capture, resource looting, or city ownership result logic changes

Forbidden in this task:
- no full strategic AI rewrite, no battle formula change, and no portrait/skill UI rollback

## Priority 2
`v0.68b-12b-4 WorldMap City Detail Governor / Stationed Hero Web Parity MVP`

Goal:
- bring the city detail panel governor and stationed hero display closer to web parity using imported seed data without adding broader gameplay execution

## Priority 3
`v0.68b-12c Selected City Panel Web Content Parity`

Goal:
- align the Godot Selected City / `CityInfoPanel` content more closely with the actual web selected-city render output while keeping all actions display-only

## Priority 4
`v0.68b-12d City Detail Panel Web Content Parity`

Goal:
- align the unified city-detail mode content more closely with the actual web resource/internal-trade/external-trade render output

## Priority 5
`v0.68b-12e Diplomacy Spy Panel Web Content Parity`

Goal:
- align the unified diplomacy/spy mode with the actual web diplomacy/spy render output without adding real diplomacy or spy execution

## Priority 6
`v0.68b-13 Hero Portrait Asset Naming Contract`

Goal:
- define portrait asset naming/lookup rules for web-to-Godot hero HUD reuse without changing runtime hero logic

## Priority 7
`v0.68b-14 Hero Portrait Asset Apply MVP`

Goal:
- apply available hero portrait assets to the worldmap HUD portrait slots without changing hero logic

## Priority 8
`v0.68c BattleContext Runtime Injection MVP`

Goal:
- inject prepared `BattleContext` data into battle startup while preserving the current stable `5v5` fallback path

## Priority 9
`v0.68d Hero/Army Deployment MVP`

Goal:
- add hero/army deployment MVP on top of the worldmap contract without breaking current battle fallback

## Priority 10
`v0.69 Battlefield Variant Loader`

Goal:
- load battlefield map variants from `BattleContext.map_variant_id` without changing battle formulas or roster ownership

## Priority 11
`v0.69b Naval Battle Entry MVP`

Goal:
- create the first naval battle entry path from sea route / coastal encounter data through `BattleContext`

## Completed / Archived Context
- `v0.68b-12b-17a Battlefield Portrait Scale + Skill Name Hotfix` is complete.
- Battlefield portrait badge display now uses the previous engine baseline size: old `128x128` battlefield portraits at scene scale `0.32`, so 512-source portraits are scaled to roughly `41px` in the battlefield badge.
- `portrait_path` remains the single 512 source; no new 128 files or split portrait fields were added.
- Unique-skill display now prefers real `skill_name`; `장수명 전법` is fallback only. Existing sample unique-skill names/cutin paths are reused when WorldMap context only supplied fallback skill data.
- Existing unique-skill toast frame/animation path is preserved, with common `skill_unknown`/fallback icon only when no dedicated skill/cutin image exists. Full cutin presentation remains deferred.
- `v0.68b-12b-17 Actual Hero Portrait Binding + Skill Toast UI MVP` is complete.
- BattleContext `portrait_path` data is now bound into battle UI portraits before sample HERO_REGISTRY fallback data, and Sprite2D portrait slots scale the single 512-source image to the existing 128 target size.
- Missing portraits use a named common unknown portrait fallback, not a specific sample hero portrait; missing skill toast/cutin images use a common skill fallback icon.
- Unique-skill toast names now prefer WorldMap context `skill_name` data. Cutin presentation, save/load, capture/wounds/death, hero movement, and resource looting remain deferred.
- `v0.68b-12b-16c Hero Portrait Import Metadata Audit` is complete.
- Existing repo policy is to track many Godot `.png.import` files, including `assets/heroes/portraits/**`, while `.gitignore` ignores the generated `.import/` cache directory.
- No untracked or ignored `assets/heroes/portraits` `.import` files remained after audit, so this task did not delete files or add new portrait import metadata.
- Next task is `v0.68b-12b-17 Actual Hero Portrait Binding + Skill Toast UI MVP`.
- `v0.68b-12b-16b Hero Placement Data Patch` is complete.
- 유비, 권율, 척준경, 여포, and 하후돈 now have battle-ready WorldMap hero data with confirmed unique skill names.
- City placement is updated: 성도 includes 유비, 한성 includes 권율 and excludes 척준경, 평양 includes 척준경, 낙양 includes 여포, and 업성 includes 하후돈.
- Portrait/cutin contract remains one 512-source `portrait_path` plus separate `cutin_path`; no split portrait fields were added.
- Save/load placement persistence, capture/wounds, hero movement systems, precise skill balance, and cutin presentation remain deferred.
- `v0.68b-12b-16 WorldMap Hero Battle Data Unique Skill Contract MVP` is complete.
- Existing sample battle data confirmed in `scripts/battle_web_import_test.gd`: `HERO_REGISTRY`, `TEST_BATTLE_ROSTER`, and `UNIQUE_SKILL_REGISTRY`.
- Actual WorldMap heroes are sourced from `scripts/worldmap_test.gd` `HERO_DATA` and city `stationed_hero_ids` / `hero_ids`.
- BattleContext now includes `attacker_heroes` and `defender_heroes` enriched with combat fields, one `portrait_path`, separate `cutin_path`, and required unique-skill fields.
- Portrait contract is one 512-source `portrait_path`; 128 battle slots should downscale from it. No `portrait_128_path` / `portrait_512_path` split was added.
- Existing 128 folders were not deleted; actual image resolver/binding is deferred to `v0.68b-12b-17` or `16a`.
- Battle runtime registers context hero/skill data into runtime registries and preserves sample roster fallback when data is missing or unsupported.
- Save/load expansion remains unimplemented.
- `v0.68b-12b-15-hotfix1 ReadOnly City Dictionary Troop Apply Fix` is complete.
- Cause: `_set_city_runtime_troops()` / owner apply wrote into `CITY_HUD_DATA` seed city dictionaries, which can be read-only in Godot.
- Fix summary: added mutable `_city_runtime_states`; runtime owner/troop changes duplicate seed/current city state with `duplicate(true)`, mutate only the copy, and rebind the right panel from merged seed + runtime data.
- Warning cleanup: unused `_apply_attacker_win_invasion_result()` attacker city name parameter is now `_attacker_city_name`.
- Verification passed: `git diff --check`, Godot project headless load, root `WorldMap_Test.tscn` headless load, and root `Battle_Fullscreen_Test.tscn` headless load.
- Remaining risk: exact live F6 manual invasion return path still needs click-through confirmation.
- `v0.68b-12b-15 WorldMap Invasion Result Ownership Troop Apply MVP` is complete.
- Implemented in `scripts/worldmap_test.gd` and `scripts/battle_web_import_test.gd`.
- Payload handling now accepts result/winner/is_player_win variants, owner ids, starting troops, and surviving deployed troops.
- Defense victory preserves city ownership, clears pending invasion/context, refreshes UI, and applies minimal nonnegative troop reductions where data exists.
- Defense defeat changes the target city to the attacker owner through existing `owner` / `nation` fields plus marker `owner_faction_id`, updates `_player_state.owned_city_ids`, applies safe occupation troops, and refreshes the right panel/worldmap UI.
- Retreat/cancel/aborted/unknown results do not change ownership and fail safely with Korean status text.
- Deferred: hero capture, hero movement, resource losses, detailed casualty calculation, save/load persistence expansion for resolved city ownership, AI strategy recalculation, and multi-invasion queues.
- Verification passed: patch strings, `git diff --check`, Godot project headless load, root `WorldMap_Test.tscn` headless load, and root `Battle_Fullscreen_Test.tscn` headless load.
- Remaining risk: interactive F6 still needs a full manual invasion battle-return click-through.
- `v0.68b-12b-14-hotfix3 Owner Shadow Warning Cleanup` is complete.
- Cause: `scripts/battle_web_import_test.gd` used local variable `owner` in `_apply_worldmap_context_side_roster()`, shadowing the base `Node.owner` property.
- Fix summary: renamed the local to `city_owner_id` and updated only the local metadata references.
- Behavior remains unchanged: `"source_owner"` metadata and summary `"owner"` output still receive the same WorldMap context value.
- Verification passed: repo-local GDScript `var owner` search, `git diff --check`, Godot project headless load, root `WorldMap_Test.tscn` headless load, and root `Battle_Fullscreen_Test.tscn` headless load.
- Remaining risk: interactive F6 should still confirm the live console has no owner shadow warning after normal UI interaction.
- `v0.68b-12b-14-hotfix2 Integer Division Warning Cleanup` is complete.
- Cause: WorldMap calendar helpers used ambiguous integer `/` expressions for year and season-index math, triggering Godot reload warnings.
- Fix summary: `scripts/worldmap_test.gd` now uses explicit `floori(float(... ) / float(...))` for the intended integer calendar divisions.
- Calendar behavior remains unchanged: start year `154`, seasons `봄 / 여름 / 가을 / 겨울`, `10` turns per season, and `40` turns per year.
- Verification passed: patch strings, calendar constants, obvious touched-file integer division scan, `git diff --check`, Godot project headless load, root `WorldMap_Test.tscn` headless load, and root `Battle_Fullscreen_Test.tscn` headless load.
- Remaining risk: interactive F6 should still confirm the live console has no yellow integer division warnings after normal UI interaction.
- `v0.68b-12b-14-hotfix1 Unified Panel Chrome Nil Visible Guard` is complete.
- Cause: `_refresh_unified_panel_chrome()` assumed unified panel chrome nodes and runtime-created primary tab buttons were always non-null before `.visible` writes.
- Fix summary: `scripts/worldmap_test.gd` now guards unified panel chrome `.visible` / `.modulate` writes and warns once if a chrome node is missing.
- `WorldMap_Test.tscn` was inspected but not modified for this hotfix.
- Verification passed: patch strings, guarded visible assignments, forbidden-scope search, `git diff --check`, Godot project headless load, and root `WorldMap_Test.tscn` headless load.
- Remaining risk: interactive F6 should be rechecked visually because headless load cannot reproduce every click/drag path.
- `v0.68b-12b-14 WorldMap Battle Result Return MVP` is complete.
- Modified `scripts/worldmap_test.gd`, `scripts/battle_web_import_test.gd`, and agent docs.
- Battle result payload uses runtime-only Godot `Engine` metadata key `samwar_worldmap_battle_result` with source/type/mode/result/winner, attacker/defender city ids and names, and turn number.
- WorldMap-launched battles now show a `월드맵으로 돌아가기` button after victory/defeat; pressing it stores the payload and transitions to root `WorldMap_Test.tscn`.
- WorldMap consumes and clears the payload on startup, shows a defense result status, clears pending invasion/context, hides the pending choice card, and refreshes panels.
- Direct battle scene launch remains preserved because the return button stays hidden without WorldMap context.
- No ownership, troop/resource, wounded, hero movement/capture, auto resolution, combat balance, or save architecture changes were added.
- Verification passed: patch strings, result metadata paths, forbidden implementation search, `git diff --check`, Godot project headless load, root `WorldMap_Test.tscn` headless load, and root `Battle_Fullscreen_Test.tscn` headless load.
- Historical note: this recommendation is superseded by completed `v0.68b-12b-15`; current follow-up is `v0.68b-12b-16 WorldMap Invasion Result Persistence / QA Follow-up`.
- `v0.68b-12b-13 Battle Roster Context Apply MVP` is complete.
- WorldMap-launched battles now adapt the existing `Battle_Fullscreen_Test.tscn` demo capacity slots with defender/attacker governor and stationed hero ids where those ids resolve to the battle hero registry.
- Missing, empty, or unknown context hero ids fall back to the existing per-slot `TEST_BATTLE_ROSTER`, so direct battle testing and incomplete WorldMap rosters remain stable.
- Combat HP/troop scaling from city garrison values is deferred; this patch only applies context roster identity/metadata and concise battle log feedback.
- Modified `scripts/worldmap_test.gd`, `scripts/battle_web_import_test.gd`, and agent docs.
- Selected battle scene: `Battle_Fullscreen_Test.tscn`, using `scripts/battle_web_import_test.gd`.
- Handoff strategy: runtime-only Godot `Engine` metadata key `samwar_worldmap_battle_context`; the battle scene reads and clears it on startup, with no save/autoload/project-setting persistence.
- Manual/auto defense now prepares context, stores the full context payload, and transitions to the battle scene. Direct battle scene launch without context still uses the existing demo setup.
- Verification passed: patch strings, handoff/intake paths, forbidden implementation search, `git diff --check`, Godot project headless load, root `WorldMap_Test.tscn` headless load, and direct `Battle_Fullscreen_Test.tscn` headless load.
- Recommended next task: `v0.68b-12b-14 WorldMap Battle Result Return MVP`.
- `v0.68b-12b-11 WorldMap Enemy Invasion BattleContext Bridge` is complete.
- Modified `scripts/worldmap_test.gd`, `scripts/worldmap_hero_portrait_helper.gd.uid`, and agent docs.
- Inspected web references: `battle_state.js`, `battle_rules.js`, `world_rules.js`, `app_state.js`, `world_map_ui.js`, `world_hud_ui.js`, `main.js`, `battle_rosters.js`, `cities.js`, and `heroes.js`.
- Manual/auto defense buttons now validate the pending invasion event and create runtime `_player_state.pending_battle_context` with defense type/source/mode, attacker/defender ids and names, turn numbers, owners, troops, stationed hero ids, and governor ids.
- Save/load/reset policy remains web-like: pending invasion event and pending battle context are not persisted and are cleared on load/reset.
- Verification passed: patch strings, context/validation paths, forbidden implementation search, `git diff --check`, Godot project headless load, and root `WorldMap_Test.tscn` headless load.
- Recommended next task: `v0.68b-12b-12 WorldMap Enemy Invasion Battle Scene Handoff MVP`.
- `v0.68b-12b-10b WorldMap Hero Portrait Asset Binding MVP` is complete.
- Modified `scripts/worldmap_test.gd`, `scripts/worldmap_city_info_panel.gd`, `scripts/worldmap_hero_portrait_helper.gd`, and agent docs.
- Inspected asset folders: `assets/web_battle/portraits`, `assets/web_battle/portraits_battlefield`, and repo-local asset listings.
- Portrait lookup uses existing `HERO_DATA` fields, maps legacy `assets/portraits/...` seed paths to existing `assets/web_battle/portraits/...`, and keeps `?` fallback for missing/failed textures.
- Updated chancellor and right taesu/governor portrait boxes; stationed hero list remains text-only for layout safety.
- Verification passed: patch/helper strings, `git diff --check`, Godot project headless load, and root `WorldMap_Test.tscn` headless load.
- Recommended next task after 10b was `v0.68b-12b-11 WorldMap Enemy Invasion BattleContext Bridge`; it is now complete.
- `v0.68b-12b-10a WorldMap Right City Info Panel Web Parity Cleanup` is complete.
- Modified `scripts/worldmap_test.gd`, `scripts/worldmap_city_info_panel.gd`, root `WorldMap_Test.tscn`, and agent docs.
- Inspected web references: `world_map_ui.js`, `world_hud_ui.js`, `ui_render.js`, `selected_city_ui.js`, `app_state.js`, `world_rules.js`, `data/cities.js`, and `data/heroes.js`.
- The right selected-city panel now cleanly displays owner/nation/region, population, gold, food, resources, troops, defense, public support/order, commerce, agriculture, taesu/governor, and stationed heroes.
- Pending invasion defender cities now show `침공 대상 도시 · 방어전 준비 중`; attacker cities show `침공 출발 도시`.
- Verification passed: patch strings, right-panel strings, `git diff --check`, Godot project headless load, and root `WorldMap_Test.tscn` headless load.
- Recommended next task after 10a was `v0.68b-12b-10b WorldMap Hero Portrait Asset Binding MVP`; it is now complete.
- `v0.68b-12b-10.5 Session Handoff Docs Update Before Stop` documents the current stop point before the next session.
- Current stable baseline is `v0.68b-12b-15 WorldMap Invasion Result Ownership Troop Apply MVP`.
- User-reported F6 runtime visual check is working normally, and the pending invasion choice UI displays correctly enough for the current MVP.
- Active worldmap scene is root-level `WorldMap_Test.tscn`; `scenes/WorldMap_Test.tscn` may not exist.
- Runtime save path is `user://worldmap_left_panel_state.json`.
- `agent/LOCAL_ENV.md` and `.godot/` are ignored local files and must not be committed.
- Pending invasion event and pending battle context are not persisted on save/load; load/reset clear both according to the web audit policy.
- Battle scene handoff, battle result return, and bounded runtime ownership/troop apply are complete; persistence, resource loss, and detailed casualty handling remain deferred.
- Completed today: `12b-1` seed import, `12b-2` left controls, `12b-3` chancellor policy/warehouse, `12b-3a` warehouse cleanup, `12b-4` turn/save, `12b-5` turn loop, `12b-6` domestic apply, `12b-7` QA, `12b-8` invasion audit, `12b-9` invasion event, and `12b-10` invasion choice UI.

- `v0.68b-12b-10 WorldMap Enemy Invasion Choice UI MVP` is complete.
- Modified `scripts/worldmap_test.gd` and agent docs only; root `WorldMap_Test.tscn` was inspected but not modified.
- Added a runtime `PendingInvasionChoiceCard` to the left world status panel, hidden without a pending event and visible when `_player_state.pending_invasion_event` exists.
- The card shows attacker/defender city details plus `수동 방어` and `자동 방어` placeholder buttons.
- Button handlers only update safe status text and keep the pending event intact; they do not create battle prep data, start battle, auto-resolve, change ownership, move heroes/troops, or deduct troops.
- `아군 턴 종료` is disabled/blocked while a pending event exists, and save/load/reset continue to clear pending invasion state.
- Recommended next task after 10 was `v0.68b-12b-11 WorldMap Enemy Invasion BattleContext Bridge`; it is now complete.

- `v0.68b-12b-8 WorldMap Enemy Invasion Web Logic Audit` is complete.
- Created `agent/ENEMY_INVASION_AUDIT.md` and updated handoff/current-state docs only; no Godot gameplay code or scene file was modified.
- Inspected local read-only web sources for enemy turn/invasion flow: `js\core\app_state.js`, `world_rules.js`, `world_calendar.js`, `save_load.js`, `battle_state.js`, `battle_rules.js`, `battle_ai.js`, `js\ui\world_hud_ui.js`, `world_map_ui.js`, `ui_render.js`, `main.js`, and `constants.js`.
- Web invasion is rolled in `app_state.endWorldTurn()` after player-side turn systems with `ENEMY_INVASION_CHANCE = 0.45`; candidates are enemy-owned cities whose `neighbors` include player-owned cities.
- Web target selection is random among eligible adjacent pairs; no troop threshold, route type, diplomacy/peace check, city strength priority, cooldown, or multi-action enemy world turn was found in the audited selection path.
- Web invasion creates a defense `pendingBattleChoice` and a minimal defense `battleContext` only; battle start and troop allocation happen after manual/auto defense choice, and ownership changes only after battle retreat/return.
- Web save/load clears pending invasion/battle state and returns to normalized player-turn world mode.
- Recommended next task: `v0.68b-12b-9 WorldMap Enemy Invasion Event MVP`.

- `v0.68b-12b-7 WorldMap Domestic Apply Visual QA + Balance Check` is complete.
- Modified `scripts/worldmap_test.gd` and agent docs only; root `WorldMap_Test.tscn` was inspected but not modified.
- Added `_player_state.last_domestic_apply_turn` and a same-turn guard in `_apply_domestic_turn_mvp()` so stale or duplicate callbacks cannot apply domestic resource/loyalty changes twice.
- Updated save metadata to `v0.68b-12b-7`; save/load/reset continue to persist domestic-updated resources, loyalty, tax, chancellor id/policy, phase, turn, calendar labels, pending state, and the last applied turn guard.
- QA coverage was static/headless: default cycle path, preview-only tax/policy/chancellor handlers, warehouse/loyalty refresh paths, save/load/reset restoration, capacity/loyalty clamps, and hidden internal warehouse/debug labels.
- No enemy invasion, enemy AI, target selection, hero movement, city ownership change, governor execution, new domestic system, `BattleContext`, battle transition, route/pathfinding change, or broad simulation was added.
- Recommended next task: `v0.68b-12b-8 WorldMap Enemy Invasion Web Logic Audit`.

- `v0.68b-12b-6 WorldMap Turn Domestic Apply Web Parity MVP` is complete.
- Inspected local read-only web references: `C:\dev\SamWar_web\js\core\app_state.js`, `js\core\save_load.js`, `js\core\world_calendar.js`, `js\core\domestic_income.js`, `js\core\domestic_effects.js`, `js\constants.js`, `js\ui\world_hud_ui.js`, and `js\ui\world_map_ui.js`.
- Modified `scripts/worldmap_test.gd` and agent docs only; root `WorldMap_Test.tscn` was inspected but not modified.
- Domestic apply now runs once when the enemy-turn placeholder finishes and the game returns to the next player turn.
- Ported the narrow web MVP subset: seasonal owned-city income, population/commerce tax gold, tax loyalty delta, chancellor policy income multipliers, active chancellor national modifiers, hero upkeep deduction, warehouse capacity clamp, and concise result status.
- Tax slider and chancellor policy dropdown remain preview-only until turn completion; save/load/reset and UI refresh do not apply domestic changes.
- Save data version is now `v0.68b-12b-6` and continues to persist `_player_state`, including domestic-updated resources/loyalty, tax, chancellor id/policy, phase, turn, and calendar labels.
- No enemy invasion, enemy AI, target selection, hero movement, city ownership change, governor appointment execution, soldier upkeep application, salt consumption, `BattleContext`, battle transition, route/pathfinding change, or broad simulation was added.
- Recommended next task: `v0.68b-12b-7 WorldMap Domestic Apply Visual QA + Balance Check`.

- `v0.68b-12b-5 WorldMap Enemy Turn Return / Turn Cycle MVP` is complete.
- Inspected local read-only web references: `C:\dev\SamWar_web\js\core\app_state.js`, `js\core\save_load.js`, `js\ui\world_hud_ui.js`, `js\ui\world_map_ui.js`, `js\main.js`, `js\core\world_calendar.js`, and `js\constants.js`.
- Modified `scripts/worldmap_test.gd` and agent docs only; root `WorldMap_Test.tscn` was inspected but not modified.
- The Godot left panel now completes `아군 턴 -> 적군 턴 -> 다음 아군 턴` with a short Timer-backed enemy placeholder.
- `_finish_enemy_turn_mvp()` returns the phase to player, and `_advance_world_turn_mvp()` increments `turn_number` exactly once per completed cycle.
- Calendar labels now follow the web MVP rule: `154` start year, `10` turns per season, `40` turns per year, seasons `봄/여름/가을/겨울`.
- Enemy-turn pending state disables `아군 턴 종료` during the placeholder and is cancelled on load/reset to avoid duplicate timers.
- Save/load/reset preserve phase and turn/calendar state through `_player_state`; loading an enemy-phase save resumes the placeholder return path.
- No enemy invasion, target selection, hero movement, city ownership change, resource production tick, domestic apply pipeline, `BattleContext`, battle transition, route/pathfinding change, or broad AI simulation was added.
- Recommended next task: `v0.68b-12b-6 WorldMap Turn Domestic Apply Web Parity MVP`.

- `v0.68b-12b-4 WorldMap Turn End + Save Management Web Parity MVP` is complete.
- Inspected local read-only web references: `C:\dev\SamWar_web\js\core\app_state.js`, `js\core\save_load.js`, `js\ui\world_hud_ui.js`, `js\ui\world_map_ui.js`, and `js\main.js`.
- Modified `scripts/worldmap_test.gd` and agent docs only; the active worldmap scene remains root `WorldMap_Test.tscn`.
- Hid the remaining visible bottom internal/debug labels below `국가 창고`, including selected-city/stationed-hero/logistics/trade/policy explanatory bottom lines.
- Replaced the old `야군 편집` button text with `아군 턴 종료`.
- `아군 턴 종료` now changes `_player_state.turn_phase` from `player` to `enemy`, updates the visible phase label to `적군 턴`, refreshes the left panel, and calls a documented `_run_enemy_turn_mvp()` hook.
- The enemy-turn hook is placeholder-only and does not run enemy invasion, AI, ownership changes, hero movement, `BattleContext`, battle transition, resource ticks, or turn-cycle return.
- Save management now uses `user://worldmap_left_panel_state.json` for runtime JSON save/load and resets `_player_state` to the startup seed baseline; no repo file is used for runtime save data.
- Verification passed: patch strings present, button/save/hook paths present, hidden-label assignments present, save path uses `user://`, Godot project headless load passed, `WorldMap_Test.tscn` headless load passed, and `git diff --check` passed.
- Recommended next task: `v0.68b-12b-5 WorldMap Enemy Turn Return / Turn Cycle MVP`.

- `v0.68b-12b-3a WorldMap National Warehouse Card UI Cleanup` is complete.
- Modified `scripts/worldmap_test.gd`, root `WorldMap_Test.tscn`, and agent docs; the requested `scenes/WorldMap_Test.tscn` path is absent in this repo.
- Replaced the visible plain multiline `국가 창고` output with a boxed runtime `WarehouseCard` `PanelContainer`.
- The visible card now shows only data-bound resource rows for `쌀`, `보리`, `수산물`, `목재`, `철`, `말`, `비단`, `소금`, and `금전`, each with current/max and status label.
- Hidden from visible warehouse UI: `영웅 유지비`, `병사 유지비 preview`, `보존 소금`, `유지비 정상`, and other internal maintenance preview lines.
- Verification passed: patch strings present, warehouse card/helper paths present, row display bound from `_player_state.resource_stock`, visible `SupplyLabel` output hidden, Godot project headless load passed, `WorldMap_Test.tscn` headless load passed, and `git diff --check` passed.
- No gameplay systems were added: no movement, appointment execution, actual upkeep/resource production, resource mutation, turn simulation, `BattleContext`, battle transition, route/pathfinding, or broader HUD redesign.
- `v0.68b-12b-3 WorldMap Chancellor Policy + National Warehouse Web Parity MVP` is complete.
- Inspected local read-only web parity sources: `C:\dev\SamWar_web\data\heroes.js`, `cities.js`, `battle_rosters.js`, `js\core\app_state.js`, `js\core\domestic_income.js`, `js\core\domestic_effects.js`, `js\constants.js`, `js\ui\world_hud_ui.js`, and `js\ui\resource_ui.js`.
- Modified `scripts/worldmap_test.gd` and root `WorldMap_Test.tscn`; the requested `scenes/WorldMap_Test.tscn` path is absent in this repo.
- Added a functional `재상 정책` dropdown backed by `_player_state.chancellor_policy_id` with the five web policy options: `균형형`, `농업 중심`, `상업 중심`, `무역 중심`, and `군사 중심`.
- Ported the web policy effect definitions into local preview metadata so policy selection refreshes effect text, resource multiplier summary, hero upkeep preview, soldier upkeep preview, and salt preservation preview without mutating resources.
- Retired the duplicate visible `보유 자원: ...` line and consolidated resource display into `국가 창고`, with rows bound from `_player_state.resource_stock`, web-like capacity/status labels, and upkeep/preservation preview lines.
- Verification passed: patch strings present, policy dropdown/helpers present, warehouse helpers present, duplicate visible resource assignment absent, forbidden implementation search returned no matches, Godot project headless load passed, `WorldMap_Test.tscn` headless load passed, and `git diff --check` passed.
- No hero movement, governor/chancellor appointment execution beyond UI state, full end-turn simulation, actual resource/loyalty mutation, `BattleContext`, battle transition, route/pathfinding, castle icon, or repo-outside web change was made.
- `v0.68b-12b-2 WorldMap Left Panel Web Parity Controls MVP` is complete.
- Inspected local read-only web parity sources: `C:\dev\SamWar_web\data\heroes.js`, `cities.js`, `battle_rosters.js`, `js\core\app_state.js`, `js\core\domestic_income.js`, `js\core\domestic_effects.js`, `js\constants.js`, and `js\ui\world_hud_ui.js`.
- Modified `scripts/worldmap_test.gd` and root `WorldMap_Test.tscn`; the requested `scenes/WorldMap_Test.tscn` path is absent in this repo.
- Added a tax slider and web-like tax preview binding: `_player_state.tax_level` updates visible tax value/status and preview text without applying turn income, resources, or loyalty changes.
- National loyalty now displays seed-backed value/status/progress from `_player_state.national_loyalty`.
- Chancellor assignment now uses a dropdown populated from selected-city stationed heroes plus first option `미임명`; selection updates only `_player_state.chancellor_id` and refreshes card/effect preview text from `HERO_DATA.chancellor_profile`.
- Missing portraits use a `?` fallback and do not block chancellor display.
- Verification passed: patch strings/data blocks present, Hanseong stationed heroes found, dropdown/fallback paths found, forbidden implementation search returned no matches, Godot project headless load passed, `WorldMap_Test.tscn` headless load passed, and `git diff --check` passed.
- No turn simulation, resource mutation, loyalty application, policy effect execution, movement, appointment system behavior, `BattleContext`, battle transition, route/pathfinding, castle icon, or repo-outside web change was made.
- `v0.68b-12b-2 WorldMap Left Panel Seed Binding QA` is complete.
- Updated `scripts/worldmap_test.gd` left panel display binding only; no scene file changes were needed because the existing `LeftWorldStatusPanel` labels were sufficient.
- Verified/fixed left panel reads from `_player_state`, `CITY_HUD_DATA`, and `HERO_DATA`: selected/origin city names, selected city owner/region/governor/stationed heroes, owned city list, owned hero list, resource stock, and web-parity no-chancellor fallback.
- City marker selection now updates `_player_state.selected_city_id` and refreshes `LeftWorldStatusPanel` so the left panel follows current selected city seed data.
- Added display-only formatting helpers for city names, hero names, city/hero lists, and player resource stock so the UI shows clean Korean fallback text instead of empty ids or raw unknown keys.
- Verification passed: patch strings/data blocks present, forbidden implementation search returned no matches, Godot project headless load passed, `WorldMap_Test.tscn` headless load passed, and `git diff --check` passed.
- No hero movement, governor/chancellor appointment execution, policy effect, resource/troop/turn mutation, `BattleContext`, battle transition, route/pathfinding, scene layout, castle icon, or repo-outside web change was made.
- `v0.68b-12b-1 WorldMap Hero City Seed Data Import` is complete.
- Used local read-only web sources `C:\dev\SamWar_web\data\heroes.js`, `C:\dev\SamWar_web\data\cities.js`, `C:\dev\SamWar_web\data\battle_rosters.js`, plus constants/app-state references for faction IDs, resource keys, tax/resource baseline, selected city, and no-chancellor default.
- Updated `scripts/worldmap_test.gd` only for runtime seed data: `HERO_DATA`, `CITY_HUD_DATA`, and `_player_state`.
- `HERO_DATA` now preserves existing Godot HUD keys and adds web seed fields for identity, faction/side, role/command rank, troops/hp/combat stats, portrait paths, unique skill id, and chancellor profile.
- `CITY_HUD_DATA` now preserves existing display strings and adds web seed fields for city identity, owner/nation/region/type, population, gold/food/troops, public order, commerce, agriculture, defense, hero_ids, resource/domestic/yield seeds, governors, and stationed hero rosters.
- `_player_state` now records web-aligned player faction/current city/selected city/owned city/owned hero/resource stock seeds and uses an empty `chancellor_id` for web parity with `chancellorHeroId: null`.
- Verification passed: patch strings/data blocks present, forbidden implementation search returned no matches, Godot project headless load passed, `WorldMap_Test.tscn` headless load passed, and `git diff --check` passed.
- No movement, appointment execution, policy effect, resource/troop/turn mutation, `BattleContext`, battle transition, route/pathfinding, scene layout, castle icon, or repo-outside web file change was made.
- `v0.68b-12b-0.5 Session Handoff Docs Update Before New Chat` is complete.
- This was a docs-only handoff update for the next chat; no code, scenes, assets, or seed data were changed.
- It records the current worldmap HUD flow from `v0.68b-8` through `v0.68b-12b`, the `v0.68b-12b-pre` auto work header rule documentation, the `v0.68b-12b` left HUD content parity investigation, and the `v0.68b-12b-0` hero/city seed data structure audit.
- `v0.68b-12b-pre Codex Auto Work Header Rule Documentation` is complete and made `[SamWar_BattleLab 자동 작업 권한 헤더]` mandatory before future task names/goals.
- `v0.68b-12b Left World HUD Web Content Parity` included a web-source attempt/investigation flow before implementation: inspect the web left HUD render and resource/trade copy, then keep the Godot patch display-only.
- `v0.68b-12b-0 WorldMap Hero City Seed Data Structure Audit` is complete.
- Investigation summary: web `heroes.js` is an array with hero identity, faction/side, role, stats, portrait, battlefield portrait, and chancellor profile fields; web `cities.js` carries city identity, ownership, route, governor, loyalty, resource, military, domestic, and yield fields; web `battle_rosters.js` `cityDefenderRosters` is the key city-stationed hero source.
- Web domestic parity note: `createInitialDomesticPolicy()` initializes `chancellorHeroId` as `null`; `getEligibleChancellorHeroes()` returns active player-side heroes; governor candidates come from selected-city stationed player-side heroes at that city.
- Godot seed state note: `scripts/worldmap_test.gd` currently owns display-only `HERO_DATA`, `CITY_HUD_DATA`, `CHANCELLOR_POLICY_DATA`, `GOVERNOR_POLICY_DATA`, and `_player_state`. `_player_state.chancellor_id` now uses the web-parity empty baseline.
- `v0.68b-12b Left World HUD Web Content Parity` is complete.
- The Godot `LeftWorldStatusPanel` was checked against the actual web `world_hud_ui.js` and `resource_ui.js` output instead of adding arbitrary new UI.
- Runtime copy now follows the web left HUD order: `World Turn`, turn/calendar/owner, `국가충성도`, `세금 수준`, chancellor card, `재상 임명`, `재상 정책`, `보유 자원`, `국가 창고`, `내부 보급망`, `내부 병력 재배치`, `대외 무역`, income/policy/tax summary, wild-army edit, and save/load/reset.
- Chancellor card copy now reflects web chancellor profile fields for 정도전, with a portrait initial fallback until the portrait asset contract/apply tasks.
- Chancellor policy options remain `균형형`, `농업 중심`, `상업 중심`, `무역 중심`, and `군사 중심`; changing the option updates explanation only.
- Buttons remain placeholders; no real turn, resource, policy effect, save/load/reset, domestic, diplomacy/spy, battle, army, route, pathfinding, or AI behavior was added.
- Castle icon visuals remain disabled, and route lines plus sea route arrow flow remain unchanged.
- 김작 F6 should confirm left HUD content parity, section order, chancellor card/policy UI, resource/supply/logistics/trade wording, placeholder-only behavior, bottom spacing, independent drag/collapse preservation, city-click refresh, castle icon disabled state, route/sea arrow continuity, and battle scene stability.
- `v0.68b-12 WorldMap Unified City Detail Diplomacy Panel MVP` is complete.
- The former separate City Detail and Diplomacy/Spy HUD surfaces are consolidated into one `CityDetailPanel`-backed unified panel.
- Primary tabs are `도시 상세` and `외교·첩보`.
- City-detail mode keeps the existing secondary tabs: `자원`, `자국무역`, and `타국무역`.
- Diplomacy/spy mode uses secondary tabs: `외교` and `첩보`, with display-only placeholder copy.
- The standalone `DiplomacySpyPanel` is hidden at runtime and no longer occupies separate screen space.
- The unified panel has a compact collapse/expand state with `도시 상세 열기`; no panel position persistence was added.
- Independent drag remains for the unified panel, `CityInfoPanel`, and `LeftWorldStatusPanel`; `SelectedCityPanel` / `CityInfoPanel` remains separate from the unified panel.
- No domestic execution, diplomacy/spy execution, resource mutation, turn processing, save/load, `BattleContext`, battle entry, hero transfer, army movement, route/pathfinding, or AI behavior was added.
- Castle icon visuals remain disabled, and route lines plus sea route arrow flow remain unchanged.
- 김작 F6 should confirm unified panel structure, primary/secondary tab switching, collapse/expand, independent drag, no camera pan while panel-dragging, city-click data refresh, placeholder-only controls, castle icon disabled state, route/sea arrow continuity, and battle scene stability.
- `v0.68b-11 WorldMap Independent Draggable Panels + Top Banner Cleanup MVP` is complete.
- Referenced the web `world_map_ui.js` grouped `city-hud-stack` draggable flow, but did not copy its grouped movement or localStorage persistence.
- Godot now hides the retired top `SamWar Web` banner and `도시 HUD 위치 이동 · Godot MVP fixed` dragbar at runtime.
- `LeftWorldStatusPanel`, `DiplomacySpyPanel`, `CityDetailPanel`, and `CityInfoPanel` can move independently by left-dragging their title/header labels.
- Panel drag is runtime-only, clamps panels so a visible portion stays on-screen, and does not create save files, user config, localStorage, or project setting changes.
- Buttons, tabs, and policy `OptionButton` controls remain outside the drag handles and keep display-only placeholder behavior.
- City click data binding, City Detail tabs, selected-city HUD, chancellor/governor policy UI, castle icon disabled state, route lines, sea route arrow flow, and existing battle scenes remain unchanged.
- 김작 F6 should confirm the removed top UI, independent panel drag, no cross-panel following, header-only drag, control/drag non-conflict, no camera pan while dragging a panel, screen-fixed HUD during pan/zoom, city-click refresh, tab/policy preservation, castle icon disabled state, route/sea arrow continuity, and battle scene stability.
- `v0.68b-10 WorldMap Domestic Affairs Web Source Parity MVP` is complete.
- Referenced actual web sources for world HUD, selected city, city detail/resources/trade, diplomacy/spy, governor, garrison, military, constants, app state, city data, hero data, and battle rosters.
- Godot `CityDetailPanel` now follows the web `resource_ui.js` tab structure: `자원`, `자국무역`, and `타국무역`, with display-only tab switching.
- Chancellor and governor policy options now follow web constants and labels; policy selection only updates local UI text.
- City HUD seed data prioritizes web `data/cities.js`, `data/heroes.js`, and `data/battle_rosters.js` for city loyalty/resource/military copy, governors, and stationed hero rosters.
- Selected City copy now follows `selected_city_ui.js` more closely with `주둔 무장`, `군대 상태`, `공격`, `무장 이동`, and recruit placeholder wording.
- No domestic execution, resource mutation, turn processing, save/load, `BattleContext`, battle entry, hero transfer, army movement, route/pathfinding, or AI behavior was added.
- Castle icon visuals remain disabled, and route lines plus sea route arrow flow remain unchanged.
- 김작 F6 should confirm the web-source parity of tabs/text/buttons, city click dual panel refresh, policy description-only behavior, placeholder-only buttons, castle icon disabled state, HUD fixed behavior during pan/zoom, route/sea arrow continuity, and battle scene stability.
- `v0.68b-9 WorldMap HUD Data Binding MVP` is complete.
- Referenced the web chancellor/governor/policy/garrison/city-detail HUD modules and data files.
- Godot `WorldMapUI` now displays local HUD data for player turn/status, chancellor portrait/name/stats/policy, city governor portrait/name/stats/policy, city loyalty, stationed hero chips, and richer city detail resource/military/trade/rating copy.
- Chancellor and governor policy `OptionButton` controls update local UI state and descriptions only; no resource effects, turn processing, domestic execution, recruitment, hero transfer, army movement, battle entry, or `BattleContext` creation was added.
- Castle icon visuals remain disabled, and route lines plus sea route arrow flow remain unchanged.
- 김작 F6 should confirm the chancellor data/policy UI, governor data/policy UI, stationed hero list, CityDetail data binding, placeholder-only buttons, castle icon disabled state, fixed HUD behavior during pan/zoom, route/sea arrow continuity, and existing battle scene stability.
- `v0.68b-8 WorldMap Web HUD Visual Parity MVP` is complete.
- Referenced the web `index.html`, `css/main.css`, `world_map_ui.js`, `ui_render.js`, `world_hud_ui.js`, `diplomacy_spy_ui.js`, `resource_ui.js`, and `selected_city_ui.js` structure and styling.
- Tuned Godot `WorldMapUI` toward the web HUD visual style: dark navy translucent panels, thin gold borders, gold/beige headings, dense small text, inner cards, tab buttons, red action buttons, progress-bar placeholders, and a centered `SamWar Web` title banner.
- Left World Turn panel now visually includes turn/calendar/owner, progress placeholder bars, chancellor, national resources, internal supply, logistics plan, external trade, wild-army edit, and save/load/reset placeholders.
- Diplomacy/Spy, City Detail, and Selected City panels were visually expanded with web-like card/tabs/action styling while remaining placeholder-only.
- City clicks still refresh City Detail and Selected City; no `BattleContext`, battle entry, domestic execution, diplomacy/spy execution, turn/resource changes, or hero/army movement was added.
- Castle icon visuals remain disabled, and route line / sea arrow flow were not changed.
- 김작 F6 should confirm visual similarity to the web HUD, screen-fixed panel behavior, placeholder-only buttons, castle icon disabled state, route/sea arrow continuity, and battle scene stability.
- `v0.68b-8 WorldMap Web HUD Panel Structure Import MVP` is complete.
- Godot `WorldMapUI` now mirrors the web worldmap HUD structure at MVP scope: left World Turn/Status panel, upper-right Diplomacy/Spy panel, right City Detail panel, and expanded Selected City / `CityInfoPanel`.
- The implementation referenced the web `renderAllWorldUI()`, `renderWorldHud()`, `renderDiplomacySpyPanel()`, `renderCityDetailPanel()`, and `renderSelectedCityPanel()` structure.
- City marker clicks still update `selected_city_id`, `selected_city_marker`, and `SelectionRing`, and now refresh both `CityDetailPanel` and `CityInfoPanel`.
- Turn/status, diplomacy, spy, city detail, selected city, attack, hero-move, domestic, and wild-army-edit controls remain placeholder-only.
- No `BattleContext`, battle entry, domestic execution, resource turn processing, or hero/army movement behavior was added.
- Castle icon visuals remain disabled, and route lines plus sea route arrow flow remain unchanged.
- 김작 F6 should confirm the left world status panel, upper-right diplomacy/spy panel, city detail panel, selected city panel, city-click dual refresh, screen-fixed HUD behavior, placeholder-only buttons, castle icon disable state, route/sea arrow continuity, and battle scene stability.
- `v0.68b-6a WorldMap Castle Icon Visual Disable Functional Marker Patch` is complete.
- Castle icon visuals are deferred for now; all castle icon assets and `CastleIcon` scene nodes remain, but the nodes are hidden.
- `scripts/worldmap_city_marker.gd` now uses `CASTLE_ICON_VISUALS_ENABLED := false` and restores the colored `CityDot` as the visible functional marker.
- CityInfoPanel, selected city state, `SelectionRing`, `ClickArea`, `NameText`, and city metadata remain intact.
- Route lines and sea route arrow flow remain unchanged. No `BattleContext`, battle entry, domestic UI, or real hero/army movement behavior was added.
- 김작 F6 should confirm castle icons are not visible, city labels and simple markers remain visible, city clicking / selection ring / CityInfoPanel still work, pan/zoom clicking remains normal, route/sea arrow flow remains normal, and battle scenes are stable.
- `v0.68b-6 WorldMap Selected City Panel Web Parity MVP` is complete.
- Ported the web selected-city HUD structure into `WorldMapUI/CityInfoPanel`.
- City marker clicks now update `selected_city_id`, maintain `selected_city_marker`, clear previous marker selection, show the selected marker's `SelectionRing`, and refresh panel metadata.
- The panel displays city name, id, region/owner, city type, neighbors, route type summary, MVP status text, and attack / hero-move placeholder buttons.
- Attack and hero-move placeholders do not create `BattleContext`, change scenes, move heroes/armies, or open domestic detail UI.
- Route lines and sea route arrow flow were preserved; sea arrow initial spacing moved into script to avoid scene-load `progress_ratio` errors.
- 김작 F6 should confirm city selection, selected marker readability, fixed panel placement, metadata text, placeholder buttons, pan/zoom click behavior, route/sea arrow continuity, and battle scene stability.
- `v0.68b-5 WorldMap Sea Route Arrow Flow FX MVP` is complete.
- Added sea-only visual flow arrows to Gyeongju-Kyoto, Gyeongju-Osaka, Sabi-Kyushu, Sabi-Jianye, and Kyushu-Osaka.
- Each sea route has an `ArrowFlowRoot` Path2D with four `PathFollow2D` arrow markers and small pale blue Polygon2D arrow sprites.
- `scripts/worldmap_route_flow_fx.gd` references the route's scene-authored `Path2D.curve`; it does not regenerate curves from city positions.
- Arrow flow is one-way from `start_city_id` to `end_city_id` for this MVP.
- Land routes remain line-only. No movement, pathfinding, trade, battle entry, naval battle, or `BattleContext` behavior was added.
- 김작 F6 should confirm sea arrows flow naturally, wrap cleanly, read at a good speed, do not cover city markers/names, land routes have no arrows, pan/zoom keeps FX attached, city click info remains normal, and battle scenes are stable.
- `v0.68b-4-hotfix1 WorldMap Land Route Visibility Tuning` is complete.
- Land route visibility was strengthened by changing land `Line2D` width to `4.5` and color to `Color(0.86, 0.62, 0.32, 0.72)`.
- Sea route style was intentionally kept unchanged.
- `Path2D.curve` remains scene-authored; no route paths, city marker positions, route metadata, movement, battle entry, or `BattleContext` behavior changed.
- 김작 F6 should confirm land routes read clearly on earth-tone terrain without overpowering castle icons, sea route feel is unchanged, pan/zoom keeps routes attached, editable curves remain available, city click info remains normal, and battle scenes are stable.
- `v0.68b-4 WorldMap Route Layer Path2D MVP` is complete.
- Added route roots under `WorldMap_Test.tscn > WorldMapRoot > RouteLayer`, each with metadata, `Path2D`, and `Line2D`.
- Route meaning is code metadata while actual route shape is scene-authored `Path2D.curve`.
- Initial routes were seeded from current `CityMarker_*` positions based on web `neighbors` / `routeTypes`; land routes are muted earth-tone and sea routes are pale blue.
- Route clicking, army movement, pathfinding, battle entry, naval battle logic, and `BattleContext` runtime injection remain deferred.
- 김작 2D/F6 should confirm route node structure, editable curves, route line visibility during camera pan/zoom, land/sea visual separation, city marker readability, city click info panel behavior, and battle scene stability.
- Known issue retained: CityMarker root movement / name text attachment still needs manual confirmation and is not treated as a route-layer blocker.
- `v0.68b-3 WorldMap City Castle Icon Apply` is complete.
- City markers now use regional castle icon children: Korea, China, Japan, and Ordo.
- `CastleIcon`, Node2D `NameText`, and `ClickArea/CollisionShape2D` remain children of each `CityMarker_*` root, so editor root movement should move the full city bundle.
- 김작 2D/F6 should confirm icon mapping, icon/name overlap, root movement bundle behavior, click info panel, camera behavior, and battle scene stability.
- `v0.68b-2-hotfix6 WorldMap City Marker Node2D NameLabel Fix` is complete.
- Converted city `NameLabel` nodes from `Label` / `Control` to Node2D text nodes so marker root movement carries city names in the 2D editor.
- 김작 2D/F6 should confirm root movement now visibly moves city name text, marker dot, and click area together.
- `v0.68b-2-hotfix5 WorldMap City Marker Label Reparent Fix` is complete.
- All 13 `CityMarker_*` roots now use explicit local children named `CityDot`, `NameLabel`, and `ClickArea/CollisionShape2D`.
- `scripts/worldmap_city_marker.gd` reads those local children and does not assign separate world-space positions to `NameLabel`.
- City marker positions remain scene-authored source of truth, and moving a root marker should carry icon/dot, label, and click area together.
- 김작 2D/F6 should confirm root move attachment for Hanseong and the other 12 cities, click area movement, Ctrl+S persistence, and marker click info panel behavior.
- `v0.68b-2-hotfix4 WorldMap City Marker Root Attachment Fix` is complete.
- Added `ClickArea` / `CollisionShape2D` under every `CityMarker_*` root and kept icon/dot plus label as root children.
- Added marker click signal plumbing and a minimal `WorldMapUI/CityInfoLabel` update path while preserving marker metadata.
- City marker positions remain scene-authored source of truth, and moving a root marker should carry its icon, label, and click area together.
- 김작 2D/F6 should confirm root move attachment, click area alignment, info label update, Ctrl+S persistence, camera behavior, and battle scene stability.
- `v0.68b-2-hotfix3 WorldMap Manual Tile Layout Control` is complete.
- Runtime no longer auto-repositions the four worldmap Tile nodes during `_ready()`.
- Tile layout source of truth is now the scene-authored Tile node positions in `WorldMap_Test.tscn`.
- Camera clamp/world rect is calculated from the union of the current tile Sprite2D rects.
- City marker positions remain scene-authored source of truth and marker nodes/metadata were preserved.
- 김작 2D/F6 should confirm manual Tile move/save persistence, no runtime overwrite, camera clamp against the tile union rect, city marker presence, and battle scene stability.
- `v0.68b-2-hotfix2 WorldMap Tile Editor Seam Fix` is complete.
- Corrected scene-authored tile positions so the Godot 2D editor shows the 4 worldmap tiles as one contiguous map.
- Re-seeded all 13 city markers to the corrected 1024x1024 four-tile combined rect while preserving `CityMarker_*`.`position` as the future source of truth.
- Kept camera pan/drag/zoom/clamp behavior, marker metadata, and empty future layers intact.
- 김작 2D/F6 should confirm seam-free tile display, city markers on the map, debug layer non-interference, camera behavior, fixed UI labels, and battle scene stability.
- `v0.68b-2-hotfix1 WorldMap City Marker Coordinate Space Fix` is complete.
- Aligned `CityLayer`, `RouteLayer`, `ArmyLayer`, `EffectLayer`, and `DebugLayer` with `WorldMapTileLayer` under the same zero-offset `WorldMapRoot` coordinate basis.
- Scene-authored the four tile positions and re-seeded all 13 city markers against the 4-tile combined rect so markers sit on the map image in the Godot 2D editor.
- Preserved the rule that final city position source of truth is `CityMarker_*`.`position` in `WorldMap_Test.tscn`, not web `x` / `y`.
- 김작 F6 should confirm marker-on-map placement, editor move-and-save persistence, camera pan/zoom/clamp behavior, fixed UI labels, and no battle scene regression.
- `v0.68b-2 WorldMap City Marker Layer MVP` is complete.
- Added 13 scene-authored city marker nodes under `WorldMap_Test.tscn > WorldMapRoot > CityLayer`, based on `SamWar_web/data/cities.js`.
- Added `scripts/worldmap_city_marker.gd` with exported metadata for `city_id`, `display_name`, `region_id`, `owner_faction_id`, `neighbors`, `route_types`, and `web_seed_position`.
- Treated web `x` / `y` as initial seed/fallback only; final marker placement is the `CityMarker_*` root node position saved in the Godot scene.
- Kept city click, selection UI, route drawing, army movement, battle entry, and `BattleContext` creation deferred.
- 김작 F6 should confirm marker visibility/readability, editor move-and-save persistence, camera pan/zoom attachment, and absence of city click/battle entry behavior.
- `v0.68b-1 WorldMap Four-Tile Canvas Foundation` is complete.
- Added `WorldMap_Test.tscn` as a 2x2 four-tile visual worldmap canvas using the prepared `assets/worldmap/tiles/` PNGs.
- Added `scripts/worldmap_test.gd` for `WorldMapCamera` current setup, WASD/arrow pan, right/middle drag pan, optional wheel zoom, and viewport/zoom-aware clamp to the combined tile rect.
- Prepared empty `CityLayer`, `RouteLayer`, `ArmyLayer`, `EffectLayer`, and `DebugLayer`; no city click, route graph, army movement, battle entry, or `BattleContext` creation was implemented.
- 김작 F6 should confirm tile attachment, camera movement/clamp, fixed UI labels, empty layer presence, and existing `Battle_Fullscreen_Test.tscn` stability.
- `v0.68a-4-hotfix6 Unique Skill Cutin Punch Motion` is complete.
- Added root-level punch motion to the unique skill cut-in: alpha fade-in, `0.85 -> 1.12 -> 1.0` scale, minimal hold, then upward fade-out / shrink to `0.92`.
- Kept particles, glow shaders, and sound deferred for a later step.
- 고유특기 effect values, target selection, cooldowns, AI judgment, formulas, Camera2D policy, battlefield background, and status badge rules remain unchanged.
- 김작 F6 should confirm the cut-in pops in quickly, exits upward without lingering, does not accumulate scale/position offsets on later uses, and connects cleanly to battlefield FX.
- `v0.68a-4-hotfix4 Unique Skill Dynamic Impact Presentation` is complete.
- Reused existing unique skill cut-in nodes and added dynamic presentation behavior: ink flash, side-based slide-in, image scale punch, delayed skill-name pop, and fast slide/fade-out.
- Effect apply timing now includes the delayed-name enter window so battlefield damage/buff/FX and camera shake begin after the cut-in exit.
- 고유특기 effect values, target selection, cooldowns, AI judgment, formulas, Camera2D policy, battlefield background, and status badge rules remain unchanged.
- 김작 F6 should confirm the cut-in feels like an attack presentation rather than a large static toast, exits quickly, and connects directly to battlefield FX.
- `v0.68a-4-hotfix3 Unique Skill Cutin Fast Impact Timing` is complete.
- Unique skill cut-in timing now uses `0.10s` enter, `0.40s` hold, and `0.12s` exit for a short strong impact.
- The cut-in should no longer linger before returning to damage/buff/FX and camera shake.
- 김작 F6 should confirm the cut-in feels around `0.6s`, remains readable, and no longer interrupts battle tempo.
- `v0.68a-4-hotfix2 Unique Skill Cutin Toast Tempo Match` is complete.
- Unique skill cut-in timing now uses `0.14s` enter, `0.9s` hold, and `0.14s` exit, closer to turn-exchange toast tempo.
- The previous `1.5s` hold is no longer used because it felt too long in 김작 F6.
- 김작 F6 should confirm the cut-in is readable, not dragged out, returns quickly to battle effects, and keeps camera shake/focus stable.
- `v0.68a-4-hotfix2 Unique Skill Cutin Timing Trace` is complete.
- Added debug-gated `[UNIQUE_CUTIN]` timing logs for show, enter done, hold start/done, exit start, hide done, and effect apply.
- Timing trace logs remain available for diagnosing the cut-in sequence, but the `1.5s` hold target is superseded by the toast-tempo match timing.
- 김작 F6 should use the current `0.9s` hold tempo as the active confirmation target.
- `v0.68a-4-hotfix1 Unique Skill Cutin Hold + Shadow Warning Fix` is complete.
- Unique skill cut-in/toast hold is now `1.5s`, while enter/exit remain short.
- Removed `global_scale` / `position` local-variable shadowing warnings in `scripts/battle_web_import_test.gd`.
- 김작 F6 should confirm the cut-in no longer disappears too quickly, post-cutin damage/buff/FX still applies, camera shake returns to current focus, and GDScript warning output is clean.
- `v0.68a-4 Unique Skill Fullscreen Cut-In Presentation` is complete.
- Unique skill presentation now uses a screen-fixed wide cut-in through the existing `BattleUI/UniqueSkillToastRoot`.
- The cut-in scales with viewport size for the large battlefield / Camera2D focus era, while existing unique skill effect values, target rules, cooldowns, AI value gates, and registry data remain unchanged.
- 김작 F6 should confirm the fullscreen cut-in scale, UI overlap feel, short enter/hold/exit timing, post-cutin damage/buff/FX, camera focus/shake return, status badge fix6, and normal attack/strategy/defend flow.
- `v0.68a-3 Battlefield Large Background Apply + Camera Clamp` is complete.
- Applied `assets/web_battle/battlefield/battlefield_3200x1800_worldmap_test_01.png` to the scene-authored battlefield background.
- Preserved current separated unit deployment and logical grid structure; no deployment recenter was done.
- Camera clamp now prefers the large battlefield texture rect before falling back to logical board bounds.
- 김작 F6 QA should confirm the large background fills camera movement, no gray/empty area appears, overlays stay synced, and normal combat flow remains stable.
- `v0.68a-2-hotfix1 Camera-Bound Overlay Sync Fix` is complete.
- Changed camera-bound overlay refresh so facing indicators, post-move facing arrows, READY frames, floating command panel, and status badges are recalculated during/after Camera2D focus movement.
- `_world_to_battle_ui_position()` now derives screen UI coordinates from the current `MainCamera` position/zoom instead of relying only on possibly stale viewport canvas transform data.
- 김작 F6 QA should confirm first-screen indicators, post-move direction arrows, status badges, and camera shake remain synced to units.
- `v0.68a-2 Combat Focus Camera Follow` is complete.
- Added Camera2D focus helpers for world position, unit focus, combat-pair midpoint, unit focus anchor, and battlefield clamp.
- Focus timing now covers battle start, ally selection, ally move start/finish, ally attack, enemy move/attack, strategy, unique skill, and reinforcement arrival.
- Camera shake now returns to the current focus baseline instead of the original scene position during unique-skill presentation.
- 김작 F6 QA should confirm smooth combat focus, fixed CanvasLayer UI, status badge fix6 preservation, and no strange return after shake.
- `v0.68a-1 Camera2D World/UI Layer Foundation` is complete.
- Confirmed scene-authored `MainCamera` exists as `Camera2D` and configured it as current at runtime.
- Added MainCamera configure/reset helpers and preserved scene-authored camera position/zoom as the baseline for reset and existing camera shake.
- Kept UI CanvasLayer-based and split combat focus follow plus battlefield scale/recenter into later tasks.
- 김작 F6 visual QA remains for normal battle display, fixed UI, MainCamera current behavior, existing camera shake, status badge preservation, and stable battle loop.
- `v0.68a-fix6 Vertical Facing Status Badge Side Edge Snap Fix` is complete.
- Changed up/down-facing battlefield status badges from arrow top/bottom tail placement to the arrow's left edge snap.
- Final status badge placement is `→` left edge, `←` right edge, `↑` left edge, and `↓` left edge.
- Left/right-facing edge snap from `v0.68a-fix4` remains unchanged.
- Confusion fallback `◎N` remains.
- 김작 F6 visual QA remains for vertical side-edge snap, `0-4px` gap, no top/bottom vertical placement, body/face/flag overlap checks, and multi-status badge block alignment.
- `v0.68a-fix5 Vertical Facing Status Badge Arrow Tail Fix` is complete.
- Changed up/down-facing battlefield status badges from side/portrait-adjacent placement to arrow-tail placement.
- Up-facing badges now attach below the arrow bottom edge; down-facing badges attach above the arrow top edge.
- Left/right-facing edge snap from `v0.68a-fix4` remains unchanged.
- Confusion fallback `◎N` remains.
- 김작 F6 visual QA remains for all-facing arrow-tail placement, vertical body-overlap checks, confusion `◎N`, and multi-status badge block alignment.
- `v0.68a-fix4 Status Badge Edge Snap To Facing Arrow` is complete.
- Changed battlefield status badge placement from full facing-indicator width math to approximate facing-arrow visual edge snapping.
- Right-facing units snap the badge block's right edge to the arrow's left edge; left-facing units snap the badge block's left edge to the arrow's right edge.
- Up/down-facing units keep the body-center avoidance side rule while using the same arrow visual edge snap.
- Confusion fallback `◎N` remains.
- 김작 F6 visual QA remains for `0-4px` arrow-edge gap, same ally/enemy rule, up/down body-overlap avoidance, confusion `◎N`, and multi-status badge block alignment.
- `v0.68a-fix3 Status Icon Tighten + Confusion Fallback Restore` is complete.
- Tightened battlefield status badge placement further from a `6px` arrow gap to a `2px` arrow gap.
- Restored confusion battlefield badge display from numeric-only `N` to stable `◎N` fallback because the attempted blank-symbol display did not render reliably in Godot.
- Removed the unused `centered_badge_x` local variable warning.
- 김작 F6 visual QA remains for near-attached arrow placement, up/down body-overlap avoidance, confusion `◎N`, shake `⚠N`, first-run stability, and multi-icon horizontal alignment.
- `v0.68a-fix2 Status Icon Tight Arrow Anchor + Confusion Icon Patch` is complete.
- Tightened battlefield status badge placement to a `6px` arrow gap for horizontal facings.
- Changed up/down-facing badge placement to use the nearby arrow side that avoids the unit body center.
- Changed confusion battlefield badge display from `◎N` to turn count only, such as `N`.
- 김작 F6 visual QA remains for tight arrow attachment, up/down body-overlap avoidance, confusion `N`, shake `⚠N`, and multi-icon horizontal alignment.
- `v0.68a-fix1 Status Icon Anchor Consistency Patch` is complete.
- Unified battlefield status badge placement for ally, enemy, support, and reinforce units around the facing arrow's backside.
- Facing rules: right-facing badges left of arrow, left-facing badges right of arrow, up-facing badges below arrow, down-facing badges above arrow.
- Reduced arrow-to-badge separation to a tight `10px` anchor gap while preserving horizontal multi-icon layout.
- 김작 F6 visual QA remains for unit distance, arrow backside placement, face-line fit, and severe overlap checks.
- `v0.68 Agent Contract Split for WorldMap + Hero Scale Prep` is complete.
- Added worldmap, hero data, army deployment, BattleContext, battle engine, and skill system contract docs.
- Defined the future data flow: worldmap / army encounter -> `BattleContext` -> battle engine consumes `BattleContext.roster`.
- Documented that battle type, terrain, region, and `map_variant_id` are decided before battle startup by worldmap / region rules.
- Recorded the next candidates: `v0.68b WorldMap Region Graph MVP`, `v0.68c BattleContext Runtime Injection MVP`, `v0.68d Hero/Army Deployment MVP`, `v0.69 Battlefield Variant Loader`, and `v0.69b Naval Battle Entry MVP`.
- No code, scene, script, or asset changes were made.
- `v0.67z-4 Agent Role Split Foundation` is complete.
- Added role-based agent docs for architecture, implementation, QA, runtime QA, visual QA, and workflow management.
- Kept `CODEX_WORKFLOW_RULES.md` as the canonical source for task classification, autonomous execution, approval handling, and verification depth.
- Kept the current stable baseline at `v0.67z-3 Strategy Status Badge Near Facing Arrow Patch`; no code, scene, or asset changes were made.
- `v0.67z-3 Strategy Status Badge Near Facing Arrow Patch` is complete.
- Battlefield status badges now use the facing indicator line as their placement source instead of a fixed right-side offset.
- Left-facing units place badges to the right of the arrow, right-facing units place badges to the left, and up/down facings choose the near side of the arrow/portrait line.
- 김작 F6 visual QA remains: confirm status badges stay near the arrow for 좌→우 / 우→좌 units and do not fully overlap hero faces.
- `v0.67z-2 Deployment Anchor Source Unification` is complete.
- Runtime deployment markers now sync from scene-authored `Slot` / `UnitVisualRoot` anchors before state creation and marker-to-grid-cell sync.
- `UnitMarker` nodes remain in the scene as compatibility sync targets, while manual layout control should happen through the slot/root visual anchors.
- 김작 F6 visual QA remains: move `Slots/AllyReinforce01Slot` and confirm ROUND 2 김유신 spawn plus HP/troop/portrait/click/facing/status alignment.
- `v0.67z Unit Visual Attachment / Manual Layout Control Patch` is complete.
- Runtime start now syncs unit markers from scene-authored `UnitVisualRoot` global movement, allowing slot/root movement in the Godot 2D editor to become the shared visual anchor.
- Token, portrait, HP bar, troop label, shadow, move dust, click area, READY frame, facing indicator, and status badges now resolve through the slot-synced visual anchor.
- Click areas remain root-level `Area2D` nodes for compatibility, while READY/facing/status overlays remain UI/FX nodes positioned from the same anchor.
- `v0.67y-3 Web Defend Command + Formation Status Layout Guard` is complete.
- Manual defend now shows `◆ 방어!`, recovers `10%` of missing troops, displays green recovery text, and logs the recovery when applicable.
- Defending units show a short `◆ 방어` hit reaction when damaged.
- Formation-guide status text is compacted to a one-line summary with `외 N` overflow, and troop/status layout bounds are guarded against overlap.
- `v0.67y-2-hotfix1 Status Icon Readability Fix` is complete.
- Confusion unit badges now use `◎N` so turn counts never appear as bare numbers.
- Defense `◆` and attack-up `▲` use clearly separated blue / amber tones, and formation troop icons are enlarged to `56 x 56` with stronger troop-type text.
- `v0.67y-2 Web Defend Command Port + Status Icon Tone Polish` is complete.
- Floating panel's former move slot now resolves manual `방어`, while direct move-click remains the movement path.
- Defend stores `is_defending`, consumes the action, displays `◆ 방어 태세`, and reduces incoming damage through the existing directional damage helper.
- Status badge/text alpha was toned down; enemy/auto defense use remains deferred.
- `v0.67y-1-hotfix1 Unified Status Display + Toast Fade Polish` is complete.
- Strategy statuses and unique-skill buffs now share one status display formatter for unit badges and formation-guide status lines.
- Unique-skill attack / defense buffs display with `◆`, while confusion / shake keep icon-style unit badges and readable formation text.
- Defeat-retreat toast hide polish now uses a short `0.18s` fade with a subtle scale/position settle after hold.
- `v0.67y-1 Strategy Status UX + Result Sequence Fix` is complete.
- Defeat-retreat toasts now hold `1.2s` for the first exit and `1.0s` for queued follow-ups, with result toast display deferred until the exit queue finishes.
- Enlarged battlefield strategy status icons, added formation-guide status summaries, and enlarged troop icons to `52 x 52`.
- `동요` now applies a light 공/방 `-10%` effect through damage calculation, and strategy status turns decrease after the affected unit acts or skips.
- Enemy/auto strategy use remains deferred to `v0.67y-2 Strategy AI/Auto Expansion`.
- `v0.67y Web Strategy Port MVP` is complete.
- Enabled the floating `책략` command for eligible manual allies with intelligence-based range, success rate, and outcome tiers.
- Added cyan strategy range/target markers, success/failure resolve, mini-log entries, floating effects, and compact unit/formation `혼란` / `동요` status icons.
- `혼란` now skips affected ally/enemy actions; enemy/auto strategy use remains deferred to `v0.67y-2 Strategy AI/Auto Expansion`.
- `v0.67x-7-hotfix4 Defeat Toast Duration + Size Tune` is complete.
- Defeat-retreat toasts now hold for `1.5s`, keep elapsed logs, and use a smaller panel / portrait / text layout.
- `v0.67x-7-hotfix3 Defeat Toast Actual 3s Hold Fix` is complete.
- Defeat-retreat toast fade-out now starts only after the `3.0s` hold, with DEBUG elapsed logs for SHOW / HOLD_DONE / HIDE.
- `v0.67x-7-hotfix2 Defeat Toast 3s + Hakikjin Range Sync` is complete.
- Ally/enemy battle-exit toasts now hold for `3.0s`, and 학익진 표시/피해 대상 now share the same caster-range target helper.
- `v0.67x-7-hotfix1 Defeat Toast Hold Duration 2s` is complete.
- Ally defeat and enemy retreat toasts now hold for `2.0s`, including sequential queued exits, while the snapshot queue remains non-blocking.
- `v0.67x-7 Defeat Retreat Toast Actual Apply` is complete.
- Ally/enemy battle exits now snapshot portrait / name / side / fallback line before cleanup and play on the visible scene-authored toast layer.
- Ally and enemy toasts use separate dialogue pools, default `1.25s` hold, and `1.05s+` sequential queue playback for simultaneous exits.
- Dead units become untargetable immediately, and full-auto result flow remains stable with the defeat-retreat queue active.
- `v0.67x-7 Enemy Retreat Toast Actual Apply` is complete.
- Enemy defeat now snapshots portrait / name / retreat line before cleanup and plays on a dedicated visible toast layer.
- Simultaneous enemy defeats enqueue sequential retreat toasts while dead units become untargetable immediately.
- Full-auto result flow remains stable with retreat toast queue active.
- `v0.67x-6 Targeting UX + Buff Preview + Retreat Toast Polish` is complete.
- Manual buff unique skills now hide the floating command panel, show range / valid-target preview, then auto-resolve.
- Attack and unique-skill targeting modes hide the floating command panel and restore it after cancel or resolve.
- Valid target gold/orange markers were strengthened while preserving purple range cells.
- Enemy defeat now shows a short portrait retreat toast without blocking cleanup, result toasts, or full-auto flow.
- `v0.67x-5 Unique Skill Regression Fix Gate` is complete.
- Restored formation-guide troop icons to readable `40 x 40` while keeping `UniqueSkillReadyIcon` at `64 x 64`.
- Unified unique skill readiness and auto/enemy value checks around range-limited valid targets.
- Fixed buff unique skill manual resolve/reuse and limited buff effects to valid in-range, unbuffed allies.
- Added separate valid-target markers over purple unique skill range cells and short auto/enemy range previews.
- Confirmed WASAPI warning is external to project battle/audio logic.
- `v0.67x-4 Unique Skill Range + Enemy Skill Priority Rebalance` is complete.
- Restored formation-guide troop icon readability while keeping the `UniqueSkillReadyIcon` at `64 x 64`.
- First-normalized unique skill ranges so melee skills require close range and AOE stays mid-range.
- Reduced enemy/auto unique skill overuse by requiring high-value or fallback-value conditions.
- Restored enemy movement / approach / basic attack pressure in full-auto flow.
- Kept directional damage bonus active with front `1.0`, side `1.15`, back `1.3`.
- Deferred detailed unique skill range balance, `SkillInfoPanel`, and tactics status/explanation UI.
- `v0.67x-2 Enemy/Auto Unique Skill + Directional Damage Bonus` is complete.
- Auto battle can use ally unique skills before normal attack/move/wait fallback.
- Enemy AI can use unique skills on enemy turns and after movement rechecks.
- Directional damage bonus is applied to basic attacks, enemy hits, and single-target attack unique skills.
- Directional multipliers are front `1.0`, side `1.15`, back `1.3`.
- Unique skill readiness now uses cooldown state instead of a one-use flag.
- Formation-guide `UniqueSkillReadyIcon` is enlarged to `64 x 64`.
- Deferred `SkillInfoPanel` and unique skill range balance to later passes.
- `v0.67x-hotfix2 Unique Skill UX Targeting + Backdrop + Ready Icon Fix` is complete.
- Removed the `is_visible` parameter shadowing warning.
- Removed the black rectangular unique skill toast backdrop.
- Kept unique skill hover tooltip text suppressed while keeping button text visible.
- Enlarged the formation-guide unique skill ready icon to `36 x 36`.
- Changed ally manual unique skill flow to button click -> range/target display -> valid target click -> resolve.
- Kept `SkillInfoPanel` deferred as a later UX pass.
- `v0.67x-1 Unique Skill Hover Cleanup + Ready Icon` is complete.
- Removed duplicate hover tooltip text from `FloatingUniqueSkillButton`.
- Added a small formation-guide unique skill ready icon for the currently usable active ally only.
- Kept `SkillInfoPanel` deferred as the next UX candidate.
- No battle logic change intended.
- `v0.67x Unique Skill MVP Per Hero Cutin` is complete.
- Added `10` hero unique skill registry entries for the current test battle roster.
- Linked the `6` new cutin images and existing Yi Sunsin / Jeong Dojeon / Guan Yu / Zhang Fei cutins.
- Enabled ally manual unique skill use from the floating command panel.
- Added a world-anchored ink unique skill toast with `2200ms` timing, cutin image, and skill name text.
- Added large red unique skill damage numbers and short camera shake.
- Enemy / auto unique skill use is deferred to a future pass.
- `v0.67w Battle Screen Basic UX Stable Lock` is complete.
- Locked the current MVP battle-screen UX around:
  - ally formation guide `5` cards
  - enemy formation guide `5` cards
  - lower-left battle mini log
  - bottom command `TextureButton` bar + background panel
  - floating command panel
- Kept legacy large side panels hidden, kept `UnitCloseupPanel` hidden, and kept direct move-click / rollback / post-move reopen / active ally pulse stable.
- Bottom command bar background is considered good enough for MVP and can remain a later polish candidate.
- `v0.67v Bottom Command Bar Background Panel Apply` is complete.
- Applied `bottom_command_bar_bg.png` as the `CommandBar` scene background.
- Hid the old black `CommandBar` panel fill behind a transparent panel style.
- Preserved bottom command `TextureButton` handlers and scene-authored layout.
- `v0.67u-3 Formation Guide Card Compact Info Polish` is complete.
- Hid `UnitCloseupPanel` while keeping it reusable.
- Simplified formation cards and removed status text.
- Added troop icon + troop type label to each formation guide card.
- Reduced formation card font sizes for a tighter strategy UI read.
- Active/reserve distinction now relies on visual style instead of text.
- `v0.67u Formation Slot Guide Layout MVP` is complete.
- `BattleMiniLogPanel` is added.
- `FormationSlotGuideLayer` is added with ally/enemy guide panels.
- Only main `3` + reinforce `2` per side are shown.
- Guide UI is display-only with no click behavior.
- Battle logic is unchanged.
- `v0.67t-hotfix Bottom Command TextureButton Scene Fix` is complete.
- Converted `AutoBattleButton`, `EndTurnButton`, and `RetreatButton` from `Button` to scene-authored `TextureButton`.
- Connected the 6 bottom command PNG assets directly in `Battle_Fullscreen_Test.tscn`.
- Preserved existing handlers.
- `RetreatButton` remains a disabled placeholder.
- `v0.67t Bottom Command Button PNG Apply QA` is complete.
- Applied all 6 bottom command PNG files to the bottom global command bar.
- `AutoBattleButton`, `EndTurnButton`, and `RetreatButton` nodes were preserved.
- Existing handlers were unchanged.
- `RetreatButton` remains a disabled placeholder.
- Text overlay is removed only when button image style applies successfully.
- `v0.67s Bottom Command Button Actual Asset Integration` is complete.
- Added `_try_load_texture_or_null()`.
- Added `_apply_button_texture_style_if_available()`.
- Kept actual PNG loading optional and fallback-safe.
- Kept `AutoBattleButton`, `EndTurnButton`, and `RetreatButton` handlers unchanged.
- `v0.67r Bottom Command Bar Art Asset Structure Prep` is complete.
- Prepared `assets/web_battle/ui/bottom_command/README.md`.
- Prepared optional button-art runtime mapping for `AutoBattleButton`, `EndTurnButton`, and `RetreatButton`.
- Actual PNG files are not required yet; missing files keep existing button behavior with no load error.
- `v0.67k-5 Enemy AI Multi-Target Engagement Reservation Fix` is completed history, not the current active priority.
- Enemy AI multi-target engagement improvement is part of the current stable battle baseline.
- Older detailed history is preserved in:
  - `agent/archive/v0.67-docs_agent_docs_slimdown/CURRENT_STATE_full_before_slimdown.md`
  - `agent/archive/v0.67-docs_agent_docs_slimdown/CHANGELOG_full_before_slimdown.md`
  - `agent/archive/v0.67-docs_agent_docs_slimdown/SESSION_LOG_full_before_slimdown.md`
## v0.68b-12b-28 Player Attack Deployment UX Polish
- Completed polish pass for deployment readability: wider centered panel, clearer source/target header, total deployment troops, remaining garrison, source city troops, and supply status lines.
- Supply status now displays enough/shortage text per food/rice, gold, and salt; confirm blocking reasons are shown next to the sortie button.
- Confirm feedback and player_attack result messages were strengthened.
- F6 manual QA still needed: adjacent enemy city click -> deployment panel open -> hero select/deselect -> SpinBox allocation -> supply shortage block -> sortie -> battle transition -> win/loss owner result -> save/load resource stock.
- Next recommended patch: F6 QA/hotfix for deployment panel interaction and optional actual troop allocation mapping in battle visuals if design approves.

## v0.68b-12b-32 CommandRank CommandLimit Allocation Parity
- Implemented web-parity command rank constants and labels: governor 10000, general 8000, lieutenant 6000, officer 5000.
- Governor rule: a hero matching the city `governor_id` / `governorHeroId` is treated as governor rank for allocation.
- Player attack deployment now displays command limit and caps each SpinBox by command limit plus available source-city deployable troops.
- Confirm validation re-clamps selected allocations by command limit and source reserve before BattleContext handoff.
- Player attack defender allocation and enemy invasion attacker/defender default allocation now use commandLimit distribution instead of raw even split.
- Next recommended patch: F6 QA for commandLimit UI, allocation clamp, player attack win/loss, enemy invasion defense win/loss, and woundedQueue save/load/recovery.

## v0.68b-12b-33D Defense Deployment Panel Parity
- Enemy invasion manual/auto defense buttons now open the shared deployment panel in defense mode before battle handoff.
- Defense candidates come from the defender city stationed player heroes; captured/dead are excluded and wounded remain selectable.
- Defense rows show state badge and commandLimit; SpinBox allocation is capped by commandLimit and defender city deployable troops.
- Defense confirm adds `selected_defender_hero_ids`, selected `defender_troop_allocation`, and `defender_total_allocated_troops` to BattleContext.
- Existing enemy attacker commandLimit auto allocation, pre-decrement, troop outcome, woundedQueue, and result apply flows are retained.
- Cancel keeps the pending invasion event. UX/UI polish and F6 manual QA remain the next work.

## v0.68b-12b-27 Player Attack Deployment UI MVP
- Implemented: player attack button now opens a deployment preparation panel instead of entering battle immediately.
- Rules: deployable heroes come from the selected source city; captured/dead heroes are excluded; wounded heroes remain selectable and display their state badge.
- Troops: at least one hero and positive troop assignment are required; total deployment is capped at source city troops minus 1.
- Supplies: preview and validation use food/rice = troops, gold = ceil(troops * 0.2), salt = ceil(troops * 0.1); payment is taken from the source city's runtime `resource_stock`.
- Persistence: source-city `resource_stock` is included in city runtime save/load overrides.
- Next recommended patch: F6 QA for deployment panel UX, troop allocation edge cases, save/load after supply payment, and player_attack win/loss after deployment.
