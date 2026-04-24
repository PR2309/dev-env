Write-Host "Backing up PHP Composer packages..." -ForegroundColor Cyan

# Go to script directory (reliable)
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

Write-Host "⬆ Upgrading Composer..."
composer self-update
if ($LASTEXITCODE -ne 0) {
    Write-Error "Composer update failed."
    exit 1
}

# File paths (safe)
$dataDir = Join-Path $PSScriptRoot "../Data"
$textFile = Join-Path $dataDir "global-composer-packages.txt"
$jsonFile = Join-Path $dataDir "global-packages.json"

# Ensure Data directory exists
if (-not (Test-Path $dataDir)) {
    New-Item -ItemType Directory -Path $dataDir | Out-Null
}

Write-Host "Storing PHP Composer packages..."

# Ask once if any file exists
if ((Test-Path $textFile) -or (Test-Path $jsonFile)) {
    while ($true) {
        $choice = Read-Host "Backup files exist. Overwrite? (yes/no)"
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
}

# Use temp files to avoid corruption
$tempTxt = [System.IO.Path]::GetTempFileName()
$tempJson = [System.IO.Path]::GetTempFileName()

# Generate backups
composer global show > $tempTxt
if ($LASTEXITCODE -ne 0) {
    Remove-Item $tempTxt -ErrorAction SilentlyContinue
    Remove-Item $tempJson -ErrorAction SilentlyContinue
    Write-Error "Failed to fetch Composer packages (text)."
    exit 1
}

composer global show --format=json > $tempJson
if ($LASTEXITCODE -ne 0) {
    Remove-Item $tempTxt -ErrorAction SilentlyContinue
    Remove-Item $tempJson -ErrorAction SilentlyContinue
    Write-Error "Failed to fetch Composer packages (JSON)."
    exit 1
}

# Move temp files to final location (atomic replace)
Move-Item -Force $tempTxt $textFile
Move-Item -Force $tempJson $jsonFile

Write-Host "PHP Composer environment backed up successfully!" -ForegroundColor Green
Write-Host "Saved files:"
Write-Host " - $textFile"
Write-Host " - $jsonFile"