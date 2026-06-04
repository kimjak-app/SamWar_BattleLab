# Theora Safe Encoding Test Output

This folder is reserved for Godot VideoStreamPlayer test output only.

Generated files:
- `test_safe_q7_1280x.ogv`
- `test_safe_q8_1920x.ogv`

Source:
- `assets/video_source_test/cutin_test_01.mp4`

FFmpeg:
- Portable local executable: `tools/ffmpeg/bin/ffmpeg.exe`
- Version: `8.1.1-essentials_build-www.gyan.dev`

Recommended safe preset:
- `test_safe_q7_1280x.ogv`
- Reason: Godot loads it as `VideoStreamTheora`, playback starts, color is visually normal in captured Godot frames, and file size is lower than q8.

Verification summary:
- q7: Theora, 1280x720, yuv420p, 30fps, Vorbis audio, Godot playback OK.
- q8: Theora, 1920x1080, yuv420p, 30fps, Vorbis audio, Godot playback OK but larger/heavier.
- No noaudio fallback was needed.

Do not replace production cutin assets from this folder until Godot playback and color are visually confirmed.
