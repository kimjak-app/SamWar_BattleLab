param(
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$expectedSourceRoot = "C:\dev\SamWar_web"
$expectedTargetRoot = "C:\dev\SamWar_BattleLab"
$expectedTargetAssetsRoot = Join-Path $expectedTargetRoot "assets\web_battle"
$allowedExtensions = @(".png", ".webp", ".jpg", ".jpeg")

function Get-NormalizedPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return [System.IO.Path]::GetFullPath($Path)
}

function Test-AllowedImageFile {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]$File
    )

    return $allowedExtensions -contains $File.Extension.ToLowerInvariant()
}

function Assert-PathExists {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "$Label does not exist: $Path"
    }
}

function Assert-TargetWithinAssetsRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $normalizedPath = Get-NormalizedPath -Path $Path
    $normalizedAssetsRoot = Get-NormalizedPath -Path $expectedTargetAssetsRoot

    if (-not $normalizedPath.StartsWith($normalizedAssetsRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to copy outside assets\web_battle: $normalizedPath"
    }
}

function Ensure-Directory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    Assert-TargetWithinAssetsRoot -Path $Path

    if (-not (Test-Path -LiteralPath $Path)) {
        if ($DryRun) {
            Write-Host "DRYRUN MKDIR: $Path"
            return
        }

        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function Copy-AssetFileIfNeeded {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]$SourceFile,
        [Parameter(Mandatory = $true)]
        [string]$TargetDirectory,
        [ref]$CopiedCount,
        [ref]$SkippedCount
    )

    if (-not (Test-AllowedImageFile -File $SourceFile)) {
        return
    }

    Assert-TargetWithinAssetsRoot -Path $TargetDirectory
    Ensure-Directory -Path $TargetDirectory

    $targetFilePath = Join-Path $TargetDirectory $SourceFile.Name
    Assert-TargetWithinAssetsRoot -Path $targetFilePath

    $shouldCopy = $true

    if (Test-Path -LiteralPath $targetFilePath) {
        $targetFile = Get-Item -LiteralPath $targetFilePath
        $sameSize = $targetFile.Length -eq $SourceFile.Length
        $sourceNewer = $SourceFile.LastWriteTimeUtc -gt $targetFile.LastWriteTimeUtc

        if ($sameSize -and -not $sourceNewer) {
            $shouldCopy = $false
        }
    }

    if ($shouldCopy) {
        if ($DryRun) {
            Write-Host "DRYRUN COPY: $($SourceFile.FullName) -> $targetFilePath"
            $CopiedCount.Value++
            return
        }

        Copy-Item -LiteralPath $SourceFile.FullName -Destination $targetFilePath -Force
        $CopiedCount.Value++
        return
    }

    if ($DryRun) {
        Write-Host "DRYRUN SKIP: $($SourceFile.FullName) -> $targetFilePath"
    }

    $SkippedCount.Value++
}

function Sync-FolderFiles {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceDirectory,
        [Parameter(Mandatory = $true)]
        [string]$TargetDirectory,
        [ref]$CopiedCount,
        [ref]$SkippedCount,
        [ref]$MissingSourceWarnings
    )

    if (-not (Test-Path -LiteralPath $SourceDirectory)) {
        $MissingSourceWarnings.Value.Add("Missing source directory: $SourceDirectory")
        return
    }

    Get-ChildItem -LiteralPath $SourceDirectory -File | ForEach-Object {
        Copy-AssetFileIfNeeded -SourceFile $_ -TargetDirectory $TargetDirectory -CopiedCount $CopiedCount -SkippedCount $SkippedCount
    }
}

function Sync-PatternFiles {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceDirectory,
        [Parameter(Mandatory = $true)]
        [string]$Pattern,
        [Parameter(Mandatory = $true)]
        [string]$TargetDirectory,
        [Parameter()]
        [string[]]$ExcludeNames = @(),
        [ref]$CopiedCount,
        [ref]$SkippedCount,
        [ref]$MissingSourceWarnings
    )

    if (-not (Test-Path -LiteralPath $SourceDirectory)) {
        $MissingSourceWarnings.Value.Add("Missing source directory: $SourceDirectory")
        return
    }

    Get-ChildItem -LiteralPath $SourceDirectory -File -Filter $Pattern | Where-Object {
        $_.Name -notin $ExcludeNames
    } | ForEach-Object {
        Copy-AssetFileIfNeeded -SourceFile $_ -TargetDirectory $TargetDirectory -CopiedCount $CopiedCount -SkippedCount $SkippedCount
    }
}

