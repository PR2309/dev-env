Write-Host "Backing up current VS Code Version..." -ForegroundColor Cyan

# Go to script directory
Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)

# Check VS Code
if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    Write-Error "VS Code is not installed."
    exit 1
}

# Read target version
$vscodeVersionFile = "../Data/vscode-version.txt"

# Get current VS Code version
$currentVersion = (code --version | Select-Object -First 1).Trim()

# ENSURE DIRECTORY EXISTS
$dir = Split-Path $vscodeVersionFile -Parent
if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir | Out-Null
}

# Check if backup file exists
if (Test-Path $vscodeVersionFile) {

    $existingVersion = (Get-Content $vscodeVersionFile -ErrorAction SilentlyContinue).Trim()

    Write-Host "`n⚠ Backup file already exists!" -ForegroundColor Yellow
    Write-Host "Existing saved version : $existingVersion" -ForegroundColor Yellow
    Write-Host "New version to save    : $currentVersion`n" -ForegroundColor Cyan

    # Skip if already same version
    if ($currentVersion -eq $existingVersion) {
        Write-Host "VS Code is already at version $existingVersion. No action needed." -ForegroundColor Cyan
        exit
    }

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

# Storing Current VS Code version
Write-Host "Storing current VS Code $currentVersion..." -ForegroundColor Cyan
# $currentVersion | Out-File -FilePath $vscodeVersionFile -Encoding UTF8
# if ($LASTEXITCODE -ne 0) {
#     Write-Error "Failed to save VS Code version backup."
#     exit 1
# }
# 
# Write-Host "VS Code version stored successfully!" -ForegroundColor Green
# Write-Host "Saved version: $currentVersion" -ForegroundColor Green

try {
    $currentVersion | Out-File -FilePath $vscodeVersionFile -Encoding UTF8 -Force
    Write-Host "VS Code version stored successfully!" -ForegroundColor Green
    Write-Host "Saved version: $currentVersion" -ForegroundColor Green
}
catch {
    Write-Error "Failed to save VS Code version backup. Error: $_"
    exit 1
}
