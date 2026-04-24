$json = Get-Content composer/global-packages.json | ConvertFrom-Json

foreach ($pkg in $json.installed) {
    composer global require "$($pkg.name):$($pkg.version)"
}
