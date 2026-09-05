param(
    [string]$SourceRoot = "assets/video_source_test/production_dry_run/worldmap_actions",
    [string]$OutputRoot = "assets/ui/worldmap/videos/actions"
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$SourceDir = Join-Path $RepoRoot $SourceRoot
$OutputDir = Join-Path $RepoRoot $OutputRoot

$Entries = @(
    @{ Source = "worldmap_action_diplomacy_korean_peninsula_source_06s.mp4"; Target = "worldmap_action_diplomacy_korean_peninsula.ogv" },
    @{ Source = "worldmap_action_diplomacy_china_mainland_source_06s.mp4"; Target = "worldmap_action_diplomacy_china_mainland.ogv" },
    @{ Source = "worldmap_action_diplomacy_japan_archipelago_source_06s.mp4"; Target = "worldmap_action_diplomacy_japan_archipelago.ogv" },
    @{ Source = "worldmap_action_trade_source_06s.mp4"; Target = "worldmap_action_trade.ogv" },
    @{ Source = "worldmap_action_spy_source_06s.mp4"; Target = "worldmap_action_spy.ogv" }
)

function Resolve-Tool([string]$LocalRelativePath, [string]$CommandName) {
    $local = Join-Path $RepoRoot $LocalRelativePath
    if (Test-Path $local) { return $local }
    $command = Get-Command $CommandName -ErrorAction SilentlyContinue
    if ($null -ne $command) { return $command.Source }
    throw "Missing $CommandName. Expected repo-local $LocalRelativePath or $CommandName in PATH."
}

$ffmpeg = Resolve-Tool "tools/ffmpeg/bin/ffmpeg.exe" "ffmpeg"
$ffprobe = Resolve-Tool "tools/ffmpeg/bin/ffprobe.exe" "ffprobe"
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

foreach ($entry in $Entries) {
    $source = Join-Path $SourceDir $entry.Source
    $target = Join-Path $OutputDir $entry.Target
    if (-not (Test-Path $source)) { throw "Missing source video: $source" }

    & $ffmpeg -hide_banner -loglevel error -y `
        -i $source `
        -map 0:v:0 -map 0:a:0? `
        -vf "fps=30,scale=1280:720:force_original_aspect_ratio=decrease:flags=lanczos,pad=1280:720:(ow-iw)/2:(oh-ih)/2:black,format=yuv420p" `
        -c:v libtheora -q:v 8 -g 60 `
        -c:a libvorbis -q:a 4 `
        $target
    if ($LASTEXITCODE -ne 0) { throw "FFmpeg conversion failed: $source" }

    $probe = & $ffprobe -v error -show_entries stream=codec_name,codec_type,width,height,pix_fmt -show_entries format=duration -of default=noprint_wrappers=1 -- $target
    if ($LASTEXITCODE -ne 0) { throw "FFprobe validation failed: $target" }
    Write-Host "[WorldMapActionVideo] PASS $($entry.Target)"
    Write-Host $probe
}

Write-Host "[WorldMapActionVideo] COMPLETE: 5 Godot-safe Theora/Vorbis OGV files."
