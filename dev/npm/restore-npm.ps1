$npmVersion = Get-Content dev/npm/npm-version.txt
npm install -g npm@$npmVersion
Write-Host "🔁 Restoring global NPM packages..."