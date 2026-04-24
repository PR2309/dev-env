Write-Host "Restoring Node Version..." -ForegroundColor Cyan

# Go to script directory
# Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $PSScriptRoot

# Check Node
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Error "Node.js is not installed."
    exit 1
}

# Check NVM
if (-not (Get-Command nvm -ErrorAction SilentlyContinue)) {
    Write-Error "NVM is not installed. Install NVM first."
    exit 1
}

# Read target version
# $nodeVersionFile = "../Data/node-version.txt"
$nodeVersionFile = Join-Path $PSScriptRoot "../Data/node-version.txt"

if (-not (Test-Path $nodeVersionFile)) {
    Write-Error "node-version.txt not found at $nodeVersionFile"
    exit 1
}

# Trim the version string to remove any whitespace
$targetVersion = (Get-Content $nodeVersionFile).Trim() -replace '^v', '' # Remove leading 'v' if present

# Get current version
$currentVersion = (node -v).Trim() -replace '^v', '' # Remove leading 'v' if present

Write-Host "Current Node Version: $currentVersion" -ForegroundColor Yellow
Write-Host "Target Node Version : v$targetVersion" -ForegroundColor Yellow

# Skip if already same version
if ($currentVersion -eq $targetVersion) {
    Write-Host "Node.js is already at version $targetVersion. No action needed." -ForegroundColor Cyan
    exit
}

# Confirm overwrite if file exists
while ($true) {
    $choice = Read-Host "Do you want to proceed? (yes/no)"
    $choice = $choice.ToLower()

    if ($choice -eq "yes" -or $choice -eq "y") {
        break
    } elseif ($choice -eq "no" -or $choice -eq "n") {
        Write-Host "Cancelled." -ForegroundColor Yellow
        exit
    } else {
        Write-Host "Invalid input. Enter yes/y or no/n." -ForegroundColor Red
    }
}

# Install & use Node version
Write-Host "Installing Node $targetVersion..."
nvm install $targetVersion
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to install Node.js version $targetVersion."
    exit 1
}

# Switch to the installed version
Write-Host "Switching to Node $targetVersion..."
nvm use $targetVersion
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to switch to Node.js version $targetVersion."
    exit 1
}

Write-Host "Node version restored successfully!" -ForegroundColor Green
Write-Host "Current Node Version: $currentVersion -> $(node -v)" -ForegroundColor Green