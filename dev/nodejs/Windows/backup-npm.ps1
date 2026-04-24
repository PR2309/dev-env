Write-Host "Backing up current NPM Version..." -ForegroundColor Cyan

# Go to script directory
Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)

# Check Node
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Error "Node.js is not installed."
    exit 1
}

# Read target version
$npmVersionFile = "../Data/npm-version.txt"

# Get current NPM version
$currentVersion = (npm -v).Trim()

# ENSURE DIRECTORY EXISTS
$dir = Split-Path $npmVersionFile -Parent
if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir | Out-Null
}

# Check if backup file exists
if (Test-Path $npmVersionFile) {

    $existingVersion = (Get-Content $npmVersionFile -ErrorAction SilentlyContinue).Trim()

    Write-Host "`n⚠ Backup file already exists!" -ForegroundColor Yellow
    Write-Host "Existing saved version : $existingVersion" -ForegroundColor Yellow
    Write-Host "New version to save    : $currentVersion`n" -ForegroundColor Cyan

    # Skip if already same version
    if ($currentVersion -eq $existingVersion) {
        Write-Host "NPM is already at version $existingVersion. No action needed." -ForegroundColor Cyan
        exit
    }

    while($true){
        $choice = Read-Host "Do you want to overwrite it? (yes/no)"
        $choice = $choice.ToLower()

        if ($choice -eq "yes" -or $choice -eq "y") {
            break
        } elseif ($choice -eq "no" -or $choice -eq "n") {
            Write-Host "Cancelled." -ForegroundColor Yellow
            exit
        } else {
            Write-Host "Invalid input. Please enter 'yes/y' or 'no/n'." -ForegroundColor Red
        }
    }
}

# Getting current version number (remove 'v')
# $cleanVersion = $currentVersion -replace "^v", ""
# Save version
# Set-Content -Path $npmVersionFile -Value $cleanVersion

# Storing Current NPM version
Write-Host "Storing current NPM $currentVersion..." -ForegroundColor Cyan
npm -v > $npmVersionFile
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to save npm version backup."
    exit 1
}

Write-Host "NPM version stored successfully!" -ForegroundColor Green
Write-Host "Saved version: $currentVersion" -ForegroundColor Green