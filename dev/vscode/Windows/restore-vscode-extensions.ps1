Write-Host "Restoring VS Code Extensions..." -ForegroundColor Cyan

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

if (-not (Test-Path $extensionsFile)) {
    Write-Error "Extensions backup file not found!"
    exit 1
}

# Lists
$successList = @()
$failedList  = @()

Write-Host "`nInstalling extensions..." -ForegroundColor Yellow
Write-Host ""

# Read extensions
$extensions = Get-Content $extensionsFile

foreach ($ext in $extensions) {
    if ($ext.Trim() -ne "") {

        Write-Host "→ Installing: $ext"

        & code --install-extension $ext | Out-Null

        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✔ Success" -ForegroundColor Green
            $successList += $ext
        }
        else {
            Write-Host "  ✖ Failed" -ForegroundColor Red
            $failedList += $ext
        }

        Write-Host ""
    }
}

# SUMMARY
Write-Host "========================" -ForegroundColor Cyan
Write-Host "Restore completed!" -ForegroundColor Cyan
Write-Host "Successful installs: $($successList.Count)" -ForegroundColor Green
Write-Host "Failed installs    : $($failedList.Count)" -ForegroundColor Red
Write-Host "========================"

# SHOW FAILED DETAILS
if ($failedList.Count -gt 0) {
    Write-Host "`n Failed Extensions:" -ForegroundColor Red
    foreach ($ext in $failedList) {
        Write-Host " - $ext"
    }
}

# ASK FOR SUCCESS LIST
Write-Host ""
$choice = Read-Host "Do you want to see successfully installed extensions? (yes/no)"
$choice = $choice.ToLower()

if ($choice -eq "yes" -or $choice -eq "y") {

    Write-Host "`n Successfully Installed Extensions:" -ForegroundColor Green
    foreach ($ext in $successList) {
        Write-Host " - $ext"
    }

} else {
    Write-Host "Skipping success list display." -ForegroundColor Yellow
}