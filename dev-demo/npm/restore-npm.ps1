$npmVersion = Get-Content npm/npm-version.txt
npm install -g "npm@$npmVersion" --verbose

Write-Host "Restoring global NPM packages..."