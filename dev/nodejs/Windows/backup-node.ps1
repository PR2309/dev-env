Write-Host "Backing up current Node Version..." -ForegroundColor Cyan

# Go to script directory
Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)

# Check Node
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Error "Node.js is not installed."
    exit 1
}

# Read target version
$nodeVersionFile = "../Data/node-version.txt"

# Get current Node version
$currentVersion = (node -v).Trim()

# ENSURE DIRECTORY EXISTS
$dir = Split-Path $nodeVersionFile -Parent
if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir | Out-Null
}

# Check if backup file exists
if (Test-Path $nodeVersionFile) {

    $existingVersion = (Get-Content $nodeVersionFile -ErrorAction SilentlyContinue).Trim()

    Write-Host "`n⚠ Backup file already exists!" -ForegroundColor Yellow
    Write-Host "Existing saved version : $existingVersion" -ForegroundColor Yellow
    Write-Host "New version to save    : $currentVersion`n" -ForegroundColor Cyan

    # Skip if already same version
    if ($currentVersion -eq $existingVersion) {
        Write-Host "Node is already at version $existingVersion. No action needed." -ForegroundColor Cyan
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
# Set-Content -Path $nodeVersionFile -Value $cleanVersion

# Storing Current Node version
Write-Host "Storing current Node $currentVersion..." -ForegroundColor Cyan
node -v > $nodeVersionFile
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to save Node.js version backup."
    exit 1
}

Write-Host "Node version stored successfully!" -ForegroundColor Green
Write-Host "Saved version: $currentVersion" -ForegroundColor Green