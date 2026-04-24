Write-Host "Restoring Composer global packages (from JSON)..." -ForegroundColor Cyan

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
$jsonFile = Join-Path $PSScriptRoot "../Data/global-packages.json"

# Check file exists
if (-not (Test-Path $jsonFile)) {
    Write-Error "global-packages.json not found at $jsonFile"
    exit 1
}

# Read JSON safely
try {
    $json = Get-Content $jsonFile -Raw | ConvertFrom-Json
}
catch {
    Write-Error "Failed to parse JSON file."
    exit 1
}

# Composer JSON structure → installed[]
$packages = $json.installed

if (-not $packages) {
    Write-Error "No packages found in JSON."
    exit 1
}

$failed = @()

foreach ($pkg in $packages) {

    $name = $pkg.name
    $version = $pkg.version

    # Skip invalid entries
    if (-not $name -or -not $version) { continue }

    # Remove 'v' prefix
    $version = $version -replace "^v", ""

    $fullPkg = "$name`:$version"

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