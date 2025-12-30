$nodeVersion = Get-Content dev/npm/node-version.txt
nvm install $nodeVersion
nvm use $nodeVersion
Write-Host "🔁 Restoring global NPM packages..."