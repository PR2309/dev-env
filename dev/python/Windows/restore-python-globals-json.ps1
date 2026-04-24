Write-Host "Restoring Python packages (from JSON)..." -ForegroundColor Cyan

# Go to script directory (FIXED version)
Set-Location $PSScriptRoot

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

# File path
$jsonPath = Join-Path $PSScriptRoot "../Data/requirements.json"

# Check file exists
if (-not (Test-Path $jsonPath)) {
    Write-Error "requirements.json not found at $jsonPath"
    exit 1
}

# Confirm install
while ($true) {
    $choice = Read-Host "Do you want to install all packages from JSON? (yes/no)"
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

Write-Host "⬆ Upgrading pip, setuptools, wheel..."
python -m pip install --upgrade pip setuptools wheel

# Read JSON
$packages = Get-Content $jsonPath -Raw | ConvertFrom-Json

# Track failures
$failedPackages = @()

foreach ($pkg in $packages) {

    $name = $pkg.name
    $version = $pkg.version

    # Skip invalid entries
    if ([string]::IsNullOrWhiteSpace($name) -or [string]::IsNullOrWhiteSpace($version)) {
        continue
    }

    $fullPkg = "$name==$version"

    Write-Host "Installing $fullPkg ..." -ForegroundColor Cyan

    python -m pip install $fullPkg

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed: $fullPkg" -ForegroundColor Red
        $failedPackages += $fullPkg
    }
}

# Print failed packages
Write-Host "`nFailed Packages:" -ForegroundColor Yellow

if ($failedPackages.Count -eq 0) {
    Write-Host "None" -ForegroundColor Green
} else {
    $failedPackages | ForEach-Object { Write-Host $_ }
}

Write-Host "Python environment restored successfully!" -ForegroundColor Green