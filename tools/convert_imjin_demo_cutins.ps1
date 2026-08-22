param(
    [string]$RegistryPath = "data/cutin/imjin_demo_hero_cutins.json"
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$RegistryFullPath = Join-Path $RepoRoot $RegistryPath

function Resolve-RepoPath([string]$PathValue) {
    $relative = $PathValue
    if ($relative.StartsWith("res://")) {
        $relative = $relative.Substring(6)
    }
    return Join-Path $RepoRoot ($relative -replace '/', [IO.Path]::DirectorySeparatorChar)
}

function Resolve-Tool([string]$LocalRelativePath, [string]$CommandName) {
    $local = Join-Path $RepoRoot $LocalRelativePath
    if (Test-Path $local) {
        return $local
    }
    $command = Get-Command $CommandName -ErrorAction SilentlyContinue
    if ($null -ne $command) {
        return $command.Source
    }
    throw "Missing $CommandName. Expected repo-local $LocalRelativePath or $CommandName in PATH."
}

function Invoke-FFprobeJson([string]$ProbeExe, [string]$FilePath) {
    $raw = & $ProbeExe -v error -select_streams v:0 `
        -show_entries stream=codec_name,width,height,pix_fmt,avg_frame_rate `
        -show_entries format=duration -of json -- $FilePath
    if ($LASTEXITCODE -ne 0) {
        throw "ffprobe failed: $FilePath"
    }
    return ($raw | Out-String | ConvertFrom-Json)
}

if (-not (Test-Path $RegistryFullPath)) {
    throw "Missing D5 registry: $RegistryFullPath"
}

$ffmpeg = Resolve-Tool "tools/ffmpeg/bin/ffmpeg.exe" "ffmpeg"
$ffprobe = Resolve-Tool "tools/ffmpeg/bin/ffprobe.exe" "ffprobe"
$registry = Get-Content -Raw -Encoding UTF8 $RegistryFullPath | ConvertFrom-Json
$entries = @($registry.entries | Where-Object { $_.enabled -eq $true })

if ($entries.Count -ne 8) {
    throw "D5 expects exactly 8 enabled Imjin demo cutins, found $($entries.Count)."
}

Write-Host "[D5-1] FFmpeg: $ffmpeg"
Write-Host "[D5-1] FFprobe: $ffprobe"
Write-Host "[D5-1] Converting $($entries.Count) MP4 sources to Godot-safe Theora OGV..."

foreach ($entry in $entries) {
    $source = Resolve-RepoPath ([string]$entry.source_path)
    $target = Resolve-RepoPath ([string]$entry.video_path)

    if (-not (Test-Path $source)) {
        throw "Missing source MP4 for $($entry.hero_id): $source"
    }

    $sourceProbe = Invoke-FFprobeJson $ffprobe $source
    $sourceStream = $sourceProbe.streams[0]
    $sourceDuration = [double]$sourceProbe.format.duration
    $sourceWidth = [int]$sourceStream.width
    $sourceHeight = [int]$sourceStream.height
    if ($sourceWidth -le 0 -or $sourceHeight -le 0) {
        throw "Invalid source dimensions for $($entry.hero_id): ${sourceWidth}x${sourceHeight}"
    }
    $aspect = [double]$sourceWidth / [double]$sourceHeight
    $targetAspect = 16.0 / 9.0
    if ([Math]::Abs($aspect - $targetAspect) -gt 0.03) {
        throw "Source is not close to 16:9 for $($entry.hero_id): ${sourceWidth}x${sourceHeight}"
    }
    if ($sourceDuration -lt 3.90 -or $sourceDuration -gt 4.20) {
        throw "Source duration outside D5 cutin window for $($entry.hero_id): $sourceDuration sec"
    }

    $targetDir = Split-Path -Parent $target
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

    Write-Host ("[D5-1] {0}: {1}x{2}, {3:N3}s -> {4}" -f $entry.hero_id, $sourceWidth, $sourceHeight, $sourceDuration, $target)

    & $ffmpeg -hide_banner -loglevel error -y `
        -i $source `
        -map 0:v:0 `
        -t 4.01 `
        -vf "fps=30,scale=1280:720:flags=lanczos,format=yuv420p" `
        -c:v libtheora `
        -q:v 8 `
        -g 60 `
        -an `
        $target

    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $target)) {
        throw "FFmpeg conversion failed for $($entry.hero_id)."
    }

    $targetProbe = Invoke-FFprobeJson $ffprobe $target
    $targetStream = $targetProbe.streams[0]
    $targetDuration = [double]$targetProbe.format.duration

    if ([string]$targetStream.codec_name -ne "theora") {
        throw "Unexpected codec for $($entry.hero_id): $($targetStream.codec_name)"
    }
    if ([int]$targetStream.width -ne 1280 -or [int]$targetStream.height -ne 720) {
        throw "Unexpected output size for $($entry.hero_id): $($targetStream.width)x$($targetStream.height)"
    }
    if ([string]$targetStream.pix_fmt -ne "yuv420p") {
        throw "Unexpected pixel format for $($entry.hero_id): $($targetStream.pix_fmt)"
    }
    if ($targetDuration -lt 3.90 -or $targetDuration -gt 4.10) {
        throw "Unexpected output duration for $($entry.hero_id): $targetDuration sec"
    }

    $sizeBytes = (Get-Item $target).Length
    Write-Host ("[D5-1] PASS {0}: theora 1280x720 yuv420p 30fps duration={1:N3}s bytes={2}" -f $entry.hero_id, $targetDuration, $sizeBytes)
}

Write-Host "[D5-1] COMPLETE: 8 Imjin demo cutins encoded with the existing Godot Theora pipeline."
Write-Host "[D5-1] Next: python tools/validate_imjin_demo_cutins.py --video-only"
