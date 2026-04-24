Write-Host "Restoring VS Code Settings..." -ForegroundColor Cyan

# Go to script directory
$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $baseDir

# Source backup file
$sourceFile = Join-Path $baseDir "../Data/settings.json"

# Target VS Code settings path
$targetFile = Join-Path $env:APPDATA "Code\User\settings.json"

# Check backup exists
if (-not (Test-Path $sourceFile)) {
    Write-Error "Backup settings.json not found!"
    exit 1
}

# Ensure target directory exists
$targetDir = Split-Path $targetFile -Parent
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir | Out-Null
}

# Check existing settings
if (Test-Path $targetFile) {

    Write-Host "`n⚠ Existing VS Code settings detected!" -ForegroundColor Yellow
    Write-Host "This will overwrite your current settings.`n" -ForegroundColor Yellow

    while ($true) {
        $choice = Read-Host "Do you want to overwrite? (yes/no)"
        $choice = $choice.ToLower()

        if ($choice -eq "yes" -or $choice -eq "y") {
            break
        }
        elseif ($choice -eq "no" -or $choice -eq "n") {
            Write-Host "Cancelled." -ForegroundColor Yellow
            exit 0
        }
        else {
            Write-Host "Invalid input. Please enter 'yes/y' or 'no/n'." -ForegroundColor Red
        }
    }
}

# Restore settings
try {
    Copy-Item -Path $sourceFile -Destination $targetFile -Force

    Write-Host "`nVS Code settings restored successfully!" -ForegroundColor Green
    Write-Host "Restored to: $targetFile" -ForegroundColor Green
}
catch {
    Write-Error "Failed to restore settings. Error: $_"
    exit 1
}