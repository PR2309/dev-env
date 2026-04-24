Write-Host "Backing up VS Code configuration..." -ForegroundColor Cyan

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

Write-Host "Storing VS Code configuration..."

# Backup extensions
$file = Join-Path $DataRoot "extensions.txt"
if (Test-Path $file) {
    while($true){
        $choice = Read-Host "File exists. Overwrite? (yes/no)"
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
}

code --list-extensions > $file

# Backup settings
$file = Join-Path $DataRoot "settings.json"
if (Test-Path $file) {
    while($true){
        $choice = Read-Host "File exists. Overwrite? (yes/no)"
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
}

Copy-Item "$env:APPDATA\Code\User\settings.json" $file -Force

# Backup keybindings
$file = Join-Path $DataRoot "keybindings.json"
if (Test-Path $file) {
    while($true){
        $choice = Read-Host "File exists. Overwrite? (yes/no)"
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
}

Copy-Item "$env:APPDATA\Code\User\keybindings.json" $file -Force

# Backup snippets
$snippetsDir = Join-Path $DataRoot "snippets"
if (Test-Path $snippetsDir) {
    while($true){
        $choice = Read-Host "Snippets directory exists. Overwrite? (yes/no)"
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
}

# Remove existing snippets directory and copy new one
Remove-Item $snippetsDir -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item "$env:APPDATA\Code\User\snippets" $snippetsDir -Recurse -Force

Write-Host "VS Code configuration backed up successfully!" -ForegroundColor Green