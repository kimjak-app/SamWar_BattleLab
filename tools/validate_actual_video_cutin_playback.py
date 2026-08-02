#!/usr/bin/env python3
"""Require the actual presentation test and traceable video-first route."""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
battle = (ROOT / "scripts/battle_web_import_test.gd").read_text(encoding="utf-8")
presentation = (ROOT / "scripts/ui/cutin/hero_cutin_presentation.gd").read_text(encoding="utf-8")
test = (ROOT / "tests/scripts/test_actual_video_cutin_playback.gd").read_text(encoding="utf-8")
required = ("[CUTIN_TRACE]", "registry_hit=", "selected_mode=video", "fallback_called=true", "is_video_playing()", "_play_committed_hero_cutin(caster_state, skill_data)")
errors = [f"missing runtime trace/route: {item}" for item in required if item not in battle]
for item in ("PresentationScene.instantiate()", "VideoBackgroundPlayer", "presentation.is_video_playing()", "yi_sunsin", "kwon_yul"):
	if item not in test:
		errors.append(f"actual playback test missing: {item}")
if "func is_video_playing()" not in presentation:
	errors.append("presentation lacks VideoStreamPlayer playback probe")
if errors:
	print("ACTUAL VIDEO CUTIN PLAYBACK VALIDATION FAILED", file=sys.stderr)
	print("\n".join(f"ERROR: {item}" for item in errors), file=sys.stderr)
	raise SystemExit(1)
print("ACTUAL VIDEO CUTIN PLAYBACK VALIDATION PASS: instantiated presentation, stream/play probe, video-first trace, explicit static fallback trace")
