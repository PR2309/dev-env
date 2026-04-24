Write-Host "Restoring VS Code Snippets (MERGE MODE)..." -ForegroundColor Cyan

# Go to script directory
$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $baseDir

# Source backup folder
$sourceDir = Join-Path $baseDir "../Data/snippets"

# Target VS Code snippets folder
$targetDir = Join-Path $env:APPDATA "Code\User\snippets"

# Check backup exists
if (-not (Test-Path $sourceDir)) {
    Write-Error "Snippets backup folder not found!"
    exit 1
}

# Ensure target exists
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

Write-Host "`nUsing MERGE mode (no deletion of existing files)" -ForegroundColor Yellow

$success = 0
$updated = 0

# Get all backup files
$files = Get-ChildItem -Path $sourceDir -File -Recurse

foreach ($file in $files) {

    $relativePath = $file.FullName.Replace($sourceDir, "").TrimStart("\")
    $targetPath = Join-Path $targetDir $relativePath

    # Ensure subdirectory exists
    $parentDir = Split-Path $targetPath -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    if (Test-Path $targetPath) {
        Write-Host "↻ Updating: $relativePath"
        $updated++
    }
    else {
        Write-Host "＋ Adding: $relativePath"
        $success++
    }

    # Copy file (overwrite or create)
    Copy-Item -Path $file.FullName -Destination $targetPath -Force
}

Write-Host "`n========================" -ForegroundColor Cyan
Write-Host "Snippets restore completed (MERGE MODE)!" -ForegroundColor Green
Write-Host "New files added   : $success" -ForegroundColor Green
Write-Host "Files updated     : $updated" -ForegroundColor Yellow
Write-Host "Total processed   : $($files.Count)" -ForegroundColor Cyan
Write-Host "========================"