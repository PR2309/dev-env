Write-Host "Backing up VS Code Settings..." -ForegroundColor Cyan

# Go to script directory
$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $baseDir

# VS Code settings source path
$sourceFile = Join-Path $env:APPDATA "Code\User\settings.json"

# Destination path
$DataRoot = Join-Path $baseDir "../Data"
$destFile = Join-Path $DataRoot "settings.json"

# Check if settings exist
if (-not (Test-Path $sourceFile)) {
    Write-Error "VS Code settings.json not found."
    exit 1
}

# Ensure Data directory exists
if (-not (Test-Path $DataRoot)) {
    New-Item -ItemType Directory -Path $DataRoot | Out-Null
}

# Check if backup already exists
if (Test-Path $destFile) {

    Write-Host "`n⚠ Backup file already exists!" -ForegroundColor Yellow
    Write-Host "Existing file: $destFile`n" -ForegroundColor Yellow

    while ($true) {
        $choice = Read-Host "Do you want to overwrite it? (yes/no)"
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

# Copy settings
try {
    Copy-Item -Path $sourceFile -Destination $destFile -Force

    Write-Host "`nVS Code settings backup completed!" -ForegroundColor Green
    Write-Host "Saved to: $destFile" -ForegroundColor Green
}
catch {
    Write-Error "Failed to backup settings. Error: $_"
    exit 1
}