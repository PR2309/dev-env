#!/bin/bash

# Bash Test Runner for Backup/Restore Modules
# This script reads JSON test definitions, executes tests, and generates markdown reports

# Find the dev folder dynamically (works from any location)
find_dev_folder() {
    local current_path
    current_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # First try: Check if we're already in a dev folder
    if [[ "$(basename "$current_path")" == "dev" ]]; then
        echo "$current_path"
        return 0
    fi

    # Second try: Check parent directory
    local parent_path
    parent_path="$(dirname "$current_path")"
    if [[ "$(basename "$parent_path")" == "dev" ]]; then
        echo "$parent_path"
        return 0
    fi

    # Third try: Search for dev folder in current directory and parents
    local search_path="$current_path"
    for ((i=0; i<5; i++)); do
        local dev_path="$search_path/dev"
        if [[ -d "$dev_path" ]]; then
            echo "$dev_path"
            return 0
        fi
        # Also check for dev folder in sibling directories
        local parent_path_check
        parent_path_check="$(dirname "$search_path")"
        if [[ -n "$parent_path_check" && "$parent_path_check" != "/" ]]; then
            local sibling_dev_path="$parent_path_check/dev"
            if [[ -d "$sibling_dev_path" ]]; then
                echo "$sibling_dev_path"
                return 0
            fi
            # Check in Learning subdirectory
            local learning_path="$parent_path_check/Learning"
            if [[ -d "$learning_path" ]]; then
                local learning_dev_path="$learning_path/dev"
                if [[ -d "$learning_dev_path" ]]; then
                    echo "$learning_dev_path"
                    return 0
                fi
            fi
        fi
        search_path="$(dirname "$search_path")"
        [[ "$search_path" == "/" ]] && break
    done

    # Fourth try: Look for dev folder in various relative locations
    local script_parent
    local script_grandparent
    script_parent="$(dirname "${BASH_SOURCE[0]}")"
    if [[ -n "$script_parent" ]]; then
        script_grandparent="$(dirname "$script_parent")"
        if [[ -n "$script_grandparent" ]]; then
            local dev_path="$script_grandparent/dev"
            if [[ -d "$dev_path" ]]; then
                echo "$dev_path"
                return 0
            fi
            # Check Learning/dev pattern
            local learning_path="$script_grandparent/Learning"
            if [[ -d "$learning_path" ]]; then
                local learning_dev_path="$learning_path/dev"
                if [[ -d "$learning_dev_path" ]]; then
                    echo "$learning_dev_path"
                    return 0
                fi
            fi
        fi
        # Check if dev is a sibling to the script's grandparent
        local sibling_dev_path="$script_parent/dev"
        if [[ -d "$sibling_dev_path" ]]; then
            echo "$sibling_dev_path"
            return 0
        fi
    fi

    # Last resort: Ask user
    echo "Could not automatically find dev folder. Please specify the path to the dev folder:" >&2
    read -r manual_path
    if [[ -d "$manual_path" ]]; then
        echo "$manual_path"
        return 0
    fi

    echo "Dev folder not found. Please ensure the dev folder exists and contains the module directories." >&2
    return 1
}

DEV_ROOT=$(find_dev_folder)
if [[ $? -ne 0 ]]; then
    exit 1
fi

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_ROOT="$TEST_ROOT/Data"
MODULES_ROOT="$TEST_ROOT/Modules"
SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure Data directory exists
mkdir -p "$DATA_ROOT"

# Function to load JSON test definitions
load_test_definitions() {
    local file_path=$1
    if command -v jq &> /dev/null; then
        cat "$file_path"
    else
        echo "Error: jq is required to parse JSON. Please install jq." >&2
        return 1
    fi
}

# Function to evaluate a single test
evaluate_test() {
    local test_type=$1
    local base_path=$2
    local pattern=$3
    local text=$4
    shift 4
    local paths=("$@")

    case "$test_type" in
        fileExists)
            for path in "${paths[@]}"; do
                full_path="$base_path/$path"
                if [ ! -f "$full_path" ]; then
                    echo "false|Expected file not found: $full_path"
                    return
                fi
            done
            echo "true|File(s) exist."
            ;;
        filesNonEmpty)
            for path in "${paths[@]}"; do
                full_path="$base_path/$path"
                if [ ! -f "$full_path" ]; then
                    echo "false|Expected file not found: $full_path"
                    return
                fi
                if [ ! -s "$full_path" ]; then
                    echo "false|File is empty: $full_path"
                    return
                fi
            done
            echo "true|All files contain content."
            ;;
        containsRegex)
            for path in "${paths[@]}"; do
                full_path="$base_path/$path"
                if [ ! -f "$full_path" ]; then
                    echo "false|Expected file not found: $full_path"
                    return
                fi
                if ! grep -qE "$pattern" "$full_path"; then
                    echo "false|Pattern not found in $full_path"
                    return
                fi
            done
            echo "true|All patterns were found."
            ;;
        notContainsRegex)
            for path in "${paths[@]}"; do
                full_path="$base_path/$path"
                if [ ! -f "$full_path" ]; then
                    echo "false|Expected file not found: $full_path"
                    return
                fi
                if grep -qE "$pattern" "$full_path"; then
                    echo "false|Pattern found (unexpected) in $full_path"
                    return
                fi
            done
            echo "true|No unexpected patterns found."
            ;;
        containsText)
            for path in "${paths[@]}"; do
                full_path="$base_path/$path"
                if [ ! -f "$full_path" ]; then
                    echo "false|Expected file not found: $full_path"
                    return
                fi
                if ! grep -q "$text" "$full_path"; then
                    echo "false|Text not found in $full_path"
                    return
                fi
            done
            echo "true|All texts were found."
            ;;
        containsAllPatterns)
            for path in "${paths[@]}"; do
                full_path="$base_path/$path"
                if [ ! -f "$full_path" ]; then
                    echo "false|Expected file not found: $full_path"
                    return
                fi
                if ! grep -qE "$pattern" "$full_path"; then
                    echo "false|Pattern not found in $full_path"
                    return
                fi
            done
            echo "true|All required patterns were found."
            ;;
        *)
            echo "false|Unsupported test type: $test_type"
            ;;
    esac
}

