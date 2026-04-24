Write-Host "Backing up VS Code Extensions..." -ForegroundColor Cyan

# Go to script directory
$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $baseDir

# Check VS Code CLI
if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    Write-Error "VS Code is not installed or 'code' is not in PATH."
    exit 1
}

# File path
$extensionsFile = "../Data/vscode-extensions.txt"

# Get all installed extensions
$extensions = & code --list-extensions 2>$null

if (-not $extensions) {
    Write-Error "No extensions found or failed to fetch extensions."
    exit 1
}

# Ensure directory exists
$dir = Split-Path $extensionsFile -Parent
if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

# Check if backup file exists
if (Test-Path $extensionsFile) {

    Write-Host "`n⚠ Extensions backup already exists!" -ForegroundColor Yellow
    Write-Host "File: $extensionsFile`n" -ForegroundColor Yellow

    while ($true) {
        $choice = (Read-Host "Do you want to overwrite it? (yes/no)").ToLower()

        if ($choice -in @("yes","y")) {
            break
        }
        elseif ($choice -in @("no","n")) {
            Write-Host "Cancelled by user." -ForegroundColor Yellow
            exit 0
        }
        else {
            Write-Host "Invalid input. Enter yes/y or no/n." -ForegroundColor Red
        }
    }
}

# Save extensions
try {
    $extensions | Set-Content -Path $extensionsFile -Encoding UTF8

    Write-Host "`nVS Code extensions backup completed!" -ForegroundColor Green
    Write-Host "Saved to: $extensionsFile" -ForegroundColor Green
    Write-Host "Total extensions: $($extensions.Count)" -ForegroundColor Green
}
catch {
    Write-Error "Failed to save extensions backup. Error: $_"
    exit 1
}