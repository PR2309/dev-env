Write-Host "Backing up current NPM Packages..." -ForegroundColor Cyan

# Go to script directory
Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)

# Check Node
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Error "Node.js is not installed."
    exit 1
}

# File paths
$pkgVersionFileJson = "../Data/global-packages.json"
$pkgVersionFileText = "../Data/global-npm-packages.txt"

# ENSURE DIRECTORY EXISTS
$dir = Split-Path $pkgVersionFileJson -Parent
if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir | Out-Null
}

# Check if backup already exists
if ((Test-Path $pkgVersionFileJson) -and (Test-Path $pkgVersionFileText)) {

    Write-Host "`n⚠ Backup file already exists!" -ForegroundColor Yellow
    Write-Host "JSON : $pkgVersionFileJson" -ForegroundColor Cyan
    Write-Host "TEXT : $pkgVersionFileText`n" -ForegroundColor Cyan

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
# Set-Content -Path $npmVersionFile -Value $cleanVersion

# Storing Current NPM version
Write-Host "Storing current NPM Packages..." -ForegroundColor Cyan
npm list -g --depth=0 --json > $pkgVersionFileJson
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to save JSON backup."
    exit 1
}

npm list -g --depth=0 > $pkgVersionFileText
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to save TEXT backup."
    exit 1
}
Write-Host "NPM Packages stored successfully!" -ForegroundColor Green