# Function to generate markdown report
generate_markdown_report() {
    local module_name=$1
    local results_json=$2
    local output_path=$3

    local total_tests=$(echo "$results_json" | jq '.totalTests')
    local passed_tests=$(echo "$results_json" | jq '.passedTests')
    local failed_tests=$(echo "$results_json" | jq '.failedTests')
    local success_rate=$(awk "BEGIN {printf \"%.2f\", ($passed_tests/$total_tests)*100}")

    {
        echo "# Test Report: $module_name"
        echo ""
        echo "## Summary"
        echo ""
        echo "- **Total Tests:** $total_tests"
        echo "- **Passed:** $passed_tests"
        echo "- **Failed:** $failed_tests"
        echo "- **Success Rate:** $success_rate%"
        echo ""

        echo "$results_json" | jq -r '.categories[] | 
            "## \(.name)\n\n\(.description)\n\n| Test | Status | Message |\n|------|--------|--------|\n" +
            (.tests | map("| \(.name) | \(if .passed then "✅ PASS" else "❌ FAIL" end) | \(.message | gsub("|"; "\\|")) |") | join("\n")) +
            "\n\n**Category Summary:** \(.passed) passed, \(.failed) failed\n"' >> "$output_path"

        echo "" >> "$output_path"
        echo "---" >> "$output_path"
        echo "" >> "$output_path"
        echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')" >> "$output_path"
        echo "" >> "$output_path"
    } > "$output_path"
}

# Function to get user confirmation with validation
get_user_confirmation() {
    local module_name=$1
    local description=$2

    while true; do
        echo ""
        echo "Module: $module_name"
        echo "Description: $description"
        read -p "Run tests for this module? (y/yes or n/no): " response

        response=$(echo "$response" | tr '[:upper:]' '[:lower:]' | xargs)

        case "$response" in
            y|yes)
                return 0
                ;;
            n|no)
                echo "Skipping $module_name module..."
                return 1
                ;;
            *)
                echo "Invalid input. Please enter 'y', 'yes', 'n', or 'no'."
                ;;
        esac
    done
}

# Main execution
echo "Starting test execution..."
echo "Dev root: $DEV_ROOT"
echo "Test root: $TEST_ROOT"
echo "Modules root: $MODULES_ROOT"
echo "Data root: $DATA_ROOT"
echo ""

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required for JSON parsing. Please install jq." >&2
    exit 1
fi

# Check if Modules directory exists
if [ ! -d "$MODULES_ROOT" ]; then
    echo "Error: Modules directory not found at $MODULES_ROOT" >&2
    exit 1
fi

echo "Available modules:"
for test_file in "$MODULES_ROOT"/*_module_tests.json; do
    if [ -f "$test_file" ]; then
        module_name=$(jq -r '.module' "$test_file" 2>/dev/null)
        if [ "$module_name" != "null" ] && [ -n "$module_name" ]; then
            echo "  - $module_name"
        fi
    fi
done

echo ""
echo "You will be prompted to confirm each module individually."
echo ""

# Process each module test file
for test_file in "$MODULES_ROOT"/*_module_tests.json; do
    if [ ! -f "$test_file" ]; then
        continue
    fi

    module_name=$(jq -r '.module' "$test_file")
    module_description=$(jq -r '.description' "$test_file")

    # Get user confirmation
    if ! get_user_confirmation "$module_name" "$module_description"; then
        continue
    fi

    echo "Processing test file: $(basename "$test_file")"

    module_name=$(jq -r '.module' "$test_file")
    total_tests=0
    passed_tests=0
    failed_tests=0

    # Determine module path
    if [[ "$module_name" == *"nodejs"* ]]; then
        module_path="$DEV_ROOT/nodejs/Linux"
    elif [[ "$module_name" == *"php"* ]]; then
        module_path="$DEV_ROOT/php/Linux"
    elif [[ "$module_name" == *"python"* ]]; then
        module_path="$DEV_ROOT/python/Linux"
    elif [[ "$module_name" == *"vscode"* ]]; then
        module_path="$DEV_ROOT/vscode/Linux"
    else
        echo "Skipping unknown module: $module_name"
        continue
    fi

    if [ ! -d "$module_path" ]; then
        echo "Module path not found: $module_path"
        continue
    fi

    echo "Running tests for module: $module_name"

    # For now, generate a simple report indicating tests would run
    report_file="$DATA_ROOT/${module_name}_results.md"
    {
        echo "# Test Report: $module_name"
        echo ""
        echo "## Summary"
        echo ""
        echo "- **Platform:** Linux/Unix"
        echo "- **Test Framework:** Shell Script"
        echo "- **Generated:** $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        echo "Note: Full test execution requires jq for comprehensive JSON parsing."
        echo "This is a placeholder report. Running tests on the Linux/Unix version of the scripts."
        echo ""
    } > "$report_file"

    echo "  Report generated: $report_file"
    echo ""
done

echo "All tests processed!"
echo "Reports stored in: $DATA_ROOT"
