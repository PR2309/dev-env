Write-Host "Restoring NPM Packages (from text backup)..." -ForegroundColor Cyan

# Go to script directory
Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)

# Check Node
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Error "Node.js is not installed."
    exit 1
}

# Check NPM
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Error "NPM is not installed."
    exit 1
}

# File path
$packagesPath = "../Data/global-npm-packages.txt"

# Check file exists
if (!(Test-Path $packagesPath)) {
    Write-Error "Text backup file not found"
    exit 1
}

# Read file
$lines = Get-Content $packagesPath

# Track results
$installed = @()
$failed = @()

foreach ($line in $lines) {

    # Clean line (remove tree symbols like │, ──, ├──, └──)
    $pkg = ($line -replace '^(Γö£ΓöÇΓöÇ|[\s│├└─]+)', '').Trim()

    # Skip empty lines
    if ([string]::IsNullOrWhiteSpace($pkg)) {
        continue
    }

    # Skip npm & node
    if ($pkg -match '^npm@' -or $pkg -match '^node@') {
        continue
    }

    # Skip invalid entries (no version)
    if ($pkg -notmatch '@\d') {
        Write-Host "Skipping invalid entry: $pkg" -ForegroundColor Yellow
        continue
    }

    Write-Host "Installing $pkg" -ForegroundColor Cyan
    npm install -g $pkg

    if ($LASTEXITCODE -ne 0) {
        $failed += $pkg
    } else {
        $installed += $pkg
    }
}

Write-Host "Global npm packages restored" -ForegroundColor Green

# Show failed packages
if ($failed.Count -gt 0) {
    Write-Host "`n❌ Failed packages:" -ForegroundColor Red
    $failed | ForEach-Object { Write-Host $_ }
}

# Ask to show installed packages
while ($true) {
    $choice = Read-Host "Do you want list of packages installed now? (yes/no)"
    $choice = $choice.ToLower()

    if ($choice -eq "yes" -or $choice -eq "y") {
        Write-Host "`n✔ Installed packages:" -ForegroundColor Green
        $installed | ForEach-Object { Write-Host $_ }
        break
    } elseif ($choice -eq "no" -or $choice -eq "n") {
        exit
    } else {
        Write-Host "Invalid input. Enter yes/y or no/n." -ForegroundColor Red
    }
}

# Ask to show all current packages
while ($true) {
    $choice = Read-Host "Do you want list of all installed packages? (yes/no)"
    $choice = $choice.ToLower()

    if ($choice -eq "yes" -or $choice -eq "y") {
        Write-Host "`n📦 Current global packages:" -ForegroundColor Cyan
        npm list -g --depth=0
        break
    } elseif ($choice -eq "no" -or $choice -eq "n") {
        exit
    } else {
        Write-Host "Invalid input. Enter yes/y or no/n." -ForegroundColor Red
    }
}