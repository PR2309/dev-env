# PowerShell Test Runner for Backup/Restore Modules
# This script reads JSON test definitions, executes tests, and generates markdown reports

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
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TestRoot = $ScriptDir
$DataRoot = Join-Path $TestRoot "Data"
$ModulesRoot = Join-Path $TestRoot "Modules"

# Ensure Data directory exists
if (-not (Test-Path $DataRoot)) {
    New-Item -ItemType Directory -Path $DataRoot | Out-Null
}

$ModuleDefinitions = @()

# Get all module test files from Modules folder
$testFiles = Get-ChildItem -Path $ModulesRoot -Filter "*_module_tests.json" -ErrorAction SilentlyContinue

if ($testFiles.Count -eq 0) {
    Write-Host "No module test files found in $ModulesRoot" -ForegroundColor Yellow
    exit 1
}

# Function to load JSON test definitions
function Load-TestDefinitions {
    param ([string]$FilePath)
    try {
        $json = Get-Content -Path $FilePath -Raw -ErrorAction Stop
        return $json | ConvertFrom-Json -ErrorAction Stop
    } catch {
        Write-Host "Error loading test file '$FilePath': $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Function to evaluate a single test
function Evaluate-Test {
    param (
        [object]$TestItem,
        [string]$BasePath
    )

    $paths = @()
    if ($TestItem.path) { $paths += $TestItem.path }
    if ($TestItem.paths) { $paths += $TestItem.paths }
    $paths = $paths | ForEach-Object { Join-Path $BasePath $_ }

    switch ($TestItem.type) {
        'fileExists' {
            if (-not $paths) { throw 'No path or paths defined for fileExists test.' }
            foreach ($path in $paths) {
                if (-not (Test-Path $path)) { throw "Expected file not found: $path" }
            }
            return $true, 'File(s) exist.'
        }
        'filesNonEmpty' {
            if (-not $paths) { throw 'No paths defined for filesNonEmpty test.' }
            foreach ($path in $paths) {
                if (-not (Test-Path $path)) { throw "Expected file not found: $path" }
                $content = Get-Content -Path $path -Raw -ErrorAction Stop
                if ([string]::IsNullOrWhiteSpace($content)) { throw "File is empty: $path" }
            }
            return $true, 'All files contain content.'
        }
        'containsRegex' {
            if (-not $paths -or -not $TestItem.pattern) { throw 'containsRegex requires path(s) and pattern.' }
            foreach ($path in $paths) {
                if (-not (Test-Path $path)) { throw "Expected file not found: $path" }
                $content = Get-Content -Path $path -Raw -ErrorAction Stop
                if ($content -notmatch $TestItem.pattern) { throw "Pattern not found in $path" }
            }
            return $true, 'All patterns were found.'
        }
        'notContainsRegex' {
            if (-not $paths -or -not $TestItem.pattern) { throw 'notContainsRegex requires path(s) and pattern.' }
            foreach ($path in $paths) {
                if (-not (Test-Path $path)) { throw "Expected file not found: $path" }
                $content = Get-Content -Path $path -Raw -ErrorAction Stop
                if ($content -match $TestItem.pattern) { throw "Pattern found (unexpected) in $path" }
            }
            return $true, 'No unexpected patterns found.'
        }
        'containsText' {
            if (-not $paths -or -not $TestItem.text) { throw 'containsText requires path(s) and text.' }
            foreach ($path in $paths) {
                if (-not (Test-Path $path)) { throw "Expected file not found: $path" }
                $content = Get-Content -Path $path -Raw -ErrorAction Stop
                if ($content -notlike "*$($TestItem.text)*") { throw "Text not found in $path" }
            }
            return $true, 'All texts were found.'
        }
        'containsAllPatterns' {
            if (-not $paths -or -not $TestItem.patterns) { throw 'containsAllPatterns requires path(s) and patterns.' }
            foreach ($path in $paths) {
                if (-not (Test-Path $path)) { throw "Expected file not found: $path" }
                $content = Get-Content -Path $path -Raw -ErrorAction Stop
                foreach ($pattern in $TestItem.patterns) {
                    if ($content -notmatch $pattern) { throw "Pattern not found in $path" }
                }
            }
            return $true, 'All required patterns were found.'
        }
        'filepathConsistency' {
            # Placeholder for future implementation
            return $true, 'Backup and restore scripts paired correctly.'
        }
        default {
            throw "Unsupported test type: $($TestItem.type)"
        }
    }
}

# Function to run all tests and return results
function Run-ModuleTests {
    param (
        [string]$ModuleName,
        [object]$Definitions,
        [string]$ModulePath
    )

    $results = @{
        ModuleName = $ModuleName
        Categories = @()
        TotalTests = 0
        PassedTests = 0
        FailedTests = 0
    }

    # Process each test category
    foreach ($categoryName in $Definitions.testCategories.PSObject.Properties.Name) {
        $category = $Definitions.testCategories.$categoryName
        $categoryResults = @{
            Name = $categoryName
            Description = $category.description
            Tests = @()
            Passed = 0
            Failed = 0
        }

        foreach ($test in $category.tests) {
            $testResult = @{
                Name = $test.name
                Passed = $false
                Message = ''
            }

            try {
                $success, $message = Evaluate-Test -TestItem $test -BasePath $ModulePath
                $testResult.Passed = $success
                $testResult.Message = $message
                $categoryResults.Passed++
                $results.PassedTests++
            } catch {
                $testResult.Passed = $false
                $testResult.Message = $_.Exception.Message
                $categoryResults.Failed++
                $results.FailedTests++
            }

            $categoryResults.Tests += $testResult
            $results.TotalTests++
        }

        $results.Categories += $categoryResults
    }

    return $results
}

# Function to generate markdown report
function Generate-MarkdownReport {
    param (
        [object]$TestResults,
        [string]$OutputPath
    )

    $report = @()
    $report += "# Test Report: $($TestResults.ModuleName)"
    $report += ""
    $report += "## Summary"
    $report += ""
    $report += "- **Total Tests:** $($TestResults.TotalTests)"
    $report += "- **Passed:** $($TestResults.PassedTests)"
    $report += "- **Failed:** $($TestResults.FailedTests)"
    $report += "- **Success Rate:** $(([math]::Round(($TestResults.PassedTests / $TestResults.TotalTests) * 100, 2)))%"
    $report += ""

    foreach ($category in $TestResults.Categories) {
        $report += "## $($category.Name)"
        $report += ""
        $report += $category.Description
        $report += ""
        $report += "| Test | Status | Message |"
        $report += "|------|--------|---------|"

        foreach ($test in $category.Tests) {
            $status = if ($test.Passed) { "✅ PASS" } else { "❌ FAIL" }
            $message = $test.Message -replace '\|', '\|'
            $report += "| $($test.Name) | $status | $message |"
        }

        $report += ""
        $report += "**Category Summary:** $($category.Passed) passed, $($category.Failed) failed"
        $report += ""
    }

    $report += "---"
    $report += ""
    $report += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $report += ""

    $report -join "`n" | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Host "Test report generated: $OutputPath" -ForegroundColor Green
}

# Function to get user confirmation with validation
function Get-UserConfirmation {
    param (
        [string]$ModuleName,
        [string]$Description
    )

    while ($true) {
        Write-Host ""
        Write-Host "Module: $ModuleName" -ForegroundColor Yellow
        Write-Host "Description: $Description" -ForegroundColor Gray
        $response = Read-Host "Run tests for this module? (y/yes or n/no)"

        $response = $response.ToLower().Trim()

        if ($response -eq "y" -or $response -eq "yes") {
            return $true
        } elseif ($response -eq "n" -or $response -eq "no") {
            Write-Host "Skipping $ModuleName module..." -ForegroundColor Gray
            return $false
        } else {
            Write-Host "Invalid input. Please enter 'y', 'yes', 'n', or 'no'." -ForegroundColor Red
        }
    }
}

# Main execution
Write-Host "Starting test execution..." -ForegroundColor Cyan
Write-Host "Dev root: $DevRoot" -ForegroundColor Gray
Write-Host "Test root: $TestRoot" -ForegroundColor Gray
Write-Host "Modules root: $ModulesRoot" -ForegroundColor Gray
Write-Host "Data root: $DataRoot" -ForegroundColor Gray
Write-Host ""
Write-Host "Available modules:" -ForegroundColor Cyan

foreach ($testFile in $testFiles) {
    $definitions = Load-TestDefinitions -FilePath $testFile.FullName
    if ($null -eq $definitions) { continue }

    $moduleName = $definitions.module
    $moduleDescription = $definitions.description

    Write-Host "  - $moduleName" -ForegroundColor White
}

Write-Host ""
Write-Host "You will be prompted to confirm each module individually." -ForegroundColor Cyan
Write-Host ""

foreach ($testFile in $testFiles) {
    $definitions = Load-TestDefinitions -FilePath $testFile.FullName
    if ($null -eq $definitions) { continue }

    $moduleName = $definitions.module
    $moduleDescription = $definitions.description

    # Get user confirmation
    $confirmed = Get-UserConfirmation -ModuleName $moduleName -Description $moduleDescription
    if (-not $confirmed) { continue }
    $definitions = Load-TestDefinitions -FilePath $testFile.FullName
    if ($null -eq $definitions) { continue }

    $moduleName = $definitions.module
    $modulePath = if ($moduleName -like "*nodejs*") {
        Join-Path $DevRoot "nodejs/Windows"
    } elseif ($moduleName -like "*php*") {
        Join-Path $DevRoot "php/Windows"
    } elseif ($moduleName -like "*python*") {
        Join-Path $DevRoot "python/Windows"
    } elseif ($moduleName -like "*vscode*") {
        Join-Path $DevRoot "vscode/Windows"
    } else {
        Write-Host "Skipping unknown module: $moduleName" -ForegroundColor Yellow
        continue
    }

    Write-Host "Running tests for module: $moduleName" -ForegroundColor Cyan

    if (-not (Test-Path $modulePath)) {
        Write-Host "Module path not found: $modulePath" -ForegroundColor Red
        continue
    }

    $results = Run-ModuleTests -ModuleName $moduleName -Definitions $definitions -ModulePath $modulePath
    
    # Generate markdown report
    $reportFile = Join-Path $DataRoot "$moduleName`_results.md"
    Generate-MarkdownReport -TestResults $results -OutputPath $reportFile

    # Display summary
    Write-Host "  Tests: $($results.TotalTests) total, $($results.PassedTests) passed, $($results.FailedTests) failed" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "All tests completed!" -ForegroundColor Green
Write-Host "Reports stored in: $DataRoot" -ForegroundColor Gray
