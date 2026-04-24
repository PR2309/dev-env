# To run this file:
#    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#    .\restore-npm-globals.ps1

Write-Host "Restoring NPM Packages..." -ForegroundColor Cyan

# Go to script directory
Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)

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
$packagesPath = "../Data/global-packages.json"

# Check file exists
if (!(Test-Path $packagesPath)) {
    Write-Error "global-packages.json not found"
    exit 1
}

$json = Get-Content $packagesPath | ConvertFrom-Json
$deps = $json.dependencies

# Track results
$installed = @()
$failed = @()

foreach ($pkg in $deps.PSObject.Properties) {
    $name = $pkg.Name
    $version = $pkg.Value.version

    # Skip npm & node
    if ($name -in @("npm", "node")) {
        continue
    }

    Write-Host "Installing $name@$version" -ForegroundColor Cyan
    npm install -g "$name@$version"

    if ($LASTEXITCODE -ne 0) {
        $failed += "$name@$version"
    } else {
        $installed += "$name@$version"
    }
}

Write-Host "Global npm packages restored" -ForegroundColor Green


if ($failed.Count -gt 0) {
    Write-Host "`n❌ Failed packages:" -ForegroundColor Red
    $failed | ForEach-Object { Write-Host $_ }
}

# Confirm overwrite if file exists
while ($true) {
    $choice = Read-Host "Do you want list of packages installed now? (yes/no)"
    $choice = $choice.ToLower()

    if ($choice -eq "yes" -or $choice -eq "y") {
        # Installed Packages
        Write-Host "`n✔ Installed packages:" -ForegroundColor Green
        $installed | ForEach-Object { Write-Host $_ }
        break
    } elseif ($choice -eq "no" -or $choice -eq "n") {
        # Write-Host "Cancelled." -ForegroundColor Yellow
        exit
    } else {
        Write-Host "Invalid input. Enter yes/y or no/n." -ForegroundColor Red
    }
}

while ($true) {
    $choice = Read-Host "Do you want list of all installed packages? (yes/no)"
    $choice = $choice.ToLower()

    if ($choice -eq "yes" -or $choice -eq "y") {
        # All current Packages
        Write-Host "`n📦 Current global packages:" -ForegroundColor Cyan
        npm list -g --depth=0
        break
    } elseif ($choice -eq "no" -or $choice -eq "n") {
        # Write-Host "Cancelled." -ForegroundColor Yellow
        exit
    } else {
        Write-Host "Invalid input. Enter yes/y or no/n." -ForegroundColor Red
    }
}

