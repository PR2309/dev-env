$File = "composer/global-composer-packages.txt"

if (-Not (Test-Path $File)) {
    Write-Host "❌ File not found: $File"
    exit 1
}

Write-Host "🔁 Restoring global Composer packages..."

Get-Content $File |
Select-String -Pattern "^[a-zA-Z0-9_-]+/" |
ForEach-Object {
    $pkg = ($_ -split '\s+')[0]
    Write-Host "➡ Installing $pkg"
    composer global require $pkg
}

Write-Host "✅ Composer global packages restored"
