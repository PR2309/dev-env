<#
==================== VS CODE RESTORE MENU ====================

USAGE:
  Restore everything:
    ./restore-vscode.ps1

  Restore only extensions:
    ./restore-vscode.ps1 -extensions

  Restore only settings:
    ./restore-vscode.ps1 -settings

  Restore only keybindings:
    ./restore-vscode.ps1 -keybindings

  Restore only snippets:
    ./restore-vscode.ps1 -snippets

  Restore multiple:
    ./restore-vscode.ps1 -extensions -settings

==============================================================
#>

param(
    [switch]$extensions,
    [switch]$settings,
    [switch]$keybindings,
    [switch]$snippets
)

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$VSCODE_USER_DIR = "$env:APPDATA\Code\User"

# Default → restore all
if (-not ($extensions -or $settings -or $keybindings -or $snippets)) {
    $extensions = $settings = $keybindings = $snippets = $true
}

Write-Host "Detected OS: Windows"
Write-Host "VS Code User Dir: $VSCODE_USER_DIR"
Write-Host "-------------------------------------"

if ($extensions) {
    Write-Host "Restoring VS Code extensions..."
    Get-Content "$SCRIPT_DIR\extensions.txt" | ForEach-Object {
        code --install-extension $_
    }
}

if ($settings) {
    Write-Host "Restoring settings.json..."
    Copy-Item "$SCRIPT_DIR\settings.json" "$VSCODE_USER_DIR\settings.json" -Force
}

if ($keybindings) {
    Write-Host "Restoring keybindings.json..."
    Copy-Item "$SCRIPT_DIR\keybindings.json" "$VSCODE_USER_DIR\keybindings.json" -Force
}

if ($snippets) {
    Write-Host "Restoring snippets..."
    New-Item -ItemType Directory -Force -Path "$VSCODE_USER_DIR\snippets" | Out-Null
    Copy-Item "$SCRIPT_DIR\snippets\*" "$VSCODE_USER_DIR\snippets" -Recurse -Force
}

Write-Host "✅ VS Code restore completed."
