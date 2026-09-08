# SamWar original SFX

21 deterministic synthesized effects generated for this project; no downloaded recordings or third-party samples. These are a first sound-design pass, not recordings of historical weapons or instruments. Source: `tools/generate_samwar_sfx.py` (Python standard library). 44.1 kHz mono 16-bit PCM WAV, no loops, short fades, peak approximately -2.85 dBFS. Regeneration produces identical files.

Runtime registration: `scripts/audio/game_audio.gd`. Explicit preload references include files in exported builds. Replace WAV files under the same names to retain event wiring. Open `tests/scenes/SFX_Preview.tscn` with F6 for individual audition and persistent volume/mute controls. The worldmap top System menu controls SFX enabled/volume/duplicate suppression and video enabled/volume. Video audio defaults OFF but can be enabled globally.
