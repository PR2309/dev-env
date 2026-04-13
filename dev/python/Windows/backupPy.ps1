Write-Host "Backing up Python packages..." -ForegroundColor Cyan

# Get script directory
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

Write-Host "⬆ Upgrading pip, setuptools, wheel..."
python -m pip install --upgrade pip setuptools wheel

Write-Host "Storing Python packages..."
# pip freeze > ../requirements2.txt

$file = "../requirements.txt"

if (Test-Path $file) {

    while($true){
        $choice = Read-Host "File exists. Overwrite? (yes/no)"
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

pip freeze > $file

Write-Host "Python environment backed up successfully!" -ForegroundColor Green
