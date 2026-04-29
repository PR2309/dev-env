#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEV_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

read_yes_no() {
    local prompt="$1"
    while true; do
        read -r -p "$prompt (y/n): " reply
        reply="${reply,,}"
        case "$reply" in
            y|yes) return 0 ;;
            n|no) return 1 ;;
            *) echo "Please enter y/yes or n/no." ;;
        esac
    done
}

detect_os_dir() {
    case "$(uname -s)" in
        Darwin) echo "Mac" ;;
        Linux) echo "Linux" ;;
        *) echo "" ;;
    esac
}

run_module() {
    local module_name="$1"
    local module_path="$2"
    shift 2
    local scripts=("$@")

    if ! read_yes_no "Do you want to restore $module_name"; then
        echo "Skipping $module_name."
        return
    fi

    for script_name in "${scripts[@]}"; do
        local script_path="$module_path/$script_name"
        if [[ ! -f "$script_path" ]]; then
            echo "Missing script: $script_path"
            continue
        fi

        if read_yes_no "Do you want to restore $script_name for $module_name"; then
            echo "Running $script_name..."
            bash "$script_path"
        else
            echo "Skipped $script_name."
        fi
    done
}

OS_DIR="$(detect_os_dir)"
if [[ -z "$OS_DIR" ]]; then
    echo "Unsupported OS for shell orchestrator."
    exit 1
fi

echo "Starting restore workflow..."

run_module "Node.js" "$DEV_ROOT/nodejs/$OS_DIR" \
    "restore-node.sh" \
    "restore-npm.sh" \
    "restore-npm-globals-json.sh" \
    "restore-npm-globals-text.sh"

run_module "Python" "$DEV_ROOT/python/$OS_DIR" \
    "restore-python-globals-json.sh" \
    "restore-python-globals-text.sh"

run_module "PHP/Composer" "$DEV_ROOT/php/$OS_DIR" \
    "restore-composer.sh" \
    "restore-composer-globals-json.sh" \
    "restore-composer-globals-text.sh"

run_module "VS Code" "$DEV_ROOT/vscode/$OS_DIR" \
    "restore-vscode.sh" \
    "restore-vscode-version.sh" \
    "restore-vscode-extensions.sh" \
    "restore-vscode-settings.sh" \
    "restore-vscode-keybindings.sh" \
    "restore-vscode-snippets.sh"

echo "Restore workflow completed."
