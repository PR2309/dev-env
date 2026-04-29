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
            "backup-node.ps1",
            "backup-npm.ps1",
            "backup-npm-globals.ps1"
        )
    },
    @{
        Name = "Python"
        Path = Join-Path $devRoot "python\Windows"
        Scripts = @(
            "backup-python-globals.ps1"
        )
    },
    @{
        Name = "PHP/Composer"
        Path = Join-Path $devRoot "php\Windows"
        Scripts = @(
            "backup-composer.ps1",
            "backup-composer-globals.ps1"
        )
    },
    @{
        Name = "VS Code"
        Path = Join-Path $devRoot "vscode\Windows"
        Scripts = @(
            "backup-vscode.ps1",
            "backup-vscode-version.ps1",
            "backup-vscode-extensions.ps1",
            "backup-vscode-settings.ps1",
            "backup-vscode-keybindings.ps1",
            "backup-vscode-snippets.ps1"
        )
    }
)

Write-Host "Starting backup workflow..." -ForegroundColor Green

foreach ($module in $modules) {
    Invoke-ModuleScripts -ModuleName $module.Name -ModulePath $module.Path -Scripts $module.Scripts -Action "backup"
}

Write-Host "Backup workflow completed." -ForegroundColor Green
