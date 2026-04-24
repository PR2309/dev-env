Write-Host "Backing up VS Code Snippets (MERGE MODE)..." -ForegroundColor Cyan

# Go to script directory
$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $baseDir

# Source VS Code snippets folder
$sourceDir = Join-Path $env:APPDATA "Code\User\snippets"

# Destination folder (backup)
$destDir = Join-Path $baseDir "../Data/snippets"

# Check source exists
if (-not (Test-Path $sourceDir)) {
    Write-Error "VS Code snippets folder not found!"
    exit 1
}

# Ensure destination exists
if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}

# 🔥 CHECK IF BACKUP ALREADY HAS FILES
$existingFiles = Get-ChildItem -Path $destDir -Recurse -File -ErrorAction SilentlyContinue

if ($existingFiles.Count -gt 0) {

    Write-Host "`n⚠ Backup already exists in destination!" -ForegroundColor Yellow
    Write-Host "Total existing files: $($existingFiles.Count)`n" -ForegroundColor Yellow

    while ($true) {
        $choice = (Read-Host "Do you want to proceed and MERGE backup? (yes/no)").ToLower()

        if ($choice -in @("yes","y")) {
            break
        }
        elseif ($choice -in @("no","n")) {
            Write-Host "Backup cancelled by user." -ForegroundColor Red
            exit 0
        }
        else {
            Write-Host "Invalid input. Enter yes/y or no/n." -ForegroundColor Red
        }
    }
}

Write-Host "`nUsing MERGE mode (no deletion of old files)" -ForegroundColor Yellow

# Get all snippet files
$files = Get-ChildItem -Path $sourceDir -File -Recurse

$updated = 0
$added = 0

foreach ($file in $files) {

    $relativePath = $file.FullName.Replace($sourceDir, "").TrimStart("\")
    $targetPath = Join-Path $destDir $relativePath

    # Ensure folder exists
    $targetFolder = Split-Path $targetPath -Parent
    if (-not (Test-Path $targetFolder)) {
        New-Item -ItemType Directory -Path $targetFolder -Force | Out-Null
    }

    if (Test-Path $targetPath) {
        Write-Host "↻ Updating: $relativePath"
        $updated++
    }
    else {
        Write-Host "＋ Adding: $relativePath"
        $added++
    }

    Copy-Item -Path $file.FullName -Destination $targetPath -Force
}

Write-Host "`n========================" -ForegroundColor Cyan
Write-Host "Snippets backup completed (MERGE MODE)!" -ForegroundColor Green
Write-Host "Added files      : $added" -ForegroundColor Green
Write-Host "Updated files    : $updated" -ForegroundColor Yellow
Write-Host "Total processed  : $($files.Count)" -ForegroundColor Cyan
Write-Host "========================"