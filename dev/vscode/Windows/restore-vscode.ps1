Write-Host "Restoring VS Code configuration..." -ForegroundColor Cyan

# Find the data folder dynamically (works from any location)
function Find-VscodeDataFolder {
    # Get the script directory
    $scriptPath = $MyInvocation.MyCommand.Path
    if (-not $scriptPath) {
        $scriptPath = $PSScriptRoot
        if (-not $scriptPath) {
            $scriptPath = Get-Location
        }
    }

    $currentPath = if ($scriptPath -and (Test-Path $scriptPath)) {
        if ((Get-Item $scriptPath).PSIsContainer) {
            $scriptPath
        } else {
            Split-Path -Parent $scriptPath
        }
    } else {
        Get-Location
    }

    # First try: Check if we're already in a vscode folder
    if ((Split-Path $currentPath -Leaf) -eq "vscode") {
        $dataPath = Join-Path $currentPath "Data"
        if (Test-Path $dataPath -PathType Container) {
            return $dataPath
        }
    }

    # Second try: Check parent directory
    $parentPath = Split-Path $currentPath -Parent
    if ($parentPath -and (Split-Path $parentPath -Leaf) -eq "vscode") {
        $dataPath = Join-Path $parentPath "Data"
        if (Test-Path $dataPath -PathType Container) {
            return $dataPath
        }
    }

    # Third try: Search for vscode folder in current directory and parents
    $searchPath = $currentPath
    for ($i = 0; $i -lt 5; $i++) {
        $vscodePath = Join-Path $searchPath "vscode"
        if (Test-Path $vscodePath -PathType Container) {
            $dataPath = Join-Path $vscodePath "Data"
            if (Test-Path $dataPath -PathType Container) {
                return $dataPath
            }
        }
        $searchPath = Split-Path $searchPath -Parent
        if (-not $searchPath) { break }
    }

    # Last resort: Ask user
    Write-Host "Could not automatically find vscode Data folder. Please specify the path to the vscode Data folder:" -ForegroundColor Yellow
    $manualPath = Read-Host "Enter vscode Data folder path"
    if (Test-Path $manualPath -PathType Container) {
        return $manualPath
    }

    throw "VSCode Data folder not found. Please ensure the vscode Data folder exists."
}

$DataRoot = Find-VscodeDataFolder

# Check VS Code
if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    Write-Error "VS Code not found. Install VS Code first."
    exit 1
}

$extensionsFile = Join-Path $DataRoot "extensions.txt"
$settingsFile = Join-Path $DataRoot "settings.json"
$keybindingsFile = Join-Path $DataRoot "keybindings.json"
$snippetsDir = Join-Path $DataRoot "snippets"

# Check if backup files exist
$filesExist = $false
if ((Test-Path $extensionsFile) -or (Test-Path $settingsFile) -or (Test-Path $keybindingsFile) -or (Test-Path $snippetsDir)) {
    $filesExist = $true
}

if (-not $filesExist) {
    Write-Error "No backup files found in ../Data/ directory"
    exit 1
}

while($true){
    $choice = Read-Host "Do you want to restore VS Code configuration? (yes/no)"
    $choice = $choice.ToLower()

    if ($choice -eq "yes" -or $choice -eq "y") {
        break
    } elseif ($choice -eq "no" -or $choice -eq "n") {
        Write-Host "Cancelled." -ForegroundColor Yellow
        exit
    } else {
        Write-Host "Invalid input. Please enter 'yes/y' or 'no/n'." -ForegroundColor Red
    }
}

Write-Host "Restoring VS Code configuration..."

# Restore extensions
if (Test-Path $extensionsFile) {
    Write-Host "Installing VS Code extensions..."
    $failedExtensions = @()
    Get-Content $extensionsFile | ForEach-Object {
        if ([string]::IsNullOrWhiteSpace($_)) { return }
        Write-Host "Installing $_ ..." -ForegroundColor Cyan
        $result = & code --install-extension $_ 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed: $_" -ForegroundColor Red
            $failedExtensions += $_
        }
    }

    if ($failedExtensions.Count -gt 0) {
        Write-Host "`nFailed Extensions:" -ForegroundColor Yellow
        foreach ($ext in $failedExtensions) {
            Write-Host $ext
        }
    }
}

# Restore settings
if (Test-Path $settingsFile) {
    Write-Host "Restoring settings.json..."
    Copy-Item $settingsFile "$env:APPDATA\Code\User\settings.json" -Force
}

# Restore keybindings
if (Test-Path $keybindingsFile) {
    Write-Host "Restoring keybindings.json..."
    Copy-Item $keybindingsFile "$env:APPDATA\Code\User\keybindings.json" -Force
}

# Restore snippets
if (Test-Path $snippetsDir) {
    Write-Host "Restoring snippets..."
    $userSnippetsDir = "$env:APPDATA\Code\User\snippets"
    if (-not (Test-Path $userSnippetsDir)) {
        New-Item -ItemType Directory -Path $userSnippetsDir -Force | Out-Null
    }
    Copy-Item "$snippetsDir\*" $userSnippetsDir -Recurse -Force
}

Write-Host "VS Code configuration restored successfully!" -ForegroundColor Green
