Write-Host "Restoring NPM Version..." -ForegroundColor Cyan

# Go to script directory
# Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $PSScriptRoot

# Check Node
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Error "Node.js is not installed."
    exit 1
}

# Check NPM
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Error "NPM is not installed. Install NPM first."
    exit 1
}

# Read target version
$npmVersionFile = Join-Path $PSScriptRoot "../Data/npm-version.txt"

# Check file exists
if (-not (Test-Path $npmVersionFile)) {
    Write-Host "npm-version.txt not found. Exiting..." -ForegroundColor Red
    exit 1
}

# Get current & Stored NPM version
$currentVersion = (npm -v).Trim()
$targetVersion = (Get-Content $npmVersionFile).Trim()

# Validate version format (basic check)
if (-not ($targetVersion -match '^\d+\.\d+\.\d+([\-+].*)?$')) {
    Write-Error "Invalid version format in npm-version.txt"
    exit 1
}

Write-Host "Current NPM Version: $currentVersion" -ForegroundColor Yellow
Write-Host "Target NPM Version : $targetVersion" -ForegroundColor Yellow

# Skip if already same version
if ($currentVersion -eq $targetVersion) {
    Write-Host "NPM is already at version $targetVersion. No action needed." -ForegroundColor Cyan
    exit
}

# Confirm overwrite if file exists
while ($true) {
    $choice = Read-Host "Do you want to proceed? (yes/no)"
    $choice = $choice.ToLower()

    if ($choice -eq "yes" -or $choice -eq "y") {
        # $npmVersion = Get-Content $npmVersionFile

        #Installation command
        npm install -g "npm@$targetVersion" --verbose

        # Check if installation succeeded
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed to install npm@$targetVersion" -ForegroundColor Red
            exit 1
        }

        Write-Host "Restoring global NPM Version successfully!" -ForegroundColor Green

        break
    } elseif ($choice -eq "no" -or $choice -eq "n") {
        Write-Host "Cancelled." -ForegroundColor Yellow
        exit
    } else {
        Write-Host "Invalid input. Enter yes/y or no/n." -ForegroundColor Red
    }
}

Write-Host "Current NPM Version: $currentVersion -> $(npm -v)" -ForegroundColor Green