$actualSourceRoot = Get-NormalizedPath -Path $expectedSourceRoot
$actualTargetRoot = Get-NormalizedPath -Path $expectedTargetRoot

Assert-PathExists -Path $actualSourceRoot -Label "Expected source root"
Assert-PathExists -Path $actualTargetRoot -Label "Expected target root"
Assert-PathExists -Path (Join-Path $actualSourceRoot "assets") -Label "Expected source assets root"
Assert-PathExists -Path (Join-Path $actualTargetRoot "assets") -Label "Expected target assets root"

$copiedCount = 0
$skippedCount = 0
$missingSourceWarnings = [System.Collections.Generic.List[string]]::new()

Ensure-Directory -Path $expectedTargetAssetsRoot

$folderMappings = @(
    @{
        Source = Join-Path $expectedSourceRoot "assets\battle"
        Target = Join-Path $expectedTargetAssetsRoot "battlefield"
    },
    @{
        Source = Join-Path $expectedSourceRoot "assets\units"
        Target = Join-Path $expectedTargetAssetsRoot "units"
    },
    @{
        Source = Join-Path $expectedSourceRoot "assets\unit_tokens_battlefield"
        Target = Join-Path $expectedTargetAssetsRoot "unit_tokens"
    },
    @{
        Source = Join-Path $expectedSourceRoot "assets\portraits"
        Target = Join-Path $expectedTargetAssetsRoot "portraits"
    },
    @{
        Source = Join-Path $expectedSourceRoot "assets\portraits_battlefield"
        Target = Join-Path $expectedTargetAssetsRoot "portraits_battlefield"
    }
)

foreach ($mapping in $folderMappings) {
    Sync-FolderFiles `
        -SourceDirectory $mapping.Source `
        -TargetDirectory $mapping.Target `
        -CopiedCount ([ref]$copiedCount) `
        -SkippedCount ([ref]$skippedCount) `
        -MissingSourceWarnings ([ref]$missingSourceWarnings)
}

$skillCutinsSource = Join-Path $expectedSourceRoot "assets\skill_cutins"
$resultTarget = Join-Path $expectedTargetAssetsRoot "ui\results"
$cutinsTarget = Join-Path $expectedTargetAssetsRoot "skills\cutins"
$resultPatterns = @("battle_result_*.png", "battle_result_*.webp", "battle_result_*.jpg", "battle_result_*.jpeg")
$resultNames = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

foreach ($pattern in $resultPatterns) {
    if (Test-Path -LiteralPath $skillCutinsSource) {
        Get-ChildItem -LiteralPath $skillCutinsSource -File -Filter $pattern | ForEach-Object {
            $resultNames.Add($_.Name) | Out-Null
            Copy-AssetFileIfNeeded -SourceFile $_ -TargetDirectory $resultTarget -CopiedCount ([ref]$copiedCount) -SkippedCount ([ref]$skippedCount)
        }
    }
}

Sync-PatternFiles `
    -SourceDirectory $skillCutinsSource `
    -Pattern "*" `
    -TargetDirectory $cutinsTarget `
    -ExcludeNames @($resultNames) `
    -CopiedCount ([ref]$copiedCount) `
    -SkippedCount ([ref]$skippedCount) `
    -MissingSourceWarnings ([ref]$missingSourceWarnings)

if ($DryRun) {
    Write-Host "Battle asset sync dry run summary"
    Write-Host "Would copy: $copiedCount"
    Write-Host "Would skip: $skippedCount"
}
else {
    Write-Host "Battle asset sync summary"
    Write-Host "Copied: $copiedCount"
    Write-Host "Skipped: $skippedCount"
}

Write-Host "Missing source warnings: $($missingSourceWarnings.Count)"

if ($missingSourceWarnings.Count -gt 0) {
    $missingSourceWarnings | ForEach-Object {
        Write-Warning $_
    }
}
