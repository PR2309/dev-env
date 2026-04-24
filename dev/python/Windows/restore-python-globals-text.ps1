Write-Host "Restoring Python packages..." -ForegroundColor Cyan

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

$requirements = "../Data/requirements.txt"

# Check if requirements.txt exists
if (-not (Test-Path $requirements)) {
    Write-Error "requirements.txt not found at $requirements"
    exit 1
}

while($true){
    $choice = Read-Host "Do you want to intall all packages? (yes/no)"
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

# Write-Host "Installing Python packages..."
# pip install -r $requirements

# Read all packages
$packages = Get-Content $requirements

# Array to store failed packages
$failedPackages = @()
foreach ($pkg in $packages) {

    if ([string]::IsNullOrWhiteSpace($pkg)) { continue }

    Write-Host "Installing $pkg ..." -ForegroundColor Cyan

    # pip install $pkg
    python -m pip install $pkg

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed: $pkg" -ForegroundColor Red
        $failedPackages += $pkg
    }
}

# Print failed packages
Write-Host "`nFailed Packages:" -ForegroundColor Yellow

if ($failedPackages.Count -eq 0) {
    Write-Host "None" -ForegroundColor Green
} else {
    foreach ($f in $failedPackages) {
        Write-Host $f
    }
}

Write-Host "Python environment restored successfully!" -ForegroundColor Green
