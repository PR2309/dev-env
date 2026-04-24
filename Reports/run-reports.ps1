# Report Generation Script for Backup/Restore Modules
# This script reads test results from Testing/Data and generates comprehensive reports
# Reports are written to Reports/Data/

# Find the dev folder dynamically (works from any location)
function Find-DevFolder {
    # Get the script directory
    $scriptPath = $MyInvocation.MyCommand.Path
    if (-not $scriptPath) {
        # Fallback for when script is run interactively or path is not available
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

    # First try: Check if we're already in a dev folder
    if ((Split-Path $currentPath -Leaf) -eq "dev") {
        return $currentPath
    }

    # Second try: Check parent directory
    $parentPath = Split-Path $currentPath -Parent
    if ($parentPath -and (Split-Path $parentPath -Leaf) -eq "dev") {
        return $parentPath
    }

    # Third try: Search for dev folder in current directory and parents
    $searchPath = $currentPath
    for ($i = 0; $i -lt 5; $i++) {
        $devPath = Join-Path $searchPath "dev"
        if (Test-Path $devPath -PathType Container) {
            return $devPath
        }
        # Also check for dev folder in sibling directories
        $parentPath = Split-Path $searchPath -Parent
        if ($parentPath) {
            $siblingDevPath = Join-Path $parentPath "dev"
            if (Test-Path $siblingDevPath -PathType Container) {
                return $siblingDevPath
            }
            # Check in Learning subdirectory
            $learningPath = Join-Path $parentPath "Learning"
            if (Test-Path $learningPath -PathType Container) {
                $learningDevPath = Join-Path $learningPath "dev"
                if (Test-Path $learningDevPath -PathType Container) {
                    return $learningDevPath
                }
            }
        }
        $searchPath = Split-Path $searchPath -Parent
        if (-not $searchPath) { break }
    }

    # Fourth try: Look for dev folder in various relative locations
    $scriptParent = Split-Path -Parent $scriptPath
    if ($scriptParent) {
        $scriptGrandParent = Split-Path $scriptParent -Parent
        if ($scriptGrandParent) {
            $devPath = Join-Path $scriptGrandParent "dev"
            if (Test-Path $devPath -PathType Container) {
                return $devPath
            }
            # Check Learning/dev pattern
            $learningPath = Join-Path $scriptGrandParent "Learning"
            if (Test-Path $learningPath -PathType Container) {
                $learningDevPath = Join-Path $learningPath "dev"
                if (Test-Path $learningDevPath -PathType Container) {
                    return $learningDevPath
                }
            }
        }
        # Check if dev is a sibling to the script's grandparent
        $siblingDevPath = Join-Path $scriptParent "dev"
        if (Test-Path $siblingDevPath -PathType Container) {
            return $siblingDevPath
        }
    }

    # Last resort: Ask user or use current directory
    Write-Host "Could not automatically find dev folder. Please specify the path to the dev folder:" -ForegroundColor Yellow
    $manualPath = Read-Host "Enter dev folder path"
    if (Test-Path $manualPath -PathType Container) {
        return $manualPath
    }

    throw "Dev folder not found. Please ensure the dev folder exists and contains the module directories."
}

$DevRoot = Find-DevFolder
$RootDir = Split-Path $DevRoot -Parent
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ReportRoot = Join-Path $ScriptDir 'Data'
$TestDataRoot2 = Join-Path $RootDir 'Testing/Data'

if (-not (Test-Path $ReportRoot)) {
    New-Item -ItemType Directory -Path $ReportRoot | Out-Null
}

function Write-Report {
    param (
        [string]$ModuleName,
        [string]$Content
    )

    $ReportFile = Join-Path $ReportRoot "$ModuleName-report.md"
    $Content | Out-File -FilePath $ReportFile -Encoding UTF8
    Write-Host "Generated $ReportFile successfully!" -ForegroundColor Green
}

function Get-FileStatus {
    param (
        [string]$BasePath,
        [string[]]$Files
    )

    $status = @()
    foreach ($file in $Files) {
        $filePath = Join-Path $BasePath $file
        if (Test-Path $filePath) {
            $length = (Get-Item $filePath).Length
            $lines = (Get-Content $filePath -ErrorAction SilentlyContinue).Count
            $status += "- $filePath - exists ($lines lines, $length bytes)"
        } else {
            $status += "- $filePath - MISSING"
        }
    }

    return $status -join "`n"
}

function Get-TestResults {
    param (
        [string]$ModuleName
    )

    $testResultFile = Join-Path $TestDataRoot2 "${ModuleName}_module_results.md"
    
    if (Test-Path $testResultFile) {
        try {
            $content = Get-Content -Path $testResultFile -Raw -ErrorAction Stop
            return $content
        } catch {
            return "Test data available in: $testResultFile (could not read: $($_.Exception.Message))"
        }
    } else {
        return "No test results found. Run 'powershell ..\Testing\run-tests.ps1' to generate test data."
    }
}

function Inspect-NodejsIssues {
    param ([string]$BasePath)

    $issues = @()

    $backupScripts = @('backup-node.ps1','backup-npm.ps1','backup-npm-globals.ps1')
    foreach ($script in $backupScripts) {
        $path = Join-Path $BasePath $script
        if (Test-Path $path) {
            $content = Get-Content $path -Raw
            if ($content -match 'Split-Path\s+\$file\s+-Parent') {
                $issues += "- `$script` uses an undefined `$file` variable when creating the `../Data` directory."
            }
        }
    }

    $restoreNode = Join-Path $BasePath 'restore-node.ps1'
    if (Test-Path $restoreNode) {
        $content = Get-Content $restoreNode -Raw
        if ($content -match 'NPM is already at version') {
            $issues += "- `restore-node.ps1` prints `NPM is already at version ...` instead of `Node.js is already at version ...`."
        }
        if ($content -match 'Target Node Version : v\$targetVersion') {
            $issues += "- `restore-node.ps1` prefixes target version output with `v`, which may duplicate the `v` prefix if the stored version already includes it."
        }
    }

    $restoreNpm = Join-Path $BasePath 'restore-npm.ps1'
    if (Test-Path $restoreNpm) {
        $content = Get-Content $restoreNpm -Raw
        if ($content -match "\^\\d\+\\.\\d\+\\.\\d\+\$") {
            $issues += "- `restore-npm.ps1` validates npm version format too strictly and may reject prerelease or build identifiers."
        }
    }

    if ($issues.Count -eq 0) { return $null }
    return $issues | ForEach-Object { "- $_" } | Out-String
}

function Inspect-PhpIssues {
    param ([string]$BasePath)

    $issues = @()
    $backupGlobals = Join-Path $BasePath 'backup-composer-globals.ps1'
    if (Test-Path $backupGlobals) {
        $content = Get-Content $backupGlobals -Raw
        if (-not ($content -match 'composer global show --format=json' -and $content -match 'composer global show >')) {
            $issues += "- `backup-composer-globals.ps1` does not appear to generate both JSON and text backups."
        }
    }

    if ($issues.Count -eq 0) { return $null }
    return $issues | ForEach-Object { "- $_" } | Out-String
}

function Inspect-PythonIssues {
    param ([string]$BasePath)

    $issues = @()
    $jsonRestore = Join-Path $BasePath 'restore-python-globals-json.ps1'
    $textRestore = Join-Path $BasePath 'restore-python-globals-text.ps1'

    if (Test-Path $jsonRestore) {
        $content = Get-Content $jsonRestore -Raw
        if ($content -notmatch 'requirements\.json' -or $content -notmatch 'ConvertFrom-Json') {
            $issues += "- `restore-python-globals-json.ps1` does not appear to restore from `requirements.json`."
        }
    }
    if (Test-Path $textRestore) {
        $content = Get-Content $textRestore -Raw
        if ($content -notmatch 'requirements\.txt') {
            $issues += "- `restore-python-globals-text.ps1` does not appear to restore from `requirements.txt`."
        }
    }

    if ($issues.Count -eq 0) { return $null }
    return $issues | ForEach-Object { "- $_" } | Out-String
}

function Inspect-VscodeIssues {
    param ([string]$BasePath)
    return $null
}

function Get-ModuleReport {
    param (
        [string]$ModuleName,
        [string]$BaseFolder,
        [string[]]$ExpectedFiles,
        [scriptblock]$IssueInspector
    )

    $basePath = Join-Path $RootDir $BaseFolder
    $reviewed = Get-FileStatus -BasePath $basePath -Files $ExpectedFiles

    $issues = & $IssueInspector -BasePath $basePath
    if (-not $issues) { $issues = "- No immediate issues were detected during static inspection." }

    # Get test results from Testing/Data folder
    $testResults = Get-TestResults -ModuleName $ModuleName

    return @"
# $ModuleName Script Audit Report

## Reviewed Files
$reviewed

## Static Code Analysis

### Findings
$issues

## Comprehensive Test Results

Test results for the $ModuleName module are documented below. These tests cover file existence, content validation, command presence, error handling, and more.

### Test Details
$testResults

## Conclusion
- This report was generated from live repository files.
- Static findings are based on pattern matching in the current scripts.
- Comprehensive test results are generated by the test runner in the Testing folder.
- To regenerate test data, run: `powershell ..\Testing\run-tests.ps1`
- Reports are stored in: `Reports/Data/`

---

*Report generated on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')*
"@
}

# Module definitions
$modules = @(
    @{ Name = 'nodejs'; Folder = 'nodejs/Windows'; Files = @('backup-node.ps1','backup-npm.ps1','backup-npm-globals.ps1','restore-node.ps1','restore-npm.ps1','restore-npm-globals-json.ps1','restore-npm-globals-text.ps1'); Inspector = ${function:Inspect-NodejsIssues} },
    @{ Name = 'php'; Folder = 'php/Windows'; Files = @('backup-composer.ps1','backup-composer-globals.ps1','restore-composer.ps1','restoreComposerJSON.ps1','restoreComposerText.ps1'); Inspector = ${function:Inspect-PhpIssues} },
    @{ Name = 'python'; Folder = 'python/Windows'; Files = @('backup-python-globals.ps1','restore-python-globals-json.ps1','restore-python-globals-text.ps1'); Inspector = ${function:Inspect-PythonIssues} },
    @{ Name = 'vscode'; Folder = 'vscode/Windows'; Files = @('backup-vscode.ps1','restore-vscode.ps1'); Inspector = ${function:Inspect-VscodeIssues} },
    @{ Name = 'core'; Folder = 'core'; Files = @('backupAll.ps1','restoreAll.ps1'); Inspector = $null }
)

Write-Host "Starting report generation..." -ForegroundColor Cyan
Write-Host "Dev root: $DevRoot" -ForegroundColor Gray
Write-Host "Report root: $ReportRoot" -ForegroundColor Gray
Write-Host "Test data root: $TestDataRoot" -ForegroundColor Gray
Write-Host ""

foreach ($module in $modules) {
    Write-Host "Generating report for module: $($module.Name)" -ForegroundColor Cyan
    $report = Get-ModuleReport -ModuleName $module.Name -BaseFolder $module.Folder -ExpectedFiles $module.Files -IssueInspector $module.Inspector
    Write-Report -ModuleName $module.Name -Content $report
}

Write-Host ""
Write-Host "All reports generated successfully in folder: $ReportRoot" -ForegroundColor Green
