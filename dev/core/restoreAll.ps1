$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$devRoot = Split-Path -Parent $scriptRoot

function Read-YesNo {
    param (
        [string]$Prompt
    )

    while ($true) {
        $response = (Read-Host "$Prompt (y/n)").Trim().ToLower()
        if ($response -in @("y", "yes")) { return $true }
        if ($response -in @("n", "no")) { return $false }
        Write-Host "Please enter y/yes or n/no." -ForegroundColor Yellow
    }
}

function Invoke-ModuleScripts {
    param (
        [string]$ModuleName,
        [string]$ModulePath,
        [string[]]$Scripts,
        [string]$Action
    )

    if (-not (Read-YesNo "Do you want to $Action $ModuleName")) {
        Write-Host "Skipping $ModuleName." -ForegroundColor DarkYellow
        return
    }

    foreach ($scriptName in $Scripts) {
        $scriptPath = Join-Path $ModulePath $scriptName

        if (-not (Test-Path $scriptPath)) {
            Write-Host "Missing script: $scriptPath" -ForegroundColor Red
            continue
        }

        if (Read-YesNo "Do you want to $Action $scriptName for $ModuleName") {
            Write-Host "Running $scriptName..." -ForegroundColor Cyan
            & $scriptPath
        } else {
            Write-Host "Skipped $scriptName." -ForegroundColor DarkYellow
        }
    }
}

$modules = @(
    @{
        Name = "Node.js"
        Path = Join-Path $devRoot "nodejs\Windows"
        Scripts = @(
            "restore-node.ps1",
            "restore-npm.ps1",
            "restore-npm-globals-json.ps1",
            "restore-npm-globals-text.ps1"
        )
    },
    @{
        Name = "Python"
        Path = Join-Path $devRoot "python\Windows"
        Scripts = @(
            "restore-python-globals-json.ps1",
            "restore-python-globals-text.ps1"
        )
    },
    @{
        Name = "PHP/Composer"
        Path = Join-Path $devRoot "php\Windows"
        Scripts = @(
            "restore-composer.ps1",
            "restore-composer-json.ps1",
            "restore-composer-text.ps1"
        )
    },
    @{
        Name = "VS Code"
        Path = Join-Path $devRoot "vscode\Windows"
        Scripts = @(
            "restore-vscode.ps1",
            "restore-vscode-version.ps1",
            "restore-vscode-extensions.ps1",
            "restore-vscode-settings.ps1",
            "restore-vscode-keybindings.ps1",
            "restore-vscode-snippets.ps1"
        )
    }
)

Write-Host "Starting restore workflow..." -ForegroundColor Green

foreach ($module in $modules) {
    Invoke-ModuleScripts -ModuleName $module.Name -ModulePath $module.Path -Scripts $module.Scripts -Action "restore"
}

Write-Host "Restore workflow completed." -ForegroundColor Green
