Write-Host "Backing up Composer Version..." -ForegroundColor Cyan

# Go to script directory
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

# Ensure Data directory exists
$dataDir = Join-Path $PSScriptRoot "../Data"
if (-not (Test-Path $dataDir)) {
    New-Item -ItemType Directory -Path $dataDir | Out-Null
}

# File path
$composerFile = Join-Path $dataDir "composer-version.txt"

# Get current version safely
try {
    $output = composer --version

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to get Composer version"
    }

    if ($output -match "Composer version ([0-9\.]+)") {
        $currentVersion = $Matches[1]
    } else {
        throw "Unable to parse Composer version"
    }
}
catch {
    Write-Error $_
    exit 1
}

# If file exists → compare
if (Test-Path $composerFile) {
    $existingVersion = (Get-Content $composerFile -ErrorAction Stop).Trim()

    Write-Host ""
    Write-Host "⚠ Backup file already exists!" -ForegroundColor Yellow
    Write-Host "Existing saved version : $existingVersion" -ForegroundColor Yellow
    Write-Host "New version to save    : $currentVersion" -ForegroundColor Cyan
    Write-Host ""

    # Skip if same
    if ($currentVersion -eq $existingVersion) {
        Write-Host "Composer is already at version $existingVersion. No action needed." -ForegroundColor Cyan
        exit 0
    }

    # Ask overwrite
    while ($true) {
        $choice = Read-Host "Overwrite existing version? (yes/no)"
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
}

# Save version
try {
    $currentVersion | Out-File $composerFile -Encoding utf8

    if (-not (Test-Path $composerFile)) {
        throw "File write failed"
    }
}
catch {
    Write-Error "Failed to save Composer version."
    exit 1
}

Write-Host "Composer version backed up successfully!" -ForegroundColor Green
Write-Host "Saved version: $currentVersion"