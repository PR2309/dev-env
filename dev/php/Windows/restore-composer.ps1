Write-Host "Restoring Composer Version..." -ForegroundColor Cyan

# Go to script directory (safe)
Set-Location $PSScriptRoot

# Check PHP
if (-not (Get-Command php -ErrorAction SilentlyContinue)) {
    Write-Error "PHP not found. Install PHP first."
    exit 1
}

# Check Composer
if (-not (Get-Command composer -ErrorAction SilentlyContinue)) {
    Write-Error "Composer not found. Install Composer first."
    exit 1
}

# File path
$dataDir = Join-Path $PSScriptRoot "../Data"
$composerFile = Join-Path $dataDir "composer-version.txt"

# Check file exists
if (-not (Test-Path $composerFile)) {
    Write-Error "Backup file not found: $composerFile"
    exit 1
}

# Get stored version safely
$storedVersion = (Get-Content $composerFile -ErrorAction Stop).Trim()

# Get current version safely
try {
    $versionOutput = composer --version
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to get Composer version"
    }

    # Extract version (robust)
    if ($versionOutput -match "Composer version ([0-9\.]+)") {
        $currentVersion = $Matches[1]
    } else {
        throw "Unable to parse Composer version"
    }
}
catch {
    Write-Error $_
    exit 1
}

Write-Host ""
Write-Host "Current Composer version : $currentVersion"
Write-Host "Stored Composer version  : $storedVersion"
Write-Host ""

# Skip if same
if ($currentVersion -eq $storedVersion) {
    Write-Host "Composer is already at version $storedVersion. No action needed." -ForegroundColor Cyan
    exit 0
}

# Confirm switch
while ($true) {
    $choice = Read-Host "Switch Composer version? (yes/no)"
    $choice = $choice.ToLower()

    if ($choice -eq "yes" -or $choice -eq "y") {
        break
    } elseif ($choice -eq "no" -or $choice -eq "n") {
        Write-Host "Cancelled." -ForegroundColor Yellow
        exit 0
    } else {
        Write-Host "Invalid input. Enter yes/y or no/n." -ForegroundColor Red
    }
}

Write-Host "Switching Composer to version $storedVersion..." -ForegroundColor Cyan

# Run update safely
try {
    composer self-update $storedVersion --no-interaction

    if ($LASTEXITCODE -ne 0) {
        throw "Composer self-update failed"
    }
}
catch {
    Write-Error $_
    exit 1
}

# Verify new version
try {
    $newOutput = composer --version
    if ($newOutput -match "Composer version ([0-9\.]+)") {
        $newVersion = $Matches[1]
    } else {
        throw "Unable to verify Composer version"
    }
}
catch {
    Write-Error $_
    exit 1
}

Write-Host "Composer version restored successfully!" -ForegroundColor Green
Write-Host "Current version: $newVersion"