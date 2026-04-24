Write-Host "Backing up Python packages..." -ForegroundColor Cyan

# Go to script directory
Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)

# Check Python
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Error "Python not found. Install Python first."
    exit 1
}

# Check pip
if (-not (Get-Command pip -ErrorAction SilentlyContinue)) {
    Write-Error "pip not found. Fix Python installation."
    exit 1
}


Write-Host "Storing Python packages..."

# File paths
$textFile = "../Data/requirements.txt"
$jsonFile = "../Data/requirements.json"

# Ensure directory exists
$dir = Split-Path $textFile -Parent
if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir | Out-Null
}

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

Write-Host "⬆ Upgrading pip, setuptools, wheel..."
python -m pip install --upgrade pip setuptools wheel

# Save standard requirements.txt
pip freeze > $textFile

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to save requirements.txt"
    exit 1
}

# Save JSON format
pip list --format=json | Out-File $jsonFile -Encoding utf8

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to save requirements.json"
    exit 1
}

Write-Host "Python environment backed up successfully!" -ForegroundColor Green
Write-Host "Saved files:"
Write-Host " - $textFile"
Write-Host " - $jsonFile"