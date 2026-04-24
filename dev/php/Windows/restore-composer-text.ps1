Write-Host "Restoring Composer global packages (from TEXT)..." -ForegroundColor Cyan

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

Write-Host "⬆ Updating Composer..."
composer self-update
if ($LASTEXITCODE -ne 0) {
    Write-Error "Composer update failed."
    exit 1
}

# File path
$textFile = Join-Path $PSScriptRoot "../Data/global-composer-packages.txt"

# Check file exists
if (-not (Test-Path $textFile)) {
    Write-Error "global-composer-packages.txt not found at $textFile"
    exit 1
}

$failed = @()

# Read file line by line
$lines = Get-Content $textFile

foreach ($line in $lines) {

    # Skip empty lines
    if ([string]::IsNullOrWhiteSpace($line)) { continue }

    # Split columns (name + version)
    $parts = $line -split "\s+"

    $name = $parts[0]
    $version = $null

    if ($parts.Count -ge 2) {
        $version = $parts[1]
    }

    # Skip invalid lines (must contain vendor/package)
    if (-not ($name -match "/")) { continue }

    # Clean version (remove 'v')
    if ($version) {
        $version = $version -replace "^v", ""
        $fullPkg = "$name`:$version"
    } else {
        $fullPkg = $name
    }

    Write-Host "➡ Installing $fullPkg" -ForegroundColor Cyan

    composer global require $fullPkg

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed: $fullPkg" -ForegroundColor Red
        $failed += $fullPkg
    }
}

if ($failed.Count -ne 0) {
    Write-Host "`nFailed Packages:" -ForegroundColor Yellow
    $failed | ForEach-Object { Write-Host $_ }
}

Write-Host "Composer global packages restored successfully!" -ForegroundColor Green