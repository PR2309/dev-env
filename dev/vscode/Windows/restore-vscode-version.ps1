Write-Host "Checking VS Code Version..." -ForegroundColor Cyan

# Go to script directory
Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)

# Check VS Code
if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    Write-Error "VS Code is not installed."
    exit 1
}

# Read target version
$vscodeVersionFile = "../Data/vscode-version.txt"

if (-not (Test-Path $vscodeVersionFile)) {
    Write-Error "vscode-version.txt not found at $vscodeVersionFile"
    exit 1
}

# Trim the version string to remove any whitespace
$targetVersion = (Get-Content $vscodeVersionFile).Trim()

# Get current version
$currentVersion = (code --version | Select-Object -First 1).Trim()

Write-Host "Current VS Code Version: $currentVersion" -ForegroundColor Yellow
Write-Host "Target VS Code Version : $targetVersion" -ForegroundColor Yellow

# Check if matches
if ($currentVersion -eq $targetVersion) {
    Write-Host "VS Code is already at version $targetVersion." -ForegroundColor Green
} else {
    Write-Host "VS Code version does not match. Please install VS Code version $targetVersion manually from https://code.visualstudio.com/download" -ForegroundColor Red
}
