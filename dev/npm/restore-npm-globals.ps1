# To run this file:
#    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#    .\restore-npm-globals.ps1


$path = "dev/npm/global-packages.json"

if (!(Test-Path $path)) {
    Write-Error "global-packages.json not found"
    exit 1
}

$json = Get-Content $path | ConvertFrom-Json
$deps = $json.dependencies

foreach ($pkg in $deps.PSObject.Properties) {
    $name = $pkg.Name
    $version = $pkg.Value.version

    # Skip npm & node
    if ($name -in @("npm", "node")) {
        continue
    }

    Write-Host "Installing $name@$version"
    npm install -g "$name@$version"
}

Write-Host "✅ Global npm packages restored"
